/*
* Name:     Advance Growth Chart
* Source:   Inbox/mPages/Advance Growth Chart.txt
* Purpose:
* Imported: 2026-05-15
* Category: MPages  (reason: subfolder)
* Lines:    12
* Notes:
*/

select 
chart_source_disp = uar_get_code_display (cd.chart_source_cd),
chart_type_disp = uar_get_code_display (cd.chart_type_cd),
sex_disp = uar_get_code_display (cd.sex_cd), 
cd.chart_title,
cd.min_age, 
cd.max_age
from chart_definition cd
plan cd
where cd.active_ind= 1 
order by cd.chart_title
with maxrec = 200, time = 30
