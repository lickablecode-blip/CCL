/*
* Name:     Order_DTA with Service resource
* Source:   Inbox/PathNet/Order_DTA with Service resource.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    23
* Notes:
*/

This CCL can be used for pulling the ref lab order/dtas for aliasing and also part of the
DTA sequencing process (see DTA sequencing word doc w/ CCLS)


Select 
o.catalog_cd,
o.primary_mnemonic,
o.dept_display_name,
o.active_ind,
o.activity_type_cd,
r.service_resource_cd,
serv_resr = uar_get_code_display(r.service_resource_cd),
p.task_assay_cd,
dta_short = uar_get_code_display(p.task_assay_cd),
p.sequence

from 
order_catalog o,
orc_resource_list r,
profile_task_r p


plan o
where o.active_ind = 1

join r where o.catalog_cd = r.catalog_cd and r.active_ind = 1
join p where o.catalog_cd = p.catalog_cd and p.active_ind = 1

order by serv_resr,o.catalog_cd,p.sequence
go
