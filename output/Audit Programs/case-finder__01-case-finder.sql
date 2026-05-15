/*
 * Source page  : Case Finder
 * Source file  : output/case-finder.md
 * Anchor       : (top of page)
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 3156
 *
 * Context (preceding paragraph):
 *   Exported: 3/11/26
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

drop program
dev_rpt_cf_master go
create
program dev_rpt_cf_master
/******************************************************************************
 REPORT NAME:
        Case Finder
 PROGRAM:                1fed_rpt_cf_master.prg
 DEV
PROGRAM:        dev_rpt_cf_master.prg
 DEVELOPER:        David Alt
 PUBLISHED:        2/24/26
 SNAPSHOT:
        2/24/26
 LOGICAL
PATH:        cust_script
 NODE:                        <default>
 PURPOSE/DESCRIPTION:        Finds
example encounters where the searched event occurred
 TARGET
AUDIENCE:        Developers, solution
owners, research
 DEPENDENCIES:        dev_rpt_encntr_detail_audit2.prg
                                 -->
dev_rpt_blob_output.prg
                                 dev_rpt_order_detail_audit.prg
 CAVEATS:
MOD        DATE                DEVELOPER        COMMENT
---        --/--/--        ---------        ----------------------------
001        12/17/25        David
Alt        File creation
002        01/05/26        David
Alt        Added Alerts (Alert list)
003        01/07/26        David
Alt        Added Alerts (Summary,
Detail)
004        01/08/26        David
ALt        Added Alerts (Interactive)
Added Clinical Events (Summary, Detail, Interactive)
005        01/09/26        David
Alt        Added Orders (Summary,
Detail, Interactive)
006        01/14/26        David
Alt        Added promptable query
limits for interactive reports
007        01/15/26        David
Alt        Added Diagnoses (Summary,
Detail, Interactive)
Wired Note Types and PowerForms to Clinical Event outputs
008        02/24/26        David
Alt        Initial publication
TODO:
[ ] Exclude privileged locations
[ ] Toggle test patient checkbox based on report
BUGS:
[X] Failed to read file due to exceeding max size
[ ] Orders reports don't filter by location
[ ] Alert category, example: IMMUN_EKM!IMMUN_ADMIN_CHARGE_1
CONSIDER:
******************************************************************************/
prompt
"Output to File/Printer/MINE" = "MINE" ;* Enter or select the printer or file name
to send this report to.
, "Search for" = ""
, "Search" = ""
, "" = ""
, "" = 0
, "" = VALUE(0.0 )
, "" = "code"
, "" = 0
, "" = 0
, "" = 0
, "" = "orderable"
, "Agency" = "ALL"
, "Facility" = VALUE(0.0)
, "Start Date" = "SYSDATE"
, "End Date" = "SYSDATE"
, "Include test patients" = "0"
, "Report" = ""
, "Report" = ""
;<<hidden>>"Instructions" = ""
, "Interactive record limit" = 100
with OUTDEV,
search_for, search, alert, charge, diagnosis, diagnosis_option, event,
orderable, order_syn, order_option, agency, facility, start_date,
end_date, include_tp,
rpt, rpt_alerts, icf_limit
/**************************************************************
; Global
Declarations
**************************************************************/
declare
fac_idx = i4 with protect, noconstant(0) ;index for expanding fac record
declare
dx_idx = i4 with protect, noconstant(0) ;index for expanding dx record
declare
tp_var = c2 with protect ;operator variable for test patient prompt
declare
program_name = vc with noconstant("") ;for parsing dlg_name
declare
icf_size = i4 with protect, constant($icf_limit)
/**************************************************************
; Record
Structures
**************************************************************/
; stores the
facilities chosen from the prompt
free record
fac
record fac (
1 facility[*]
2 facility_cd = f8
2 organization_id = f8
) with
protect
; stores list
of SmartZone alerts, which are found
; in
PASSIVE_ALERT instead of EKS_DLG_EVENT
free record
sz
record sz (
1 list[*]
2 module = c30
) with
protect
;stores the
diagnoses from the prompt
free record
dx
record dx (
1 list[*]
2 nomenclature_id = f8
) with
protect
; master
record for events of interest
; encounter
and patient info will always be populated,
; the other
sections are populated based on user selection
free record
cf
record cf (
1 list[*]
;encounter info
2 encntr_id = f8
2 fin = c60
2 encntr_type = c40
2 med_service = c40
2 agency = c40
2 facility = c40
2 facility_cd = f8
2 nurse_unit = c40
2 reg_dt_tm = dq8
2 disch_dt_tm = dq8
2 disch_dispo = c40
2 tz = i4 ;time zone
;patient info
2 person_id = f8
2 patient = c100
2 edipi = c200
2 birth_dt_tm = c20
2 age_at_event = c100
2 admin_sex = c40
2 race = c40
2 ethnicity = c40
2 military_status = c40
2 test_patient_ind = i2 ;1 = test patient
; alerts - discern
2 dlg_event_id = f8
2 dlg_name = c255 ;dlg_name
2 alert_name = c30 ;program_name, module_name, alert_source
2 alert_type = c10 ;Discern or SmartZone
2 alert_dt_tm = dq8
2 alert_version = c10
2 alert_validation = c12
2 alert_text = vc
2 alert_override_text = vc
2 alert_override_reason = vc
2 alert_action_taken = c40
2 alert_modified_behavior = c3
2 alert_overridden = c3
2 alert_suppressed = c3
2 dlg_prsnl = c100
2 dlg_prsnl_position = c100
; ... specific to smartzone alerts
2 passive_alert_id = f8
2 sz_alert_category = c40
2 sz_alert_beg_dt_tm = dq8 ;beg_effective_dt_tm
2 sz_alert_end_dt_tm = dq8 ;end_effective_dt_tm
2 sz_alert_action_type = c30
2 sz_alert_action_parameter = c255
; clinical events
2 event_id = f8
2 event_cd = f8
2 event = c40
2 event_dt_tm = dq8
2 result = c255
2 result_units = c40
2 result_status = c40
2 result_source = c40
2 contrib_sys = c40 ;shared by other use cases
2 entry_mode = c40
2 event_class = c40
2 performing_prsnl = c100
2 verifying_prsnl = c100
; diagnoses
2 nomenclature_id = f8
2 diagnosis_id = f8
2 diag_type = c40
2 diag_source = c10
2 diag_dt_tm = dq8
2 diag_prsnl = c100
2 diagnosis = c100
2 diagnosis_code_text = c100
2 diagnosis_code = c10
2 diag_priority = i4
; orders
2 order_id = f8
2 origin_encntr_id = f8
2 catalog_cd = f8
2 synonym_id = f8
2 order_dt_tm = dq8
2 orderable = c100
2 primary_mnemonic = c100
2 ordered_as_mnemonic = c100
2 order_catalog_type = c40
2 order_subtype = c40
2 order_clinical_display = c255
2 order_detail = c255
2 order_comment = vc
2 order_status = c40
2 order_dept_status = c40
2 order_entry_prsnl = c100
2 order_provider = c100
2 order_comms_type = c40
; (charges)
; diagnoses
; note types
; orders
; powerforms
; (procedures)
; transfusions
) with
protect ;cf record
; This record
is a clone of the first <x> rows of the cf record.
; The
interactive HTML reports generate enormous files due to hardcoded whitespace -
; e.g. ~9000
records create an HTML file greater than 400MB, which causes a memory error
; at runtime.
By creating a limited subset of the cf record, we can safely generate the
; HTML
reports without exceeding the memory limit.
free record
icf
record icf (
;1 list[icf_size] ;arbitrary limit to avoid enormous HTML files in
interactive reports
1 list[*]
;encounter info
2 encntr_id = f8
2 fin = c60
2 encntr_type = c40
2 med_service = c40
2 agency = c40
2 facility = c40
2 facility_cd = f8
2 nurse_unit = c40
2 reg_dt_tm = dq8
2 disch_dt_tm = dq8
2 disch_dispo = c40
2 tz = i4 ;time zone
;patient info
2 person_id = f8
2 patient = c100
2 edipi = c200
2 birth_dt_tm = c20
2 age_at_event = c100
2 admin_sex = c40
2 race = c40
2 ethnicity = c40
2 military_status = c40
2 test_patient_ind = i2 ;1 = test patient
; alerts - discern
2 dlg_event_id = f8
2 dlg_name = c255 ;dlg_name
2 alert_name = c30 ;program_name, module_name, alert_source
2 alert_type = c10 ;Discern or SmartZone
2 alert_dt_tm = dq8
2 alert_version = c10
2 alert_validation = c12
2 alert_text = vc
2 alert_override_text = vc
2 alert_override_reason = vc
2 alert_action_taken = c40
2 alert_modified_behavior = c3
2 alert_overridden = c3
2 alert_suppressed = c3
2 dlg_prsnl = c100
2 dlg_prsnl_position = c100
; ... specific to smartzone alerts
2 passive_alert_id = f8
2 sz_alert_category = c40
2 sz_alert_beg_dt_tm = dq8 ;beg_effective_dt_tm
2 sz_alert_end_dt_tm = dq8 ;end_effective_dt_tm
2 sz_alert_action_type = c30
2 sz_alert_action_parameter = c255
; clinical events
2 event_id = f8
2 event_cd = f8
2 event = c40
2 event_dt_tm = dq8
2 result = c255
2 result_units = c40
2 result_status = c40
2 result_source = c40
2 contrib_sys = c40 ;shared by other use cases
2 entry_mode = c40
2 event_class = c40
2 performing_prsnl = c100
2 verifying_prsnl = c100
; diagnoses
2 nomenclature_id = f8
2 diagnosis_id = f8
2 diag_type = c40
2 diag_source = c10
2 diag_dt_tm = dq8
2 diag_prsnl = c100
2 diagnosis = c100
2 diagnosis_code_text = c100
2 diagnosis_code = c10
2 diag_priority = i4
; orders
2 order_id = f8
2 origin_encntr_id = f8
2 catalog_cd = f8
2 synonym_id = f8
2 order_dt_tm = dq8
2 orderable = c100
2 primary_mnemonic = c100
2 ordered_as_mnemonic = c100
2 order_catalog_type = c40
2 order_subtype = c40
2 order_clinical_display = c255
2 order_detail = c255
2 order_comment = vc
2 order_status = c40
2 order_dept_status = c40
2 order_entry_prsnl = c100
2 order_provider = c100
2 order_comms_type = c40
; (charges)
; diagnoses
; note types
; orders
; powerforms
; (procedures)
; transfusions
) with
protect ;cf record
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
set output = TRIM(output)
return (output)
end
; Wrap the
input in HTML table cell tags
subroutine(td(input
= vc) = vc)
declare output = vc with protect, noconstant("")
set output = BUILD(|<td>|, input, |</td>|)
return (output)
end ;td
; Wrap the
input in HTML table cell tags
subroutine(td2(input
= vc) = vc)
declare output = vc with protect, noconstant("")
set output = BUILD(|<td colspan=2>|, input, |</td>|)
return (output)
end ;td
; Wrap the
input in HTML table header tags
subroutine(th(input
= vc) = vc)
declare output = vc with protect, noconstant("")
set output = BUILD(|<th>|, input, |</th>|)
return (output)
end ;th
; PowerChart
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
; Builds a
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
; Encounter
Detail Audit link
;
scope={encntr, person} identifier={encntr_id, person_id}
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
; Order
Detail Audit link
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
; Populate
the list of facilities from the prompt
subroutine
(build_fac_record(input = NULL) = NULL)
declare i = i4 with protect,
noconstant(0)
IF($facility = 0.0) ;"Any"
;if no specific facilities are chosen, account for LPE/history
encounters
CALL ALTERLIST(fac->facility, 2)
SET fac->facility[1].facility_cd = 0 ;for history encounters
SET fac->facility[2].facility_cd = 110107739 ;Amb Pharm, for LPE
encounters
SET i = 2
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
fac->facility[i].organization_id = ag.organization_id
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
fac->facility[i].organization_id = ag.organization_id
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
fac->facility[i].organization_id = ag.organization_id
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
fac->facility[i].organization_id = ag.organization_id
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
fac->facility[i].organization_id = ag.organization_id
WITH NOCOUNTER
ENDIF
end
;build_fac_record
; Populate
the list of SmartZone alerts
subroutine
(build_sz_record(input = NULL) = NULL)
SELECT INTO "NL:"
FROM EKS_MODULE_AUDIT_TEMP emat
PLAN emat WHERE emat.template_name = "PHI_ADD_PASSIVE_ALERT"
ORDER BY emat.module_name
HEAD REPORT
i = 0
HEAD emat.module_name
i += 1
CALL ALTERLIST(sz->list, i)
sz->list[i].module = emat.module_name
WITH NOCOUNTER
end
;build_sz_record
;
Differentiate Discern from SmartZone alerts
subroutine
(get_alert_type(input = vc) = c10)
declare idx = i4
declare output = c10
set output = "Discern"
for (idx = 1 to size(sz->list, 5))
if(input = PATSTRING(CONCAT("*", sz->list[idx].module,
"*")))
set output = "SmartZone"
endif
endfor
return (output)
end
;get_alert_type
; Populate
the list of diagnoses from the prompt
subroutine
(build_dx_record(input = NULL) = NULL)
declare i = i4 with protect, noconstant(0)
IF($diagnosis = 0.0) ;"Any"
IF($diagnosis_option = "code")
SELECT INTO "NL:"
FROM NOMENCLATURE n
PLAN n WHERE n.source_identifier_keycap = PATSTRING(CONCAT($search,
"*"))
                 AND
n.source_vocabulary_cd = 19350056 ;ICD-10-CM
                 AND
n.end_effective_dt_tm > SYSDATE
                 AND
n.active_ind = 1
ORDER BY n.source_identifier_keycap
DETAIL
i += 1
CALL ALTERLIST(dx->list, i)
dx->list[i].nomenclature_id = n.nomenclature_id
WITH NOCOUNTER
ELSE ;searching by description
SELECT INTO "NL:"
FROM NOMENCLATURE n
PLAN n WHERE CNVTUPPER(n.source_string) =
PATSTRING(CONCAT("*",$search, "*"))
 AND n.source_vocabulary_cd =
19350056 ;ICD-10-CM
 AND n.end_effective_dt_tm
> SYSDATE
 AND n.active_ind = 1
ORDER BY CNVTUPPER(n.source_string)
DETAIL
i += 1
CALL ALTERLIST(dx->list, i)
dx->list[i].nomenclature_id = n.nomenclature_id
WITH
NOCOUNTER
ENDIF
ELSE ;specific diagnoses were selected
SELECT INTO "NL:"
FROM NOMENCLATURE n
PLAN n WHERE n.nomenclature_id = $diagnosis
DETAIL
i += 1
CALL ALTERLIST(dx->list, i)
dx->list[i].nomenclature_id = n.nomenclature_id
WITH NOCOUNTER
ENDIF
end
;build_dx_record
; Clone a
subset of the cf record into icf
subroutine
(build_icf(NULL) = NULL)
declare i = i4
declare cnt = i4
set cnt = EVALUATE2(
IF(value(size(cf->list, 5)) < icf_size)
value(size(cf->list, 5))
ELSE
icf_size
ENDIF)
;initialize icf to cnt
CALL ALTERLIST(icf->list, cnt)
for (i = 1 to cnt)
; encntr info
set icf->list[i].encntr_id = cf->list[i].encntr_id
set icf->list[i].fin = cf->list[i].fin
set icf->list[i].encntr_type = cf->list[i].encntr_type
set icf->list[i].med_service = cf->list[i].med_service
set icf->list[i].agency = cf->list[i].agency
set icf->list[i].facility = cf->list[i].facility
set icf->list[i].facility_cd = cf->list[i].facility_cd
set icf->list[i].nurse_unit = cf->list[i].nurse_unit
set icf->list[i].reg_dt_tm = cf->list[i].reg_dt_tm
set icf->list[i].disch_dt_tm = cf->list[i].disch_dt_tm
set icf->list[i].disch_dispo = cf->list[i].disch_dispo
set icf->list[i].tz = cf->list[i].tz
; patient info
set icf->list[i].person_id = cf->list[i].person_id
set icf->list[i].patient = cf->list[i].patient
set icf->list[i].edipi = cf->list[i].edipi
set icf->list[i].birth_dt_tm = cf->list[i].birth_dt_tm
set icf->list[i].age_at_event = cf->list[i].age_at_event
set icf->list[i].admin_sex = cf->list[i].admin_sex
set icf->list[i].race = cf->list[i].race
set icf->list[i].ethnicity = cf->list[i].ethnicity
set icf->list[i].military_status = cf->list[i].military_status
set icf->list[i].test_patient_ind = cf->list[i].test_patient_ind
; alerts
set icf->list[i].dlg_event_id = cf->list[i].dlg_event_id
set icf->list[i].dlg_name = cf->list[i].dlg_name
set icf->list[i].alert_name = cf->list[i].alert_name
set icf->list[i].alert_type = cf->list[i].alert_type
set icf->list[i].alert_dt_tm = cf->list[i].alert_dt_tm
set icf->list[i].alert_version = cf->list[i].alert_version
set icf->list[i].alert_validation = cf->list[i].alert_validation
set icf->list[i].alert_text = cf->list[i].alert_text
set icf->list[i].alert_override_text =
cf->list[i].alert_override_text
set icf->list[i].alert_override_reason =
cf->list[i].alert_override_reason
set icf->list[i].alert_action_taken =
cf->list[i].alert_action_taken
set icf->list[i].alert_modified_behavior =
cf->list[i].alert_modified_behavior
set icf->list[i].alert_overridden = cf->list[i].alert_overridden
set icf->list[i].alert_suppressed = cf->list[i].alert_suppressed
set icf->list[i].dlg_prsnl = cf->list[i].dlg_prsnl
set icf->list[i].dlg_prsnl_position =
cf->list[i].dlg_prsnl_position
set icf->list[i].passive_alert_id = cf->list[i].passive_alert_id
set icf->list[i].sz_alert_category =
cf->list[i].sz_alert_category
set icf->list[i].sz_alert_beg_dt_tm =
cf->list[i].sz_alert_beg_dt_tm
set icf->list[i].sz_alert_end_dt_tm =
cf->list[i].sz_alert_end_dt_tm
set icf->list[i].sz_alert_action_type =
cf->list[i].sz_alert_action_type
set icf->list[i].sz_alert_action_parameter =
cf->list[i].sz_alert_action_parameter
; clinical events
set icf->list[i].event_id = cf->list[i].event_id
set icf->list[i].event_cd = cf->list[i].event_cd
set icf->list[i].event = cf->list[i].event
set icf->list[i].event_dt_tm = cf->list[i].event_dt_tm
set icf->list[i].result = cf->list[i].result
set icf->list[i].result_units = cf->list[i].result_units
set icf->list[i].result_status = cf->list[i].result_status
set icf->list[i].result_source = cf->list[i].result_source
set icf->list[i].contrib_sys = cf->list[i].contrib_sys
set icf->list[i].entry_mode = cf->list[i].entry_mode
set icf->list[i].event_class = cf->list[i].event_class
set icf->list[i].performing_prsnl = cf->list[i].performing_prsnl
set icf->list[i].verifying_prsnl = cf->list[i].verifying_prsnl
; diagnoses
set icf->list[i].nomenclature_id = cf->list[i].nomenclature_id
set icf->list[i].diagnosis_id = cf->list[i].diagnosis_id
set icf->list[i].diag_type = cf->list[i].diag_type
set icf->list[i].diag_source = cf->list[i].diag_source
set icf->list[i].diag_dt_tm = cf->list[i].diag_dt_tm
set icf->list[i].diag_prsnl = cf->list[i].diag_prsnl
set icf->list[i].diagnosis = cf->list[i].diagnosis
set icf->list[i].diagnosis_code_text =
cf->list[i].diagnosis_code_text
set icf->list[i].diagnosis_code = cf->list[i].diagnosis_code
set icf->list[i].diag_priority = cf->list[i].diag_priority
; orders
set icf->list[i].order_id = cf->list[i].order_id
set icf->list[i].origin_encntr_id = cf->list[i].origin_encntr_id
set icf->list[i].catalog_cd = cf->list[i].catalog_cd
set icf->list[i].synonym_id = cf->list[i].synonym_id
set icf->list[i].order_dt_tm = cf->list[i].order_dt_tm
set icf->list[i].orderable = cf->list[i].orderable
set icf->list[i].primary_mnemonic = cf->list[i].primary_mnemonic
set icf->list[i].ordered_as_mnemonic =
cf->list[i].ordered_as_mnemonic
set icf->list[i].order_catalog_type =
cf->list[i].order_catalog_type
set icf->list[i].order_subtype = cf->list[i].order_subtype
set icf->list[i].order_clinical_display =
cf->list[i].order_clinical_display
set icf->list[i].order_detail = cf->list[i].order_detail
set icf->list[i].order_comment = cf->list[i].order_comment
set icf->list[i].order_status = cf->list[i].order_status
set icf->list[i].order_dept_status =
cf->list[i].order_dept_status
set icf->list[i].order_entry_prsnl =
cf->list[i].order_entry_prsnl
set icf->list[i].order_provider = cf->list[i].order_provider
set icf->list[i].order_comms_type = cf->list[i].order_comms_type
ENDFOR
end
;build_icf
; Populates
cf record with alerts
subroutine
(build_alerts(NULL) = NULL)
IF(get_alert_type($alert) = "SmartZone") ;query PASSIVE_ALERT
SELECT INTO "NL:"
FROM PASSIVE_ALERT pal
,(LEFT JOIN EKS_MODULE em ON em.module_name = pal.alert_source
AND em.active_flag = "A")
,PERSON p
,(LEFT JOIN PERSON_INFO tpi ON tpi.person_id = p.person_id
AND tpi.info_sub_type_cd = 2678703703 ;test patient identifier
AND tpi.value_cd != 2678703509 ;"not a test patient"
AND tpi.active_ind = 1)
,PERSON_ALIAS edipi
PLAN pal WHERE pal.alert_source = program_name
AND pal.beg_effective_dt_tm >= CNVTDATETIME($start_date)
AND pal.beg_effective_dt_tm <= CNVTDATETIME($end_date)
AND pal.active_ind = 1
JOIN p WHERE p.person_id = pal.person_id
JOIN edipi WHERE edipi.person_id = p.person_id
AND edipi.person_alias_type_cd = 22 ;edipi
AND edipi.end_effective_dt_tm > SYSDATE
AND edipi.active_ind = 1
JOIN em
JOIN tpi
HEAD REPORT
i = 0
DETAIL
i += 1
CALL ALTERLIST(cf->list, i)
;...no encounter info for SmartZone alerts
;patient info
cf->list[i].person_id = pal.person_id
cf->list[i].patient = p.name_full_formatted
cf->list[i].edipi = edipi.alias
cf->list[i].birth_dt_tm =
DATEBIRTHFORMAT(p.birth_dt_tm, p.birth_tz, p.birth_prec_flag,
"MM/DD/YYYY HH:MM;;q")
cf->list[i].age_at_event = CNVTAGE(p.birth_dt_tm,
pal.beg_effective_dt_tm, 0)
cf->list[i].admin_sex = UAR_GET_CODE_DISPLAY(p.sex_cd)
cf->list[i].race = UAR_GET_CODE_DISPLAY(p.race_cd)
cf->list[i].ethnicity = UAR_GET_CODE_DISPLAY(p.ethnic_grp_cd)
cf->list[i].military_status =
UAR_GET_CODE_DISPLAY(p.vet_military_status_cd)
cf->list[i].test_patient_ind = IF(tpi.person_id != 0) 1 ELSE 0 ENDIF
;alert info
cf->list[i].passive_alert_id = pal.passive_alert_id
cf->list[i].alert_name = pal.alert_source
cf->list[i].alert_type = "SmartZone"
cf->list[i].alert_text = pal.alert_txt
cf->list[i].alert_version = em.version
cf->list[i].alert_validation = em.maint_validation
cf->list[i].sz_alert_category =
UAR_GET_CODE_DISPLAY(pal.category_cd)
cf->list[i].sz_alert_beg_dt_tm = pal.beg_effective_dt_tm
cf->list[i].sz_alert_end_dt_tm = pal.end_effective_dt_tm
cf->list[i].sz_alert_action_type = pal.action_type_txt
cf->list[i].sz_alert_action_parameter = pal.action_param_txt
WITH MAXREC=10000, TIME=1000
ELSE ;"Discern" alerts - query EKS_DLG_EVENT
SELECT INTO "NL:"
FROM EKS_DLG_EVENT ede
,EKS_DLG ed
,(LEFT JOIN EKS_MODULE em ON em.module_name = ed.program_name
AND em.active_flag = "A")
,LONG_TEXT alert_lt
,LONG_TEXT override_lt
,ENCOUNTER e
,(LEFT JOIN CUST_LOC_AGENCY_RELTN ag ON ag.location_cd =
e.loc_facility_cd)
,(LEFT JOIN TIME_ZONE_R tz ON tz.parent_entity_id = e.loc_facility_cd
AND tz.parent_entity_name = "LOCATION")
,ENCNTR_ALIAS fin
,PERSON p
,(LEFT JOIN PERSON_INFO tpi ON tpi.person_id = p.person_id
AND tpi.info_sub_type_cd = 2678703703 ;test patient identifier
AND tpi.value_cd != 2678703509 ;"not a test patient"
AND tpi.active_ind = 1)
,PERSON_ALIAS edipi
,PRSNL pr
PLAN ede WHERE 1=1
AND ede.dlg_dt_tm >= CNVTDATETIME($start_date)
AND ede.dlg_dt_tm <= CNVTDATETIME($end_date)
AND ede.dlg_name = $alert
AND ede.active_ind = 1
JOIN ed WHERE ed.dlg_name = ede.dlg_name
JOIN e WHERE e.encntr_id = ede.encntr_id
AND EXPAND(fac_idx, 1, size(fac->facility, 5),
e.loc_facility_cd, fac->facility[fac_idx].facility_cd)
AND e.active_ind = 1
JOIN fin WHERE fin.encntr_id = e.encntr_id
AND fin.encntr_alias_type_cd = 1077 ;FIN
AND fin.end_effective_dt_tm > SYSDATE
AND fin.active_ind = 1
JOIN alert_lt WHERE ede.alert_long_text_id = alert_lt.long_text_id
JOIN override_lt WHERE ede.long_text_id = override_lt.long_text_id
JOIN p WHERE p.person_id = ede.person_id
JOIN edipi WHERE edipi.person_id = p.person_id
AND edipi.person_alias_type_cd = 22 ;edipi
AND edipi.end_effective_dt_tm > SYSDATE
AND edipi.active_ind = 1
JOIN pr WHERE pr.person_id = ede.dlg_prsnl_id
JOIN em
JOIN ag
JOIN tz
JOIN tpi
HEAD REPORT
i = 0
DETAIL
i += 1
CALL ALTERLIST(cf->list, i)
; encounter info
cf->list[i].encntr_id = ede.encntr_id
cf->list[i].fin = fin.alias
cf->list[i].encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
cf->list[i].med_service = UAR_GET_CODE_DISPLAY(e.med_service_cd)
cf->list[i].agency = ag.agency
cf->list[i].facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
cf->list[i].facility_cd = e.loc_facility_cd
cf->list[i].nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
cf->list[i].reg_dt_tm = e.reg_dt_tm
cf->list[i].disch_dt_tm = e.disch_dt_tm
cf->list[i].disch_dispo =
UAR_GET_CODE_DISPLAY(e.disch_disposition_cd)
cf->list[i].tz = DATETIMEZONEBYNAME(tz.time_zone)
; patient info
cf->list[i].person_id = ede.person_id
cf->list[i].patient = p.name_full_formatted
cf->list[i].edipi = edipi.alias
cf->list[i].birth_dt_tm =
DATEBIRTHFORMAT(p.birth_dt_tm, p.birth_tz, p.birth_prec_flag,
"MM/DD/YYYY HH:MM;;q")
cf->list[i].age_at_event = CNVTAGE(p.birth_dt_tm, ede.dlg_dt_tm, 0)
cf->list[i].admin_sex = UAR_GET_CODE_DISPLAY(p.sex_cd)
cf->list[i].race = UAR_GET_CODE_DISPLAY(p.race_cd)
cf->list[i].ethnicity = UAR_GET_CODE_DISPLAY(p.ethnic_grp_cd)
cf->list[i].military_status =
UAR_GET_CODE_DISPLAY(p.vet_military_status_cd)
cf->list[i].test_patient_ind = IF(tpi.person_id != 0) 1 ELSE 0 ENDIF
; alert info
cf->list[i].dlg_event_id = ede.dlg_event_id
cf->list[i].dlg_name = ede.dlg_name
cf->list[i].alert_name = ed.program_name
cf->list[i].alert_type = "Discern"
cf->list[i].alert_dt_tm = ede.dlg_dt_tm ;will need tz formatting
cf->list[i].alert_version = em.version
cf->list[i].alert_validation = em.maint_validation
cf->list[i].alert_text =
SUBSTRING(1,1000,REPLACE_CRLF(alert_lt.long_text))
cf->list[i].alert_override_text =
SUBSTRING(1,1000,REPLACE_CRLF(override_lt.long_text))
cf->list[i].alert_override_reason =
UAR_GET_CODE_DISPLAY(ede.override_reason_cd)
cf->list[i].alert_action_taken = EVALUATE(ede.action_flag,
0, "unspecified action",
1, "display alert only",
2, "cancel triggering
action",        ;cancel the order
that triggered the alert
3, "continue triggering action",;override the alert
4, "modify triggering
action",        ;modify the order
that triggered the alert
"unknown/unspecified")
cf->list[i].alert_modified_behavior = EVALUATE2(
IF(ede.action_flag IN (2,4)) "yes"
ELSE "no"
ENDIF)
cf->list[i].alert_overridden = EVALUATE(ede.action_flag, 3
,"yes",
"no")
cf->list[i].alert_suppressed = EVALUATE2(
IF(CNVTUPPER(override_lt.long_text) = "*SUPPRESS*")
"yes"
ELSE "no"
ENDIF)
cf->list[i].dlg_prsnl = pr.name_full_formatted
cf->list[i].dlg_prsnl_position =
UAR_GET_CODE_DISPLAY(pr.position_cd)
WITH MAXREC=10000, TIME=1000
ENDIF
end
;build_alerts
; Populates
cf record with clinical events
subroutine
(build_ce(NULL) = NULL)
SELECT INTO "NL:"
FROM CLINICAL_EVENT ce
,ENCOUNTER e
,(LEFT JOIN CUST_LOC_AGENCY_RELTN ag ON ag.location_cd =
e.loc_facility_cd)
,(LEFT JOIN TIME_ZONE_R tz ON tz.parent_entity_id = e.loc_facility_cd
AND tz.parent_entity_name = "LOCATION")
,ENCNTR_ALIAS fin
,PERSON p
,(LEFT JOIN PERSON_INFO tpi ON tpi.person_id = p.person_id
AND tpi.info_sub_type_cd = 2678703703 ;test patient identifier
AND tpi.value_cd != 2678703509 ;"not a test patient"
AND tpi.active_ind = 1)
,PERSON_ALIAS edipi
,PRSNL pr_p
,PRSNL pr_v
PLAN ce WHERE ce.event_cd = $event
AND ce.event_end_dt_tm >= CNVTDATETIME($start_date)
AND ce.event_end_dt_tm <= CNVTDATETIME($end_date)
AND ce.result_status_cd NOT IN (28,29,30,31) ;er error
AND (ce.view_level = 1 OR ce.entry_mode_cd = 679378) ;working view
AND ce.valid_until_dt_tm > SYSDATE
JOIN e WHERE e.encntr_id = ce.encntr_id
AND EXPAND(fac_idx, 1, size(fac->facility, 5),
e.loc_facility_cd, fac->facility[fac_idx].facility_cd)
AND e.active_ind = 1
JOIN fin WHERE fin.encntr_id = e.encntr_id
AND fin.encntr_alias_type_cd = 1077 ;FIN
AND fin.end_effective_dt_tm > SYSDATE
AND fin.active_ind = 1
JOIN p WHERE p.person_id = ce.person_id
JOIN edipi WHERE edipi.person_id = p.person_id
AND edipi.person_alias_type_cd = 22 ;edipi
AND edipi.end_effective_dt_tm > SYSDATE
AND edipi.active_ind = 1
JOIN pr_p WHERE pr_p.person_id = ce.performed_prsnl_id
JOIN pr_v WHERE pr_v.person_id = ce.verified_prsnl_id
JOIN ag
JOIN tz
JOIN tpi
HEAD REPORT
i = 0
DETAIL
i += 1
CALL ALTERLIST(cf->list, i)
; encounter info
cf->list[i].encntr_id = ce.encntr_id
cf->list[i].fin = fin.alias
cf->list[i].encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
cf->list[i].med_service = UAR_GET_CODE_DISPLAY(e.med_service_cd)
cf->list[i].agency = ag.agency
cf->list[i].facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
cf->list[i].facility_cd = e.loc_facility_cd
cf->list[i].nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
cf->list[i].reg_dt_tm = e.reg_dt_tm
cf->list[i].disch_dt_tm = e.disch_dt_tm
cf->list[i].disch_dispo =
UAR_GET_CODE_DISPLAY(e.disch_disposition_cd)
cf->list[i].tz = DATETIMEZONEBYNAME(tz.time_zone)
; patient info
cf->list[i].person_id = p.person_id
cf->list[i].patient = p.name_full_formatted
cf->list[i].edipi = edipi.alias
cf->list[i].birth_dt_tm =
DATEBIRTHFORMAT(p.birth_dt_tm, p.birth_tz, p.birth_prec_flag,
"MM/DD/YYYY HH:MM;;q")
cf->list[i].age_at_event = CNVTAGE(p.birth_dt_tm,
ce.event_end_dt_tm, 0)
cf->list[i].admin_sex = UAR_GET_CODE_DISPLAY(p.sex_cd)
cf->list[i].race = UAR_GET_CODE_DISPLAY(p.race_cd)
cf->list[i].ethnicity = UAR_GET_CODE_DISPLAY(p.ethnic_grp_cd)
cf->list[i].military_status =
UAR_GET_CODE_DISPLAY(p.vet_military_status_cd)
cf->list[i].test_patient_ind = IF(tpi.person_id != 0) 1 ELSE 0 ENDIF
; event info
cf->list[i].event_id = ce.event_id
cf->list[i].event_cd = ce.event_cd
cf->list[i].event = UAR_GET_CODE_DISPLAY(ce.event_cd)
cf->list[i].event_dt_tm = ce.event_end_dt_tm
cf->list[i].result = ce.result_val
cf->list[i].result_units = UAR_GET_CODE_DISPLAY(ce.result_units_cd)
cf->list[i].result_status =
UAR_GET_CODE_DISPLAY(ce.result_status_cd)
cf->list[i].contrib_sys =
UAR_GET_CODE_DISPLAY(ce.contributor_system_cd)
cf->list[i].entry_mode = UAR_GET_CODE_DISPLAY(ce.entry_mode_cd)
cf->list[i].event_class = UAR_GET_CODE_DISPLAY(ce.event_class_cd)
cf->list[i].performing_prsnl = pr_p.name_full_formatted
cf->list[i].verifying_prsnl = pr_v.name_full_formatted
WITH MAXREC=10000, TIME=1000
end ;build_ce
; Populates
cf record with diagnoses
subroutine
(build_diagnoses(NULL) = NULL)
SELECT INTO "NL:"
FROM DIAGNOSIS d
,ENCOUNTER e
,(LEFT JOIN CUST_LOC_AGENCY_RELTN ag ON ag.location_cd =
e.loc_facility_cd)
,(LEFT JOIN TIME_ZONE_R tz ON tz.parent_entity_id = e.loc_facility_cd
AND tz.parent_entity_name = "LOCATION")
,ENCNTR_ALIAS fin
,PERSON p
,(LEFT JOIN PERSON_INFO tpi ON tpi.person_id = p.person_id
AND tpi.info_sub_type_cd = 2678703703 ;test patient identifier
AND tpi.value_cd != 2678703509 ;"not a test patient"
AND tpi.active_ind = 1)
,PERSON_ALIAS edipi
,NOMENCLATURE
n
PLAN d WHERE EXPAND(dx_idx, 1, size(dx->list, 5), d.nomenclature_id,
dx->list[dx_idx].nomenclature_id)
 AND d.end_effective_dt_tm >
SYSDATE
 AND d.active_ind = 1
JOIN e WHERE e.encntr_id = d.encntr_id
AND e.disch_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND EXPAND(fac_idx, 1, size(fac->facility, 5),
e.loc_facility_cd, fac->facility[fac_idx].facility_cd)
AND e.active_ind = 1
JOIN fin WHERE fin.encntr_id = e.encntr_id
AND fin.encntr_alias_type_cd = 1077 ;FIN
AND fin.end_effective_dt_tm > SYSDATE
AND fin.active_ind = 1
JOIN p WHERE p.person_id = d.person_id
JOIN edipi WHERE edipi.person_id = p.person_id
AND edipi.person_alias_type_cd = 22 ;edipi
AND edipi.end_effective_dt_tm > SYSDATE
AND edipi.active_ind = 1
JOIN n WHERE n.nomenclature_id = d.nomenclature_id
AND n.active_ind = 1
JOIN ag
JOIN tz
JOIN tpi
HEAD REPORT
i = 0
DETAIL
i += 1
CALL ALTERLIST(cf->list, i)
; encounter info
cf->list[i].encntr_id = e.encntr_id
cf->list[i].fin = fin.alias
cf->list[i].encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
cf->list[i].med_service = UAR_GET_CODE_DISPLAY(e.med_service_cd)
cf->list[i].agency = ag.agency
cf->list[i].facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
cf->list[i].facility_cd = e.loc_facility_cd
cf->list[i].nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
cf->list[i].reg_dt_tm = e.reg_dt_tm
cf->list[i].disch_dt_tm = e.disch_dt_tm
cf->list[i].disch_dispo =
UAR_GET_CODE_DISPLAY(e.disch_disposition_cd)
cf->list[i].tz = DATETIMEZONEBYNAME(tz.time_zone)
; patient info
cf->list[i].person_id = p.person_id
cf->list[i].patient = p.name_full_formatted
cf->list[i].edipi = edipi.alias
cf->list[i].birth_dt_tm =
DATEBIRTHFORMAT(p.birth_dt_tm, p.birth_tz, p.birth_prec_flag,
"MM/DD/YYYY HH:MM;;q")
cf->list[i].age_at_event = CNVTAGE(p.birth_dt_tm, e.disch_dt_tm, 0)
cf->list[i].admin_sex = UAR_GET_CODE_DISPLAY(p.sex_cd)
cf->list[i].race = UAR_GET_CODE_DISPLAY(p.race_cd)
cf->list[i].ethnicity = UAR_GET_CODE_DISPLAY(p.ethnic_grp_cd)
cf->list[i].military_status =
UAR_GET_CODE_DISPLAY(p.vet_military_status_cd)
cf->list[i].test_patient_ind = IF(tpi.person_id != 0) 1 ELSE 0 ENDIF
; diagnosis info
cf->list[i].nomenclature_id = d.nomenclature_id
cf->list[i].diagnosis_id = d.diagnosis_id
cf->list[i].diag_type = UAR_GET_CODE_DISPLAY(d.diag_type_cd)
cf->list[i].diag_source = EVALUATE2(
IF(d.diag_type_cd = 89) "Coder" ;final
ELSE "Provider"
ENDIF)
cf->list[i].diag_dt_tm = EVALUATE2(
IF(d.diag_dt_tm IS NULL) d.updt_dt_tm
ELSE d.diag_dt_tm
ENDIF)
cf->list[i].diag_prsnl =
TRIM(SUBSTRING(1,100,replace_CRLF(d.diag_prsnl_name)))
cf->list[i].diagnosis = d.diagnosis_display
cf->list[i].diagnosis_code_text = n.source_string
cf->list[i].diagnosis_code = n.source_identifier
cf->list[i].diag_priority = d.diag_priority
cf->list[i].contrib_sys =
UAR_GET_CODE_DISPLAY(d.contributor_system_cd)
WITH MAXREC=10000, TIME=1000
end
;build_diagnoses
; Populates
cf record with orders
subroutine
(build_orders(NULL) = NULL)
declare order_type = f8
declare laboratory = f8 with constant(2513)
declare pharmacy = f8 with constant(2516)
declare radiology = f8 with constant(2517)
; Get the catalog_type_cd so we can distinguish pharmacy orders
SELECT INTO "NL:"
FROM ORDER_CATALOG oc
WHERE oc.catalog_cd = $orderable
AND oc.active_ind = 1
DETAIL
order_type = oc.catalog_type_cd
WITH NULLREPORT
;IF($order_option = "orderable" AND order_type NOT IN
(laboratory, pharmacy, radiology))
;IF($order_option = "orderable" AND order_type != pharmacy)
SELECT INTO "NL:"
FROM ORDER_CATALOG oc
,ORDERS o
,ENCOUNTER e
,(LEFT JOIN CUST_LOC_AGENCY_RELTN ag ON ag.location_cd =
e.loc_facility_cd)
,(LEFT JOIN TIME_ZONE_R tz ON tz.parent_entity_id = e.loc_facility_cd
AND tz.parent_entity_name = "LOCATION")
,ENCNTR_ALIAS fin
,ORDER_ACTION oa
,PRSNL pr_entry
,PRSNL pr_owner
,PERSON p
,(LEFT JOIN PERSON_INFO tpi ON tpi.person_id = p.person_id
AND tpi.info_sub_type_cd = 2678703703 ;test patient identifier
AND tpi.value_cd != 2678703509 ;"not a test patient"
AND tpi.active_ind = 1)
,PERSON_ALIAS edipi
PLAN oc WHERE oc.catalog_cd = $orderable
JOIN o WHERE o.orig_order_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND o.template_order_flag IN (0,1,5,7) ;exclude auto-generated child
orders
AND o.catalog_cd = oc.catalog_cd
AND o.order_status_cd NOT IN (2542, 2544) ;canceled, voided
AND o.active_ind = 1
JOIN e WHERE 1=1
AND ((e.encntr_id = o.originating_encntr_id AND o.originating_encntr_id
!= 0)
OR (e.encntr_id = o.encntr_id AND o.originating_encntr_id = 0))
AND EXPAND(fac_idx, 1, size(fac->facility, 5), e.loc_facility_cd,
fac->facility[fac_idx].facility_cd)
AND e.end_effective_dt_tm > SYSDATE
AND e.active_ind = 1
JOIN fin WHERE fin.encntr_id = e.encntr_id
AND fin.encntr_alias_type_cd = 1077 ;FIN
AND fin.end_effective_dt_tm > SYSDATE
AND fin.active_ind = 1
JOIN oa WHERE oa.order_id = o.order_id
AND oa.action_type_cd = 2534 ;order
JOIN pr_owner WHERE pr_owner.person_id = oa.order_provider_id
JOIN pr_entry WHERE pr_entry.person_id = oa.action_personnel_id
JOIN p WHERE p.person_id = o.person_id
JOIN edipi WHERE edipi.person_id = p.person_id
AND edipi.person_alias_type_cd = 22 ;EDIPI
AND edipi.end_effective_dt_tm > SYSDATE
AND edipi.active_ind = 1
JOIN ag
JOIN tz
JOIN tpi
HEAD REPORT
i = 0
DETAIL
i += 1
CALL ALTERLIST(cf->list, i)
; encounter info
cf->list[i].encntr_id = e.encntr_id
cf->list[i].fin = fin.alias
cf->list[i].encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
cf->list[i].med_service = UAR_GET_CODE_DISPLAY(e.med_service_cd)
cf->list[i].agency = ag.agency
cf->list[i].facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
cf->list[i].facility_cd = e.loc_facility_cd
cf->list[i].nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
cf->list[i].reg_dt_tm = e.reg_dt_tm
cf->list[i].disch_dt_tm = e.disch_dt_tm
cf->list[i].disch_dispo =
UAR_GET_CODE_DISPLAY(e.disch_disposition_cd)
cf->list[i].tz = DATETIMEZONEBYNAME(tz.time_zone)
; patient info
cf->list[i].person_id = p.person_id
cf->list[i].patient = p.name_full_formatted
cf->list[i].edipi = edipi.alias
cf->list[i].birth_dt_tm =
DATEBIRTHFORMAT(p.birth_dt_tm, p.birth_tz, p.birth_prec_flag,
"MM/DD/YYYY HH:MM;;q")
cf->list[i].age_at_event = CNVTAGE(p.birth_dt_tm,
o.orig_order_dt_tm, 0)
cf->list[i].admin_sex = UAR_GET_CODE_DISPLAY(p.sex_cd)
cf->list[i].race = UAR_GET_CODE_DISPLAY(p.race_cd)
cf->list[i].ethnicity = UAR_GET_CODE_DISPLAY(p.ethnic_grp_cd)
cf->list[i].military_status =
UAR_GET_CODE_DISPLAY(p.vet_military_status_cd)
cf->list[i].test_patient_ind = IF(tpi.person_id != 0) 1 ELSE 0 ENDIF
; order info
cf->list[i].order_id = o.order_id
cf->list[i].catalog_cd = o.catalog_cd
cf->list[i].synonym_id = o.synonym_id
cf->list[i].order_dt_tm = o.orig_order_dt_tm
cf->list[i].orderable = oc.description
cf->list[i].primary_mnemonic = oc.primary_mnemonic
cf->list[i].ordered_as_mnemonic = o.ordered_as_mnemonic
cf->list[i].order_catalog_type =
UAR_GET_CODE_DISPLAY(oc.catalog_type_cd)
cf->list[i].order_subtype =
UAR_GET_CODE_DISPLAY(oc.activity_subtype_cd)
cf->list[i].order_clinical_display = o.clinical_display_line
cf->list[i].order_detail = o.order_detail_display_line
cf->list[i].order_status = UAR_GET_CODE_DISPLAY(o.order_status_cd)
cf->list[i].order_dept_status =
UAR_GET_CODE_DISPLAY(o.dept_status_cd)
cf->list[i].order_entry_prsnl = pr_entry.name_full_formatted
cf->list[i].order_provider = pr_owner.name_full_formatted
cf->list[i].order_comms_type =
UAR_GET_CODE_DISPLAY(o.latest_communication_type_cd)
WITH MAXREC=10000, TIME=1000, NULLREPORT
;ENDIF
end
;build_orders
; Populates
cf record with orders
subroutine
(build_orders_alt(NULL) = NULL)
SELECT INTO "NL:"
FROM ORDERS o
,ENCOUNTER e
PLAN o WHERE o.orig_order_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND o.template_order_flag IN (0,1,5,7) ;exclude auto-generated child
orders
AND o.catalog_cd = $orderable
AND o.order_status_cd NOT IN (2542, 2544) ;canceled, voided
AND o.active_ind = 1
JOIN e WHERE e.encntr_id IN (o.originating_encntr_id, o.encntr_id)
AND EXPAND(fac_idx, 1, size(fac->facility, 5), e.loc_facility_cd,
fac->facility[fac_idx].facility_cd)
HEAD REPORT
i = 0
DETAIL
i += 1
CALL ALTERLIST(cf->list, i)
; encounter info
cf->list[i].encntr_id = e.encntr_id
;cf->list[i].fin = fin.alias
cf->list[i].encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
cf->list[i].med_service = UAR_GET_CODE_DISPLAY(e.med_service_cd)
;cf->list[i].agency = ag.agency
cf->list[i].facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
cf->list[i].facility_cd = e.loc_facility_cd
cf->list[i].nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
cf->list[i].reg_dt_tm = e.reg_dt_tm
cf->list[i].disch_dt_tm = e.disch_dt_tm
cf->list[i].disch_dispo =
UAR_GET_CODE_DISPLAY(e.disch_disposition_cd)
;cf->list[i].tz = DATETIMEZONEBYNAME(tz.time_zone)
; patient info
cf->list[i].person_id = o.person_id
;                cf->list[i].patient
= p.name_full_formatted
;                cf->list[i].edipi
= edipi.alias
;                cf->list[i].birth_dt_tm
=
;                        DATEBIRTHFORMAT(p.birth_dt_tm,
p.birth_tz, p.birth_prec_flag, "MM/DD/YYYY HH:MM;;q")
;                cf->list[i].age_at_event
= CNVTAGE(p.birth_dt_tm, o.orig_order_dt_tm, 0)
;                cf->list[i].admin_sex
= UAR_GET_CODE_DISPLAY(p.sex_cd)
;                cf->list[i].race
= UAR_GET_CODE_DISPLAY(p.race_cd)
;                cf->list[i].ethnicity
= UAR_GET_CODE_DISPLAY(p.ethnic_grp_cd)
;                cf->list[i].military_status
= UAR_GET_CODE_DISPLAY(p.vet_military_status_cd)
;                cf->list[i].test_patient_ind
= IF(tpi.person_id != 0) 1 ELSE 0 ENDIF
; order info
cf->list[i].order_id = o.order_id
cf->list[i].catalog_cd = o.catalog_cd
cf->list[i].synonym_id = o.synonym_id
cf->list[i].order_dt_tm = o.orig_order_dt_tm
;cf->list[i].orderable = oc.description
;cf->list[i].primary_mnemonic = oc.primary_mnemonic
cf->list[i].ordered_as_mnemonic = o.ordered_as_mnemonic
;cf->list[i].order_catalog_type =
UAR_GET_CODE_DISPLAY(oc.catalog_type_cd)
;cf->list[i].order_subtype =
UAR_GET_CODE_DISPLAY(oc.activity_subtype_cd)
cf->list[i].order_clinical_display = o.clinical_display_line
cf->list[i].order_detail = o.order_detail_display_line
cf->list[i].order_status = UAR_GET_CODE_DISPLAY(o.order_status_cd)
cf->list[i].order_dept_status =
UAR_GET_CODE_DISPLAY(o.dept_status_cd)
;cf->list[i].order_entry_prsnl = pr_entry.name_full_formatted
;cf->list[i].order_provider = pr_owner.name_full_formatted
cf->list[i].order_comms_type =
UAR_GET_CODE_DISPLAY(o.latest_communication_type_cd)
WITH MAXREC=10000, TIME=1000, NULLREPORT
SELECT INTO "NL:"
FROM (DUMMYT d WITH seq = value(size(cf->list, 5)))
;                ,(LEFT
JOIN CUST_LOC_AGENCY_RELTN ag ON ag.location_cd =
cf->list[d.seq].facility_cd)
;                ,(LEFT
JOIN TIME_ZONE_R tz ON tz.parent_entity_id = cf->list[d.seq].facility_cd
;                        AND
tz.parent_entity_name = "LOCATION")
;                ,ORDER_ACTION
oa
;                ,PRSNL
pr_entry
;                ,PRSNL
pr_owner
;                ,PERSON
p
;                ,(LEFT
JOIN PERSON_INFO tpi ON tpi.person_id = p.person_id
;                        AND
tpi.info_sub_type_cd = 2678703703 ;test patient identifier
;                        AND
tpi.value_cd != 2678703509 ;"not a test patient"
;                        AND
tpi.active_ind = 1)
;                ,PERSON_ALIAS
edipi
;                ,ENCNTR_ALIAS
fin
,ORDER_CATALOG oc
PLAN d
;        JOIN
oa WHERE oa.order_id = cf->list[d.seq].order_id
;                AND
oa.action_type_cd = 2534 ;order
;        JOIN
pr_owner WHERE pr_owner.person_id = oa.order_provider_id
;        JOIN
pr_entry WHERE pr_entry.person_id = oa.action_personnel_id
;        JOIN
p WHERE p.person_id = cf->list[d.seq].person_id
;        JOIN
edipi WHERE edipi.person_id = p.person_id
;                AND
edipi.person_alias_type_cd = 22 ;EDIPI
;                AND
edipi.end_effective_dt_tm > SYSDATE
;                AND
edipi.active_ind = 1
;        JOIN
fin WHERE fin.encntr_id = cf->list[d.seq].encntr_id
;                AND
fin.encntr_alias_type_cd = 1077 ;FIN
;                AND
fin.end_effective_dt_tm > SYSDATE
;                AND
fin.active_ind = 1
JOIN oc WHERE oc.catalog_cd = cf->list[d.seq].catalog_cd
;        JOIN
ag
;        JOIN
tz
;        JOIN
tpi
HEAD REPORT
i = 0
DETAIL
i += 1
CALL ALTERLIST(cf->list, i)
; encounter info
;                cf->list[i].fin
= fin.alias
;                cf->list[i].agency
= ag.agency
;                cf->list[i].tz
= DATETIMEZONEBYNAME(tz.time_zone)
; patient info
;                cf->list[i].patient
= p.name_full_formatted
;                cf->list[i].edipi
= edipi.alias
;                cf->list[i].birth_dt_tm
=
;                        DATEBIRTHFORMAT(p.birth_dt_tm,
p.birth_tz, p.birth_prec_flag, "MM/DD/YYYY HH:MM;;q")
;                cf->list[i].age_at_event
= CNVTAGE(p.birth_dt_tm, cf->list[d.seq].order_dt_tm, 0)
;                cf->list[i].admin_sex
= UAR_GET_CODE_DISPLAY(p.sex_cd)
;                cf->list[i].race
= UAR_GET_CODE_DISPLAY(p.race_cd)
;                cf->list[i].ethnicity
= UAR_GET_CODE_DISPLAY(p.ethnic_grp_cd)
;                cf->list[i].military_status
= UAR_GET_CODE_DISPLAY(p.vet_military_status_cd)
;                cf->list[i].test_patient_ind
= IF(tpi.person_id != 0) 1 ELSE 0 ENDIF
; order info
cf->list[i].orderable = oc.description
cf->list[i].primary_mnemonic = oc.primary_mnemonic
cf->list[i].order_catalog_type =
UAR_GET_CODE_DISPLAY(oc.catalog_type_cd)
cf->list[i].order_subtype =
UAR_GET_CODE_DISPLAY(oc.activity_subtype_cd)
;                cf->list[i].order_entry_prsnl
= pr_entry.name_full_formatted
;                cf->list[i].order_provider
=
pr_owner.name_full_formatted
WITH MAXREC=10000, TIME=1000, NULLREPORT
end
;build_orders_alt
/**************************************************************
; Main
**************************************************************/
; Set the
test patient operator
IF($include_tp
= "0")
SET tp_var = "="
ELSE
SET tp_var = ">="
ENDIF
; Build
record structures
CALL
build_fac_record(NULL)
IF($search_for
= "Alerts")
SET program_name = PIECE($alert, "!",2,"none")
;extract from dlg_name
CALL build_sz_record(NULL)
CALL build_alerts(NULL)
ELSEIF($search_for
IN ("Clinical Events", "Note Types",
"PowerForms"))
CALL build_ce(NULL)
ELSEIF($search_for
= "Diagnoses")
CALL build_dx_record(NULL)
CALL build_diagnoses(NULL)
ELSEIF($search_for
= "Orders")
CALL build_orders(NULL)
;CALL build_orders_alt(NULL)
ENDIF
IF($rpt =
"Interactive" OR $rpt_alerts = "Interactive")
CALL build_icf(NULL)
ENDIF
/**************************************************************
; Output
**************************************************************/
SELECT
; Check for
empty record and inform user gracefully
IF(value(size(cf->list,
5)) = 0)
error = "No cases found. Adjust prompts and try again!"
ELSEIF($search_for
= "Alerts" AND $rpt_alerts = "Alert list")
DISTINCT
module = PIECE(ed.dlg_name, "!",1,"none")
,ed.program_name
,status = em.maint_validation
,em.version
,start_dt_tm = ed.beg_effective_dt_tm
,last_updated = em.updt_dt_tm
,author = TRIM(em.maint_author)
,specialist = TRIM(em.maint_specialist)
,institution = TRIM(em.maint_institution)
,alert_type =
IF(emat.module_name = ed.program_name) "SmartZone"
ELSE "Discern"
ENDIF
,ed.dlg_name
FROM EKS_DLG ed
,(LEFT JOIN EKS_MODULE em ON em.module_name = ed.program_name
AND em.active_flag = "A")
,(LEFT JOIN EKS_MODULE_AUDIT_TEMP emat ON emat.module_name =
ed.program_name
AND emat.template_name = "PHI_ADD_PASSIVE_ALERT")
PLAN ed WHERE ed.end_effective_dt_tm > SYSDATE
AND ed.active_ind = 1
JOIN em
JOIN emat
ORDER BY ed.dlg_name, ed.program_name
WITH NOCOUNTER, SEPARATOR=" ", FORMAT, CHECK, TIME=180
;TODO: how
would this account for test patient indicator?
;RESULTS ARE
INVALID
ELSEIF($search_for
= "Alerts" AND $rpt_alerts = "Summary" AND
get_alert_type($alert) = "Discern")
alert_name = PIECE(ede.dlg_name, "!", 2, "none")
,ag.agency
,facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,test_patient_ind = UAR_GET_CODE_DISPLAY(tpi.value_cd)
,nbr_alerts = COUNT(DISTINCT ede.dlg_event_id)
,nbr_patients = COUNT(DISTINCT ede.person_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
FROM EKS_DLG_EVENT ede
,(LEFT JOIN PERSON_INFO tpi ON tpi.person_id = ede.person_id
AND tpi.info_sub_type_cd = 2678703703 ;test patient identifier
AND tpi.value_cd != 2678703509 ;"not a test patient"
AND tpi.active_ind =
1)
,ENCOUNTER e
,(LEFT JOIN CUST_LOC_AGENCY_RELTN ag ON ag.location_cd =
e.loc_facility_cd)
PLAN ede WHERE 1=1
AND ede.dlg_dt_tm >= CNVTDATETIME($start_date)
AND ede.dlg_dt_tm <= CNVTDATETIME($end_date)
AND ede.dlg_name = $alert
AND ede.active_ind = 1
JOIN e WHERE e.encntr_id = ede.encntr_id
AND EXPAND(fac_idx, 1, size(fac->facility, 5),
e.loc_facility_cd, fac->facility[fac_idx].facility_cd)
AND e.active_ind = 1
JOIN ag
JOIN tpi
GROUP BY ede.dlg_name, ag.agency, e.loc_facility_cd, tpi.value_cd
ORDER BY ag.agency, facility, test_patient_ind
ELSEIF($search_for
= "Alerts" AND $rpt_alerts = "Summary" AND
get_alert_type($alert) = "SmartZone")
alert_name = pal.alert_source
,test_patient_ind = UAR_GET_CODE_DISPLAY(tpi.value_cd)
,nbr_patients = COUNT(DISTINCT pal.person_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
FROM PASSIVE_ALERT pal
,(LEFT JOIN PERSON_INFO tpi ON tpi.person_id = pal.person_id
AND tpi.info_sub_type_cd = 2678703703 ;test patient identifier
AND tpi.value_cd != 2678703509 ;"not a test patient"
AND tpi.active_ind = 1)
PLAN pal WHERE pal.alert_source = program_name
AND pal.beg_effective_dt_tm >= CNVTDATETIME($start_date)
AND pal.beg_effective_dt_tm <= CNVTDATETIME($end_date)
AND pal.active_ind = 1
JOIN tpi
GROUP BY pal.alert_source, tpi.value_cd
ORDER BY alert_name, test_patient_ind
ELSEIF($search_for
= "Alerts" AND $rpt_alerts = "Detail" AND
get_alert_type($alert) = "Discern")
; encntr info
encntr_id = cf->list[d.seq].encntr_id
,fin = cf->list[d.seq].fin
,encntr_type = cf->list[d.seq].encntr_type
,med_service = cf->list[d.seq].med_service
,agency = cf->list[d.seq].agency
,facility = cf->list[d.seq].facility
,nurse_unit = cf->list[d.seq].nurse_unit
,reg_dt_tm = DATETIMEZONEFORMAT(cf->list[d.seq].reg_dt_tm,
cf->list[d.seq].tz, "MM/DD/YYYY HH:MM;;q")
,disch_dt_tm = DATETIMEZONEFORMAT(cf->list[d.seq].disch_dt_tm,
cf->list[d.seq].tz, "MM/DD/YYYY HH:MM;;q")
,disch_dispo = cf->list[d.seq].disch_dispo
,tz = DATETIMEZONEBYINDEX(cf->list[d.seq].tz)
; patient info
,person_id = cf->list[d.seq].person_id
,patient = cf->list[d.seq].patient
,edipi = cf->list[d.seq].edipi
,birth_dt_tm = cf->list[d.seq].birth_dt_tm
,age_at_event = cf->list[d.seq].age_at_event
,admin_sex = cf->list[d.seq].admin_sex
,race = cf->list[d.seq].race
,ethnicity = cf->list[d.seq].ethnicity
,military_status = cf->list[d.seq].military_status
,test_patient_ind = cf->list[d.seq].test_patient_ind
,dlg_event_id = cf->list[d.seq].dlg_event_id
,alert_name = cf->list[d.seq].alert_name
,alert_version = cf->list[d.seq].alert_version
,alert_validation = cf->list[d.seq].alert_validation
,alert_type = cf->list[d.seq].alert_type
,alert_dt_tm = DATETIMEZONEFORMAT(cf->list[d.seq].alert_dt_tm,
cf->list[d.seq].tz, "MM/DD/YYYY HH:MM;;q")
,alert_text = cf->list[d.seq].alert_text
,alert_override_text = cf->list[d.seq].alert_override_text
,alert_override_reason = cf->list[d.seq].alert_override_reason
,alert_action_taken = cf->list[d.seq].alert_action_taken
,alert_modified_behavior = cf->list[d.seq].alert_modified_behavior
,alert_overridden = cf->list[d.seq].alert_overridden
,alert_suppressed = cf->list[d.seq].alert_suppressed
,received_by = cf->list[d.seq].dlg_prsnl
,position = cf->list[d.seq].dlg_prsnl_position
FROM (DUMMYT d with seq = value(size(cf->list, 5)))
PLAN d WHERE OPERATOR(cf->list[d.seq].test_patient_ind, tp_var, 0)
ORDER BY encntr_id, dlg_event_id
ELSEIF($search_for
= "Alerts" AND $rpt_alerts = "Detail" AND
get_alert_type($alert) = "SmartZone")
;... no encntr info for patient-level alerts
; patient info
person_id = cf->list[d.seq].person_id
,patient = cf->list[d.seq].patient
,edipi = cf->list[d.seq].edipi
,birth_dt_tm = cf->list[d.seq].birth_dt_tm
,age_at_event = cf->list[d.seq].age_at_event
,admin_sex = cf->list[d.seq].admin_sex
,race = cf->list[d.seq].race
,ethnicity = cf->list[d.seq].ethnicity
,military_status = cf->list[d.seq].military_status
,test_patient_ind = cf->list[d.seq].test_patient_ind
,passive_alert_id = cf->list[d.seq].passive_alert_id
,alert_name = cf->list[d.seq].alert_name
,alert_version = cf->list[d.seq].alert_version
,alert_validation = cf->list[d.seq].alert_validation
,alert_type = cf->list[d.seq].alert_type
,alert_text = cf->list[d.seq].alert_text
,sz_alert_category = cf->list[d.seq].sz_alert_category
,sz_alert_beg_dt_tm = cf->list[d.seq].sz_alert_beg_dt_tm
"MM/DD/YYYY;;d"
,sz_alert_end_dt_tm = cf->list[d.seq].sz_alert_end_dt_tm
"MM/DD/YYYY;;d"
,sz_alert_action_type = cf->list[d.seq].sz_alert_action_type
,sz_alert_action_parameter =
cf->list[d.seq].sz_alert_action_parameter
FROM (DUMMYT d with seq = value(size(cf->list, 5)))
PLAN d WHERE OPERATOR(cf->list[d.seq].test_patient_ind, tp_var, 0)
ORDER BY person_id, passive_alert_id
ELSEIF($search_for
= "Alerts" AND $rpt_alerts = "Interactive" AND
get_alert_type($alert) = "Discern")
; encntr info
encntr_id = icf->list[d.seq].encntr_id
,fin = icf->list[d.seq].fin
,encntr_type = icf->list[d.seq].encntr_type
,med_service = icf->list[d.seq].med_service
,agency = icf->list[d.seq].agency
,facility = icf->list[d.seq].facility
,nurse_unit = icf->list[d.seq].nurse_unit
,reg_dt_tm = DATETIMEZONEFORMAT(icf->list[d.seq].reg_dt_tm,
icf->list[d.seq].tz, "MM/DD/YYYY HH:MM;;q")
,disch_dt_tm = DATETIMEZONEFORMAT(icf->list[d.seq].disch_dt_tm,
icf->list[d.seq].tz, "MM/DD/YYYY HH:MM;;q")
,disch_dispo = icf->list[d.seq].disch_dispo
,tz = DATETIMEZONEBYINDEX(icf->list[d.seq].tz)
; patient info
,person_id = icf->list[d.seq].person_id
,patient = icf->list[d.seq].patient
,edipi = icf->list[d.seq].edipi
,birth_dt_tm = icf->list[d.seq].birth_dt_tm
,age_at_event = icf->list[d.seq].age_at_event
,admin_sex = icf->list[d.seq].admin_sex
,race = icf->list[d.seq].race
,ethnicity = icf->list[d.seq].ethnicity
,military_status = icf->list[d.seq].military_status
,test_patient_ind = icf->list[d.seq].test_patient_ind
,dlg_event_id = icf->list[d.seq].dlg_event_id
,alert_name = icf->list[d.seq].alert_name
,alert_version = icf->list[d.seq].alert_version
,alert_validation = icf->list[d.seq].alert_validation
,alert_type = icf->list[d.seq].alert_type
,alert_dt_tm = DATETIMEZONEFORMAT(icf->list[d.seq].alert_dt_tm,
icf->list[d.seq].tz, "MM/DD/YYYY HH:MM;;q")
,alert_text = icf->list[d.seq].alert_text
,alert_override_text = icf->list[d.seq].alert_override_text
,alert_override_reason = icf->list[d.seq].alert_override_reason
,alert_action_taken = icf->list[d.seq].alert_action_taken
,alert_modified_behavior = icf->list[d.seq].alert_modified_behavior
,alert_overridden = icf->list[d.seq].alert_overridden
,alert_suppressed = icf->list[d.seq].alert_suppressed
,received_by = icf->list[d.seq].dlg_prsnl
,position = icf->list[d.seq].dlg_prsnl_position
FROM (DUMMYT d with seq = value(size(icf->list, 5)))
PLAN d WHERE OPERATOR(icf->list[d.seq].test_patient_ind, tp_var, 0)
ORDER BY encntr_id, dlg_event_id
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
row+1         ^<th>Alert
Date/Time</th>^
row+1
        ^<th>Alert</th>^
row+1        ^<th>Version</th>^
row+1
        ^<th>Validation</th>^
row+1
        ^<th>Type</th>^
row+1         ^<th>Action
Taken</th>^
row+1
        ^<th>Modified
Behavior?</th>^
row+1
        ^<th>Overridden?</th>^
row+1
        ^<th>Suppressed?</th>^
row+1
        ^<th>Received
By</th>^
row+1
        ^<th>Position</th>^
row+1 ^</tr>^
row+1 ^<tr>^ ;first row with result information
row+1        call
print(td(CNVTSTRING(i)))
row+1        call
print(td(alert_dt_tm))
row+1        call
print(td(alert_name))
row+1        call
print(td(alert_version))
row+1        call
print(td(alert_validation))
row+1        call
print(td(alert_type))
row+1        call
print(td(alert_action_taken))
row+1        call
print(td(alert_modified_behavior))
row+1        call
print(td(alert_overridden))
row+1        call
print(td(alert_suppressed))
row+1        call
print(td(received_by))
row+1        call
print(td(position))
row+1 ^</tr>^
row+1 ^<tr></tr>^
row+1 ^<tr>^
row+1        ^<td
style='text-align: right;'>Encounter: </td>^
row+1        call
print(CONCAT(^<td>Type: ^, icf->list[d.seq].encntr_type, ^ (^,
eda("encntr", icf->list[d.seq].encntr_id, "Encounter
History", "History"),
^)</td>^))
row+1        call
print(CONCAT(^<td>FIN: ^, chartlink(icf->list[d.seq].person_id,
icf->list[d.seq].encntr_id, icf->list[d.seq].fin),
^</td>^))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id,
"Alerts", "Alerts")))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id,
"Diagnoses", "Diagnoses")))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id, "Clinical
Events", "Events")))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id, "Lab
Results", "Lab Results")))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id,
"Medication Administration", "Med Admin")))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id,
"Documentation", "Notes")))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id, "Orders
(all)", "Orders")))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id, "Vital
Signs", "Vital Signs")))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id,
"Registration (PIP)", "Registration")))
row+1 ^</tr>^
row+1 ^<tr>^
row+1        ^<td
style='text-align: right;'>Patient: </td>^
row+1        call
print(td(eda("person", icf->list[d.seq].person_id, "Identity
and Demographics", icf->list[d.seq].patient)))
row+1        call
print(CONCAT(^<td>EDIPI: ^, icf->list[d.seq].edipi, ^</td>^))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id,
"Allergies", "Allergies")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id,
"Medication List", "Medications")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id, "Problem
List", "Problem List")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id,
"Procedures", "Procedure History")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id, "Family
History", "Family History")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id, "Social
History", "Social History")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id, "Health
Plans", "Health Plans")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id,
"Aliases", "Other Identifiers")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id, "User
Defined Fields", "Other Info")))
row+1 ^</tr>^
row+1 ^</table>^
row+1 ^<p></p>^
FOOT REPORT
row+1 ^</body>^
row+1 ^</html>^
ELSEIF($search_for
= "Alerts" AND $rpt_alerts = "Interactive" AND
get_alert_type($alert) = "SmartZone")
;... no encntr info for patient-level alerts
; patient info
person_id = icf->list[d.seq].person_id
,patient = icf->list[d.seq].patient
,edipi = icf->list[d.seq].edipi
,birth_dt_tm = icf->list[d.seq].birth_dt_tm
,age_at_event = icf->list[d.seq].age_at_event
,admin_sex = icf->list[d.seq].admin_sex
,race = icf->list[d.seq].race
,ethnicity = icf->list[d.seq].ethnicity
,military_status = icf->list[d.seq].military_status
,test_patient_ind = icf->list[d.seq].test_patient_ind
,passive_alert_id = icf->list[d.seq].passive_alert_id
,alert_name = icf->list[d.seq].alert_name
,alert_version = icf->list[d.seq].alert_version
,alert_validation = icf->list[d.seq].alert_validation
,alert_type = icf->list[d.seq].alert_type
,alert_text = icf->list[d.seq].alert_text
,sz_alert_category = icf->list[d.seq].sz_alert_category
,sz_alert_beg_dt_tm = FORMAT(icf->list[d.seq].sz_alert_beg_dt_tm,
"MM/DD/YYYY;;d")
,sz_alert_end_dt_tm = FORMAT(icf->list[d.seq].sz_alert_end_dt_tm,
"MM/DD/YYYY;;d")
,sz_alert_action_type = icf->list[d.seq].sz_alert_action_type
,sz_alert_action_parameter =
icf->list[d.seq].sz_alert_action_parameter
FROM (DUMMYT d with seq = value(size(icf->list, 5)))
PLAN d WHERE OPERATOR(icf->list[d.seq].test_patient_ind, tp_var, 0)
ORDER BY person_id, passive_alert_id
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
row+1         ^<th>Alert
Added Date</th>^
row+1
        ^<th>Alert</th>^
row+1        ^<th>Version</th>^
row+1
        ^<th>Validation</th>^
row+1
        ^<th>Type</th>^
row+1         ^<th>Action
Taken</th>^
row+1
        ^<th>Modified
Behavior?</th>^
row+1
        ^<th>Overridden?</th>^
row+1
        ^<th>Suppressed?</th>^
row+1
        ^<th>Received
By</th>^
row+1
        ^<th>Position</th>^
row+1 ^</tr>^
row+1 ^<tr>^ ;first row with result information
row+1        call
print(td(CNVTSTRING(i)))
row+1        call
print(td(sz_alert_beg_dt_tm))
row+1        call
print(td(alert_name))
row+1        call
print(td(alert_version))
row+1        call
print(td(alert_validation))
row+1        call
print(td(alert_type))
row+1        call
print(td("N/A"))
row+1        call
print(td("N/A"))
row+1        call
print(td("N/A"))
row+1        call
print(td("N/A"))
row+1        call
print(td("N/A"))
row+1        call
print(td("N/A"))
row+1 ^</tr>^
row+1 ^<tr></tr>^
row+1 ^<tr>^
row+1        ^<td
style='text-align: right;'>Patient: </td>^
row+1        call
print(td(eda("person", icf->list[d.seq].person_id, "Identity
and Demographics", icf->list[d.seq].patient)))
row+1        call
print(CONCAT(^<td>EDIPI: ^, icf->list[d.seq].edipi, ^</td>^))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id,
"Allergies", "Allergies")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id,
"Medication List", "Medications")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id, "Problem
List", "Problem List")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id,
"Procedures", "Procedure History")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id, "Family
History", "Family History")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id, "Social
History", "Social History")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id, "Health
Plans", "Health Plans")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id,
"Aliases", "Other Identifiers")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id, "User
Defined Fields", "Other Info")))
row+1 ^</tr>^
row+1 ^</table>^
row+1 ^<p></p>^
FOOT REPORT
row+1 ^</body>^
row+1 ^</html>^
ELSEIF($search_for
IN ("Clinical Events", "Note Types",
"PowerForms") AND $rpt = "Summary")
event = UAR_GET_CODE_DISPLAY(ce.event_cd)
,ag.agency
,facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,test_patient_ind = UAR_GET_CODE_DISPLAY(tpi.value_cd)
,nbr_events = COUNT(DISTINCT ce.event_id)
,nbr_patients = COUNT(DISTINCT ce.person_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
FROM CLINICAL_EVENT ce
,(LEFT JOIN PERSON_INFO tpi ON tpi.person_id = ce.person_id
AND tpi.info_sub_type_cd = 2678703703 ;test patient identifier
AND tpi.value_cd != 2678703509 ;"not a test patient"
AND tpi.active_ind = 1)
,ENCOUNTER e
,(LEFT JOIN CUST_LOC_AGENCY_RELTN ag ON ag.location_cd =
e.loc_facility_cd)
PLAN ce WHERE ce.event_cd = $event
AND ce.event_end_dt_tm >= CNVTDATETIME($start_date)
AND ce.event_end_dt_tm <= CNVTDATETIME($end_date)
AND ce.result_status_cd NOT IN (28,29,30,31) ;er error
AND (ce.view_level = 1 OR ce.entry_mode_cd = 679378) ;working view
AND ce.valid_until_dt_tm > SYSDATE
JOIN e WHERE e.encntr_id = ce.encntr_id
AND EXPAND(fac_idx, 1, size(fac->facility, 5),
e.loc_facility_cd, fac->facility[fac_idx].facility_cd)
AND e.active_ind = 1
JOIN tpi
JOIN ag
GROUP BY ce.event_cd, ag.agency, e.loc_facility_cd, tpi.value_cd
ORDER BY event, ag.agency, facility, test_patient_ind
ELSEIF($search_for
IN ("Clinical Events", "Note Types",
"PowerForms") AND $rpt = "Detail")
; encntr info
encntr_id = cf->list[d.seq].encntr_id
,fin = cf->list[d.seq].fin
,encntr_type = cf->list[d.seq].encntr_type
,med_service = cf->list[d.seq].med_service
,agency = cf->list[d.seq].agency
,facility = cf->list[d.seq].facility
,nurse_unit = cf->list[d.seq].nurse_unit
,reg_dt_tm = DATETIMEZONEFORMAT(cf->list[d.seq].reg_dt_tm,
cf->list[d.seq].tz, "MM/DD/YYYY HH:MM;;q")
,disch_dt_tm = DATETIMEZONEFORMAT(cf->list[d.seq].disch_dt_tm,
cf->list[d.seq].tz, "MM/DD/YYYY HH:MM;;q")
,disch_dispo = cf->list[d.seq].disch_dispo
,tz = DATETIMEZONEBYINDEX(cf->list[d.seq].tz)
; patient info
,person_id = cf->list[d.seq].person_id
,patient = cf->list[d.seq].patient
,edipi = cf->list[d.seq].edipi
,birth_dt_tm = cf->list[d.seq].birth_dt_tm
,age_at_event = cf->list[d.seq].age_at_event
,admin_sex = cf->list[d.seq].admin_sex
,race = cf->list[d.seq].race
,ethnicity = cf->list[d.seq].ethnicity
,military_status = cf->list[d.seq].military_status
,test_patient_ind = cf->list[d.seq].test_patient_ind
,event_id = cf->list[d.seq].event_id
,event_cd = cf->list[d.seq].event_cd
,event = cf->list[d.seq].event
,event_dt_tm = DATETIMEZONEFORMAT(cf->list[d.seq].event_dt_tm,
cf->list[d.seq].tz, "MM/DD/YYYY HH:MM;;q")
,result = cf->list[d.seq].result
,result_units = cf->list[d.seq].result_units
,result_status = cf->list[d.seq].result_status
,result_source = cf->list[d.seq].result_source
,contrib_sys = cf->list[d.seq].contrib_sys
,entry_mode = cf->list[d.seq].entry_mode
,event_class = cf->list[d.seq].event_class
,performing_prsnl = cf->list[d.seq].performing_prsnl
,verifying_prsnl = cf->list[d.seq].verifying_prsnl
FROM (DUMMYT d with seq = value(size(cf->list, 5)))
PLAN d WHERE OPERATOR(cf->list[d.seq].test_patient_ind, tp_var, 0)
ORDER BY encntr_id, event_id
ELSEIF($search_for
IN ("Clinical Events", "Note Types",
"PowerForms") AND $rpt = "Interactive")
; encntr info
encntr_id = icf->list[d.seq].encntr_id
,fin = icf->list[d.seq].fin
,encntr_type = icf->list[d.seq].encntr_type
,med_service = icf->list[d.seq].med_service
,agency = icf->list[d.seq].agency
,facility = icf->list[d.seq].facility
,nurse_unit = icf->list[d.seq].nurse_unit
,reg_dt_tm = DATETIMEZONEFORMAT(icf->list[d.seq].reg_dt_tm,
icf->list[d.seq].tz, "MM/DD/YYYY HH:MM;;q")
,disch_dt_tm = DATETIMEZONEFORMAT(icf->list[d.seq].disch_dt_tm,
icf->list[d.seq].tz, "MM/DD/YYYY HH:MM;;q")
,disch_dispo = icf->list[d.seq].disch_dispo
,tz = DATETIMEZONEBYINDEX(icf->list[d.seq].tz)
; patient info
,person_id = icf->list[d.seq].person_id
,patient = icf->list[d.seq].patient
,edipi = icf->list[d.seq].edipi
,birth_dt_tm = icf->list[d.seq].birth_dt_tm
,age_at_event = icf->list[d.seq].age_at_event
,admin_sex = icf->list[d.seq].admin_sex
,race = icf->list[d.seq].race
,ethnicity = icf->list[d.seq].ethnicity
,military_status = icf->list[d.seq].military_status
,test_patient_ind = icf->list[d.seq].test_patient_ind
,event_id = icf->list[d.seq].event_id
,event_cd = icf->list[d.seq].event_cd
,event = icf->list[d.seq].event
,event_dt_tm = DATETIMEZONEFORMAT(icf->list[d.seq].event_dt_tm,
icf->list[d.seq].tz, "MM/DD/YYYY HH:MM;;q")
,result = icf->list[d.seq].result
,result_units = icf->list[d.seq].result_units
,result_status = icf->list[d.seq].result_status
,result_source = icf->list[d.seq].result_source
,contrib_sys = icf->list[d.seq].contrib_sys
,entry_mode = icf->list[d.seq].entry_mode
,event_class = icf->list[d.seq].event_class
,performing_prsnl = icf->list[d.seq].performing_prsnl
,verifying_prsnl = icf->list[d.seq].verifying_prsnl
FROM (DUMMYT d with seq = value(size(icf->list, 5)))
PLAN d WHERE OPERATOR(icf->list[d.seq].test_patient_ind, tp_var, 0)
ORDER BY encntr_id, event_id
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
print(CONCAT(^<td>Type: ^, icf->list[d.seq].encntr_type, ^ (^,
eda("encntr", icf->list[d.seq].encntr_id, "Encounter
History", "History"),
^)</td>^))
row+1        call
print(CONCAT(^<td>FIN: ^, chartlink(icf->list[d.seq].person_id,
icf->list[d.seq].encntr_id, icf->list[d.seq].fin),
^</td>^))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id,
"Charges", "Charges")))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id,
"Diagnoses", "Diagnoses")))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id, "Clinical
Events", "Events")))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id, "Lab
Results", "Lab Results")))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id,
"Medication Administration", "Med Admin")))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id,
"Documentation", "Notes")))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id, "Orders
(all)", "Orders")))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id, "Vital
Signs", "Vital Signs")))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id,
"Registration (PIP)", "Registration")))
row+1 ^</tr>^
row+1 ^<tr>^
row+1        ^<td
style='text-align: right;'>Patient: </td>^
row+1        call
print(td(eda("person", icf->list[d.seq].person_id, "Identity
and Demographics", icf->list[d.seq].patient)))
row+1        call
print(CONCAT(^<td>EDIPI: ^, icf->list[d.seq].edipi, ^</td>^))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id,
"Allergies", "Allergies")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id,
"Medication List", "Medications")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id, "Problem
List", "Problem List")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id,
"Procedures", "Procedure History")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id, "Family
History", "Family History")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id, "Social
History", "Social History")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id, "Health
Plans", "Health Plans")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id,
"Aliases", "Other Identifiers")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id, "User
Defined Fields", "Other Info")))
row+1 ^</tr>^
row+1 ^</table>^
row+1 ^<p></p>^
FOOT REPORT
row+1 ^</body>^
row+1 ^</html>^
ELSEIF($search_for
= "Diagnoses" AND $rpt = "Summary")
diagnosis_code = n.source_identifier
,diagnosis_text = n.source_string
,ag.agency
,facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,test_patient_ind = UAR_GET_CODE_DISPLAY(tpi.value_cd)
,nbr_diagnoses = COUNT(d.diagnosis_id)
,nbr_patients = COUNT(d.person_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
FROM DIAGNOSIS d
,(LEFT JOIN PERSON_INFO tpi ON tpi.person_id = d.person_id
AND tpi.info_sub_type_cd = 2678703703 ;test patient identifier
AND tpi.value_cd != 2678703509 ;"not a test patient"
AND tpi.active_ind = 1)
,ENCOUNTER e
,(LEFT JOIN CUST_LOC_AGENCY_RELTN ag ON ag.location_cd =
e.loc_facility_cd)
,NOMENCLATURE
n
PLAN d WHERE EXPAND(dx_idx, 1, size(dx->list, 5), d.nomenclature_id,
dx->list[dx_idx].nomenclature_id)
 AND d.end_effective_dt_tm >
SYSDATE
 AND d.active_ind = 1
JOIN e WHERE e.encntr_id = d.encntr_id
AND e.disch_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND EXPAND(fac_idx, 1, size(fac->facility, 5),
e.loc_facility_cd, fac->facility[fac_idx].facility_cd)
AND e.active_ind = 1
JOIN n WHERE n.nomenclature_id = d.nomenclature_id
AND n.active_ind = 1
JOIN ag
JOIN tpi
GROUP BY n.source_identifier, n.source_string, ag.agency,
e.loc_facility_cd, tpi.value_cd
ORDER BY diagnosis_code, ag.agency, facility, test_patient_ind
ELSEIF($search_for
= "Diagnoses" AND $rpt = "Detail")
; encntr info
encntr_id = cf->list[d.seq].encntr_id
,fin = cf->list[d.seq].fin
,encntr_type = cf->list[d.seq].encntr_type
,med_service = cf->list[d.seq].med_service
,agency = cf->list[d.seq].agency
,facility = cf->list[d.seq].facility
,nurse_unit = cf->list[d.seq].nurse_unit
,reg_dt_tm = DATETIMEZONEFORMAT(cf->list[d.seq].reg_dt_tm,
cf->list[d.seq].tz, "MM/DD/YYYY HH:MM;;q")
,disch_dt_tm = DATETIMEZONEFORMAT(cf->list[d.seq].disch_dt_tm,
cf->list[d.seq].tz, "MM/DD/YYYY HH:MM;;q")
,disch_dispo = cf->list[d.seq].disch_dispo
,tz = DATETIMEZONEBYINDEX(cf->list[d.seq].tz)
; patient info
,person_id = cf->list[d.seq].person_id
,patient = cf->list[d.seq].patient
,edipi = cf->list[d.seq].edipi
,birth_dt_tm = cf->list[d.seq].birth_dt_tm
,age_at_event = cf->list[d.seq].age_at_event
,admin_sex = cf->list[d.seq].admin_sex
,race = cf->list[d.seq].race
,ethnicity = cf->list[d.seq].ethnicity
,military_status = cf->list[d.seq].military_status
,test_patient_ind = cf->list[d.seq].test_patient_ind
; diagnosis info
,nomenclature_id = cf->list[d.seq].nomenclature_id
,diagnosis_id = cf->list[d.seq].diagnosis_id
,diag_type = cf->list[d.seq].diag_type
,diag_source = cf->list[d.seq].diag_source
,diag_dt_tm = DATETIMEZONEFORMAT(cf->list[d.seq].diag_dt_tm,
cf->list[d.seq].tz, "MM/DD/YYYY HH:MM;;q")
,diag_prsnl = cf->list[d.seq].diag_prsnl
,diagnosis = cf->list[d.seq].diagnosis
,diagnosis_code_text = cf->list[d.seq].diagnosis_code_text
,diagnosis_code = cf->list[d.seq].diagnosis_code
,diag_priority = cf->list[d.seq].diag_priority
,contrib_sys = cf->list[d.seq].contrib_sys
FROM (DUMMYT d with seq = value(size(cf->list, 5)))
PLAN d WHERE OPERATOR(cf->list[d.seq].test_patient_ind, tp_var, 0)
ORDER BY encntr_id, diagnosis_id
ELSEIF($search_for
= "Diagnoses" AND $rpt = "Interactive")
; encntr info
encntr_id = icf->list[d.seq].encntr_id
,fin = icf->list[d.seq].fin
,encntr_type = icf->list[d.seq].encntr_type
,med_service = icf->list[d.seq].med_service
,agency = icf->list[d.seq].agency
,facility = icf->list[d.seq].facility
,nurse_unit = icf->list[d.seq].nurse_unit
,reg_dt_tm = DATETIMEZONEFORMAT(icf->list[d.seq].reg_dt_tm,
icf->list[d.seq].tz, "MM/DD/YYYY HH:MM;;q")
,disch_dt_tm = DATETIMEZONEFORMAT(icf->list[d.seq].disch_dt_tm,
icf->list[d.seq].tz, "MM/DD/YYYY HH:MM;;q")
,disch_dispo = icf->list[d.seq].disch_dispo
,tz = DATETIMEZONEBYINDEX(icf->list[d.seq].tz)
; patient info
,person_id = icf->list[d.seq].person_id
,patient = icf->list[d.seq].patient
,edipi = icf->list[d.seq].edipi
,birth_dt_tm = icf->list[d.seq].birth_dt_tm
,age_at_event = icf->list[d.seq].age_at_event
,admin_sex = icf->list[d.seq].admin_sex
,race = icf->list[d.seq].race
,ethnicity = icf->list[d.seq].ethnicity
,military_status = icf->list[d.seq].military_status
,test_patient_ind = icf->list[d.seq].test_patient_ind
; diagnosis info
,nomenclature_id = icf->list[d.seq].nomenclature_id
,diagnosis_id = icf->list[d.seq].diagnosis_id
,diag_type = icf->list[d.seq].diag_type
,diag_source = icf->list[d.seq].diag_source
,diag_dt_tm = DATETIMEZONEFORMAT(icf->list[d.seq].diag_dt_tm,
icf->list[d.seq].tz, "MM/DD/YYYY HH:MM;;q")
,diag_prsnl = icf->list[d.seq].diag_prsnl
,diagnosis = icf->list[d.seq].diagnosis
,diagnosis_code_text = icf->list[d.seq].diagnosis_code_text
,diagnosis_code = icf->list[d.seq].diagnosis_code
,diag_priority = icf->list[d.seq].diag_priority
,contrib_sys = icf->list[d.seq].contrib_sys
FROM (DUMMYT d with seq = value(size(icf->list, 5)))
PLAN d WHERE OPERATOR(icf->list[d.seq].test_patient_ind, tp_var, 0)
ORDER BY encntr_id, diagnosis_id
 HEAD REPORT
i = 0
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
i += 1
;table & header
row+1 ^<table border='1'>^
row+1 ^<tr>^
row+1        ^<th>&nbsp;</th>^
row+1
        ^<th>Diagnosis
Date/Time</th>^
row+1
        ^<th>Code</th>^
row+1        ^<th
colspan=2>Coded Diagnosis</th>^
row+1        ^<th
colspan=2>Selected Diagnosis</th>^
row+1        ^<th>Priority</th>^
row+1
        ^<th>Provider</th>^
row+1
        ^<th>Source</th>^
row+1
        ^<th>Type</th>^
row+1        ^<th>System</th>^
row+1 ^</tr>^
row+1 ^<tr>^ ;first row with result information
row+1        call
print(td(CNVTSTRING(i)))
row+1        call
print(td(diag_dt_tm))
row+1        call
print(td(diagnosis_code))
row+1        call
print(td2(diagnosis_code_text))
row+1        call
print(td2(diagnosis))
row+1        call
print(td(diag_priority))
row+1        call
print(td(diag_prsnl))
row+1        call
print(td(diag_source))
row+1        call
print(td(diag_type))
row+1        call
print(td(contrib_sys))
row+1 ^</tr>^
row+1 ^<tr></tr>^
row+1 ^<tr>^
row+1        ^<td
style='text-align: right;'>Encounter: </td>^
row+1        call
print(CONCAT(^<td>Type: ^, icf->list[d.seq].encntr_type, ^ (^,
eda("encntr", icf->list[d.seq].encntr_id, "Encounter
History", "History"),
^)</td>^))
row+1        call
print(CONCAT(^<td>FIN: ^, chartlink(icf->list[d.seq].person_id,
icf->list[d.seq].encntr_id, icf->list[d.seq].fin),
^</td>^))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id,
"Charges", "Charges")))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id,
"Diagnoses", "Diagnoses")))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id, "Clinical
Events", "Events")))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id, "Lab
Results", "Lab Results")))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id,
"Medication Administration", "Med Admin")))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id,
"Documentation", "Notes")))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id, "Orders
(all)", "Orders")))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id, "Vital
Signs", "Vital Signs")))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id,
"Registration (PIP)", "Registration")))
row+1 ^</tr>^
row+1 ^<tr>^
row+1        ^<td
style='text-align: right;'>Patient: </td>^
row+1        call
print(td(eda("person", icf->list[d.seq].person_id, "Identity
and Demographics", icf->list[d.seq].patient)))
row+1        call
print(CONCAT(^<td>EDIPI: ^, icf->list[d.seq].edipi, ^</td>^))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id,
"Allergies", "Allergies")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id,
"Medication List", "Medications")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id, "Problem
List", "Problem List")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id,
"Procedures", "Procedure History")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id, "Family
History", "Family History")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id, "Social
History", "Social History")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id, "Health
Plans", "Health Plans")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id,
"Aliases", "Other Identifiers")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id, "User
Defined Fields", "Other Info")))
row+1 ^</tr>^
row+1 ^</table>^
row+1 ^<p></p>^
FOOT REPORT
row+1 ^</body>^
row+1 ^</html>^
ELSEIF($search_for
= "Orders" AND $rpt = "Summary" AND $order_option =
"orderable")
orderable = oc.description
,ag.agency
,facility = UAR_GET_CODE_DISPLAY(CNVTREAL(o.loc_facility_cd))
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
,e1.loc_facility_cd
FROM ORDERS o1
,ENCOUNTER e1
WHERE o1.catalog_cd = $orderable
AND o1.orig_order_dt_tm >= CNVTDATETIME($start_date)
AND o1.orig_order_dt_tm <= CNVTDATETIME($end_date)
AND o1.encntr_id != 0
AND o1.originating_encntr_id = 0
AND o1.order_status_cd NOT IN (2542, 2544) ;canceled, voided
         AND
o1.template_order_flag IN (0,1,5,7) ;exclude auto-generated child orders
         AND o1.active_ind = 1
         AND e1.encntr_id =
o1.encntr_id
         AND EXPAND(fac_idx, 1,
size(fac->facility, 5), e1.loc_facility_cd,
fac->facility[fac_idx].facility_cd)
UNION
(SELECT ;o only
o2.catalog_cd
,o2.order_id
,o2.person_id
,o2.encntr_id
,o2.originating_encntr_id
,eid = o2.originating_encntr_id
,e2.loc_facility_cd
FROM ORDERS o2
,ENCOUNTER e2
WHERE o2.catalog_cd = $orderable
AND o2.orig_order_dt_tm >= CNVTDATETIME($start_date)
AND o2.orig_order_dt_tm <= CNVTDATETIME($end_date)
AND o2.encntr_id = 0
AND o2.originating_encntr_id != 0
AND o2.order_status_cd NOT IN (2542, 2544) ;canceled, voided
         AND
o2.template_order_flag IN (0,1,5,7) ;exclude auto-generated child orders
         AND o2.active_ind = 1
         AND e2.encntr_id =
o2.originating_encntr_id
         AND EXPAND(fac_idx, 1,
size(fac->facility, 5), e2.loc_facility_cd,
fac->facility[fac_idx].facility_cd)
UNION
(SELECT ;e and o, are same - includes where both = 0
o3.catalog_cd
,o3.order_id
,o3.person_id
,o3.encntr_id
,o3.originating_encntr_id
,eid = o3.encntr_id
,e3.loc_facility_cd
FROM ORDERS o3
,ENCOUNTER e3
WHERE o3.catalog_cd = $orderable
AND o3.orig_order_dt_tm >= CNVTDATETIME($start_date)
AND o3.orig_order_dt_tm <= CNVTDATETIME($end_date)
AND o3.encntr_id = o3.originating_encntr_id
AND o3.order_status_cd NOT IN (2542, 2544) ;canceled, voided
         AND
o3.template_order_flag IN (0,1,5,7) ;exclude auto-generated child orders
         AND o3.active_ind = 1
         AND e3.encntr_id =
o3.encntr_id
         AND EXPAND(fac_idx, 1,
size(fac->facility, 5), e3.loc_facility_cd,
fac->facility[fac_idx].facility_cd)
UNION
(SELECT ;e and o, are different
o4.catalog_cd
,o4.order_id
,o4.person_id
,o4.encntr_id
,o4.originating_encntr_id
,eid = o4.originating_encntr_id
,e4.loc_facility_cd
FROM ORDERS o4
,ENCOUNTER e4
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
         AND e4.encntr_id =
o4.originating_encntr_id
         AND EXPAND(fac_idx, 1,
size(fac->facility, 5), e4.loc_facility_cd,
fac->facility[fac_idx].facility_cd)
) WITH
SQLTYPE("f8","f8","f8","f8","f8","f8","f8"),
RDBUNION))) o )
,(LEFT JOIN PERSON_INFO tp ON tp.person_id = CNVTREAL(o.person_id)
AND tp.info_sub_type_cd = 2678703703 ;test patient identifier
AND tp.value_cd != 2678703509 ;"not a test patient"
AND tp.active_ind = 1)
;,ENCOUNTER e
,(LEFT JOIN CUST_LOC_AGENCY_RELTN ag ON ag.location_cd =
CNVTREAL(o.loc_facility_cd))
,ORDER_CATALOG oc
PLAN o
;JOIN e WHERE e.encntr_id = CNVTREAL(o.eid)
;        AND EXPAND(fac_idx, 1,
size(fac->facility, 5), e.loc_facility_cd,
fac->facility[fac_idx].facility_cd)
JOIN oc WHERE oc.catalog_cd = CNVTREAL(o.catalog_cd)
JOIN tp
JOIN ag
GROUP BY oc.description, ag.agency, o.loc_facility_cd, tp.value_cd
ORDER BY orderable, ag.agency, facility, test_patient_ind
ELSEIF($search_for
= "Orders" AND $rpt = "Summary" AND $order_option =
"synonym")
orderable = o3.description
,ordered_as = o3.ordered_as_mnemonic
,o3.agency
,facility = UAR_GET_CODE_DISPLAY(o3.loc_facility_cd)
,test_patient_ind = UAR_GET_CODE_DISPLAY(o3.value_cd)
,nbr_orders = COUNT(o3.order_id)
,nbr_patients = COUNT(o3.person_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
FROM
((SELECT ;orders from activating encounters
oc.description
,o.ordered_as_mnemonic
,ag.agency
,e.loc_facility_cd
,tpi.value_cd
,o.person_id
,o.order_id
FROM ORDER_CATALOG oc
,ORDERS o
,ENCOUNTER e
,CUST_LOC_AGENCY_RELTN ag
,PERSON_INFO tpi
WHERE o.synonym_id = $order_syn
AND o.catalog_cd = oc.catalog_cd
AND o.orig_order_dt_tm >= CNVTDATETIME($start_date)
AND o.orig_order_dt_tm <= CNVTDATETIME($end_date)
AND o.order_status_cd NOT IN (2542, 2544) ;canceled, voided
         AND
o.template_order_flag IN (0,1,5,7) ;exclude auto-generated child orders
AND o.originating_encntr_id = 0
AND o.active_ind = 1
AND o.encntr_id = e.encntr_id
AND e.loc_facility_cd = outerjoin(ag.location_cd)
AND tpi.person_id = outerjoin(o.person_id)
AND tpi.info_sub_type_cd = outerjoin(2678703703) ;test patient
identifier
AND tpi.value_cd != outerjoin(2678703509) ;"not a test
patient"
AND tpi.active_ind = outerjoin(1)
UNION
(SELECT ;orders from originating encounters
oc2.description
,o2.ordered_as_mnemonic
,ag2.agency
,e2.loc_facility_cd
,tpi2.value_cd
,o2.person_id
,o2.order_id
FROM ORDER_CATALOG oc2
,ORDERS o2
,ENCOUNTER e2
,CUST_LOC_AGENCY_RELTN ag2
,PERSON_INFO tpi2
WHERE o2.synonym_id = $order_syn
AND o2.catalog_cd = oc2.catalog_cd
AND o2.orig_order_dt_tm >= CNVTDATETIME($start_date)
AND o2.orig_order_dt_tm <= CNVTDATETIME($end_date)
AND o2.order_status_cd NOT IN (2542, 2544) ;canceled, voided
         AND
o2.template_order_flag IN (0,1,5,7) ;exclude auto-generated child orders
AND o2.originating_encntr_id != 0
AND o2.active_ind = 1
AND o2.originating_encntr_id = e2.encntr_id
AND ag2.location_cd = outerjoin(e2.loc_facility_cd)
AND tpi2.person_id = outerjoin(o2.person_id)
AND tpi2.info_sub_type_cd = outerjoin(2678703703) ;test patient
identifier
AND tpi2.value_cd != outerjoin(2678703509) ;"not a test
patient"
AND tpi2.active_ind = outerjoin(1)
) WITH
SQLTYPE("c100","vc","c40","f8","f8","f8","f8"),
RDBUNION) o3)
WHERE EXPAND(fac_idx, 1, size(fac->facility, 5), o3.loc_facility_cd,
fac->facility[fac_idx].facility_cd)
GROUP BY o3.description, o3.ordered_as_mnemonic, o3.agency,
o3.loc_facility_cd, o3.value_cd
ORDER BY orderable, o3.agency, facility, test_patient_ind
ELSEIF($search_for
= "Orders*" AND $rpt = "Detail")
; encntr info
encntr_id = cf->list[d.seq].encntr_id
,fin = cf->list[d.seq].fin
,encntr_type = cf->list[d.seq].encntr_type
,med_service = cf->list[d.seq].med_service
,agency = cf->list[d.seq].agency
,facility = cf->list[d.seq].facility
,nurse_unit = cf->list[d.seq].nurse_unit
,reg_dt_tm = DATETIMEZONEFORMAT(cf->list[d.seq].reg_dt_tm,
cf->list[d.seq].tz, "MM/DD/YYYY HH:MM;;q")
,disch_dt_tm = DATETIMEZONEFORMAT(cf->list[d.seq].disch_dt_tm,
cf->list[d.seq].tz, "MM/DD/YYYY HH:MM;;q")
,disch_dispo = cf->list[d.seq].disch_dispo
,tz = DATETIMEZONEBYINDEX(cf->list[d.seq].tz)
; patient info
,person_id = cf->list[d.seq].person_id
,patient = cf->list[d.seq].patient
,edipi = cf->list[d.seq].edipi
,birth_dt_tm = cf->list[d.seq].birth_dt_tm
,age_at_event = cf->list[d.seq].age_at_event
,admin_sex = cf->list[d.seq].admin_sex
,race = cf->list[d.seq].race
,ethnicity = cf->list[d.seq].ethnicity
,military_status = cf->list[d.seq].military_status
,test_patient_ind = cf->list[d.seq].test_patient_ind
; order info
,order_id = cf->list[d.seq].order_id
,catalog_cd = cf->list[d.seq].catalog_cd
,synonym_id = cf->list[d.seq].synonym_id
,order_dt_tm = DATETIMEZONEFORMAT(cf->list[d.seq].order_dt_tm,
cf->list[d.seq].tz, "MM/DD/YYYY HH:MM;;q")
,orderable = cf->list[d.seq].orderable
,primary_mnemonic = cf->list[d.seq].primary_mnemonic
,ordered_as_mnemonic = cf->list[d.seq].ordered_as_mnemonic
,catalog_type = cf->list[d.seq].order_catalog_type
,activity_subtype = cf->list[d.seq].order_subtype
,clinical_display =
SUBSTRING(1,255,replace_CRLF(cf->list[d.seq].order_clinical_display))
,order_detail =
SUBSTRING(1,255,replace_CRLF(cf->list[d.seq].order_detail))
,order_status = cf->list[d.seq].order_status
,dept_status = cf->list[d.seq].order_dept_status
,order_entry_prsnl = cf->list[d.seq].order_entry_prsnl
,order_provider = cf->list[d.seq].order_provider
,comms_type = cf->list[d.seq].order_comms_type
FROM (DUMMYT d with seq = value(size(cf->list, 5)))
PLAN d WHERE OPERATOR(cf->list[d.seq].test_patient_ind, tp_var, 0)
ORDER BY encntr_id, order_id
ELSEIF($search_for
= "Orders*" AND $rpt = "Interactive")
; encntr info
encntr_id = icf->list[d.seq].encntr_id
,fin = icf->list[d.seq].fin
,encntr_type = icf->list[d.seq].encntr_type
,med_service = icf->list[d.seq].med_service
,agency = icf->list[d.seq].agency
,facility = icf->list[d.seq].facility
,nurse_unit = icf->list[d.seq].nurse_unit
,reg_dt_tm = DATETIMEZONEFORMAT(icf->list[d.seq].reg_dt_tm,
icf->list[d.seq].tz, "MM/DD/YYYY HH:MM;;q")
,disch_dt_tm = DATETIMEZONEFORMAT(icf->list[d.seq].disch_dt_tm,
icf->list[d.seq].tz, "MM/DD/YYYY HH:MM;;q")
,disch_dispo = icf->list[d.seq].disch_dispo
,tz = DATETIMEZONEBYINDEX(icf->list[d.seq].tz)
; patient info
,person_id = icf->list[d.seq].person_id
,patient = icf->list[d.seq].patient
,edipi = icf->list[d.seq].edipi
,birth_dt_tm = icf->list[d.seq].birth_dt_tm
,age_at_event = icf->list[d.seq].age_at_event
,admin_sex = icf->list[d.seq].admin_sex
,race = icf->list[d.seq].race
,ethnicity = icf->list[d.seq].ethnicity
,military_status = icf->list[d.seq].military_status
,test_patient_ind = icf->list[d.seq].test_patient_ind
; order info
,order_id = icf->list[d.seq].order_id
,catalog_cd = icf->list[d.seq].catalog_cd
,synonym_id = icf->list[d.seq].synonym_id
,order_dt_tm = DATETIMEZONEFORMAT(icf->list[d.seq].order_dt_tm,
icf->list[d.seq].tz, "MM/DD/YYYY HH:MM;;q")
,orderable = icf->list[d.seq].orderable
,primary_mnemonic = icf->list[d.seq].primary_mnemonic
,ordered_as_mnemonic = icf->list[d.seq].ordered_as_mnemonic
,catalog_type = icf->list[d.seq].order_catalog_type
,activity_subtype = icf->list[d.seq].order_subtype
,clinical_display =
SUBSTRING(1,255,replace_CRLF(icf->list[d.seq].order_clinical_display))
,order_detail =
SUBSTRING(1,255,replace_CRLF(icf->list[d.seq].order_detail))
,order_status = icf->list[d.seq].order_status
,dept_status = icf->list[d.seq].order_dept_status
,order_entry_prsnl = icf->list[d.seq].order_entry_prsnl
,order_provider = icf->list[d.seq].order_provider
,comms_type = icf->list[d.seq].order_comms_type
FROM (DUMMYT d with seq = value(size(icf->list, 5)))
PLAN d WHERE OPERATOR(icf->list[d.seq].test_patient_ind, tp_var, 0)
ORDER BY person_id, encntr_id, order_id
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
 ^<tr>^
^<th>&nbsp;</th>^
         ^<th>Order
Date/Time</th>^
         ^<th>Order</th>^
^<th>Ordered As</th>^
         ^<th>Order
Type</th>^
         ^<th>Order
Subtype</th>^
         ^<th>Order
Status</th>^
         ^<th>Provider</th>^
         ^<th
style="width: 80px;">Summary Views</th>^
         ^<th>Order
Details</th>^
         ^<th>Order
Comments</th>^
         ^<th>Order
History</th>^
 ^</tr>^
row+1 ^<tr>^ ;first row with result information
row+1        call
print(td(CNVTSTRING(i)))
row+1        call
print(td(order_dt_tm))
row+1        call
print(td(orderable))
row+1        call
print(td(ordered_as_mnemonic))
row+1        call
print(td(catalog_type))
row+1        call
print(td(activity_subtype))
row+1        call
print(td(order_status))
row+1        call
print(td(order_provider))
row+1        ^<td
style="text-align: center;">^
call print(oda(order_id, "Order Info (generic view)",
"Generic"))
^</br>^
call print(oda(order_id, "Order Info (laboratory view)",
"Lab"))
^ | ^
call print(oda(order_id, "Order Info (radiology view)",
"Rad"))
^ | ^
call print(oda(order_id, "Order Info (pharmacy view)",
"Rx"))
^</td>^
row+1        call
print(td(oda(order_id, "Order Details", "Details")))
row+1        call
print(td(oda(order_id, "Order Comments", "Comments")))
row+1        call
print(td(oda(order_id, "Order Actions", "History")))
row+1 ^</tr>^
row+1 ^<tr></tr>^
row+1 ^<tr>^
row+1        ^<td
style='text-align: right;'>Encounter: </td>^
row+1        call
print(CONCAT(^<td>Type: ^, icf->list[d.seq].encntr_type, ^ (^,
eda("encntr", icf->list[d.seq].encntr_id, "Encounter
History", "History"),
^)</td>^))
row+1        call
print(CONCAT(^<td>FIN: ^, chartlink(icf->list[d.seq].person_id,
icf->list[d.seq].encntr_id, icf->list[d.seq].fin),
^</td>^))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id,
"Charges", "Charges")))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id,
"Diagnoses", "Diagnoses")))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id, "Clinical
Events", "Events")))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id, "Lab
Results", "Lab Results")))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id,
"Medication Administration", "Med Admin")))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id,
"Documentation", "Notes")))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id, "Orders
(all)", "Orders")))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id, "Vital
Signs", "Vital Signs")))
row+1        call
print(td(eda("encntr", icf->list[d.seq].encntr_id,
"Registration (PIP)", "Registration")))
row+1 ^</tr>^
row+1 ^<tr>^
row+1        ^<td
style='text-align: right;'>Patient: </td>^
row+1        call
print(td(eda("person", icf->list[d.seq].person_id, "Identity
and Demographics", icf->list[d.seq].patient)))
row+1        call
print(CONCAT(^<td>EDIPI: ^, icf->list[d.seq].edipi, ^</td>^))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id,
"Allergies", "Allergies")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id,
"Medication List", "Medications")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id, "Problem
List", "Problem List")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id,
"Procedures", "Procedure History")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id, "Family
History", "Family History")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id, "Social
History", "Social History")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id, "Health
Plans", "Health Plans")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id,
"Aliases", "Other Identifiers")))
row+1        call
print(td(eda("person", icf->list[d.seq].person_id, "User
Defined Fields", "Other Info")))
row+1 ^</tr>^
row+1 ^</table>^
row+1 ^<p></p>^
FOOT REPORT
row+1 ^</body>^
row+1 ^</html>^
ENDIF
INTO $OUTDEV
error = "fallback reached"
WITH
NOCOUNTER, SEPARATOR=" ", FORMAT, CHECK, TIME=1000
,EXPAND=2, MAXREC=10000, MAXCOL=1000
,ORAHINTCBO("GATHER_PLAN_STATISTICS","DALT_CF_1")
end
go
