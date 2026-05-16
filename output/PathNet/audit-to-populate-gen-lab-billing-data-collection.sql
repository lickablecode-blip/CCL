/*
* Name:     audit to populate gen lab billing data collection
* Source:   Inbox/PathNet/audit to populate gen lab billing data collection.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    20
* Notes:
*/

SELECT DISTINCT
	o.DESCRIPTION
	, o.primary_mnemonic
	, o.dept_display_name
	, dta_short = uar_get_code_display(p.task_assay_cd)
	, D.DESCRIPTION
	, p.SEQUENCE

FROM
	order_catalog   o
	, orc_resource_list   r
	, profile_task_r   p
	, DISCRETE_TASK_ASSAY   D

plan o
where o.active_ind = 1    and o.activity_type_cd = 692

join r where o.catalog_cd = r.catalog_cd      and r.active_ind = 1   
join p where o.catalog_cd = p.catalog_cd      and p.active_ind = 1
join d where d.task_assay_cd = p.task_assay_cd

ORDER BY
	o.DESCRIPTION
	, p.SEQUENCE
