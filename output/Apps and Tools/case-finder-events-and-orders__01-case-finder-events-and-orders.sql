/*
 * Source page  : Case Finder - Events and Orders
 * Source file  : output/case-finder-events-and-orders.md
 * Anchor       : (top of page)
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 1210
 *
 * Context (preceding paragraph):
 *   Exported: 12/16/25
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

drop program
dev_rpt_cf_events_orders go
create
program dev_rpt_cf_events_orders
/******************************************************************************
 REPORT NAME:
        Case Finder - Events and Orders
 PROGRAM:                1fed_rpt_cf_events_orders.prg
 DEV
PROGRAM:        dev_rpt_cf_events_orders.prg
 DEVELOPER:        David Alt
 PUBLISHED:        12/02/2024
 SNAPSHOT:                08/12/2025
 LOGICAL
PATH:        cust_script
 NODE:                        <default>
 PURPOSE/DESCRIPTION:
        Technical tool to identify
usage examples and statistics for
                                                 clinical
events, DTAs, and orderables.
 TARGET AUDIENCE: report developers, solution owners/experts
MOD        DATE                DEVELOPER                COMMENT
---        --/--/--        ---------                ----------------------------
001        05/15/24        David
Alt                Initial
build/prototype
002        11/19/24        David
Alt                Set
alpha resp wildcard to suffix only - causes error otherwise
003 12/02/24        David
Alt                Initial
publication to production
004        12/04/24        David
Alt                Removed
order status filter that was excluding rows
005        06/09/25        David
Alt                Increased
width of dt/tm controls
006        07/18/25        David
Alt                Max
rec increased to 5000, added view_level = 1 to event reports
007        08/12/25        David
Alt                Removed
view_level filters, added output to show 0-level events
--- unpublished changes ---
008        12/16/25        David
Alt                Added
Detail (interactive)
# ToDo:
Getting memory errors with interactive output for orders
# Consider:
x Add "Any" options to catalog type and activity type - not
feasible because can't apply operand to prompt logic
******************************************************************************/
prompt
"Output to File/Printer/MINE" = "MINE" ;* Enter or select the printer or file name
to send this report to.
, "Search" = ""
, "Search by" = "event_cd"
, "Event/DTA" = 0
, "Response" = "*"
, "Orderable" = 0
, "Mnemonic" = 0
, "Agency" = "ALL"
, "Facility" = VALUE(0.0)
, "Start Date" = "SYSDATE"
, "End Date" = "SYSDATE"
, "Output" = ""
with OUTDEV,
search, search_by, event_result, alpha_resp, order_result,
order_syn_result, agency, facility, start_date, end_date, rpt
/**************************************************************
; Global
Declarations
**************************************************************/
declare
target_event_cd = f8 with protect, noconstant(0)
declare
target_catalog_cd = f8 with protect, noconstant(0)
declare
fac_idx = i4 with protect, noconstant(0) ;index for expanding fac record
declare
ors_idx = i4 with protect, noconstant(0) ;index for expanding ors record
/**************************************************************
; Record
Structures
**************************************************************/
free record
fac ;stores the facilities chosen from the prompt
record fac (
1 facility[*]
2 facility_cd = f8
) with
protect
free record
ors
record ors (
1 list[*]
2 order_id = f8
2 encntr_id = f8
2 person_id = f8
) with
protect
/**************************************************************
; Subroutines
**************************************************************/
; Removes all
line feeds/carriage returns/tabs from a string
subroutine
(replace_CRLF(input = vc) = vc)
; HT = char(9) horizontal tab
; LF = char(10) line feed
; CR = char(13) carriage return
declare output = vc with protect, noconstant("")
declare CRLF = vc with protect, constant(concat(char(13), char(10)))
declare CR = vc with protect, constant(char(13))
declare LF = vc with protect, constant(char(10))
declare HT = vc with protect, constant(char(9))
declare REPLACEMENT = vc with constant(" ")
; remove carriage return+line feed at the beginning and end of the
string
; option 3 -> Trim leading and trailing spaces
set output = trim(input, 3)
; replace carriage return+line feed inside string
set output = replace(output, CRLF, REPLACEMENT)
set output = replace(output, CR, REPLACEMENT)
set output = replace(output, LF, REPLACEMENT)
set output = replace(output, HT, REPLACEMENT)
set output = TRIM(output)
return (output)
end
subroutine
(get_event_cd_from_dta(input = f8) = f8)
declare output = f8
SELECT INTO "NL:"
FROM CODE_VALUE cv
,(LEFT JOIN DISCRETE_TASK_ASSAY dta ON dta.task_assay_cd =
cv.code_value)
,(LEFT JOIN CODE_VALUE_EVENT_R cver ON cver.parent_cd = cv.code_value)
PLAN cv WHERE cv.code_value = input
JOIN dta
JOIN cver
detail
output = EVALUATE2(
IF(cver.event_cd > 0) cver.event_cd
ELSE dta.event_cd
ENDIF
)
with nocounter
return (output)
end
;get_event_cd_from_dta
; Populate
the list of facilities from the prompt
subroutine
(build_fac_record(input = NULL) = NULL)
declare i = i4 with protect,
noconstant(0)
IF($facility = 0.0) ;"Any"
IF($agency = "ALL")
SELECT INTO "NL:"
 FROM CUST_LOC_AGENCY_RELTN ag
 ,CODE_VALUE cv
 PLAN ag
 JOIN cv WHERE ag.location_cd
= cv.code_value
 AND cv.display_key !=
"ZZ*"
DETAIL
i += 1
CALL ALTERLIST(fac->facility, i)
fac->facility[i].facility_cd = ag.location_cd
WITH NOCOUNTER
ELSEIF($agency = "DOD")
SELECT INTO "NL:"
 FROM CUST_LOC_AGENCY_RELTN ag
 ,CODE_VALUE cv
 PLAN ag WHERE ag.agency =
"DOD"
 JOIN cv WHERE ag.location_cd
= cv.code_value
 AND cv.display_key !=
"ZZ*"
DETAIL
i += 1
CALL ALTERLIST(fac->facility, i)
fac->facility[i].facility_cd = ag.location_cd
WITH NOCOUNTER
ELSEIF($agency = "USCG")
SELECT INTO "NL:"
 FROM CUST_LOC_AGENCY_RELTN ag
 ,CODE_VALUE cv
 PLAN ag WHERE ag.agency =
"USCG"
 JOIN cv WHERE ag.location_cd
= cv.code_value
 AND cv.display_key !=
"ZZ*"
DETAIL
i += 1
CALL ALTERLIST(fac->facility, i)
fac->facility[i].facility_cd = ag.location_cd
WITH
NOCOUNTER
ELSEIF($agency = "VA")
SELECT INTO "NL:"
 FROM CUST_LOC_AGENCY_RELTN ag
 ,CODE_VALUE cv
 PLAN ag WHERE ag.agency =
"VA"
 JOIN cv WHERE ag.location_cd
= cv.code_value
 AND cv.display_key !=
"ZZ*"
DETAIL
i += 1
CALL ALTERLIST(fac->facility, i)
fac->facility[i].facility_cd = ag.location_cd
WITH NOCOUNTER
ENDIF ;"Any" chosen
ELSE ;specific organizations were selected
SELECT INTO "NL:"
FROM CUST_LOC_AGENCY_RELTN ag
PLAN ag WHERE ag.location_cd = $facility
DETAIL
i += 1
CALL ALTERLIST(fac->facility, i)
fac->facility[i].facility_cd = ag.location_cd
WITH NOCOUNTER
ENDIF
end
;build_fac_record
subroutine(build_ors(input
= NULL) = NULL)
SELECT INTO "NL:"
FROM ORDERS o
,ENCOUNTER e
PLAN o WHERE o.orig_order_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND NOT EXISTS(        SELECT 1
FROM PERSON_INFO pi
WHERE pi.person_id = o.person_id
AND pi.info_sub_type_cd = 2678703703 ;Test Patient Identifier
AND pi.value_cd != 2678703509 ;"Not a Test Patient"
)
AND o.template_order_flag IN (0,1,5,7) ;exclude auto-generated child
orders
AND o.catalog_cd = target_catalog_cd
AND o.active_ind = 1
JOIN e WHERE 1=1
AND ((e.encntr_id = o.originating_encntr_id AND o.originating_encntr_id
!= 0)
OR (e.encntr_id = o.encntr_id AND o.originating_encntr_id = 0))
AND EXPAND(fac_idx, 1, size(fac->facility, 5), e.loc_facility_cd,
fac->facility[fac_idx].facility_cd)
AND e.end_effective_dt_tm > SYSDATE
AND e.active_ind = 1
ORDER BY o.order_id
HEAD REPORT
i = 0
DETAIL
i += 1
CALL ALTERLIST(ors->list, i)
ors->list[i].order_id = o.order_id
ors->list[i].encntr_id = e.encntr_id
ors->list[i].person_id = o.person_id
WITH MAXREC=5000, NULLREPORT
end
;build_ors
;wrap the
input in HTML table cell tags
subroutine(td(input
= vc) = vc)
declare output = vc with protect, noconstant("")
set output = BUILD(|<td>|, input, |</td>|)
return (output)
end ;td
;PowerChart
link
subroutine(chartlink(pid
= f8, eid = f8, label = vc) = vc)
declare output = vc with protect, noconstant("")
set output = BUILD(|<a href='javascript:APPLINK(0,
"Powerchart.exe", "/PERSONID=|
,pid
,| /ENCNTRID=|
,eid
,|")'>|
,label
,|</a>|
)
return (output)
end
;chartlink
;Builds a
link to a report
subroutine(reportlink(rpt
= vc, prompts = vc, mode = i2, label = vc) = vc)
declare output = vc with protect, noconstant("")
set output = BUILD(|<a href='javascript:CCLLINK("|
,rpt
,|","|
,prompts
,|",|
,mode
,|)'>|
,label
,|</a>|
)
return (output)
end
;reportlink
;Encounter
Detail Audit link
;scope={encntr,
person} identifier={encntr_id,
person_id}
subroutine(eda(scope=c6,
identifier=f8, rpt=vc, label=vc) = vc)
declare output = vc with protect, noconstant("")
declare prompts = vc with protect, noconstant("")
declare outdev = vc with protect, noconstant("")
declare id = vc with protect, noconstant("")
declare eid_type = vc with protect, noconstant("")
declare pid_type = vc with protect, noconstant("")
declare cat = vc with protect, noconstant("")
declare enc_rpt = vc with protect, noconstant("")
declare pat_rpt = vc with protect, noconstant("")
set outdev = |^MINE^|
set id = BUILD(|^|, CNVTSTRING(identifier), |^|)
set eid_type = |^.encntr_id^|
set pid_type = |^.person_id^|
IF(scope = "encntr")
set cat = BUILD(|^encounter^|)
set enc_rpt = BUILD(|^|, rpt, |^|)
set pat_rpt = |^^|
ELSEIF(scope = "person")
set cat = BUILD(|^patient^|)
set enc_rpt = |^^|
set pat_rpt = BUILD(|^|, rpt, |^|)
ENDIF
set prompts = BUILD(outdev,
        |,|,
id,
                |,|,
eid_type,        |,|,
pid_type,         |,|,
cat,
                |,|,
enc_rpt,         |,|,
pat_rpt)
set output =
reportlink("dev_rpt_encntr_detail_audit2:group1", prompts, 0, label)
return (output)
end ;eda
;call order
detail audit
subroutine(oda(order_id=f8,
rpt=vc, label=vc) = vc)
declare output = vc with protect, noconstant("")
declare prompts = vc with protect, noconstant("")
declare outdev = vc with protect, noconstant(|^MINE^|)
declare scope = vc with protect, noconstant(|^^|)
declare start_date = vc with protect, noconstant(|^^|)
declare end_date = vc with protect, noconstant(|^^|)
declare cat_type = f8 with protect, noconstant(0)
declare act_type = f8 with protect, noconstant(0)
declare sub_type = f8 with protect, noconstant(0)
declare rpt_enterprise = vc with protect, noconstant(|^^|)
declare rpt_facility = vc with protect, noconstant(|^^|)
declare rpt_orderable = vc with protect, noconstant(|^^|)
declare rpt_order = vc with protect, noconstant(|^^|)
declare facility = f8 with protect, noconstant(0)
declare orderable = f8 with protect, noconstant(0)
declare order_lookup = f8 with protect, noconstant(0)
set scope = |^Order^|
set rpt_order = BUILD(|^|, rpt, |^|)
set order_lookup = order_id
set prompts = BUILD(outdev,
                |,|,
scope,
                        |,|,
start_date,         |,|,
end_date,
                |,|,
"VALUE(0.0)",        |,|,
"VALUE(0.0)",        |,|,
"VALUE(0.0)",        |,|,
;cat_type,
                |,|,
;act_type,
                |,|,
;sub_type,
                |,|,
rpt_enterprise,        |,|,
rpt_facility,        |,|,
rpt_orderable,        |,|,
rpt_order,                |,|,
"VALUE(0.0)",        |,|,
"VALUE(0.0)",        |,|,
;facility,                |,|,
;orderable,                |,|,
order_lookup)
set output = reportlink("dev_rpt_order_detail_audit:group1",
prompts, 0, label)
return (output)
end ;oda
/**************************************************************
; Main
**************************************************************/
; If no
qualifications are met, values will default to 0
IF($search_by
= "event_cd")
                SET
target_event_cd = $event_result
ELSEIF($search_by
= "task_assay_cd")SET target_event_cd =
get_event_cd_from_dta($event_result)
ELSEIF($search_by
= "catalog_cd")         SET
target_catalog_cd = $order_result
ELSEIF($search_by
= "synonym_id")        SET
target_catalog_cd = $order_syn_result
ENDIF
; Build
record structures
CALL
build_fac_record(NULL)
IF($search_by
IN ("catalog_cd", "synonym_id"))
CALL build_ors(NULL)
ENDIF
/**************************************************************
; Output
**************************************************************/
SELECT ;INTO
$OUTDEV
IF($search_by
IN ("event_cd", "task_assay_cd") AND $rpt = "Detail
(max 5000 rows)")
;patient info
patient = p.name_full_formatted
,edipi = edipi.alias
,birth_dt_tm = DateBirthFormat(p.birth_dt_tm, p.birth_tz,
p.birth_prec_flag, "@SHORTDATETIME")
 ,age_at_event = CNVTAGE(p.birth_dt_tm,
ce.event_end_dt_tm, 0)
 ,sex =
UAR_GET_CODE_DISPLAY(p.sex_cd)
;encounter info
,fin = fin.alias
,encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
,ag.agency
,facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
,reg_dt_tm = DATETIMEZONEFORMAT(e.reg_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
,disch_dt_tm = DATETIMEZONEFORMAT(e.disch_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
;event info
,event = UAR_GET_CODE_DISPLAY(ce.event_cd)
,event_dt_tm = DATETIMEZONEFORMAT(ce.event_end_dt_tm, ce.event_end_tz,
"MM/DD/YYYY HH:MM;;q")
,result = ce.result_val
 ,result_units =
UAR_GET_CODE_DISPLAY(ce.result_units_cd)
 ,result_status =
UAR_GET_CODE_DISPLAY(ce.result_status_cd)
 ,result_source =
UAR_GET_CODE_DISPLAY(ce.source_cd)
 ,contrib_sys =
UAR_GET_CODE_DISPLAY(ce.contributor_system_cd)
 ,entry_mode =
UAR_GET_CODE_DISPLAY(ce.entry_mode_cd)
 ,event_class =
UAR_GET_CODE_DISPLAY(ce.event_class_cd)
 ,performing_prsnl =
perf_p.name_full_formatted
 ,verifying_prsnl =
veri_p.name_full_formatted
;identifiers
,ce.person_id
,ce.encntr_id
,ce.event_id
,ce.event_cd
,ce.task_assay_cd
FROM CLINICAL_EVENT ce
,ENCOUNTER e
,CUST_LOC_AGENCY_RELTN ag
,TIME_ZONE_R tz
,ENCNTR_ALIAS fin
,PERSON p
,PERSON_ALIAS edipi
,PRSNL perf_p
,PRSNL veri_p
PLAN ce WHERE 1=1
AND ce.event_cd = target_event_cd
;if you pass a string >60 characters, it won't return any results.
Using 40 to be safe
AND ce.event_tag =
PATSTRING(CONCAT(TRIM(SUBSTRING(1,40,$alpha_resp)),"*"))
AND ce.event_end_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND ce.result_status_cd NOT IN (28,29,30,31)
AND (ce.view_level = 1 OR ce.entry_mode_cd = 679378) ;working view
AND ce.valid_until_dt_tm > SYSDATE
JOIN e WHERE e.encntr_id = ce.encntr_id
AND EXPAND(fac_idx, 1, size(fac->facility, 5),
e.loc_facility_cd, fac->facility[fac_idx].facility_cd)
AND e.active_ind = 1
AND e.end_effective_dt_tm > SYSDATE
JOIN ag WHERE ag.location_cd = e.loc_facility_cd
JOIN tz WHERE tz.parent_entity_id = e.loc_facility_cd
AND tz.parent_entity_name = "LOCATION"
JOIN fin WHERE fin.encntr_id = e.encntr_id
AND fin.encntr_alias_type_cd = 1077
AND fin.active_ind = 1
AND fin.end_effective_dt_tm > SYSDATE
JOIN p WHERE p.person_id = ce.person_id
AND NOT EXISTS(        SELECT 1
FROM PERSON_INFO pi
WHERE pi.person_id = p.person_id
AND pi.info_sub_type_cd = 2678703703 ;Test Patient Identifier
AND pi.value_cd != 2678703509 ;"Not a Test Patient"
 )
AND p.active_ind = 1
AND p.end_effective_dt_tm > SYSDATE
JOIN edipi WHERE edipi.person_id = ce.person_id
AND edipi.person_alias_type_cd = 22
AND edipi.active_ind = 1
AND edipi.end_effective_dt_tm > SYSDATE
JOIN perf_p WHERE perf_p.person_id = ce.performed_prsnl_id
JOIN veri_p WHERE veri_p.person_id = ce.verified_prsnl_id
;ORDER BY CNVTUPPER(p.name_full_formatted), reg_dt_tm, event_dt_tm
;no order statement leads to more randomly scattered results
ELSEIF($search_by
IN ("event_cd", "task_assay_cd") AND $rpt = "Detail
(interactive)")
;patient info
patient = p.name_full_formatted
,edipi = edipi.alias
,birth_dt_tm = DateBirthFormat(p.birth_dt_tm, p.birth_tz,
p.birth_prec_flag, "@SHORTDATETIME")
 ,age_at_event = CNVTAGE(p.birth_dt_tm,
ce.event_end_dt_tm, 0)
 ,sex =
UAR_GET_CODE_DISPLAY(p.sex_cd)
;encounter info
,fin = fin.alias
,encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
,ag.agency
,facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
,reg_dt_tm = DATETIMEZONEFORMAT(e.reg_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
,disch_dt_tm = DATETIMEZONEFORMAT(e.disch_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
;event info
,event = UAR_GET_CODE_DISPLAY(ce.event_cd)
,event_dt_tm = DATETIMEZONEFORMAT(ce.event_end_dt_tm, ce.event_end_tz,
"MM/DD/YYYY HH:MM;;q")
,result = ce.result_val
 ,result_units =
UAR_GET_CODE_DISPLAY(ce.result_units_cd)
 ,result_status =
UAR_GET_CODE_DISPLAY(ce.result_status_cd)
 ,result_source =
UAR_GET_CODE_DISPLAY(ce.source_cd)
 ,contrib_sys =
UAR_GET_CODE_DISPLAY(ce.contributor_system_cd)
 ,entry_mode =
UAR_GET_CODE_DISPLAY(ce.entry_mode_cd)
 ,event_class =
UAR_GET_CODE_DISPLAY(ce.event_class_cd)
 ,performing_prsnl =
perf_p.name_full_formatted
 ,verifying_prsnl =
veri_p.name_full_formatted
;identifiers
,ce.person_id
,ce.encntr_id
,ce.event_id
,ce.event_cd
,ce.task_assay_cd
FROM CLINICAL_EVENT ce
,ENCOUNTER e
,CUST_LOC_AGENCY_RELTN ag
,TIME_ZONE_R tz
,ENCNTR_ALIAS fin
,PERSON p
,PERSON_ALIAS edipi
,PRSNL perf_p
,PRSNL veri_p
PLAN ce WHERE 1=1
AND ce.event_cd = target_event_cd
;if you pass a string >60 characters, it won't return any results.
Using 40 to be safe
AND ce.event_tag =
PATSTRING(CONCAT(TRIM(SUBSTRING(1,40,$alpha_resp)),"*"))
AND ce.event_end_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND ce.result_status_cd NOT IN (28,29,30,31)
AND (ce.view_level = 1 OR ce.entry_mode_cd = 679378) ;working view
AND ce.valid_until_dt_tm > SYSDATE
JOIN e WHERE e.encntr_id = ce.encntr_id
AND EXPAND(fac_idx, 1, size(fac->facility, 5),
e.loc_facility_cd, fac->facility[fac_idx].facility_cd)
AND e.active_ind = 1
AND e.end_effective_dt_tm > SYSDATE
JOIN ag WHERE ag.location_cd = e.loc_facility_cd
JOIN tz WHERE tz.parent_entity_id = e.loc_facility_cd
AND tz.parent_entity_name = "LOCATION"
JOIN fin WHERE fin.encntr_id = e.encntr_id
AND fin.encntr_alias_type_cd = 1077
AND fin.active_ind = 1
AND fin.end_effective_dt_tm > SYSDATE
JOIN p WHERE p.person_id = ce.person_id
AND NOT EXISTS(        SELECT 1
FROM PERSON_INFO pi
WHERE pi.person_id = p.person_id
AND pi.info_sub_type_cd = 2678703703 ;Test Patient Identifier
AND pi.value_cd != 2678703509 ;"Not a Test Patient"
 )
AND p.active_ind = 1
AND p.end_effective_dt_tm > SYSDATE
JOIN edipi WHERE edipi.person_id = ce.person_id
AND edipi.person_alias_type_cd = 22
AND edipi.active_ind = 1
AND edipi.end_effective_dt_tm > SYSDATE
JOIN perf_p WHERE perf_p.person_id = ce.performed_prsnl_id
JOIN veri_p WHERE veri_p.person_id = ce.verified_prsnl_id
;ORDER BY CNVTUPPER(p.name_full_formatted), reg_dt_tm, event_dt_tm
;no order statement leads to more randomly scattered results
 HEAD REPORT
i=0
;metadata
row+1 ^<html><head><meta content='CCLLINK'
name='discern'>^
row+1 ^<title>Case Finder - Interactive View</title>^
row+1 ^<style>^
row+1        ^html, body, table
{ font: normal 0.9em/1.5em Arial, Helvetica, sans-serif; }^
row+1        ^table { border:
1px #EEE; border-collapse: collapse; margin-left: 10px;}^
row+1        ^th { background:
#EEE; border: 1px solid #878787; padding-left: 5px; padding-right: 5px; }^
row+1        ^td { border: 1px
solid #878787; padding-left: 5px; padding-right: 5px; }^
row+1        ^a { color:
#24469C; }^
row+1 ^</style>^
row+1 ^</head>^
row+1 ^<body>^
DETAIL
i+=1
;table & header
row+1 ^<table border='1'>^
row+1 ^<tr>^
row+1        ^<th>&nbsp;</th>^
row+1         ^<th>Event
Date/Time</th>^
row+1
        ^<th>Event</th>^
row+1        ^<th>Result</th>^
row+1
        ^<th>Units</th>^
row+1
        ^<th>Status</th>^
row+1
        ^<th>Source</th>^
row+1
        ^<th>System</th>^
row+1         ^<th>Entry
Mode</th>^
row+1
        ^<th>Class</th>^
row+1
        ^<th>Performed
By</th>^
row+1
        ^<th>Verified
By</th>^
row+1 ^</tr>^
row+1 ^<tr>^ ;first row with result information
row+1        call
print(td(CNVTSTRING(i)))
row+1        call
print(td(event_dt_tm))
row+1        call
print(td(event))
row+1        call
print(td(result))
row+1        call
print(td(result_units))
row+1        call
print(td(result_status))
row+1        call
print(td(result_source))
row+1        call
print(td(contrib_sys))
row+1        call
print(td(entry_mode))
row+1        call
print(td(event_class))
row+1        call
print(td(performing_prsnl))
row+1        call
print(td(verifying_prsnl))
row+1 ^</tr>^
row+1 ^<tr></tr>^
row+1 ^<tr>^
row+1        ^<td
style='text-align: right;'>Encounter: </td>^
row+1        call
print(CONCAT(^<td>FIN: ^, chartlink(e.person_id, e.encntr_id, fin.alias),
^</td>^))
row+1        call
print(CONCAT(^<td>Type: ^, eda("encntr", e.encntr_id,
"Encounter History", encntr_type), ^</td>^))
row+1        call
print(td(eda("encntr", e.encntr_id, "Charges",
"Charges")))
row+1        call
print(td(eda("encntr", e.encntr_id, "Diagnoses",
"Diagnoses")))
row+1        call
print(td(eda("encntr", e.encntr_id, "Clinical Events",
"Events")))
row+1        call
print(td(eda("encntr", e.encntr_id, "Lab Results",
"Lab Results")))
row+1        call
print(td(eda("encntr", e.encntr_id, "Medication
Administration", "Med Admin")))
row+1        call
print(td(eda("encntr", e.encntr_id, "Documentation",
"Notes")))
row+1        call
print(td(eda("encntr", e.encntr_id, "Orders (all)",
"Orders")))
row+1        call
print(td(eda("encntr", e.encntr_id, "Vital Signs",
"Vital Signs")))
row+1        call
print(td(eda("encntr", e.encntr_id, "Registration (PIP)",
"Registration")))
row+1 ^</tr>^
row+1 ^<tr>^
row+1        ^<td
style='text-align: right;'>Patient: </td>^
row+1        call
print(td(eda("person", e.person_id, "Identity and
Demographics", patient)))
row+1        call
print(CONCAT(^<td>EDIPI: ^, edipi, ^</td>^))
row+1        call
print(td(eda("person", e.person_id, "Allergies",
"Allergies")))
row+1        call
print(td(eda("person", e.person_id, "Medication List",
"Medications")))
row+1        call
print(td(eda("person", e.person_id, "Problem List",
"Problem List")))
row+1        call
print(td(eda("person", e.person_id, "Procedures",
"Procedure History")))
row+1        call
print(td(eda("person", e.person_id, "Family History",
"Family History")))
row+1        call
print(td(eda("person", e.person_id, "Social History",
"Social History")))
row+1        call
print(td(eda("person", e.person_id, "Health Plans",
"Health Plans")))
row+1        call
print(td(eda("person", e.person_id, "Aliases", "Other
Identifiers")))
row+1        call
print(td(eda("person", e.person_id, "User Defined Fields",
"Other Info")))
row+1 ^</tr>^
row+1 ^</table>^
row+1 ^<p></p>^
FOOT REPORT
row+1 ^</body>^
row+1 ^</html>^
ELSEIF($search_by
IN ("event_cd", "task_assay_cd") AND $rpt = "Summary
by facility")
event = UAR_GET_CODE_DISPLAY(ce.event_cd)
,ag.agency
,facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,nbr_events = COUNT(DISTINCT ce.event_id)
,nbr_patients = COUNT(DISTINCT ce.person_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
,alpha_response = $alpha_resp
FROM CLINICAL_EVENT ce
,ENCOUNTER e
,CUST_LOC_AGENCY_RELTN ag
,PERSON p
PLAN ce WHERE 1=1
AND ce.event_cd = target_event_cd
;if you pass a string >60 characters, it won't return any results.
Using 40 to be safe
AND ce.event_tag =
PATSTRING(CONCAT(TRIM(SUBSTRING(1,40,$alpha_resp)),"*"))
AND ce.event_end_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND ce.result_status_cd NOT IN (28,29,30,31)
AND (ce.view_level = 1 OR ce.entry_mode_cd = 679378) ;working view
AND ce.valid_until_dt_tm > SYSDATE
JOIN e WHERE e.encntr_id = ce.encntr_id
AND EXPAND(fac_idx, 1, size(fac->facility, 5),
e.loc_facility_cd, fac->facility[fac_idx].facility_cd)
AND e.active_ind = 1
AND e.end_effective_dt_tm > SYSDATE
JOIN ag WHERE ag.location_cd = e.loc_facility_cd
JOIN p WHERE p.person_id = ce.person_id
AND NOT EXISTS(        SELECT 1
FROM PERSON_INFO pi
WHERE pi.person_id = p.person_id
AND pi.info_sub_type_cd = 2678703703 ;Test Patient Identifier
AND pi.value_cd != 2678703509 ;"Not a Test Patient"
 )
AND p.active_ind = 1
AND p.end_effective_dt_tm > SYSDATE
GROUP BY ce.event_cd, ag.agency, e.loc_facility_cd
ORDER BY event, ag.agency, facility
ELSEIF($search_by
IN ("catalog_cd", "synonym_id") AND $rpt = "Detail
(max 5000 rows)")
;patient info
patient = p.name_full_formatted
,edipi = edipi.alias
,birth_dt_tm = DateBirthFormat(p.birth_dt_tm, p.birth_tz,
p.birth_prec_flag, "@SHORTDATETIME")
 ,age_at_order = CNVTAGE(p.birth_dt_tm,
o.orig_order_dt_tm, 0)
 ,sex =
UAR_GET_CODE_DISPLAY(p.sex_cd)
;encounter info
,fin = fin.alias
,encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
,ag.agency
,facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
,reg_dt_tm = DATETIMEZONEFORMAT(e.reg_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
,disch_dt_tm = DATETIMEZONEFORMAT(e.disch_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
 ;order information
 ,orderable = oc.description
 ,order_dt_tm =
         DATETIMEZONEFORMAT(o.orig_order_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
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
SUBSTRING(1,255,replace_CRLF(o.order_detail_display_line))
 ,order_comment =
SUBSTRING(1,255,replace_CRLF(ocmt_txt.long_text))
 ,order_status =
UAR_GET_CODE_DISPLAY(o.order_status_cd)
 ,dept_status =
UAR_GET_CODE_DISPLAY(o.dept_status_cd)
 ,order_entered_by =
CNVTUPPER(order_enter.name_full_formatted)
 ,order_signed_by =
CNVTUPPER(order_sign.name_full_formatted)
 ,stop_type =
UAR_GET_CODE_DISPLAY(o.stop_type_cd)
 ,discontinue_type =
UAR_GET_CODE_DISPLAY(o.discontinue_type_cd)
 ,last_comms_type =
UAR_GET_CODE_DISPLAY(o.latest_communication_type_cd)
 ,contrib_sys =
UAR_GET_CODE_DISPLAY(o.contributor_system_cd)
 ,o.pathway_catalog_id
;identifiers
,o.person_id
,o.encntr_id
,o.originating_encntr_id
,o.order_id
,o.catalog_cd
 FROM ORDERS o
 ,(LEFT JOIN ORDER_ACTION oa ON
o.order_id = oa.order_id        AND
oa.action_type_cd = 2534)
 ,(LEFT JOIN PRSNL order_enter ON
oa.action_personnel_id = order_enter.person_id)
 ,(LEFT JOIN PRSNL order_sign ON
oa.order_provider_id = order_sign.person_id)
 ,(LEFT JOIN ORDER_COMMENT ocmt ON
ocmt.order_id = o.order_id)
 ,(LEFT JOIN LONG_TEXT ocmt_txt ON
ocmt_txt.long_text_id = ocmt.long_text_id
         AND ocmt_txt.active_ind
= 1)
,ORDER_CATALOG oc
,ENCOUNTER e
,CUST_LOC_AGENCY_RELTN ag
,TIME_ZONE_R tz
,ENCNTR_ALIAS fin
,PERSON p
,PERSON_ALIAS edipi
PLAN o WHERE EXPAND(ors_idx, 1, size(ors->list, 5), o.order_id,
ors->list[ors_idx].order_id)
JOIN oc WHERE oc.catalog_cd = o.catalog_cd
JOIN e WHERE EXPAND(ors_idx, 1, size(ors->list, 5), e.encntr_id,
ors->list[ors_idx].encntr_id)
JOIN ag WHERE ag.location_cd = e.loc_facility_cd
JOIN tz WHERE tz.parent_entity_id = e.loc_facility_cd
AND tz.parent_entity_name = "LOCATION"
 JOIN fin WHERE fin.encntr_id = e.encntr_id
         AND
fin.encntr_alias_type_cd = 1077 ;FIN
                 AND
fin.end_effective_dt_tm > SYSDATE
                 AND
fin.active_ind = 1
JOIN p WHERE p.person_id = o.person_id
AND p.end_effective_dt_tm > SYSDATE
AND p.active_ind = 1
JOIN edipi WHERE edipi.person_id = o.person_id
AND edipi.person_alias_type_cd = 22 ;EDIPI
AND edipi.end_effective_dt_tm > SYSDATE
AND edipi.active_ind = 1
 JOIN oa
 JOIN order_enter
 JOIN order_sign
 JOIN ocmt
 JOIN ocmt_txt
 ;no order statement leads to more randomly
scattered results
ELSEIF($search_by
IN ("catalog_cd", "synonym_id") AND $rpt = "Detail
(interactive)")
;patient info
patient = p.name_full_formatted
,edipi = edipi.alias
,fin = fin.alias
,encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
 ,orderable = oc.description
 ,order_dt_tm =
         DATETIMEZONEFORMAT(o.orig_order_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
 ,catalog_type =
UAR_GET_CODE_DISPLAY(oc.catalog_type_cd)
 ,activity_subtype =
UAR_GET_CODE_DISPLAY(oc.activity_subtype_cd)
 ,order_detail =
SUBSTRING(1,255,replace_CRLF(o.order_detail_display_line))
 ,order_status =
UAR_GET_CODE_DISPLAY(o.order_status_cd)
 ,order_entered_by =
CNVTUPPER(order_enter.name_full_formatted)
 ,order_signed_by =
CNVTUPPER(order_sign.name_full_formatted)
 ,last_comms_type =
UAR_GET_CODE_DISPLAY(o.latest_communication_type_cd)
 ,contrib_sys =
UAR_GET_CODE_DISPLAY(o.contributor_system_cd)
 FROM ORDERS o
 ,(LEFT JOIN ORDER_ACTION oa ON
o.order_id = oa.order_id        AND
oa.action_type_cd = 2534)
 ,(LEFT JOIN PRSNL order_enter ON
oa.action_personnel_id = order_enter.person_id)
 ,(LEFT JOIN PRSNL order_sign ON
oa.order_provider_id = order_sign.person_id)
,ORDER_CATALOG oc
,ENCOUNTER e
,TIME_ZONE_R tz
,ENCNTR_ALIAS fin
,PERSON p
,PERSON_ALIAS edipi
PLAN o WHERE EXPAND(ors_idx, 1, size(ors->list, 5), o.order_id,
ors->list[ors_idx].order_id)
JOIN oc WHERE oc.catalog_cd = o.catalog_cd
JOIN e WHERE EXPAND(ors_idx, 1, size(ors->list, 5), e.encntr_id,
ors->list[ors_idx].encntr_id)
JOIN tz WHERE tz.parent_entity_id = e.loc_facility_cd
AND tz.parent_entity_name = "LOCATION"
 JOIN fin WHERE fin.encntr_id = e.encntr_id
         AND
fin.encntr_alias_type_cd = 1077 ;FIN
                 AND
fin.end_effective_dt_tm > SYSDATE
                 AND
fin.active_ind = 1
JOIN p WHERE p.person_id = o.person_id
AND p.end_effective_dt_tm > SYSDATE
AND p.active_ind = 1
JOIN edipi WHERE edipi.person_id = o.person_id
AND edipi.person_alias_type_cd = 22 ;EDIPI
AND edipi.end_effective_dt_tm > SYSDATE
AND edipi.active_ind = 1
 JOIN oa
 JOIN order_enter
 JOIN order_sign
 ;no order statement leads to more randomly
scattered results
 HEAD REPORT
i=0
;metadata
row+1 ^<html><head><meta content='CCLLINK'
name='discern'>^
row+1 ^<title>Case Finder - Interactive View</title>^
row+1 ^<style>^
row+1        ^html, body, table
{ font: normal 0.9em/1.5em Arial, Helvetica, sans-serif; }^
row+1        ^table { border:
1px #EEE; border-collapse: collapse; margin-left: 10px;}^
row+1        ^th { background:
#EEE; border: 1px solid #878787; padding-left: 5px; padding-right: 5px; }^
row+1        ^td { border: 1px
solid #878787; padding-left: 5px; padding-right: 5px; }^
row+1        ^a { color:
#24469C; }^
row+1 ^</style>^
row+1 ^</head>^
row+1 ^<body>^
DETAIL
i+=1
;table & header
row+1 ^<table border='1'>^
row+1 ^<tr>^
row+1        ^<th>&nbsp;</th>^
row+1         ^<th>Order
Date/Time</th>^
row+1
        ^<th>Orderable</th>^
row+1        ^<th>Catalog
Type</th>^
row+1
        ^<th>Activity
Subtype</th>^
row+1
        ^<th>Status</th>^
row+1         ^<th>Order
Detail</th>^
row+1
        ^<th>Results</th>^
row+1
        ^<th>System</th>^
row+1
        ^<th>Communication
Type</th>^
row+1
        ^<th>Entered
By</th>^
row+1         ^<th>Signed
By</th>^
row+1 ^</tr>^
row+1 ^<tr>^ ;first row with result information
row+1        call
print(td(CNVTSTRING(i)))
row+1        call
print(td(order_dt_tm))
row+1        call
print(td(orderable))
row+1        call
print(td(catalog_type))
row+1        call
print(td(activity_subtype))
row+1        call
print(td(order_status))
row+1        call
print(td(order_detail))
row+1        call
print(td(oda(o.order_id, "Order Info (laboratory view)", "View
Results")))
row+1        call
print(td(contrib_sys))
row+1        call
print(td(last_comms_type))
row+1        call
print(td(order_entered_by))
row+1        call
print(td(order_signed_by))
row+1 ^</tr>^
row+1 ^<tr></tr>^ ;spacer
row+1 ^<tr>^
row+1        ^<td
style='text-align: right;'>Encounter: </td>^
row+1        call
print(CONCAT(^<td>FIN: ^, chartlink(e.person_id, e.encntr_id, fin.alias),
^</td>^))
row+1        call
print(CONCAT(^<td>Type: ^, eda("encntr", e.encntr_id,
"Encounter History", encntr_type), ^</td>^))
row+1        call
print(td(eda("encntr", e.encntr_id, "Charges",
"Charges")))
row+1        call
print(td(eda("encntr", e.encntr_id, "Diagnoses",
"Diagnoses")))
row+1        call
print(td(eda("encntr", e.encntr_id, "Clinical Events",
"Events")))
row+1        call
print(td(eda("encntr", e.encntr_id, "Lab Results",
"Lab Results")))
row+1        call
print(td(eda("encntr", e.encntr_id, "Medication
Administration", "Med Admin")))
row+1        call
print(td(eda("encntr", e.encntr_id, "Documentation",
"Notes")))
row+1        call
print(td(eda("encntr", e.encntr_id, "Orders (all)",
"Orders")))
row+1        call
print(td(eda("encntr", e.encntr_id, "Vital Signs",
"Vital Signs")))
row+1        call
print(td(eda("encntr", e.encntr_id, "Registration (PIP)",
"Registration")))
row+1 ^</tr>^
row+1 ^<tr>^
row+1        ^<td
style='text-align: right;'>Patient: </td>^
row+1        call
print(td(eda("person", e.person_id, "Identity and
Demographics", patient)))
row+1        call
print(CONCAT(^<td>EDIPI: ^, edipi, ^</td>^))
row+1        call
print(td(eda("person", e.person_id, "Allergies",
"Allergies")))
row+1        call
print(td(eda("person", e.person_id, "Medication List",
"Medications")))
row+1        call
print(td(eda("person", e.person_id, "Problem List",
"Problem List")))
row+1        call
print(td(eda("person", e.person_id, "Procedures",
"Procedure History")))
row+1        call
print(td(eda("person", e.person_id, "Family History",
"Family History")))
row+1        call
print(td(eda("person", e.person_id, "Social History",
"Social History")))
row+1        call
print(td(eda("person", e.person_id, "Health Plans",
"Health Plans")))
row+1        call
print(td(eda("person", e.person_id, "Aliases", "Other
Identifiers")))
row+1        call
print(td(eda("person", e.person_id, "User Defined Fields",
"Other Info")))
row+1 ^</tr>^
row+1 ^</table>^
row+1 ^<p></p>^
FOOT REPORT
row+1 ^</body>^
row+1 ^</html>^
ELSEIF($search_by
IN ("catalog_cd", "synonym_id") AND $rpt = "Summary by
facility")
orderable = oc.description
,ag.agency
,facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,nbr_orders = COUNT(DISTINCT o.order_id)
,nbr_patients = COUNT(DISTINCT o.person_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
FROM ORDERS o
,ORDER_CATALOG oc
,ENCOUNTER e
,(LEFT JOIN CUST_LOC_AGENCY_RELTN ag ON ag.location_cd =
e.loc_facility_cd)
PLAN o WHERE EXPAND(ors_idx, 1, size(ors->list, 5), o.order_id,
ors->list[ors_idx].order_id)
JOIN oc WHERE oc.catalog_cd = o.catalog_cd AND oc.active_ind = 1
JOIN e WHERE EXPAND(ors_idx, 1, size(ors->list, 5), e.encntr_id,
ors->list[ors_idx].encntr_id)
JOIN ag
GROUP BY oc.description, ag.agency, e.loc_facility_cd
ORDER BY orderable, ag.agency,
facility
ELSE
error = "No report selected in the Output prompt"
ENDIF
INTO $OUTDEV
error = "Invalid prompt selections"
WITH
NOCOUNTER, SEPARATOR=" ", FORMAT, CHECK, TIME=600
,EXPAND=2, MAXREC=5000, MAXCOL=1000
end
go
