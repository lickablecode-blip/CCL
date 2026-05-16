/*
* Name:     MPage Document Filter Audit
* Source:   Inbox/mPages/MPage Document Filter Audit.txt
* Purpose:
* Imported: 2026-05-15
* Category: MPages  (reason: subfolder)
* Lines:    88
* Notes:
*/

select distinct
mpage=c.category_name
, position=uar_get_code_display(x.parent_entity_id)
, component=r.report_name
, filter=if(f.filter_display = "Clinical Documentation")f.filter_display
  elseif(f.filter_display = "Clinical Documentation Label")f.filter_display
  elseif(f.filter_display = "Clinical documentation specialty group #1 subsection label")"Specialty Group #1"
  elseif(f.filter_display = "Clinical documentation specialty group #1 results")"Group #1 Results"
  elseif(f.filter_display = "Clinical documentation specialty group #2 subsection label")"Specialty Group #2"
  elseif(f.filter_display = "Clinical documentation specialty group #2 results")"Group #2 Results"
  elseif(f.filter_display = "Clinical documentation specialty group #3 subsection label")"Specialty Group #3"
  elseif(f.filter_display = "Clinical documentation specialty group #3 results")"Group #3 Results"
  elseif(f.filter_display = "Clinical documentation specialty group #4 subsection label")"Specialty Group #4"
  elseif(f.filter_display = "Clinical documentation specialty group #4 results")"Group #4 Results"
  elseif(f.filter_display = "Clinical documentation specialty group #5 subsection label")"Specialty Group #5"
  elseif(f.filter_display = "Clinical documentation specialty group #5 results")"Group #5 Results"
  elseif(f.filter_display = "Clinical documentation specialty group #6 subsection label")"Specialty Group #6"
  elseif(f.filter_display = "Clinical documentation specialty group #6 results")"Group #6 Results"
  elseif(f.filter_display = "Clinical documentation specialty group #7 subsection label")"Specialty Group #7"
  elseif(f.filter_display = "Clinical documentation specialty group #7 results")"Group #7 Results"
  elseif(f.filter_display = "Clinical documentation specialty group #8 subsection label")"Specialty Group #8"
  elseif(f.filter_display = "Clinical documentation specialty group #8 results")"Group #8 Results"
  elseif(f.filter_display = "Clinical documentation specialty group #9 subsection label")"Specialty Group #9"
  elseif(f.filter_display = "Clinical documentation specialty group #9 results")"Group #9 Results"
  elseif(f.filter_display = "Clinical documentation specialty group #10 subsection label")"Specialty Group #10"
  elseif(f.filter_display = "Clinical documentation specialty group #10 results")"Group #10 Results"  
  endif
, mpage_setting=v1.freetext_desc
, parent_ec_cd=e1.event_cd
, parent_ec_disp=uar_get_code_display(e1.event_cd)
, child_es_disp=vc.event_set_cd_disp
, child_ec=e.event_cd
, child_ec_disp=uar_get_code_display(e.event_cd)
from
br_datamart_category c
, br_datamart_report r
, br_datamart_value v
, br_datamart_flex x
, br_datamart_report_filter_r fr
, br_datamart_filter f
, br_datamart_value v1
, v500_event_set_canon vsc
, v500_event_set_explode e
, v500_event_set_code vc
, v500_event_set_explode e1
plan c where c.category_name = "Prenatal Workflow"
join r where r.br_datamart_category_id = c.br_datamart_category_id
and r.report_name = "Documents"
join v where v.br_datamart_category_id = c.br_datamart_category_id
and v.parent_entity_id = r.br_datamart_report_id
and v.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
join x where x.br_datamart_flex_id = outerjoin(v.br_datamart_flex_id)
join fr where fr.br_datamart_report_id = v.parent_entity_id
join f where f.br_datamart_category_id = v.br_datamart_category_id
and f.br_datamart_filter_id = fr.br_datamart_filter_id
and f.filter_display in 
("Clinical Documentation"
,"Clinical Documentation Label"
,"Clinical documentation specialty group #1 subsection label"
,"Clinical documentation specialty group #1 results"
,"Clinical documentation specialty group #2 subsection label"
,"Clinical documentation specialty group #2 results"
,"Clinical documentation specialty group #3 subsection label"
,"Clinical documentation specialty group #3 results"
,"Clinical documentation specialty group #4 subsection label"
,"Clinical documentation specialty group #4 results"
,"Clinical documentation specialty group #5 subsection label"
,"Clinical documentation specialty group #5 results"
,"Clinical documentation specialty group #6 subsection label"
,"Clinical documentation specialty group #6 results"
,"Clinical documentation specialty group #7 subsection label"
,"Clinical documentation specialty group #7 results"
,"Clinical documentation specialty group #8 subsection label"
,"Clinical documentation specialty group #8 results"
,"Clinical documentation specialty group #9 subsection label"
,"Clinical documentation specialty group #9 results"
,"Clinical documentation specialty group #10 subsection label"
,"Clinical documentation specialty group #10 results")
join v1 where v1.br_datamart_category_id = f.br_datamart_category_id
and v1.br_datamart_filter_id = f.br_datamart_filter_id
and v1.br_datamart_flex_id = v.br_datamart_flex_id
join vsc where vsc.parent_event_set_cd = outerjoin(v1.parent_entity_id)
join e where e.event_set_cd=outerjoin(vsc.event_set_cd)
and e.event_set_level = outerjoin(0)
join vc where vc.event_set_cd = outerjoin(e.event_set_cd)
join e1 where e1.event_set_cd = outerjoin(v1.parent_entity_id)
and e1.event_set_level = outerjoin(0)
order by c.category_name, position, f.filter_seq, mpage_setting, vc.event_set_cd_disp
