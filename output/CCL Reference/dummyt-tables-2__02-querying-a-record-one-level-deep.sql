/*
 * Source page  : DUMMYT tables
 * Source file  : output/dummyt-tables-2.md
 * Anchor       : Querying a record (one level deep)
 * Block index  : 2 of 5
 * Detected lang: ccl
 * Lines        : 7
 *
 * Context (preceding paragraph):
 *   <… code to populate the record …>
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
person_id = rec->list[d.seq].person_id
,encntr_id = rec->list[d.seq].encntr_id
,link = SUBSTRING(1,255,rec->list[d.seq].link)
FROM (DUMMYT
d with seq = value(size(rec->list, 5)))
PLAN d
