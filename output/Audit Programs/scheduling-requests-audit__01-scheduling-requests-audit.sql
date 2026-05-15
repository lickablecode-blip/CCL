/*
 * Source page  : Scheduling Requests Audit
 * Source file  : output/scheduling-requests-audit.md
 * Anchor       : (top of page)
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 718
 *
 * Context (preceding paragraph):
 *   Exported: 2/17/26
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

drop program
dev_rpt_sch_req_list go
create
program dev_rpt_sch_req_list
/******************************************************************************
 REPORT NAME:
        Scheduling Requests Audit
 PROGRAM:                1fed_rpt_sch_req_list.prg
 DEV
PROGRAM:        dev_rpt_sch_req_list.prg
 DEVELOPER:        David Alt
 PUBLISHED:        8/9/24
 SNAPSHOT:                12/18/25
 LOGICAL
PATH:        cust_script
 NODE:                        <default>
 PURPOSE/DESCRIPTION: Provides summary and detail reports for
scheduling request lists. Defaults to the
                                                 unknown
queue, but not limited to it.
Scheduling request lists need regular oversight to ensure that
scheduling requests are acted on and not diverted
to the unknown queue. "Missed" scheduling requests may
indicate delayed or missed patient care leading to harm.
This is a recognized national patient safety issue for both the VA and
DoD.
Additionally, once scheduling request lists reach a certain size, they
will stop loading and can crash the
front-end application. This provides a safe output for neglected
queues.
# What's wrong with the existing "Unknown Queue" report?
1)  Existing unknown queue report can only look at the unknown
queue and "VA Needs Scheduling Location" lists -
however, there are thousands of other scheduling request lists that may
be unmonitored.
2)  Existing unknown queue report places too much emphasis on
orders, rather than scheduling requests.
Output lacks sufficient detail.
3)  DoD IG investigation highlighting inability for enterprise or
sites to effectively monitor these lists -
need a flexible tool
 TARGET AUDIENCE: Schedulers; patient safety managers
MOD        DATE                DEVELOPER                COMMENT
---        --/--/--        ---------                ----------------------------
001        08/09/24        David
Alt                Initial
validation published (DHAINC02781882/Jazz 732927)
002        09/06/24        David
Alt                Rewrite
003        11/17/25        David
Alt                Expanded
"requested_location" oe_field_id list
TODO
Origin of some orders still unknown, but added order application
BUGS
******************************************************************************/
prompt
"Output to File/Printer/MINE" = "MINE" ;* Enter or select the
printer or file name to send this report to.
, "Queue Search" = "*"
, "Queue" = VALUE( 1390900.00)
, "Type" = 4517
, "Status" = VALUE(Pending, 653550.00)
, "Request Start" = "SYSDATE"
, "Request End" = "SYSDATE"
, "Origin" = "ANY"
, "Include results where origin can't be determined" = 1
, "Ordering Facility" = VALUE(0.0)
, "Report" = ""
with OUTDEV,
search, queue, action, status, start_date, end_date, origin, unknown_ind,
facility, rpt
/**************************************************************
; Global
Declarations
**************************************************************/
declare
status_op = c2 with protect ;used for "Any" prompt
declare
fac_idx = i4 with protect, noconstant(0) ;for expanding fac record
/**************************************************************
; Record
Structures
**************************************************************/
free record
fac
record fac (
1 list[*]
2 location_cd = f8
) with
protect
free record
req
record req (
1 list[*]
;queue info
2 sch_object_id = f8
2 request_list = c90
;request info
2 sch_entry_id = f8
2 requested_action = c40
;2 request_type = c40 ;always
"appointment"
2 appt_type = c40
2 request_status = c40
2 request_made_dt_tm = dq8 ;not local time
2 earliest_dt_tm = dq8
2 latest_dt_tm = dq8
;order info
2 order_id = f8
2 catalog_cd = f8
2 oe_format_id = f8
2 orderable = c100
2 order_dt_tm = dq8
2 order_status = c40
2 order_activity_type = c40
2 order_catalog_type = c40
2 requested_location_oef = c40
2 requested_location_val = c40
2 order_provider = c100
2 order_entered_by = c100
2 order_display_line = c255
2 order_comment = c255
2 order_application = c100
;patient info
2 person_id = f8
2 patient = c100
2 edipi = c10
;2 mrn = c14
;2 sex = c40
;2 dob = c10
;originating encntr info
2 origin_unknown_ind = i2
2 encntr_id = f8
2 encntr_active_ind = c3
2 fin = c20
2 agency = c4
2 facility = c40
2 facility_cd = f8
2 nurse_unit = c40
2 med_service = c40
2 encntr_type = c40
2 time_zone = c100
) with
protect ;end req
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
; Populate
the list of locations from the prompt
subroutine
(build_fac_record(input = NULL) = NULL)
;declare i = i4 with protect, noconstant(0)
IF($facility = 0.0) ;"Any"
IF($origin = "ANY")
SELECT INTO "NL:"
FROM CUST_LOC_AGENCY_RELTN ag
,CODE_VALUE cv
PLAN ag WHERE ag.location_cd NOT IN (6295542077, 1275479033) ;DoD
privileged locations
JOIN cv WHERE cv.code_value = ag.location_cd
AND cv.display_key != "ZZ*"
HEAD REPORT
i = 0
DETAIL
i += 1
CALL ALTERLIST(fac->list, i)
fac->list[i].location_cd = ag.location_cd
WITH NOCOUNTER
ELSEIF($origin = "DOD")
SELECT INTO "NL:"
FROM CUST_LOC_AGENCY_RELTN ag
,CODE_VALUE cv
PLAN ag WHERE ag.agency = "DOD"
AND ag.location_cd NOT IN (6295542077, 1275479033) ;DoD privileged
locations
JOIN cv WHERE cv.code_value = ag.location_cd
AND cv.display_key != "ZZ*"
HEAD REPORT
i = 0
DETAIL
i += 1
CALL ALTERLIST(fac->list, i)
fac->list[i].location_cd = ag.location_cd
WITH NOCOUNTER
ELSEIF($origin = "FHCC")
SELECT INTO "NL:"
FROM CUST_LOC_AGENCY_RELTN ag
,CODE_VALUE cv
 PLAN ag WHERE ag.location_cd
IN (
 10148779387,10148779287,10148779337,
 353977013, 5645665891,
9812006769,
 5645666273, 7501619405,
9812032145,
 445154639, 445154649, 445154659,
 9811946053, 8650312629, 8650312837,
 8650312683, 8650312887,
8650312735,
 8650312937, 8650312987,
8650312785,
 8650313037, 8650313087)
JOIN cv WHERE cv.code_value = ag.location_cd
AND cv.display_key != "ZZ*"
HEAD REPORT
i = 0
DETAIL
i += 1
CALL ALTERLIST(fac->list, i)
fac->list[i].location_cd = ag.location_cd
WITH
NOCOUNTER
ELSEIF($origin = "USCG")
SELECT INTO "NL:"
FROM CUST_LOC_AGENCY_RELTN ag
,CODE_VALUE cv
PLAN ag WHERE ag.agency = "USCG"
JOIN cv WHERE cv.code_value = ag.location_cd
AND cv.display_key != "ZZ*"
HEAD REPORT
i = 0
DETAIL
i += 1
CALL ALTERLIST(fac->list, i)
fac->list[i].location_cd = ag.location_cd
WITH NOCOUNTER
ELSEIF($origin = "VA")
SELECT INTO "NL:"
FROM CUST_LOC_AGENCY_RELTN ag
,CODE_VALUE cv
PLAN ag WHERE ag.agency = "VA"
JOIN cv WHERE cv.code_value = ag.location_cd
AND cv.display_key != "ZZ*"
HEAD REPORT
i = 0
DETAIL
i += 1
CALL ALTERLIST(fac->list, i)
fac->list[i].location_cd = ag.location_cd
WITH NOCOUNTER
ENDIF
ELSE ;specific facilities were selected
SELECT INTO "NL:"
FROM CUST_LOC_AGENCY_RELTN ag
PLAN ag WHERE ag.location_cd = $facility
HEAD REPORT
i = 0
DETAIL
i += 1
CALL ALTERLIST(fac->list, i)
fac->list[i].location_cd = ag.location_cd
WITH NOCOUNTER
ENDIF
end
;build_fac_record
subroutine
(get_queue_requests(input=NULL) = NULL)
SELECT INTO "NL:"
FROM SCH_OBJECT so
,SCH_ENTRY se
,(LEFT JOIN SCH_EVENT_ATTACH sea ON sea.sch_event_id = se.sch_event_id
AND sea.end_effective_dt_tm > SYSDATE
AND sea.version_dt_tm > SYSDATE
AND sea.active_ind = 1)
,(LEFT JOIN ORDERS o ON o.order_id = sea.order_id
AND o.catalog_type_cd != 380752871 ;CSS Interface Order
AND o.active_ind = 1)
,(LEFT JOIN ORDER_DETAIL od ON od.order_id = o.order_id
AND od.oe_field_id IN (
; CS 220 Location
24506968073        ;Scheduling
Location
; CS 100173 Scheduling Locations - Non-Radiology
,37024091        ;Scheduling
Locations - Non Radiology
; CS 100261
,301272197        ;OMS
Scheduling Location
; CS 100301 Scheduling Location
,25786615        ;Scheduling
Location
; CS 100319 Scheduling VA Locations
,336112513        ;Acute
Scheduling VA Location
; CS 100414 DOD Clinic Follow Up Locations
,1007380489        ;DOD Clinic
Follow Up Location
; CS 100669
,114511571        ;MTF
Scheduling Location
; CS 100735
,128697651        ;Infusion
Scheduling Location
; CS 100820 Clinic Procedure 20
         ,137811739        ;procedure
scheduling location 20min
; CS 100860 Clinic Procedure 60
,137812971        ;procedure
scheduling location 60min
; CS 100990 Card Procedure Scheduling Location
,162596819        ;Card
Procedure Scheduling Location
,471414715        ;Card
Procedure Scheduling Location
; CS 100993
,162597191        ;Pulm
Procedure Scheduling Location
; CS 100999        VA
Scheduling Location
,352109491        ;VA
Scheduling Location
,361104561        ;Rad Order
Location
; CS 102124        Infusion
Scheduling Location
,162769267        ;Scheduling
Location - Infusion
)
;AND od.oe_field_meaning_id = 9000 ;unnecessary b/c using unique
identifiers
)
,(LEFT JOIN ORDER_COMMENT ocmt ON ocmt.order_id = o.order_id)
,(LEFT JOIN LONG_TEXT ocmt_txt ON ocmt_txt.long_text_id =
ocmt.long_text_id
AND ocmt_txt.active_ind =
1)
,(LEFT JOIN ORDER_ENTRY_FIELDS oef ON oef.oe_field_id =
od.oe_field_id)
,(LEFT JOIN ORDER_ACTION oa ON oa.order_id = o.order_id
AND oa.action_type_cd = 2534) ;ordered
,(LEFT JOIN APPLICATION app ON app.application_number =
oa.order_app_nbr
AND app.active_ind = 1)
,(LEFT JOIN PRSNL order_prov ON order_prov.person_id =
oa.order_provider_id
AND order_prov.active_ind = 1)
,(LEFT JOIN PRSNL order_entry ON order_entry.person_id =
oa.action_personnel_id
AND order_entry.active_ind =
1)
,PERSON p
,PERSON_ALIAS edipi
;,PERSON_ALIAS mrn
PLAN so WHERE so.sch_object_id = $queue
AND so.end_effective_dt_tm > SYSDATE
AND so.version_dt_tm > SYSDATE
AND so.active_ind = 1
JOIN se WHERE se.queue_id = so.sch_object_id
AND OPERATOR(se.entry_state_cd, status_op, $status) ;pending, canceled,
etc.
AND se.req_action_cd = $action ;book or reschedule
AND se.request_made_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND se.end_effective_dt_tm > SYSDATE
AND se.version_dt_tm > SYSDATE
AND se.active_ind = 1
JOIN p WHERE p.person_id = se.person_id
; remove test patients
AND NOT EXISTS(
SELECT 1
FROM PERSON_INFO pi
WHERE pi.person_id = p.person_id
AND pi.info_sub_type_cd = 2678703703 ;test patient identifier
AND pi.value_cd != 2678703509 ;not a test patient
AND pi.active_ind = 1
)
AND p.active_ind = 1
JOIN edipi WHERE edipi.person_id = p.person_id
AND edipi.person_alias_type_cd = 22 ;EDIPI
AND edipi.end_effective_dt_tm > SYSDATE
AND edipi.active_ind = 1
;        JOIN
mrn WHERE mrn.person_id = p.person_id
;                AND
mrn.person_alias_type_cd = 10 ;MRN
;                AND
mrn.end_effective_dt_tm > SYSDATE
;                AND
mrn.active_ind = 1
JOIN sea
JOIN o
JOIN oa
JOIN order_prov
JOIN order_entry
JOIN app
JOIN od
JOIN ocmt
JOIN ocmt_txt
JOIN oef
ORDER BY se.sch_entry_id, od.action_sequence, od.detail_sequence
HEAD REPORT
i = 0
HEAD se.sch_entry_id
i += 1
CALL ALTERLIST(req->list, i)
action_seq = 0
detail_seq = 0
;queue info
req->list[i].sch_object_id = so.sch_object_id
req->list[i].request_list = so.description
;request info
req->list[i].sch_entry_id = se.sch_entry_id
req->list[i].requested_action =
UAR_GET_CODE_DISPLAY(se.req_action_cd)
;req->list[i].request_type = UAR_GET_CODE_DISPLAY(se.entry_type_cd)
;always "appointment"
req->list[i].appt_type = UAR_GET_CODE_DISPLAY(se.appt_type_cd)
req->list[i].request_status =
UAR_GET_CODE_DISPLAY(se.entry_state_cd)
req->list[i].request_made_dt_tm = se.request_made_dt_tm
req->list[i].earliest_dt_tm = se.earliest_dt_tm
req->list[i].latest_dt_tm = se.latest_dt_tm
;                req->list[i].request_made_dt_tm_conv2
= DATETIMEZONEFORMAT(req->list[d.seq].request_made_dt_tm_conv
;                ,DATETIMEZONEBYNAME(req->list[d.seq].time_zone),
"MM/DD/YYYY HH:MM;;q")
;order info
req->list[i].order_id = o.order_id
req->list[i].catalog_cd = o.catalog_cd
req->list[i].oe_format_id = o.oe_format_id
req->list[i].orderable = sea.description
req->list[i].order_dt_tm = o.orig_order_dt_tm ;needs time zone
conversion
req->list[i].order_status = UAR_GET_CODE_DISPLAY(o.order_status_cd)
req->list[i].order_activity_type =
UAR_GET_CODE_DISPLAY(o.activity_type_cd)
req->list[i].order_catalog_type =
UAR_GET_CODE_DISPLAY(o.catalog_type_cd)
req->list[i].order_provider = order_prov.name_full_formatted
req->list[i].order_entered_by = order_entry.name_full_formatted
req->list[i].order_display_line =
replace_CRLF(o.clinical_display_line)
req->list[i].order_comment =
replace_CRLF(SUBSTRING(1,255,ocmt_txt.long_text))
req->list[i].order_application = app.description
;patient info
req->list[i].patient = CNVTUPPER(p.name_full_formatted)
req->list[i].edipi = edipi.alias
;req->list[i].mrn = mrn.alias
;req->list[i].sex = UAR_GET_CODE_DISPLAY(p.sex_cd)
;req->list[i].dob = DateBirthFormat(p.birth_dt_tm, p.birth_tz,
p.birth_prec_flag, "@SHORTDATETIME")
;pre-populate that location is unknown, then overwrite
later
req->list[i].origin_unknown_ind = 1
req->list[i].facility_cd = 0.0
req->list[i].encntr_active_ind = "n/a"
req->list[i].encntr_type = "n/a"
req->list[i].fin = "n/a"
req->list[i].encntr_id = EVALUATE2(
IF(o.originating_encntr_id != 0) o.originating_encntr_id
ELSE o.encntr_id
ENDIF)
HEAD od.action_sequence
action_seq += 1
HEAD od.detail_sequence
detail_seq += 1
;only keep last populated value
req->list[i].requested_location_oef = oef.description
req->list[i].requested_location_val =
UAR_GET_CODE_DISPLAY(od.oe_field_value)
;look for agency origin in the OEF. This is an assumption that might
not work for shared sites (FHCC)
IF((CNVTUPPER(oef.description) = "*DOD*" OR
CNVTUPPER(UAR_GET_CODE_DISPLAY(od.oe_field_value)) = "*DOD*"))
req->list[i].agency = "DOD"
ELSEIF((CNVTUPPER(oef.description) = "*VA*" OR
CNVTUPPER(UAR_GET_CODE_DISPLAY(od.oe_field_value)) = "*VA*"))
req->list[i].agency = "VA"
ENDIF
WITH NOCOUNTER
end
;get_queue_requests
subroutine(add_encntr_info(input=NULL)
= NULL)
SELECT INTO "NL:"
FROM (DUMMYT d WITH seq = value(size(req->list, 5)))
,ENCOUNTER e
,(LEFT JOIN CUST_LOC_AGENCY_RELTN ag ON ag.location_cd =
e.loc_facility_cd)
,ENCNTR_ALIAS fin
,TIME_ZONE_R tz
PLAN d
JOIN e WHERE e.encntr_id = req->list[d.seq].encntr_id
JOIN fin WHERE fin.encntr_id = e.encntr_id
AND fin.encntr_alias_type_cd = 1077 ;fin
JOIN tz WHERE tz.parent_entity_id = e.loc_facility_cd
AND tz.parent_entity_name = "LOCATION"
JOIN ag
ORDER BY d.seq
DETAIL
;TODO: needs if statement to find non-facility encntrs like LPE,
history, etc.
req->list[d.seq].origin_unknown_ind = 0
req->list[d.seq].encntr_active_ind = EVALUATE(e.active_ind, 0,
"no", 1, "yes")
IF(e.encntr_type_cd NOT IN (20058643, 19962609)) ;history, LPE
req->list[d.seq].agency = ag.agency
req->list[d.seq].facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
req->list[d.seq].facility_cd = e.loc_facility_cd
req->list[d.seq].nurse_unit =
UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
ENDIF
req->list[d.seq].med_service =
UAR_GET_CODE_DISPLAY(e.med_service_cd)
req->list[d.seq].encntr_type =
UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
req->list[d.seq].fin = fin.alias
req->list[d.seq].time_zone = tz.time_zone
WITH NOCOUNTER
end
;add_encntr_info
/**************************************************************
; Main
**************************************************************/
; Build input
operators
; request
status
IF(substring(1,1,reflect(parameter(5,0)))
= "L") ;multiple selections
SET status_op = "IN"
ELSEIF(parameter(5,1)
= 0.0); "Any" selected
SET status_op = ">="
ELSE ;single
value selected
SET status_op = "="
ENDIF
DECLARE
loc_parser = vc
IF
($unknown_ind = 1) ;user wants to see unknown
 SET loc_parser = "1 = 1"
ELSE
 SET loc_parser =
"req->list[d.seq].origin_unknown_ind = 0"
ENDIF
; Build
record structures IF valid prompts
IF (
reflect($queue) != "I4"
AND                ;queue
checked
reflect($status) != "I4"
AND        ;status checked
reflect($facility) !=
"I4"                ;facility
checked
)
CALL build_fac_record(NULL)
CALL get_queue_requests(NULL)
CALL add_encntr_info(NULL)
ENDIF
/**************************************************************
; Output
**************************************************************/
SELECT
; Error
trapping
IF(
reflect($queue) = "I4" OR
reflect($status) = "I4" OR
reflect($facility) = "I4"
)
error = "Invalid prompt entries"
,queue = IF(reflect($queue) = "I4") "missing" ELSE
"ok" ENDIF
,status = IF(reflect($status) = "I4") "missing"
ELSE "ok" ENDIF
,facility = IF(reflect($facility) = "I4") "missing"
ELSE "ok" ENDIF
ELSEIF(value(size(req->list,
5)) = 0) ;no results
info = "No results"
ELSEIF($rpt =
"Detail (scheduler view)")
request_list = req->list[d.seq].request_list
;patient info
,patient = req->list[d.seq].patient
,edipi = req->list[d.seq].edipi
;,mrn = req->list[d.seq].mrn
;        ,sex
= req->list[d.seq].sex
;        ,birth_date
= req->list[d.seq].dob
;request info
,action = req->list[d.seq].requested_action
,appt_type = req->list[d.seq].appt_type
,requested_location = req->list[d.seq].requested_location_val
,earliest_dt_tm = DATETIMEZONEFORMAT(req->list[d.seq].earliest_dt_tm
,DATETIMEZONEBYNAME(req->list[d.seq].time_zone),
"MM/DD/YYYY;;d")
,latest_dt_tm = DATETIMEZONEFORMAT(req->list[d.seq].latest_dt_tm
,DATETIMEZONEBYNAME(req->list[d.seq].time_zone),
"MM/DD/YYYY;;d")
,request_made_dt_tm =
DATETIMEZONEFORMAT(req->list[d.seq].request_made_dt_tm
,DATETIMEZONEBYNAME(req->list[d.seq].time_zone), "MM/DD/YYYY
HH:MM;;q")
,request_status = req->list[d.seq].request_status
,time_on_list =
FORMAT(DATETIMEDIFF(SYSDATE,req->list[d.seq].request_made_dt_tm,7),"####d.##h.##m")
,orderable = req->list[d.seq].orderable
,order_details = req->list[d.seq].order_display_line
,order_comment = req->list[d.seq].order_comment
,order_provider = req->list[d.seq].order_provider
,encntr_tz = req->list[d.seq].time_zone
FROM (DUMMYT d WITH seq = value(size(req->list, 5)))
PLAN d WHERE parser(loc_parser) ;filters out unknown locations, if
selected
AND (req->list[d.seq].facility_cd = 0 OR
         
EXPAND(fac_idx, 1, size(fac->list, 5),
req->list[d.seq].facility_cd,
fac->list[fac_idx].location_cd)
)
ORDER BY patient, request_made_dt_tm, earliest_dt_tm
ELSEIF($rpt =
"Detail (auditor view)")
request_list = req->list[d.seq].request_list
;patient info
,patient = req->list[d.seq].patient
,edipi = req->list[d.seq].edipi
;,mrn = req->list[d.seq].mrn
;primary request info
,requested_action = req->list[d.seq].requested_action
,requested_appt_type = req->list[d.seq].appt_type
,requested_location = req->list[d.seq].requested_location_val
,request_made_dt_tm =
DATETIMEZONEFORMAT(req->list[d.seq].request_made_dt_tm
,DATETIMEZONEBYNAME(req->list[d.seq].time_zone), "MM/DD/YYYY
HH:MM;;q")
,earliest_dt_tm = DATETIMEZONEFORMAT(req->list[d.seq].earliest_dt_tm
,DATETIMEZONEBYNAME(req->list[d.seq].time_zone),
"MM/DD/YYYY;;d")
,latest_dt_tm = DATETIMEZONEFORMAT(req->list[d.seq].latest_dt_tm
,DATETIMEZONEBYNAME(req->list[d.seq].time_zone),
"MM/DD/YYYY;;d")
,request_status = req->list[d.seq].request_status
,time_on_list =
FORMAT(DATETIMEDIFF(SYSDATE,req->list[d.seq].request_made_dt_tm,7),"####d.##h.##m")
;order info
,orderable = req->list[d.seq].orderable
,order_provider = req->list[d.seq].order_provider
,order_detail = req->list[d.seq].order_display_line
,order_comment = req->list[d.seq].order_comment
,order_catalog_type = req->list[d.seq].order_catalog_type
,order_activity_type = req->list[d.seq].order_activity_type
,order_status = req->list[d.seq].order_status
,oef_location_field = req->list[d.seq].requested_location_oef
,order_application =
req->list[d.seq].order_application
;encounter info
,fin =
req->list[d.seq].fin
,ordering_agency = req->list[d.seq].agency
,ordering_facility = req->list[d.seq].facility
,ordering_nurse_unit = req->list[d.seq].nurse_unit
,ordering_med_service = req->list[d.seq].med_service
,encntr_type = req->list[d.seq].encntr_type
,encntr_active =
req->list[d.seq].encntr_active_ind
,encntr_tz = req->list[d.seq].time_zone
;identifiers
,queue_id = CNVTSTRING(req->list[d.seq].sch_object_id)
,sch_entry_id = CNVTSTRING(req->list[d.seq].sch_entry_id)
,order_id = CNVTSTRING(req->list[d.seq].order_id)
,oe_format_id = CNVTSTRING(req->list[d.seq].oe_format_id)
,encntr_id = CNVTSTRING(req->list[d.seq].encntr_id)
FROM (DUMMYT d WITH seq = value(size(req->list, 5)))
PLAN d WHERE parser(loc_parser) ;filters out unknown locations, if
selected
AND (req->list[d.seq].facility_cd = 0 OR
         
EXPAND(fac_idx, 1, size(fac->list, 5),
req->list[d.seq].facility_cd,
fac->list[fac_idx].location_cd)
)
ORDER BY patient, request_made_dt_tm, earliest_dt_tm
;removed from
prompt
ELSEIF($rpt =
"Counts")
error = "not implemented"
ENDIF
INTO $OUTDEV
error = "Invalid prompt selections"
WITH
NOCOUNTER, SEPARATOR=" ", FORMAT, CHECK, TIME=180, EXPAND=2
end
go
