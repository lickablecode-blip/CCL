/*
* Name:     Orderable_Audit
* Source:   Inbox/PathNet/Orderable_Audit.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    34
* Notes:
*/

select
	oc.catalog_cd,
	oc.description,
	oc.primary_mnemonic,
	ocs_mnemonic_type_disp = uar_get_code_display( ocs.mnemonic_type_cd ),
	ocs.synonym_id,
	ocs.mnemonic,
	oc.dept_display_name,
	oc_activity_subtype_disp = uar_get_code_display( oc.activity_subtype_cd ),
	ocs.hide_flag,
	oc.orderable_type_flag,
	Min_Ahead = dc.min_ahead,
	Ahead_action = uar_get_code_display(dc.min_ahead_action_cd),
	Min_Behind = dc.min_behind,
	Behind_Action = uar_get_code_display(dc.min_behind_action_cd),
	Exact_Action = uar_get_code_display(dc.exact_hit_action_cd)

from	order_catalog  oc,
		order_catalog_synonym  ocs,
		dup_checking dc,
		dummyt d

plan oc
  where oc.activity_type_cd = 692
    and oc.active_ind = 1

join ocs
  where ocs.catalog_cd = oc.catalog_cd
    and ocs.active_ind = 1
    
Join D
    
Join dc
	where oc.catalog_cd = dc.catalog_cd
	and dc.active_ind = 1

order by	oc.description,
			ocs_mnemonic_type_disp
			
With outerjoin = D
go
