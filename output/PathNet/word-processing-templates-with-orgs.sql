/*
* Name:     word_processing_templates_with_orgs
* Source:   Inbox/PathNet/word_processing_templates_with_orgs.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    32
* Notes:
*/

select wp.short_desc, org.organization_id,
org.org_name, wp.*
from wp_template wp,
filter_entity_reltn fer,
organization org
plan wp where wp.active_ind = 1
join fer where fer.parent_entity_name = "WP_TEMPLATE" 
and fer.parent_entity_id = wp.template_id 
and fer.end_effective_dt_tm > sysdate
join org where fer.filter_entity1_id = org.organization_id
and org.active_ind = 1
order by wp.short_desc, org.org_name_key go 

-------------------------------------------------------------------------------------------------------

select wp.short_desc, 
org.organization_id,
org.org_name,
wp.*,
lt.long_text


from wp_template wp,
filter_entity_reltn fer,
organization org,
wp_template_text wtt,
long_text lt

plan wp where wp.active_ind = 1
join fer where fer.parent_entity_name = "WP_TEMPLATE" 
and fer.parent_entity_id = wp.template_id 
and fer.end_effective_dt_tm > sysdate
join org where fer.filter_entity1_id = org.organization_id
and org.active_ind = 1 and org.organization_id = 589723
join wtt where wtt.template_id = wp.template_id
join lt where lt.long_text_id = wtt.long_text_id

order by wp.short_desc, org.org_name_key go
