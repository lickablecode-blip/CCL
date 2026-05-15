/*
 * Source page  : UNION
 * Source file  : output/union.md
 * Anchor       : Extended example, multiple unions
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 104
 *
 * Context (preceding paragraph):
 *   The orders queries are UNIONed into an inline table and then inner- and left-joined to
 *   several other tables.
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

ELSEIF($search_for
= "Orders*" AND $rpt = "Summary" AND $order_option =
"orderable")
orderable = oc.description
,ag.agency
,facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,test_patient_ind =
UAR_GET_CODE_DISPLAY(tp.value_cd)
,nbr_orders = COUNT(o.order_id)
,nbr_patients = COUNT(o.person_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
FROM (
(SELECT ;e only
o1.catalog_cd
,o1.order_id
,o1.person_id
,o1.encntr_id
,o1.originating_encntr_id
,eid = o1.encntr_id
FROM ORDERS o1
WHERE o1.catalog_cd = $orderable
AND o1.orig_order_dt_tm >= CNVTDATETIME($start_date)
AND o1.orig_order_dt_tm <= CNVTDATETIME($end_date)
AND o1.encntr_id != 0
AND o1.originating_encntr_id = 0
AND o1.order_status_cd NOT IN (2542, 2544) ;canceled, voided
         AND
o1.template_order_flag IN (0,1,5,7) ;exclude auto-generated child orders
         AND o1.active_ind = 1
UNION
(SELECT ;o only
o2.catalog_cd
,o2.order_id
,o2.person_id
,o2.encntr_id
,o2.originating_encntr_id
,eid = o2.originating_encntr_id
FROM ORDERS o2
WHERE o2.catalog_cd = $orderable
AND o2.orig_order_dt_tm >= CNVTDATETIME($start_date)
AND o2.orig_order_dt_tm <= CNVTDATETIME($end_date)
AND o2.encntr_id = 0
AND o2.originating_encntr_id != 0
AND o2.order_status_cd NOT IN (2542, 2544) ;canceled, voided
         AND
o2.template_order_flag IN (0,1,5,7) ;exclude auto-generated child orders
         AND o2.active_ind = 1
UNION
(SELECT ;e and o, are same - includes where both = 0
o3.catalog_cd
,o3.order_id
,o3.person_id
,o3.encntr_id
,o3.originating_encntr_id
,eid = o3.encntr_id
FROM ORDERS o3
WHERE o3.catalog_cd = $orderable
AND o3.orig_order_dt_tm >= CNVTDATETIME($start_date)
AND o3.orig_order_dt_tm <= CNVTDATETIME($end_date)
AND o3.encntr_id = o3.originating_encntr_id
AND o3.order_status_cd NOT IN (2542, 2544) ;canceled, voided
         AND
o3.template_order_flag IN (0,1,5,7) ;exclude auto-generated child orders
         AND o3.active_ind = 1
UNION
(SELECT ;e and o, are different
o4.catalog_cd
,o4.order_id
,o4.person_id
,o4.encntr_id
,o4.originating_encntr_id
,eid = o4.originating_encntr_id
FROM ORDERS o4
WHERE o4.catalog_cd = $orderable
AND o4.orig_order_dt_tm >= CNVTDATETIME($start_date)
AND o4.orig_order_dt_tm <= CNVTDATETIME($end_date)
AND o4.encntr_id != 0
AND o4.originating_encntr_id != 0
AND o4.encntr_id != o4.originating_encntr_id
AND o4.order_status_cd NOT IN (2542, 2544) ;canceled, voided
         AND
o4.template_order_flag IN (0,1,5,7) ;exclude auto-generated child orders
         AND o4.active_ind = 1
) WITH
SQLTYPE("f8","f8","f8","f8","f8","f8"),
RDBUNION))) o )
,(LEFT JOIN PERSON_INFO tp ON tp.person_id = CNVTREAL(o.person_id)
AND tp.info_sub_type_cd = 2678703703 ;test patient identifier
AND tp.value_cd != 2678703509 ;"not a test patient"
AND tp.active_ind = 1)
,ENCOUNTER e
,(LEFT JOIN CUST_LOC_AGENCY_RELTN ag ON ag.location_cd =
e.loc_facility_cd)
,ORDER_CATALOG oc
PLAN o
JOIN e WHERE e.encntr_id = CNVTREAL(o.eid)
AND EXPAND(fac_idx, 1, size(fac->facility, 5), e.loc_facility_cd,
fac->facility[fac_idx].facility_cd)
JOIN oc WHERE oc.catalog_cd = CNVTREAL(o.catalog_cd)
JOIN tp
JOIN ag
GROUP BY oc.description, ag.agency, e.loc_facility_cd, tp.value_cd
ORDER BY orderable, ag.agency, facility, test_patient_ind
