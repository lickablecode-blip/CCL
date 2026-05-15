#!/usr/bin/env python3
"""
export_scripts.py - Extract every CCL/SQL code block from the OneNote MHT
export and write each one as an individual .sql file inside a categorized
folder structure under "Script and Snippet Exports/".

Re-runnable: every run fully regenerates the output tree.

Usage:
  python3 export_scripts.py [--dry-run]
"""

import argparse
import random
import re
import shutil
import sys
import textwrap
from collections import defaultdict
from pathlib import Path
from urllib.parse import quote

from bs4 import BeautifulSoup

import parse_onenote as po

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

ROOT = Path(__file__).parent
OUT_ROOT = ROOT / "Script and Snippet Exports"
SNIPPET_LINES = 5

# ── Curated taxonomy ──────────────────────────────────────────────────────────
# Maps page-slug → folder name. Unmapped slugs fall through to "Misc".
# User reviews and revises folder names to match GitLab repo conventions.
PAGE_TO_FOLDER = {
    # ── Audit Programs ────────────────────────────────────────────
    "application-access-audit":           "Audit Programs",
    "code-set-audit":                     "Audit Programs",
    "discern-access-structure-and-usage": "Audit Programs",
    "dta-detail-audit":                   "Audit Programs",
    "encounter-detail-audit":             "Audit Programs",
    "facility-detail-audit":              "Audit Programs",
    "order-detail-audit":                 "Audit Programs",
    "personnel-detail-audit":             "Audit Programs",
    "powerform-detail-audit":             "Audit Programs",
    "scheduling-requests-audit":          "Audit Programs",

    # ── Apps and Tools ────────────────────────────────────────────
    "application-launcher":               "Apps and Tools",
    "blob-out":                           "Apps and Tools",
    "case-finder":                        "Apps and Tools",
    "case-finder-diagnosis":              "Apps and Tools",
    "case-finder-events-and-orders":      "Apps and Tools",
    "millennium-data-dictionary-builder": "Apps and Tools",
    "referral-management":                "Apps and Tools",
    "referral-management-javascript":     "Apps and Tools",
    "appointments-by-uic":                "Apps and Tools",
    "blood-bank-inventory":               "Apps and Tools",

    # ── MPages ────────────────────────────────────────────────────
    "medication-list":                    "MPages",
    "discern-developer":                  "MPages",

    # ── Orders and Scheduling ─────────────────────────────────────
    "unknown-queue-and-scheduling-list":  "Orders and Scheduling",

    # ── PowerForms ────────────────────────────────────────────────
    "phadbtoolsexe-pharmacy-db-tools":    "PowerForms",  # FUZZY — user verify

    # ── Data Model ────────────────────────────────────────────────
    "agency":                             "Data Model",
    "births":                             "Data Model",
    "charges-charge-mods":                "Data Model",
    "contact-information":                "Data Model",
    "cspricingtool-bill-item":            "Data Model",
    "cust-loc-agency-reltn":              "Data Model",
    "diagnosis":                          "Data Model",
    "discrete-task-assays-dta":           "Data Model",
    "document-events-wip":                "Data Model",
    "dta-using-nomenclature":             "Data Model",
    "favorites":                          "Data Model",
    "flags":                              "Data Model",
    "health-plans":                       "Data Model",
    "labs":                               "Data Model",
    "laboratory-results":                 "Data Model",
    "length-of-stay-los":                 "Data Model",
    "location-associations":              "Data Model",
    "metadata":                           "Data Model",
    "procedures":                         "Data Model",
    "surgical-cases":                     "Data Model",
    "table-indexes":                      "Data Model",
    "db-item-location-maintenance":       "Data Model",

    # ── CCL Reference ─────────────────────────────────────────────
    "blob-data-wip":                      "CCL Reference",
    "blob-notes-scratch":                 "CCL Reference",
    "conditional-clauses-parser":         "CCL Reference",
    "dummyt-tables-2":                    "CCL Reference",
    "evaluate":                           "CCL Reference",
    "go-to":                              "CCL Reference",
    "html-output":                        "CCL Reference",
    "one-level":                          "CCL Reference",
    "two-levels":                         "CCL Reference",
    "three-levels":                       "CCL Reference",
    "program-template":                   "CCL Reference",
    "with-clause-control-options":        "CCL Reference",
    "git-repo-structure":                 "CCL Reference",

    # ── Functions ─────────────────────────────────────────────────
    "band-bitwise-and":                   "Functions",
    "build":                              "Functions",
    "concat":                             "Functions",
    "datebirthformat":                    "Functions",
    "datedeceasedformat":                 "Functions",
    "datetimecmp":                        "Functions",
    "datetimediff":                       "Functions",
    "date-and-time-zones":                "Functions",
    "working-with-time-zones":            "Functions",
    "format":                             "Functions",
    "regexplike":                         "Functions",
    "uar-get-code-description":           "Functions",
    "uar-get-code-display":               "Functions",
    "uar-get-definition":                 "Functions",
    "uar-get-displaykey":                 "Functions",
    "eval-elh-change-bit":                "Functions",
    "replace-crlf":                       "Functions",

    # ── Recipes ───────────────────────────────────────────────────
    "excluding-inactive-rows":            "Recipes",
    "excluding-test-patients":            "Recipes",
    "exists-not-exists":                  "Recipes",
    "exploding-event-sets":               "Recipes",
    "inline-tables":                      "Recipes",
    "joins":                              "Recipes",
    "select-into":                        "Recipes",
    "union":                              "Recipes",
    "recursive-queries":                  "Recipes",
}


# ── core helpers ──────────────────────────────────────────────────────────────
def comment_header(
    title: str,
    slug: str,
    anchor: str,
    block_idx: int,
    block_total: int,
    lang: str,
    line_count: int,
    context: str,
) -> str:
    safe_context = (context or "").replace("*/", "* /").strip()
    if safe_context:
        wrapped = textwrap.fill(
            safe_context,
            width=92,
            initial_indent=" *   ",
            subsequent_indent=" *   ",
        )
    else:
        wrapped = " *   (no preceding paragraph)"

    anchor_display = anchor if anchor else "(top of page)"
    lang_display = lang if lang else "unknown"

    return (
        "/*\n"
        f" * Source page  : {title}\n"
        f" * Source file  : output/{slug}.md\n"
        f" * Anchor       : {anchor_display}\n"
        f" * Block index  : {block_idx} of {block_total}\n"
        f" * Detected lang: {lang_display}\n"
        f" * Lines        : {line_count}\n"
        " *\n"
        " * Context (preceding paragraph):\n"
        f"{wrapped}\n"
        " *\n"
        " * Exported by export_scripts.py from Development-Shared.mht\n"
        " */\n\n"
    )


def block_filename(page_slug: str, block_idx: int, anchor: str, page_title: str, is_snippet: bool) -> str:
    base = po.slugify(anchor) if anchor else po.slugify(page_title)
    suffix = "_snippet" if is_snippet else ""
    return f"{page_slug}__{block_idx:02d}-{base}{suffix}.sql"


# ── main ──────────────────────────────────────────────────────────────────────
def main():
    parser = argparse.ArgumentParser(description="Export OneNote CCL/SQL blocks → .sql files")
    parser.add_argument("--dry-run", action="store_true", help="List planned files, write nothing")
    args = parser.parse_args()

    print(f"Reading {po.MHT_PATH} ({po.MHT_PATH.stat().st_size / 1e6:.1f} MB)…")
    html, img_map = po.parse_mht(po.MHT_PATH)

    print("Parsing HTML…")
    soup = BeautifulSoup(html, "lxml")
    for tag in soup.find_all(re.compile(r"^(o:|v:|w:|dt:)", re.I)):
        tag.decompose()
    for el in soup.find_all("span"):
        if "mso-spacerun" in (el.get("style") or ""):
            el.replace_with(" ")

    pages = po.extract_pages(soup)
    print(f"  Pages found: {len(pages)}")

    # Wipe prior output for a clean regeneration (only when actually writing)
    if not args.dry_run and OUT_ROOT.exists():
        shutil.rmtree(OUT_ROOT)

    slug_counts: dict[str, int] = defaultdict(int)
    # Each manifest row: dict with folder, page_slug, page_title, page_md, filename,
    # anchor, lang, lines, is_snippet, block_idx, block_total
    manifest: list[dict] = []
    unmapped: set[str] = set()

    for title, page_div in pages:
        slug_base = po.slugify(title)
        slug_counts[slug_base] += 1
        page_slug = slug_base if slug_counts[slug_base] == 1 else f"{slug_base}-{slug_counts[slug_base]}"

        _md, code_blocks, _gl, _drop, _imgs = po.convert_page(
            list(page_div.children), page_slug, img_map, verbose=False, dry_run=True
        )
        # Drop empty blocks defensively (parse_onenote already mostly avoids them)
        code_blocks = [cb for cb in code_blocks if cb.get("code", "").strip()]
        if not code_blocks:
            continue

        folder = PAGE_TO_FOLDER.get(page_slug, "Misc")
        if folder == "Misc":
            unmapped.add(page_slug)

        block_total = len(code_blocks)
        for i, cb in enumerate(code_blocks, start=1):
            code = cb["code"]
            lines = code.strip().splitlines()
            line_count = len(lines)
            is_snippet = line_count < SNIPPET_LINES

            fname = block_filename(page_slug, i, cb.get("anchor", ""), title, is_snippet)
            target_dir = OUT_ROOT / folder
            target_path = target_dir / fname

            header = comment_header(
                title=title,
                slug=page_slug,
                anchor=cb.get("anchor", ""),
                block_idx=i,
                block_total=block_total,
                lang=cb.get("lang", ""),
                line_count=line_count,
                context=cb.get("context", ""),
            )
            file_content = header + code.rstrip() + "\n"

            row = {
                "folder": folder,
                "page_slug": page_slug,
                "page_title": title,
                "page_md": f"output/{page_slug}.md",
                "filename": fname,
                "anchor": cb.get("anchor", ""),
                "lang": cb.get("lang", "") or "unknown",
                "lines": line_count,
                "is_snippet": is_snippet,
                "block_idx": i,
                "block_total": block_total,
                "rel_path": f"{folder}/{fname}",
            }
            manifest.append(row)

            if args.dry_run:
                print(f"  PLAN  {row['rel_path']}  ({row['lang']}, {line_count} lines)")
            else:
                target_dir.mkdir(parents=True, exist_ok=True)
                target_path.write_text(file_content, encoding="utf-8")

    # ── INDEX.md ─────────────────────────────────────────────────────────────
    if not args.dry_run:
        write_index(manifest)

    print_summary(manifest, unmapped, args.dry_run)


def write_index(manifest: list[dict]) -> None:
    by_folder: dict[str, list[dict]] = defaultdict(list)
    for row in manifest:
        by_folder[row["folder"]].append(row)

    total_files = len(manifest)
    folders = sorted(by_folder.keys(), key=str.lower)

    lines = [
        "# Script and Snippet Exports",
        "",
        "_Auto-generated by `export_scripts.py` from `Development-Shared.mht`._",
        "",
        f"**{total_files} code blocks** across **{len({r['page_slug'] for r in manifest})} source pages**, "
        f"organized into **{len(folders)} folders**.",
        "",
    ]

    for folder in folders:
        rows = by_folder[folder]
        lines.append(f"## {folder} ({len(rows)} files)")
        lines.append("")

        # Group by source page (preserve source order = first-seen order)
        by_page: dict[str, list[dict]] = defaultdict(list)
        page_order: list[str] = []
        for r in rows:
            if r["page_slug"] not in by_page:
                page_order.append(r["page_slug"])
            by_page[r["page_slug"]].append(r)

        for page_slug in page_order:
            page_rows = by_page[page_slug]
            page_title = page_rows[0]["page_title"]
            page_md = page_rows[0]["page_md"]
            lines.append(f"### {page_title} ([{page_md}](../{page_md}))")
            for r in page_rows:
                snippet_flag = " _snippet_" if r["is_snippet"] else ""
                href = f"{quote(r['folder'])}/{quote(r['filename'])}"
                lines.append(
                    f"- [{r['filename']}]({href}) — {r['lang']}, {r['lines']} lines{snippet_flag}"
                )
            lines.append("")

    (OUT_ROOT / "INDEX.md").write_text("\n".join(lines) + "\n", encoding="utf-8")


def print_summary(manifest: list[dict], unmapped: set[str], dry_run: bool) -> None:
    total = len(manifest)
    snippet_count = sum(1 for r in manifest if r["is_snippet"])
    folders = sorted({r["folder"] for r in manifest}, key=str.lower)
    pages = {r["page_slug"] for r in manifest}

    print()
    print("=" * 60)
    print("EXPORT SUMMARY" + ("  (DRY RUN)" if dry_run else ""))
    print("=" * 60)
    print(f"  Total files       : {total}")
    print(f"  Source pages      : {len(pages)}")
    print(f"  Snippet files     : {snippet_count}  (<{SNIPPET_LINES} lines)")
    print(f"  Folders           : {len(folders)}")
    for f in folders:
        n = sum(1 for r in manifest if r["folder"] == f)
        print(f"    - {f}  ({n} files)")

    if unmapped:
        print()
        print(f"  ⚠ Unmapped pages routed to Misc/ ({len(unmapped)}):")
        for s in sorted(unmapped):
            n = sum(1 for r in manifest if r["page_slug"] == s)
            print(f"    - {s}  ({n} files) — add to PAGE_TO_FOLDER and re-run")

    if not dry_run:
        # Random sample: print first 20 lines of 3 random files from 3 different folders
        print()
        print("  Sample headers (3 random files from different folders):")
        if len(folders) >= 3:
            chosen_folders = random.sample(folders, 3)
        else:
            chosen_folders = folders
        for f in chosen_folders:
            candidates = [r for r in manifest if r["folder"] == f]
            if not candidates:
                continue
            r = random.choice(candidates)
            path = OUT_ROOT / r["folder"] / r["filename"]
            print(f"\n    --- {r['rel_path']} ---")
            try:
                head = path.read_text(encoding="utf-8").splitlines()[:14]
                for line in head:
                    print(f"    {line}")
            except OSError as e:
                print(f"    (could not read: {e})")

    print()
    print("Done.")


if __name__ == "__main__":
    main()
