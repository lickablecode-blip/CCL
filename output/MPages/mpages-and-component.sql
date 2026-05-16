/*
* Name:     MPages and component
* Source:   Inbox/mPages/MPages and component.txt
* Purpose:
* Imported: 2026-05-15
* Category: MPages  (reason: subfolder)
* Lines:    6
* Notes:
*/

select component.report_name , component.report_mean, mpage.category_name,
mpage.category_mean
from br_datamart_report component, br_datamart_category mpage
plan component where component.report_name = "Advanced Growth Chart"
join mpage where component.br_datamart_category_id = mpage.br_datamart_category_id order by
component.report_mean, mpage.category_name
