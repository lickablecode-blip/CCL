/*
* Name:     Order to DTA Laboratory
* Source:   Inbox/PathNet/Order to DTA Laboratory.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    32
* Notes:
*/

SELECT
	OC_CATALOG_TYPE_DISP = UAR_GET_CODE_DISPLAY(OC.CATALOG_TYPE_CD)
	, OC_ACTIVITY_TYPE_DISP = UAR_GET_CODE_DISPLAY(OC.ACTIVITY_TYPE_CD)
	, oc.catalog_cd
	, oc.description
	, oc.primary_mnemonic
	, oc.dept_display_name
	, dta.task_assay_cd
	, dta.mnemonic
	, dta.description
	, dta_default_result_type_disp = uar_get_code_display( dta.default_result_type_cd )
	, ptr.sequence
	, ptr.pending_ind
	, PROMPT_TEST = ptr.item_type_flag
	, Post_Verified = ptr.post_prompt_ind

FROM
	order_catalog   oc
	, profile_task_r   ptr
	, discrete_task_assay   dta

plan oc
where oc.catalog_type_cd = 2513
  and oc.active_ind = 1

join ptr
where ptr.catalog_cd = oc.catalog_cd
  and ptr.active_ind = 1

join dta
where dta.task_assay_cd = ptr.task_assay_cd
  and dta.active_ind = 1

ORDER BY
	OC_ACTIVITY_TYPE_DISP
	, oc.description
	, ptr.sequence
