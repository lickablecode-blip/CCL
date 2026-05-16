/*
* Name:     Orderable Audit with synonym's & OEFs
* Source:   Inbox/PathNet/Orderable Audit with synonym's & OEFs.txt
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
	oef.OE_FORMAT_NAME,
	oef.OE_FORMAT_ID 

from order_catalog oc,
       order_catalog_synonym ocs,
	 order_entry_format oef

plan oc
  where oc.ACTIVITY_TYPE_CD = 692 and oc.active_ind = 1

join ocs
  where ocs.catalog_cd = oc.catalog_cd

join oef
  where oef.oe_format_id = oc.oe_format_id

order by oc.primary_mnemonic

go
