/*
* Name:     Like _to_Unlike_dup_audit
* Source:   Inbox/PathNet/Like _to_Unlike_dup_audit.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    12
* Notes:
*/

select 
	oc.description,
	ddc_dup_catalog_disp = uar_get_code_display( ddc.dup_catalog_cd )

from
	order_catalog  oc,
	dept_dup_check  ddc

plan oc
where oc.activity_type_cd = 692
  and oc.active_ind = 1
  and oc.dept_dup_check_ind = 1

join ddc
where ddc.catalog_cd = oc.catalog_cd
