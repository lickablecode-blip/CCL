/*
* Name:     Note Template Usage
* Source:   Inbox/Notes & Templates/Note Template Usage.txt
* Purpose:
* Imported: 2026-05-15
* Category: PowerForms  (reason: subfolder)
* Lines:    21
* Notes:
*/

select 
        Note_Title = ce.event_title_text
        ,Total = count(ce.event_title_text)
        
from
        clinical_event ce

plan ce 
        where ce.entry_mode_cd = (
                select c.code_value
                from code_value c
                where c.code_set = 29520
                and c.cdf_meaning = "DYNDOC") ;Dynamic Documents only
        and ce.view_level = 1 ;Viewable Rows
        and ce.valid_until_dt_tm > cnvtdatetime("07-jul-2021 23:59:59") ;MODIFY END Date
        and ce.valid_from_dt_tm < cnvtdatetime ("07-jul-2021 23:59:59") ;MODIFY END Date
        and ce.performed_dt_tm > cnvtdatetime  ("01-jul-2021 00:00:00") ;MODIFY BEGIN Date
        and ce.performed_dt_tm < cnvtdatetime  ("01-jul-2021 23:59:59") ;MODIFY END Date

group by
        ce.event_title_text

order by 
        Total desc

with time = 30
