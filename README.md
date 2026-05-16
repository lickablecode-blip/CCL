# CCL Query Library

A collection of **CCL (Cerner Coherence Language)** ad hoc query scripts for auditing and analyzing configuration in Oracle Health (Cerner) PowerChart / Millennium.

## What's Here

All production queries live in `output/`, organized by category:

| Folder | Contents |
|---|---|
| `Audit Programs` | Position-level, access, and configuration audits |
| `CCL Reference` | Language examples, program templates, DUMMYT patterns |
| `Data Model` | Table exploration, joins, and data retrieval examples |
| `Functions` | UAR functions, date/time helpers, string functions |
| `MPages` | MPage component and filter queries |
| `Orders & Scheduling` | Order catalog, scheduling, and DTA queries |
| `PathNet` | Lab/PathNet-specific queries and migration programs |
| `PowerForms` | Dynamic documentation, PowerForm, and note type queries |
| `Rules & Alerts` | Alert rules, special duty, and notification queries |

Each `.sql` file is a standalone query — copy it into Discern Explorer / CCL and run directly. Hard-coded filter values (position names, component IDs, etc.) are marked in comments and must be updated for your environment before running.

## Adding New Files

Drop CCL files (`.txt` or `.prg`) into the appropriate `Inbox/` subdirectory, then run:

```bash
# Preview what will be imported
python import_inbox.py --dry-run

# Import (keeps originals in Inbox/)
python import_inbox.py --keep

# Import and delete originals
python import_inbox.py
```

The script slugifies filenames to kebab-case, prepends a provenance header, deduplicates by SHA-256 hash, and routes files to the correct `output/` category based on the `Inbox/` subdirectory name. Near-duplicates (≥92% similarity) are moved to `Inbox/review/` for manual decision.

## File Header Format

Every imported file starts with:

```sql
/*
* Name:     <original filename>
* Source:   Inbox/<subfolder>/<filename>
* Purpose:
* Imported: YYYY-MM-DD
* Category: <category>  (reason: subfolder)
* Lines:    <n>
* Notes:
*/
```

## Query Language

CCL is a proprietary SQL-like language. Two valid syntaxes coexist in this repo:

- **Traditional CCL** — `PLAN / JOIN`, `OUTERJOIN()`, `EVALUATE()`, `WITH NOCOUNTER`
- **SQL-style CCL** — standard `SELECT / FROM / WHERE / JOIN` with subqueries

Key active-record guards used throughout:
- `DATA_STATUS_IND = 1` — active records only
- `END_EFFECTIVE_DT_TM > CNVTDATETIME(CURDATE, CURTIME)` — not yet expired
