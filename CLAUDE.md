# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repository Is

This is a collection of **CCL (Cerner Coherence Language)** ad hoc queries used to audit and analyze clinical documentation configuration in a Cerner PowerChart / Oracle Health system. There is no build system, package manager, test framework, or linting toolchain — files are standalone `.txt` query scripts executed directly in Cerner's ad hoc query tool (Discern Explorer / CCL).

## Query Language

CCL is a proprietary SQL-like language specific to Cerner. Two distinct syntaxes appear in this repo:

- **Traditional CCL** — uses `PLAN / JOIN` clauses, `OUTERJOIN()`, `EVALUATE()`, `FORMAT()`, `WITH NOCOUNTER`. Most files use this style.
- **SQL-style CCL** — uses standard `SELECT / FROM / WHERE / JOIN` with subqueries. Some files use this style.

Both styles are valid and can coexist. Cerner accepts either syntax in the ad hoc query runner.

### Key Cerner-Specific Functions
| Function | Purpose |
|---|---|
| `UAR_GET_CODE_DISPLAY(cd)` | Returns the display string for a code value |
| `UAR_GET_CODE_DESCRIPTION(cd)` | Returns the long description for a code value |
| `CNVTDATETIME(date, time)` | Converts date/time to Cerner datetime |
| `EVALUATE(field, val1, result1, ...)` | Switch/case expression |
| `FORMAT(dt, '@SHORTDATETIME')` | Formats a datetime value |

### Key Tables / Views
| Table | Contents |
|---|---|
| `NOTE_TYPE` | Clinical note type configuration |
| `CODE_VALUE` | Master code/value lookup table |
| `V500_EVENT_SET_EXPLODE` | Expands event sets to individual event codes |
| `V500_EVENT_CODE` | Event code definitions |
| `APP_PREFS` | Application preferences, including position assignments |
| `BR_DATAMART_*` | MPage component/filter/category configuration |
| `DCP_PATIENT_LIST` | Patient list definitions |
| `PCT_CARE_TEAM` | Care team assignments |
| `PRSNL` | Personnel/provider table |

`APPLICATION_NUMBER = 600005` identifies PowerChart in `APP_PREFS`.

## Query Categories

| Category | Example Files |
|---|---|
| Note types & templates | `Active Note Types.txt`, `Note Type Audit.txt`, `Note Type Usage*.txt` |
| PowerForms / DynDocs | `Active PowerForms.txt`, `All PowerForms & Textual Renditions.txt`, `PowerForm Sections.txt` |
| MPage components & filters | `MPage Component Audit.txt`, `MPage Document Filter Audit.txt`, `mponent & Filter Audit*.txt` |
| Positions & access | `PowerChart Positions.txt`, `Position to MPage.txt`, `poit Mpages and positions.txt` |
| Care teams | `Care Teams.txt` |
| Orders | `Quick Visit Audit.txt`, `Virtual Viewing Orders.txt`, `Order Activity by Position.txt` |
| Ad hoc folder structure | `AdHoc Folder Contents.txt`, `All AdHoc Roots & PVC Values.txt` |

## Conventions

- Each file is a single self-contained query; the header comment (lines starting with `*`) describes what the query returns and what columns are included.
- Hard-coded filter values (MPage names, component names, position codes) appear in comments like `; name of MPage` — these must be updated per environment before running.
- `DATA_STATUS_IND = 1` filters for active records; omit to include inactive/retired records.
- `END_EFFECTIVE_DT_TM > CNVTDATETIME(CURDATE, CURTIME)` is the standard active-record date guard.
