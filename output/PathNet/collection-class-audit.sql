/*
* Name:     Collection_Class_Audit
* Source:   Inbox/PathNet/Collection_Class_Audit.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    7
* Notes:
*/

select into "nl:"
	cc_coll_class_disp = uar_get_code_display( cc.coll_class_cd ),
	cc.max_class_volume

from
	collection_class  cc

where cc.coll_class_cd > 0

order by	cc_coll_class_disp
