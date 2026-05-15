/*
 * Source page  : CSPricingTool (bill item)
 * Source file  : output/cspricingtool-bill-item.md
 * Anchor       : Bill Codes
 * Block index  : 2 of 3
 * Detected lang: ccl
 * Lines        : 34
 *
 * Context (preceding paragraph):
 *   3/25/25 - Query complete in Order Detail Audit.
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

ELSEIF($scope
= "Orderable" AND $rpt_orderable = "Configuration (bill
codes)")
orderable = oc.description
,bill_item = bi.ext_description
,owner = UAR_GET_CODE_DISPLAY(bi.ext_owner_cd)
,bill_code_schedule = UAR_GET_CODE_DISPLAY(bim.key1_id)
,code = bim.key6
,description = bim.key7
,qcf = bim.bim1_nbr
,priority = bim.bim1_int
,bim.beg_effective_dt_tm "MM/DD/YYYY HH:MM;;q"
,bim.end_effective_dt_tm "MM/DD/YYYY HH:MM;;q"
,modified_by = p.name_full_formatted
,modified_on = bim.updt_dt_tm "MM/DD/YYYY HH:MM;;q"
;IDENTIFIERS
,catalog_cd = bi.ext_parent_reference_id
,bi.bill_item_id
,bim.bill_item_mod_id
FROM ORDER_CATALOG oc
,BILL_ITEM bi
,BILL_ITEM_MODIFIER bim
,PRSNL p
PLAN oc WHERE oc.catalog_cd = $orderable
JOIN bi WHERE bi.ext_parent_reference_id = oc.catalog_cd
AND bi.ext_parent_contributor_cd = 3443 ;order catalog
AND bi.end_effective_dt_tm > SYSDATE
AND bi.active_ind = 1
JOIN bim WHERE bim.bill_item_id = bi.bill_item_id
AND bim.bill_item_type_cd = 3459 ;bill code
AND bim.end_effective_dt_tm > SYSDATE
AND bim.active_ind = 1
JOIN p WHERE p.person_id = bim.updt_id
ORDER BY orderable, CNVTUPPER(bi.ext_description), bill_code_schedule
