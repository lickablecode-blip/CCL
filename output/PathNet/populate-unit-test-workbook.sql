/*
* Name:     Populate Unit Test Workbook
* Source:   Inbox/PathNet/Populate Unit Test Workbook.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    23
* Notes:
*/

SELECT
	serv_resr = uar_get_code_display(r.service_resource_cd)
	, o.primary_mnemonic
	, o.dept_display_name
	, p.sequence
	, p.task_assay_cd
		, D.DESCRIPTION
	, dta_short = uar_get_code_display(p.task_assay_cd)


FROM
	order_catalog   o
	, orc_resource_list   r
	, profile_task_r   p
	, DISCRETE_TASK_ASSAY   D

plan o
where o.active_ind = 1

join r where o.catalog_cd = r.catalog_cd and O.ACTIVITY_TYPE_CD = 692    and r.active_ind = 1
join p where o.catalog_cd = p.catalog_cd      and p.active_ind = 1
join D where d.task_assay_cd = p.task_assay_cd

ORDER BY
	serv_resr
	, o.primary_mnemonic
	, p.sequence
go
