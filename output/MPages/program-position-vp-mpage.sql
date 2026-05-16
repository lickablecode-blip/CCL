/*
* Name:     Program, position, VP, Mpage
* Source:   Inbox/mPages/Program, position, VP, Mpage.txt
* Purpose:
* Imported: 2026-05-15
* Category: MPages  (reason: subfolder)
* Lines:    50
* Notes:
*/

select
application=a.description
, position=c.display
, toc_disp=n.pvc_value
;, seq=trim(n2.pvc_value)
, viewpoint=m.viewpoint_name
, mpage=cat.category_name
;, seq=trim(cnvtstring(r.view_seq))
from
view_prefs v
, code_value c
, detail_prefs d
, name_value_prefs n
, application a
, name_value_prefs n2
, name_value_prefs n3
, mp_viewpoint m
, mp_viewpoint_reltn r
, br_datamart_category cat
plan v where v.frame_type = "CHART"
and v.view_name = "DISCERNRPT"
;and v.application_number = 600005 ; Powerchart is 600005 and firstnet is 4250111
join c where c.code_value = v.position_cd
and c.active_ind = 1
and c.display = "*" ; Enter position name
join a where a.application_number = v.application_number
join d where d.application_number = v.application_number
and d.position_cd = v.position_cd
and d.view_name = v.view_name
and d.view_seq = v.view_seq
join n2 where n2.parent_entity_id = v.view_prefs_id
and n2.pvc_name = "DISPLAY_SEQ"
join n3 where n3.parent_entity_id = d.detail_prefs_id
and n3.pvc_name = "REPORT_NAME"
and n3.pvc_value = "<url>$DM_INFO:CONTENT_SERVICE_URL$/mp-content*"
join n where n.parent_entity_id = v.view_prefs_id
and n.pvc_name = "VIEW_CAPTION"
join m where m.viewpoint_name_key = value(substring(findstring('vId="', n3.pvc_value)+5
,(findstring('"&s',trim(n3.pvc_value,7))-(findstring('vId="', n3.pvc_value)+5))
, n3.pvc_value), n3.pvc_value)
and m.viewpoint_name = "*" ; Enter viewpoint name
join r where r.mp_viewpoint_id = m.mp_viewpoint_id
join cat where cat.br_datamart_category_id = r.br_datamart_category_id
;and cat.layout_flag = 1
and cat.category_name = "Inpatient Hospitalist Admit Workflow" ; Enter Mpage Name Here
order by a.description
, cnvtupper(c.display)
, cnvtstring(n2.pvc_value)
, r.view_seq
;, cnvtupper(cat.category_name)
