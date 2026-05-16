/*
* Name:     Tempates_audit
* Source:   Inbox/PathNet/Tempates_audit.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    12
* Notes:
*/

select
	wt_activity_type_disp = uar_get_code_display(wt.activity_type_cd),
	lt.long_text,
	wt.short_desc
 
from
	wp_template_text wtt,
	wp_template wt,
	long_text lt
 
plan wt where wt.activity_type_cd = 692
join wtt where wtt.template_id = wt.template_id
join lt where lt.long_text_id = wtt.long_text_id
order by wt_activity_type_disp,wt.short_desc
