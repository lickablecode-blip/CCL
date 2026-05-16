/*
* Name:     DTA_LvL_Routing_Enhanced_Audit
* Source:   Inbox/PathNet/DTA_LvL_Routing_Enhanced_Audit.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    30
* Notes:
*/

ID orders with DTA Level Routing


select
o.catalog_cd,
o.Primary_mnemonic,
o.Dept_Display_Name,
ptr.task_assay_cd,
Assay_Name = uar_get_code_display (ptr.task_assay_cd),
apr.service_resource_cd,
Service_resource = uar_get_code_display (apr.service_resource_cd),
Result_type = uar_get_code_display (apr.default_result_type_cd),
Active = apr.active_ind

from Order_Catalog o,
Profile_task_r ptr,
assay_processing_r apr,
assay_resource_list arl

plan o
where o.active_ind = 1
and o.activity_type_cd = 692
and o.resource_route_lvl = 2 

join ptr
where ptr.catalog_cd = o.catalog_cd
and ptr.active_ind = 1

join arl 
where arl.task_assay_cd = ptr.task_assay_cd
and arl.active_ind = 1

join apr
where apr.task_assay_cd = arl.task_assay_cd
and apr.service_resource_cd = arl.service_resource_cd

order by o.Primary_mnemonic,ptr.sequence,
apr.service_resource_cd
