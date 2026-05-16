/*
* Name:     Order_No_Routing
* Source:   Inbox/PathNet/Order_No_Routing.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    9
* Notes:
*/


SELECT 
	ORDERS_NO_ROUTING = UAR_GET_CODE_DISPLAY( O.CATALOG_CD ),
	O.CATALOG_CD

FROM
	ORDER_CATALOG  O

Plan O where  O.ACTIVE_IND = 1 and  O.ACTIVITY_TYPE_CD = 692 and  O.CATALOG_CD
not in (select distinct Catalog_cd from orc_resource_list p where p.active_ind = 1)
and  O.ORDERABLE_TYPE_FLAG not in (6,2)

ORDER BY	ORDERS_NO_ROUTING
