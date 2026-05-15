/*
 * Source page  : Inline tables
 * Source file  : output/inline-tables.md
 * Anchor       : LEFT JOIN to an inline table:
 * Block index  : 5 of 7
 * Detected lang: ccl
 * Lines        : 63
 *
 * Context (preceding paragraph):
 *   The key difference here is in the parentheses around the LEFT JOIN - because there is
 *   already the outer left parenthesis due to the left join, you only need a single one for
 *   the inline table.
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
fin = fin.alias
,e.reg_dt_tm "MM/DD/YYYY HH:MM;;q"
    ,e.disch_dt_tm
"MM/DD/YYYY HH:MM;;q"
    ,encntr_type
= UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
    ,med_service
= UAR_GET_CODE_DISPLAY(e.med_service_cd)
    ,loc
= UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
    ,encntr_relation
= UAR_GET_CODE_DISPLAY(epr.encntr_prsnl_r_cd)
    ,ce_cnt.num_events
FROM
ENCNTR_PRSNL_RELTN epr
    ,ENCNTR_ALIAS
fin
    ,ENCOUNTER
e
    ,(LEFT
JOIN (SELECT ce.encntr_id
            ,
num_events = COUNT(*)
        FROM
CLINICAL_EVENT ce
        WHERE
(ce.performed_prsnl_id = <prsnl_id> ;prsnl either documented, verified,
or updated a clinical event
                OR
ce.verified_prsnl_id = <prsnl_id>
                OR
ce.updt_id = <prsnl_id>) ;query runs faster if you remove the updt_id
check
            AND
ce.publish_flag = 1 ;event is published for end-user visibility
            AND
ce.view_level = 1 ;exclude system-level events
            AND
ce.result_status_cd NOT IN (28,29,30,31) ;exclude events "entered in
error"
            AND
ce.valid_until_dt_tm > SYSDATE ;exclude inactive events
        GROUP
BY ce.encntr_id
        WITH
SQLTYPE("f8", "i4") ;necessary for functioning of inline
table
        )
ce_cnt
         ON
e.encntr_id = ce_cnt.encntr_id)
PLAN epr
WHERE epr.active_ind = 1    AND epr.prsnl_person_id =
<prsnl_id>
JOIN fin
WHERE epr.encntr_id = fin.encntr_id AND fin.encntr_alias_type_cd = 1077 ;fin
JOIN e WHERE
epr.encntr_id = e.encntr_id
JOIN ce_cnt
ORDER BY
e.reg_dt_tm DESC
WITH TIME=30
