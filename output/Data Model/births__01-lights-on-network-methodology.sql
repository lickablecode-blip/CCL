/*
 * Source page  : Births
 * Source file  : output/births.md
 * Anchor       : Lights On Network methodology
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 43
 *
 * Context (preceding paragraph):
 *   "A unique count of the number of occurrences that a neonate outcome is being documented
 *   within a mother’s chart for non-historical pregnancies."
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

select cnt =
count(*)
from
 clinical_event
ce
 ,
encounter e
 ,
organization o
 ,
code_value cv1
 ,
code_value cv2
 ,
code_value cv_facility
where
ce.Event_Cd = cv1.Code_Value
 and
ce.encntr_id = e.encntr_id
 and
ce.result_status_cd = cv2.code_value
 and
e.loc_facility_cd = cv_facility.code_value
 and
e.organization_id = o.organization_id
 and
cv1.concept_cki = 'CERNER!ASYr9AEYvUr1YoRACqIGfQ' ; neonate outcome
 and
ce.event_end_dt_tm between ? and ?
 and
cv2.cdf_meaning IN ('AUTH', 'ALTERED', 'MODIFIED')
 and
ce.event_tag != 'Date\Time Correction'
 and
ce.valid_until_dt_tm > cnvtdatetime(sysdate)
 and
ce.result_val > ' '
 and
ce.person_id > 0
group by
e.encntr_id
order by
e.encntr_id
