/*
 * Source page  : CSPricingTool (bill item)
 * Source file  : output/cspricingtool-bill-item.md
 * Anchor       : Price Schedules
 * Block index  : 3 of 3
 * Detected lang: ccl
 * Lines        : 43
 *
 * Context (preceding paragraph):
 *   Those rows are likely found in PRICE_SCHED, whereas the populated data is in
 *   PRICE_SCHED_ITEMS
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

ELSEIF($scope
= "Orderable" AND $rpt_orderable = "Configuration (price
schedules)")
orderable =
oc.description
,bill_item = bi.ext_description
,owner = UAR_GET_CODE_DISPLAY(bi.ext_owner_cd)
,price_schedule = ps.price_sched_desc
;,psi.detail_charge_ind
,psi.stats_only_ind
,interval_template = UAR_GET_CODE_DISPLAY(psi.interval_template_cd)
,psi.units_ind
,psi.price
,mark_up = psi.cost_adj_amt
,psi.tax
,psi.beg_effective_dt_tm "MM/DD/YYYY HH:MM;;q"
,psi.end_effective_dt_tm "MM/DD/YYYY HH:MM;;q"
,modified_by = p.name_full_formatted
,modified_on = psi.updt_dt_tm "MM/DD/YYYY HH:MM;;q"
;IDENTIFIERS
,oc.catalog_cd
,bi.bill_item_id
,psi.price_sched_items_id
,ps.price_sched_id
FROM ORDER_CATALOG oc
,BILL_ITEM bi
,PRICE_SCHED_ITEMS psi
,PRICE_SCHED ps
,PRSNL p
PLAN oc WHERE oc.catalog_cd = $orderable
JOIN bi WHERE oc.catalog_cd = bi.ext_parent_reference_id
AND bi.ext_parent_contributor_cd = 3443 ;order catalog
AND bi.end_effective_dt_tm > SYSDATE
AND bi.active_ind = 1
JOIN psi WHERE psi.bill_item_id = bi.bill_item_id
AND psi.end_effective_dt_tm > SYSDATE
AND psi.active_ind = 1
JOIN ps WHERE ps.price_sched_id = psi.price_sched_id
AND ps.end_effective_dt_tm > SYSDATE
AND ps.active_ind = 1
JOIN p WHERE p.person_id = psi.updt_id
ORDER BY orderable, CNVTUPPER(bi.ext_description),
CNVTUPPER(ps.price_sched_desc)
