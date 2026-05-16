/*
* Name:     rename a TOC entry 
* Source:   Inbox/mPages/rename a TOC entry .txt
* Purpose:
* Imported: 2026-05-15
* Category: MPages  (reason: subfolder)
* Lines:    5
* Notes:
*/

select val.mpage_param_value, bdr.report_name, bdr.report_mean
from br_datamart_value val, br_datamart_report_filter_r bdrf, br_datamart_report bdr plan val
where val.mpage_param_mean = "mp_link" and val.mpage_param_value LIKE "*Allergies*"
join bdrf where bdrf.br_datamart_filter_id = val.br_datamart_filter_id join bdr where
bdr.br_datamart_report_id = bdrf.br_datamart_report_id
