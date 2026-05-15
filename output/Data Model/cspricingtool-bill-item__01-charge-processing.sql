/*
 * Source page  : CSPricingTool (bill item)
 * Source file  : output/cspricingtool-bill-item.md
 * Anchor       : Charge Processing
 * Block index  : 1 of 3
 * Detected lang: ccl
 * Lines        : 40
 *
 * Context (preceding paragraph):
 *   3/25/25 - Flag values are contained in BILL_ITEM_MODIFIER.bim1_int and need to be
 *   parsed. See "Bill Item Modifier map". Have not found reprocessing yet.
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

ELSEIF($scope
= "Orderable" AND $rpt_orderable = "Configuration (charge
processing)")
orderable =
oc.description
,bill_item = bi.ext_description
,owner = UAR_GET_CODE_DISPLAY(bi.ext_owner_cd)
,schedule = UAR_GET_CODE_DISPLAY(bim.key1_id)
,charge_level = UAR_GET_CODE_DISPLAY(bim.key4_id)
,charge_point = UAR_GET_CODE_DISPLAY(bim.key2_id)
;,reprocessing = "" ;haven't found this yet
,manual_flag = IF(bim.bim1_int IN (1,3,5,7,9,11,13,15)) "yes"
ELSE "no" ENDIF
,diagnosis_flag = IF(bim.bim1_int IN (2,3,6,7,10,11,14,15))
"yes" ELSE "no" ENDIF
,physician_flag = IF(bim.bim1_int IN (4,6,7,12,13,14,15))
"yes" ELSE "no" ENDIF
,result_is_quantity_flag = IF(bim.bim1_int IN (8,9,10,11,12,13,14,15))
"yes" ELSE "no" ENDIF
,modified_by = p.name_full_formatted
,modified_on = bim.updt_dt_tm "MM/DD/YYYY HH:MM;;q"
;IDENTIFIERS
,oc.catalog_cd
,bi.bill_item_id
,bim.bill_item_mod_id
FROM ORDER_CATALOG oc
,BILL_ITEM bi
,BILL_ITEM_MODIFIER bim
,PRSNL p
PLAN oc WHERE oc.catalog_cd = $orderable
JOIN bi WHERE oc.catalog_cd = bi.ext_parent_reference_id
AND bi.ext_parent_contributor_cd = 3443 ;order catalog
AND bi.end_effective_dt_tm > SYSDATE
AND bi.active_ind = 1
JOIN bim WHERE bim.bill_item_id = bi.bill_item_id
AND bim.bill_item_type_cd = 3460 ;Charge Point Schedule
AND bim.end_effective_dt_tm > SYSDATE
AND bim.active_ind = 1
JOIN p WHERE p.person_id = bim.updt_id
ORDER BY orderable, bill_item, schedule
