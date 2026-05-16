/*
* Name:     Equation_audit
* Source:   Inbox/PathNet/Equation_audit.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    16
* Notes:
*/

select 
	e_task_assay_disp = uar_get_code_display( e.task_assay_cd ),
	e_service_resource_disp = uar_get_code_display( e.service_resource_cd ),
	e_sex_disp = uar_get_code_display( e.sex_cd ),
	e.age_from_minutes,
	e_age_from_units_disp = uar_get_code_display( e.age_from_units_cd ),
	e.age_to_minutes,
	e_age_to_units_disp = uar_get_code_display( e.age_to_units_cd ),
	e.equation_description

from
	equation  e,
	discrete_task_assay dta

plan dta where dta.activity_type_cd = 692 and dta.active_ind = 1
join e where e.task_assay_cd = dta.task_assay_cd and e.active_ind = 1

order by	e_task_assay_disp
go
