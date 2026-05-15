/*
 * Source page  : Health plans
 * Source file  : output/health-plans.md
 * Anchor       : Encounter-Level, with profile
 * Block index  : 1 of 2
 * Detected lang: ccl
 * Lines        : 45
 *
 * Context (preceding paragraph):
 *   (no preceding paragraph)
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

ELSEIF($cat =
"encounter" AND $enc_rpt = "Health Plans")
fin = ids->fin
,profile = UAR_GET_CODE_DISPLAY(e.person_plan_profile_type_cd)
,seq = epr.priority_seq
,health_plan = hp.plan_name
,plan_type = UAR_GET_CODE_DISPLAY(hp.plan_type_cd)
,service_type = UAR_GET_CODE_DISPLAY(hp.service_type_cd)
,payer = org.org_name
,financial_class = UAR_GET_CODE_DISPLAY(hp.financial_class_cd)
,epr.member_nbr
,epr.subs_member_nbr
,epr.group_nbr
,signature_on_file = UAR_GET_CODE_DISPLAY(epr.signature_on_file_cd)
,begin_date = epr.beg_effective_dt_tm
,subscriber = subscriber.name_full_formatted
,subscriber_employer = por.ft_org_name
,subscriber_status = UAR_GET_CODE_DISPLAY(por.empl_occupation_cd)
 ,subscriber_rank =
UAR_GET_CODE_DISPLAY(por.empl_title_cd)
 ,subscriber_grade =
UAR_GET_CODE_DISPLAY(por.empl_type_cd)
 ,epr.encntr_plan_reltn_id
FROM ENCOUNTER e
,ENCNTR_PLAN_RELTN epr
,(LEFT JOIN PERSON_PLAN_RELTN ppr ON ppr.person_plan_reltn_id =
epr.person_plan_reltn_id
AND ppr.member_nbr = epr.subs_member_nbr
AND ppr.active_ind = 1)
,(LEFT JOIN PERSON subscriber ON subscriber.person_id = ppr.person_id)
,(LEFT JOIN PERSON_ORG_RELTN por ON por.person_id =
subscriber.person_id
AND por.person_org_reltn_cd = 1136 ;employer
AND por.active_ind = 1)
,HEALTH_PLAN hp
,ORGANIZATION org
PLAN e WHERE e.encntr_id = ids->encntr_id
JOIN epr WHERE epr.encntr_id = e.encntr_id
AND epr.active_ind = 1
JOIN ppr
JOIN subscriber
JOIN por
JOIN hp WHERE hp.health_plan_id = epr.health_plan_id
JOIN org WHERE org.organization_id = epr.organization_id
ORDER BY profile, seq
