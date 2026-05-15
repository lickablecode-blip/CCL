/*
 * Source page  : Joins
 * Source file  : output/joins.md
 * Anchor       : Style 3: mixed style
 * Block index  : 2 of 3
 * Detected lang: ccl
 * Lines        : 10
 *
 * Context (preceding paragraph):
 *   Tables with inner joins are listed in the FROM clause but qualified in the WHERE
 *   clause; and left joins are listed and qualified in the FROM clause. The left joins must
 *   be listed underneath the table they are joining; the following example is correct, but
 *   would fail to run if the left join were listed under CODE_VALUE. The left joins still
 *   need the unqualified JOIN statement at the end of the plan, and left-joined tables
 *   should be listed after any inner joins to improve performance.
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT *
FROM
ENCOUNTER e
,(LEFT JOIN PERSON p ON p.person_id = e.person_id)
,CODE_VALUE cv
PLAN e WHERE
e.active_ind = 1
JOIN cv WHERE
cv.code_value = e.encntr_type_cd
JOIN p ;left joins go last for performance reasons
