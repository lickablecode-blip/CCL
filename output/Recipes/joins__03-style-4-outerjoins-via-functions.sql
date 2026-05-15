/*
 * Source page  : Joins
 * Source file  : output/joins.md
 * Anchor       : Style 4: outerjoins via functions
 * Block index  : 3 of 3
 * Detected lang: ccl
 * Lines        : 9
 *
 * Context (preceding paragraph):
 *   This style is common in older code written by Oracle Cerner, and uses an outerjoin
 *   function. All tables are listed in the FROM clause and all joins/qualifications occur
 *   in the PLAN clause. This style makes it harder to tell at a glance whether a table is
 *   an inner or outer join.
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT *
FROM
ENCOUNTER e
,PERSON p
,CODE_VALUE cv
PLAN e WHERE
e.active_ind = 1
AND e.person_id = OUTERJOIN(p.person_id)
AND cv.code_value = e.encntr_type_cd
