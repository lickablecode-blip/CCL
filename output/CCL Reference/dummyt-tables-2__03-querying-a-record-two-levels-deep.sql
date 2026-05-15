/*
 * Source page  : DUMMYT tables
 * Source file  : output/dummyt-tables-2.md
 * Anchor       : Querying a record (two levels deep)
 * Block index  : 3 of 5
 * Detected lang: unknown
 * Lines        : 6
 *
 * Context (preceding paragraph):
 *   In this example, the record structure stores groups of reports, but any given group
 *   (list[*]) can have different numbers of reports (rpt[*]). We need a DUMMYT table for
 *   each list, and we use the MAXREC function to specify the size of the first list in the
 *   PLAN clause.
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

record rec (
1 list[*]
2 group = c40
2 rpt[*]
3 rpt_title = c40
)
