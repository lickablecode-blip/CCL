/*
* Name:     Coll_Priority_Audit
* Source:   Inbox/PathNet/Coll_Priority_Audit.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    14
* Notes:
*/

select 
	cp_coll_priority_disp = uar_get_code_display( cp.collection_priority_cd ),
	cp_coll_priority_desc = uar_get_code_description( cp.collection_priority_cd ),
	cp.after_last_ind,
	cp.before_first_ind,
	cp.group_with_other_flag,
	cp.immediate_print_ind,
	cp.time_study_ind,
	cp.label_sequence,
	cp_def_rep_pri = uar_get_code_display( cp.default_report_priority_cd )
	

from
	collection_priority	cp

where cp.collection_priority_cd > 0

order by	cp_coll_priority_disp
