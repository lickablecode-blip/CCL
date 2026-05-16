/*
* Name:     Order_DTA_Audit with subactivity type
* Source:   Inbox/PathNet/Order_DTA_Audit with subactivity type.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    29
* Notes:
*/

select
	oc.catalog_cd,
	o_activity_subtype_disp = uar_get_code_display( oc.activity_subtype_cd),
	oc.description,
	oc.primary_mnemonic,
	oc.dept_display_name,
	dta.mnemonic,
	dta.task_assay_cd,
	dta.description,
	dta_default_result_type_disp = uar_get_code_display( dta.default_result_type_cd ),
	ptr.sequence,
	ptr.pending_ind,
	PROMPT_TEST=ptr.item_type_flag,
	Post_Verified=ptr.post_prompt_ind
	

from
	order_catalog  oc,
	profile_task_r  ptr,
	discrete_task_assay  dta

plan oc
where oc.activity_type_cd = 692
  and oc.active_ind = 1

join ptr
where ptr.catalog_cd = oc.catalog_cd
  and ptr.active_ind = 1

join dta
where dta.task_assay_cd = ptr.task_assay_cd
  and dta.active_ind = 1

order by	oc.description,
			ptr.sequence
