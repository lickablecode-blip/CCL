/*
* Name:     CHS Unit Testing Audit
* Source:   Inbox/PathNet/CHS Unit Testing Audit.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    27
* Notes:
*/

;Shows Service Resource, Primary mneumonic, dept display name, DTA desc, DTA short, Activity SubType for Unit Testing with ability to search by site prefix


select
	r_service_resource_disp = uar_get_code_display(r.service_resource_cd)
	, o.primary_mnemonic
	, o.dept_display_name
	, d.description
	, dta_short = uar_get_code_display(p.task_assay_cd)
	, o_activity_subtype_disp = uar_get_code_display(o.activity_subtype_cd)

from
	order_catalog   o
	, orc_resource_list   r
	, profile_task_r   p
	, discrete_task_assay   d
	, code_value   c

plan o
where o.active_ind = 1

join r where o.catalog_cd = r.catalog_cd
and o.activity_type_cd = 692 ;Gen Lab
and r.active_ind = 1
join p where o.catalog_cd = p.catalog_cd
and p.active_ind = 1
join d where d.task_assay_cd = p.task_assay_cd
join c where r.service_resource_cd=c.code_value
and c.display= "*PAPH*" ;site prefix

order by
	o.primary_mnemonic,
	r_service_resource_disp
