/*
 * Source page  : DUMMYT tables
 * Source file  : output/dummyt-tables-2.md
 * Anchor       : Querying a record (two levels deep)
 * Block index  : 4 of 5
 * Detected lang: ccl
 * Lines        : 9
 *
 * Context (preceding paragraph):
 *   <… code to populate the record …>
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
group = rec->list[d.seq].group
,report_title = rec->list[d.seq].rpt[r.seq].report_title
FROM (DUMMYT
d WITH seq = value(size(rec->list, 5)))
,(DUMMYT r WITH seq = 1)
PLAN d WHERE
MAXREC(r, size(rec->list[d.seq].rpt, 5))
JOIN r
