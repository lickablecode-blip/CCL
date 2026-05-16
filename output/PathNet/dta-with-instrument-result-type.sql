/*
* Name:     DTA with Instrument Result Type
* Source:   Inbox/PathNet/DTA with Instrument Result Type.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    36
* Notes:
*/

SELECT
	dta_short = uar_get_code_display(p.task_assay_cd)
	, serv_resr = uar_get_code_display(r.service_resource_cd)
	, A_DEFAULT_RESULT_TYPE_DISP = UAR_GET_CODE_DISPLAY(A.DEFAULT_RESULT_TYPE_CD)
	, o.catalog_cd
	, o.primary_mnemonic
	, o.dept_display_name
	, r.service_resource_cd
	, o.active_ind
	, p.task_assay_cd
	, p.sequence
	, o.activity_type_cd

FROM
	order_catalog   o
	, orc_resource_list   r
	, profile_task_r   p
	, ASSAY_PROCESSING_R   A

plan o
where o.active_ind = 1

join r where o.catalog_cd = r.catalog_cd   and r.active_ind = 1
join p where o.catalog_cd = p.catalog_cd   and p.active_ind = 1
join a where a.service_resource_cd = r.service_resource_cd  and a.task_assay_cd = p.task_assay_cd

GROUP BY
	o.catalog_cd
	, o.primary_mnemonic
	, o.active_ind
	, o.dept_display_name
	, r.service_resource_cd
	, p.task_assay_cd
	, p.sequence
	, A.DEFAULT_RESULT_TYPE_CD
	, o.activity_type_cd

ORDER BY
	dta_short
	, serv_resr
	, A_DEFAULT_RESULT_TYPE_DISP
