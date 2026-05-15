#!/usr/bin/env python3
"""
import_inbox.py - Import loose .txt CCL files into a categorized library.

Drop .txt files into Inbox/. Each run renames them to .sql, classifies them as
a Script (>= 5 code lines) or a Snippet (< 5), infers a category folder, writes
the file with a small provenance header, and deletes the source .txt.

Dedup: exact duplicates (by raw or normalized content hash) are skipped;
near-duplicates are parked in Inbox/review/ for manual decision. State lives in
.import-manifest.json and self-heals from the Scripts/ and Snippets/ trees.

Self-contained: single file, Python stdlib only. No imports from this repo's
other modules and no dependency on the "Script and Snippet Exports/" tree.

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
SCRIPTS = ROOT / "Scripts"
SNIPPETS = ROOT / "Snippets"
MANIFEST = ROOT / ".import-manifest.json"

SNIPPET_LINES = 5
MANIFEST_VERSION = 1
DEFAULT_SIMILARITY = 0.92
LENGTH_BAND = 0.25  # only compare near-dup candidates within +/-25% norm length

# ── Curated taxonomy: page-slug → category folder ─────────────────────────────
# Baked-in copy so this script has no cross-file dependency. Edit to extend.
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
    # Apps and Tools
    "application-launcher": "Apps and Tools",
    "blob-out": "Apps and Tools",
    "case-finder": "Apps and Tools",
    "case-finder-diagnosis": "Apps and Tools",
    "case-finder-events-and-orders": "Apps and Tools",
    "millennium-data-dictionary-builder": "Apps and Tools",
    "referral-management": "Apps and Tools",
    "referral-management-javascript": "Apps and Tools",
    "appointments-by-uic": "Apps and Tools",
    "blood-bank-inventory": "Apps and Tools",
    # MPages
    "medication-list": "MPages",
    "discern-developer": "MPages",
    # Orders and Scheduling
    "unknown-queue-and-scheduling-list": "Orders and Scheduling",
    # PowerForms
    "phadbtoolsexe-pharmacy-db-tools": "PowerForms",
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
    # Recipes
    "excluding-inactive-rows": "Recipes",
    "excluding-test-patients": "Recipes",
    "exists-not-exists": "Recipes",
    "exploding-event-sets": "Recipes",
    "inline-tables": "Recipes",
    "joins": "Recipes",
    "select-into": "Recipes",
    "union": "Recipes",
    "recursive-queries": "Recipes",
}

# ── Keyword scorer lexicon: category → distinctive substrings ─────────────────
# Order matters: earlier categories win ties. Matched case-insensitively as
# plain substrings (CCL identifiers and operators don't sit on \b boundaries).
KEYWORD_LEXICON = [
    ("Functions", [
        "uar_get_code_description", "uar_get_code_display", "uar_get_definition",
        "uar_get_displaykey", "band(", "concat(", "datetimediff(", "datetimecmp(",
        "datebirthformat(", "datedeceasedformat(", "regexplike(", "cnvtdatetime",
    ]),
    ("Audit Programs", [
        "audit", "usage report", "dm_info", "dm_query_history", "dm_audit",
    ]),
    ("PowerForms", [
        "powerform", "dcp_forms", "dcp_section", "dcp_input_ref", "dcp_grid",
    ]),
    ("MPages", [
        "mpage", "discern.execute", "getrecorddata", "<html", "br_datamart",
    ]),
    ("Orders and Scheduling", [
        "sch_appt", "sch_event", "order_status", "orders.activity_type",
        "sch_appt_slot",
    ]),
    ("Apps and Tools", [
        "drop program", "create program", "record reply", "record request",
        "with replace", "execute ",
    ]),
    ("Recipes", [
        "select into", "union all", "dummyt", "cross join", "connect by",
        "left join",
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


def infer_category(slug: str, content: str) -> tuple[str, str]:
    """Return (category, reason)."""
    # (a) slug lookup — try the full slug, then progressively shorter prefixes
    parts = slug.split("-")
    for end in range(len(parts), 0, -1):
        candidate = "-".join(parts[:end])
        if candidate in PAGE_TO_FOLDER:
            return PAGE_TO_FOLDER[candidate], "slug-map"

    # (b) existing-file match in the importer's own output trees
    for base in (SCRIPTS, SNIPPETS):
        if not base.exists():
            continue
        for cat_dir in base.iterdir():
            if not cat_dir.is_dir():
                continue
            if (cat_dir / f"{slug}.sql").exists():
                return cat_dir.name, "existing-match"

    # (c) keyword scorer
    lowered = content.lower()
    best_cat, best_score = None, 0
    for cat, keywords in KEYWORD_LEXICON:
        score = sum(1 for kw in keywords if kw in lowered)
        if score > best_score:
            best_cat, best_score = cat, score
    if best_cat and best_score >= 2:
        return best_cat, "keywords"

    # (d) fallback
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


def make_header(source_name: str, category: str, reason: str,
                lines: int, is_snippet: bool) -> str:
    today = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    classification = "Snippet" if is_snippet else "Script"
    return (
        "/*\n"
        f" * Imported from : {source_name}\n"
        f" * Imported on   : {today}\n"
        f" * Category      : {category}  (reason: {reason})\n"
        f" * Lines         : {lines}\n"
        f" * Classification: {classification}\n"
        " */\n\n"
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
    is_snippet = path.parts[-3] == "Snippets" if len(path.parts) >= 3 else False
    return {
        "source_filename": path.name,
        "target_path": rel,
        "category": path.parent.name,
        "category_reason": "reindex",
        "is_snippet": rel.startswith("Snippets/"),
        "lines": count_code_lines(raw),
        "raw_hash": sha256(strip_leading_header(raw)),
        "norm_hash": sha256(norm),
        "norm_content_len": len(norm),
        "imported_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    }


def scan_library() -> list[dict]:
    entries = []
    for base in (SCRIPTS, SNIPPETS):
        if not base.exists():
            continue
        for sql in sorted(base.rglob("*.sql")):
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
def process_file(txt: Path, manifest: dict, args) -> str:
    """Import one .txt file. Returns a one-line status string."""
    raw = txt.read_text(encoding="utf-8", errors="replace")
    body = strip_leading_header(raw)
    raw_hash = sha256(body)
    norm = normalize(raw)
    norm_hash = sha256(norm)

    # exact-dup check
    for e in manifest["entries"]:
        if e["raw_hash"] == raw_hash or e["norm_hash"] == norm_hash:
            if not args.dry_run and not args.keep:
                txt.unlink()
            return f"EXACT-DUP   {txt.name}  ->  {e['target_path']}"

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
            dest = REVIEW / f"{txt.stem}__similar-to-{existing_slug}.txt"
            txt.rename(dest)
        return (f"NEAR-DUP    {txt.name}  ({best_ratio:.2f})  ->  {best_target}"
                f"  [moved to Inbox/review/]")

    # classify + categorize
    slug = slugify(txt.stem)
    lines = count_code_lines(raw)
    is_snippet = lines < SNIPPET_LINES
    category, reason = infer_category(slug, body)

    base = SNIPPETS if is_snippet else SCRIPTS
    folder = base / category
    target = unique_target(folder, slug)
    rel = target.relative_to(ROOT).as_posix()

    if args.dry_run:
        kind = "Snippet" if is_snippet else "Script"
        return f"PLAN        {txt.name}  ->  {rel}  ({kind}, {lines} ln, {reason})"

    header = make_header(txt.name, category, reason, lines, is_snippet)
    folder.mkdir(parents=True, exist_ok=True)
    target.write_text(header + body.rstrip() + "\n", encoding="utf-8")

    entry = {
        "source_filename": txt.name,
        "target_path": rel,
        "category": category,
        "category_reason": reason,
        "is_snippet": is_snippet,
        "lines": lines,
        "raw_hash": raw_hash,
        "norm_hash": norm_hash,
        "norm_content_len": norm_len,
        "imported_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    }
    entry["_norm_content"] = norm  # in-memory only; stripped before save
    manifest["entries"].append(entry)

    if not args.keep:
        txt.unlink()

    kind = "Snippet" if is_snippet else "Script"
    return f"IMPORTED    {txt.name}  ->  {rel}  ({kind}, {lines} ln, {reason})"


def main():
    parser = argparse.ArgumentParser(
        description="Import loose .txt CCL files into categorized Scripts/Snippets."
    )
    parser.add_argument("--dry-run", action="store_true",
                        help="Show the plan; write, move, and delete nothing.")
    parser.add_argument("--keep", action="store_true",
                        help="Import but do not delete source .txt files.")
    parser.add_argument("--similarity", type=float, default=DEFAULT_SIMILARITY,
                        help=f"Near-dup ratio threshold (default {DEFAULT_SIMILARITY}).")
    parser.add_argument("--reindex", action="store_true",
                        help="Rebuild the manifest from the Scripts/ and Snippets/ trees, then exit.")
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

    txt_files = sorted(INBOX.glob("*.txt"))
    if not txt_files:
        print("No files to import (Inbox/ has no .txt files).")
        # Still persist any self-heal additions.
        _persist(manifest, args)
        return

    print(f"Found {len(txt_files)} .txt file(s) in Inbox/"
          + ("  (DRY RUN)" if args.dry_run else ""))
    print("=" * 72)

    counts = {"IMPORTED": 0, "EXACT-DUP": 0, "NEAR-DUP": 0, "PLAN": 0}
    for txt in txt_files:
        status = process_file(txt, manifest, args)
        print(f"  {status}")
        counts[status.split()[0]] = counts.get(status.split()[0], 0) + 1

    print("=" * 72)
    if args.dry_run:
        print(f"DRY RUN: {counts['PLAN']} would import, "
              f"{counts['EXACT-DUP']} exact-dup, {counts['NEAR-DUP']} near-dup.")
    else:
        print(f"Done: {counts['IMPORTED']} imported, "
              f"{counts['EXACT-DUP']} exact-dup skipped, "
              f"{counts['NEAR-DUP']} near-dup parked in Inbox/review/.")
        _persist(manifest, args)


def _persist(manifest: dict, args) -> None:
    if args.dry_run:
        return
    # Strip in-memory-only fields before writing.
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
