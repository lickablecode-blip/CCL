/*
* Name:     Order_No_DTA
* Source:   Inbox/PathNet/Order_No_DTA.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    10
* Notes:
*/

SELECT 
	ORDERS_NO_DTAS = UAR_GET_CODE_DISPLAY( O.CATALOG_CD ),
	O.CATALOG_CD

FROM
	ORDER_CATALOG  O

Plan O where  O.ACTIVE_IND = 1 and  O.ACTIVITY_TYPE_CD = 692 and
o.catalog_cd
not in (select distinct Catalog_cd from profile_task_r p where p.active_ind = 1)
and  O.ORDERABLE_TYPE_FLAG not in (6,2)

ORDER BY	ORDERS_NO_DTAS
