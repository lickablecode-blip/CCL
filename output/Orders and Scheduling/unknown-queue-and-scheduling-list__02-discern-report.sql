/*
 * Source page  : Unknown Queue and Scheduling List
 * Source file  : output/unknown-queue-and-scheduling-list.md
 * Anchor       : Discern Report
 * Block index  : 2 of 8
 * Detected lang: ccl
 * Lines        : 61
 *
 * Context (preceding paragraph):
 *   So a more modern version of the code reads something like the below - running it just
 *   for one appointment type in our domain, but it pulls back all the preps linked to it.
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

Select
Appt_Type =
uar_get_code_display(sat.appt_type_cd)
,Location =
uar_get_code_display(sal.location_cd)
,Pre_Name =
ste.mnemonic
from
sch_appt_type sat
,sch_appt_loc
sal
,sch_text_link
stl
,sch_sub_list
ssl
,sch_template
ste
PLAN SAT
where
sat.appt_type_cd = 11707156.00 ;gen surg new
and
sat.active_ind = 1
and
sat.end_effective_dt_tm > CNVTDATETIME(curdate,curtime3)
JOIN SAL
where
sal.appt_type_cd = sat.appt_type_cd
and
sal.active_ind = 1
and
sal.end_effective_dt_tm > CNVTDATETIME(curdate,curtime3)
JOIN STL
where
stl.parent_id = sal.appt_type_cd
and
stl.parent2_id = sal.location_cd
and
stl.active_ind = 1
and
stl.end_effective_dt_tm > CNVTDATETIME(curdate,curtime3)
and
stl.text_type_cd IN (10343.00 ;preps
,     
10342.00 ;post appt ins
)
JOIN SSL
where
ssl.parent_id = stl.text_link_id
and
ssl.active_ind = 1
and
ssl.end_effective_dt_tm > CNVTDATETIME(curdate,curtime3)
JOIN STE
where
ste.template_id = ssl.template_id
and
ste.active_ind = 1
and
ste.end_effective_dt_tm > CNVTDATETIME(curdate,curtime3)
WITH FORMAT,
TIME = 120
