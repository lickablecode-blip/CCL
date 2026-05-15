/*
 * Source page  : Health plans
 * Source file  : output/health-plans.md
 * Anchor       : Person-Level, with profile
 * Block index  : 2 of 2
 * Detected lang: ccl
 * Lines        : 47
 *
 * Context (preceding paragraph):
 *   (no preceding paragraph)
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

ELSEIF($cat =
"patient" AND $pat_rpt = "Health Plans")
profile = UAR_GET_CODE_DISPLAY(ppp.profile_type_cd)
,seq = pppr.priority_seq
,health_plan = hp.plan_name
,plan_type = UAR_GET_CODE_DISPLAY(hp.plan_type_cd)
,service_type = UAR_GET_CODE_DISPLAY(hp.service_type_cd)
,payer = org.org_name
,financial_class = UAR_GET_CODE_DISPLAY(hp.financial_class_cd)
,plan_reltn =
UAR_GET_CODE_DISPLAY(ppr.person_plan_r_cd)
,ppr.member_nbr
,ppr.group_nbr
,signature_on_file = UAR_GET_CODE_DISPLAY(ppr.signature_on_file_cd)
,begin_date = ppr.beg_effective_dt_tm
,subscriber = subscriber.name_full_formatted
,subscriber_employer = por.ft_org_name
,subscriber_status = UAR_GET_CODE_DISPLAY(por.empl_occupation_cd)
 ,subscriber_rank =
UAR_GET_CODE_DISPLAY(por.empl_title_cd)
 ,subscriber_grade =
UAR_GET_CODE_DISPLAY(por.empl_type_cd)
 ,ppr.person_plan_reltn_id
FROM PERSON_PLAN_RELTN ppr
,(LEFT JOIN PERSON_PLAN_PROFILE_RELTN pppr ON pppr.person_plan_reltn_id
= ppr.person_plan_reltn_id
AND pppr.active_ind = 1)
,(LEFT JOIN PERSON_PLAN_PROFILE ppp ON ppp.person_plan_profile_id =
pppr.person_plan_profile_id
AND ppp.active_ind = 1)
,PERSON subscriber
,(LEFT JOIN PERSON_ORG_RELTN por ON por.person_id =
subscriber.person_id
AND por.person_org_reltn_cd = 1136 ;employer
AND por.active_ind = 1)
,HEALTH_PLAN hp
,ORGANIZATION org
PLAN ppr WHERE ppr.person_id = ids->person_id
AND ppr.priority_seq != 0
AND ppr.active_ind = 1
JOIN subscriber WHERE subscriber.person_id = ppr.subscriber_person_id
JOIN hp WHERE hp.health_plan_id = ppr.health_plan_id
JOIN org WHERE org.organization_id = ppr.organization_id
JOIN pppr
JOIN ppp
JOIN por
ORDER BY profile, seq
