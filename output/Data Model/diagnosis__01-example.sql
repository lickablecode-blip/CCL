/*
 * Source page  : Diagnosis
 * Source file  : output/diagnosis.md
 * Anchor       : Example
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 48
 *
 * Context (preceding paragraph):
 *   This can pose a real challenge to the developer, given that many reports see the coded
 *   version of the chart as authoritative. It can help to ask the user if they're looking
 *   for the provider's intent/opinion vs only the coded version. For inpatient and
 *   emergency visits, which are 100% manually coded, this can be enough. However,
 *   ambulatory encounters aren't manually coded and the majority of diagnoses will have a
 *   "Discharge" type.
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
diagnosis = n.source_string
,code = PIECE(n.concept_cki,"!",2,"parse error")
,type = UAR_GET_CODE_DISPLAY(d.diag_type_cd)
,priority = d.diag_priority
,alt_priority = cp.priority_nbr
,vocabulary = PIECE(n.concept_cki,"!",1,"parse
error")
,contrib_system = UAR_GET_CODE_DISPLAY(d.contributor_system_cd)
,diagnosis_dt_tm = DATETIMEZONEFORMAT(d.diag_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
,last_updated = DATETIMEZONEFORMAT(d.updt_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
,diagnosing_prsnl = d.diag_prsnl_name
,d.diagnosis_display ; as entered by provider
,classification = UAR_GET_CODE_DISPLAY(d.classification_cd)
,clinical_service = UAR_GET_CODE_DISPLAY(d.clinical_service_cd)
,confirmation_status = UAR_GET_CODE_DISPLAY(d.confirmation_status_cd)
,hospital_acquired_ind = d.hac_ind
,present_on_admit = UAR_GET_CODE_DISPLAY(d.present_on_admit_cd)
,ranking = UAR_GET_CODE_DISPLAY(d.ranking_cd)
,d.encntr_id
,d.diagnosis_id
FROM
DIAGNOSIS d
,(LEFT JOIN CONDITION_PRIORITY cp ON d.diagnosis_id =
cp.condition_entity_id
AND d.encntr_id = cp.encntr_id
AND cp.condition_entity_name = "DIAGNOSIS"
AND cp.active_ind = 1)
,NOMENCLATURE n
,ENCOUNTER e
,TIME_ZONE_R tz
PLAN d WHERE
d.encntr_id = <encntr_id>
AND d.end_effective_dt_tm > SYSDATE
AND d.active_ind = 1
JOIN n WHERE
d.nomenclature_id = n.nomenclature_id
JOIN e WHERE
e.encntr_id = d.encntr_id
JOIN tz WHERE
tz.parent_entity_id = e.loc_facility_cd
AND tz.parent_entity_name = "LOCATION"
JOIN cp
ORDER BY
contrib_system, type, priority, alt_priority, n.source_string
WITH TIME=30
