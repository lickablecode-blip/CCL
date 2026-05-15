/*
 * Source page  : DB Item Location Maintenance
 * Source file  : output/db-item-location-maintenance.md
 * Anchor       : List of medications & Item Control tab
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 82
 *
 * Context (preceding paragraph):
 *   EXPLORE: Performance with OBJECT_IDENTIFIER_INDEX tables is poor. Could some or all of
 *   these be replaced with MED_IDENTIFIER?
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

; Quantity on
Hand
SELECT
location = loc.display
,location_type = loc.cdf_meaning
,item_nbr = oii_item_nbr.value
,description = oii_item_desc.value
,short_description = oii_short_desc.value
,qoh_qty = qoh.qty
,qoh_type = UAR_GET_CODE_DISPLAY(qoh.qoh_type_cd)
,perpetual_inventory_ind = ici.stock_type_ind
,track_instances = EVALUATE(ici.instance_ind, 1, "yes",
"no")
,count_cycle = UAR_GET_CODE_DISPLAY(ici.count_cycle_cd)
,lot_tracking_level = UAR_GET_CODE_DISPLAY(ici.lot_tracking_level_cd)
,base_package_type = base_pack.description
,base_package_qty = base_pack.qty
,abc_classification = UAR_GET_CODE_DISPLAY(ici.abc_class_cd)
,charge_type = UAR_GET_CODE_DISPLAY(ici.charge_type_cd)
,stock_package_type = stock_pack.description
,stock_package_qty = stock_pack.qty
,cost_center = UAR_GET_CODE_DISPLAY(ici.cost_center_cd)
,g_l_subaccount = UAR_GET_CODE_DISPLAY(ici.sub_account_cd)
,schedulable_qty = ici.sch_qty
,countback = EVALUATE(ici.countback_flag,
0, "No count required",
1, "Blind counting",
2, "Confirm count",
"undefined flag value")
;identifiers
,qoh.item_id
FROM
CODE_VALUE loc
,QUANTITY_ON_HAND qoh
,ITEM_CONTROL_INFO ici
,OBJECT_IDENTIFIER_INDEX oii_item_nbr
,OBJECT_IDENTIFIER_INDEX oii_item_desc
,OBJECT_IDENTIFIER_INDEX oii_short_desc
,PACKAGE_TYPE base_pack
,PACKAGE_TYPE stock_pack
PLAN loc
WHERE 1=1
AND CNVTUPPER(loc.display) = "0123-PEDS IMMUNIZATION LOT INV"
AND loc.cdf_meaning IN ("INVLOC", "PHARM") ; not
all-inclusive!
AND loc.active_ind = 1
JOIN qoh
WHERE qoh.location_cd = loc.code_value;
AND qoh.active_ind = 1
JOIN ici
WHERE ici.item_id = qoh.item_id
AND ici.location_cd = qoh.location_cd
JOIN
oii_item_nbr WHERE oii_item_nbr.object_id = qoh.item_id
AND oii_item_nbr.identifier_type_cd = 3101 ;item number (CS 11000)
AND oii_item_nbr.rel_parent_entity_id = 0
AND oii_item_nbr.relationship_type_cd = 0
AND oii_item_nbr.active_ind = 1
JOIN
oii_item_desc WHERE oii_item_desc.object_id = qoh.item_id
AND oii_item_desc.identifier_type_cd = 3097 ;description (CS 11000)
AND oii_item_desc.rel_parent_entity_id = 0
AND oii_item_desc.relationship_type_cd = 0
AND oii_item_desc.active_ind = 1
JOIN
oii_short_desc WHERE oii_short_desc.object_id = qoh.item_id
AND oii_short_desc.identifier_type_cd = 3109 ;short description (CS
11000)
AND oii_short_desc.rel_parent_entity_id = 0
AND oii_short_desc.relationship_type_cd = 0
AND oii_short_desc.active_ind = 1
JOIN
base_pack WHERE base_pack.package_type_id = qoh.package_type_id
AND base_pack.package_type_id != 0
AND base_pack.active_ind = 1
JOIN
stock_pack WHERE stock_pack.package_type_id = ici.stock_package_type_id
AND stock_pack.package_type_id != 0
AND stock_pack.active_ind = 1
ORDER BY
item_nbr
WITH TIME=90
