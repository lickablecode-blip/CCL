/*
* Name:     DTA_Lvl_Routing_Audit
* Source:   Inbox/PathNet/DTA_Lvl_Routing_Audit.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    19
* Notes:
*/

select 
	oc.catalog_cd,
	oc.description,
	oc.primary_mnemonic,
	oc.dept_display_name,
	orl_service_resource_disp = uar_get_code_display( orl.service_resource_cd ),
	orl.sequence
	

from
	order_catalog  oc,
	orc_resource_list  orl

plan oc
  where oc.activity_type_cd = 692
  	and oc.active_ind = 1
	and oc.resource_route_lvl = 2

join orl
  where orl.catalog_cd = oc.catalog_cd
  	and orl.active_ind = 1

order by	oc.description,
			orl.sequence
