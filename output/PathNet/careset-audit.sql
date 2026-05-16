/*
* Name:     Careset_Audit
* Source:   Inbox/PathNet/Careset_Audit.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    34
* Notes:
*/

select 
	oc.description,
	oc.primary_mnemonic,
	ocs_mnemonic_type_disp = uar_get_code_display( ocs.mnemonic_type_cd ),
	ocs.mnemonic,
	oc.orderable_type_flag,
	oc_activity_subtype_disp = uar_get_code_display( oc.activity_subtype_cd ),
	oc1.description,
	oc1.primary_mnemonic,
	ocs1.hide_flag

from
	order_catalog  oc,
	order_catalog_synonym  ocs,
	cs_component  csc,
	order_catalog_synonym  ocs1,
	order_catalog  oc1

plan oc
where oc.orderable_type_flag in (2, 6)
  and oc.activity_type_cd = 692
  and oc.active_ind = 1

join ocs
where ocs.catalog_cd = oc.catalog_cd
  and ocs.active_ind = 1

join csc
where csc.catalog_cd = oc.catalog_cd

join ocs1
where ocs1.synonym_id = csc.comp_id
  and ocs1.active_ind = 1
  and ocs1.activity_type_cd = 692

join oc1
where oc1.catalog_cd = ocs1.catalog_cd
  and oc1.active_ind = 1


order by	oc.description
GO
