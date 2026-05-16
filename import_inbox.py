#!/usr/bin/env python3
"""
import_inbox.py - Import loose CCL files into a categorized output library.

Drop .txt/.prg files into Inbox/ subdirectories. Each run renames them to
.sql, classifies them into an output/ category folder using the Inbox
subfolder name as the primary signal, writes the file with a provenance
header, and deletes the source file.

Dedup: exact duplicates (by raw or normalized content hash) are skipped;
near-duplicates are parked in Inbox/review/ for manual decision. State lives
in .import-manifest.json and self-heals from the output/ tree.

Self-contained: single file, Python stdlib only.

Usage:
  python3 import_inbox.py [--dry-run] [--keep] [--similarity 0.92] [--reindex]
"""

import argparse
import difflib
import hashlib
import json
import os
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

ROOT = Path(__file__).parent
INBOX = ROOT / "Inbox"
REVIEW = INBOX / "review"
OUTPUT = ROOT / "output"
MANIFEST = ROOT / ".import-manifest.json"

MANIFEST_VERSION = 2
DEFAULT_SIMILARITY = 0.92
LENGTH_BAND = 0.25  # only compare near-dup candidates within +/-25% norm length

IMPORTABLE_EXTS = {".txt", ".prg"}

# ── Inbox subfolder → output category (highest-priority classification signal) ─
SUBFOLDER_CATEGORY = {
    "mPages":            "MPages",
    "Notes & Templates": "PowerForms",
    "Orders":            "Orders & Scheduling",
    "PathNet":           "PathNet",
    "Positions":         "Audit Programs",
    "PowerForms":        "PowerForms",
    "Rules & Alerts":    "Rules & Alerts",
}

# ── Curated taxonomy: page-slug → category folder ─────────────────────────────
PAGE_TO_FOLDER = {
    # Audit Programs
    "application-access-audit": "Audit Programs",
    "code-set-audit": "Audit Programs",
    "discern-access-structure-and-usage": "Audit Programs",
    "dta-detail-audit": "Audit Programs",
    "encounter-detail-audit": "Audit Programs",
    "facility-detail-audit": "Audit Programs",
    "order-detail-audit": "Audit Programs",
    "personnel-detail-audit": "Audit Programs",
    "powerform-detail-audit": "Audit Programs",
    "scheduling-requests-audit": "Audit Programs",
    # MPages
    "medication-list": "MPages",
    "discern-developer": "MPages",
    "mpage-component": "MPages",
    "mpage-filter": "MPages",
    "mpage-document": "MPages",
    "viewpoint": "MPages",
    "master-mpage-query": "MPages",
    # Orders & Scheduling
    "unknown-queue-and-scheduling-list": "Orders & Scheduling",
    "order-activity": "Orders & Scheduling",
    "quick-visit": "Orders & Scheduling",
    "virtual-viewing-orders": "Orders & Scheduling",
    "retail-pharmacy": "Orders & Scheduling",
    # PowerForms
    "phadbtoolsexe-pharmacy-db-tools": "PowerForms",
    "note-type": "PowerForms",
    "note-template": "PowerForms",
    "smart-template": "PowerForms",
    "powerform": "PowerForms",
    "task-catalog": "PowerForms",
    # Data Model
    "agency": "Data Model",
    "births": "Data Model",
    "charges-charge-mods": "Data Model",
    "contact-information": "Data Model",
    "cspricingtool-bill-item": "Data Model",
    "cust-loc-agency-reltn": "Data Model",
    "diagnosis": "Data Model",
    "discrete-task-assays-dta": "Data Model",
    "document-events-wip": "Data Model",
    "dta-using-nomenclature": "Data Model",
    "favorites": "Data Model",
    "flags": "Data Model",
    "health-plans": "Data Model",
    "labs": "Data Model",
    "laboratory-results": "Data Model",
    "length-of-stay-los": "Data Model",
    "location-associations": "Data Model",
    "metadata": "Data Model",
    "procedures": "Data Model",
    "surgical-cases": "Data Model",
    "table-indexes": "Data Model",
    "db-item-location-maintenance": "Data Model",
    # CCL Reference
    "blob-data-wip": "CCL Reference",
    "blob-notes-scratch": "CCL Reference",
    "conditional-clauses-parser": "CCL Reference",
    "dummyt-tables-2": "CCL Reference",
    "evaluate": "CCL Reference",
    "go-to": "CCL Reference",
    "html-output": "CCL Reference",
    "one-level": "CCL Reference",
    "two-levels": "CCL Reference",
    "three-levels": "CCL Reference",
    "program-template": "CCL Reference",
    "with-clause-control-options": "CCL Reference",
    "git-repo-structure": "CCL Reference",
    # Functions
    "band-bitwise-and": "Functions",
    "build": "Functions",
    "concat": "Functions",
    "datebirthformat": "Functions",
    "datedeceasedformat": "Functions",
    "datetimecmp": "Functions",
    "datetimediff": "Functions",
    "date-and-time-zones": "Functions",
    "working-with-time-zones": "Functions",
    "format": "Functions",
    "regexplike": "Functions",
    "uar-get-code-description": "Functions",
    "uar-get-code-display": "Functions",
    "uar-get-definition": "Functions",
    "uar-get-displaykey": "Functions",
    "eval-elh-change-bit": "Functions",
    "replace-crlf": "Functions",
    # PathNet
    "orderable-audit": "PathNet",
    "dta-evt-cd-audit": "PathNet",
    "qc-rules-audit": "PathNet",
}

# ── Keyword scorer lexicon: category → distinctive substrings ─────────────────
KEYWORD_LEXICON = [
    ("PathNet", [
        "order_catalog", "dup_checking", "order_catalog_synonym",
        "assay_processing_r", "dta_", "qc_rules", "lab_sect",
        "orderable_type_flag", "mig_imp", "mig_run",
    ]),
    ("Functions", [
        "uar_get_code_description", "uar_get_code_display", "uar_get_definition",
        "uar_get_displaykey", "band(", "concat(", "datetimediff(", "datetimecmp(",
        "datebirthformat(", "decdeceasedformat(", "regexplike(", "cnvtdatetime",
    ]),
    ("Audit Programs", [
        "audit", "usage report", "dm_info", "dm_query_history", "dm_audit",
    ]),
    ("PowerForms", [
        "powerform", "dcp_forms", "dcp_section", "dcp_input_ref", "dcp_grid",
        "note_type", "dd_ref_template", "dd_ref_emr_content",
    ]),
    ("MPages", [
        "mpage", "discern.execute", "getrecorddata", "<html", "br_datamart",
        "br_datamart_flex", "br_datamart_component",
    ]),
    ("Orders & Scheduling", [
        "sch_appt", "sch_event", "order_status", "orders.activity_type",
        "sch_appt_slot",
    ]),
    ("Rules & Alerts", [
        "special_duty", "rule_def", "ntt_alert", "alert_",
    ]),
    ("Data Model", [
        "clinical_event", "code_value_outcome", "code_value", "encntr_id",
        "person_id", "encounter ", "health_plan", "order_id",
    ]),
    ("CCL Reference", [
        "evaluate2(", "evaluate(", "go to ", "#exit_program", "endif",
    ]),
]


# ── helpers ───────────────────────────────────────────────────────────────────
def slugify(text: str) -> str:
    text = text.lower().strip()
    text = re.sub(r"[^\w\s-]", "", text)
    text = re.sub(r"[\s_]+", "-", text)
    text = re.sub(r"-+", "-", text)
    return text[:80].strip("-") or "untitled"


def strip_leading_header(text: str) -> str:
    """Remove a leading /* ... */ block (the provenance header we write)."""
    m = re.match(r"\s*/\*.*?\*/\s*", text, flags=re.S)
    return text[m.end():] if m else text


def normalize(text: str) -> str:
    """Lossy normalization for content hashing and similarity comparison."""
    text = strip_leading_header(text)
    text = re.sub(r"/\*.*?\*/", " ", text, flags=re.S)
    text = re.sub(r";.*?$", " ", text, flags=re.M)
    text = text.lower()
    text = re.sub(r"\s+", " ", text).strip()
    return text


def sha256(text: str) -> str:
    return "sha256:" + hashlib.sha256(text.encode("utf-8", "replace")).hexdigest()


def count_code_lines(text: str) -> int:
    body = strip_leading_header(text).strip()
    return sum(1 for ln in body.splitlines() if ln.strip())


def infer_category(slug: str, content: str, subfolder: str = "") -> tuple[str, str]:
    """Return (category, reason). Subfolder name is the highest-priority signal."""
    # (a) subfolder hint
    if subfolder and subfolder in SUBFOLDER_CATEGORY:
        return SUBFOLDER_CATEGORY[subfolder], "subfolder"

    # (b) slug lookup — try full slug, then progressively shorter prefixes
    parts = slug.split("-")
    for end in range(len(parts), 0, -1):
        candidate = "-".join(parts[:end])
        if candidate in PAGE_TO_FOLDER:
            return PAGE_TO_FOLDER[candidate], "slug-map"

    # (c) existing-file match in the output tree
    if OUTPUT.exists():
        for cat_dir in OUTPUT.iterdir():
            if not cat_dir.is_dir():
                continue
            if (cat_dir / f"{slug}.sql").exists():
                return cat_dir.name, "existing-match"

    # (d) keyword scorer
    lowered = content.lower()
    best_cat, best_score = None, 0
    for cat, keywords in KEYWORD_LEXICON:
        score = sum(1 for kw in keywords if kw in lowered)
        if score > best_score:
            best_cat, best_score = cat, score
    if best_cat and best_score >= 2:
        return best_cat, "keywords"

    return "Misc", "fallback"


def unique_target(folder: Path, slug: str) -> Path:
    """Resolve filename collisions by appending -2, -3, ..."""
    candidate = folder / f"{slug}.sql"
    if not candidate.exists():
        return candidate
    n = 2
    while True:
        candidate = folder / f"{slug}-{n}.sql"
        if not candidate.exists():
            return candidate
        n += 1


def make_header(stem: str, source_name: str, category: str, reason: str,
                lines: int) -> str:
    today = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    return (
        "/*\n"
        f"* Name:     {stem}\n"
        f"* Source:   {source_name}\n"
        "* Purpose:\n"
        f"* Imported: {today}\n"
        f"* Category: {category}  (reason: {reason})\n"
        f"* Lines:    {lines}\n"
        "* Notes:\n"
        "*/\n\n"
    )


# ── manifest ──────────────────────────────────────────────────────────────────
def load_manifest() -> dict:
    if MANIFEST.exists():
        try:
            data = json.loads(MANIFEST.read_text(encoding="utf-8"))
            if isinstance(data, dict) and "entries" in data:
                return data
        except (json.JSONDecodeError, OSError):
            pass
    return {"version": MANIFEST_VERSION, "entries": []}


def save_manifest(manifest: dict) -> None:
    manifest["version"] = MANIFEST_VERSION
    tmp = MANIFEST.with_suffix(".json.tmp")
    tmp.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    os.replace(tmp, MANIFEST)


def entry_from_file(path: Path) -> dict:
    """Build a manifest entry for an already-imported .sql file."""
    raw = path.read_text(encoding="utf-8", errors="replace")
    norm = normalize(raw)
    rel = path.relative_to(ROOT).as_posix()
    return {
        "source_filename": path.name,
        "target_path": rel,
        "category": path.parent.name,
        "category_reason": "reindex",
        "lines": count_code_lines(raw),
        "raw_hash": sha256(strip_leading_header(raw)),
        "norm_hash": sha256(norm),
        "norm_content_len": len(norm),
        "imported_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    }


def scan_library() -> list[dict]:
    entries = []
    if not OUTPUT.exists():
        return entries
    for sql in sorted(OUTPUT.rglob("*.sql")):
        entries.append(entry_from_file(sql))
    return entries


def heal_manifest(manifest: dict, reindex: bool) -> dict:
    """Rebuild or top up the manifest from the on-disk library."""
    on_disk = scan_library()
    if reindex:
        manifest["entries"] = on_disk
        return manifest

    known = {e["target_path"] for e in manifest["entries"]}
    added = [e for e in on_disk if e["target_path"] not in known]
    if added:
        manifest["entries"].extend(added)
        print(f"  Self-heal: added {len(added)} untracked library file(s) to manifest.")
    return manifest


# ── main import loop ──────────────────────────────────────────────────────────
def process_file(src: Path, manifest: dict, args, subfolder: str = "") -> str:
    """Import one CCL source file. Returns a one-line status string."""
    # .prg files carry an existing Cerner copyright header — preserve it as-is.
    is_prg = src.suffix.lower() == ".prg"

    raw = src.read_text(encoding="utf-8", errors="replace")
    body = raw if is_prg else strip_leading_header(raw)
    raw_hash = sha256(body)
    norm = normalize(raw)
    norm_hash = sha256(norm)

    # exact-dup check
    for e in manifest["entries"]:
        if e["raw_hash"] == raw_hash or e["norm_hash"] == norm_hash:
            if not args.dry_run and not args.keep:
                src.unlink()
            return f"EXACT-DUP   {src.name}  ->  {e['target_path']}"

    # near-dup check
    norm_len = len(norm)
    best_ratio, best_target = 0.0, None
    for e in manifest["entries"]:
        elen = e.get("norm_content_len", 0)
        if elen == 0:
            continue
        if abs(elen - norm_len) > LENGTH_BAND * max(elen, norm_len):
            continue
        e_norm = e.get("_norm_content")
        if e_norm is None:
            continue
        ratio = difflib.SequenceMatcher(None, norm, e_norm).ratio()
        if ratio > best_ratio:
            best_ratio, best_target = ratio, e["target_path"]
    if best_target and best_ratio >= args.similarity:
        existing_slug = Path(best_target).stem
        if not args.dry_run:
            REVIEW.mkdir(parents=True, exist_ok=True)
            dest = REVIEW / f"{src.stem}__similar-to-{existing_slug}.txt"
            src.rename(dest)
        return (f"NEAR-DUP    {src.name}  ({best_ratio:.2f})  ->  {best_target}"
                f"  [moved to Inbox/review/]")

    # classify + categorize
    slug = slugify(src.stem)
    lines = count_code_lines(raw)
    category, reason = infer_category(slug, body, subfolder)

    folder = OUTPUT / category
    target = unique_target(folder, slug)
    rel = target.relative_to(ROOT).as_posix()

    try:
        source_display = src.relative_to(ROOT).as_posix()
    except ValueError:
        source_display = src.name

    if args.dry_run:
        return f"PLAN        {src.name}  ->  {rel}  ({lines} ln, {reason})"

    header = make_header(src.stem, source_display, category, reason, lines)
    folder.mkdir(parents=True, exist_ok=True)
    target.write_text(header + body.rstrip() + "\n", encoding="utf-8")

    entry = {
        "source_filename": src.name,
        "target_path": rel,
        "category": category,
        "category_reason": reason,
        "lines": lines,
        "raw_hash": raw_hash,
        "norm_hash": norm_hash,
        "norm_content_len": norm_len,
        "imported_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    }
    entry["_norm_content"] = norm  # in-memory only; stripped before save
    manifest["entries"].append(entry)

    if not args.keep:
        src.unlink()

    return f"IMPORTED    {src.name}  ->  {rel}  ({lines} ln, {reason})"


def main():
    parser = argparse.ArgumentParser(
        description=(
            "Import CCL .txt/.prg files from Inbox/ subdirectories into "
            "output/ category folders as .sql files."
        )
    )
    parser.add_argument("--dry-run", action="store_true",
                        help="Show the plan; write, move, and delete nothing.")
    parser.add_argument("--keep", action="store_true",
                        help="Import but do not delete source files.")
    parser.add_argument("--similarity", type=float, default=DEFAULT_SIMILARITY,
                        help=f"Near-dup ratio threshold (default {DEFAULT_SIMILARITY}).")
    parser.add_argument("--reindex", action="store_true",
                        help="Rebuild the manifest from the output/ tree, then exit.")
    args = parser.parse_args()

    INBOX.mkdir(exist_ok=True)

    manifest = load_manifest()

    if args.reindex:
        manifest = heal_manifest(manifest, reindex=True)
        save_manifest(manifest)
        print(f"Reindexed: manifest now tracks {len(manifest['entries'])} library file(s).")
        return

    manifest = heal_manifest(manifest, reindex=False)

    # Load normalized content for near-dup comparison (in-memory only).
    for e in manifest["entries"]:
        if "_norm_content" not in e:
            p = ROOT / e["target_path"]
            if p.exists():
                e["_norm_content"] = normalize(p.read_text(encoding="utf-8", errors="replace"))
            else:
                e["_norm_content"] = None

    # Collect all importable files from Inbox/ (recurse into subdirectories).
    src_files = sorted(
        p for p in INBOX.rglob("*")
        if p.is_file()
        and p.suffix.lower() in IMPORTABLE_EXTS
        and "review" not in p.parts
    )

    if not src_files:
        print("No files to import (Inbox/ has no .txt or .prg files).")
        _persist(manifest, args)
        return

    print(f"Found {len(src_files)} file(s) in Inbox/"
          + ("  (DRY RUN)" if args.dry_run else ""))
    print("=" * 72)

    counts: dict[str, int] = {}
    for src in src_files:
        subfolder = src.parent.name if src.parent != INBOX else ""
        status = process_file(src, manifest, args, subfolder)
        print(f"  {status}")
        key = status.split()[0]
        counts[key] = counts.get(key, 0) + 1

    print("=" * 72)
    if args.dry_run:
        print(f"DRY RUN: {counts.get('PLAN', 0)} would import, "
              f"{counts.get('EXACT-DUP', 0)} exact-dup, "
              f"{counts.get('NEAR-DUP', 0)} near-dup.")
    else:
        print(f"Done: {counts.get('IMPORTED', 0)} imported, "
              f"{counts.get('EXACT-DUP', 0)} exact-dup skipped, "
              f"{counts.get('NEAR-DUP', 0)} near-dup parked in Inbox/review/.")
        _persist(manifest, args)


def _persist(manifest: dict, args) -> None:
    if args.dry_run:
        return
    clean = {
        "version": MANIFEST_VERSION,
        "entries": [
            {k: v for k, v in e.items() if not k.startswith("_")}
            for e in manifest["entries"]
        ],
    }
    save_manifest(clean)


if __name__ == "__main__":
    main()
