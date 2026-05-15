/*
 * Source page  : Favorites
 * Source file  : output/favorites.md
 * Anchor       : Orders, PowerPlans
 * Block index  : 3 of 3
 * Detected lang: ccl
 * Lines        : 40
 *
 * Context (preceding paragraph):
 *   Once the build_favorites subroutine is called, the record structure can be queried:
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

ELSEIF($last_tab
= "config" AND $config = "Order Favorites")
path = SUBSTRING(1,1000,fav->item[d.seq].path)
,orderable = fav->item[d.seq].orderable
,order_mnemonic = fav->item[d.seq].order_mnemonic
,order_sentence = fav->item[d.seq].order_sentence
,catalog_type =
UAR_GET_CODE_DISPLAY(fav->item[d.seq].catalog_type_cd)
,activity_type =
UAR_GET_CODE_DISPLAY(fav->item[d.seq].activity_type_cd)
,activity_subtype =
UAR_GET_CODE_DISPLAY(fav->item[d.seq].activity_subtype_cd)
,last_saved_dt_tm = fav->item[d.seq].last_saved_dt_tm
"MM/DD/YYYY HH:MM;;q"
,catalog_cd = fav->item[d.seq].catalog_cd
,synonym_id = fav->item[d.seq].synonym_id
;,orderable_active_ind = fav->item[d.seq].order_active_ind
;,synonym_active_ind = fav->item[d.seq].synonym_active_ind
FROM (DUMMYT d with seq = value(size(fav->item, 5)))
PLAN d WHERE fav->item[d.seq].fav_type = "order"
ORDER BY path, CNVTUPPER(fav->item[d.seq].orderable)
ELSEIF($last_tab
= "config" AND $config = "PowerPlan Favorites")
path = SUBSTRING(1,1000,fav->item[d.seq].path)
,powerplan = fav->item[d.seq].powerplan
,favorited_name = fav->item[d.seq].powerplan_cust
,plan_type = fav->item[d.seq].plan_type
,version = fav->item[d.seq].version
,favorited_dt_tm = fav->item[d.seq].last_saved_dt_tm
"MM/DD/YYYY HH:MM;;q"
,last_ordered_dt_tm = fav->item[d.seq].last_ordered_dt_tm
"MM/DD/YYYY HH:MM;;q"
,plan_active_ind = fav->item[d.seq].plan_active_ind
,cust_plan_active_ind = fav->item[d.seq].cust_plan_active_ind
,pathway_catalog_id = fav->item[d.seq].pathway_catalog_id
,pathway_customized_plan_id =
fav->item[d.seq].pathway_customized_plan_id
FROM (DUMMYT d with seq = value(size(fav->item, 5)))
PLAN d WHERE fav->item[d.seq].fav_type = "pathway"
ORDER BY path, CNVTUPPER(fav->item[d.seq].powerplan)
