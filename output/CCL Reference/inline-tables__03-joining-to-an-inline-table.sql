/*
 * Source page  : Inline tables
 * Source file  : output/inline-tables.md
 * Anchor       : Joining to an inline table:
 * Block index  : 3 of 7
 * Detected lang: ccl
 * Lines        : 20
 *
 * Context (preceding paragraph):
 *   CAVEAT : You can't use PLAN/JOIN in inline tables. Use the old-style joins in the WHERE
 *   clause. Example:
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
tmp.person_id
,e.encntr_id
,ENC_TYPE = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
FROM
ENCOUNTER e,
((SELECT p.NAME_LAST_KEY, p.NAME_FIRST_KEY, p.NAME_MIDDLE_KEY,
p.person_id ;needs double parentheses
 FROM PERSON p
 WHERE p.person_id =
<person_id>
 WITH SQLTYPE("C80",
"C80", "C80", "F8") ;have to define the data
types
 ) tmp )
PLAN e
JOIN tmp
WHERE e.person_id = tmp.person_id
WITH
MAXREC=10, TIME=60
