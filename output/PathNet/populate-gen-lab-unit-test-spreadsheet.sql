/*
* Name:     Populate gen lab unit test spreadsheet
* Source:   Inbox/PathNet/Populate gen lab unit test spreadsheet.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    26
* Notes:
*/

SELECT
	o_activity_subtype_disp = uar_get_code_display( oc.activity_subtype_cd)
	, oc.primary_mnemonic
	, oc.dept_display_name
	, ptr.sequence
	, dta.task_assay_cd
	, dta.description
	, dta.mnemonic
	, dta_default_result_type_disp = uar_get_code_display( dta.default_result_type_cd )

FROM
	order_catalog   oc
	, profile_task_r   ptr
	, discrete_task_assay   dta

plan oc
where oc.activity_type_cd = 692
  and oc.active_ind = 1

join ptr
where ptr.catalog_cd = oc.catalog_cd
  and ptr.active_ind = 1

join dta
where dta.task_assay_cd = ptr.task_assay_cd
  and dta.active_ind = 1

ORDER BY
	o_activity_subtype_disp
	, oc.primary_mnemonic
	, ptr.sequence
