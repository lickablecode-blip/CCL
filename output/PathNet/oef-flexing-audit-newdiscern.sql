/*
* Name:     oef_flexing_audit_newDiscern
* Source:   Inbox/PathNet/oef_flexing_audit_newDiscern.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    23
* Notes:
*/



select distinct 			;distinct added 7/14
		;into "oef_flex"
  flex_cd = uar_get_code_display(a.flex_cd),
  ;a.flex_cd,
  a.flex_type_flag,
  a.default_value,
  a.accept_flag,
  format_name = o.oe_format_name,
  ff.accept_flag,
  field_name = oef.description
from accept_format_flexing a
    ,order_entry_format o
    ,order_entry_fields oef
    ,oe_format_fields ff
plan a
join o
  where o.oe_format_id = a.oe_format_id
join oef
  where oef.oe_field_id = a.oe_field_id
join ff
  where ff.oe_format_id = a.oe_format_id
    and ff.oe_field_id = a.oe_field_id
order by format_name, a.flex_type_flag, flex_cd, field_name
