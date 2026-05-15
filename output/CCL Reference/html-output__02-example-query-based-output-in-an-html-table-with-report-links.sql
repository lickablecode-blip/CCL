/*
 * Source page  : HTML output
 * Source file  : output/html-output.md
 * Anchor       : Example: query-based output in an HTML table, with report links
 * Block index  : 2 of 4
 * Detected lang: ccl
 * Lines        : 202
 *
 * Context (preceding paragraph):
 *   Both basic HTML and CSS are supported, although they need to be added inline or wrapped
 *   in the page's <style> tags instead of loading a separate file. Capabilities will vary
 *   based on the browser used in the Discern Output Viewer, which can be configured to use
 *   either IE or Edge. This is a global setting across all Discern reports. Images are
 *   theoretically supported but must be on the server (unsure if it needs to be on the
 *   server launching IE, or on the server/node running the CCL program).
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

ELSEIF($cat =
"encounter" AND $enc_rpt = "Orders (interactive)")
 orderable = oc.description
 ,ordered_as =
         IF(TRIM(oc.description)
= TRIM(o.ordered_as_mnemonic)) ""
         ELSE
o.ordered_as_mnemonic ;often contains brand name
         ENDIF
 ,order_dt_tm =
DATETIMEZONEFORMAT(o.orig_order_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,order_status =
UAR_GET_CODE_DISPLAY(o.order_status_cd)
 ,order_entered_by =
CNVTUPPER(order_enter.name_full_formatted)
 ,order_signed_by =
CNVTUPPER(order_sign.name_full_formatted)
 ,order_detail =
SUBSTRING(1,250,replace_CRLF(o.order_detail_display_line))
 ,last_communication_type =
UAR_GET_CODE_DISPLAY(o.latest_communication_type_cd)
 ,catalog_type =
UAR_GET_CODE_DISPLAY(oc.catalog_type_cd)
 ,activity_type =
UAR_GET_CODE_DISPLAY(oc.activity_type_cd)
 ,activity_subtype =
UAR_GET_CODE_DISPLAY(oc.activity_subtype_cd)
 ,clinical_category =
UAR_GET_CODE_DISPLAY(o.dcp_clin_cat_cd)
 ,start_dt_tm =
DATETIMEZONEFORMAT(o.current_start_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,projected_stop_dt_tm =
DATETIMEZONEFORMAT(o.projected_stop_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,discontinue_dt_tm =
DATETIMEZONEFORMAT(o.discontinue_effective_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,discontinue_type =
UAR_GET_CODE_DISPLAY(o.discontinue_type_cd)
,order_type =
         IF(o.originating_encntr_id
!= 0 AND o.encntr_id = 0) "future (unactivated)"
         ELSEIF(o.originating_encntr_id
!= 0 AND o.encntr_id != 0) "future (activated)"
         ELSEIF(o.originating_encntr_id
= 0) "non-future"
         ELSE "other"
         ENDIF
,template_flag = EVALUATE(o.template_order_flag,
         0, "None",
         1, "Template",
         2, "Order-based
Instance",
         3, "Task-based
Instance",
         4, "Rx-based
Instance",
         5, "Future
Recurring Template",
         6, "Future
Recurring Instance",
         7, "Protocol",
         "<unmapped
value>")
,contrib_system = UAR_GET_CODE_DISPLAY(o.contributor_system_cd)
 ,encntr_fin = ids->fin
,originating_fin =
origin_fin.alias
,o.order_id
 FROM ORDERS o
         ,(LEFT JOIN ENCNTR_ALIAS
origin_fin ON
                 (
                 (origin_fin.encntr_id
= o.originating_encntr_id AND o.originating_encntr_id != 0)
         OR
                 (origin_fin.encntr_id
= o.encntr_id AND o.originating_encntr_id = 0)
                 )
                 AND
origin_fin.encntr_alias_type_cd = 1077 ;FIN
                 AND
origin_fin.end_effective_dt_tm > SYSDATE
                 AND
origin_fin.active_ind = 1)
 ,(LEFT JOIN ORDER_ACTION oa ON
o.order_id = oa.order_id        AND
oa.action_type_cd = 2534)
 ,(LEFT JOIN PRSNL order_enter ON
oa.action_personnel_id = order_enter.person_id)
 ,(LEFT JOIN PRSNL order_sign ON
oa.order_provider_id = order_sign.person_id)
 ,ORDER_CATALOG oc
 PLAN o WHERE (o.encntr_id =
ids->encntr_id OR o.originating_encntr_id = ids->encntr_id)
         ;AND o.order_status_cd
NOT IN (2542, 2544, 2545) ;canceled, voided, discontinued
         AND
o.template_order_flag IN (0,1,5,7) ;exclude auto-generated child orders
(instances)
         AND o.active_ind = 1
 JOIN oc WHERE o.catalog_cd = oc.catalog_cd
 JOIN origin_fin
 JOIN oa
 JOIN order_enter
 JOIN order_sign
ORDER BY order_dt_tm, o.orig_order_convs_seq
HEAD REPORT
i=0
row+1 "<html>"
row+1 "<head>"
row+1 "<meta content='CCLLINK' name='discern'>"
row+1        "<title>Orders
(interactive)</title>"
row+1        "<style>"
row+1                "html,
body, table { font: normal 0.9em/1.5em Arial, Helvetica, sans-serif; }"
row+1                "table
{ border-collapse: collapse; }"
row+1                "th,
td { padding-left: 5px; padding-right: 5px; }"
row+1        "</style>"
row+1 "</head>"
row+1 "<body>"
;table & header
row+1 "<table border='1'>"
row+1 "<tr>"
row+1        "<th>&nbsp;</th>"
row+1
        "<th>Orderable</th>"
row+1
        "<th>Order
Time</th>"
row+1        "<th>Order
Status</th>"
row+1
        "<th>Catalog
Type</th>"
row+1         "<th
colspan='4'>Overview</th>"
row+1
        "<th>Actions</th>"
row+1
        "<th>Details</th>"
row+1
        "<th>Pathways</th>"
row+1        "<th>Result
Actions</th>"
row+1
        "<th>Tasks</th>"
row+1        "<th>order_id</th>"
row+1 "</tr>"
DETAIL
i+=1
row+1 "<tr>"
row+1        call
print(td(CNVTSTRING(i)))
row+1         call
print(td(oc.description))
row+1        call
print(td(order_dt_tm))
row+1        call
print(td(order_status))
row+1         call
print(td(catalog_type))
row+1        call
print(td(call_oda_order(o.order_id, "Order Info (generic view)",
"Generic")))
row+1        call
print(td(call_oda_order(o.order_id, "Order Info (laboratory view)",
"Lab")))
row+1        call
print(td(call_oda_order(o.order_id, "Order Info (pharmacy view)",
"Pharm")))
row+1        call
print(td(call_oda_order(o.order_id, "Order Info (radiology view)",
"Rad")))
row+1        call
print(td(call_oda_order(o.order_id, "Order Actions",
"Actions")))
row+1        call
print(td(call_oda_order(o.order_id, "Order Details",
"Details")))
row+1        call
print(td(call_oda_order(o.order_id, "Order Pathways",
"Pathways")))
row+1        call
print(td(call_oda_order(o.order_id, "Order Result Actions",
"Result Actions")))
row+1        call
print(td(call_oda_order(o.order_id, "Order Tasks",
"Tasks")))
row+1        call
print(td(CNVTSTRING(o.order_id)))
row+1 "</tr>"
FOOT REPORT
row+1 "</table>"
row+1 "</body>"
row+1
"</html>"
