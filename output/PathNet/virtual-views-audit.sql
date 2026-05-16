/*
* Name:     Virtual views audit
* Source:   Inbox/PathNet/Virtual views audit.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    19
* Notes:
*/

select distinct
	oc.PRIMARY_MNEMONIC,
	oc.CATALOG_CD,
	ocs.MNEMONIC,
	MNEMONIC_TYPE = uar_get_code_display ( ocs.MNEMONIC_TYPE_CD ),
	ocs.SYNONYM_ID,
	facility_cd = uar_get_code_display (ocsf.facility_cd)

from order_catalog oc,
       order_catalog_synonym ocs,
	ocs_facility_r ocsf

plan ocs
  where ocs.ACTIVITY_TYPE_CD = 692
 

join oc
  where ocs.catalog_cd = oc.catalog_cd
  and oc.active_ind = 1

join ocsf
  where ocsf.synonym_id = ocs.synonym_id



order by oc.primary_mnemonic

go
