/*
* Name:     Non-Viewpoit Mpages and positions
* Source:   Inbox/mPages/Non-Viewpoit Mpages and positions.txt
* Purpose:
* Imported: 2026-05-15
* Category: MPages  (reason: subfolder)
* Lines:    12
* Notes:
*/

select mpage.category_name, position.description, nvp.pvc_value
from name_value_prefs nvp, br_datamart_category mpage,
code_value position, detail_prefs dp
plan mpage where
mpage.br_datamart_category_id > 0 join nvp
where nvp.pvc_name = "REPORT_NAME"
and findstring(mpage.category_mean,
nvp.pvc_value) > 0 join dp where
dp.detail_prefs_id = nvp.parent_entity_id join
position where dp.position_cd =
position.code_value order by
mpage.category_name, position.description
