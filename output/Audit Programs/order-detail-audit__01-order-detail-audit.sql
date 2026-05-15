/*
 * Source page  : Order Detail Audit
 * Source file  : output/order-detail-audit.md
 * Anchor       : (top of page)
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 2579
 *
 * Context (preceding paragraph):
 *   Exported: 12/14/25
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

/******************************************************************************
 REPORT NAME:
        Order Detail Audit
 PROGRAM:                1fed_rpt_order_detail_audit.prg
 DEV
PROGRAM:        dev_rpt_order_detail_audit.prg
 DEVELOPER:        David Alt
(david.a.alt2.mil@health.mil)
 PUBLISHED:        05/01/2023
 LOGICAL
PATH:        cust_script:
 NODE:                        <default>
 PURPOSE/DESCRIPTION:
         Audits around the order
catalog and order configuration.
 TARGET AUDIENCE:
          Users involved in order
catalog maintenance
          Facility-level
informaticists
MOD        DATE                DEVELOPER        COMMENT
---        --/--/--        ---------        ----------------------------
000        04/25/23        David
Alt        Initial draft out for
validation
001        04/27/23        David
Alt        Added "Tasks" and
"Order Tasks" reports
002        05/01/23        David
Alt        Added activity subtype
prompt for Enterprise reports
003 05/02/23        David
Alt        Fixed bugs related to
viewable/hidden
004        07/11/23        David
Alt        Added Order->Order Info
(radiology view)
Added Order->RX Dispense History
005        08/21/23        David
Alt        Added Orderable->Usage
(by agency)
006        09/21/23        David
Alt        Added "All
facilities" label to virtual views
007        10/06/23        David
Alt        Added bill_item_id to
Enterprise->Catalog/Modified/New
Added bill_item_id to Orderable->Configuration
008        10/24/23        David
Alt        Fixed bug in
Orderable->Events
009 02/06/24        David
Alt        Fixed inner join in order
lookup preventing orders from appearing
010        10/27/23        David
Alt        Added
Orderable->Scheduling Locations
011        10/31/23        David
Alt        Reordered where clauses in
usage reports to better hit index xie17orders
012        02/20/24        David
Alt        Renamed Usage * --> Usage
(overall) * to stop wildcard interference (enterprise, facility)
Added Enterprise->Usage (by facility) *
013        04/26/24        David
Alt        Added Order->Order Result
Actions
014 05/14/24        David
Alt        Fixed FIN discrepancies from
encntr vs originating_encntr
015        05/15/24        David
Alt        Converted dt_tm to local
dt_tm
016        06/24/24        David
Alt        Added Order->Order
Pathways
017        07/29/24        David
Alt        Updated Order->Order Info
(laboratory View) fields to reduce dependency on clinical event table,
added some new columns related to container/order status
018        08/16/24        David
Alt        New logic for all usage
reports:
- excluded test patients
- excluded auto-generated orders
- better join to base location on originating encounters
Updated Order->Order Detail to include order action associations
019        11/05/24        David
Alt        Added
Orderable->Configuration (cosignature)
020        11/26/24        David
Alt        Added
Orderable->Reference Text
021        03/24/25        David
Alt        Added Orderable->Pathways
and Plans (rough draft, unvalidated)
022        03/25/25        David
Alt        Added Orderable->HCPCS
(pharmacy view)
Added Orderable->Configuration (bill codes)
Added Orderable->Configuration (charge processing)
Added Orderable->Configuration (price schedules)
023        03/31/25        David
Alt        Added Order->Order
Diagnoses
Updated Orderable->Scheduling Locations (add agency/facility)
Enhanced security
024        05/07/25        David
Alt        Added Orderable->Order
Entry Fields
Added Order->Order Notifications
025        06/17/25        David
Alt        Added Facility->Usage (by
provider)
026        07/08/25        David
Alt        Added od.oe_field_id to
Order->Order Details
027        07/14/25        David
Alt        Updated Order->RX
Dispense History (new fields)
---- unpublished ----
028        07/22/25        David
Alt        Added Order->Order
Compliance Details
Removed unnecessary active_ind filters in Order reports
029        08/14/25        David
Alt        Added action_sequence to
Order->RX Dispense History
030        09/18/25        David
Alt        Renamed order_signed_by
--> order_provider
031        11/17/25        David
Alt        Added Order->Order
Comments
032        12/15/25        David
Alt        Added
Orderable->Scheduling Flex Strings
Added Orderable->Scheduling Order Roles
Added Orderable->Scheduling Appointment Types
Modded Orderable->Scheduling Locations to include order roles
 TODO / CONSIDER:
 Orderable->Configuration: add counts of scheduling location (and to
catalog outputs?)
 Order->Order Pathways: needs fields reviewed for completeness;
validation
 Order->Container Events: track what happens to a lab specimen after
it's ordered
 Order->Med Admin Events
 Add template_order_flag and
template_order_field
 Prompt: add catalog type filter to orderable search
******************************************************************************/
drop program
dev_rpt_order_detail_audit go
create
program dev_rpt_order_detail_audit
prompt
"Output to File/Printer/MINE" = "MINE" ;* Enter or select the printer or
file name to send this report to.
, "Scope" = ""
, "Order Start *" = "CURDATE"
, "Order End *" = "CURDATE"
, "Catalog Type" =
VALUE(0.0)
, "Activity Type" =
VALUE(0.0)
, "Sub Type" = VALUE(0.0)
;<<hidden>>"Instructions" = ""
, "" = ""
, "" = ""
, "" = ""
, "" = ""
;<<hidden>>"Agency" = "ALL"
, "Facility" = 0
;<<hidden>>"Search (use * for wildcard)" =
""
, "Orderable" = 0
, "Order ID" = 0
;<<hidden>>"Order Info" = ""
with OUTDEV,
scope, start_date, end_date, cat_type, act_type, sub_type,
rpt_enterprise, rpt_facility, rpt_orderable, rpt_order, facility,
orderable, order_lookup
/**************************************************************
; Global
Declarations
**************************************************************/
declare
cat_var = C2 with protect ;operator variable for Catalog Type prompt
declare
act_var = C2 with protect ;operator variable for Activity Type prompt
declare
sub_var = C2 with protect ;operator variable for Activity Subtype prompt
declare
access_allowed_ind = i2 with protect
/**************************************************************
; Prompt
Magic - accounting for "Any (*)" options
**************************************************************/
;CAT_VAR -
Catalog Type prompt inflection
IF(substring(1,1,reflect(parameter(5,0)))
= "L") ;multiple selection
 SET cat_var = "IN"
ELSEIF(parameter(5,1)=
0.0) ;"Any" selected (must define as 0.0 in prompt)
 SET cat_var = ">="
ELSE ;single
value selected
 SET cat_var = "="
ENDIF
;ACT_VAR -
Activity Type prompt inflection
IF(substring(1,1,reflect(parameter(6,0)))
= "L") ;multiple selection
 SET act_var = "IN"
ELSEIF(parameter(6,1)=
0.0) ;"Any" selected (must define as 0.0 in prompt)
 SET act_var = ">="
ELSE ;single
value selected
 SET act_var = "="
ENDIF
;SUB_VAR -
Activity Subtype prompt inflection
IF(substring(1,1,reflect(parameter(7,0)))
= "L") ;multiple selection
 SET sub_var = "IN"
ELSEIF(parameter(7,1)=
0.0) ;"Any" selected (must define as 0.0 in prompt)
 SET sub_var = ">="
ELSE ;single
value selected
 SET sub_var = "="
ENDIF
/**************************************************************
; Record
Structures
**************************************************************/
/**************************************************************
; Subroutines
**************************************************************/
; Removes all
line feeds/carriage returns/tabs from a string
subroutine
(replace_CRLF(input = vc) = vc)
declare output = vc with protect, noconstant("")
declare CRLF = vc with protect, constant(concat(char(13), char(10)))
declare CR = vc with protect, constant(char(13)) ;carriage return
declare LF = vc with protect, constant(char(10)) ;line feed
declare HT = vc with protect, constant(char(9)) ;horizontal tab
declare REPLACEMENT = vc with constant(" ")
; remove carriage return+line feed at the beginning and end of the
string
set output = trim(input, 3) ; option 3 -> Trim leading and trailing
spaces
; replace carriage return+line feed inside string
set output = replace(output, CRLF, REPLACEMENT)
set output = replace(output, CR, REPLACEMENT)
set output = replace(output, LF, REPLACEMENT)
set output = replace(output, HT, REPLACEMENT)
return (output)
end
; Check if
order comes from excluded locations
subroutine
(get_access_allowed(input = f8) = i2)
<SENSITIVE/removed>
RETURN (output)
end
;get_encntr_access_allowed
/**************************************************************
; Main
**************************************************************/
IF($scope =
"Order")
SET access_allowed_ind = get_access_allowed($order_lookup)
ENDIF
/**************************************************************
; Output
**************************************************************/
SELECT
;PROMPT
CHECKS
IF($scope =
"Facility" AND $facility = 0) error = "You must select at least
one facility."
ELSEIF($scope
= "Orderable" AND $orderable = 0) error = "You must select at
least one orderable."
ELSEIF($scope
= "Order" AND $order_lookup = 0) error = "You must enter an
order_id."
ELSEIF($scope
= "Order" AND access_allowed_ind = 0) error = "Access to this
encounter is restricted."
;add a check
if one of the categories is unselected
;Add
#facilities virtual-viewed? By agency?
ELSEIF($scope
= "Enterprise" AND $rpt_enterprise = "Catalog")
orderable = oc.description
,catalog_type = UAR_GET_CODE_DISPLAY(oc.catalog_type_cd)
,activity_type = UAR_GET_CODE_DISPLAY(oc.activity_type_cd)
,subtype = UAR_GET_CODE_DISPLAY(oc.activity_subtype_cd)
,clinical_category = UAR_GET_CODE_DISPLAY(oc.dcp_clin_cat_cd)
,oc.primary_mnemonic
,oefmt.oe_format_name
,oc.auto_cancel_ind
,oc.print_req_ind
,oc.catalog_cd
,oc.oe_format_id
,bi.bill_item_id
,last_updated = oc.updt_dt_tm "MM/DD/YYYY;;d"
FROM ORDER_CATALOG oc
,(LEFT JOIN BILL_ITEM bi ON oc.catalog_cd = bi.ext_parent_reference_id
AND bi.ext_parent_contributor_cd = 3443 ;order catalog
AND bi.active_ind = 1
AND bi.end_effective_dt_tm > SYSDATE)
,ORDER_ENTRY_FORMAT oefmt
PLAN oc WHERE oc.active_ind = 1
AND OPERATOR(oc.catalog_type_cd, cat_var, $cat_type)
AND OPERATOR(oc.activity_type_cd, act_var, $act_type)
AND OPERATOR(oc.activity_subtype_cd, sub_var, $sub_type)
JOIN oefmt WHERE oc.oe_format_id = oefmt.oe_format_id
AND oefmt.action_type_cd = 2534 ;order
JOIN bi
ORDER BY catalog_type, orderable
ELSEIF($scope
= "Enterprise" AND $rpt_enterprise = "Hidden")
orderable = oc.description
,catalog_type = UAR_GET_CODE_DISPLAY(oc.catalog_type_cd)
,activity_type = UAR_GET_CODE_DISPLAY(oc.activity_type_cd)
,subtype = UAR_GET_CODE_DISPLAY(oc.activity_subtype_cd)
,clinical_category = UAR_GET_CODE_DISPLAY(oc.dcp_clin_cat_cd)
,oc.catalog_cd
FROM ORDER_CATALOG oc
PLAN oc WHERE oc.active_ind = 1
AND OPERATOR(oc.catalog_type_cd, cat_var, $cat_type)
AND OPERATOR(oc.activity_type_cd, act_var, $act_type)
AND OPERATOR(oc.activity_subtype_cd, sub_var, $sub_type)
AND NOT EXISTS(
SELECT 1
FROM ORDER_CATALOG_SYNONYM ocs
,OCS_FACILITY_R ofr
WHERE oc.catalog_cd = ocs.catalog_cd
AND ocs.active_ind = 1
AND ocs.synonym_id = ofr.synonym_id)
ORDER BY catalog_type, orderable
ELSEIF($scope
= "Enterprise" AND $rpt_enterprise = "Modified *")
orderable = oc.description
,catalog_type = UAR_GET_CODE_DISPLAY(oc.catalog_type_cd)
,oc.catalog_cd
,bi.bill_item_id
,modified_on = oc.updt_dt_tm "MM/DD/YYYY HH:MM;;q"
,modified_by =
IF(p.person_id > 0 AND p.position_cd > 0)
BUILD(p.name_full_formatted, " (",
UAR_GET_CODE_DISPLAY(p.position_cd), ")")
ELSEIF(p.person_id > 0 AND p.position_cd = 0) p.name_full_formatted
ELSE ""
ENDIF
,p.email
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date)
"MM/DD/YYYY;;d"
FROM ORDER_CATALOG oc
,(LEFT JOIN BILL_ITEM bi ON oc.catalog_cd = bi.ext_parent_reference_id
AND bi.ext_parent_contributor_cd = 3443 ;order catalog
AND bi.active_ind = 1
AND bi.end_effective_dt_tm >
SYSDATE)
,PRSNL p
,CODE_VALUE cv
PLAN oc WHERE oc.active_ind = 1
AND OPERATOR(oc.catalog_type_cd, cat_var, $cat_type)
AND OPERATOR(oc.activity_type_cd, act_var, $act_type)
AND OPERATOR(oc.activity_subtype_cd, sub_var, $sub_type)
AND oc.updt_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
JOIN p WHERE oc.updt_id = p.person_id
JOIN cv WHERE oc.catalog_cd = cv.code_value
AND oc.updt_dt_tm > cv.begin_effective_dt_tm + 1 ;modified more than
1 day after creation
AND cv.active_ind = 1
JOIN bi
ORDER BY catalog_type, orderable
ELSEIF($scope
= "Enterprise" AND $rpt_enterprise = "New *")
orderable = oc.description
,catalog_type = UAR_GET_CODE_DISPLAY(oc.catalog_type_cd)
,oc.catalog_cd
,bi.bill_item_id
,created_on = cv.begin_effective_dt_tm "MM/DD/YYYY HH:MM;;q"
,created_by =
IF(p.person_id > 0 AND p.position_cd > 0)
BUILD(p.name_full_formatted, " (",
UAR_GET_CODE_DISPLAY(p.position_cd), ")")
ELSEIF(p.person_id > 0 AND p.position_cd = 0) p.name_full_formatted
ELSE ""
ENDIF
,p.email
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date)
"MM/DD/YYYY;;d"
FROM CODE_VALUE cv
,ORDER_CATALOG oc
,(LEFT JOIN BILL_ITEM bi ON oc.catalog_cd = bi.ext_parent_reference_id
AND bi.ext_parent_contributor_cd = 3443 ;order catalog
AND bi.active_ind = 1
AND bi.end_effective_dt_tm >
SYSDATE)
,PRSNL p
PLAN cv WHERE cv.code_set = 200
AND cv.begin_effective_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND cv.active_ind = 1
JOIN oc WHERE cv.code_value = oc.catalog_cd
AND OPERATOR(oc.catalog_type_cd, cat_var, $cat_type)
AND OPERATOR(oc.activity_type_cd, act_var, $act_type)
AND OPERATOR(oc.activity_subtype_cd, sub_var, $sub_type)
AND oc.active_ind = 1
JOIN p WHERE cv.updt_id = p.person_id
JOIN bi
ORDER BY catalog_type, orderable
ELSEIF($scope
= "Enterprise" AND $rpt_enterprise = "Tasks")
;        catalog_type
= UAR_GET_CODE_DISPLAY(oc.catalog_type_cd)
;        ,nbr_orderables
= COUNT(DISTINCT oc.catalog_cd)
;        ,nbr_tasks
= COUNT(DISTINCT ot.reference_task_id)
orderable = oc.description
,catalog_type = UAR_GET_CODE_DISPLAY(oc.catalog_type_cd)
,activity_type = UAR_GET_CODE_DISPLAY(oc.activity_type_cd)
,otx.primary_task_ind
,ot.task_description
,activity = UAR_GET_CODE_DISPLAY(ot.task_activity_cd)
,type = UAR_GET_CODE_DISPLAY(ot.task_type_cd)
,event = UAR_GET_CODE_DISPLAY(ot.event_cd)
,ot.chart_not_cmplt_ind
,ot.ignore_req_ind
,ot.quick_chart_ind
,ot.quick_chart_done_ind
,ot.quick_chart_notdone_ind
,ot.capture_bill_info_ind
,ot.grace_period_mins
,ot.retain_time
,ot.retain_units
,ot.reschedule_time
,ot.overdue_min
,ot.overdue_units ;0 N/A, 1 min, 2 hour ?
,ot.allpositionchart_ind
,order_task_type = EVALUATE(otx.order_task_type_flag,
0, "None",
1, "PROFILE_TASK_R",
2, "DISCRETE_TASK_R",
"Unknown Value")
,oc.catalog_cd
,ot.reference_task_id
FROM ORDER_CATALOG oc
,ORDER_TASK_XREF otx
,ORDER_TASK ot
PLAN oc WHERE oc.active_ind = 1
AND OPERATOR(oc.catalog_type_cd, cat_var, $cat_type)
AND OPERATOR(oc.activity_type_cd, act_var, $act_type)
AND OPERATOR(oc.activity_subtype_cd, sub_var,
$sub_type)
JOIN otx WHERE oc.catalog_cd = otx.catalog_cd
JOIN ot WHERE otx.reference_task_id = ot.reference_task_id
ORDER BY catalog_type, orderable, otx.primary_task_ind DESC,
ot.task_description
;PERFORMANCE
IS TERRIBLE
ELSEIF($scope
= "Enterprise" AND $rpt_enterprise = "Usage (overall) *")
ag.agency
,catalog_type = UAR_GET_CODE_DISPLAY(oc.catalog_type_cd)
,orderable = oc.description
,nbr_orders = COUNT(DISTINCT o.order_id)
,nbr_patients = COUNT(DISTINCT o.person_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date)
"MM/DD/YYYY;;d"
FROM ORDERS o
,ORDER_CATALOG oc
,ENCOUNTER e
,(LEFT JOIN CUST_LOC_AGENCY_RELTN ag ON ag.location_cd =
e.loc_facility_cd)
PLAN o WHERE 1=1
AND NOT EXISTS(        SELECT 1
FROM PERSON_INFO pi
WHERE pi.person_id = o.person_id
AND pi.info_sub_type_cd = 2678703703 ;Test Patient Identifier
AND pi.value_cd != 2678703509 ;"Not a Test Patient"
)
AND o.orig_order_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND o.order_status_cd IN (2543, 2546, 2550) ;completed, future, ordered
AND OPERATOR(o.catalog_type_cd, cat_var, $cat_type)
AND OPERATOR(o.activity_type_cd, act_var, $act_type)
AND o.template_order_flag IN (0,1,5,7) ;ignore auto-generated orders
AND o.active_ind = 1
JOIN oc WHERE o.catalog_cd = oc.catalog_cd
AND OPERATOR(oc.activity_subtype_cd, sub_var, $sub_type)
JOIN e WHERE 1=1
AND ((e.encntr_id = o.originating_encntr_id AND o.originating_encntr_id
!= 0)
OR (e.encntr_id = o.encntr_id AND o.originating_encntr_id = 0))
AND e.active_ind = 1
JOIN ag
GROUP BY ag.agency, oc.catalog_type_cd, oc.description
ORDER BY ag.agency, catalog_type, orderable
;PERFORMANCE
IS TERRIBLE
ELSEIF($scope
= "Enterprise" AND $rpt_enterprise = "Usage (by facility)
*")
ag.agency
,facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,catalog_type = UAR_GET_CODE_DISPLAY(oc.catalog_type_cd)
,orderable = oc.description
,nbr_orders = COUNT(DISTINCT o.order_id)
,nbr_patients = COUNT(DISTINCT o.person_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date)
"MM/DD/YYYY;;d"
FROM ORDERS o
,ORDER_CATALOG oc
,ENCOUNTER e
,(LEFT JOIN CUST_LOC_AGENCY_RELTN ag ON ag.location_cd =
e.loc_facility_cd)
PLAN o WHERE 1=1
AND NOT EXISTS(        SELECT 1
FROM PERSON_INFO pi
WHERE pi.person_id = o.person_id
AND pi.info_sub_type_cd = 2678703703 ;Test Patient Identifier
AND pi.value_cd != 2678703509 ;"Not a Test Patient"
)
AND o.orig_order_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND o.order_status_cd IN (2543, 2546, 2550) ;completed, future, ordered
AND OPERATOR(o.catalog_type_cd, cat_var, $cat_type)
AND OPERATOR(o.activity_type_cd, act_var, $act_type)
AND o.template_order_flag IN (0,1,5,7) ;ignore auto-generated orders
AND o.active_ind = 1
JOIN oc WHERE o.catalog_cd = oc.catalog_cd
AND OPERATOR(oc.activity_subtype_cd, sub_var, $sub_type)
JOIN e WHERE 1=1
AND ((e.encntr_id = o.originating_encntr_id AND o.originating_encntr_id
!= 0)
OR (e.encntr_id = o.encntr_id AND o.originating_encntr_id = 0))
AND e.active_ind = 1
JOIN ag
GROUP BY ag.agency, e.loc_facility_cd, oc.catalog_type_cd,
oc.description
ORDER BY ag.agency, facility, catalog_type,
orderable
;PERFORMANCE
IS TERRIBLE
ELSEIF($scope
= "Enterprise" AND $rpt_enterprise = "Unused *")
orderable = oc.description
,catalog_type = UAR_GET_CODE_DISPLAY(oc.catalog_type_cd)
,oc.catalog_cd
FROM ORDER_CATALOG oc
PLAN oc WHERE oc.active_ind = 1
AND OPERATOR(oc.catalog_type_cd, cat_var, $cat_type)
AND OPERATOR(oc.activity_type_cd, act_var, $act_type)
AND OPERATOR(oc.activity_subtype_cd, sub_var, $sub_type)
AND NOT EXISTS(
SELECT 1
FROM ORDERS o
WHERE oc.catalog_cd = o.catalog_cd
AND o.orig_order_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date))
ORDER BY catalog_type, orderable
ELSEIF($scope
= "Facility" AND $rpt_facility = "Viewable")
facility =
IF(ofr.facility_cd = 0) "All facilities"
ELSE UAR_GET_CODE_DISPLAY(ofr.facility_cd)
ENDIF
,orderable = oc.description
,ocs.mnemonic
,mnemonic_type = UAR_GET_CODE_DISPLAY(ocs.mnemonic_type_cd)
,catalog_type = UAR_GET_CODE_DISPLAY(ocs.catalog_type_cd)
,activity_type = UAR_GET_CODE_DISPLAY(ocs.activity_type_cd)
,activity_subtype = UAR_GET_CODE_DISPLAY(ocs.activity_subtype_cd)
,clinical_category = UAR_GET_CODE_DISPLAY(ocs.dcp_clin_cat_cd)
,orderable_type_flag =
IF(ocs.orderable_type_flag = 0) "Standard"
ELSEIF(ocs.orderable_type_flag = 1) "Standard"
ELSEIF(ocs.orderable_type_flag = 2) "Order Set/Care Set"
ELSEIF(ocs.orderable_type_flag = 3) "Care Plan"
ELSEIF(ocs.orderable_type_flag = 4) "AP Special"
ELSEIF(ocs.orderable_type_flag = 5) "Department Only"
ELSEIF(ocs.orderable_type_flag = 6) "Care Set - Order Set"
ELSEIF(ocs.orderable_type_flag = 7) "Home Health Problem"
ELSEIF(ocs.orderable_type_flag = 8) "Multi-Ingredient"
ELSEIF(ocs.orderable_type_flag = 9) "Interval Test"
ELSEIF(ocs.orderable_type_flag = 10) "Freetext"
ELSEIF(ocs.orderable_type_flag = 11) "TPN"
ELSEIF(ocs.orderable_type_flag = 12) "Attachment"
ELSEIF(ocs.orderable_type_flag = 13) "Compound"
ELSEIF(ocs.orderable_type_flag = 14) "Complex IV"
ENDIF
,hide_flag = IF(ocs.hide_flag = 0) "show synonym" ELSE
"hide synonym" ENDIF
,oefmt.oe_format_name
,oc.auto_cancel_ind
,oc.print_req_ind
,oc.catalog_cd
,oc.oe_format_id
,last_updated = oc.updt_dt_tm "MM/DD/YYYY;;d"
FROM OCS_FACILITY_R ofr
,ORDER_CATALOG_SYNONYM ocs
,ORDER_CATALOG oc
,ORDER_ENTRY_FORMAT oefmt
PLAN ofr WHERE ofr.facility_cd = $facility OR ofr.facility_cd = 0
JOIN ocs WHERE ofr.synonym_id = ocs.synonym_id
AND OPERATOR(ocs.catalog_type_cd, cat_var, $cat_type)
AND OPERATOR(ocs.activity_type_cd, act_var, $act_type)
AND OPERATOR(ocs.activity_subtype_cd, sub_var,
$sub_type)
AND ocs.active_ind = 1
JOIN oc WHERE ocs.catalog_cd = oc.catalog_cd
AND oc.active_ind = 1
JOIN oefmt WHERE oc.oe_format_id = oefmt.oe_format_id
AND oefmt.action_type_cd = 2534 ;order
ORDER BY facility, catalog_type, activity_type, activity_subtype,
orderable, mnemonic_type, ocs.mnemonic
ELSEIF($scope
= "Facility" AND $rpt_facility = "Hidden")
DISTINCT
orderable = oc.description
,catalog_type = UAR_GET_CODE_DISPLAY(oc.catalog_type_cd)
,activity_type = UAR_GET_CODE_DISPLAY(oc.activity_type_cd)
,subtype = UAR_GET_CODE_DISPLAY(oc.activity_subtype_cd)
,clinical_category = UAR_GET_CODE_DISPLAY(oc.dcp_clin_cat_cd)
,oc.primary_mnemonic
,oefmt.oe_format_name
,oc.auto_cancel_ind
,oc.print_req_ind
,oc.catalog_cd
,oc.oe_format_id
,last_updated = oc.updt_dt_tm
"MM/DD/YYYY;;d"
FROM ORDER_CATALOG_SYNONYM ocs
,OCS_FACILITY_R ofr
,ORDER_CATALOG oc
,ORDER_ENTRY_FORMAT oefmt
PLAN ocs WHERE ocs.mnemonic_type_cd = 2583 ;primary
AND OPERATOR(ocs.catalog_type_cd, cat_var, $cat_type)
AND OPERATOR(ocs.activity_type_cd, act_var, $act_type)
AND OPERATOR(ocs.activity_subtype_cd, sub_var,
$sub_type)
AND ocs.active_ind = 1
JOIN ofr WHERE ocs.synonym_id = ofr.synonym_id
AND ofr.facility_cd > 0
AND ofr.facility_cd != $facility
JOIN oc WHERE ocs.catalog_cd = oc.catalog_cd
AND oc.active_ind = 1
JOIN oefmt WHERE oc.oe_format_id = oefmt.oe_format_id
AND oefmt.action_type_cd = 2534 ;order
ORDER BY catalog_type, orderable
;PERFORMANCE
POOR
ELSEIF($scope
= "Facility" AND $rpt_facility = "Usage (overall) *")
facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,catalog_type = UAR_GET_CODE_DISPLAY(o.catalog_type_cd)
,orderable = oc.description
,orders_completed = COUNT(DISTINCT o.order_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date)
"MM/DD/YYYY;;d"
FROM ORDERS o
,ENCOUNTER e
,ORDER_CATALOG oc
PLAN o WHERE 1=1
AND NOT EXISTS(        SELECT 1
FROM PERSON_INFO pi
WHERE pi.person_id = o.person_id
AND pi.info_sub_type_cd = 2678703703 ;Test Patient Identifier
AND pi.value_cd != 2678703509 ;"Not a Test Patient"
)
AND o.orig_order_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND o.order_status_cd = 2543 ;completed
AND OPERATOR(o.catalog_type_cd, cat_var, $cat_type)
AND OPERATOR(o.activity_type_cd, act_var, $act_type)
AND o.template_order_flag IN (0,1,5,7) ;ignore auto-generated orders
AND o.active_ind = 1
JOIN e WHERE 1=1
AND ((e.encntr_id = o.originating_encntr_id AND o.originating_encntr_id
!= 0)
OR (e.encntr_id = o.encntr_id AND o.originating_encntr_id = 0))
AND e.loc_facility_cd = $facility
AND e.active_ind = 1
JOIN oc WHERE o.catalog_cd = oc.catalog_cd AND oc.active_ind = 1
AND OPERATOR(oc.activity_subtype_cd, sub_var, $sub_type)
GROUP BY e.loc_facility_cd, o.catalog_type_cd, oc.description
ORDER BY facility, catalog_type, orderable
ELSEIF($scope
= "Facility" AND $rpt_facility = "Usage (by provider) *")
facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,order_provider = order_p.name_full_formatted
,orderable = oc.description
,orders_completed = COUNT(DISTINCT o.order_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date)
"MM/DD/YYYY;;d"
FROM ORDERS o
,ENCOUNTER e
,ORDER_CATALOG oc
,ORDER_ACTION oa
,PRSNL order_p
PLAN o WHERE 1=1
AND NOT EXISTS(        SELECT 1
FROM PERSON_INFO pi
WHERE pi.person_id = o.person_id
AND pi.info_sub_type_cd = 2678703703 ;Test Patient Identifier
AND pi.value_cd != 2678703509 ;"Not a Test Patient"
)
AND o.orig_order_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND o.order_status_cd = 2543 ;completed
AND OPERATOR(o.catalog_type_cd, cat_var, $cat_type)
AND OPERATOR(o.activity_type_cd, act_var, $act_type)
AND o.template_order_flag IN (0,1,5,7) ;ignore auto-generated orders
AND o.active_ind = 1
JOIN e WHERE 1=1
AND ((e.encntr_id = o.originating_encntr_id AND o.originating_encntr_id
!= 0)
OR (e.encntr_id = o.encntr_id AND o.originating_encntr_id = 0))
AND e.loc_facility_cd = $facility
AND e.active_ind = 1
JOIN oc WHERE o.catalog_cd = oc.catalog_cd AND oc.active_ind = 1
AND OPERATOR(oc.activity_subtype_cd, sub_var, $sub_type)
JOIN oa WHERE oa.order_id = o.order_id
AND oa.action_type_cd = 2534 ;ordered (initial action of placing an
order)
JOIN order_p WHERE order_p.person_id = oa.order_provider_id
GROUP BY e.loc_facility_cd, order_p.name_full_formatted, oc.description
ORDER BY facility, order_provider, orderable
ELSEIF($scope
= "Facility" AND $rpt_facility = "Usage (by nurse unit) *")
facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,building = UAR_GET_CODE_DISPLAY(e.loc_building_cd)
,nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
,catalog_type = UAR_GET_CODE_DISPLAY(o.catalog_type_cd)
,orderable = oc.description
,orders_completed = COUNT(DISTINCT o.order_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date)
"MM/DD/YYYY;;d"
FROM ORDERS o
,ENCOUNTER e
,ORDER_CATALOG oc
PLAN o WHERE 1=1
AND NOT EXISTS(        SELECT 1
FROM PERSON_INFO pi
WHERE pi.person_id = o.person_id
AND pi.info_sub_type_cd = 2678703703 ;Test Patient Identifier
AND pi.value_cd != 2678703509 ;"Not a Test Patient"
)
AND o.orig_order_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND o.order_status_cd = 2543 ;completed
AND OPERATOR(o.catalog_type_cd, cat_var, $cat_type)
AND OPERATOR(o.activity_type_cd, act_var,
$act_type)
AND o.active_ind = 1
JOIN e WHERE 1=1
AND ((e.encntr_id = o.originating_encntr_id AND o.originating_encntr_id
!= 0)
OR (e.encntr_id = o.encntr_id AND o.originating_encntr_id = 0))
AND e.loc_facility_cd = $facility
AND e.active_ind = 1
JOIN oc WHERE o.catalog_cd = oc.catalog_cd
AND oc.active_ind = 1
AND OPERATOR(oc.activity_subtype_cd, sub_var, $sub_type)
GROUP BY e.loc_facility_cd, e.loc_building_cd, e.loc_nurse_unit_cd,
o.catalog_type_cd, oc.description
ORDER BY facility, building, nurse_unit, catalog_type, orderable
ELSEIF($scope
= "Facility" AND $rpt_facility = "Unused *")
DISTINCT
facility = UAR_GET_CODE_DISPLAY(ofr.facility_cd)
,orderable = oc.description
,catalog_type = UAR_GET_CODE_DISPLAY(oc.catalog_type_cd)
,oc.catalog_cd
FROM OCS_FACILITY_R ofr
,ORDER_CATALOG_SYNONYM ocs
,ORDER_CATALOG oc
PLAN ofr WHERE ofr.facility_cd = $facility ;facility prompt
JOIN ocs WHERE ofr.synonym_id = ocs.synonym_id
AND OPERATOR(ocs.catalog_type_cd, cat_var, $cat_type) ;catalog type
prompt
AND OPERATOR(ocs.activity_type_cd, act_var, $act_type);activity type
prompt
AND OPERATOR(ocs.activity_subtype_cd, sub_var, $sub_type)
AND NOT EXISTS(
SELECT 1
FROM ORDERS o
,ENCOUNTER e
WHERE ocs.catalog_cd = o.catalog_cd
AND o.orig_order_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND ((e.encntr_id = o.originating_encntr_id AND o.originating_encntr_id
!= 0)
OR (e.encntr_id = o.encntr_id AND o.originating_encntr_id = 0))
AND e.loc_facility_cd = $facility ;facility prompt
)
AND ocs.active_ind = 1
JOIN oc WHERE ocs.catalog_cd = oc.catalog_cd
AND oc.active_ind = 1
ORDER BY facility, catalog_type, orderable
ELSEIF($scope
= "Orderable" AND $rpt_orderable = "Viewable")
DISTINCT
orderable = oc.description
,catalog_type = UAR_GET_CODE_DISPLAY(oc.catalog_type_cd)
,facility =
IF(ofr.facility_cd = 0) "All facilities"
ELSE UAR_GET_CODE_DISPLAY(ofr.facility_cd)
ENDIF
,facility_description = UAR_GET_CODE_DESCRIPTION(ofr.facility_cd)
,ag.agency
FROM ORDER_CATALOG oc
,ORDER_CATALOG_SYNONYM ocs
,OCS_FACILITY_R ofr
,(LEFT JOIN CUST_LOC_AGENCY_RELTN ag ON ofr.facility_cd =
ag.location_cd)
PLAN oc WHERE oc.catalog_cd = $orderable
JOIN ocs WHERE oc.catalog_cd = ocs.catalog_cd
AND ocs.active_ind = 1
JOIN ofr WHERE ocs.synonym_id = ofr.synonym_id
JOIN ag
ORDER BY orderable, facility
;Review this
for unnecessary fields and missing fields
ELSEIF($scope
= "Orderable" AND $rpt_orderable = "Configuration")
orderable = oc.description
,catalog_type = UAR_GET_CODE_DISPLAY(oc.catalog_type_cd)
,activity_type = UAR_GET_CODE_DISPLAY(oc.activity_type_cd)
,activity_subtype = UAR_GET_CODE_DISPLAY(oc.activity_subtype_cd)
,clinical_category = UAR_GET_CODE_DISPLAY(oc.dcp_clin_cat_cd)
,oc.primary_mnemonic
,oefmt.oe_format_name
,oc.auto_cancel_ind
,oc.print_req_ind
,oc.bill_only_ind
,oc.complete_upon_order_ind
,oc.schedule_ind
,oc.consent_form_ind
,comment_template_ind = oc.comment_template_flag
,stop_type = UAR_GET_CODE_DISPLAY(oc.stop_type_cd)
,continuing_order_method = EVALUATE(oc.cont_order_method_flag,
0, "Order",
1, "Task",
2, "Pharmacy",
"Unknown Value")
,modified_on = oc.updt_dt_tm "MM/DD/YYYY HH:MM;;q"
,modified_by =
IF(p.person_id > 0 AND p.position_cd > 0)
BUILD(p.name_full_formatted, " (",
UAR_GET_CODE_DISPLAY(p.position_cd), ")")
ELSEIF(p.person_id > 0 AND p.position_cd = 0) p.name_full_formatted
ELSE ""
ENDIF
,oc.cki
,oc.concept_cki
,oc.oe_format_id
,oc.catalog_cd
FROM ORDER_CATALOG oc
,ORDER_ENTRY_FORMAT oefmt
,PRSNL p
PLAN oc WHERE oc.catalog_cd = $orderable
AND oc.active_ind = 1
JOIN oefmt WHERE oc.oe_format_id = oefmt.oe_format_id
AND oefmt.action_type_cd = 2534
;order
JOIN p WHERE oc.updt_id = p.person_id
ORDER BY orderable
ELSEIF($scope
= "Orderable" AND $rpt_orderable = "Configuration
(cosignature)")
;ORDERABLE INFORMATION
orderable = oc.description
,catalog_type = UAR_GET_CODE_DISPLAY(oc.catalog_type_cd)
,activity_type = UAR_GET_CODE_DISPLAY(oc.activity_type_cd)
,oc.primary_mnemonic
;COSIGNATURE FLAGS
,place_order = oa_order.doctor_cosign_flag
,cancel = oa_cancel.doctor_cosign_flag
,cancel_discontinue = oa_cancel_dc.doctor_cosign_flag
,cancel_reorder = oa_cancel_ro.doctor_cosign_flag
,modify = oa_modify.doctor_cosign_flag
,renew = oa_renew.doctor_cosign_flag
,void = oa_void.doctor_cosign_flag
,last_updated = oc.updt_dt_tm
"@SHORTDATETIME"
,oc.catalog_cd
FROM
ORDER_CATALOG oc
,(LEFT JOIN ORDER_CATALOG_REVIEW oa_order ON oc.catalog_cd =
oa_order.catalog_cd
AND oa_order.action_type_cd = 2534)
,(LEFT JOIN ORDER_CATALOG_REVIEW oa_cancel ON oc.catalog_cd =
oa_cancel.catalog_cd
AND oa_cancel.action_type_cd = 2526)
,(LEFT JOIN ORDER_CATALOG_REVIEW oa_cancel_dc ON oc.catalog_cd =
oa_cancel_dc.catalog_cd
AND oa_cancel_dc.action_type_cd = 2527)
,(LEFT JOIN ORDER_CATALOG_REVIEW oa_cancel_ro ON oc.catalog_cd =
oa_cancel_ro.catalog_cd
AND oa_cancel_ro.action_type_cd = 674188)
,(LEFT JOIN ORDER_CATALOG_REVIEW oa_void ON oc.catalog_cd =
oa_void.catalog_cd
AND oa_void.action_type_cd = 2530)
,(LEFT JOIN ORDER_CATALOG_REVIEW oa_modify ON oc.catalog_cd =
oa_modify.catalog_cd
AND oa_modify.action_type_cd = 2533)
,(LEFT JOIN ORDER_CATALOG_REVIEW oa_renew ON oc.catalog_cd =
oa_renew.catalog_cd
AND oa_renew.action_type_cd =
2535)
PLAN oc WHERE oc.catalog_cd = $orderable
AND oc.active_ind = 1
JOIN oa_order
JOIN oa_cancel
JOIN oa_cancel_dc
JOIN oa_cancel_ro
JOIN oa_modify
JOIN oa_renew
JOIN oa_void
ORDER BY orderable
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
;        ,reprocessing
= "" ;haven't found this yet
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
ELSEIF($scope
= "Orderable" AND $rpt_orderable = "Events")
orderable = oc.description
,oc.catalog_cd
,task_assay = UAR_GET_CODE_DISPLAY(dta.task_assay_cd)
,dta.task_assay_cd
,event =
IF(cvr.event_cd > 0) UAR_GET_CODE_DISPLAY(cvr.event_cd)
ELSE UAR_GET_CODE_DISPLAY(dta.event_cd)
ENDIF
,event_cd =
IF(cvr.event_cd > 0) cvr.event_cd
ELSE dta.event_cd
ENDIF
FROM ORDER_CATALOG oc
,PROFILE_TASK_R ptr
,DISCRETE_TASK_ASSAY dta
,(LEFT JOIN CODE_VALUE_EVENT_R cvr ON dta.task_assay_cd =
cvr.parent_cd)
PLAN oc WHERE oc.catalog_cd = $orderable
JOIN ptr WHERE oc.catalog_cd = ptr.catalog_cd AND ptr.active_ind = 1
JOIN dta WHERE ptr.task_assay_cd = dta.task_assay_cd
JOIN cvr
ORDER BY orderable, event
ELSEIF($scope
= "Orderable" AND $rpt_orderable = "HCPCS (pharmacy view)")
orderable = oc.description
,bill_item_long = bi.ext_description
,bill_item_short = bi.ext_short_desc
,ocs.mnemonic
,hcpcs = mi.value
,pharmacy_type = UAR_GET_CODE_DISPLAY(mi.pharmacy_type_cd)
,schedule = UAR_GET_CODE_DISPLAY(bim.key1_id)
,code = bim.key6
,details = bim.key7
;IDENTIFIERS
,ocir.catalog_cd
,ocs.synonym_id
;        ,mdf.med_def_flex_id
;        ,mi.item_id
;        ,mi.med_product_id
;        ,mi.med_identifier_id
;        ,bi.bill_item_id
;        ,bim.bill_item_mod_id
FROM ORDER_CATALOG oc
,ORDER_CATALOG_SYNONYM ocs
,ORDER_CATALOG_ITEM_R ocir
,MED_IDENTIFIER mi
,MED_DEF_FLEX mdf
,BILL_ITEM bi
,BILL_ITEM_MODIFIER bim
PLAN oc WHERE oc.catalog_cd = $orderable
JOIN ocs WHERE ocs.catalog_cd = oc.catalog_cd
AND ocs.active_ind = 1
JOIN ocir WHERE ocir.synonym_id = ocs.synonym_id
JOIN mi WHERE mi.item_id = ocir.item_id
AND mi.med_identifier_type_cd = 615035 ;HCPCS
AND mi.active_ind = 1
JOIN mdf WHERE mdf.med_def_flex_id = mi.med_def_flex_id
AND mdf.active_ind = 1
JOIN bi WHERE bi.ext_parent_reference_id = mi.med_def_flex_id
AND bi.ext_parent_contributor_cd = 674241 ;Med Def Flex
AND bi.end_effective_dt_tm > SYSDATE
AND bi.active_ind = 1
JOIN bim WHERE bim.bill_item_id = bi.bill_item_id
AND bim.key1_id IN (SELECT code_value
FROM CODE_VALUE
WHERE code_set = 14002
AND cdf_meaning = "HCPCS"
AND active_ind = 1)
AND bim.end_effective_dt_tm > SYSDATE
AND bim.active_ind = 1
ORDER BY orderable,
CNVTUPPER(bi.ext_description),CNVTUPPER(ocs.mnemonic)
ELSEIF($scope
= "Orderable" AND $rpt_orderable = "Order Entry Fields")
orderable = oc.description
,action_type = UAR_GET_CODE_DISPLAY(oe_ff.action_type_cd)
,oe_ff.label_text
,accept_flag = EVALUATE(oe_ff.accept_flag,
0, "required",
1, "optional",
2, "no display",
3, "display only",
"unknown flag")
,oe_ff.default_value
,field_type = EVALUATE(oef.field_type_flag,
0, "alphanumeric",
1, "integer",
2, "decimal",
3, "date",
5, "date/time",
6, "code set",
7, "yes/no",
8, "provider",
9, "location",
10, "ICD",
11, "printer",
12, "list",
13, "user/personnel",
14, "accession",
15, "surgical duration",
"unknown flag")
,code_set = oef.codeset
,oef.event_cd
;        ,oe_ff.require_cosign_ind
;        ,oe_ff.require_review_ind
;        ,oe_ff.require_verify_ind
;identifiers
,oc.oe_format_id
,oe_ff.oe_field_id
,oef.oe_field_meaning_id
FROM ORDER_CATALOG oc
,OE_FORMAT_FIELDS oe_ff
,ORDER_ENTRY_FIELDS oef
PLAN oc WHERE oc.catalog_cd = $orderable
JOIN oe_ff WHERE oe_ff.oe_format_id = oc.oe_format_id
JOIN oef WHERE oef.oe_field_id = oe_ff.oe_field_id
ORDER BY orderable, action_type, oe_ff.group_seq, oe_ff.field_seq
;THIS IS A
ROUGH DRAFT AND HAS NOT BEEN VALIDATED - 3/24/25
; removed from prompt 7/8/25
; description: Order pathways and PowerPlans associated with the orderable
ELSEIF($scope
= "Orderable" AND $rpt_orderable = "Pathways and Plans")
DISTINCT
orderable = oc.description
,ocs.mnemonic
,mnemonic_type = UAR_GET_CODE_DISPLAY(ocs.mnemonic_type_cd)
,activity_type = BUILD(
UAR_GET_CODE_DISPLAY(ocs.activity_type_cd)
,"/"
,UAR_GET_CODE_DISPLAY(pcomp.dcp_clin_cat_cd)
)
,activity_subtype =
IF(ocs.activity_subtype_cd > 0 AND pcomp.dcp_clin_sub_cat_cd = 0)
UAR_GET_CODE_DISPLAY(ocs.activity_subtype_cd)
ELSEIF(ocs.activity_subtype_cd = 0 AND pcomp.dcp_clin_sub_cat_cd >
0)
UAR_GET_CODE_DISPLAY(pcomp.dcp_clin_sub_cat_cd)
ELSEIF(ocs.activity_subtype_cd > 0 AND pcomp.dcp_clin_sub_cat_cd
> 0)
BUILD(
UAR_GET_CODE_DISPLAY(ocs.activity_subtype_cd)
,"/"
,UAR_GET_CODE_DISPLAY(pcomp.dcp_clin_sub_cat_cd)
)
ELSE ""
ENDIF
,pathway = pc.description
,oc.catalog_cd
,ocs.synonym_id
,pc.pathway_catalog_id
; SOURCE PLAN (i.e. parent)
;,pathway_type = pc.type_mean
;,reltn_type = pcr.type_mean
; TARGET PLAN (i.e. subphase)
;,target_plan = tpc.description
;,target_catalog_id = tpc.pathway_catalog_id
;,target_type = tpc.type_mean
;,tpc.sub_phase_ind
FROM ORDER_CATALOG oc
,ORDER_CATALOG_SYNONYM ocs
,PATHWAY_COMP pcomp
,PATHWAY_CATALOG tpc ;target
,PW_CAT_RELTN pcr
,PATHWAY_CATALOG pc ;source
PLAN oc WHERE 1=1
AND oc.catalog_cd = $orderable ;ondansetron
JOIN ocs WHERE ocs.catalog_cd = oc.catalog_cd
;AND ocs.synonym_id = 2765650
;4 mg/5 mL
;AND ocs.mnemonic_type_cd = 2583 ;Primary
AND ocs.active_ind = 1 ;excludes orders that have been ZZ'd
JOIN pcomp WHERE pcomp.parent_entity_id = ocs.synonym_id
AND pcomp.parent_entity_name = "ORDER_CATALOG_SYNONYM"
AND pcomp.comp_type_cd = 10736 ;Order (linked to ORDER_CATALOG_SYNONYM)
AND pcomp.active_ind = 1
JOIN tpc WHERE tpc.pathway_catalog_id = pcomp.pathway_catalog_id
AND tpc.end_effective_dt_tm > SYSDATE
AND tpc.active_ind = 1
JOIN pcr WHERE pcr.pw_cat_t_id = tpc.pathway_catalog_id
JOIN pc WHERE pc.pathway_catalog_id = pcr.pw_cat_s_id
AND pc.type_mean NOT IN ("PHASE", "DOT") ;or IN
"CAREPLAN"
AND pc.pathway_type_cd = 681133 ;medical
AND pc.end_effective_dt_tm > sysdate
AND pc.active_ind = 1
ORDER BY CNVTUPPER(ocs.mnemonic), CNVTUPPER(pc.description)
ELSEIF($scope
= "Orderable" AND $rpt_orderable = "Reference Text")
orderable = oc.description
,oc.catalog_cd
,text_type = UAR_GET_CODE_DISPLAY(rt.text_type_cd)
,rt.ref_text_name
,reference_text = lbr.long_blob
;        ,rtv.beg_effective_dt_tm        ;relevant
if looking at inactive versions
;        ,rtv.end_effective_dt_tm        ;relevant
if looking at inactive versions
;        ,rtv.active_ind                                ;relevant
if looking at inactive versions
,rt.ref_text_variation_id
,rtv.ref_text_version_id
,rtv.long_blob_id
FROM ORDER_CATALOG oc
,REF_TEXT_VARIATION rt
,REF_TEXT_VERSION rtv
,LONG_BLOB_REFERENCE lbr
PLAN oc WHERE oc.catalog_cd = $orderable
JOIN rt WHERE rt.parent_entity_id = oc.catalog_cd
JOIN rtv WHERE rtv.ref_text_variation_id = rt.ref_text_variation_id
AND rtv.active_ind = 1 ;remove this to see all versions
JOIN lbr WHERE lbr.long_blob_id = rtv.long_blob_id
AND lbr.active_ind = 1
ORDER BY orderable, text_type, rt.ref_text_name,
rtv.beg_effective_dt_tm
ELSEIF($scope
= "Orderable" AND $rpt_orderable = "Scheduling Appointment
Types")
orderable = oc.description
,oc.catalog_cd
,appt_type = UAR_GET_CODE_DISPLAY(soa.appt_type_cd)
,order_required = UAR_GET_CODE_DISPLAY(soa.proc_spec_cd)
,notify_on_delete = UAR_GET_CODE_DISPLAY(soa.del_appt_cd)
,soa.appt_type_cd
FROM ORDER_CATALOG oc
,(LEFT JOIN SCH_ORDER_APPT soa ON soa.catalog_cd = oc.catalog_cd
AND soa.end_effective_dt_tm > SYSDATE
AND soa.version_dt_tm > SYSDATE
AND soa.active_ind = 1)
PLAN oc WHERE 1=1
AND oc.catalog_cd = 2907603
AND oc.active_ind = 1
JOIN soa
ORDER BY orderable, appt_type
ELSEIF($scope
= "Orderable" AND $rpt_orderable = "Scheduling Flex
Strings")
orderable = oc.description
,oc.catalog_cd
,oc.schedule_ind
,association_type = UAR_GET_CODE_DISPLAY(ssa.assoc_type_cd)
,flex_type = UAR_GET_CODE_DISPLAY(sfs.flex_type_cd)
,flex_string = sfs.mnemonic
,sfs.sch_flex_id
FROM ORDER_CATALOG oc
,(LEFT JOIN SCH_SIMPLE_ASSOC ssa ON ssa.parent_id = oc.catalog_cd
AND ssa.child_table = "SCH_FLEX_STRING"
AND ssa.end_effective_dt_tm > SYSDATE
AND ssa.version_dt_tm > SYSDATE
AND ssa.active_ind = 1)
,(LEFT JOIN SCH_FLEX_STRING sfs ON sfs.sch_flex_id = ssa.child_id
AND sfs.end_effective_dt_tm > SYSDATE
AND sfs.version_dt_tm > SYSDATE
AND sfs.active_ind = 1)
PLAN oc WHERE oc.catalog_cd = $orderable
JOIN ssa
JOIN sfs
ORDER BY orderable, association_type, flex_type, flex_string
ELSEIF($scope
= "Orderable" AND $rpt_orderable = "Scheduling Locations")
orderable = oc.description
,oc.catalog_cd
,ag.agency
,facility = UAR_GET_CODE_DISPLAY(b_f.parent_loc_cd)
,nurse_unit = UAR_GET_CODE_DISPLAY(sol.location_cd)
,nurse_unit_description = UAR_GET_CODE_DESCRIPTION(sol.location_cd)
,slr.mnemonic
,order_role = UAR_GET_CODE_DISPLAY(slr.sch_role_cd)
,slr.role_meaning
,role_type = UAR_GET_CODE_DISPLAY(slr.role_type_cd)
,algorithm = UAR_GET_CODE_DISPLAY(slr.algorithm_cd)
,sol.location_cd
,sor.list_role_id
FROM ORDER_CATALOG oc
,SCH_ORDER_LOC sol
,(LEFT JOIN LOCATION_GROUP u_b ON u_b.child_loc_cd = sol.location_cd
AND u_b.location_group_type_cd = 778 ;building
AND u_b.root_loc_cd = 0
AND u_b.end_effective_dt_tm > SYSDATE
AND u_b.active_ind = 1)
,(LEFT JOIN LOCATION_GROUP b_f ON b_f.child_loc_cd = u_b.parent_loc_cd
AND b_f.location_group_type_cd = 783 ;facility
AND b_f.root_loc_cd = 0
AND b_f.end_effective_dt_tm > SYSDATE
AND b_f.active_ind = 1)
,(LEFT JOIN CUST_LOC_AGENCY_RELTN ag ON ag.location_cd =
b_f.parent_loc_cd)
,(LEFT JOIN SCH_ORDER_ROLE sor ON sor.catalog_cd = sol.catalog_cd
AND sor.location_cd = sol.location_cd
AND sor.end_effective_dt_tm > SYSDATE
AND sor.version_dt_tm > SYSDATE
AND sor.active_ind = 1)
,(LEFT JOIN SCH_LIST_ROLE slr ON slr.list_role_id = sor.list_role_id
AND slr.end_effective_dt_tm > SYSDATE
AND slr.version_dt_tm > SYSDATE
AND slr.active_ind =
1)
PLAN oc WHERE oc.catalog_cd = $orderable
JOIN sol WHERE oc.catalog_cd = sol.catalog_cd
AND sol.end_effective_dt_tm > SYSDATE
AND sol.active_ind = 1
JOIN u_b
JOIN b_f
JOIN ag
JOIN sor
JOIN slr
ORDER BY orderable, ag.agency, facility, nurse_unit, slr.mnemonic
ELSEIF($scope
= "Orderable" AND $rpt_orderable = "Scheduling Order
Roles")
orderable = oc.description
,oc.catalog_cd
,location = UAR_GET_CODE_DISPLAY(sor.location_cd)
,slr.mnemonic
,order_role = UAR_GET_CODE_DISPLAY(slr.sch_role_cd)
,slr.role_meaning
,role_type = UAR_GET_CODE_DISPLAY(slr.role_type_cd)
,algorithm = UAR_GET_CODE_DISPLAY(slr.algorithm_cd)
,sor.list_role_id
FROM ORDER_CATALOG oc
,(LEFT JOIN SCH_ORDER_ROLE sor ON sor.catalog_cd = oc.catalog_cd
AND sor.end_effective_dt_tm > SYSDATE
AND sor.version_dt_tm > SYSDATE
AND sor.active_ind = 1)
,(LEFT JOIN SCH_LIST_ROLE slr ON slr.list_role_id = sor.list_role_id
AND slr.end_effective_dt_tm > SYSDATE
AND slr.version_dt_tm > SYSDATE
AND slr.active_ind = 1)
PLAN oc WHERE oc.catalog_cd = $orderable
JOIN sor
JOIN slr
ORDER BY location, slr.mnemonic
ELSEIF($scope
= "Orderable" AND $rpt_orderable = "Sentences")
DISTINCT
orderable = oc.description
,ocs.mnemonic
,mnemonic_type = UAR_GET_CODE_DISPLAY(ocs.mnemonic_type_cd)
,order_sentence = ocsr.order_sentence_disp_line
,ocsr.synonym_id
,ocsr.order_sentence_id
FROM ORDER_CATALOG_SYNONYM ocs
,ORDER_CATALOG oc
,ORD_CAT_SENT_R ocsr
;,ORDER_SENTENCE os
;,ORDER_SENTENCE_DETAIL osd
PLAN ocs WHERE ocs.catalog_cd = $orderable
AND ocs.active_ind = 1
JOIN oc WHERE ocs.catalog_cd = oc.catalog_cd
AND oc.active_ind = 1
JOIN ocsr WHERE ocs.synonym_id = ocsr.synonym_id
AND ocsr.active_ind = 1
;JOIN os WHERE ocsr.order_sentence_id = os.order_sentence_id
;JOIN osd WHERE os.order_sentence_id = osd.order_sentence_id
ORDER BY orderable, mnemonic_type, CNVTUPPER(ocs.mnemonic),
order_sentence
ELSEIF($scope
= "Orderable" AND $rpt_orderable = "Synonyms")
orderable = oc.description
,ocs.mnemonic
,mnemonic_type = UAR_GET_CODE_DISPLAY(ocs.mnemonic_type_cd)
,catalog_type = UAR_GET_CODE_DISPLAY(ocs.catalog_type_cd)
,activity_type = UAR_GET_CODE_DISPLAY(ocs.activity_type_cd)
,activity_subtype = UAR_GET_CODE_DISPLAY(ocs.activity_subtype_cd)
,clinical_category = UAR_GET_CODE_DISPLAY(ocs.dcp_clin_cat_cd)
,orderable_type_flag = EVALUATE(ocs.orderable_type_flag,
0, "Standard",
1, "Standard",
2, "Order Set/Care Set",
3, "Care Plan",
4, "AP Special",
5, "Department Only",
6, "Care Set - Order Set",
7, "Home Health Problem",
8, "Multi-Ingredient",
9, "Interval Test",
10, "Freetext",
11, "TPN",
12, "Attachment",
13, "Compound",
14, "Complex IV",
"Unknown Value")
,hide_flag = EVALUATE(ocs.hide_flag, 0, "Show Synonym",
"Hide Synonym")
;discrepancy/conflict in values between DM_FLAGS and field properties
for authorization_review!
,authorization_review_flag = EVALUATE(ocs.authorization_review_flag,
0, "None",
1, "Indicator Only (no status updates)",
2, "Indicator Only (with status updates)",
3, "Alert (no override required)",
4, "Alert (override required)",
5, "Prior Authorization Required",
"Unknown Value")
,ocs.concept_cki
,ocs.catalog_cd
,ocs.synonym_id
,last_updated = ocs.updt_dt_tm "MM/DD/YYYY;;d"
FROM ORDER_CATALOG_SYNONYM ocs
,ORDER_CATALOG oc
PLAN ocs WHERE ocs.catalog_cd = $orderable
AND ocs.active_ind = 1
JOIN oc WHERE ocs.catalog_cd = oc.catalog_cd
AND oc.active_ind = 1
ORDER BY orderable, mnemonic_type, CNVTUPPER(ocs.mnemonic)
ELSEIF($scope
= "Orderable" AND $rpt_orderable = "Tasks")
orderable = oc.description
,catalog_type = UAR_GET_CODE_DISPLAY(oc.catalog_type_cd)
,activity_type = UAR_GET_CODE_DISPLAY(oc.activity_type_cd)
,otx.primary_task_ind
,ot.task_description
,activity = UAR_GET_CODE_DISPLAY(ot.task_activity_cd)
,type = UAR_GET_CODE_DISPLAY(ot.task_type_cd)
,event = UAR_GET_CODE_DISPLAY(ot.event_cd)
,ot.chart_not_cmplt_ind
,ot.ignore_req_ind
,ot.quick_chart_ind
,ot.quick_chart_done_ind
,ot.quick_chart_notdone_ind
,ot.capture_bill_info_ind
,ot.grace_period_mins
,ot.retain_time
,ot.retain_units
,ot.reschedule_time
,ot.overdue_min
,ot.overdue_units ;0 N/A, 1 min, 2 hour ?
,ot.allpositionchart_ind
,order_task_type = EVALUATE(otx.order_task_type_flag,
0, "None",
1, "PROFILE_TASK_R",
2, "DISCRETE_TASK_R",
"Unknown Value")
,oc.catalog_cd
,ot.reference_task_id
FROM ORDER_CATALOG oc
,ORDER_TASK_XREF otx
,ORDER_TASK ot
PLAN oc WHERE oc.catalog_cd = $orderable
JOIN otx WHERE oc.catalog_cd = otx.catalog_cd
JOIN ot WHERE otx.reference_task_id = ot.reference_task_id
ORDER BY orderable, otx.primary_task_ind DESC, ot.task_description
ELSEIF($scope
= "Orderable" AND $rpt_orderable = "Usage (by agency) *")
ag.agency
,orderable = oc.description
,synonym = ocs.mnemonic
,synonym_type = UAR_GET_CODE_DISPLAY(ocs.mnemonic_type_cd)
,orders_completed = COUNT(DISTINCT o.order_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date)
"MM/DD/YYYY;;d"
FROM ORDERS o
,ORDER_CATALOG_SYNONYM ocs
,ORDER_CATALOG oc
,ENCOUNTER e
,(LEFT JOIN CUST_LOC_AGENCY_RELTN ag ON ag.location_cd =
e.loc_facility_cd)
PLAN o WHERE 1=1 ;index = xie100orders
AND NOT EXISTS(        SELECT 1
FROM PERSON_INFO pi
WHERE pi.person_id = o.person_id
AND pi.info_sub_type_cd = 2678703703 ;Test Patient Identifier
AND pi.value_cd != 2678703509 ;"Not a Test Patient"
)
AND o.orig_order_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND o.catalog_cd = $orderable
AND o.order_status_cd IN (2543, 2546, 2550) ;completed, future, ordered
AND o.active_ind = 1
JOIN ocs WHERE o.synonym_id = ocs.synonym_id
JOIN oc WHERE o.catalog_cd = oc.catalog_cd AND oc.active_ind = 1
JOIN e WHERE 1=1
AND ((e.encntr_id = o.originating_encntr_id AND o.originating_encntr_id
!= 0)
OR (e.encntr_id = o.encntr_id AND o.originating_encntr_id = 0))
AND e.active_ind = 1
JOIN ag
GROUP BY ag.agency, oc.description, ocs.mnemonic, ocs.mnemonic_type_cd
ORDER BY ag.agency, orderable, synonym
ELSEIF($scope
= "Orderable" AND $rpt_orderable = "Usage (by facility) *")
ag.agency
,facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,orderable = oc.description
,nbr_orders = COUNT(DISTINCT o.order_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date)
"MM/DD/YYYY;;d"
FROM ORDERS o
,ORDER_CATALOG oc
,ENCOUNTER e
,(LEFT JOIN CUST_LOC_AGENCY_RELTN ag ON ag.location_cd =
e.loc_facility_cd)
PLAN o WHERE 1=1 ;index = xie100orders
AND NOT EXISTS(        SELECT 1
FROM PERSON_INFO pi
WHERE pi.person_id = o.person_id
AND pi.info_sub_type_cd = 2678703703 ;Test Patient Identifier
AND pi.value_cd != 2678703509 ;"Not a Test Patient"
)
AND o.orig_order_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND o.catalog_cd = $orderable
AND o.order_status_cd IN (2543, 2546, 2550) ;completed, future, ordered
AND o.template_order_flag IN (0,1,5,7) ;ignore automatically generated
orders
AND o.active_ind = 1
JOIN oc WHERE o.catalog_cd = oc.catalog_cd
JOIN e WHERE 1=1
AND ((e.encntr_id = o.originating_encntr_id AND o.originating_encntr_id
!= 0)
OR (e.encntr_id = o.encntr_id AND o.originating_encntr_id = 0))
AND e.active_ind = 1
JOIN ag
GROUP BY ag.agency, e.loc_facility_cd, oc.description
ORDER BY ag.agency, facility, orderable
ELSEIF($scope
= "Order" AND $rpt_order = "Order Info (generic view)")
 o.order_id
 ,fin = fin.alias
 ,originating_fin = fin_orig.alias
 ; ORDER INFORMATION
 ,orderable = oc.description
 ,catalog_type =
UAR_GET_CODE_DISPLAY(oc.catalog_type_cd)
 ,activity_type =
UAR_GET_CODE_DISPLAY(oc.activity_type_cd)
 ,activity_subtype =
UAR_GET_CODE_DISPLAY(oc.activity_subtype_cd)
 ,clinical_category =
UAR_GET_CODE_DISPLAY(o.dcp_clin_cat_cd)
 ,primary_mnemonic = o.order_mnemonic
 ,o.ordered_as_mnemonic ;often contains
brand name
 ,o.clinical_display_line
 ,order_detail =
SUBSTRING(1,100,replace_CRLF(o.order_detail_display_line))
 ,order_status =
UAR_GET_CODE_DISPLAY(o.order_status_cd)
 ,dept_status =
UAR_GET_CODE_DISPLAY(o.dept_status_cd)
 ,order_entered_by =
CNVTUPPER(order_enter.name_full_formatted)
 ,order_provider =
CNVTUPPER(order_sign.name_full_formatted)
 ,stop_type =
UAR_GET_CODE_DISPLAY(o.stop_type_cd)
 ,discontinue_type =
UAR_GET_CODE_DISPLAY(o.discontinue_type_cd)
 ,last_comms_type =
UAR_GET_CODE_DISPLAY(o.latest_communication_type_cd)
 ,contrib_sys =
UAR_GET_CODE_DISPLAY(o.contributor_system_cd)
 ; TIMING
 ,order_dt_tm =
         DATETIMEZONEFORMAT(o.orig_order_dt_tm,
o.current_start_tz, "MM/DD/YYYY HH:MM;;q")
 ,current_start_dt_tm =
         DATETIMEZONEFORMAT(o.current_start_dt_tm,
o.current_start_tz, "MM/DD/YYYY HH:MM;;q")
 ,projected_stop_dt_tm =
         DATETIMEZONEFORMAT(o.projected_stop_dt_tm,
o.projected_stop_tz, "MM/DD/YYYY HH:MM;;q")
 ,discontinue_effective_dt_tm =
         DATETIMEZONEFORMAT(o.discontinue_effective_dt_tm,
o.discontinue_effective_tz, "MM/DD/YYYY HH:MM;;q")
 ,status_dt_tm =
DATETIMEZONEFORMAT(o.status_dt_tm, o.orig_order_tz, "MM/DD/YYYY
HH:MM;;q")
 ,order_tz =
DateTimeZoneByIndex(o.orig_order_tz)
 ; IDENTIFIERS
 ,o.cki
 ,oefmt.oe_format_name
 ,times_displayed_as =
DateTimeZoneByIndex(curtimezoneapp)
 FROM ORDERS o
 ,(LEFT JOIN ORDER_ACTION oa ON
o.order_id = oa.order_id        AND
oa.action_type_cd = 2534)
 ,(LEFT JOIN PRSNL order_enter ON
oa.action_personnel_id = order_enter.person_id)
 ,(LEFT JOIN PRSNL order_sign ON
oa.order_provider_id = order_sign.person_id)
 ,(LEFT JOIN ENCNTR_ALIAS fin ON
fin.encntr_id = o.encntr_id
         AND
fin.encntr_alias_type_cd = 1077
         AND fin.active_ind = 1
         AND
fin.end_effective_dt_tm > SYSDATE)
,(LEFT JOIN ENCNTR_ALIAS fin_orig ON fin_orig.encntr_id =
o.originating_encntr_id
AND fin_orig.encntr_alias_type_cd = 1077
AND fin_orig.active_ind = 1
AND fin_orig.end_effective_dt_tm > SYSDATE)
 ,ORDER_CATALOG oc
 ,ORDER_ENTRY_FORMAT oefmt
 PLAN o WHERE o.order_id = $order_lookup
 JOIN fin
 JOIN fin_orig
 JOIN oc WHERE o.catalog_cd = oc.catalog_cd
 JOIN oefmt WHERE o.oe_format_id =
oefmt.oe_format_id
AND oefmt.action_type_cd = 2534 ;order
 JOIN oa
 JOIN order_enter
 JOIN order_sign
ELSEIF($scope
= "Order" AND $rpt_order = "Order Info (laboratory view)")
 o.order_id
,orderable = oc.description
 ;RESULT INFO
 ,event = UAR_GET_CODE_DISPLAY(ce.event_cd)
 ,ce.result_val
 ,result_units =
UAR_GET_CODE_DISPLAY(ce.result_units_cd)
 ,result_flag =
UAR_GET_CODE_DISPLAY(ce.normalcy_cd)
 ,result_status =
UAR_GET_CODE_DISPLAY(ce.result_status_cd)
;ORDER INFO
 ,order_status =
UAR_GET_CODE_DISPLAY(o.order_status_cd)
 ,dept_status =
UAR_GET_CODE_DISPLAY(o.dept_status_cd)
 ,performing_device =
UAR_GET_CODE_DISPLAY(ce.resource_cd)
 ,performing_lab =
UAR_GET_CODE_DISPLAY(perf_resource.location_cd)
 ,performing_facility = perf_org.org_name
 ;COLLECTION/SPECIMEN
 ,accession_formatted =
UAR_FMT_ACCESSION(ca.accession, size(ca.accession, 1)) ;replaced CE version
 ,specimen_type =
UAR_GET_CODE_DISPLAY(c.specimen_type_cd) ;replaced CE-based field
 ,collect_method =
UAR_GET_CODE_DISPLAY(c.collection_method_cd) ;replaced CE-based field
 ,collect_priority =
UAR_GET_CODE_DESCRIPTION(spec.specimen_collect_priority_cd) ;DISPLAY is
abbreviated
 ,collection_status =
EVALUATE(ocr.collection_status_flag,
         0, "Pending",
         1,
"Collected",
         2, "On Hold",
         3,
"Recollect",
         4,
"Rescheduled",
         5, "Canceled",
         6, "Omitted",
         7, "Inactive",
         "<unmapped
value>")
,container_location = UAR_GET_CODE_DISPLAY(c.current_location_cd)
 ;TIMING
 ,orig_order_dt_tm =
DATETIMEZONEFORMAT(o.orig_order_dt_tm, o.current_start_tz, "MM/DD/YYYY
HH:MM;;q")
 ,collect_dt_tm =
DATETIMEZONEFORMAT(c.drawn_dt_tm, o.current_start_tz, "MM/DD/YYYY
HH:MM;;q") ;replaced CE-based field
 ,received_dt_tm =
DATETIMEZONEFORMAT(c.received_dt_tm, o.current_start_tz, "MM/DD/YYYY
HH:MM;;q") ;replaced CE-based field
 ,performed_dt_tm =
DATETIMEZONEFORMAT(ce.performed_dt_tm, ce.performed_tz, "MM/DD/YYYY
HH:MM;;q")
 ,verified_dt_tm =
DATETIMEZONEFORMAT(ce.verified_dt_tm, ce.verified_tz, "MM/DD/YYYY
HH:MM;;q")
;OTHER LAB ORDER INFO
 ,activity_type =
UAR_GET_CODE_DISPLAY(oc.activity_type_cd)
 ,activity_subtype =
UAR_GET_CODE_DISPLAY(oc.activity_subtype_cd)
 ,loinc_analyte = PIECE(cid.concept_cki,
"!", 2, "")
 ;REFERENCE RANGES
 ,ce.critical_low
 ,ce.normal_low
 ,ce.normal_high
 ,ce.critical_high
;ENCOUNTER/PROVIDER INFO
,originating_fin = fin_orig.alias
 ,fin = fin.alias
 ,responsible_provider =
         IF(order_p.position_cd
> 0)
                 BUILD(order_p.name_full_formatted,
" (", TRIM(UAR_GET_CODE_DISPLAY(order_p.position_cd)), ")")
         ELSE
order_p.name_full_formatted
         ENDIF
 ,ordering_prsnl =
         IF(entry_p.position_cd
> 0)
                 BUILD(entry_p.name_full_formatted,
" (", TRIM(UAR_GET_CODE_DISPLAY(entry_p.position_cd)), ")")
         ELSE
entry_p.name_full_formatted
         ENDIF
 ;OTHER IDENTIFIERS
 ;,o.order_id
 ;,o.originating_encntr_id
 ;,o.encntr_id
 ;,c.container_id
 ;,c.specimen_id
 ;,ce.event_id
 FROM ORDERs o
 ,(LEFT JOIN ENCNTR_ALIAS fin ON
fin.encntr_id = o.encntr_id
         AND
fin.encntr_alias_type_cd = 1077
         AND fin.active_ind = 1
         AND
fin.end_effective_dt_tm > SYSDATE)
,(LEFT JOIN ENCNTR_ALIAS fin_orig ON fin_orig.encntr_id =
o.originating_encntr_id
AND fin_orig.encntr_alias_type_cd = 1077
AND fin_orig.active_ind = 1
AND fin_orig.end_effective_dt_tm > SYSDATE)
,(LEFT JOIN ORDER_CONTAINER_R ocr ON ocr.order_id = o.order_id)
,(LEFT JOIN CONTAINER c ON c.container_id = ocr.container_id)
,(LEFT JOIN CONTAINER_ACCESSION ca ON ca.container_id =
c.container_id)
 ,(LEFT JOIN V500_SPECIMEN spec ON
spec.specimen_id = c.specimen_id)
 ,(LEFT JOIN CLINICAL_EVENT ce ON
ce.order_id = o.order_id
 AND ce.view_level = 1
         AND ce.valid_until_dt_tm
>= SYSDATE
         AND ce.result_status_cd
NOT IN (28,29,30,31)) ;IN ERROR
 ,(LEFT JOIN SERVICE_RESOURCE
perf_resource ON ce.resource_cd = perf_resource.service_resource_cd)
 ,(LEFT JOIN ORGANIZATION perf_org ON
perf_resource.organization_id = perf_org.organization_id)
 ,(LEFT JOIN CONCEPT_IDENTIFIER_DTA cid
ON ce.task_assay_cd = cid.task_assay_cd
 AND cid.service_resource_cd =
ce.resource_cd
 AND cid.specimen_type_cd =
c.specimen_type_cd
 AND cid.concept_type_flag = 1
;LOINC Analyte Code
 AND cid.ignore_ind = 0 ;row is not
ignored by the LOINC service
 AND cid.active_ind = 1
 AND cid.end_effective_dt_tm >
SYSDATE)
 ,ORDER_CATALOG oc
 ,ORDER_ACTION oa
 ,PRSNL order_p
 ,PRSNL entry_p
PLAN o WHERE o.order_id = $order_lookup
JOIN oc WHERE o.catalog_cd = oc.catalog_cd
JOIN oa WHERE oa.order_id = o.order_id
AND oa.action_type_cd = 2534 ;ordered
JOIN order_p WHERE order_p.person_id = oa.order_provider_id
AND order_p.active_ind =
1
JOIN entry_p WHERE entry_p.person_id = oa.action_personnel_id
AND entry_p.active_ind = 1
 JOIN fin
 JOIN fin_orig
 JOIN ocr
 JOIN c
 JOIN ca
 JOIN spec
 JOIN ce
 JOIN perf_resource
 JOIN perf_org
 JOIN cid
 ORDER BY accession_formatted, orderable,
event
ELSEIF($scope
= "Order" AND $rpt_order = "Order Info (pharmacy view)")
 o.order_id
 ,fin = fin.alias
 ,originating_fin = fin_orig.alias
 ; ORDER INFORMATION
 ,orderable =
UAR_GET_CODE_DESCRIPTION(o.catalog_cd)
 ,primary_mnemonic = o.order_mnemonic
 ,o.ordered_as_mnemonic ;often contains
brand name
 ,o.clinical_display_line
 ,order_comment =
SUBSTRING(1,300,oc_text.long_text) ;breaks grain, too many comment types
 ,order_status =
UAR_GET_CODE_DISPLAY(o.order_status_cd)
 ,dept_status =
UAR_GET_CODE_DISPLAY(o.dept_status_cd)
 ,pharmacy_review_status =
EVALUATE(o.need_rx_clin_review_flag,
 0, "unset",
 1, "needs review",
 2, "review complete",
 3, "reviewed/rejected",
 4, "not applicable",
 "unknown value")
 ,order_entered_by =
CNVTUPPER(order_enter.name_full_formatted)
 ,order_provider =
CNVTUPPER(order_sign.name_full_formatted)
 ,stop_type =
UAR_GET_CODE_DISPLAY(o.stop_type_cd)
 ,discontinue_type =
UAR_GET_CODE_DISPLAY(o.discontinue_type_cd)
 ,last_comms_type =
UAR_GET_CODE_DISPLAY(o.latest_communication_type_cd)
 ,contrib_sys =
UAR_GET_CODE_DISPLAY(o.contributor_system_cd)
 ; MEDICATION INFORMATION
 ,med_type =
UAR_GET_CODE_DISPLAY(o.dcp_clin_cat_cd) ;medications vs continuous infusions
 ,med_order_type =
UAR_GET_CODE_DISPLAY(o.med_order_type_cd) ;med, intermittent, IV, etc
 ,dose_strength =
str_dose.oe_field_display_value
 ,dose_strength_unit =
str_dose_unit.oe_field_display_value
 ,dose_volume =
vol_dose.oe_field_display_value
 ,dose_volume_unit =
vol_dose_unit.oe_field_display_value
 ,rate = rate.oe_field_display_value
 ,rate_unit =
rate_unit.oe_field_display_value
 ,route = rx_route.oe_field_display_value
 ,drug_form =
drug_form.oe_field_display_value
 ,freq = freq.oe_field_display_value
 ,prn = prn.oe_field_display_value
 ,prn_reason =
prn_reason.oe_field_display_value
 ,duration = dur.oe_field_display_value
 ,duration_unit =
dur_unit.oe_field_display_value
 ,pharmacy_mask = EVALUATE(o.rx_mask,
 1, "diluent",
 2, "additive",
 4, "med",
 8, "TPN",
 16, "sliding scale",
 32, "tapering dose",
 64, "PCA",
 "other")
 ; TIMING
 ,order_dt_tm =
         DATETIMEZONEFORMAT(o.orig_order_dt_tm,
o.current_start_tz, "MM/DD/YYYY HH:MM;;q")
 ,current_start_dt_tm =
         DATETIMEZONEFORMAT(o.current_start_dt_tm,
o.current_start_tz, "MM/DD/YYYY HH:MM;;q")
 ,projected_stop_dt_tm =
         DATETIMEZONEFORMAT(o.projected_stop_dt_tm,
o.projected_stop_tz, "MM/DD/YYYY HH:MM;;q")
 ,discontinue_effective_dt_tm =
         DATETIMEZONEFORMAT(o.discontinue_effective_dt_tm,
o.discontinue_effective_tz, "MM/DD/YYYY HH:MM;;q")
 ; IDENTIFIERS
 ,o.cki
 ,oefmt.oe_format_name
 FROM ORDERS o
 ,(LEFT JOIN ORDER_DETAIL str_dose ON
o.order_id = str_dose.order_id
 AND str_dose.oe_field_meaning =
"STRENGTHDOSE")
 ,(LEFT JOIN ORDER_DETAIL str_dose_unit
ON o.order_id = str_dose_unit.order_id
 AND str_dose_unit.oe_field_meaning
= "STRENGTHDOSEUNIT")
 ,(LEFT JOIN ORDER_DETAIL vol_dose ON
o.order_id = vol_dose.order_id
 AND vol_dose.oe_field_meaning =
"VOLUMEDOSE")
 ,(LEFT JOIN ORDER_DETAIL vol_dose_unit
ON o.order_id = vol_dose_unit.order_id
 AND vol_dose_unit.oe_field_meaning
= "VOLUMEDOSEUNIT")
 ,(LEFT JOIN ORDER_DETAIL rate ON
o.order_id = rate.order_id
 AND rate.oe_field_meaning =
"RATE")
 ,(LEFT JOIN ORDER_DETAIL rate_unit ON
o.order_id = rate_unit.order_id
 AND rate_unit.oe_field_meaning =
"RATEUNIT")
 ,(LEFT JOIN ORDER_DETAIL rx_route ON
o.order_id = rx_route.order_id
 AND rx_route.oe_field_meaning =
"RXROUTE")
 ,(LEFT JOIN ORDER_DETAIL drug_form ON
o.order_id = drug_form.order_id
 AND drug_form.oe_field_meaning =
"DRUGFORM")
 ,(LEFT JOIN ORDER_DETAIL freq ON
o.order_id = freq.order_id
 AND freq.oe_field_meaning =
"FREQ")
 ,(LEFT JOIN ORDER_DETAIL prn ON
o.order_id = prn.order_id
 AND prn.oe_field_meaning =
"SCH/PRN")
 ,(LEFT JOIN ORDER_DETAIL prn_reason ON
o.order_id = prn_reason.order_id
 AND prn_reason.oe_field_meaning =
"PRNREASON")
 ,(LEFT JOIN ORDER_DETAIL dur ON
o.order_id = dur.order_id
 AND dur.oe_field_meaning =
"DURATION")
 ,(LEFT JOIN ORDER_DETAIL dur_unit ON
o.order_id = dur_unit.order_id
 AND dur_unit.oe_field_meaning =
"DURATIONUNIT")
,(LEFT JOIN ORDER_COMMENT oc ON o.order_id = oc.order_id)
,(LEFT JOIN LONG_TEXT oc_text ON oc.long_text_id =
oc_text.long_text_id)
 ,(LEFT JOIN ORDER_ACTION oa ON
o.order_id = oa.order_id
 AND oa.action_type_cd = 2534) ;
;needed for ordering provider
 ,(LEFT JOIN PRSNL order_enter ON
oa.action_personnel_id = order_enter.person_id)
 ,(LEFT JOIN PRSNL order_sign ON
oa.order_provider_id = order_sign.person_id)
 ,(LEFT JOIN ENCNTR_ALIAS fin ON
fin.encntr_id = o.encntr_id
         AND
fin.encntr_alias_type_cd = 1077
         AND fin.active_ind = 1
         AND
fin.end_effective_dt_tm > SYSDATE)
,(LEFT JOIN ENCNTR_ALIAS fin_orig ON fin_orig.encntr_id =
o.originating_encntr_id
AND fin_orig.encntr_alias_type_cd = 1077
AND fin_orig.active_ind = 1
AND fin_orig.end_effective_dt_tm > SYSDATE)
 ,ORDER_ENTRY_FORMAT oefmt
PLAN o WHERE o.order_id = $order_lookup
 JOIN fin
 JOIN fin_orig
 JOIN oefmt WHERE o.oe_format_id =
oefmt.oe_format_id
AND oefmt.action_type_cd = 2534 ;order
 JOIN oc ;you can have multiple comments,
breaking the grain
 JOIN oc_text ;you can have multiple
comments, breaking the grain
 JOIN oa
 JOIN order_enter
 JOIN order_sign
 JOIN str_dose
 JOIN str_dose_unit
 JOIN vol_dose
 JOIN vol_dose_unit
 JOIN rate
 JOIN rate_unit
 JOIN rx_route
 JOIN drug_form
 JOIN freq
 JOIN prn
 JOIN prn_reason
 JOIN dur
 JOIN dur_unit
ELSEIF($scope
= "Order" AND $rpt_order = "Order Info (radiology view)")
 o.order_id
 ,fin = fin.alias
 ,originating_fin = fin_orig.alias
 ; ORDER INFORMATION
 ,orderable = oc.description
 ,catalog_type =
UAR_GET_CODE_DISPLAY(oc.catalog_type_cd)
 ,activity_type =
UAR_GET_CODE_DISPLAY(oc.activity_type_cd)
 ,activity_subtype =
UAR_GET_CODE_DISPLAY(oc.activity_subtype_cd)
 ,clinical_category =
UAR_GET_CODE_DISPLAY(o.dcp_clin_cat_cd)
 ,o.ordered_as_mnemonic ;often contains
brand name
 ,powerplan = pc.description
 ,order_detail =
SUBSTRING(1,100,replace_CRLF(o.order_detail_display_line))
 ,order_status =
UAR_GET_CODE_DISPLAY(o.order_status_cd)
 ,dept_status =
UAR_GET_CODE_DISPLAY(o.dept_status_cd)
 ,order_entered_by =
CNVTUPPER(order_enter.name_full_formatted)
 ,order_provider =
CNVTUPPER(order_sign.name_full_formatted)
 ,stop_type =
UAR_GET_CODE_DISPLAY(o.stop_type_cd)
 ,o.discontinue_ind
 ,discontinue_type =
UAR_GET_CODE_DISPLAY(o.discontinue_type_cd)
 ,last_comms_type =
UAR_GET_CODE_DISPLAY(o.latest_communication_type_cd)
 ,contrib_sys =
UAR_GET_CODE_DISPLAY(o.contributor_system_cd)
 ; ORDER TIMING
 ,order_dt_tm =
         DATETIMEZONEFORMAT(o.orig_order_dt_tm,
o.current_start_tz, "MM/DD/YYYY HH:MM;;q")
 ,current_start_dt_tm =
         DATETIMEZONEFORMAT(o.current_start_dt_tm,
o.current_start_tz, "MM/DD/YYYY HH:MM;;q")
 ,projected_stop_dt_tm =
         DATETIMEZONEFORMAT(o.projected_stop_dt_tm,
o.projected_stop_tz, "MM/DD/YYYY HH:MM;;q")
 ,discontinue_effective_dt_tm =
         DATETIMEZONEFORMAT(o.discontinue_effective_dt_tm,
o.discontinue_effective_tz, "MM/DD/YYYY HH:MM;;q")
 ,status_dt_tm =
DATETIMEZONEFORMAT(o.status_dt_tm, o.orig_order_tz, "MM/DD/YYYY
HH:MM;;q")
 ,order_tz =
DateTimeZoneByIndex(o.orig_order_tz)
; EXAM INFORMATION
 ,exam_required = re.required_ind
 ,exam_scheduled_dt_tm =
DATETIMEZONEFORMAT(re.sched_req_dt_tm, re.sched_req_tz, "MM/DD/YYYY
HH:MM;;q")
 ,exam_resource =
UAR_GET_CODE_DISPLAY(re.service_resource_cd)
 ,re.exam_sequence
 ,exam_start =
DATETIMEZONEFORMAT(re.starting_dt_tm, re.sched_req_tz, "MM/DD/YYYY
HH:MM;;q")
 ,exam_complete =
DATETIMEZONEFORMAT(re.complete_dt_tm, re.sched_req_tz, "MM/DD/YYYY
HH:MM;;q")
 ,exam_charges_sent_ind =
re.charges_sent_ind
 ,exam_timezone =
DateTimeZoneByIndex(re.sched_req_tz)
 ; REPORT INFORMATION
 ,rpt_reference_nbr =
rr.rad_rpt_reference_nbr
 ,rpt_creation_method =
UAR_GET_CODE_DISPLAY(rr.report_creation_mthd_cd)
 ,rpt_dictated_dt_tm =
DATETIMEZONEFORMAT(rr.dictated_dt_tm, rr.dictated_tz, "MM/DD/YYYY
HH:MM;;q")
 ,rpt_transcribed_dt_tm =
DATETIMEZONEFORMAT(rr.original_trans_dt_tm, rr.original_trans_tz,
"MM/DD/YYYY HH:MM;;q")
 ,rpt_final_dt_tm =
DATETIMEZONEFORMAT(rr.final_dt_tm, rr.final_tz, "MM/DD/YYYY
HH:MM;;q")
 ,rpt_dictated_by =
BUILD(dict_prsnl.name_full_formatted, " (",
UAR_GET_CODE_DISPLAY(dict_prsnl.position_cd), ")")
 ,rpt_addendum_ind = rr.addendum_ind
 ,rpt_modified_ind = rr.modified_ind
 ,rpt_sign_reject_mark_flag =
EVALUATE(rr.sign_reject_mark_flag,
         0, "Unmarked",
         1, "Marked for
Signout",
         2, "Marked for
Rejection",
         3, "Marked for
Return to Resident",
         "Unknown
flag")
 ,rpt_charges_sent_ind = rr.charges_sent_ind
,rpt_timezone = DateTimeZoneByIndex(rr.final_tz)
 ; IDENTIFIERS
 ,oefmt.oe_format_name
 ,o.encntr_id
 ,o.originating_encntr_id
 ,re.rad_exam_id
 ,rr.rad_report_id
 ;,times_displayed_as =
DateTimeZoneByIndex(curtimezoneapp)
 FROM ORDERS o
 ,(LEFT JOIN ENCNTR_ALIAS fin ON
fin.encntr_id = o.encntr_id
         AND
fin.encntr_alias_type_cd = 1077
         AND fin.active_ind = 1
         AND
fin.end_effective_dt_tm > SYSDATE)
,(LEFT JOIN ENCNTR_ALIAS fin_orig ON fin_orig.encntr_id =
o.originating_encntr_id
AND fin_orig.encntr_alias_type_cd = 1077
AND fin_orig.active_ind = 1
AND fin_orig.end_effective_dt_tm > SYSDATE)
         ,(LEFT JOIN
PATHWAY_CATALOG pc ON o.pathway_catalog_id = pc.pathway_catalog_id)
         ,(LEFT JOIN RAD_EXAM re
ON o.order_id = re.order_id)
         ,(LEFT JOIN RAD_REPORT
rr ON o.order_id = rr.order_id)
         ,(LEFT JOIN PRSNL
dict_prsnl ON rr.dictated_by_id = dict_prsnl.person_id)
 ,(LEFT JOIN ORDER_ACTION oa ON
o.order_id = oa.order_id        AND
oa.action_type_cd = 2534)
 ,(LEFT JOIN PRSNL order_enter ON
oa.action_personnel_id = order_enter.person_id)
 ,(LEFT JOIN PRSNL order_sign ON
oa.order_provider_id = order_sign.person_id)
 ,ORDER_CATALOG oc
 ,ORDER_ENTRY_FORMAT oefmt
 PLAN o WHERE o.order_id = $order_lookup
 JOIN oc WHERE o.catalog_cd = oc.catalog_cd
 JOIN oefmt WHERE o.oe_format_id =
oefmt.oe_format_id
AND oefmt.action_type_cd = 2534 ;order
JOIN fin
 JOIN fin_orig
 JOIN pc
 JOIN re
 JOIN rr
 JOIN dict_prsnl
 JOIN oa
 JOIN order_enter
 JOIN order_sign
ELSEIF($scope
= "Order" AND $rpt_order = "Order Actions")
o.order_id
,orderable = oc.description
,action_seq = oa.action_sequence
,action_dt_tm = DATETIMEZONEFORMAT(oa.action_dt_tm, oa.action_tz,
"MM/DD/YYYY HH:MM;;q")
,action_type = UAR_GET_CODE_DISPLAY(oa.action_type_cd)
,order_status = UAR_GET_CODE_DISPLAY(oa.order_status_cd)
,dept_status = UAR_GET_CODE_DISPLAY(oa.dept_status_cd)
,detail_display_line = oa.order_detail_display_line
,communication_type = UAR_GET_CODE_DISPLAY(oa.communication_type_cd)
,action_prsnl = p.name_full_formatted
,schedulable_state = UAR_GET_CODE_DISPLAY(oa.sch_state_cd)
,stop_type = UAR_GET_CODE_DISPLAY(oa.stop_type_cd)
FROM ORDERS o
,ORDER_ACTION oa
,ORDER_CATALOG oc
,PRSNL p
PLAN o WHERE o.order_id = $order_lookup
JOIN oa WHERE o.order_id = oa.order_id
JOIN oc WHERE o.catalog_cd = oc.catalog_cd
JOIN p WHERE oa.action_personnel_id = p.person_id
ORDER BY action_seq
ELSEIF($scope
= "Order" AND $rpt_order = "Order Comments")
orderable = oc.description
,action_seq = ocm.action_sequence
,comment = SUBSTRING(1,30000,lt.long_text)
,comment_type = UAR_GET_CODE_DISPLAY(ocm.comment_type_cd)
,comment_dt_tm = DATETIMEZONEFORMAT(ocm.updt_dt_tm, o.current_start_tz,
"MM/DD/YYYY HH:MM;;q")
,comment_prsnl = p.name_full_formatted
FROM ORDERS o
,ORDER_CATALOG oc
,ORDER_COMMENT ocm ;comment_dt_tm and comment_prsnl_id blank, using updt_ instead
,LONG_TEXT lt
,PRSNL p
PLAN o WHERE o.order_id = $order_lookup
JOIN oc WHERE oc.catalog_cd = o.catalog_cd
JOIN ocm WHERE ocm.order_id = o.order_id
JOIN lt WHERE lt.long_text_id = ocm.long_text_id
JOIN p WHERE p.person_id = ocm.updt_id
ORDER BY ocm.action_sequence
ELSEIF($scope
= "Order" AND $rpt_order = "Order Compliance Details")
orderable = oc.description
,ocd.compliance_capture_dt_tm
,order_compliance_status =
UAR_GET_CODE_DISPLAY(ocd.compliance_status_cd)
,encntr_compliance_status =
EVALUATE(ocmp.encntr_compliance_status_flag,
0, "Complete",
1, "Incomplete",
2, "In Error",
"Unknown flag value")
,information_source = UAR_GET_CODE_DISPLAY(ocd.information_source_cd)
,compliance_prsnl =
IF(p.position_cd = 0) p.name_full_formatted
ELSE BUILD(p.name_full_formatted, " (",
TRIM(UAR_GET_CODE_DISPLAY(p.position_cd)), ")")
ENDIF
,ocmp.no_known_home_meds_ind
,ocmp.unable_to_obtain_ind
,fin = fin.alias
,o.order_id
,ocmp.encntr_id
,ocd.order_compliance_id
,ocd.order_compliance_detail_id
FROM ORDERS o
,ORDER_CATALOG oc
,ORDER_COMPLIANCE_DETAIL ocd
,(LEFT JOIN LONG_TEXT lt ON lt.long_text_id = ocd.long_text_id)
,ORDER_COMPLIANCE ocmp
,(LEFT JOIN ENCNTR_ALIAS fin ON fin.encntr_id = ocmp.encntr_id
AND fin.encntr_alias_type_cd = 1077 ;FIN
AND fin.end_effective_dt_tm > SYSDATE
AND fin.active_ind = 1)
,PRSNL p
PLAN o WHERE o.order_id = $order_lookup
JOIN oc WHERE oc.catalog_cd = o.catalog_cd
JOIN ocd WHERE ocd.order_nbr = o.order_id
JOIN ocmp WHERE ocmp.order_compliance_id = ocd.order_compliance_ID
JOIN p WHERE p.person_id = ocmp.performed_prsnl_id
JOIN lt
JOIN fin
ORDER BY ocd.compliance_capture_dt_tm
ELSEIF($scope
= "Order" AND $rpt_order = "Order Details")
o.order_id
,orderable = oc.description
,field = oef.description
,od.oe_field_meaning ;field
,od.oe_field_display_value
,order_action = UAR_GET_CODE_DISPLAY(oa.action_type_cd)
,order_action_sequence = od.action_sequence
,od.detail_sequence
,field_type = EVALUATE(oef.field_type_flag,
0, "Alphanumeric",
1, "Integer",
2, "Decimal",
3, "Date",
5, "Date/Time",
6, "Code Set",
7, "Yes/No",
8, "Provider",
9, "Location",
10, "ICD",
11, "Printer",
12, "List",
13, "User/Personnel",
14, "Accession",
15, "Surgical Duration",
"Unknown Value")
,validation_type = EVALUATE(oef.validation_type_flag,
0, "None",
1, "Code Set",
2, "Request",
3, "Range",
"Unknown Value")
,od.oe_field_id
FROM ORDERS o
,ORDER_DETAIL od
,ORDER_ENTRY_FIELDS oef
,ORDER_CATALOG oc
,ORDER_ACTION oa
PLAN o WHERE o.order_id = $order_lookup
JOIN od WHERE o.order_id = od.order_id
JOIN oef WHERE od.oe_field_id = oef.oe_field_id
AND od.oe_field_meaning_id = oef.oe_field_meaning_id
JOIN oc WHERE o.catalog_cd = oc.catalog_cd
JOIN oa WHERE oa.order_id = o.order_id
AND oa.action_sequence = od.action_sequence
ORDER BY od.action_sequence, od.detail_sequence
ELSEIF($scope
= "Order" AND $rpt_order = "Order Diagnoses")
o.order_id
,orderable = oc.description
,diagnosis = n.source_string
,code = n.source_identifier
,ner.priority
,n.nomenclature_id
FROM ORDERS o
,(LEFT JOIN NOMEN_ENTITY_RELTN ner
ON ner.parent_entity_id = o.order_id
AND ner.parent_entity_name = "ORDERS"
AND ner.child_entity_name = "DIAGNOSIS"
AND ner.end_effective_dt_tm > SYSDATE
AND ner.active_ind = 1
)
,(LEFT JOIN NOMENCLATURE n ON n.nomenclature_id = ner.nomenclature_id)
,ORDER_CATALOG oc
PLAN o WHERE o.order_id = $order_lookup
JOIN oc WHERE oc.catalog_cd = o.catalog_cd
JOIN ner
JOIN n
ORDER BY ner.priority, CNVTUPPER(n.source_string)
ELSEIF($scope
= "Order" AND $rpt_order = "Order Notifications")
notification = EVALUATE(orn.notification_type_flag,
1, "Renew",
2, "Cosign",
3, "Med Student",
4, "Incomplete Order",
5, "Refusal",
"unknown flag")
,notification_dt_tm =
DATETIMEZONEFORMAT(orn.notification_display_dt_tm, orn.notification_display_tz,
"MM/DD/YYYY HH:MM;;q")
,status = EVALUATE(orn.notification_status_flag,
1, "pending",
2, "completed",
3, "refused",
4, "forwarded",
5, "admin cleared",
6, "no longer needed",
"unknown flag")
,status_changed = DATETIMEZONEFORMAT(orn.status_change_dt_tm,
orn.status_change_tz, "MM/DD/YYYY HH:MM;;q")
,from_prsnl = from_prsnl.name_full_formatted
,from_group = from_group.prsnl_group_name
,to_prsnl = to_prsnl.name_full_formatted
,to_group = to_group.prsnl_group_name
,assigned_prsnl = assigned.name_full_formatted
,orn.action_sequence
;identifiers
,orn.order_notification_id
,orn.parent_order_notification_id
FROM ORDER_NOTIFICATION orn
,(LEFT JOIN PRSNL from_prsnl ON from_prsnl.person_id =
orn.from_prsnl_id)
,(LEFT JOIN PRSNL_GROUP from_group ON from_group.prsnl_group_id =
orn.from_prsnl_group_id)
,(LEFT JOIN PRSNL to_prsnl ON to_prsnl.person_id = orn.to_prsnl_id)
,(LEFT JOIN PRSNL_GROUP to_group ON to_group.prsnl_group_id =
orn.to_prsnl_group_id)
,(LEFT JOIN PRSNL assigned ON assigned.person_id =
orn.assigned_prsnl_id)
PLAN orn WHERE orn.order_id = $order_lookup
JOIN from_prsnl
JOIN from_group
JOIN to_prsnl
JOIN to_group
JOIN assigned
ORDER BY orn.action_sequence
;This topic
has not been explored - code transcribed from Dr. Dan Brooks' SQL
ELSEIF($scope
= "Order" AND $rpt_order = "Order Pathways")
o.order_id
,orderable = oc.description
,pathway = pc.description
,display_method = UAR_GET_CODE_DISPLAY(pc.display_method_cd)
,action_type = UAR_GET_CODE_DISPLAY(pca.action_type_cd)
,action_prsnl = action_prsnl.name_full_formatted
,action_dt_tm = DATETIMEZONEFORMAT(pca.action_dt_tm, pca.action_tz,
"MM/DD/YYYY HH:MM;;q")
,apc.activated_ind
,activated_prsnl = activated_prsnl.name_full_formatted
,activated_dt_tm = DATETIMEZONEFORMAT(apc.activated_dt_tm,
apc.activated_tz, "MM/DD/YYYY HH:MM;;q")
,p.pathway_id
,pc.pathway_catalog_id
FROM ORDERS o
,ORDER_CATALOG oc
,PATHWAY p
,PATHWAY_CATALOG pc
,ACT_PW_COMP apc
,PW_COMP_ACTION pca
,PRSNL action_prsnl
,PRSNL activated_prsnl
PLAN o WHERE o.order_id = $order_lookup
JOIN oc WHERE oc.catalog_cd = o.catalog_cd
JOIN p WHERE p.encntr_id = o.encntr_id
JOIN pc WHERE pc.pathway_catalog_id = p.pathway_catalog_id
JOIN apc WHERE apc.pathway_id = p.pathway_id
JOIN pca WHERE pca.act_pw_comp_id = apc.act_pw_comp_id
AND pca.parent_entity_name = "ORDERS"
AND pca.parent_entity_id = o.order_id
AND pca.action_type_cd = 10754 ;create
JOIN action_prsnl WHERE action_prsnl.person_id = pca.action_prsnl_id
JOIN activated_prsnl WHERE activated_prsnl.person_id =
apc.activated_prsnl_id
ELSEIF($scope
= "Order" AND $rpt_order = "Order Result Actions")
orderable = oc.description
,event = UAR_GET_CODE_DISPLAY(ce.event_cd)
,result = ce.result_val
 ,result_units =
UAR_GET_CODE_DISPLAY(ce.result_units_cd)
 ,result_flag =
UAR_GET_CODE_DISPLAY(ce.normalcy_cd)
,event_end_dt_tm = DATETIMEZONEFORMAT(ce.event_end_dt_tm,
ce.event_end_tz, "MM/DD/YYYY HH:MM;;q")
,action_dt_tm = DATETIMEZONEFORMAT(cep.action_dt_tm, cep.action_tz,
"MM/DD/YYYY HH:MM:SS;;q")
,action = UAR_GET_CODE_DISPLAY(cep.action_type_cd)
,action_status = UAR_GET_CODE_DISPLAY(cep.action_status_cd)
,action_prsnl =
IF(ap.position_cd > 0) BUILD(ap.name_full_formatted, " (",
UAR_GET_CODE_DISPLAY(ap.position_cd), ")")
ELSE ap.name_full_formatted
ENDIF
,order_provider = op.name_full_formatted
,action_by_order_provider =
IF(op.person_id = ap.person_id) "yes"
ELSE "no"
ENDIF
;IDENTIFIERS
,ce.order_id
,ce.event_id
,cep.event_prsnl_id
FROM CLINICAL_EVENT ce
,CE_EVENT_PRSNL cep
,PRSNL ap
,ORDER_CATALOG oc
,ORDER_ACTION oa
,PRSNL op
PLAN ce WHERE ce.order_id = $order_lookup
AND ce.result_status_cd NOT IN (28,29,30,31)
AND ce.view_level = 1
AND ce.valid_until_dt_tm > SYSDATE
JOIN cep WHERE cep.event_id = ce.event_id
AND cep.valid_until_dt_tm >
SYSDATE
JOIN ap WHERE ap.person_id = cep.action_prsnl_id
AND ap.active_ind = 1
JOIN oc WHERE oc.catalog_cd = ce.catalog_cd
AND oc.active_ind = 1
JOIN oa WHERE oa.order_id = ce.order_id
AND oa.action_type_cd = 2534 ;order
JOIN op WHERE op.person_id = oa.order_provider_id
AND op.active_ind = 1
ORDER BY event, cep.action_dt_tm, action
ELSEIF($scope
= "Order" AND $rpt_order = "Order Tasks")
ta.order_id
,orderable =
IF(oc.catalog_cd > 0) oc.description
ELSE ""
ENDIF
,catalog_type = UAR_GET_CODE_DISPLAY(ta.catalog_type_cd)
,activity_type = UAR_GET_CODE_DISPLAY(oc.activity_type_cd)
,ta.task_create_dt_tm "MM/DD/YYYY HH:MM;;q"
,task_dt_tm = DATETIMEZONEFORMAT(ta.task_dt_tm, ta.task_tz,
"MM/DD/YYYY HH:MM;;q")
,ta.scheduled_dt_tm "MM/DD/YYYY HH:MM;;q"
,activity = UAR_GET_CODE_DISPLAY(ta.task_activity_cd)
,status =
IF(ta.task_status_reason_cd > 0)
BUILD(TRIM(UAR_GET_CODE_DISPLAY(ta.task_status_cd)), " (",
TRIM(UAR_GET_CODE_DISPLAY(ta.task_status_reason_cd)), ")")
ELSE UAR_GET_CODE_DISPLAY(ta.task_status_cd)
ENDIF
,priority = UAR_GET_CODE_DISPLAY(ta.task_priority_cd)
,type = UAR_GET_CODE_DISPLAY(ta.task_type_cd)
,class = UAR_GET_CODE_DISPLAY(ta.task_class_cd)
,med_order_type = UAR_GET_CODE_DISPLAY(ta.med_order_type_cd)
,ta.iv_ind
,ta.tpn_ind
,ta.msg_subject
,performing_prsnl = p.name_full_formatted
,nurse_unit = UAR_GET_CODE_DISPLAY(ta.location_cd)
FROM TASK_ACTIVITY ta
,(LEFT JOIN ORDER_CATALOG oc ON ta.catalog_cd = oc.catalog_cd)
,PRSNL p
PLAN ta WHERE ta.order_id = $order_lookup
AND ta.active_ind = 1
JOIN p WHERE ta.performed_prsnl_id = p.person_id
JOIN oc
ORDER BY ta.order_id
ELSEIF($scope
= "Order" AND $rpt_order = "RX Dispense History")
o.order_mnemonic
,dh.action_sequence
,event_type = UAR_GET_CODE_DISPLAY(dh.disp_event_type_cd)
,event_reason = UAR_GET_CODE_DISPLAY(dh.reason_cd)
,dispense_dt_tm = DATETIMEZONEFORMAT(dh.dispense_dt_tm, dh.dispense_tz,
"MM/DD/YYYY HH:MM;;q")
,dispense_tz = DateTimeZoneByIndex(dh.dispense_tz)
,dispense_qty = dh.disp_qty
,units = UAR_GET_CODE_DISPLAY(dh.disp_qty_unit_cd)
,dh.refills_remaining
,dh.qty_remaining
,status =
UAR_GET_CODE_DISPLAY(ds.dispense_status_cd)
,priority = UAR_GET_CODE_DISPLAY(dh.disp_priority_cd)
,type = UAR_GET_CODE_DISPLAY(dh.pharm_type_cd)
,pharmacy = UAR_GET_CODE_DISPLAY(dh.disp_sr_cd)
,pharmacy_desc = UAR_GET_CODE_DESCRIPTION(dh.disp_sr_cd)
,pharmacy_workstation = UAR_GET_CODE_DISPLAY(dh.level5_cd)
,dispense_prsnl = BUILD(run_p.name_full_formatted, " (",
UAR_GET_CODE_DISPLAY(run_p.position_cd), ")")
,dh.charge_ind
,dh.charge_dt_tm
,dh.prev_dispense_dt_tm
,dh.next_dispense_dt_tm
,dh.fill_nbr
,dh.ivr_refill_ind
,track_nbr_prefix = UAR_GET_CODE_DISPLAY(dh.track_nbr_cd)
,dh.track_nbr
,hp.plan_name
,dh.authorization_nbr
,o.order_id
,dh.dispense_hx_id
,dh.crdt_dispense_hx_id
FROM ORDERS o
,DISPENSE_HX dh
,(LEFT JOIN DISPENSE_STATUS ds ON dh.dispense_hx_id =
ds.dispense_hx_id)
,(LEFT JOIN HEALTH_PLAN hp ON dh.health_plan_id = hp.health_plan_id)
,PRSNL run_p
PLAN o WHERE o.order_id = $order_lookup
JOIN dh WHERE o.order_id = dh.order_id
;AND dh.disp_event_type_cd IN (685817, 638938) ;dispense, device
dispense
JOIN run_p WHERE dh.run_user_id = run_p.person_id
JOIN hp
JOIN ds
ORDER BY dh.dispense_hx_id, dh.dispense_dt_tm
ENDIF
INTO $OUTDEV
error = "Invalid prompt selections"
WITH
NOCOUNTER, SEPARATOR=" ", FORMAT, CHECK, TIME=300
end
go
