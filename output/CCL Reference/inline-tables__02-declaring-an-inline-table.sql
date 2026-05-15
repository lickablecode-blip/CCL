/*
 * Source page  : Inline tables
 * Source file  : output/inline-tables.md
 * Anchor       : Declaring an inline table
 * Block index  : 2 of 7
 * Detected lang: sql
 * Lines        : 18
 *
 * Context (preceding paragraph):
 *   CAVEAT : You can't use PLAN/JOIN in inline tables. Use the old-style joins in the WHERE
 *   clause. Example:
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT *
FROM
(
 (SELECT
 p.person_id
 ,ENCNTR_COUNT =
COUNT(e.encntr_id)
 FROM
 ENCOUNTER e
,PERSON p
 WHERE e.active_ind = 1
 AND e.person_id = p.person_id
 GROUP BY p.person_id
 WITH
SQLTYPE("f8","i4")
 ) test_pts
)
WITH TIME=30
