/*
* Name:     Orders Routing with and without Service Resources
* Source:   Inbox/PathNet/Orders Routing with and without Service Resources.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    44
* Notes:
*/

SELECT
	ORDERS = UAR_GET_CODE_DISPLAY( O.CATALOG_CD )
      , O.CATALOG_CD
	, dta_short = uar_get_code_display(p.task_assay_cd)
	 , serv_resr = uar_get_code_display(r.service_resource_cd)
	;, pst_specimen_type_disp = uar_get_code_display( pst.specimen_type_cd )
	;, pst.specimen_type_cd
	;, A_DEFAULT_RESULT_TYPE_DISP = UAR_GET_CODE_DISPLAY(A.DEFAULT_RESULT_TYPE_CD)
	, o.primary_mnemonic
	, o.dept_display_name
	, r.service_resource_cd
	, orders_active = o.active_ind
	, resource_active = r.active_ind
	, p.task_assay_cd
	, p.sequence
	, o.activity_type_cd

FROM
	order_catalog   o
	;, procedure_specimen_type  pst
	, orc_resource_list   r
	, profile_task_r   p
	;, ASSAY_PROCESSING_R   A

plan o where o.active_ind = 1 and o.activity_type_cd = 692
or (o.active_ind = 1 and o.activity_type_cd = 692 and O.CATALOG_CD not in (select distinct Catalog_cd from orc_resource_list p where p.active_ind = 1) 
and O.ORDERABLE_TYPE_FLAG not in (6,2))


join r where r.catalog_cd = outerjoin(o.catalog_cd) ;and r.active_ind = 1
join p where o.catalog_cd = p.catalog_cd and p.active_ind = 1
;join a where a.service_resource_cd = r.service_resource_cd  and a.task_assay_cd = p.task_assay_cd
;join pst where pst.catalog_cd = o.catalog_cd


GROUP BY
	o.catalog_cd
	, o.primary_mnemonic
	, o.active_ind
	, o.dept_display_name
	, r.service_resource_cd
	, p.task_assay_cd
	, p.sequence
	;, A.DEFAULT_RESULT_TYPE_CD
	, o.activity_type_cd
	;, pst.specimen_type_cd

ORDER BY
	;dta_short
	serv_resr
	;, A_DEFAULT_RESULT_TYPE_DISP
