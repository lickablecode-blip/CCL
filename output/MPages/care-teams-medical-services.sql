/*
* Name:     Care Teams & Medical Services
* Source:   Inbox/mPages/Care Teams & Medical Services.txt
* Purpose:
* Imported: 2026-05-15
* Category: MPages  (reason: subfolder)
* Lines:    47
* Notes:
*/

; Medical Services
select 
cv.code_set
, cv.display
from 
code_value cv
plan cv where cv.code_set = 4003171
and cv.active_ind = 1
order by cv.display_key

-----------------
;Care Teams
select 
cv.code_set
, cv.display
from 
code_value cv
plan cv where cv.code_set = 4003138
and cv.active_ind = 1
order by cv.display_key

------------------------------------
;Current Configuration
select distinct
agency=lar.agency
, facility=uar_get_code_display(pct.facility_cd)
, medical_service = uar_get_code_display(pct.pct_med_service_cd)
, care_team = uar_get_code_display(pct.pct_team_cd)
FROM
pct_care_team   pct
, code_value cv1
, code_value cv2
, cust_loc_agency_reltn lar
plan pct
where pct.pct_care_team_id = pct.orig_pct_team_id
and pct.prsnl_id = 0.00
and pct.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
and pct.active_ind = 1
join cv1
where cv1.code_value = pct.pct_med_service_cd
join cv2
where cv2.code_value = pct.pct_team_cd
join lar
where lar.location_cd = pct.facility_cd
order by 
agency
, facility
, medical_service
, care_team
