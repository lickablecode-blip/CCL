/*
* Name:     WORKIN~1
* Source:   Inbox/PathNet/WORKIN~1.TXT
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    44
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
,C_CONTRIBUTOR_SOURCE_DISP = UAR_GET_CODE_DISPLAY(a.CONTRIBUTOR_SOURCE_CD)
	, INBOUND_ALIAS = a.ALIAS
	, OUTBOUND_ALIAS = C.ALIAS
	, a.CODE_SET
	, a.CODE_VALUE
	

from
	order_catalog  oc,
	profile_task_r  ptr,
	discrete_task_assay  dta
, code_value   CV
, CODE_VALUE_alias   a
, CODE_VALUE_OUTBOUND   C
plan oc
where oc.activity_type_cd = 692
  and oc.active_ind = 1

join ptr
where ptr.catalog_cd = oc.catalog_cd
  and ptr.active_ind = 1

join dta
where dta.task_assay_cd = ptr.task_assay_cd
  and dta.active_ind = 1

join cv
where cv.description = oc.description
and cv.code_set = 200
join a where a.CODE_value=cv.code_value
and a.contributor_source_cd =            82267797  ; CS 73;
join c where c.CODE_value=cv.code_value
and c.contributor_source_cd =            82267797 ;CS 73 (should be the same value as above);

order by	oc.description,
			ptr.sequence
