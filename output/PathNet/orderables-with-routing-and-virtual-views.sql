/*
* Name:     Orderables with routing and virtual views
* Source:   Inbox/PathNet/Orderables with routing and virtual views.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    27
* Notes:
*/

SELECT
	o.catalog_cd
	, o.primary_mnemonic
	, o.dept_display_name
	, o.active_ind
	, o.activity_type_cd
	, r.service_resource_cd
	, serv_resr = uar_get_code_display(r.service_resource_cd)
	, OC.SYNONYM_ID
	, OC.MNEMONIC
	, OC_MNEMONIC_TYPE_DISP = UAR_GET_CODE_DISPLAY(OC.MNEMONIC_TYPE_CD)
	, OFR_FACILITY_DISP = UAR_GET_CODE_DISPLAY(OFR.FACILITY_CD)
	, OFR.SYNONYM_ID

FROM
	order_catalog   o
	, orc_resource_list   r
	, ORDER_CATALOG_SYNONYM   OC
	, OCS_FACILITY_R   OFR

plan o
where o.active_ind = 1    and o.activity_type_cd = 288
join oc where oc.catalog_cd = o.catalog_cd
join ofr where  OFR.SYNONYM_ID = OC.SYNONYM_ID

join r where o.catalog_cd = r.catalog_cd       and r.active_ind = 1

ORDER BY
	o.primary_mnemonic
	, r.service_resource_cd
GO
