/*
 * Source page  : Favorites
 * Source file  : output/favorites.md
 * Anchor       : Orders, PowerPlans
 * Block index  : 2 of 3
 * Detected lang: ccl
 * Lines        : 274
 *
 * Context (preceding paragraph):
 *   Properly reproducing favorite lists for orders and PowerPlans requires using a record
 *   structure to rebuild the full path. If keeping the path intact isn't necessary for your
 *   use case, you can query the tables directly. The following example is a snippet from
 *   Personnel Detail Audit. There may be more efficient ways to do this … but at a certain
 *   point, if it works, it works!
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

free record
fav_fldr ;favorites folder structure
record
fav_fldr (
1 fldr[*]
2 folder_id = f8
2 folder = c500
2 parent_folder_id = f8
2 path = vc
) with
protect ;favorites folder structure
free record
fav ;favorites
record fav (
1 item[*]
; shared fields
2 fav_type = c7 ;"order" or "pathway"
2 path = vc
2 last_saved_dt_tm = dq8
2 last_ordered_dt_tm = dq8
; Orders
2 orderable = c100
2 order_mnemonic = c200
2 order_sentence = c255
2 catalog_type_cd = f8
2 activity_type_cd = f8
2 activity_subtype_cd = f8
2 order_active_ind = i2
2 synonym_active_ind = i2
2 catalog_cd = f8
2 synonym_id = f8
; PowerPlans
2 powerplan = c100
2 powerplan_cust = c100 ;user "favorited" name
2 plan_type = c10 ;"standard" or "customized"
2 version = i4
2 plan_active_ind = c3
2 cust_plan_active_ind = c3
2 pathway_catalog_id = f8
2 pathway_customized_plan_id = f8
1 fav_order_cnt = i4
1 fav_powerplan_cnt = id4
) with
protect ;favorites
/**************************************************************
; Subroutines
- Building the Favorites List
**************************************************************/
;Step 1 of building the favorites list
subroutine
(build_folder_list(prsnl_id) = NULL)
SELECT INTO "NL:"
FROM ALT_SEL_CAT fldr
PLAN fldr WHERE fldr.owner_id = prsnl_id
ORDER BY fldr.alt_sel_category_id
HEAD REPORT
i = 0
DETAIL
i += 1
CALL ALTERLIST(fav_fldr->fldr, i)
fav_fldr->fldr[i].folder_id = fldr.alt_sel_category_id
fav_fldr->fldr[i].folder = TRIM(fldr.short_description, 3)
fav_fldr->fldr[i].path = ""
 WITH NULLREPORT
end
;build_folder_list
;Step 2 of building the favorites list
subroutine(get_parent_folders(NULL)
= NULL)
declare fldr_cnt = i4 with protect, constant(size(fav_fldr->fldr,
5))
declare pos = i4 with protect, noconstant(0)
declare idx = i4 with noconstant(0) ;index for EXPAND or FOR loop
SELECT INTO "NL:"
FROM ALT_SEL_LIST asl
PLAN asl WHERE EXPAND(idx, 1,
fldr_cnt,        asl.child_alt_sel_cat_id,
fav_fldr->fldr[idx].folder_id)
ORDER BY asl.alt_sel_category_id
DETAIL
pos = LOCATEVAL(idx, 1, fldr_cnt, asl.child_alt_sel_cat_id,
fav_fldr->fldr[idx].folder_id)
fav_fldr->fldr[pos].parent_folder_id = asl.alt_sel_category_id
WITH NULLREPORT
end
;get_parent_folders
;Step 3 of building the favorites list
subroutine(get_path(alt_sel_cat_id
= f8) = vc)
declare fldr_cnt = i4 with protect, constant(size(fav_fldr->fldr,
5))
declare pos = i4 with protect, noconstant(0)
declare idx = i4 with protect, noconstant(0)
declare folder_id = f8 with protect, noconstant(0)
declare parent_id = f8 with protect, noconstant(0)
declare is_root = i2 with protect, noconstant(0)
declare path = vc with protect, noconstant("")
set folder_id = alt_sel_cat_id
set parent_id = fav_fldr->fldr[LOCATEVAL(pos, 1, fldr_cnt,
folder_id, fav_fldr->fldr[pos].folder_id)].parent_folder_id
set is_root = EVALUATE2(IF(parent_id = 0) 1 ELSE 0 ENDIF)
set path = fav_fldr->fldr[LOCATEVAL(pos, 1, fldr_cnt, folder_id,
fav_fldr->fldr[pos].folder_id)].folder
while (is_root = 0) ;not the parent folder
if (parent_id = 0)
set is_root = 1 ;reached the parent, time to stop
else
;find the index of the parent folder
set pos = LOCATEVAL(idx, 1, fldr_cnt, parent_id,
fav_fldr->fldr[idx].folder_id)
if (pos > 0) ;we located the parent folder in the record
set path = BUILD(fav_fldr->fldr[pos].folder, "/", path)
set parent_id = fav_fldr->fldr[pos].parent_folder_id ;update
parent_id to the parent's parent folder_id
endif
endif
endwhile
return (path)
end ;get_path
;Step 4 of building the favorites list
subroutine(add_paths(NULL)
= NULL)
declare fldr_cnt = i4 with protect, constant(size(fav_fldr->fldr,
5))
declare i = i4 with protect, noconstant(0)
for (i = 1 to fldr_cnt)
set fav_fldr->fldr[i].path =
get_path(fav_fldr->fldr[i].folder_id)
endfor
end
;add_paths
;Step 5 of building the favorites list
subroutine(build_favorite_list(NULL)
= NULL)
declare fldr_cnt = i4 with protect, constant(size(fav_fldr->fldr,
5))
declare pos = i4 with protect, noconstant(0)
declare idx = i4 with protect,
noconstant(0)
set fav->fav_order_cnt = 0
set fav->fav_powerplan_cnt = 0
; add order favorites and standard powerplans
SELECT INTO "NL:"
FROM ALT_SEL_CAT cat
,ALT_SEL_LIST item
,(LEFT JOIN ORDER_CATALOG_SYNONYM ocs ON ocs.synonym_id =
item.synonym_id)
,(LEFT JOIN ORDER_CATALOG oc ON oc.catalog_cd = ocs.catalog_cd)
,(LEFT JOIN ORDER_SENTENCE os ON os.order_sentence_id =
ocs.order_sentence_id)
,(LEFT JOIN PATHWAY_CATALOG pc ON pc.pathway_catalog_id =
item.pathway_catalog_id)
PLAN cat WHERE cat.owner_id = $prsnl
JOIN item WHERE item.alt_sel_category_id = cat.alt_sel_category_id
AND item.list_type != 1 ;exclude items that are subfolders
JOIN ocs
JOIN oc
JOIN os
JOIN pc
HEAD REPORT
i = 0
DETAIL
i += 1
CALL ALTERLIST(fav->item, i)
pos = LOCATEVAL(idx, 1, fldr_cnt, item.alt_sel_category_id,
fav_fldr->fldr[idx].folder_id)
fav->item[i].path = fav_fldr->fldr[pos].path
fav->item[i].last_saved_dt_tm = item.updt_dt_tm
IF(item.synonym_id != 0)
fav->fav_order_cnt += 1
fav->item[i].fav_type = "order"
fav->item[i].orderable = oc.description
fav->item[i].order_mnemonic = ocs.mnemonic
fav->item[i].order_sentence = TRIM(os.order_sentence_display_line,3)
fav->item[i].catalog_type_cd = oc.catalog_type_cd
fav->item[i].activity_type_cd = oc.activity_type_cd
fav->item[i].activity_subtype_cd = oc.activity_subtype_cd
fav->item[i].order_active_ind = oc.active_ind
fav->item[i].synonym_active_ind = ocs.active_ind
fav->item[i].catalog_cd = oc.catalog_cd
fav->item[i].synonym_id = ocs.synonym_id
ELSEIF(item.pathway_catalog_id != 0)
fav->fav_powerplan_cnt += 1
fav->item[i].fav_type = "pathway"
fav->item[i].powerplan = pc.description
fav->item[i].plan_type = "standard"
;fav->item[i].powerplan_cust = pcp.plan_name
fav->item[i].version = pc.version
fav->item[i].plan_active_ind = CNVTSTRING(pc.active_ind)
fav->item[i].cust_plan_active_ind = "n/a"
fav->item[i].pathway_catalog_id = pc.pathway_catalog_id
;fav->item[i].pathway_customized_plan_id =
pcp.pathway_customized_plan_id
ENDIF
WITH NULLREPORT
; add customized powerplans
SELECT INTO "NL:"
FROM PATHWAY_CUSTOMIZED_PLAN pcp
,PATHWAY_CATALOG pc
PLAN pcp WHERE pcp.prsnl_id = $prsnl
JOIN pc WHERE pc.pathway_catalog_id = pcp.pathway_catalog_id
HEAD REPORT
i = value(size(fav->item, 5))
DETAIL
i += 1
CALL ALTERLIST(fav->item, i)
fav->fav_powerplan_cnt += 1
fav->item[i].path = "My Favorite Plans"
fav->item[i].last_saved_dt_tm = pcp.updt_dt_tm
fav->item[i].fav_type = "pathway"
fav->item[i].powerplan = pc.description
fav->item[i].plan_type = "customized"
fav->item[i].powerplan_cust = pcp.plan_name
fav->item[i].version = pc.version
fav->item[i].plan_active_ind = CNVTSTRING(pc.active_ind)
fav->item[i].cust_plan_active_ind = CNVTSTRING(pcp.active_ind)
fav->item[i].pathway_catalog_id = pc.pathway_catalog_id
fav->item[i].pathway_customized_plan_id =
pcp.pathway_customized_plan_id
WITH NULLREPORT
end
;build_favorite_list
subroutine(get_powerplan_last_ordered(NULL)
= NULL)
DECLARE idx = i4 WITH protect, noconstant(0)
DECLARE num = i4 WITH protect, noconstant(0)
DECLARE pos = i4 WITH protect, noconstant(0)
SELECT INTO "NL:"
p.pathway_catalog_id
,pcp.pathway_customized_plan_id
,last_ordered_dt_tm = MAX(pa.action_dt_tm); "MM/DD/YYYY;;d"
FROM PATHWAY p
 ,(LEFT JOIN
PATHWAY_CUSTOMIZED_PLAN pcp ON pcp.pathway_catalog_id = p.pathway_catalog_id
 AND pcp.prsnl_id =
$prsnl)
 ,PATHWAY_ACTION pa
PLAN p WHERE EXPAND(idx, 1, size(fav->item, 5),
p.pathway_catalog_id, fav->item[idx].pathway_catalog_id)
JOIN pa WHERE pa.pathway_id = p.pathway_id
 AND pa.action_prsnl_id =
$prsnl
 AND pa.action_type_cd = 10752
;order
JOIN pcp
GROUP BY p.pathway_catalog_id, pcp.pathway_customized_plan_id
ORDER BY p.pathway_catalog_id, pcp.pathway_customized_plan_id
DETAIL
;For each combination of pathway_catalog_id and
pathway_customized_plan_id,
;look up the corresponding record and assign last_ordered_dt_tm
pos = LOCATEVAL(num, 1, size(fav->item, 5), p.pathway_catalog_id,
fav->item[num].pathway_catalog_id)
IF(pos != 0 AND fav->item[pos].pathway_customized_plan_id =
pcp.pathway_customized_plan_id)
fav->item[pos].last_ordered_dt_tm = last_ordered_dt_tm
;MAX(pa.action_dt_tm);
ENDIF
WITH NULLREPORT
end
;get_powerplan_last_ordered
;Convenience routine for building the order favorites
list
subroutine(build_favorites(prsnl_id
= f8) = NULL)
CALL build_folder_list(prsnl_id)
CALL get_parent_folders(NULL)
CALL add_paths(NULL)
CALL build_favorite_list(NULL)
IF(fav->fav_powerplan_cnt != 0)
CALL get_powerplan_last_ordered(NULL)
ENDIF
end
;build_favorites
