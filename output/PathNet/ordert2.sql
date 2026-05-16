/*
* Name:     ORDERT~2
* Source:   Inbox/PathNet/ORDERT~2.TXT
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    33
* Notes:
*/

SELECT DISTINCT
	o.catalog_cd
	, O_ACTIVITY_TYPE_DISP = UAR_GET_CODE_DISPLAY(O.ACTIVITY_TYPE_CD)
	, o.primary_mnemonic
	, o.dept_display_name
	, o.active_ind
	, o.activity_type_cd
	, r.service_resource_cd
	, serv_resr = uar_get_code_display(r.service_resource_cd)
	, p.task_assay_cd
	, dta_short = uar_get_code_display(p.task_assay_cd)
	, p.sequence
	, OC.MNEMONIC
	, OC_MNEMONIC_TYPE_DISP = UAR_GET_CODE_DISPLAY(OC.MNEMONIC_TYPE_CD)
	, OC.OE_FORMAT_ID
	, OE.OE_FORMAT_NAME

FROM
	order_catalog   o
	, orc_resource_list   r
	, profile_task_r   p
	, ORDER_CATALOG_SYNONYM   OC
	, ORDER_ENTRY_FORMAT   OE

plan o
where o.active_ind = 1

join r where o.catalog_cd = r.catalog_cd    and r.active_ind = 1  and o.ACTIVITY_TYPE_CD = 692
join p where o.catalog_cd = p.catalog_cd    and p.active_ind = 1
join oc where OC.MNEMONIC = o.primary_mnemonic   and OC.MNEMONIC_TYPE_CD = 2583
JOIN oe where OE.OE_FORMAT_ID = OC.OE_FORMAT_ID

ORDER BY
	serv_resr
	, o.catalog_cd
	, p.sequence
go
