/*
* Name:     dtas_event codes_not in esh
* Source:   Inbox/PathNet/dtas_event codes_not in esh.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    10
* Notes:
*/

select
dta.task_assay_cd,ec.event_cd,ec.event_set_name
from
discrete_task_assay dta,
code_value_event_r cver,
v500_event_code ec
plan dta
where dta.task_assay_cd > 1
and dta.activity_type_cd in
(select code_value from code_value where code_set = 106 and cdf_meaning = "GLB") and dta.active_ind = 1 join cver where dta.task_assay_cd = cver.parent_cd join ec where cver.event_cd = ec.event_cd and ec.event_cd not in (select distinct event_cd from v500_event_set_explode) go
