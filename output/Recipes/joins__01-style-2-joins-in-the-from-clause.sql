/*
 * Source page  : Joins
 * Source file  : output/joins.md
 * Anchor       : Style 2: joins in the FROM clause
 * Block index  : 1 of 3
 * Detected lang: ccl
 * Lines        : 9
 *
 * Context (preceding paragraph):
 *   Tables are joined/qualified in the FROM clause, surrounded by parentheses, and require
 *   an unqualified JOIN statement at the end of the PLAN clause.
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT *
FROM
ENCOUNTER e
,(INNER JOIN PERSON p ON p.person_id = e.person_id)
,(LEFT JOIN CODE_VALUE cv ON cv.code_value = e.encntr_type_cd)
PLAN e WHERE
e.active_ind = 1
JOIN p
JOIN cv
