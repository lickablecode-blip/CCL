/*
 * Source page  : Encounter Detail Audit
 * Source file  : output/encounter-detail-audit.md
 * Anchor       : (top of page)
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 6684
 *
 * Context (preceding paragraph):
 *   Exported on: 4/15/26
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

drop program
dev_rpt_encntr_detail_audit2 go
create
program dev_rpt_encntr_detail_audit2
/******************************************************************************
 REPORT NAME:
        Encounter Detail Audit
 PROGRAM-PUB:        1fed_rpt_encntr_detail_audit2.prg
 PROGRAM-DEV:        dev_rpt_encntr_detail_audit2.prg
 DEVELOPER:        David Alt
(david.a.alt2.mil@health.mil)
 PUBLISHED:        6/4/2025
(original: 2022)
 SNAPSHOT:                4/14/2026
 LOGICAL
PATH:        cust_script:
 NODE:                        <default>
 PURPOSE/DESCRIPTION: This collection of reports assists technical
users with
                                          data quality and configuration
investigations by exposing
                                          raw data around common concepts.
 TARGET AUDIENCE: Technical users, solution experts/owners,
data quality investigators
 DEPENDENCIES:
         dev_rpt_blob_out.prg
         dev_rpt_ce_susceptibility.prg
         dev_rpt_order_detail_audit.prg
MOD        DATE                DEVELOPER        COMMENT
---        --/--/--        ---------        ----------------------------
000        12/01/24        David
Alt        Overhaul work started
000        01/14/25        David
Alt        Ready for initial jazz
review
001        03/06/25        David
Alt        Added person-level profile
to Patient->Health Plans
Added dynamic label to Encounter->Clinical Events
002        03/21/25        David
Alt        Added
Encounter->Scheduling Actions
003        03/31/25        David
Alt        Enhanced security
004        05/14/25        David
Alt        Publication review
Added Encounter->Orders (interactive)
Added Patient->Past Encounters (interactive)
Converted Patient->Special Duty Status (history) to interactive
005        06/04/25        David
Alt        Added birth sex to
Patient->Identity and Demographics
renamed sex->admin_sex
006        06/09/25        David
Alt        Added Encounter->Alert
Escalation Messages
Added Patient->Emergency Contacts
007        06/18/25        David
Alt        Updated
Patient->Transfusion history
008        06/27/25        David
Alt        Added DISTINCT to
Encounter->Lab Results
009        07/08/25        David
Alt        Fixed Patient->Health
Plans (profile to left join)
010        07/15/25        David
Alt        Added Patient->Passive
Alerts
011        07/17/25        David
Alt        Added species to
Patient->Identity and Demographics
012        07/21/25        David
Alt        Filtered rescheduled appts
from Encounter->Scheduling Actions, added appt status
013        08/06/25        David
Alt        Removed active_ind from
input filter to allow loading of canceled FINs
Did NOT remove from output filters b/c could explode results. Revisit
if needed.
014        08/12/25        David
Alt        Rewrote join logic for
Encounter->Health Plans and Patient->Health Plans
015        08/13/25        David
Alt        Changed CLINICAL_EVENT
view_level logic; was excluding iview dynamic groups
Added Patient->Person Relationships
Rewrote Encounter->Registration (PIP), field names changed
016        09/03/25        David
Alt        Added extension to
Patient->Contact Info (phone numbers)
017        10/20/25        David
Alt        Modded Encounter->Charges
for consistent end_effective_dt_tm/active_ind use
018        10/21/25        David
Alt        Modded
Patient->Appointments (past) to include no-shows
019        11/20/25        David
Alt        Modded
Encounter->Documentation to include DHMSM (HL7) alias
020        12/10/25        David
Alt        Modded
Encounter->Encounter History to include admit type
021        12/15/25        David
Alt        Added
Encounter->Transfusions
022        01/08/26        David
Alt        Modded Encounter->Alerts
to include version, validation
023        01/16/26        David
Alt        Reordered fields in
Patient->Health Plans to match RevCycle
Rebuilt Patient->Health Plans to better match RevCycle
024        01/21/26        David
Alt        Further revisions to both
Health Plans reports to match RevCycle
025        01/21/26        David
Alt        Added Patient->Employer
History
026        01/30/26        David
Alt        Modded Personnel
Relationships to include prsnl_id
027        02/06/26        David
Alt        Modded Patient->Identity
to show death age as current age
028        02/11/26        David
Alt        Added
Encounter->Documentation (interactive)
029        02/24/26        David
Alt        Modded
Encounter->Documentation to better match PowerChart list
030        03/09/26        David
Alt        Improvements to report
security
031        03/16/26        David
Alt        Added
Encounter->Microbiology Results
032        03/18/26        David
Alt        Modded
Encounter->Clinical Events reports to include AP results
Added Encounter->Pathology Results
033        03/23/26        David
Alt        Modded Patient->Past
Encounters (interactive) - new table layout
034        04/14/26        David
Alt        Added Patient->Pathology
Results
Modded Encounter->Pathology Results
----------- UNPUBLISHED
---------------
; ### TODO
; Consider
Encounter->Messages
; Consider
Patient->Message History
; Consider
Patient->Pregnancy History
; Consider
Patient->Health Maintenance
; Consider
adding PPD results to Immunizations
; Work on
Patient->EDI column usefulness/ordering; do we need EXT_DATA_GROUP?
******************************************************************************/
prompt
"Output to File/Printer/MINE" = "MINE" ;* Enter or select the printer or file name
to send this report to.
, "Identifier" = ""
, "Type" = "FIN"
, "Type" = "EDIPI"
, "Category" = "encounter"
, "Report" = ""
, "Report" = ""
with OUTDEV,
identifier, eid_type, pid_type, cat, enc_rpt, pat_rpt
/**************************************************************
; Global
Declarations
**************************************************************/
%I
cust_script:dod_env_params.inc
declare idx =
i4 with protect ;index variable for expand
/**************************************************************
; Record
Structures
**************************************************************/
free record
ids
record ids (
1 input = c30
1 input_cat = c10
1 input_type = c15
1 success_ind = i2
1 person_id = f8
1 encntr_id = f8
1 loc_facility_cd = f8
1 organization_id = f8
1 fin = c30
1 tz = i4
1 access_allowed = i2
) with
protect
free record
elh ;encounter location history
record elh
(        ;stores elh rows where
location actually changed
1 list[*]
2 encntr_loc_hist_id = f8
) with
protect
free record
orx ;order - rx, i.e. pharmacy orders
record orx (
1 list[*]
2 order_id = f8
2 str_dose = c40
2 str_dose_unit = c40
2 vol_dose = c40
2 vol_dose_unit = c40
2 rate = c40
2 rate_unit = c40
2 rx_route = c40
2 drug_form = c40
2 freq = c40
2 prn = c40
2 prn_reason = c250
2 duration = c40
2 duration_unit = c40
) with
protect
/**************************************************************
; SUBROUTINES
**************************************************************/
; Builds the
ids ("identifiers") record
subroutine
(build_ids(input=null) = null)
;store the prompt values for testing
SET ids->input = $identifier
SET ids->input_cat = $cat
IF($cat = "encounter")
SET ids->input_type = $eid_type
ELSE
SET ids->input_type = $pid_type
ENDIF
;set access_allowed to -1 as "n/a", e.g. for patient-level
searches
SET ids->access_allowed = -1
;retrieve the encntr_id or person_id
IF($cat = "encounter")
IF($eid_type = "FIN")
                                SET
ids->encntr_id = get_eid_from_fin($identifier)
ELSEIF($eid_type = ".encntr_id")
        SET ids->encntr_id =
get_eid_from_eid($identifier)
ELSEIF($eid_type = ".surg_case_id") SET ids->encntr_id =
get_eid_from_scid($identifier)
ENDIF
SET ids->tz = get_encntr_tz(ids->encntr_id)
SET ids->access_allowed = check_eid(ids->encntr_id)
SET ids->fin = get_fin_from_eid(ids->encntr_id)
SET ids->person_id = get_pid_from_eid(CNVTSTRING(ids->encntr_id,
30)) ;validate this works
ELSEIF($cat = "patient")
IF($pid_type = "FIN")
                                SET
ids->person_id = get_pid_from_fin($identifier)
ELSEIF($pid_type = ".encntr_id")
        SET ids->person_id =
get_pid_from_eid($identifier)
ELSEIF($pid_type = ".surg_case_id") SET ids->person_id =
get_pid_from_scid($identifier)
ELSEIF($pid_type = "EDIPI")
                SET
ids->person_id = get_pid_from_edipi($identifier)
ELSEIF($pid_type = "MRN")
                        SET
ids->person_id = get_pid_from_mrn($identifier)
ELSEIF($pid_type =
"SSN")                        SET
ids->person_id = get_pid_from_ssn($identifier)
ELSEIF($pid_type = ".person_id")
        SET ids->person_id =
get_pid_from_pid($identifier)
ENDIF
ELSE SET ids->success_ind = 0
ENDIF
end
;build_ids
; Get
encntr_id from FIN
subroutine
(get_eid_from_fin(input=c30) = f8)
DECLARE output = f8
SELECT INTO "NL:"
FROM ENCNTR_ALIAS fin
PLAN fin WHERE fin.alias = input
AND fin.encntr_alias_type_cd = 1077 ;FIN
;AND fin.active_ind = 1 ; prevented users from investigating canceled
FINs
DETAIL
IF(fin.encntr_id != 0)
output = fin.encntr_id
ids->success_ind = 1
ELSE ids->success_ind = 0
ENDIF
WITH nocounter
RETURN (output)
end
;get_eid_from_fin
; Get
encntr_id (float) from encntr_id (string)
subroutine
(get_eid_from_eid(input=c30) = f8)
DECLARE output = f8
SELECT INTO "NL:"
FROM ENCOUNTER e
PLAN e WHERE e.encntr_id = CNVTREAL(input)
AND e.active_ind = 1
DETAIL
IF(e.encntr_id != 0)
output = e.encntr_id
ids->success_ind = 1
ELSE ids->success_ind = 0
ENDIF
WITH nocounter
RETURN (output)
end
;get_eid_from_eid
; Get
encntr_id from surg_case_id (string)
subroutine
(get_eid_from_scid(input=c30) = f8)
DECLARE output = f8
SELECT INTO "NL:"
FROM SURGICAL_CASE sc
PLAN sc WHERE sc.surg_case_id = CNVTREAL(input)
AND sc.active_ind = 1
DETAIL
IF(sc.surg_case_id != 0)
output = sc.encntr_id
ids->success_ind = 1
ELSE ids->success_ind = 0
ENDIF
WITH nocounter
RETURN (output)
end
;get_eid_from_scid
; Get
person_id from FIN
subroutine
(get_pid_from_fin(input=c30) = f8)
DECLARE output = f8
SELECT INTO "NL:"
FROM ENCNTR_ALIAS fin
,ENCOUNTER e
PLAN fin WHERE fin.alias = input
AND fin.encntr_alias_type_cd = 1077 ;FIN
JOIN e WHERE e.encntr_id = fin.encntr_id
DETAIL
IF(fin.encntr_id != 0)
output = e.person_id
ids->success_ind = 1
ELSE ids->success_ind = 0
ENDIF
WITH nocounter
RETURN (output)
end
;get_pid_from_fin
; Get
person_id from encntr_id (string)
subroutine
(get_pid_from_eid(input=c30) = f8)
DECLARE output = f8
SELECT INTO "NL:"
FROM ENCOUNTER e
PLAN e WHERE e.encntr_id = CNVTREAL(input)
AND e.active_ind = 1
DETAIL
IF(e.encntr_id != 0)
output = e.person_id
ids->success_ind = 1
ELSE ids->success_ind = 0
ENDIF
WITH nocounter
RETURN (output)
end
;get_pid_from_eid
; Get
person_id from surg_case_id (string)
subroutine
(get_pid_from_scid(input=c30) = f8)
DECLARE output = f8
SELECT INTO "NL:"
FROM SURGICAL_CASE sc
PLAN sc WHERE sc.surg_case_id = CNVTREAL(input)
AND sc.active_ind = 1
DETAIL
IF(sc.surg_case_id != 0)
output = sc.person_id
ids->success_ind = 1
ELSE ids->success_ind = 0
ENDIF
WITH nocounter
RETURN (output)
end
;get_pid_from_scid
; Get
person_id from EDIPI
subroutine
(get_pid_from_edipi(input=c30) = f8)
DECLARE output = f8
SELECT INTO "NL:"
FROM PERSON_ALIAS edipi
,PERSON p
PLAN edipi WHERE edipi.alias = input
AND edipi.person_alias_type_cd = 22 ;EDIPI
AND edipi.active_ind = 1
JOIN p WHERE p.person_id = edipi.person_id
AND p.person_type_cd = 903 ;person
AND p.active_ind = 1
DETAIL
IF(edipi.person_id != 0)
output = edipi.person_id
ids->success_ind = 1
ELSE ids->success_ind = 0
ENDIF
WITH nocounter
RETURN (output)
end
;get_pid_from_edipi
; Get
person_id from MRN
subroutine
(get_pid_from_mrn(input=c30) = f8)
DECLARE output = f8
SELECT INTO "NL:"
FROM PERSON_ALIAS mrn
,PERSON p
PLAN mrn WHERE mrn.alias = input
AND mrn.alias_pool_cd = 105897385 ;MRN
AND mrn.active_ind = 1
JOIN p WHERE p.person_id = mrn.person_id
AND p.person_type_cd = 903 ;person
AND p.active_ind = 1
DETAIL
IF(mrn.person_id != 0)
output = mrn.person_id
ids->success_ind = 1
ELSE ids->success_ind = 0
ENDIF
WITH nocounter
RETURN (output)
end
;get_pid_from_mrn
; Get
person_id from SSN
subroutine
(get_pid_from_ssn(input=c30) = f8)
DECLARE output = f8
SELECT INTO "NL:"
FROM PERSON_ALIAS ssn
,PERSON p
PLAN ssn WHERE ssn.alias = input
AND ssn.person_alias_type_cd = 18 ;SSN
AND ssn.active_ind = 1
JOIN p WHERE p.person_id = ssn.person_id
AND p.person_type_cd = 903 ;person
AND p.active_ind = 1
DETAIL
IF(ssn.person_id != 0)
output = ssn.person_id
ids->success_ind = 1
ELSE ids->success_ind = 0
ENDIF
WITH nocounter
RETURN (output)
end
;get_pid_from_ssn
; Get
person_id (float) from person_id (string)
subroutine
(get_pid_from_pid(input=c30) = f8)
DECLARE output = f8
SELECT INTO "NL:"
FROM PERSON p
PLAN p WHERE p.person_id = CNVTREAL(input)
AND p.active_ind = 1
DETAIL
IF(p.person_id != 0)
output = p.person_id
ids->success_ind = 1
ELSE ids->success_ind = 0
ENDIF
WITH nocounter
RETURN (output)
end
;get_pid_from_pid
; Get FIN
from encntr_id; only call after encntr_id is extracted
subroutine
(get_fin_from_eid(input=f8) = c30)
DECLARE output = c30
SELECT INTO "NL:"
FROM ENCNTR_ALIAS fin
PLAN fin WHERE fin.encntr_id = ids->encntr_id
AND fin.encntr_alias_type_cd = 1077 ;FIN
AND fin.active_ind = 1
DETAIL
output = TRIM(fin.alias)
WITH nocounter
RETURN (output)
end
;get_fin_from_eid
; Extracts
the encounter time zone
subroutine
(get_encntr_tz(input=f8) = i4)
DECLARE output = i4
SELECT INTO "NL:"
tz = DATETIMEZONEBYNAME(tz.time_zone)
FROM ENCOUNTER e
,TIME_ZONE_R tz
PLAN e WHERE e.encntr_id = input
JOIN tz WHERE tz.parent_entity_id = e.loc_facility_cd
AND tz.parent_entity_name = "LOCATION"
DETAIL
output = DATETIMEZONEBYNAME(tz.time_zone)
WITH nocounter
RETURN (output)
end
;get_encntr_tz
; Evaluate
encounter location change bits
subroutine
(eval_elh_change_bit(change_bit=i4) = vc)
declare output = vc with protect
declare change_cnt = i2 with protect
declare trunc_len = i2 with protect
declare cb_accommodation_cd = i4 with protect,constant(1)
declare cb_accommodation_reason_cd = i4 with protect,constant(2)
declare cb_accommodation_request_cd = i4 with protect,constant(4)
declare cb_admit_type_cd = i4 with protect,constant(8)
declare cb_alt_lvl_care_cd = i4 with protect,constant(16)
declare cb_alc_decomp_dt_tm = i4 with protect,constant(32)
declare cb_alt_lvl_care_dt_tm = i4 with protect,constant(64)
declare cb_alc_reason_cd = i4 with protect,constant(128)
declare cb_arrive_dt_tm = i4 with protect,constant(256)
declare cb_depart_dt_tm = i4 with protect,constant(512)
declare cb_encntr_type_cd = i4 with protect,constant(1024)
declare cb_encntr_type_class_cd = i4 with protect,constant(2048)
declare cb_isolation_cd = i4 with protect,constant(4096)
declare cb_location_cd = i4 with protect,constant(8192)
declare cb_loc_facility_cd = i4 with protect,constant(16384)
declare cb_loc_building_cd = i4 with protect,constant(32768)
declare cb_loc_nurse_unit_cd = i4 with protect,constant(65536)
declare cb_loc_room_cd = i4 with protect,constant(131072)
declare cb_loc_bed_cd = i4 with protect,constant(262144)
declare cb_program_service_cd = i4 with protect,constant(524288)
declare cb_specialty_unit_cd = i4 with protect,constant(1048576)
declare        cb_organization_id
= i4 with protect,constant(2097152)
declare cb_med_service_cd = i4 with protect,constant(4194304)
declare cb_placement_auth_prsnl_id = i4 with protect,constant(8388608)
declare cb_security_access_cd = i4 with protect,constant(16777216)
declare cb_service_category_cd = i4 with
protect,constant(33554432)
set output = ""
set change_cnt = 0
IF(BAND(change_bit, cb_accommodation_cd) = cb_accommodation_cd)
set output = CONCAT(output, "accommodation_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_accommodation_reason_cd) =
cb_accommodation_reason_cd)
set output = CONCAT(output, "accommodation_reason_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_accommodation_request_cd) =
cb_accommodation_request_cd)
set output = CONCAT(output, "accommodation_request_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_admit_type_cd) = cb_admit_type_cd)
set output = CONCAT(output, "admit_type_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_alt_lvl_care_cd) = cb_alt_lvl_care_cd)
set output = CONCAT(output, "alt_lvl_care_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_alc_decomp_dt_tm) = cb_alc_decomp_dt_tm)
set output = CONCAT(output, "alc_decomp_dt_tm,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_alt_lvl_care_dt_tm) = cb_alt_lvl_care_dt_tm)
set output = CONCAT(output, "alt_lvl_care_dt_tm,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_alc_reason_cd) = cb_alc_reason_cd)
set output = CONCAT(output, "alc_reason_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_arrive_dt_tm) = cb_arrive_dt_tm)
set output = CONCAT(output, "arrive_dt_tm,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_depart_dt_tm) = cb_depart_dt_tm)
set output = CONCAT(output, "depart_dt_tm,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_encntr_type_cd) = cb_encntr_type_cd)
set output = CONCAT(output, "encntr_type_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_encntr_type_class_cd) = cb_encntr_type_class_cd)
set output = CONCAT(output, "encntr_type_class_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_isolation_cd) = cb_isolation_cd)
set output = CONCAT(output, "isolation_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_location_cd) = cb_location_cd)
set output = CONCAT(output, "location_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_loc_facility_cd) = cb_loc_facility_cd)
set output = CONCAT(output, "loc_facility_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_loc_building_cd) = cb_loc_building_cd)
set output = CONCAT(output, "loc_building_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_loc_nurse_unit_cd) = cb_loc_nurse_unit_cd)
set output = CONCAT(output, "loc_nurse_unit_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_loc_room_cd) = cb_loc_room_cd)
set output = CONCAT(output, "loc_room_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_loc_bed_cd) = cb_loc_bed_cd)
set output = CONCAT(output, "loc_bed_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_program_service_cd) = cb_program_service_cd)
set output = CONCAT(output, "program_service_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_specialty_unit_cd) = cb_specialty_unit_cd)
set output = CONCAT(output, "specialty_unit_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_organization_id) = cb_organization_id)
set output = CONCAT(output, "organization_id,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_med_service_cd) = cb_med_service_cd)
set output = CONCAT(output, "med_service_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_placement_auth_prsnl_id) =
cb_placement_auth_prsnl_id)
set output = CONCAT(output, "placement_auth_prsnl_id,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_security_access_cd) = cb_security_access_cd)
set output = CONCAT(output, "security_access_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_service_category_cd) = cb_service_category_cd)
set output = CONCAT(output, "service_category_cd,")
set change_cnt = change_cnt + 1
ENDIF
;if there is text with a trailing comma, remove the last comma
IF(change_cnt > 0)
set output = REPLACE(output, ",", ", ")
set trunc_len = TEXTLEN(output) - 1
set output = SUBSTRING(1,trunc_len,output)
ENDIF
return (output)
end
;eval_elh_change_bit
; Evaluate
encounter location change bits
subroutine
(get_loc_change_ind(change_bit=i4) = i2)
declare output = i2 with protect, noconstant(0)
declare cb_location_cd = i4 with protect,constant(8192)
IF(BAND(change_bit, cb_location_cd) = cb_location_cd)
set output = 1
ENDIF
return (output)
end
;get_loc_change_ind
;build the
orders record
subroutine
(build_orx(input = NULL) = NULL)
SELECT INTO "NL:"
FROM ORDERS o
,(LEFT JOIN ORDER_DETAIL od ON od.order_id = o.order_id)
PLAN o WHERE o.encntr_id = ids->encntr_id
AND o.activity_type_cd = 705 ;Pharmacy
 AND o.active_ind = 1
 JOIN od
 ORDER BY o.order_id, od.action_sequence,
od.detail_sequence
 HEAD REPORT
         i = 0
 HEAD o.order_id
         action_seq = 0
         detail_seq = 0
         i += 1
         CALL
ALTERLIST(orx->list, i)
         orx->list[i].order_id
= o.order_id
 HEAD od.action_sequence
         action_seq += 1
 HEAD od.detail_sequence
         detail_seq += 1
         IF(od.oe_field_meaning =
"STRENGTHDOSE") orx->list[i].str_dose = od.oe_field_display_value
ENDIF
         IF(od.oe_field_meaning =
"STRENGTHDOSEUNIT") orx->list[i].str_dose_unit =
od.oe_field_display_value ENDIF
         IF(od.oe_field_meaning =
"VOLUMEDOSE") orx->list[i].vol_dose = od.oe_field_display_value
ENDIF
         IF(od.oe_field_meaning =
"VOLUMEDOSEUNIT") orx->list[i].vol_dose_unit =
od.oe_field_display_value ENDIF
         IF(od.oe_field_meaning =
"RATE") orx->list[i].rate = od.oe_field_display_value ENDIF
         IF(od.oe_field_meaning =
"RATEUNIT") orx->list[i].rate_unit = od.oe_field_display_value
ENDIF
         IF(od.oe_field_meaning =
"RXROUTE") orx->list[i].rx_route = od.oe_field_display_value ENDIF
         IF(od.oe_field_meaning =
"DRUGFORM") orx->list[i].drug_form = od.oe_field_display_value
ENDIF
         IF(od.oe_field_meaning =
"FREQ") orx->list[i].freq = od.oe_field_display_value ENDIF
         IF(od.oe_field_meaning =
"SCH/PRN") orx->list[i].prn = od.oe_field_display_value ENDIF
         IF(od.oe_field_meaning =
"PRNREASON") orx->list[i].prn_reason = od.oe_field_display_value
ENDIF
         IF(od.oe_field_meaning =
"DURATION") orx->list[i].duration = od.oe_field_display_value
ENDIF
         IF(od.oe_field_meaning =
"DURATIONUNIT") orx->list[i].duration_unit =
od.oe_field_display_value ENDIF
 WITH nocounter
end
;build_orx
;build the
encounter location history record
subroutine(build_elh(input
= NULL) = NULL)
declare cb_location_cd = i4 with protect,constant(8192)
SELECT INTO "NL:"
FROM ENCNTR_LOC_HIST elh
PLAN elh WHERE elh.encntr_id = ids->encntr_id
AND elh.active_ind = 1
ORDER BY elh.beg_effective_dt_tm
HEAD REPORT
i = 0
DETAIL
IF(BAND(elh.change_bit, cb_location_cd) = cb_location_cd)
i += 1
CALL ALTERLIST(elh->list, i)
elh->list[i].encntr_loc_hist_id = elh.encntr_loc_hist_id
ENDIF
WITH nocounter
end
;build_elh
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
return (output)
end
;return_CRLF
/**************************************************************
; Subroutines
- HTML/Interactivity
**************************************************************/
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
;call order
detail audit
;need to make
these actually match their data types
subroutine(call_oda_order(order_id=f8,
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
end
;call_oda_order
/**************************************************************
; MAIN
**************************************************************/
;retrieve
encntr_id/person_id/etc
IF(TEXTLEN($identifier)
> 0) CALL build_ids(null) ENDIF
;build
report-specific record structures
IF($cat =
"encounter" AND $enc_rpt = "Location History") CALL
build_elh(null) ENDIF
IF($cat =
"encounter" AND $enc_rpt = "Orders (pharmacy)") CALL
build_orx(null) ENDIF
/**************************************************************
; OUTPUT -
Error Handling
**************************************************************/
SELECT
; Error
checking
IF(ids->success_ind
= 0)
error = "Invalid identifier in prompt."
,success_ind =
ids->success_ind
,input_category = ids->input_cat
,input_type = ids->input_type
,input = ids->input
,person_id = ids->person_id
,encntr_id = ids->encntr_id
,access_allowed_ind = ids->access_allowed
,encntr_tz = ids->tz
; Exit
gracefully if user attempting to access restricted encounter
ELSEIF(ids->access_allowed
= 0)
error = "Access to this encounter is restricted."
,success_ind =
ids->success_ind
,input_category = ids->input_cat
,input_type = ids->input_type
,input = ids->input
,person_id = ids->person_id
,encntr_id = ids->encntr_id
,access_allowed_ind = ids->access_allowed
,encntr_tz = ids->tz
/**************************************************************
; OUTPUT -
Encounter-level Reports
**************************************************************/
ELSEIF($cat =
"encounter" AND $enc_rpt = "Encounter Info (clinical)")
 fin = ids->fin
 ,facility =
UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
 ,start_location =
 IF(hist.loc_nurse_unit_cd > 0)
UAR_GET_CODE_DISPLAY(hist.loc_nurse_unit_cd)
 ELSE
UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
 ENDIF
 ,end_location =
UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
,encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
,med_service = UAR_GET_CODE_DISPLAY(e.med_service_cd)
,reg_dt_tm = DATETIMEZONEFORMAT(e.reg_dt_tm, ids->tz,
"MM/DD/YYYY
HH:MM;;q")
,discharge_dt_tm = DATETIMEZONEFORMAT(e.disch_dt_tm, ids->tz,
"MM/DD/YYYY HH:MM;;q")
,attending_provider = attend.name_full_formatted
;other info
 ,encntr_status =
UAR_GET_CODE_DISPLAY(e.encntr_status_cd)
 ,admit_type =
UAR_GET_CODE_DISPLAY(e.admit_type_cd)
 ,admit_source =
UAR_GET_CODE_DISPLAY(e.admit_src_cd)
 ,admit_mode =
UAR_GET_CODE_DISPLAY(e.admit_mode_cd)
 ,discharge_disposition =
UAR_GET_CODE_DISPLAY(e.disch_disposition_cd)
 ,place_of_service = pos.org_name
 ,place_of_service_type =
UAR_GET_CODE_DISPLAY(e.place_of_svc_type_cd)
 ,meprs = meprs.alias
;other personnel
 ,registration_prsnl =
         IF(reg.person_id != 0)
reg.name_full_formatted
         ELSEIF(reg.person_id = 0
AND prereg.person_id != 0) prereg.name_full_formatted
         ELSE ""
         ENDIF
 ,admitting_provider =
admit.name_full_formatted
 ,discharge_prsnl =
disch.name_full_formatted
;other timing
 ,pre_reg_dt_tm =
DATETIMEZONEFORMAT(e.pre_reg_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,est_arrive_dt_tm =
DATETIMEZONEFORMAT(e.est_arrive_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,arrive_dt_tm =
DATETIMEZONEFORMAT(e.arrive_dt_tm, ids->tz, "MM/DD/YYYY HH:MM;;q")
 ,inpatient_admit_dt_tm =
DATETIMEZONEFORMAT(e.inpatient_admit_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,place_of_svc_admit_dt_tm =
DATETIMEZONEFORMAT(e.place_of_svc_admit_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,assign_to_loc_dt_tm =
DATETIMEZONEFORMAT(e.assign_to_loc_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,depart_dt_tm =
DATETIMEZONEFORMAT(e.depart_dt_tm, ids->tz, "MM/DD/YYYY HH:MM;;q")
 ,encntr_complete_dt_tm =
DATETIMEZONEFORMAT(e.encntr_complete_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,e.encntr_id
 FROM ENCOUNTER e
 ,(LEFT JOIN (SELECT eh.encntr_id
 ,eh.loc_nurse_unit_cd
 ,eh_rank = ROW_NUMBER()
OVER(PARTITION BY eh.encntr_id ORDER BY eh.beg_effective_dt_tm)
 FROM ENCNTR_LOC_HIST eh
 WHERE eh.active_ind = 1
 WITH
SQLTYPE("f8","f8","i2")) hist
 ON e.encntr_id = hist.encntr_id
         AND hist.eh_rank =
1)
 ,(LEFT JOIN PRSNL prereg ON
prereg.person_id = e.pre_reg_prsnl_id)
 ,(LEFT JOIN PRSNL reg ON reg.person_id
= e.reg_prsnl_id)
 ,(LEFT JOIN PRSNL disch ON
disch.person_id = e.disch_prsnl_id)
 ,(LEFT JOIN ORGANIZATION pos ON
pos.organization_id = e.place_of_svc_org_id)
 ,(LEFT JOIN CODE_VALUE_OUTBOUND meprs
ON meprs.code_value = e.loc_nurse_unit_cd
 AND meprs.code_set = 220
 AND meprs.contributor_source_cd =
108418263) ;Legacy_Values == MEPRS (CS 73)
 ,(LEFT JOIN ENCNTR_PRSNL_RELTN
epr_attend ON epr_attend.encntr_id = e.encntr_id
 AND epr_attend.encntr_prsnl_r_cd =
1119 ;Attending Provider
 AND epr_attend.active_ind = 1
 AND epr_attend.end_effective_dt_tm
> SYSDATE)
 ,(LEFT JOIN PRSNL attend ON
attend.person_id = epr_attend.prsnl_person_id
 AND attend.end_effective_dt_tm >
SYSDATE)
 ,(LEFT JOIN ENCNTR_PRSNL_RELTN
epr_admit ON epr_admit.encntr_id = e.encntr_id
 AND epr_admit.encntr_prsnl_r_cd =
1116 ;Admitting Provider
 AND epr_admit.active_ind = 1
 AND epr_admit.end_effective_dt_tm
> SYSDATE)
 ,(LEFT JOIN PRSNL admit ON
admit.person_id =
epr_admit.prsnl_person_id)
 PLAN e WHERE e.encntr_id =
ids->encntr_id
 JOIN hist
 JOIN pos ;place of service organization
 JOIN meprs
 JOIN prereg
 JOIN reg
 JOIN disch
 JOIN epr_attend
 JOIN attend
 JOIN epr_admit
 JOIN admit
ELSEIF($cat =
"encounter" AND $enc_rpt = "Encounter Info (financial)")
 fin = ids->fin
 ,encntr_type =
UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
 ,facility =
UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
 ,nurse_unit =
UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
 ,pft_fin = pft.pft_encntr_alias
 ,billing_entity = be.be_name
 ,pft.acct_id
 ,pft.recur_seq
 ,recur_year_month =
BUILD(CNVTSTRING(pft.recur_current_year), "-",
CNVTSTRING(pft.recur_current_month))
 ,pft.encntr_id
 ,pft.pft_encntr_id
 FROM ENCOUNTER e
 ,PFT_ENCNTR pft
 ,(LEFT JOIN BILLING_ENTITY be ON
pft.billing_entity_id = be.billing_entity_id
 AND be.active_ind = 1)
PLAN e WHERE e.encntr_id = ids->encntr_id
 JOIN pft WHERE e.encntr_id = pft.encntr_id
AND pft.active_ind = 1
 JOIN be
 ORDER BY recur_year_month
ELSEIF($cat =
"encounter" AND $enc_rpt = "Alerts")
 fin = ids->fin
 ,dlg_dt_tm =
DATETIMEZONEFORMAT(ede.dlg_dt_tm, ids->tz, "MM/DD/YYYY HH:MM;;q")
 ;ALERT NAMING INFORMATION
 ,module_name = PIECE(ed.dlg_name,
"!",1,"none")
 ,ed.program_name
,version = em.maint_version
,validation = em.maint_validation
 ,ede.dlg_name
 ,ede.modify_dlg_name
 ;ALERT TEXT
 ,alert_text =
SUBSTRING(1,200,alert_lt.long_text)
 ,override_text =
SUBSTRING(1,200,override_lt.long_text)
 ,override_reason =
UAR_GET_CODE_DISPLAY(ede.override_reason_cd)
 ;ALERT BEHAVIOR
 ,action_taken = EVALUATE(ede.action_flag,
 0, "unspecified action",
 1, "display alert only",
 2, "cancel triggering
action",        ;cancel the order
that triggered the alert
 3, "continue triggering
action",;override the alert
 4, "modify triggering
action",        ;modify the order
that triggered the alert
 5, "message from EKS_LOG_ACTION_A
template",
 "<unmapped value>")
 ,alert_modified_behavior =
 IF(ede.action_flag IN (2,4))
"yes"
 ELSE "no"
 ENDIF
 ,alert_overridden =
EVALUATE(ede.action_flag, 3, "yes", "no")
 ,alert_suppressed =
 IF(CNVTUPPER(override_lt.long_text) =
"*SUPPRESS*") "yes"
 ELSE "no"
 ENDIF
 ,alert_received_by =
         IF(p.position_cd != 0)
BUILD(p.name_full_formatted, " (",
UAR_GET_CODE_DISPLAY(p.position_cd), ")")
         ELSE
p.name_full_formatted
         ENDIF
 ;TRIGGER INFORMATION
 ,trigger_order =
UAR_GET_CODE_DESCRIPTION(oc.catalog_cd)
 ,trigger_order_details =
o.order_detail_display_line
 ,ede.dlg_event_id
 ,ede.trigger_order_id
 FROM EKS_DLG_EVENT ede
 ,(LEFT JOIN ORDERS o ON
ede.trigger_order_id = o.order_id)
 ;This ORDER_CATALOG join required to
get triggering order when user canceled the actual order
 ,(LEFT JOIN ORDER_CATALOG oc
 ON (ede.trigger_entity_name =
"ORDER CATALOG"
 OR ede.trigger_entity_name =
"ORDER_CATALOG")
 AND ede.trigger_entity_id =
oc.catalog_cd)
 ,EKS_DLG ed
 ,(LEFT JOIN EKS_MODULE em ON
em.module_name = ed.program_name
AND em.active_flag = "A")
 ,LONG_TEXT alert_lt
 ,LONG_TEXT override_lt
 ,PRSNL p
 PLAN ede WHERE ede.encntr_id =
ids->encntr_id AND ede.active_ind = 1
 JOIN ed WHERE ed.dlg_name = ede.dlg_name
 JOIN alert_lt WHERE alert_lt.long_text_id =
ede.alert_long_text_id
 JOIN override_lt WHERE
override_lt.long_text_id = ede.long_text_id
 JOIN p WHERE p.person_id = ede.dlg_prsnl_id
 JOIN o
 JOIN oc
 JOIN em
 ORDER BY ede.dlg_dt_tm
ELSEIF($cat =
"encounter" AND $enc_rpt = "Alert Escalation Messages")
fin = ids->fin
,aeh.alert_source
,aeh.alert_seq
,message_subject = SUBSTRING(1,200,replace_crlf(aeh.subject_text))
,message_type = UAR_GET_CODE_DISPLAY(aeh.msg_type_cd)
,message_text = SUBSTRING(1,30000,replace_crlf(msg.long_text)) ;max
output in Discern = 31784 characters.
,recipient =
IF(TEXTLEN(TRIM(aeh.recipient_name)) != 0) BUILD("FAILED DELIVERY:
", aeh.recipient_name)
ELSE
IF(pr.position_cd != 0)
BUILD(pr.name_full_formatted, " (",
TRIM(UAR_GET_CODE_DISPLAY(pr.position_cd)), ")")
ELSE pr.name_full_formatted
ENDIF
ENDIF
,aeh.failure_reason
;timing
,send_dt_tm = DATETIMEZONEFORMAT(aeh.send_dt_tm, ids->tz,
"MM/DD/YYYY HH:MM;;q")
,acknowledge_by_dt_tm = DATETIMEZONEFORMAT(aeh.ack_by_dt_tm,
ids->tz, "MM/DD/YYYY HH:MM;;q")
,acknowledged_dt_tm = DATETIMEZONEFORMAT(aeh.ack_updt_tm, ids->tz,
"MM/DD/YYYY HH:MM;;q")
;        ,ack_comment
= SUBSTRING(1,2000,replace_crlf(trim(aeh.ack_comment))) ;this breaks the output
,aeh.priority
,aeh.escalation_level
,expectation_flag = EVALUATE(aeh.expectation_flag,
0, "expectations met",
1, "expectations not met",
"unknown flag value")
,aeh.closed_ind
,aeh.timer_ind
,o.order_mnemonic
;identifiers
,aeh.order_id
,aeh.alert_id
,aeh.eks_alert_esc_hist_id
FROM EKS_ALERT_ESC_HIST aeh
,(LEFT JOIN LONG_TEXT msg ON msg.long_text_id = aeh.msg_long_text_id
AND msg.active_ind = 1)
,(LEFT JOIN PRSNL pr ON pr.person_id = aeh.parent_entity_id
AND aeh.parent_entity_name = "PERSON")
,(LEFT JOIN ORDERS o ON o.order_id = aeh.order_id
AND aeh.order_id != 0)
PLAN aeh WHERE aeh.encntr_id = ids->encntr_id
JOIN msg
JOIN pr
JOIN o
ORDER BY aeh.alert_id, aeh.alert_seq
ELSEIF($cat =
"encounter" AND $enc_rpt = "Aliases")
 encntr_alias_type =
UAR_GET_CODE_DISPLAY(ea.encntr_alias_type_cd)
 ,alias_pool =
UAR_GET_CODE_DISPLAY(ea.alias_pool_cd)
 ,ea.alias
 ,status =
         IF(ea.active_ind = 1 AND
ea.end_effective_dt_tm > SYSDATE) "Active/Current"
         ELSEIF(ea.active_ind = 1
AND ea.end_effective_dt_tm <= SYSDATE) "Active/Historical"
         ELSEIF(ea.active_ind = 0
AND ea.end_effective_dt_tm > SYSDATE) "Inactive/Current"
         ELSEIF(ea.active_ind = 0
AND ea.end_effective_dt_tm <= SYSDATE) "Inactive/Historical"
         ELSE "unmapped
value"
         ENDIF
 ,contrib_system =
UAR_GET_CODE_DISPLAY(ea.contributor_system_cd)
 ,ea.beg_effective_dt_tm
"MM/DD/YYYY;;d"
 ,ea.end_effective_dt_tm
"MM/DD/YYYY;;d"
 ,ea.active_ind
 ,ea.encntr_alias_type_cd
 ,ea.alias_pool_cd
 ,ea.encntr_alias_id
 FROM ENCNTR_ALIAS ea
 PLAN ea WHERE ea.encntr_id =
ids->encntr_id
 ORDER BY encntr_alias_type,
ea.beg_effective_dt_tm
ELSEIF($cat =
"encounter" AND $enc_rpt = "Appointments")
fin = ids->fin
,location = UAR_GET_CODE_DISPLAY(sa.appt_location_cd)
,appt_type = UAR_GET_CODE_DISPLAY(se.appt_type_cd)
,appt_time = DATETIMEZONEFORMAT(sa.beg_dt_tm, ids->tz,
"MM/DD/YYYY HH:MM;;q")
,sa.duration
,appt_status = UAR_GET_CODE_DISPLAY(sa.sch_state_cd)
,slot_type = sa2.slot_mnemonic
,resource = UAR_GET_CODE_DISPLAY(sa2.resource_cd)
,role = UAR_GET_CODE_DISPLAY(sa2.sch_role_cd)
,sa2.role_meaning
,sa.sch_event_id
FROM SCH_APPT sa
,(LEFT JOIN SCH_APPT sa2 ON sa2.sch_event_id = sa.sch_event_id
AND sa2.role_meaning != "PATIENT"
AND sa2.slot_state_cd != 9543 ;removed
AND sa2.end_effective_dt_tm > SYSDATE
AND sa2.version_dt_tm > SYSDATE
AND sa2.active_ind = 1)
,SCH_EVENT se
PLAN sa WHERE sa.encntr_id = ids->encntr_id
AND sa.role_meaning = "PATIENT"
AND sa.end_effective_dt_tm > SYSDATE
AND sa.version_dt_tm > SYSDATE
AND sa.sch_state_cd IN (
4536 ;checked in
,4537 ;checked out
,4538 ;confirmed
,4054213 ;complete
)
AND sa.slot_state_cd != 9543 ;removed
AND sa.active_ind = 1
JOIN se WHERE se.sch_event_id = sa.sch_event_id
AND se.end_effective_dt_tm > SYSDATE
AND se.version_dt_tm > SYSDATE
AND se.active_ind = 1
JOIN sa2
ORDER BY sa.beg_dt_tm
ELSEIF($cat =
"encounter" AND $enc_rpt = "Charges")
 charge = c.charge_description
 ,category = EVALUATE2(
 IF(c.activity_sub_type_cd > 0)
CONCAT(
 TRIM(UAR_GET_CODE_DISPLAY(c.activity_type_cd)),
 " (",
 TRIM(UAR_GET_CODE_DISPLAY(c.activity_sub_type_cd)),
 ")")
 ELSE
UAR_GET_CODE_DISPLAY(c.activity_type_cd)
 ENDIF)
 ,service_dt_tm =
DATETIMEZONEFORMAT(c.service_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,icd_diag = icd.field6
 ,icd_diag2 = icd2.field6
 ,icd_diag3 = icd3.field6
 ,icd_proc = icd_proc.field6
 ,cpt = cpt.field6
 ,cpt_mod = cpt_mod.field6
 ,cpt_mod2 = cpt_mod2.field6
 ,cpt_mod3 = cpt_mod3.field6
 ,hcpcs = hcpcs.field6
 ,revenue = rev_code.field6
 ,cdm = cdm.field6
 ,ndc = ndc.field6
 ; CHARGE DETAILS
 ,charge_type =
UAR_GET_CODE_DISPLAY(c.charge_type_cd)
 ,tier_group =
UAR_GET_CODE_DISPLAY(c.tier_group_cd)
 ,financial_class =
UAR_GET_CODE_DISPLAY(c.fin_class_cd)
 ,offset = IF(c.offset_charge_item_id >
0) "yes" ELSE "no" ENDIF
 ,c.manual_ind
 ,status = EVALUATE(c.process_flg,
 0,        "Pending",
 1,        "Suspended",
 2,        "Review",
 3,        "On Hold",
 4,        "Manual",
 5,        "Skipped",
 6,        "Combined",
 7,        "Absorbed",
 8,        "ABN (Advanced
Beneficiary Notice) Status",
 10,        "Offset",
 11,        "Adjusted",
 12,        "Grouped",
 13,        "Unreconciled
Credit",
 100,        "Posted",
 222,        "Temporary Near
Time In-Process",
 777,        "Bundled",
 977,        "Bundled -
Interfaced",
 996,        "OMF Stats
Only",
 998,        "Pharmacy NO
CHARGE charges",
 997,        "Statistics
Only",
 999,        "Interfaced",
 "<unmapped
value>")
 ,c.item_price
 ,quantity = c.item_quantity
 ,total_price = c.item_extended_price
 ; OTHER DATE TIMES
 ,credited_dt_tm =
DATETIMEZONEFORMAT(c.credited_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,adjusted_dt_tm =
DATETIMEZONEFORMAT(c.adjusted_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,last_updated =
DATETIMEZONEFORMAT(c.updt_dt_tm, ids->tz, "MM/DD/YYYY HH:MM;;q")
 ; PROVIDERS
 ,ordering_provider =
CNVTUPPER(ord_prov.name_full_formatted)
 ,verifying_provider =
CNVTUPPER(veri_prsnl.name_full_formatted)
 ,posted_by =
CNVTUPPER(post_prsnl.name_full_formatted)
 ,updated_by =
CNVTUPPER(updt_prsnl.name_full_formatted)
 ; IDENTIFIERS
 ,c.order_id
 ,c.bill_item_id
 ,c.charge_item_id
FROM CHARGE c
 ;ICD DIAGNOSIS CODES
 ,(LEFT JOIN CHARGE_MOD icd ON
c.charge_item_id = icd.charge_item_id
 AND icd.field1_id =
value(UAR_GET_CODE_BY("MEANING",14002,"ICD9"))
 AND icd.field2_id = 1
 AND
icd.end_effective_dt_tm > SYSDATE
 AND icd.active_ind = 1)
 ,(LEFT JOIN CHARGE_MOD icd2
ON c.charge_item_id = icd2.charge_item_id
 AND icd2.field1_id =
value(UAR_GET_CODE_BY("MEANING",14002,"ICD9"))
 AND icd2.field2_id = 2
 AND
icd2.end_effective_dt_tm > SYSDATE
 AND icd2.active_ind = 1)
 ,(LEFT JOIN CHARGE_MOD icd3
ON c.charge_item_id = icd3.charge_item_id
 AND icd3.field1_id =
value(UAR_GET_CODE_BY("MEANING",14002,"ICD9"))
 AND icd3.field2_id = 3
 AND
icd3.end_effective_dt_tm > SYSDATE
 AND icd3.active_ind = 1)
 ;ICD PROCEDURE CODES
 ,(LEFT JOIN CHARGE_MOD
icd_proc ON c.charge_item_id = icd_proc.charge_item_id
 AND icd_proc.field1_id IN
(SELECT cv.code_value FROM CODE_VALUE cv
 WHERE cv.code_set = 14002 AND cv.cdf_meaning = "PROCCODE"
 AND cv.end_effective_dt_tm > SYSDATE AND cv.active_ind = 1)
 AND icd_proc.field2_id =
1
 AND
icd_proc.end_effective_dt_tm > SYSDATE
 AND icd_proc.active_ind =
1)
 ;CPT PROCEDURE CODES
 ,(LEFT JOIN CHARGE_MOD cpt ON
c.charge_item_id = cpt.charge_item_id
 AND cpt.field1_id IN
(SELECT cv.code_value FROM CODE_VALUE cv
 WHERE cv.code_set = 14002 AND cv.cdf_meaning = "CPT4"
 AND cv.end_effective_dt_tm > SYSDATE AND cv.active_ind = 1)
 AND cpt.field2_id = 1
 AND
cpt.end_effective_dt_tm > SYSDATE
 AND cpt.active_ind = 1)
 ;CPT MODIFIER CODES
 ,(LEFT JOIN CHARGE_MOD
cpt_mod ON c.charge_item_id = cpt_mod.charge_item_id
 AND cpt_mod.field1_id IN
(SELECT cv.code_value FROM CODE_VALUE cv
 WHERE cv.code_set = 14002 AND cv.cdf_meaning = "MODIFIER"
 AND cv.active_ind = 1 AND cv.end_effective_dt_tm > SYSDATE)
 AND cpt_mod.field2_id = 1
 AND
cpt_mod.end_effective_dt_tm > SYSDATE
 AND cpt_mod.active_ind =
1)
 ,(LEFT JOIN CHARGE_MOD
cpt_mod2 ON c.charge_item_id = cpt_mod2.charge_item_id
 AND cpt_mod2.field1_id IN
(SELECT cv.code_value FROM CODE_VALUE cv
 WHERE cv.code_set = 14002 AND cv.cdf_meaning = "MODIFIER"
 AND cv.active_ind = 1 AND cv.end_effective_dt_tm > SYSDATE)
 AND cpt_mod2.field2_id =
2
 AND
cpt_mod2.end_effective_dt_tm > SYSDATE
 AND cpt_mod2.active_ind =
1)
 ,(LEFT JOIN CHARGE_MOD
cpt_mod3 ON c.charge_item_id = cpt_mod3.charge_item_id
 AND cpt_mod3.field1_id IN
(SELECT cv.code_value FROM CODE_VALUE cv
 WHERE cv.code_set = 14002 AND cv.cdf_meaning = "MODIFIER"
 AND cv.active_ind = 1 AND cv.end_effective_dt_tm > SYSDATE)
 AND cpt_mod3.field2_id =
3
 AND
cpt_mod3.end_effective_dt_tm > SYSDATE
 AND cpt_mod3.active_ind =
1)
 ;HCPCS CODES
 ,(LEFT JOIN CHARGE_MOD hcpcs
ON c.charge_item_id = hcpcs.charge_item_id
 AND hcpcs.field1_id IN
(SELECT cv.code_value FROM CODE_VALUE cv
 WHERE cv.code_set = 14002 AND cv.cdf_meaning = "HCPCS"
 AND cv.active_ind = 1 AND cv.end_effective_dt_tm > SYSDATE)
 AND hcpcs.field2_id = 1
 AND
hcpcs.end_effective_dt_tm > SYSDATE
 AND hcpcs.active_ind = 1)
 ;REVENUE CODES
 ,(LEFT JOIN CHARGE_MOD
rev_code ON c.charge_item_id = rev_code.charge_item_id
 AND rev_code.field1_id IN
(SELECT cv.code_value FROM CODE_VALUE cv
 WHERE cv.code_set = 14002 AND cv.cdf_meaning = "REVENUE"
 AND cv.active_ind = 1 AND cv.end_effective_dt_tm > SYSDATE)
 AND rev_code.field2_id =
1
 AND
rev_code.end_effective_dt_tm > SYSDATE
 AND rev_code.active_ind =
1)
 ;CDM CODES
 ,(LEFT JOIN CHARGE_MOD cdm ON
c.charge_item_id = cdm.charge_item_id
 AND cdm.field1_id IN
(SELECT cv.code_value FROM CODE_VALUE cv
 WHERE cv.code_set = 14002 AND cv.cdf_meaning = "CDM_SCHED"
 AND cv.active_ind = 1 AND cv.end_effective_dt_tm > SYSDATE)
 AND
cdm.end_effective_dt_tm > SYSDATE
 AND cdm.active_ind = 1)
 ;NDC
number
 ,(LEFT JOIN CHARGE_MOD ndc ON
c.charge_item_id = ndc.charge_item_id
 AND ndc.field1_id =
24356556
 AND
ndc.end_effective_dt_tm > SYSDATE
 AND ndc.active_ind = 1)
 ,CHARGE_EVENT c_evnt ;needed
for accession
 ,PRSNL ord_prov
 ,PRSNL updt_prsnl
 ,PRSNL veri_prsnl
 ,PRSNL post_prsnl
 PLAN c WHERE c.encntr_id =
ids->encntr_id
         ;AND
c.offset_charge_item_id = 0 ;what exactly does this do?
 AND c.end_effective_dt_tm > SYSDATE
 AND c.active_ind = 1
 JOIN c_evnt WHERE c.charge_event_id =
c_evnt.charge_event_id
 AND c_evnt.active_ind = 1
 JOIN ord_prov WHERE c.ord_phys_id =
ord_prov.person_id
 JOIN updt_prsnl WHERE c.updt_id =
updt_prsnl.person_id
 JOIN veri_prsnl WHERE c.verify_phys_id =
veri_prsnl.person_id
 JOIN post_prsnl WHERE c.posted_id =
post_prsnl.person_id
 JOIN icd
 JOIN icd2
 JOIN icd3
 JOIN icd_proc
 JOIN cpt
 JOIN cpt_mod
 JOIN cpt_mod2
 JOIN cpt_mod3
 JOIN hcpcs
 JOIN rev_code
 JOIN cdm
 JOIN ndc
 ORDER BY category, c.service_dt_tm, charge
ELSEIF($cat =
"encounter" AND $enc_rpt = "Clinical Events")
 fin = ids->fin
 ,event = UAR_GET_CODE_DISPLAY(ce.event_cd)
 ,ce.event_title_text
 ,ce.event_tag
 ,result = ce.result_val
 ,result_units =
UAR_GET_CODE_DISPLAY(ce.result_units_cd)
 ,result_status =
UAR_GET_CODE_DISPLAY(ce.result_status_cd)
 ,result_source =
UAR_GET_CODE_DISPLAY(ce.source_cd)
 ,contrib_system =
UAR_GET_CODE_DISPLAY(ce.contributor_system_cd)
 ,event_class =
UAR_GET_CODE_DISPLAY(ce.event_class_cd)
 ,entry_mode =
UAR_GET_CODE_DISPLAY(ce.entry_mode_cd)
 ,event_reltn =
UAR_GET_CODE_DESCRIPTION(ce.event_reltn_cd)
 ,blob_data =
 IF(blob.event_id > 0)
 BUILD("Yes (",
blob.blob_length, " chars)")
 ELSE "No"
 ENDIF
 ,label = cdl.label_name
 ,parent_event_tag_title =
 IF(ce.event_id != parent.event_id)
 BUILD(UAR_GET_CODE_DISPLAY(parent.event_cd),
 " (",
parent.event_tag, ")",
 " (",
parent.event_title_text, ")"
 )
 ELSE ""
 ENDIF
 ,event_start_dt_tm =
DATETIMEZONEFORMAT(ce.event_start_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,event_end_dt_tm =
DATETIMEZONEFORMAT(ce.event_end_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,performed_dt_tm =
DATETIMEZONEFORMAT(ce.performed_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,verified_dt_tm =
DATETIMEZONEFORMAT(ce.verified_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,performed_prsnl =
perf_p.name_full_formatted
 ,verified_prsnl =
veri_p.name_full_formatted
 ,ce.authentic_flag
 ,ce.publish_flag
 ,orderable = oc.description
 ,discrete_task_assay =
UAR_GET_CODE_DISPLAY(ce.task_assay_cd)
 ,service_resource =
UAR_GET_CODE_DISPLAY(ce.resource_cd)
 ,accession =
UAR_FMT_ACCESSION(ce.accession_nbr, size(ce.accession_nbr, 1))
 ,ce.reference_nbr ;unique identifier to the
origin of the data
 ,ce.encntr_id
 ,ce.event_id
 ,ce.parent_event_id
 ,ce.order_id
 ,ce.ce_dynamic_label_id
 ,ce.event_cd
 ,ce.task_assay_cd
 ,ce.catalog_cd
 ,ce.resource_cd
 FROM CLINICAL_EVENT ce
 ,(LEFT JOIN PRSNL perf_p ON
ce.performed_prsnl_id = perf_p.person_id)
 ,(LEFT JOIN PRSNL veri_p ON
ce.verified_prsnl_id = veri_p.person_id)
 ,(LEFT JOIN CE_BLOB blob ON ce.event_id
= blob.event_id
         AND
blob.valid_until_dt_tm > SYSDATE)
 ,(LEFT JOIN ORDER_CATALOG oc ON
ce.catalog_cd = oc.catalog_cd AND oc.active_ind = 1)
 ,(LEFT JOIN CE_DYNAMIC_LABEL cdl ON
cdl.ce_dynamic_label_id = ce.ce_dynamic_label_id)
 ,CLINICAL_EVENT parent
 PLAN ce WHERE ce.encntr_id =
ids->encntr_id
 AND (ce.view_level = 1
         OR ce.event_class_cd =
221 ;AP/anatomic pathology
         OR ce.entry_mode_cd =
679378 ;working view
 )
 AND ce.result_status_cd NOT IN
(28,29,30,31) ;IN ERROR
 AND ce.valid_until_dt_tm > SYSDATE
 JOIN parent WHERE ce.parent_event_id =
parent.event_id
 AND parent.valid_until_dt_tm >
SYSDATE
 JOIN perf_p
 JOIN veri_p
 JOIN blob
 JOIN oc
 JOIN cdl
 ORDER BY ce.event_id
ELSEIF($cat =
"encounter" AND $enc_rpt = "Clinical Events (summary)")
event = UAR_GET_CODE_DISPLAY(ce.event_cd)
,nbr_events = COUNT(*)
,event_class = UAR_GET_CODE_DISPLAY(ce.event_class_cd)
,entry_mode = UAR_GET_CODE_DISPLAY(ce.entry_mode_cd)
,ce.view_level
,event_reltn = UAR_GET_CODE_DESCRIPTION(ce.event_reltn_cd)
,ce.event_cd
FROM CLINICAL_EVENT ce
PLAN ce WHERE ce.encntr_id = ids->encntr_id
AND ce.result_status_cd NOT IN (28,29,30,31) ;IN ERROR
AND ce.valid_until_dt_tm > SYSDATE
GROUP BY ce.event_cd, ce.event_class_cd, ce.entry_mode_cd,
ce.view_level, ce.event_reltn_cd
ORDER BY CNVTUPPER(UAR_GET_CODE_DISPLAY(ce.event_cd)), event_class,
entry_mode, ce.view_level, event_reltn DESC
ELSEIF($cat =
"encounter" AND $enc_rpt = "Diagnoses")
 fin = ids->fin
 ,diagnosis = n.source_string
 ,code =
PIECE(n.concept_cki,"!",2,"parse error")
 ,type =
UAR_GET_CODE_DISPLAY(d.diag_type_cd)
 ,priority = d.diag_priority
 ,alt_priority = cp.priority_nbr
 ,vocabulary =
PIECE(n.concept_cki,"!",1,"parse error")
 ,contrib_system =
UAR_GET_CODE_DISPLAY(d.contributor_system_cd)
 ,diagnosis_dt_tm =
DATETIMEZONEFORMAT(d.diag_dt_tm, ids->tz, "MM/DD/YYYY HH:MM;;q")
 ,last_updated =
DATETIMEZONEFORMAT(d.updt_dt_tm, ids->tz, "MM/DD/YYYY HH:MM;;q")
 ,diagnosing_prsnl = d.diag_prsnl_name
 ,d.diagnosis_display
 ,classification =
UAR_GET_CODE_DISPLAY(d.classification_cd)
 ,clinical_service =
UAR_GET_CODE_DISPLAY(d.clinical_service_cd)
 ,confirmation_status =
UAR_GET_CODE_DISPLAY(d.confirmation_status_cd)
 ,hospital_acquired_ind = d.hac_ind
 ,present_on_admit =
UAR_GET_CODE_DISPLAY(d.present_on_admit_cd)
 ,ranking =
UAR_GET_CODE_DISPLAY(d.ranking_cd)
 ,d.encntr_id
 ,d.diagnosis_id
 FROM DIAGNOSIS d
 ,(LEFT JOIN CONDITION_PRIORITY cp ON
d.diagnosis_id = cp.condition_entity_id
         AND d.encntr_id =
cp.encntr_id
         AND
cp.condition_entity_name = "DIAGNOSIS"
         AND cp.active_ind = 1)
 ,NOMENCLATURE n
 PLAN d WHERE d.encntr_id =
ids->encntr_id
 AND d.active_ind = 1
 AND d.beg_effective_dt_tm < SYSDATE
 AND d.end_effective_dt_tm > SYSDATE
 JOIN n WHERE d.nomenclature_id =
n.nomenclature_id
 JOIN cp
 ORDER BY contrib_system, type, priority,
alt_priority, n.source_string
ELSEIF($cat =
"encounter" AND $enc_rpt = "Documentation")
fin = ids->fin
,note_type = UAR_GET_CODE_DISPLAY(ce.event_cd)
,note_title = ce.event_title_text
,authored_dt_tm = DATETIMEZONEFORMAT(ce.performed_dt_tm, ids->tz,
"MM/DD/YYYY HH:MM;;q")
,signed_dt_tm = DATETIMEZONEFORMAT(ce.verified_dt_tm, ids->tz,
"MM/DD/YYYY HH:MM;;q")
,note_status =
IF(ce.view_level = 1 AND ce.publish_flag = 0 AND ce.result_status_cd =
33)
"in progress (open draft)"
ELSEIF(ce.view_level = 1 AND ce.publish_flag = 1 AND
ce.result_status_cd = 33)
"in progress (closed draft)"
ELSEIF(latest.event_id > 0) "complete"
ELSE "unknown"
ENDIF
,sign_status =
IF(cep2.ce_event_prsnl_id = 0 AND latest.event_id > 0)
"signed"
ELSEIF(cep2.ce_event_prsnl_id = 0 AND latest.event_id = 0) "needs
signature"
ELSEIF(cep2.ce_event_prsnl_id > 0 AND cosigner.person_id !=
latest.action_prsnl_id) "needs cosignature"
ELSEIF(cep2.ce_event_prsnl_id > 0 AND cosigner.person_id =
latest.action_prsnl_id) "cosigned"
ELSE "unknown"
ENDIF
,author = author.name_full_formatted
,signed = IF(latest.event_id > 0) "yes" ELSE
"no" ENDIF
,cosign_author = cosigner.name_full_formatted
,cosigned =
IF(cep2.ce_event_prsnl_id = 0) "n/a"
ELSEIF(cep2.ce_event_prsnl_id > 0 AND cosigner.person_id =
latest.action_prsnl_id) "yes"
ELSE "no"
ENDIF
,pending_sign = IF(cep1.ce_event_prsnl_id > 0) "yes" ELSE
"no" ENDIF
,pending_cosign = IF(cep2.ce_event_prsnl_id > 0 AND
cep2.action_status_cd = 657) "yes" ELSE "no" ENDIF
,last_sign_action =
CNVTLOWER(UAR_GET_CODE_DISPLAY(latest.action_type_cd))
,last_signed_by = last_sign_p.name_full_formatted
,last_signed_dt_tm = DATETIMEZONEFORMAT(latest.action_dt_tm,
ids->tz, "MM/DD/YYYY HH:MM;;q")
,note_class_loinc = class_loinc.alias
 ,note_type_loinc = type_loinc.alias
 ,hl7_alias = dhmsm.alias
,entry_mode = UAR_GET_CODE_DISPLAY(ce.entry_mode_cd)
,ce.event_cd
,ce.event_id
FROM CLINICAL_EVENT ce
 ,(LEFT JOIN CODE_VALUE_OUTBOUND
class_loinc ON class_loinc.code_value = ce.event_cd
 AND
class_loinc.contributor_source_cd = 18024137 ;LOINC
 AND class_loinc.alias_type_meaning
= "CLASSCODE")
 ,(LEFT JOIN CODE_VALUE_OUTBOUND
type_loinc ON type_loinc.code_value = ce.event_cd
 AND
type_loinc.contributor_source_cd = 18024137 ;LOINC
 AND type_loinc.alias_type_meaning =
"CONTENTTYPE")
 ,(LEFT JOIN CODE_VALUE_OUTBOUND dhmsm
ON dhmsm.code_value = ce.event_cd
         AND
dhmsm.contributor_source_cd = 105099617) ;DHMSM, used for ACS-DAL HL7 interface
,(LEFT JOIN CE_EVENT_PRSNL cep1
ON ce.event_id = cep1.event_id
AND cep1.action_type_cd = 107 ;sign
AND cep1.action_status_cd = 614384 ;pending
AND cep1.valid_until_dt_tm > SYSDATE)
,(LEFT JOIN CE_EVENT_PRSNL cep2 ;cosign
ON ce.event_id = cep2.event_id
AND cep2.request_prsnl_id = ce.performed_prsnl_id
AND cep2.action_prsnl_id != cep2.request_prsnl_id
AND cep2.action_type_cd = 107 ;sign
AND cep2.valid_until_dt_tm > SYSDATE)
,(LEFT JOIN PRSNL cosigner ON cep2.action_prsnl_id =
cosigner.person_id)
,(LEFT JOIN (
SELECT cep.event_id
,cep.ce_event_prsnl_id
,cep.action_prsnl_id
,cep.action_type_cd
,cep.action_dt_tm
,cep_rank = ROW_NUMBER() OVER(PARTITION BY cep.event_id ORDER BY
cep.action_dt_tm DESC)
FROM CE_EVENT_PRSNL cep
,PRSNL p
WHERE cep.action_type_cd IN (107, 112) ;sign, verify
AND cep.action_status_cd = 653
AND cep.valid_until_dt_tm > SYSDATE
AND cep.action_prsnl_id = p.person_id
WITH
SQLTYPE("f8","f8","f8","f8","dq8","i2"))
latest
ON ce.event_id = latest.event_id AND latest.cep_rank = 1)
,(LEFT JOIN PRSNL last_sign_p ON latest.action_prsnl_id =
last_sign_p.person_id)
,PRSNL author
PLAN ce WHERE ce.encntr_id = ids->encntr_id
AND (ce.event_class_cd = 231 ;mdoc
OR (ce.event_class_cd = 234 AND ce.entry_mode_cd = 2976512)
;radiology/ESI
OR (ce.event_cd = 67649553) ;CM Readmission Risk
)
AND ce.view_level = 1
AND ce.result_status_cd NOT IN (28,29,30,31)
AND ce.valid_until_dt_tm > SYSDATE
JOIN author WHERE ce.performed_prsnl_id = author.person_id
JOIN class_loinc
JOIN type_loinc
JOIN dhmsm
JOIN cep1
JOIN cep2
JOIN cosigner
JOIN latest
JOIN last_sign_p
ORDER BY ce.performed_dt_tm
ELSEIF($cat =
"encounter" AND $enc_rpt = "Documentation (interactive)")
DISTINCT
fin = ids->fin
,note_type = UAR_GET_CODE_DISPLAY(ce.event_cd)
,note_title = ce.event_title_text
,service_dt_tm = DATETIMEZONEFORMAT(ce.event_end_dt_tm, ids->tz,
"MM/DD/YYYY HH:MM (ZZZ);;q")
,authored_dt_tm = DATETIMEZONEFORMAT(ce.performed_dt_tm, ids->tz,
"MM/DD/YYYY HH:MM;;q")
,signed_dt_tm = DATETIMEZONEFORMAT(ce.verified_dt_tm, ids->tz,
"MM/DD/YYYY HH:MM;;q")
,author = author.name_full_formatted
,entry_mode =
IF(cbr.event_id != 0)
CONCAT("Scanned Document (",
UAR_GET_CODE_DISPLAY(cbr.format_cd), ")")
ELSE UAR_GET_CODE_DISPLAY(ce.entry_mode_cd)
ENDIF
,event_class = UAR_GET_CODE_DISPLAY(ce.event_class_cd)
,storage = UAR_GET_CODE_DISPLAY(cbr.storage_cd)
,document_format = UAR_GET_CODE_DISPLAY(cbr.format_cd)
,ce.event_cd
,ce.event_id
FROM CLINICAL_EVENT ce
,(LEFT JOIN CLINICAL_EVENT ce2 ON ce2.parent_event_id = ce.event_id
AND ce2.event_id != ce2.parent_event_id
AND ce2.valid_until_dt_tm > SYSDATE)
,(LEFT JOIN CE_BLOB_RESULT cbr ON cbr.event_id = ce2.event_id
AND cbr.storage_cd = 650264 ;OTG / scanned documents
AND cbr.valid_until_dt_tm > SYSDATE)
,(LEFT JOIN PRSNL author ON ce.performed_prsnl_id = author.person_id)
PLAN ce WHERE ce.encntr_id = ids->encntr_id
AND (ce.event_class_cd = 231 ;mdoc
OR (ce.event_class_cd = 234 AND ce.entry_mode_cd = 2976512)
;radiology/ESI
OR (ce.event_cd = 67649553) ;CM Readmission Risk
)
AND ce.view_level = 1
AND ce.result_status_cd NOT IN (28,29,30,31)
AND ce.valid_until_dt_tm > SYSDATE
JOIN ce2
JOIN cbr
JOIN author
ORDER BY ce.event_end_dt_tm
 HEAD REPORT
i=0
;metadata
row+1 ^<html><head><meta content='CCLLINK'
name='discern'>^
row+1 ^<title>Documentation (interactive)</title>^
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
;table & header
row+1 ^<table border='1'>^
 ^<tr>^
^<th>&nbsp;</th>^
^<th>Service Dt/Tm</th>^
         ^<th>Document</th>^
         ^<th>Title</th>^
         ^<th>Author</th>^
         ^<th>Entry
Mode</th>^
         ^<th>Event
Class</th>^
         ^<th>Event
ID</th>^
 ^</tr>^
DETAIL
i+=1
blob_prompt = BUILD(|^MINE^|, |,|,
CNVTSTRING(ce.event_id), |,|,
2, |,|, ;get the children one level deep
2) ;display child-level meta information/separators
row+1 ^<tr>^ ;first row with result information
call print(td(CNVTSTRING(i)))
call print(td(service_dt_tm))
call print(td(reportlink("dev_rpt_blob_out:group1",
blob_prompt, 0, note_type)))
call print(td(note_title))
call print(td(author))
call print(td(entry_mode))
call print(td(event_class))
call print(td(CNVTSTRING(ce.event_id)))
^</tr>^
FOOT REPORT
row+1 ^</table>^
row+1
^<p></p>^
row+1 ^</body>^
row+1 ^</html>^
ELSEIF($cat =
"encounter" AND $enc_rpt = "Encounter History")
 fin = ids->fin
 ,facility =
UAR_GET_CODE_DISPLAY(eh.loc_facility_cd)
 ,building =
UAR_GET_CODE_DISPLAY(eh.loc_building_cd)
 ,nurse_unit =
UAR_GET_CODE_DISPLAY(eh.loc_nurse_unit_cd)
 ,room =
UAR_GET_CODE_DISPLAY(eh.loc_room_cd)
 ,bed = UAR_GET_CODE_DISPLAY(eh.loc_bed_cd)
 ,encntr_type =
UAR_GET_CODE_DISPLAY(eh.encntr_type_cd)
 ,med_service =
UAR_GET_CODE_DISPLAY(eh.med_service_cd)
 ,admit_type =
UAR_GET_CODE_DISPLAY(eh.admit_type_cd)
 ,start_dt_tm =
DATETIMEZONEFORMAT(eh.beg_effective_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,stop_dt_tm =
DATETIMEZONEFORMAT(eh.end_effective_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,duration =
FORMAT(DATETIMEDIFF(eh.end_effective_dt_tm,eh.beg_effective_dt_tm,7),"####d.##h.##m")
 ,meprs = meprs.alias
 ,accommodation =
UAR_GET_CODE_DISPLAY(eh.accommodation_cd)
 ,accommodation_request =
UAR_GET_CODE_DISPLAY(eh.accommodation_request_cd)
 ,isolation =
UAR_GET_CODE_DISPLAY(eh.isolation_cd)
 ,arrive_prsnl =
CNVTUPPER(arrive_prsnl.name_full_formatted)
 ,depart_prsnl =
CNVTUPPER(depart_prsnl.name_full_formatted)
 ,updated_by =
CNVTUPPER(updt_prsnl.name_full_formatted)
 ,transaction_dt_tm =
DATETIMEZONEFORMAT(eh.transaction_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,changed_fields = SUBSTRING(1,500,
eval_elh_change_bit(eh.change_bit))
 ,location_change_ind =
get_loc_change_ind(eh.change_bit)
 ,eh.encntr_loc_hist_id
 FROM ENCNTR_LOC_HIST eh
 ,(LEFT JOIN PRSNL arrive_prsnl ON
arrive_prsnl.person_id = eh.arrive_prsnl_id)
 ,(LEFT JOIN PRSNL depart_prsnl ON
depart_prsnl.person_id = eh.depart_prsnl_id)
 ,(LEFT JOIN PRSNL updt_prsnl ON
updt_prsnl.person_id = eh.updt_id)
 ,(LEFT JOIN CODE_VALUE_OUTBOUND meprs
ON meprs.code_value = eh.loc_nurse_unit_cd
 AND meprs.code_set = 220
 AND meprs.contributor_source_cd =
108418263)        ;Legacy_Values =
MEPRS
 PLAN eh WHERE eh.encntr_id =
ids->encntr_id
 AND eh.active_ind = 1
 JOIN arrive_prsnl
 JOIN depart_prsnl
 JOIN updt_prsnl
 JOIN meprs
 ORDER BY start_dt_tm
ELSEIF($cat =
"encounter" AND $enc_rpt = "Health Plans")
fin = ids->fin
,profile =
IF(e.person_plan_profile_type_cd = 0 AND epr.end_effective_dt_tm <
SYSDATE) "zz Historical"
ELSEIF(e.person_plan_profile_type_cd = 0 AND epr.end_effective_dt_tm
> SYSDATE) "z Unassociated"
ELSE UAR_GET_CODE_DISPLAY(e.person_plan_profile_type_cd)
ENDIF
,seq = epr.priority_seq
,health_plan = hp.plan_name
,plan_type = UAR_GET_CODE_DISPLAY(hp.plan_type_cd)
,service_type = UAR_GET_CODE_DISPLAY(hp.service_type_cd)
,payer = org.org_name
,financial_class = UAR_GET_CODE_DISPLAY(hp.financial_class_cd)
,epr.member_nbr
,epr.subs_member_nbr
,epr.group_nbr
,signature_on_file = UAR_GET_CODE_DISPLAY(epr.signature_on_file_cd)
,begin_date = epr.beg_effective_dt_tm
,subscriber = subscriber.name_full_formatted
,subscriber_edipi = sub_edipi.alias
,subscriber_agency = govt_agency.org_name
,subscriber_employer = por.ft_org_name
,subscriber_status = UAR_GET_CODE_DISPLAY(por.empl_occupation_cd)
 ,subscriber_rank =
UAR_GET_CODE_DISPLAY(por.empl_title_cd)
 ,subscriber_grade =
UAR_GET_CODE_DISPLAY(por.empl_type_cd)
 ,epr.encntr_plan_reltn_id
FROM ENCOUNTER e
,ENCNTR_PLAN_RELTN epr
,(LEFT JOIN PERSON_PLAN_RELTN ppr ON ppr.person_plan_reltn_id =
epr.person_plan_reltn_id
AND ppr.member_nbr = epr.subs_member_nbr
AND ppr.active_ind = 1)
,(LEFT JOIN PERSON subscriber ON subscriber.person_id = ppr.person_id)
,(LEFT JOIN PERSON_ALIAS sub_edipi ON sub_edipi.person_id =
subscriber.person_id
 AND sub_edipi.person_alias_type_cd
= 22 ;EDIPI
 AND sub_edipi.end_effective_dt_tm
> SYSDATE
 AND sub_edipi.active_ind = 1)
,(LEFT JOIN PERSON_ORG_RELTN por ON por.person_id =
subscriber.person_id
AND por.person_org_reltn_cd = 1136 ;employer
AND por.active_ind = 1)
,(LEFT JOIN ORGANIZATION govt_agency ON govt_agency.organization_id =
por.organization_id)
,HEALTH_PLAN hp
,ORGANIZATION org
PLAN e WHERE e.encntr_id = ids->encntr_id
JOIN epr WHERE epr.encntr_id = e.encntr_id
AND epr.active_ind = 1
JOIN hp WHERE hp.health_plan_id = epr.health_plan_id
JOIN org WHERE org.organization_id = epr.organization_id
JOIN ppr
JOIN subscriber
JOIN por
JOIN sub_edipi
 JOIN govt_agency
ORDER BY profile, seq
ELSEIF($cat =
"encounter" AND $enc_rpt = "Intake/Output")
fin = ids->fin
,type = EVALUATE(cio.io_type_flag, 1, "Intake", 2,
"Output")
,event =
IF(cio.io_type_flag = 1 AND ce.event_cd = 4056680) ;med admin
UAR_GET_CODE_DESCRIPTION(ce_ref.catalog_cd)
ELSEIF(cio.io_type_flag = 1 AND ce.event_cd != 4056680 AND ce.order_id
!= 0) ;other intake
o.ordered_as_mnemonic
ELSEIF(cio.io_type_flag = 2) UAR_GET_CODE_DISPLAY(ce.event_cd) ;output
ELSE UAR_GET_CODE_DISPLAY(ce.event_cd)
ENDIF
,cio.io_volume
,units =
IF(ce.result_units_cd != 0) UAR_GET_CODE_DISPLAY(ce.result_units_cd)
ELSE "See comment"
ENDIF
,start_dt_tm = DATETIMEZONEFORMAT(cio.io_start_dt_tm, ids->tz,
"MM/DD/YYYY HH:MM;;q")
,end_dt_tm = DATETIMEZONEFORMAT(cio.io_end_dt_tm, ids->tz,
"MM/DD/YYYY HH:MM;;q")
,comment =
IF(cio.io_type_flag = 1 AND ce.event_cd = 4056680) ;med admin
o_ref.simplified_display_line
ELSEIF(cio.io_type_flag = 1 AND ce.event_cd != 4056680) ;other intake
o.simplified_display_line
ELSEIF(cio.io_type_flag = 2) cdl.label_name ;output
ELSE ""
ENDIF
,cio.event_id
,ce.order_id
,cio.reference_event_id
,reference_order_id = ce_ref.order_id
FROM CE_INTAKE_OUTPUT_RESULT cio
,CLINICAL_EVENT ce
,(LEFT JOIN ORDERS o ON o.order_id = ce.order_id)
,(LEFT JOIN CE_DYNAMIC_LABEL cdl ON cdl.ce_dynamic_label_id =
ce.ce_dynamic_label_id)
,CLINICAL_EVENT ce_ref
,(LEFT JOIN ORDERS o_ref ON o_ref.order_id = ce_ref.order_id)
PLAN cio WHERE cio.encntr_id = ids->encntr_id
AND cio.valid_until_dt_tm > SYSDATE
JOIN ce WHERE ce.event_id = cio.event_id
AND ce.result_status_cd NOT IN (28,29,30,31)
AND ce.valid_until_dt_tm > SYSDATE
JOIN ce_ref WHERE ce_ref.event_id = cio.reference_event_id
AND ce_ref.result_status_cd NOT IN (28,29,30,31)
AND ce_ref.valid_until_dt_tm > SYSDATE
JOIN o
JOIN cdl
JOIN o_ref
ORDER BY cio.io_start_dt_tm, cio.event_id
ELSEIF($cat =
"encounter" AND $enc_rpt = "Lab Results")
DISTINCT
;TODO change column order
 orderable = oc.description
 ,event = UAR_GET_CODE_DISPLAY(ce.event_cd)
 ,result = ce.result_val
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
 ,specimen_type =
UAR_GET_CODE_DISPLAY(c.specimen_type_cd) ;replaced CE-based field
 ,collection_method =
UAR_GET_CODE_DISPLAY(c.collection_method_cd) ;replaced CE-based field
 ,collection_priority =
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
 ,order_dt_tm =
DATETIMEZONEFORMAT(o.orig_order_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,collect_dt_tm =
DATETIMEZONEFORMAT(c.drawn_dt_tm, ids->tz, "MM/DD/YYYY HH:MM;;q")
;replaced CE-based field
 ,received_dt_tm =
DATETIMEZONEFORMAT(c.received_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q") ;replaced CE-based field
 ,performed_dt_tm =
DATETIMEZONEFORMAT(ce.performed_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,verified_dt_tm =
DATETIMEZONEFORMAT(ce.verified_dt_tm, ids->tz, "MM/DD/YYYY
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
 ,responsible_provider =
         IF(order_p.position_cd
!= 0)
                 BUILD(order_p.name_full_formatted,
" (", TRIM(UAR_GET_CODE_DISPLAY(order_p.position_cd)), ")")
         ELSE
order_p.name_full_formatted
         ENDIF
 ,ordering_prsnl =
         IF(entry_p.position_cd
!= 0)
                 BUILD(entry_p.name_full_formatted,
" (", TRIM(UAR_GET_CODE_DISPLAY(entry_p.position_cd)), ")")
         ELSE
entry_p.name_full_formatted
         ENDIF
 ;OTHER IDENTIFIERS
,order_type =
         IF(o.originating_encntr_id
!= 0 AND o.encntr_id = 0) "future (unactivated)"
         ELSEIF(o.originating_encntr_id
!= 0 AND o.encntr_id != 0) "future (activated)"
         ELSEIF(o.originating_encntr_id
= 0) "non-future"
         ELSE "other"
         ENDIF
 ,template_flag =
EVALUATE(o.template_order_flag,
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
,accession_formatted = UAR_FMT_ACCESSION(ca.accession,
size(ca.accession, 1)) ;replaced CE version
,o.order_id
 ,ce.event_id
 ;,c.container_id
 ;,c.specimen_id
 FROM CLINICAL_EVENT ce
,(LEFT JOIN ORDER_CONTAINER_R ocr ON ocr.order_id = ce.order_id)
,(LEFT JOIN CONTAINER c ON c.container_id = ocr.container_id)
,(LEFT JOIN CONTAINER_ACCESSION ca ON ca.container_id =
c.container_id)
 ,(LEFT JOIN V500_SPECIMEN spec ON
spec.specimen_id = c.specimen_id)
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
         ,ORDERs o
 ,ORDER_CATALOG oc
 ,ORDER_ACTION oa
 ,PRSNL order_p
 ,PRSNL entry_p
PLAN ce WHERE ce.encntr_id = ids->encntr_id
 AND ce.view_level = 1
         AND ce.result_status_cd
NOT IN (28,29,30,31) ;IN ERROR
         AND ce.valid_until_dt_tm
>= SYSDATE
 JOIN o WHERE o.order_id = ce.order_id
AND o.catalog_type_cd = 2513 ;lab
JOIN oc WHERE o.catalog_cd = oc.catalog_cd
JOIN oa WHERE oa.order_id = o.order_id AND oa.action_type_cd = 2534
;ordered
JOIN order_p WHERE order_p.person_id = oa.order_provider_id
JOIN entry_p WHERE entry_p.person_id = oa.action_personnel_id
 JOIN ocr
 JOIN c
 JOIN ca
 JOIN spec
 JOIN perf_resource
 JOIN perf_org
 JOIN cid
 ;I don't love this sort order but it keeps
the panel results together
 ORDER BY ce.order_id, event
ELSEIF($cat =
"encounter" AND $enc_rpt = "Location History")
 fin = ids->fin
 ,facility =
UAR_GET_CODE_DISPLAY(eh.loc_facility_cd)
 ,building =
UAR_GET_CODE_DISPLAY(eh.loc_building_cd)
 ,nurse_unit =
UAR_GET_CODE_DISPLAY(eh.loc_nurse_unit_cd)
 ,room =
UAR_GET_CODE_DISPLAY(eh.loc_room_cd)
 ,bed = UAR_GET_CODE_DISPLAY(eh.loc_bed_cd)
 ,encntr_type =
UAR_GET_CODE_DISPLAY(eh.encntr_type_cd)
 ,med_service =
UAR_GET_CODE_DISPLAY(eh.med_service_cd)
 ,start_dt_tm =
DATETIMEZONEFORMAT(eh.beg_effective_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,stop_dt_tm =
DATETIMEZONEFORMAT(eh.end_effective_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,duration =
FORMAT(DATETIMEDIFF(eh.end_effective_dt_tm,eh.beg_effective_dt_tm,7),"####d.##h.##m")
 ,meprs = meprs.alias
 ,accommodation =
UAR_GET_CODE_DISPLAY(eh.accommodation_cd)
 ,accommodation_request =
UAR_GET_CODE_DISPLAY(eh.accommodation_request_cd)
 ,isolation =
UAR_GET_CODE_DISPLAY(eh.isolation_cd)
 ,arrive_prsnl =
CNVTUPPER(arrive_prsnl.name_full_formatted)
 ,depart_prsnl =
CNVTUPPER(depart_prsnl.name_full_formatted)
 ,updated_by =
CNVTUPPER(updt_prsnl.name_full_formatted)
 ,transaction_dt_tm =
DATETIMEZONEFORMAT(eh.transaction_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,changed_fields = SUBSTRING(1,500,
eval_elh_change_bit(eh.change_bit))
 ,location_change_ind =
get_loc_change_ind(eh.change_bit)
 ,eh.encntr_loc_hist_id
 FROM ENCNTR_LOC_HIST eh
 ,(LEFT JOIN PRSNL arrive_prsnl ON
arrive_prsnl.person_id = eh.arrive_prsnl_id)
 ,(LEFT JOIN PRSNL depart_prsnl ON
depart_prsnl.person_id = eh.depart_prsnl_id)
 ,(LEFT JOIN PRSNL updt_prsnl ON
updt_prsnl.person_id = eh.updt_id)
 ,(LEFT JOIN CODE_VALUE_OUTBOUND meprs
ON meprs.code_value = eh.loc_nurse_unit_cd
 AND meprs.code_set = 220
 AND meprs.contributor_source_cd =
108418263)        ;Legacy_Values =
MEPRS
 PLAN eh WHERE EXPAND(idx, 1,
size(elh->list,5), eh.encntr_loc_hist_id,
elh->list[idx].encntr_loc_hist_id)
 JOIN arrive_prsnl
 JOIN depart_prsnl
 JOIN updt_prsnl
 JOIN meprs
 ORDER BY start_dt_tm
ELSEIF($cat =
"encounter" AND $enc_rpt = "Medication Administration")
fin = ids->fin
,parent_order =
o.ordered_as_mnemonic
,component = UAR_GET_CODE_DISPLAY(ce.event_cd)
,instructions = o.simplified_display_line
,dose = cmr.admin_dosage
,units = UAR_GET_CODE_DISPLAY(cmr.dosage_unit_cd)
,route = UAR_GET_CODE_DISPLAY(cmr.admin_route_cd)
,site =
UAR_GET_CODE_DISPLAY(cmr.admin_site_cd)
,admin_start_dt_tm = DATETIMEZONEFORMAT(cmr.admin_start_dt_tm,
ids->tz, "MM/DD/YYYY HH:MM;;q")
,reg_dt_tm = DATETIMEZONEFORMAT(e.reg_dt_tm, ids->tz,
"MM/DD/YYYY HH:MM;;q")
,inpatient_admit_dt_tm = DATETIMEZONEFORMAT(e.inpatient_admit_dt_tm,
ids->tz, "MM/DD/YYYY HH:MM;;q")
,reg_to_drug = FORMAT(DATETIMEDIFF(cmr.admin_start_dt_tm, e.reg_dt_tm,
7),"####d.##h.##m")
,admit_to_drug = FORMAT(DATETIMEDIFF(cmr.admin_start_dt_tm,
e.inpatient_admit_dt_tm, 7),"####d.##h.##m")
,reg_to_drug_min = DATETIMEDIFF(cmr.admin_start_dt_tm, e.reg_dt_tm, 4)
,admit_to_drug_min = DATETIMEDIFF(cmr.admin_start_dt_tm,
e.inpatient_admit_dt_tm, 4)
;BCMA
,bcma_med_match =
IF(mae.med_admin_event_id = 0) "no scan record"
ELSEIF(mae.positive_med_ident_ind = 1) "yes"
ELSEIF(mae.positive_med_ident_ind != 1) "no"
ELSE ""
ENDIF
,bcma_patient_match =
IF(mae.med_admin_event_id = 0) "no record"
ELSEIF(mae.positive_patient_ident_ind = 1) "yes"
ELSEIF(mae.positive_patient_ident_ind != 1) "no"
ELSE ""
ENDIF
;identifiers
,ce.order_id
,ce.parent_event_id
,ce.event_id
;        ,o.cki
;        ,drug_identifier
= SUBSTRING(9,6, o.cki) ;doesnt' work for cki MUL.MMDC strings
FROM CLINICAL_EVENT ce
,(LEFT JOIN MED_ADMIN_EVENT mae ON mae.event_id = ce.event_id)
,CE_MED_RESULT cmr
,ORDERS o
,ENCOUNTER e
PLAN ce WHERE ce.encntr_id = ids->encntr_id
AND ce.event_cd != 679984 ;Administration Information
AND ce.event_reltn_cd = 132 ;children
AND ce.view_level = 1
AND ce.result_status_cd NOT IN (28,29,30,31)
AND ce.valid_until_dt_tm > SYSDATE
JOIN cmr WHERE ce.event_id = cmr.event_id
AND cmr.valid_until_dt_tm > SYSDATE
JOIN o WHERE ce.order_id = o.order_id
AND o.active_ind = 1
JOIN e WHERE ce.encntr_id = e.encntr_id
JOIN mae
ORDER BY admin_start_dt_tm
ELSEIF($cat =
"encounter" AND $enc_rpt = "Microbiology Results")
DISTINCT ;duplicates coming from ORDER_CONTAINER_R joins
event = UAR_GET_CODE_DISPLAY(ce.event_cd)
,child_event = UAR_GET_CODE_DISPLAY(child.event_cd)
 ,result = ce.event_tag
,accession = UAR_FMT_ACCESSION(ce.accession_nbr,
size(ce.accession_nbr,1))
,collected_dt_tm = DATETIMEZONEFORMAT(c.drawn_dt_tm, ids->tz,
"MM/DD/YYYY HH:MM (ZZZ);;q")
,event_verified = DATETIMEZONEFORMAT(ce.verified_dt_tm, ids->tz,
"MM/DD/YYYY HH:MM (ZZZ);;q")
,child_verified = DATETIMEZONEFORMAT(child.verified_dt_tm, ids->tz,
"MM/DD/YYYY HH:MM (ZZZ);;q")
 FROM CLINICAL_EVENT ce
         ,(LEFT JOIN
ORDER_CONTAINER_R ocr ON ocr.order_id = ce.order_id)
         ,(LEFT JOIN CONTAINER c
ON c.container_id = ocr.container_id)
         ,CLINICAL_EVENT child
PLAN ce WHERE ce.encntr_id = ids->encntr_id
 AND ce.event_class_cd = 230
;MBO/microbiology
 AND ce.view_level = 1
         AND ce.result_status_cd
NOT IN (28,29,30,31) ;IN ERROR
         AND ce.valid_until_dt_tm
>= SYSDATE
JOIN child WHERE child.parent_event_id = ce.event_id
AND child.event_reltn_cd = 132 ;child
AND ce.result_status_cd NOT IN (28,29,30,31) ;IN
ERROR
AND child.valid_until_dt_tm > SYSDATE
JOIN ocr
JOIN c
 ORDER BY ce.event_id DESC, child.event_id
 HEAD REPORT
i = 0
;metadata
row+1 ^<html><head><meta content='CCLLINK'
name='discern'>^
row+1 ^<title>Microbiology Results (interactive)</title>^
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
HEAD ce.event_id
i += 1
subi = ichar("a")-1 ;initialize the alphabetical counter
susc_prompt = BUILD(|^MINE^|,
|,|,        CNVTSTRING(ce.event_id))
susc_link = reportlink("dev_rpt_ce_susceptibility:group1",
susc_prompt, 0, "See susceptibility testing")
;table & header
row+1 ^<table border='1'>^
row+1 ^<tr>^
^<th>&nbsp;</th>^
         ^<th>Study</th>^
         ^<th>Result</th>^
         ^<th>Collected
Date/Time</th>^
^<th>Verified Date/Time</th>^
^<th>Accession</th>^
^<th>Event ID</th>^
^</tr>^
;first row with result information
row+1 ^<tr>^
call print(td(CNVTSTRING(i)))
^<td><b>^, event, ^</b></td>^ ;bold the parent
event
^<td>^, ce.event_tag, ^</br>^, susc_link, ^</td>^
call print(td(collected_dt_tm))
call print(td(" "))
call print(td(accession))
call print(td(CNVTSTRING(ce.event_id)))
^</tr>^
;subrows with individual reports
DETAIL
subi += 1 ;increment the alphabetical counter for subrows
blob_prompt = BUILD(|^MINE^|, |,|,
CNVTSTRING(child.event_id), |,|,
1, |,|, ;direct blob output of the given event_id
0) ;no meta information
num_hours = BUILD("+ ",
CNVTSTRING(ROUND(DATETIMEDIFF(child.verified_dt_tm, c.drawn_dt_tm, 3),
0)),
" hours")
row+1 ^<tr>^ ;subrows with micro reports
call print(td(CONCAT(char(subi),".")))
call print(td(child_event))
call print(td(reportlink("dev_rpt_blob_out:group1",
blob_prompt, 0, "See report")))
call print(td(num_hours))
call print(td(child_verified))
call print(td(" "))
call print(td(CNVTSTRING(child.event_id)))
^</tr>^
FOOT ce.event_id
row+1 ^</table>^
row+1 ^<p></p>^
FOOT REPORT
row+1 ^</body>^
row+1 ^</html>^
ELSEIF($cat =
"encounter" AND $enc_rpt = "Orders (all)")
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
;This report
relies on a record structure to collapse down multiple ORDER_DETAIL rows
;to keep the
grain at the order level
ELSEIF($cat =
"encounter" AND $enc_rpt = "Orders (pharmacy)")
 orderable =
UAR_GET_CODE_DESCRIPTION(o.catalog_cd)
 ,ordered_as =
         IF(TRIM(UAR_GET_CODE_DISPLAY(o.catalog_cd))
= TRIM(o.ordered_as_mnemonic)) ""
         ELSE
o.ordered_as_mnemonic ;often contains brand name
         ENDIF
 ,order_dt_tm =
DATETIMEZONEFORMAT(o.orig_order_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
,order_status = UAR_GET_CODE_DISPLAY(o.order_status_cd)
 ,pharmacy_review_status =
EVALUATE(o.need_rx_clin_review_flag,
 0, "unset",
 1, "needs review",
 2, "review complete",
 3, "reviewed/rejected",
 4, "not applicable",
 "<unmapped value>")
 ,order_entered_by =
CNVTUPPER(order_enter.name_full_formatted)
 ,order_signed_by =
CNVTUPPER(order_sign.name_full_formatted)
,order_detail =
SUBSTRING(1,250,replace_CRLF(o.order_detail_display_line))
,last_communication_type =
UAR_GET_CODE_DISPLAY(o.latest_communication_type_cd)
 ; MEDICATION INFORMATION
 ,med_type =
UAR_GET_CODE_DISPLAY(o.dcp_clin_cat_cd) ;medications vs continuous infusions
 ,med_order_type =
UAR_GET_CODE_DISPLAY(o.med_order_type_cd) ;med, intermittent, IV, etc
 ,str_dose = orx->list[d.seq].str_dose
 ,str_dose_unit =
orx->list[d.seq].str_dose_unit
 ,vol_dose = orx->list[d.seq].vol_dose
 ,vol_dose_unit =
orx->list[d.seq].vol_dose_unit
 ,rate = orx->list[d.seq].rate
 ,rate_unit = orx->list[d.seq].rate_unit
 ,rx_route = orx->list[d.seq].rx_route
 ,drug_form = orx->list[d.seq].drug_form
 ,freq = orx->list[d.seq].freq
 ,prn = orx->list[d.seq].prn
 ,prn_reason =
orx->list[d.seq].prn_reason
 ,duration = orx->list[d.seq].duration
 ,duration_unit =
orx->list[d.seq].duration_unit
 ,pharmacy_mask = EVALUATE(o.rx_mask,
 1, "diluent",
 2, "additive",
 4, "med",
 8, "TPN",
 16, "sliding scale",
 32, "tapering dose",
 64, "PCA",
 "<unmapped
value>")
 ,start_dt_tm =
DATETIMEZONEFORMAT(o.current_start_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,projected_stop_dt_tm =
DATETIMEZONEFORMAT(o.projected_stop_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,discontinue_dt_tm =
DATETIMEZONEFORMAT(o.discontinue_effective_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
,discontinue_type = UAR_GET_CODE_DISPLAY(o.discontinue_type_cd)
 ,template_flag =
EVALUATE(o.template_order_flag,
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
 ,o.cki
,contrib_system = UAR_GET_CODE_DISPLAY(o.contributor_system_cd)
,fin = ids->fin
,o.order_id
FROM (DUMMYT d with seq = value(size(orx->list, 5)))
,ORDERS o
,(LEFT JOIN ORDER_ACTION oa ON o.order_id = oa.order_id
 AND oa.action_type_cd = 2534) ;
;needed for ordering provider
 ,(LEFT JOIN PRSNL order_enter ON
oa.action_personnel_id = order_enter.person_id)
 ,(LEFT JOIN PRSNL order_sign ON
oa.order_provider_id =
order_sign.person_id)
PLAN d
JOIN o WHERE o.order_id = orx->list[d.seq].order_id
 JOIN oa
 JOIN order_enter
 JOIN order_sign
 ORDER BY o.orig_order_dt_tm,
o.orig_order_convs_seq
ELSEIF($cat =
"encounter" AND $enc_rpt = "Orders (radiology)")
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
 ,activity_type =
UAR_GET_CODE_DISPLAY(oc.activity_type_cd)
 ,activity_subtype =
UAR_GET_CODE_DISPLAY(oc.activity_subtype_cd)
 ,clinical_category =
UAR_GET_CODE_DISPLAY(o.dcp_clin_cat_cd)
 ,powerplan = pc.description
 ; ORDER TIMING
 ,start_dt_tm =
DATETIMEZONEFORMAT(o.current_start_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,projected_stop_dt_tm =
DATETIMEZONEFORMAT(o.projected_stop_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,discontinue_dt_tm =
DATETIMEZONEFORMAT(o.discontinue_effective_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
,discontinue_type = UAR_GET_CODE_DISPLAY(o.discontinue_type_cd)
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
         IF(dict_prsnl.position_cd
!= 0) BUILD(dict_prsnl.name_full_formatted, " (",
UAR_GET_CODE_DISPLAY(dict_prsnl.position_cd), ")")
         ELSE
dict_prsnl.name_full_formatted
         ENDIF
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
 ;IDENTIFIERS
,order_type =
         IF(o.originating_encntr_id
!= 0 AND o.encntr_id = 0) "future (unactivated)"
         ELSEIF(o.originating_encntr_id
!= 0 AND o.encntr_id != 0) "future (activated)"
         ELSEIF(o.originating_encntr_id
= 0) "non-future"
         ELSE "other"
         ENDIF
 ,template_flag =
EVALUATE(o.template_order_flag,
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
,re.rad_exam_id
 ,rr.rad_report_id
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
 PLAN o WHERE (o.encntr_id =
ids->encntr_id OR o.originating_encntr_id = ids->encntr_id)
         AND o.catalog_type_cd =
2517 ;radiology
         ;AND
o.template_order_flag IN (0,1,5,7) ;exclude auto-generated child orders
(instances)
         AND o.active_ind = 1
 JOIN oc WHERE o.catalog_cd = oc.catalog_cd
 JOIN origin_fin
 JOIN pc
 JOIN re
 JOIN rr
 JOIN dict_prsnl
 JOIN oa
 JOIN order_enter
 JOIN order_sign
 ORDER BY order_dt_tm,
o.orig_order_convs_seq
ELSEIF($cat =
"encounter" AND $enc_rpt = "Pathology Results")
accession_nbr =
IF(ca.accession_id != 0) UAR_FMT_ACCESSION(ca.accession,
size(ca.accession, 1))
ELSE UAR_FMT_ACCESSION(pc.accession_nbr, size(pc.accession_nbr,1))
ENDIF
,study = UAR_GET_CODE_DISPLAY(ce.event_cd)
,study_date = DATETIMEZONEFORMAT(ce.event_end_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY;;d")
,specimen =
IF(cs.case_specimen_id != 0)
CONCAT(TRIM(UAR_GET_CODE_DISPLAY(cs.specimen_cd),3), " (",
TRIM(cs.specimen_description, 3), ")")
ELSE
UAR_GET_CODE_DESCRIPTION(c.specimen_type_cd) ;replaced CE-based field
ENDIF
,ordering_provider =
IF(pc.case_id != 0) phys.name_full_formatted
ELSE op.name_full_formatted
ENDIF
,order_diagnosis = n.source_string
,facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
,fin = fin.alias
,case_year =
IF(pc.case_id != 0) CNVTSTRING(pc.case_year)
ELSE SUBSTRING(6,4, ca.accession)
ENDIF
,case_number =
IF(pc.case_id != 0) pc.case_number
ELSE CNVTINT(SUBSTRING(13,6,ca.accession))
ENDIF
,pathologist =
IF(pc.case_id != 0) path.name_full_formatted
ELSEIF(pc.case_id = 0 AND ce.verified_prsnl_id = 4291727) "See
report"
ELSE vp.name_full_formatted
ENDIF
,specimen_collected_dt_tm =
IF(cs.case_specimen_id != 0)
IF(cs.collect_dt_tm > 0)
DATETIMEZONEFORMAT(cs.collect_dt_tm, DATETIMEZONEBYNAME(tz.time_zone),
"MM/DD/YYYY HH:MM (ZZZ);;q")
ELSE
DATETIMEZONEFORMAT(pc.case_collect_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM (ZZZ);;q")
ENDIF
ELSE
DATETIMEZONEFORMAT(c.drawn_dt_tm, DATETIMEZONEBYNAME(tz.time_zone),
"MM/DD/YYYY HH:MM (ZZZ);;q")
ENDIF
,specimen_received_dt_tm =
IF(cs.case_specimen_id != 0)
IF(cs.received_dt_tm > 0)
DATETIMEZONEFORMAT(cs.received_dt_tm, DATETIMEZONEBYNAME(tz.time_zone),
"MM/DD/YYYY HH:MM (ZZZ);;q")
ELSE
DATETIMEZONEFORMAT(pc.accessioned_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM (ZZZ);;q")
ENDIF
ELSE
DATETIMEZONEFORMAT(c.received_dt_tm, DATETIMEZONEBYNAME(tz.time_zone),
"MM/DD/YYYY HH:MM (ZZZ);;q")
ENDIF
,report_complete_dt_tm =
IF(pc.case_id != 0)
DATETIMEZONEFORMAT(pc.main_report_cmplete_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM (ZZZ);;q")
ELSE ""
;This is past the specimen received date
;DATETIMEZONEFORMAT(ce.verified_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM (ZZZ);;q")
ENDIF
;identifiers
;        ,ce.person_id
;        ,ce.encntr_id
;        ,ce.event_id
;        ,ce.order_id
;        ,pc.case_id
FROM CLINICAL_EVENT ce
,(LEFT JOIN CASE_REPORT cr ON cr.event_id = ce.event_id)
,(LEFT JOIN PATHOLOGY_CASE pc ON pc.case_id = cr.case_id)
,(LEFT JOIN CASE_SPECIMEN cs ON cs.case_id = pc.case_id)
,(LEFT JOIN PRSNL path ON path.person_id =
pc.responsible_pathologist_id
AND path.person_id > 2)
,(LEFT JOIN PRSNL phys ON phys.person_id = pc.requesting_physician_id
AND phys.person_id > 2)
,(LEFT JOIN ORDER_ACTION oa ON oa.order_id = ce.order_id
AND oa.action_type_cd = 2534) ;order
,(LEFT JOIN PRSNL op ON op.person_id = oa.order_provider_id)
,(LEFT JOIN PRSNL vp ON vp.person_id = ce.verified_prsnl_id)
,(LEFT JOIN ORDER_CONTAINER_R ocr ON ocr.order_id = ce.order_id)
,(LEFT JOIN CONTAINER c ON c.container_id = ocr.container_id)
,(LEFT JOIN CONTAINER_ACCESSION ca ON ca.container_id =
c.container_id)
,(LEFT JOIN ENCOUNTER e ON e.encntr_id = ce.encntr_id)
,(LEFT JOIN TIME_ZONE_R tz ON tz.parent_entity_id = e.loc_facility_cd
AND tz.parent_entity_name = "LOCATION")
,(LEFT JOIN ENCNTR_ALIAS fin ON fin.encntr_id = e.encntr_id
AND fin.encntr_alias_type_cd = 1077
AND fin.end_effective_dt_tm > SYSDATE
AND fin.active_ind = 1)
,(LEFT JOIN NOMEN_ENTITY_RELTN ner ON ner.parent_entity_id =
ce.order_id
AND ner.parent_entity_name = "ORDERS"
AND ner.child_entity_name = "DIAGNOSIS"
AND ner.priority = 1)
,(LEFT JOIN NOMENCLATURE n ON n.nomenclature_id = ner.nomenclature_id)
PLAN ce WHERE ce.encntr_id = ids->encntr_id
AND ce.event_cd IN (
SELECT ex.event_cd
FROM V500_EVENT_SET_EXPLODE ex
WHERE ex.event_set_cd IN (4003743, 105911751, 24316470357)) ;Pathology
Reports, AP Specimens, Anatomic Pathology
AND ce.event_class_cd IN (226, 231) ;GRP, mdoc
AND ce.valid_until_dt_tm > SYSDATE+1
JOIN cr
JOIN pc
JOIN cs
JOIN path
JOIN phys
JOIN oa
JOIN op
JOIN vp
JOIN ocr
JOIN c
JOIN ca
JOIN e
JOIN tz
JOIN fin
JOIN ner
JOIN n
ORDER BY ce.event_end_dt_tm DESC
 HEAD REPORT
i = 0
;metadata
row+1 ^<html><head><meta content='CCLLINK'
name='discern'>^
row+1 ^<title>Microbiology Results (interactive)</title>^
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
;table & header
row+1 ^<table border='1'>^
row+1 ^<tr>^
^<th>&nbsp;</th>^
         ^<th>Accession</th>^
         ^<th>Study</th>^
         ^<th>Study
Date</th>^
         ^<th>Specimen</th>^
         ^<th>Ordering
Provider</th>^
         ^<th>Order
Diagnosis</th>^
         ^<th>Case
Year</th>^
         ^<th>Case
Number</th>^
         ^<th>Facility</th>^
         ^<th>Encounter
Type</th>^
         ^<th>FIN</th>^
;                
        ^<th>Pathologist</th>^
;                
        ^<th>Specimen Collected
Date/Time</th>^
;                
        ^<th>Specimen Received
Date/Time</th>^
;                
        ^<th>Report Complete
Date/Time</th>^
 ^</tr>^
DETAIL
i += 1
blob_prompt = BUILD(|^MINE^|, |,|,
CNVTSTRING(ce.event_id), |,|,
2, |,|, ;events are two layers deep
4) ;path headers
;first row with result information
row+1 ^<tr>^
call print(td(CNVTSTRING(i)))
call print(td(accession_nbr))
call print(td(reportlink("dev_rpt_blob_out:group1",
blob_prompt, 0, study)))
call print(td(study_date))
call print(td(specimen))
call print(td(ordering_provider))
call print(td(order_diagnosis))
call print(td(case_year))
call print(td(case_number))
call print(td(facility))
call print(td(encntr_type))
call print(td(fin))
;                call
print(td(pathologist))
;                call
print(td(specimen_collected_dt_tm))
;                call
print(td(specimen_received_dt_tm))
;                call
print(td(report_complete_dt_tm))
^</tr>^
FOOT REPORT
row+1 ^</table>^
row+1 ^</body>^
row+1 ^</html>^
ELSEIF($cat =
"encounter" AND $enc_rpt = "Patient Portal Results")
 fin = ids->fin
 ,event = UAR_GET_CODE_DISPLAY(ce.event_cd)
 ,result = ce.result_val
 ,units =
UAR_GET_CODE_DISPLAY(ce.result_units_cd)
 ,event_dt_tm =
DATETIMEZONEFORMAT(ce.event_end_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,performed_dt_tm =
DATETIMEZONEFORMAT(ce.performed_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,verified_dt_tm =
DATETIMEZONEFORMAT(ce.verified_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,performed_prsnl =
perf_p.name_full_formatted
 ,verified_prsnl =
veri_p.name_full_formatted
 ,contrib_system =
UAR_GET_CODE_DISPLAY(ce.contributor_system_cd)
 ,entry_mode =
UAR_GET_CODE_DISPLAY(ce.entry_mode_cd)
 ,event_class =
UAR_GET_CODE_DISPLAY(ce.event_class_cd)
 ,blob_data =
 IF(blob.event_id > 0)
 BUILD("Yes (",
blob.blob_length, " chars)")
 ELSE "No"
 ENDIF
 ,ce.event_cd
 ,ce.event_id
 FROM CLINICAL_EVENT ce
 ,(LEFT JOIN PRSNL perf_p ON
ce.performed_prsnl_id = perf_p.person_id)
 ,(LEFT JOIN PRSNL veri_p ON
ce.verified_prsnl_id = veri_p.person_id)
 ,(LEFT JOIN CE_BLOB blob ON ce.event_id
= blob.event_id)
 PLAN ce WHERE ce.encntr_id =
ids->encntr_id
 AND ce.entry_mode_cd = 106165707
;HealtheLife, aka Patient Portal
 AND ce.view_level = 1
 AND ce.valid_until_dt_tm >= SYSDATE
 AND ce.result_status_cd NOT IN
(28,29,30,31) ;IN ERROR
 JOIN perf_p
 JOIN veri_p
 JOIN blob
 ORDER BY event
ELSEIF($cat =
"encounter" AND $enc_rpt = "Personnel Relationships")
 fin = ids->fin
 ,personnel =
CNVTUPPER(p.name_full_formatted)
 ,position =
UAR_GET_CODE_DISPLAY(p.position_cd)
 ,relationship =
UAR_GET_CODE_DISPLAY(epr.encntr_prsnl_r_cd)
 ,p.physician_ind
 ,epr.priority_seq
 ,start_dt_tm =
DATETIMEZONEFORMAT(epr.beg_effective_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,stop_dt_tm =
DATETIMEZONEFORMAT(epr.end_effective_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,reltn_assigned_by =
         IF(updt_p.person_id !=
0)
IF(updt_p.position_cd !=
0)
BUILD(TRIM(updt_p.name_full_formatted), " (",
TRIM(UAR_GET_CODE_DISPLAY(updt_p.position_cd)), ")")
ELSE updt_p.name_full_formatted
ENDIF
ELSE ""
         ENDIF
,prsnl_id = p.person_id
 ,epr.encntr_prsnl_reltn_id
 FROM ENCNTR_PRSNL_RELTN epr
 ,PRSNL p
 ,PRSNL updt_p
 PLAN epr WHERE epr.encntr_id =
ids->encntr_id
         AND epr.active_ind = 1
 JOIN p WHERE epr.prsnl_person_id =
p.person_id
 JOIN updt_p WHERE epr.updt_id =
updt_p.person_id
 ORDER BY epr.beg_effective_dt_tm,
p.name_full_formatted
ELSEIF($cat =
"encounter" AND $enc_rpt = "Procedures")
 fin = ids->fin
 ,procedure = EVALUATE2(
 IF(TEXTLEN(TRIM(p.procedure_note)) = 0)
n.source_string
 ELSE p.procedure_note
 ENDIF)
 ,p.proc_dt_tm
,proc_type = EVALUATE(p.proc_type_flag,
0,"unknown",
1,"associated with encounter",
2,"historical/narrative",
"<unmapped value>")
 ,category =
UAR_GET_CODE_DISPLAY(n.vocab_axis_cd)
 ,vocabulary =
UAR_GET_CODE_DISPLAY(n.source_vocabulary_cd)
 ,proc_cki = n.concept_cki
 ,code = n.source_identifier
 ,p.proc_priority
 ,mod_nomenclature = pmn.source_string
 ,mod_cki = pmn.concept_cki
,p.proc_type_flag
 ,p.procedure_id
 ,p.nomenclature_id
 FROM ENCOUNTER e
 ,(LEFT JOIN ENCNTR_PRSNL_RELTN epr
 ON e.encntr_id = epr.encntr_id
 AND epr.encntr_prsnl_r_cd = 1119
;Attending
 AND epr.end_effective_dt_tm >
SYSDATE)
 ,(LEFT JOIN PRSNL attend ON
epr.prsnl_person_id = attend.person_id)
 ,PROCEDURE p
,(LEFT JOIN PROC_MODIFIER pm ON pm.parent_entity_id = p.procedure_id
AND pm.parent_entity_name = "PROCEDURE"
AND pm.active_ind = 1)
,(LEFT JOIN NOMENCLATURE pmn ON pmn.nomenclature_id =
pm.nomenclature_id
AND pmn.active_ind = 1)
 ,NOMENCLATURE n
 PLAN e WHERE e.encntr_id =
ids->encntr_id
 JOIN p WHERE p.encntr_id = e.encntr_id
         AND p.proc_type_flag !=
2 ;exclude narrated (aka historical) procedures
 AND p.end_effective_dt_tm >= SYSDATE
 AND p.active_ind = 1
 JOIN n WHERE n.nomenclature_id =
p.nomenclature_id
 ;AND n.data_status_cd != 39 ;Unauth
 JOIN epr
 JOIN
attend
 JOIN pm
 JOIN pmn
 ORDER BY p.proc_dt_tm DESC, p.proc_priority
ELSEIF($cat =
"encounter" AND $enc_rpt = "Procedures (charge view)")
 fin = ids->fin
 ,activity_type =
UAR_GET_CODE_DISPLAY(c.activity_type_cd)
 ,activity_subtype =
UAR_GET_CODE_DISPLAY(c.activity_sub_type_cd)
 ,charge_description =
SUBSTRING(1,100,replace_CRLF(c.charge_description))
 ,category =
UAR_GET_CODE_DISPLAY(n.principle_type_cd)
 ,vocabulary =
UAR_GET_CODE_DISPLAY(n.source_vocabulary_cd)
 ,mod =
 IF(n.source_identifier IS NULL)
cm.field6
 ELSE n.source_identifier
 ENDIF
 ,mod_description = n.source_string
 ,ordering_provider =
         IF(ord_p.person_id != 0)
                 IF(ord_p.position_cd
!= 0)
                         BUILD(TRIM(ord_p.name_full_formatted),
" (", TRIM(UAR_GET_CODE_DISPLAY(ord_p.position_cd)), ")")
                 ELSE
ord_p.name_full_formatted
                 ENDIF
ELSE ""
         ENDIF
 ,performing_provider =
         IF(perf_p.person_id !=
0)
                 IF(perf_p.position_cd
!= 0)
                         BUILD(TRIM(perf_p.name_full_formatted),
" (", TRIM(UAR_GET_CODE_DISPLAY(perf_p.position_cd)), ")")
                 ELSE
perf_p.name_full_formatted
                 ENDIF
         ELSE ""
         ENDIF
 ,verifying_provider =
         IF(verify_p.person_id !=
0)
                 IF(verify_p.position_cd
!= 0)
                         BUILD(TRIM(verify_p.name_full_formatted),
" (", TRIM(UAR_GET_CODE_DISPLAY(verify_p.position_cd)),
")")
                 ELSE
verify_p.name_full_formatted
                 ENDIF
         ELSE ""
         ENDIF
 ,tier_group =
UAR_GET_CODE_DISPLAY(c.tier_group_cd)
 ,charge_type =
UAR_GET_CODE_DISPLAY(c.charge_type_cd)
 ,mod_type =
UAR_GET_CODE_DISPLAY(cm.charge_mod_type_cd)
 ,mod_source =
UAR_GET_CODE_DISPLAY(cm.charge_mod_source_cd)
 ,service_dt_tm =
DATETIMEZONEFORMAT(c.service_dt_tm, ids->tz,"MM/DD/YYYY HH:MM;;q")
 ,credited_dt_tm =
DATETIMEZONEFORMAT(c.credited_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ; IDENTIFIERS
 ,c.order_id
 ,c.bill_item_id
 ,c.charge_item_id
 ,cm.charge_mod_id
 FROM CHARGE c
 ,(LEFT JOIN PRSNL ord_p ON
c.ord_phys_id = ord_p.person_id)
 ,(LEFT JOIN PRSNL perf_p ON
c.perf_phys_id = perf_p.person_id)
 ,(LEFT JOIN PRSNL verify_p ON
c.verify_phys_id = verify_p.person_id)
 ,CHARGE_MOD cm
 ,NOMENCLATURE n
 PLAN c WHERE c.encntr_id =
ids->encntr_id
 AND c.end_effective_dt_tm > SYSDATE
 AND c.active_ind = 1
 JOIN cm WHERE cm.charge_item_id =
c.charge_item_id
 AND cm.end_effective_dt_tm > SYSDATE
 AND cm.active_ind = 1
 JOIN n WHERE n.nomenclature_id =
cm.nomen_id AND n.principle_type_cd != 1252 ;Disease or Syndrome
 JOIN ord_p
 JOIN perf_p
 JOIN verify_p
 ORDER BY activity_type, c.charge_item_id,
cm.charge_mod_id
ELSEIF($cat =
"encounter" AND $enc_rpt = "Registration (PIP)")
fin = ids->fin
,encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
,patient = p.name_full_formatted
,affiliation_code = UAR_GET_CODE_DISPLAY(aff_c.value_cd)
,mil_status = UAR_GET_CODE_DISPLAY(p.vet_military_status_cd)
,bencat = UAR_GET_CODE_DISPLAY(bencat.value_cd)
,patcat = UAR_GET_CODE_DISPLAY(patcat.value_cd)
,profile = UAR_GET_CODE_DISPLAY(e.person_plan_profile_type_cd)
,health_plan = hp.plan_name
,payor = org.org_name
,subscriber = subscriber.name_full_formatted
,subscriber_employer = por.ft_org_name
,subscriber_status = UAR_GET_CODE_DISPLAY(por.empl_occupation_cd)
 ,subscriber_rank =
UAR_GET_CODE_DISPLAY(por.empl_title_cd)
 ,subscriber_grade =
UAR_GET_CODE_DISPLAY(por.empl_type_cd)
FROM ENCOUNTER e
,(LEFT JOIN ENCNTR_PLAN_RELTN epr ON epr.encntr_id = e.encntr_id
AND epr.priority_seq = 1 ;only pull primary health plan for encounter
AND epr.end_effective_dt_tm > SYSDATE
AND epr.active_ind = 1)
,(LEFT JOIN HEALTH_PLAN hp ON hp.health_plan_id = epr.health_plan_id)
,(LEFT JOIN PERSON_ORG_RELTN por ON por.person_org_reltn_id =
epr.sponsor_person_org_reltn_id
AND por.person_org_reltn_cd = 1136 ;employer
AND por.end_effective_dt_tm > SYSDATE
AND por.active_ind = 1)
,(LEFT JOIN PERSON subscriber ON subscriber.person_id = por.person_id)
,(LEFT JOIN ORGANIZATION org ON org.organization_id =
epr.organization_id)
,(LEFT JOIN PERSON_INFO aff_c ON aff_c.person_id = e.person_id
AND aff_c.info_sub_type_cd = 108679813 ;Add Person Affiliation Code
AND aff_c.end_effective_dt_tm > SYSDATE
AND aff_c.active_ind = 1)
,(LEFT JOIN ENCNTR_INFO patcat ON patcat.encntr_id = e.encntr_id
AND patcat.info_sub_type_cd = 109901051
AND patcat.end_effective_dt_tm > SYSDATE
AND patcat.active_ind = 1)
,(LEFT JOIN ENCNTR_INFO bencat ON bencat.encntr_id = e.encntr_id
AND bencat.info_sub_type_cd = 109901057 ;BENCAT
AND bencat.end_effective_dt_tm > SYSDATE
AND bencat.active_ind = 1)
,PERSON p
PLAN e WHERE e.encntr_id = ids->encntr_id
JOIN p WHERE p.person_id = e.person_id
JOIN epr
JOIN hp
JOIN por
JOIN subscriber
JOIN org
JOIN aff_c
JOIN patcat
JOIN bencat
ELSEIF($cat =
"encounter" AND $enc_rpt = "Registration (UDFs)")
 fin = ids->fin
 ,info_type =
UAR_GET_CODE_DISPLAY(ei.info_type_cd)
 ,info_subtype =
UAR_GET_CODE_DISPLAY(ei.info_sub_type_cd)
,value =
IF(ei.value_cd != 0) UAR_GET_CODE_DISPLAY(ei.value_cd)
ELSEIF(ei.long_text_id != 0) SUBSTRING(1,500,text.long_text)
ELSEIF(ei.value_numeric_ind != 0) CNVTSTRING(ei.value_numeric, 50,
2);50 chars, 2 decimals
ELSE FORMAT(ei.value_dt_tm, "MM/DD/YYYY HH:MM;;q")
ENDIF
,value_type =
IF(ei.value_cd != 0) "code_value"
ELSEIF(ei.long_text_id != 0) "long_text"
ELSEIF(ei.value_numeric_ind != 0) "numeric"
ELSE "date/time"
ENDIF
 ,beg_effective_dt_tm =
DATETIMEZONEFORMAT(ei.beg_effective_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,end_effective_dt_tm =
DATETIMEZONEFORMAT(ei.end_effective_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,ei.encntr_info_id
 FROM ENCNTR_INFO ei
 ,(LEFT JOIN LONG_TEXT text ON
text.long_text_id = ei.long_text_id
         AND text.active_ind = 1)
 PLAN ei WHERE ei.encntr_id =
ids->encntr_id
         AND ei.active_ind = 1
 JOIN text
 ORDER BY info_type, info_subtype
ELSEIF($cat =
"encounter" AND $enc_rpt = "Scheduling Actions")
;"duplicates"
occur but vary by candidate_id and conversation_id
facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
,encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
,appt_type = UAR_GET_CODE_DISPLAY(se.appt_type_cd)
,appt_status = UAR_GET_CODE_DISPLAY(sa.sch_state_cd)
,appt_time = DATETIMEZONEFORMAT(sa.beg_dt_tm, ids->tz,
"MM/DD/YYYY HH:MM;;q")
,action_dt_tm = DATETIMEZONEFORMAT(sea.perform_dt_tm, ids->tz,
"MM/DD/YYYY HH:MM;;q")
,action =
IF(sea.sch_reason_cd != 0)
BUILD(UAR_GET_CODE_DISPLAY(sea.sch_action_cd), " (",
UAR_GET_CODE_DISPLAY(sea.sch_reason_cd), ")")
ELSE UAR_GET_CODE_DISPLAY(sea.sch_action_cd)
ENDIF
,action_prsnl = action_p.name_full_formatted
,action_prsnl_position = UAR_GET_CODE_DISPLAY(action_p.position_cd)
,application = UAR_GET_CODE_DISPLAY(sea.product_cd)
;identifiers
,e.encntr_id
,sa.sch_appt_id
,se.sch_event_id
,sea.sch_action_id
FROM ENCOUNTER e
,SCH_APPT sa
,SCH_EVENT se
,SCH_EVENT_ACTION sea
,PRSNL action_p
PLAN e WHERE e.encntr_id = ids->encntr_id
JOIN sa WHERE sa.encntr_id = e.encntr_id
AND sa.role_meaning = "PATIENT"
AND sa.sch_state_cd != 4545 ;rescheduled
AND sa.end_effective_dt_tm > SYSDATE
AND sa.version_dt_tm > SYSDATE
AND sa.active_ind = 1
JOIN se WHERE se.sch_event_id = sa.sch_event_id
AND se.end_effective_dt_tm > SYSDATE
AND se.version_dt_tm > SYSDATE
AND se.active_ind = 1
JOIN sea WHERE sea.sch_event_id = se.sch_event_id
AND sea.end_effective_dt_tm > SYSDATE
AND sea.version_dt_tm > SYSDATE
AND sea.active_ind = 1
JOIN action_p WHERE action_p.person_id = sea.action_prsnl_id
ORDER BY sa.beg_dt_tm, appt_status, sea.perform_dt_tm,
sea.sch_action_id
ELSEIF($cat =
"encounter" AND $enc_rpt = "Surgical Anesthesia Actions")
 fin = ids->fin
 ,case_nbr = sc.surg_case_nbr_formatted
 ,sa_ref.action_name
 ,action_dt_tm =
DATETIMEZONEFORMAT(sa.action_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,action_prsnl =
         IF(action_p.person_id !=
0)
                 IF(action_p.position_cd
!= 0)
                         BUILD(TRIM(action_p.name_full_formatted),
" (", TRIM(UAR_GET_CODE_DISPLAY(action_p.position_cd)),
")")
                 ELSE
action_p.name_full_formatted
                 ENDIF
         ELSE ""
         ENDIF
;identifiers
 ,sc.surg_case_id
 ,sar.sa_anesthesia_record_id
 ,sa.sa_action_id
 ,sa.sa_ref_action_id
 FROM SURGICAL_CASE sc
 ,SA_ANESTHESIA_RECORD sar
 ,SA_ACTION sa
 ,SA_REF_ACTION sa_ref
 ,PRSNL action_p
 PLAN sc WHERE sc.encntr_id =
ids->encntr_id
 JOIN sar WHERE sar.surgical_case_id =
sc.surg_case_id
 JOIN sa WHERE sa.sa_anesthesia_record_id =
sar.sa_anesthesia_record_id
 AND sa.active_ind = 1
 JOIN sa_ref WHERE sa_ref.sa_ref_action_id =
sa.sa_ref_action_id
 JOIN action_p WHERE action_p.person_id =
sa.prsnl_id
 ORDER BY sa.action_dt_tm
ELSEIF($cat =
"encounter" AND $enc_rpt = "Surgical Anesthesia
Attributes")
attribute_type = UAR_GET_CODE_DISPLAY(sca.case_attribute_type_cd)
,attribute =
IF(CNVTREAL(sca.case_attribute_value_txt) = 0)
sca.case_attribute_value_txt
ELSE ;numerical value
IF(cv.cdf_meaning = "SURGEON") CONCAT("prsnl_id:",
sca.case_attribute_value_txt)
ELSEIF(cv.cdf_meaning = "SURGDTTM")
sca.case_attribute_value_txt
ELSE TRIM(UAR_GET_CODE_DISPLAY(CNVTREAL(sca.case_attribute_value_txt)))
ENDIF
ENDIF
,sequence = sca.case_attribute_sequence
,last_modified = DATETIMEZONEFORMAT(sca.updt_dt_tm, ids->tz,
"MM/DD/YYYY HH:MM;;q")
,last_modified_by =
IF(updt_p.person_id != 0)
IF(updt_p.position_cd != 0)
BUILD(TRIM(updt_p.name_full_formatted), " (",
TRIM(UAR_GET_CODE_DISPLAY(updt_p.position_cd)), ")")
ELSE updt_p.name_full_formatted
ENDIF
ELSE ""
ENDIF
,raw_attribute = sca.case_attribute_value_txt
,sc.surg_case_id
,sar.sa_anesthesia_record_id
,sca.sa_case_attribute_id
FROM SURGICAL_CASE sc
,SA_ANESTHESIA_RECORD sar
,SA_CASE_ATTRIBUTE sca
,CODE_VALUE cv
,PRSNL updt_p
PLAN sc WHERE sc.encntr_id = ids->encntr_id
JOIN sar WHERE sar.surgical_case_id = sc.surg_case_id
AND sar.active_ind = 1
JOIN sca WHERE sca.sa_anesthesia_record_id =
sar.sa_anesthesia_record_id
AND sca.active_ind = 1
JOIN cv WHERE cv.code_value = sca.case_attribute_type_cd
JOIN updt_p WHERE updt_p.person_id = sca.updt_id
ORDER BY attribute_type, sca.case_attribute_sequence
ELSEIF($cat =
"encounter" AND $enc_rpt = "Surgical Case Attendees")
 fin = ids->fin
 ,case_nbr = sc.surg_case_nbr_formatted
 ,attendee =
         IF(p.person_id != 0)
                 IF(p.position_cd
!= 0)
                         CONCAT(TRIM(p.name_full_formatted),
" (", TRIM(UAR_GET_CODE_DISPLAY(p.position_cd)), ")")
                 ELSE
p.name_full_formatted
                 ENDIF
         ELSE ""
         ENDIF
 ,role_performed =
UAR_GET_CODE_DISPLAY(ca.role_perf_cd)
 ,surgical_area =
UAR_GET_CODE_DISPLAY(ca.surg_area_cd)
 ,time_in = DATETIMEZONEFORMAT(ca.in_dt_tm,
ids->tz, "MM/DD/YYYY HH:MM;;q")
 ,time_out =
DATETIMEZONEFORMAT(ca.out_dt_tm, ids->tz, "MM/DD/YYYY HH:MM;;q")
 ,sc.surg_case_id
 ,ca.case_attendance_id
 FROM SURGICAL_CASE sc
 ,CASE_ATTENDANCE ca
 ,PRSNL p
 PLAN sc WHERE sc.encntr_id =
ids->encntr_id
 JOIN ca WHERE ca.surg_case_id =
sc.surg_case_id
 AND ca.active_ind = 1
 JOIN p WHERE p.person_id =
ca.case_attendee_id
 ORDER BY time_in, role_performed
ELSEIF($cat =
"encounter" AND $enc_rpt = "Surgical Case Info")
;TODO use
build pattern for personnel/position
 fin = ids->fin
 ,case_nbr = sc.surg_case_nbr_formatted
 ,case_type =
UAR_GET_CODE_DISPLAY(sc.pat_type_cd)
 ,case_complete = sc.surg_complete_qty
 ;LOCATION
 ,institution =
UAR_GET_CODE_DISPLAY(sc.inst_cd)
 ,department =
UAR_GET_CODE_DISPLAY(sc.dept_cd)
 ,area =
UAR_GET_CODE_DISPLAY(sc.surg_area_cd)
 ,room =
UAR_GET_CODE_DISPLAY(sc.surg_op_loc_cd)
 ;DATE TIMES
 ,sched_start_dt_tm =
DATETIMEZONEFORMAT(sc.sched_start_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,check_in_dt_tm =
DATETIMEZONEFORMAT(sc.checkin_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,case_start_dt_tm =
DATETIMEZONEFORMAT(sc.surg_start_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,case_stop_dt_tm =
DATETIMEZONEFORMAT(sc.surg_stop_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,case_dur_min = sc.surg_dur_min
 ,turnover_min = sc.turnover_dur
 ,cancel_dt_tm =
DATETIMEZONEFORMAT(sc.cancel_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,cancel_reason =
UAR_GET_CODE_DISPLAY(sc.cancel_reason_cd)
 ;PERSONNEL
 ,primary_surgeon =
surgeon.name_full_formatted
 ,surgeon_specialty =
surg_spec.prsnl_group_name
 ,primary_anesthesiologist =
anesth.name_full_formatted
 ;CASE INFORMATION
 ,preop_diagnosis =
SUBSTRING(1,300,preop.long_text)
 ,postop_diagnosis =
SUBSTRING(1,300,postop.long_text)
 ,case_level =
UAR_GET_CODE_DISPLAY(sc.case_level_cd)
 ,sc.add_on_ind
 ,asa_class =
UAR_GET_CODE_DISPLAY(sc.asa_class_cd)
 ,wound_class =
UAR_GET_CODE_DISPLAY(sc.wound_class_cd)
;IDENTIFIERS
 ,sc.encntr_id
 ,sc.surg_case_id
 FROM SURGICAL_CASE sc
 ,LONG_TEXT preop
 ,LONG_TEXT postop
 ,PRSNL surgeon
 ,PRSNL anesth
 ,PRSNL_GROUP surg_spec
 PLAN sc WHERE sc.encntr_id =
ids->encntr_id
 JOIN preop WHERE preop.long_text_id =
sc.preop_diag_text_id
 JOIN postop WHERE postop.long_text_id =
sc.postop_diag_text_id
 JOIN surgeon WHERE surgeon.person_id =
sc.surgeon_prsnl_id
 JOIN anesth WHERE anesth.person_id =
sc.anesth_prsnl_id
 JOIN surg_spec WHERE
surg_spec.prsnl_group_id = sc.surg_specialty_id
ELSEIF($cat =
"encounter" AND $enc_rpt = "Surgical Case Procedures")
 fin = ids->fin
 ,case_nbr = sc.surg_case_nbr_formatted
 ,surg_area =
UAR_GET_CODE_DISPLAY(scp.surg_area_cd)
 ,procedure =
UAR_GET_CODE_DISPLAY(scp.surg_proc_cd)
 ,scp.modifier
 ,proc_complete = scp.PROC_COMPLETE_QTY
 ,scp.primary_proc_ind
 ,scp.concurrent_ind
 ,proc_start_dt_tm =
DATETIMEZONEFORMAT(scp.proc_start_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,proc_end_dt_tm =
DATETIMEZONEFORMAT(scp.proc_end_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,scp.proc_dur_min
 ,case_dur_min = sc.surg_dur_min
 ,scp.proc_text
 ,primary_surgeon =
surgeon.name_full_formatted
 ,surgeon_specialty =
surg_spec.prsnl_group_name
 ,anesth_type =
UAR_GET_CODE_DISPLAY(scp.anesth_type_cd)
 ,wound_class =
UAR_GET_CODE_DISPLAY(scp.wound_class_cd)
 ,pick_list_changed =
EVALUATE(scp.pick_list_chg_flag, 1, "Changed", "Unchanged")
 ,spec_not_collected_reason =
UAR_GET_CODE_DISPLAY(scp.spec_not_collected_reason_cd)
 ,sc.surg_case_id
 ,scp.surg_case_proc_id
 FROM SURGICAL_CASE sc
 ,(LEFT JOIN SURG_CASE_PROCEDURE scp
 ON sc.surg_case_id =
scp.surg_case_id
 AND scp.active_ind = 1)
 ,PRSNL surgeon
 ,PRSNL_GROUP surg_spec
 PLAN sc WHERE sc.encntr_id =
ids->encntr_id
 JOIN scp
 JOIN surgeon WHERE surgeon.person_id =
scp.primary_surgeon_id
 JOIN surg_spec WHERE
surg_spec.prsnl_group_id = scp.surg_specialty_id
 ORDER BY sc.surg_case_id,
scp.primary_proc_ind DESC, scp.surg_case_proc_id
ELSEIF($cat =
"encounter" AND $enc_rpt = "Surgical Case Times")
 fin = ids->fin
 ,case_nbr = sc.surg_case_nbr_formatted
 ,case_event =
UAR_GET_CODE_DISPLAY(c.task_assay_cd)
 ,event_dt_tm =
DATETIMEZONEFORMAT(c.case_time_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,surgical_area =
UAR_GET_CODE_DISPLAY(sc.surg_area_cd)
 ,staging_area =
UAR_GET_CODE_DISPLAY(c.stage_cd)
 ,operating_area =
UAR_GET_CODE_DISPLAY(sc.surg_op_loc_cd)
 ,c.surg_case_id
 ,c.case_times_id
 ,c.task_assay_cd
 FROM SURGICAL_CASE sc
 ,CASE_TIMES c
 PLAN sc WHERE sc.encntr_id =
ids->encntr_id
 JOIN c WHERE c.surg_case_id =
sc.surg_case_id
 AND c.active_ind = 1
 ORDER BY c.case_time_dt_tm
ELSEIF($cat =
"encounter" AND $enc_rpt = "Transfusions")
 fin = ids->fin
 ,category =
UAR_GET_CODE_DISPLAY(prod.product_cat_cd)
,prod.product_nbr
,product_type = UAR_GET_CODE_DISPLAY(prod.product_cd)
 ,abo_rh =
CONCAT(TRIM(UAR_GET_CODE_DISPLAY(bp.cur_abo_cd)), " ",
TRIM(UAR_GET_CODE_DISPLAY(bp.cur_rh_cd)))
 ,ordered_dt_tm =
         DATETIMEZONEFORMAT(o_dispense.orig_order_dt_tm,
pe_transfuse.event_tz, "MM/DD/YYYY HH:MM;;q")
 ,dispensed_dt_tm =
DATETIMEZONEFORMAT(pe_dispense.event_dt_tm, pe_dispense.event_tz,
"MM/DD/YYYY HH:MM;;q")
 ,transfused_dt_tm =
DATETIMEZONEFORMAT(pe_transfuse.event_dt_tm, pe_transfuse.event_tz,
"MM/DD/YYYY HH:MM;;q")
 ,xf.transfused_vol
 ,units =
UAR_GET_CODE_DISPLAY(prod.cur_unit_meas_cd)
 ,order_detail =
SUBSTRING(1,255,replace_CRLF(o_dispense.clinical_display_line))
 ,event_type =
UAR_GET_CODE_DISPLAY(pe_transfuse.event_type_cd)
 ,inventory_loc =
UAR_GET_CODE_DISPLAY(prod.cur_inv_locn_cd)
 ,owner =
UAR_GET_CODE_DISPLAY(prod.cur_owner_area_cd)
 ,donation_type =
UAR_GET_CODE_DISPLAY(prod.donation_type_cd)
 ,order_to_dispense =
FORMAT(DATETIMEDIFF(pe_dispense.event_dt_tm, o_dispense.orig_order_dt_tm,
7),"####d.##h.##m")
 ,dispense_to_transfusion =
FORMAT(DATETIMEDIFF(pe_transfuse.event_dt_tm, pe_dispense.event_dt_tm,
7),"####d.##h.##m")
 ,order_to_transfusion =
FORMAT(DATETIMEDIFF(pe_transfuse.event_dt_tm, o_dispense.orig_order_dt_tm,
7),"####d.##h.##m")
 ;identifiers
 ,pe_transfuse.encntr_id
 ,pe_dispense.order_id
 ,xf.product_id
 ,xf.product_event_id
 FROM PRODUCT_EVENT pe_transfuse
 ,(LEFT JOIN PRODUCT_EVENT pe_dispense
ON pe_dispense.product_event_id = pe_transfuse.related_product_event_id
         AND
pe_dispense.event_type_cd = 1436) ;dispense
 ,(LEFT JOIN ORDERS o_dispense ON
o_dispense.order_id = pe_dispense.order_id
         AND
o_dispense.active_ind = 1)
 ,PRODUCT prod
 ,(LEFT JOIN BLOOD_PRODUCT bp ON
bp.product_id = prod.product_id)
 ,TRANSFUSION xf
 PLAN pe_transfuse WHERE
pe_transfuse.encntr_id = ids->encntr_id
 JOIN prod WHERE prod.product_id =
pe_transfuse.product_id
 JOIN xf WHERE xf.product_event_id =
pe_transfuse.product_event_id
 AND xf.active_ind = 1
 JOIN bp
 JOIN pe_dispense
 JOIN o_dispense
 ORDER BY pe_transfuse.event_dt_tm
ELSEIF($cat =
"encounter" AND $enc_rpt = "Vital Signs")
 fin = ids->fin
 ,event = UAR_GET_CODE_DISPLAY(ce.event_cd)
 ,result = ce.result_val
 ,result_units =
UAR_GET_CODE_DISPLAY(ce.result_units_cd)
 ,result_flag =
UAR_GET_CODE_DISPLAY(ce.normalcy_cd)
 ,result_source =
UAR_GET_CODE_DISPLAY(ce.source_cd)
 ,contrib_system =
UAR_GET_CODE_DISPLAY(ce.contributor_system_cd)
 ,entry_mode =
UAR_GET_CODE_DISPLAY(ce.entry_mode_cd)
 ,event_dt_tm =
DATETIMEZONEFORMAT(ce.event_end_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,verified_dt_tm =
DATETIMEZONEFORMAT(ce.verified_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,performed_dt_tm =
DATETIMEZONEFORMAT(ce.performed_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,personnel =
         IF(veri_p.person_id !=
0) veri_p.name_full_formatted
         ELSE
perf_p.name_full_formatted
         ENDIF
 ;REFERENCE RANGES
 ,discrete_task_assay =
UAR_GET_CODE_DISPLAY(ce.task_assay_cd)
 ,ce.critical_low
 ,ce.normal_low
 ,ce.normal_high
 ,ce.critical_high
;IDENTIFIERS
 ,ce.event_id
 ,ce.event_cd
 ,ce.task_assay_cd
 FROM CLINICAL_EVENT ce
 ,(LEFT JOIN PRSNL perf_p ON
perf_p.person_id = ce.performed_prsnl_id)
 ,(LEFT JOIN PRSNL veri_p ON
veri_p.person_id = ce.verified_prsnl_id)
 PLAN ce WHERE ce.encntr_id =
ids->encntr_id
         AND ce.event_cd IN (
                 SELECT
event_cd
                 FROM
V500_EVENT_SET_EXPLODE
                 WHERE
event_set_cd IN (
3995611 ;Weight Change Information
,3995650 ;Pediatric Growth Measurements
,7917830093 ;RPM-HT Patient Generated Vitals
,36852281 ;Anesthesia Vital Signs
,3995640 ;Orthostatic Vital Signs
,38808219 ;Physical Activity Vital Signs
,3995619 ;Vital Signs
,4720865 ;Vital Signs with Activity
)
)
 AND (ce.view_level = 1 OR
ce.entry_mode_cd = 679378) ;working view
 AND ce.valid_until_dt_tm >= SYSDATE
 AND ce.result_status_cd NOT IN
(28,29,30,31) ;IN ERROR
JOIN perf_p
JOIN veri_p
ORDER BY ce.event_end_dt_tm DESC, ce.verified_dt_tm DESC,
ce.performed_dt_tm DESC
/**************************************************************
; OUTPUT -
Patient-level Reports
**************************************************************/
ELSEIF($cat =
"patient" AND $pat_rpt = "Identity and Demographics")
 name_full = p.name_full_formatted
 ,p.name_last_key
 ,p.name_first_key
 ,p.name_middle_key
 ,edipi = edipi.alias
 ,birth_dt_tm =
DateBirthFormat(p.birth_dt_tm, p.birth_tz, p.birth_prec_flag,
"MM/DD/YYYY;;d")
 ,current_age =
         IF(p.deceased_dt_tm !=
0) CNVTAGE(p.birth_dt_tm, p.deceased_dt_tm, 0)
         ELSE
CNVTAGE(p.birth_dt_tm, SYSDATE, 0)
         ENDIF
 ,admin_sex = UAR_GET_CODE_DISPLAY(p.sex_cd)
 ,birth_sex =
UAR_GET_CODE_DISPLAY(pp.birth_sex_cd)
 ,race = UAR_GET_CODE_DISPLAY(p.race_cd)
 ,ethnicity =
UAR_GET_CODE_DISPLAY(p.ethnic_grp_cd)
 ,religion =
UAR_GET_CODE_DISPLAY(p.religion_cd)
 ,language =
UAR_GET_CODE_DISPLAY(p.language_cd)
 ,interpreter_req =
UAR_GET_CODE_DISPLAY(pp.interp_required_cd)
 ,survey_permission =
UAR_GET_CODE_DISPLAY(pp.contact_for_research_perm_cd)
 ,deceased_status =
UAR_GET_CODE_DISPLAY(p.deceased_cd)
 ;,deceased_dt_tm =
DateDeceasedFormat(p.deceased_dt_tm, p.deceased_tz, "MM/DD/YYYY;;d")
 ,p.deceased_dt_tm
 ,age_at_death = IF(p.deceased_dt_tm != 0)
CNVTAGE(p.birth_dt_tm, p.deceased_dt_tm, 0) ELSE "" ENDIF
 ,military_status =
UAR_GET_CODE_DISPLAY(p.vet_military_status_cd)
 ,assigned_unit = assigned_alias.alias
 ,attached_unit = attached_alias.alias
 ,species =
UAR_GET_CODE_DISPLAY(p.species_cd)
 ,last_updated = p.updt_dt_tm
"MM/DD/YYYY HH:MM;;q"
 ,p.person_id
 FROM PERSON p
 ,(LEFT JOIN PERSON_ALIAS edipi ON
edipi.person_id = p.person_id
 AND edipi.person_alias_type_cd =
value(UAR_GET_CODE_BY("MEANING",4,"MILITARYID"))
 AND edipi.end_effective_dt_tm >
SYSDATE
 AND edipi.active_ind = 1)
 ,(LEFT JOIN PERSON_MILITARY pm ON
pm.person_id = p.person_id)
 ,(LEFT JOIN ORGANIZATION_ALIAS
assigned_alias ON assigned_alias.organization_id = pm.assigned_unit_org_id
 AND assigned_alias.org_alias_type_cd =
1129 ;Employer Code
 AND assigned_alias.end_effective_dt_tm
> SYSDATE
 AND assigned_alias.active_ind = 1)
 ,(LEFT JOIN ORGANIZATION_ALIAS
attached_alias ON attached_alias.organization_id = pm.attached_unit_org_id
 AND attached_alias.org_alias_type_cd =
1129 ;Employer Code
 AND attached_alias.end_effective_dt_tm
> SYSDATE
 AND attached_alias.active_ind = 1)
 ,PERSON_PATIENT pp
 PLAN p WHERE p.person_id =
ids->person_id
 JOIN pp WHERE pp.person_id = p.person_id
 JOIN edipi
 JOIN pm
 JOIN assigned_alias
 JOIN attached_alias
ELSEIF($cat =
"patient" AND $pat_rpt = "Aliases")
 person_alias_type =
UAR_GET_CODE_DISPLAY(pa.person_alias_type_cd)
 ,alias_pool =
UAR_GET_CODE_DISPLAY(pa.alias_pool_cd)
 ,pa.alias
 ,status =
         IF(pa.active_ind = 1 AND
pa.end_effective_dt_tm > SYSDATE) "Active/Current"
         ELSEIF(pa.active_ind = 1
AND pa.end_effective_dt_tm <= SYSDATE) "Active/Historical"
         ELSEIF(pa.active_ind = 0
AND pa.end_effective_dt_tm > SYSDATE) "Inactive/Current"
         ELSEIF(pa.active_ind = 0
AND pa.end_effective_dt_tm <= SYSDATE) "Inactive/Historical"
         ELSE "unmapped
value"
         ENDIF
 ,contrib_system =
UAR_GET_CODE_DISPLAY(pa.contributor_system_cd)
 ,pa.beg_effective_dt_tm
"MM/DD/YYYY;;d"
 ,pa.end_effective_dt_tm
"MM/DD/YYYY;;d"
 ,pa.active_ind
 ,pa.person_alias_type_cd
 ,pa.alias_pool_cd
 ,pa.person_alias_id
 FROM PERSON_ALIAS pa
 PLAN pa WHERE pa.person_id =
ids->person_id
 ORDER BY status, person_alias_type,
pa.beg_effective_dt_tm
ELSEIF($cat =
"patient" AND $pat_rpt = "Allergies")
;TODO add free-text allergy indicator
 substance = IF(TEXTLEN(n.source_string)
< 2) CNVTUPPER(a.substance_ftdesc) ELSE CNVTUPPER(n.source_string) ENDIF
 ,status =
UAR_GET_CODE_DISPLAY(a.reaction_status_cd)
 ,category =
UAR_GET_CODE_DISPLAY(a.substance_type_cd)
 ,type =
UAR_GET_CODE_DISPLAY(a.reaction_class_cd)
 ,severity =
UAR_GET_CODE_DISPLAY(a.severity_cd)
 ,react.reactions
 ;,interaction =
 ,comment =
SUBSTRING(1,512,replace_CRLF(ac.allergy_comment))
 ,ac.comment_dt_tm
 ,allergy_source = IF(a.source_of_info_cd =
0) a.source_of_info_ft ELSE UAR_GET_CODE_DISPLAY(a.source_of_info_cd) ENDIF
 ,reviewed_on =
DATETIMEZONEFORMAT(a.reviewed_dt_tm, a.reviewed_tz, "MM/DD/YYYY
HH:MM;;q")
 ,reviewed_by =
         IF(rev_p.position_cd !=
0)
                 BUILD(TRIM(rev_p.name_full_formatted),
" (", TRIM(UAR_GET_CODE_DISPLAY(rev_p.position_cd)), ")")
         ELSE
rev_p.name_full_formatted
         ENDIF
 ,estimated_onset =
DATETIMEZONEFORMAT(a.onset_dt_tm, a.onset_tz, "MM/DD/YYYY;;d")
 ,updated_on = a.updt_dt_tm "MM/DD/YYYY
HH:MM;;q"
 ,updated_by =
         IF(updt_p.position_cd !=
0)
                 BUILD(TRIM(updt_p.name_full_formatted),
" (", TRIM(UAR_GET_CODE_DISPLAY(updt_p.position_cd)), ")")
         ELSE
updt_p.name_full_formatted
         ENDIF
 ,data_status =
UAR_GET_CODE_DISPLAY(a.data_status_cd)
 ,contrib_system =
UAR_GET_CODE_DISPLAY(a.contributor_system_cd)
 ,a.allergy_id
 ,a.allergy_instance_id
 FROM ALLERGY a
 ,(LEFT JOIN
 (SELECT DISTINCT
 r.allergy_instance_id
         ,reactions =
LISTAGG(n.source_string, "; ", "OVERFLOW")
 OVER(PARTITION BY
r.allergy_instance_id ORDER BY
CNVTUPPER(n.source_string))
 FROM REACTION r, NOMENCLATURE n
 WHERE r.reaction_nom_id =
n.nomenclature_id
 AND r.active_ind = 1
 AND n.end_effective_dt_tm >
SYSDATE
 AND n.active_ind = 1
 WITH
SQLTYPE("f8","vc")
 ) react ON a.allergy_instance_id =
react.allergy_instance_id)
 ,(LEFT JOIN ALLERGY_COMMENT ac ON
ac.allergy_id = a.allergy_id
         AND ac.active_ind = 1)
 ,NOMENCLATURE n
 ,PRSNL rev_p
 ,PRSNL updt_p
 PLAN a WHERE a.person_id =
ids->person_id
 AND a.active_ind = 1
 JOIN n WHERE a.substance_nom_id =
n.nomenclature_id
 JOIN rev_p WHERE a.reviewed_prsnl_id =
rev_p.person_id
 JOIN updt_p WHERE a.updt_id =
updt_p.person_id
 JOIN react
 JOIN ac
 ORDER BY status, substance
ELSEIF($cat =
"patient" AND $pat_rpt = "Appointments (future)")
 ;TODO distinct due to dental appointment
weirdness
 DISTINCT
patient = p.name_full_formatted
,location = UAR_GET_CODE_DISPLAY(sa.appt_location_cd)
,appt_type = UAR_GET_CODE_DISPLAY(se.appt_type_cd)
,appt_time = DATETIMEZONEFORMAT(sa.beg_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
,sa.duration
,appt_status = UAR_GET_CODE_DISPLAY(sa.sch_state_cd)
,slot_type = sar.slot_mnemonic
,resource = UAR_GET_CODE_DISPLAY(sar.resource_cd)
,role = sar.role_description
,sar.role_meaning
,sa.sch_event_id
FROM SCH_APPT sa
,(LEFT JOIN ENCOUNTER e ON e.encntr_id = sa.encntr_id)
,(LEFT JOIN TIME_ZONE_R tz ON tz.parent_entity_id = e.loc_facility_cd
AND tz.parent_entity_name = "LOCATION")
,SCH_EVENT se
,(LEFT JOIN SCH_APPT sar ON sar.sch_event_id = se.sch_event_id
AND sar.sch_role_cd != 4572) ;get non-patient versions
,PERSON p
PLAN sa WHERE sa.person_id = ids->person_id
AND sa.beg_dt_tm > SYSDATE
AND sa.sch_role_cd = 4572 ;patient
AND sa.sch_state_cd != 4535 ;canceled
AND sa.end_effective_dt_tm > SYSDATE
AND sa.version_dt_tm > SYSDATE
AND sa.active_ind = 1
JOIN se WHERE se.sch_event_id = sa.sch_event_id
AND se.end_effective_dt_tm > SYSDATE
AND se.version_dt_tm > SYSDATE
AND se.active_ind = 1
JOIN p WHERE p.person_id = sa.person_id
JOIN sar
JOIN e
JOIN tz
ORDER BY sa.beg_dt_tm
ELSEIF($cat =
"patient" AND $pat_rpt = "Appointments (past)")
DISTINCT ;needed due to duplicates for each dental appointment
patient = p.name_full_formatted
,location = UAR_GET_CODE_DISPLAY(sa.appt_location_cd)
 ,appt_type =
UAR_GET_CODE_DISPLAY(se.appt_type_cd)
 ,appt_time =
DATETIMEZONEFORMAT(sa.beg_dt_tm, DATETIMEZONEBYNAME(tz.time_zone),
"MM/DD/YYYY HH:MM;;q")
 ,sa.duration
 ,appt_status =
UAR_GET_CODE_DISPLAY(sa.sch_state_cd)
,fin = fin.alias
,encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
,med_service = UAR_GET_CODE_DISPLAY(e.med_service_cd)
,attending_provider = attending.name_full_formatted
,sa.sch_event_id
FROM SCH_APPT sa
,(LEFT JOIN ENCNTR_ALIAS fin ON fin.encntr_id = sa.encntr_id
AND fin.encntr_alias_type_cd = 1077 ;FIN
AND fin.end_effective_dt_tm > SYSDATE
AND fin.active_ind = 1)
,(LEFT JOIN ENCOUNTER e ON e.encntr_id = sa.encntr_id)
,(LEFT JOIN ENCNTR_PRSNL_RELTN epr ON epr.encntr_id = e.encntr_id
AND epr.encntr_prsnl_r_cd = 1119
AND epr.end_effective_dt_tm > SYSDATE
AND epr.active_ind = 1)
,(LEFT JOIN PRSNL attending ON attending.person_id =
epr.prsnl_person_id)
,(LEFT JOIN TIME_ZONE_R tz ON tz.parent_entity_id = e.loc_facility_cd
AND tz.parent_entity_name = "LOCATION")
 ,SCH_EVENT se
 ,(LEFT JOIN SCH_EVENT_ACTION
sea ON sea.sch_event_id = se.sch_event_id
         AND sea.sch_action_cd =
4517 ;schedule
         AND sea.active_ind = 1)
,PERSON p
PLAN sa WHERE sa.person_id = ids->person_id
AND sa.role_meaning = "PATIENT"
AND sa.sch_state_cd IN ( ;CS 14233
4536 ;checked in
,4537 ;checked out
,4538 ;confirmed
,4054213 ;complete
,4543 ;noshow
)
AND sa.beg_dt_tm <= SYSDATE
AND sa.end_effective_dt_tm > SYSDATE
AND sa.version_dt_tm > SYSDATE
AND sa.active_ind = 1
JOIN se WHERE se.sch_event_id = sa.sch_event_id
 AND se.end_effective_dt_tm
> SYSDATE
 AND se.version_dt_tm >
SYSDATE
 AND se.active_ind =
1
JOIN p WHERE p.person_id = sa.person_id
JOIN sea
JOIN fin
JOIN e
JOIN epr
JOIN attending
JOIN tz
ORDER BY sa.beg_dt_tm
ELSEIF($cat =
"patient" AND $pat_rpt = "Contact Info (addresses)")
 type =
UAR_GET_CODE_DISPLAY(a.address_type_cd)
 ,street_addr1 = a.street_addr
 ,a.street_addr2
 ,a.street_addr3
 ,a.street_addr4
 ,a.city
 ,state =
 IF(a.state_cd > 0)
UAR_GET_CODE_DISPLAY(a.state_cd)
 ELSE a.state
 ENDIF
 ,a.zipcode
 ,a.zipcode_key
 ,county =
 IF(a.county_cd > 0)
UAR_GET_CODE_DISPLAY(a.county_cd)
 ELSE a.county
 ENDIF
 ,country =
 IF(a.country_cd > 0)
UAR_GET_CODE_DISPLAY(a.country_cd)
 ELSE a.country
 ENDIF
 ,address_status =
UAR_GET_CODE_DISPLAY(a.address_info_status_cd)
 ,contrib_system =
UAR_GET_CODE_DISPLAY(a.contributor_system_cd)
 ,last_updated = a.updt_dt_tm
"MM/DD/YYYY HH:MM;;q"
 ,sequence = a.address_type_seq
 ,a.address_id
 FROM ADDRESS a
 PLAN a WHERE a.parent_entity_id =
ids->person_id
 AND a.parent_entity_name =
"PERSON"
 AND a.end_effective_dt_tm > SYSDATE
 AND a.active_ind = 1
 ORDER BY type, sequence
ELSEIF($cat =
"patient" AND $pat_rpt = "Contact Info (phone numbers)")
type = UAR_GET_CODE_DISPLAY(ph.phone_type_cd)
,phone_number = ph.phone_num
,ph.extension
,format = UAR_GET_CODE_DISPLAY(ph.phone_format_cd)
,contrib_system = UAR_GET_CODE_DISPLAY(ph.contributor_system_cd)
,last_updated = ph.updt_dt_tm "MM/DD/YYYY HH:MM;;q"
,sequence = ph.phone_type_seq
,ph.phone_id
FROM PHONE ph
PLAN ph WHERE ph.parent_entity_id = ids->person_id
AND ph.parent_entity_name = "PERSON"
AND ph.end_effective_dt_tm > SYSDATE
AND ph.active_ind = 1
ORDER BY type, sequence
ELSEIF($cat =
"patient" AND $pat_rpt = "Emergency Contacts")
name = p.name_full_formatted
,listed_as = UAR_GET_CODE_DISPLAY(ppr.person_reltn_type_cd)
,phone_number = ph.phone_num_key "###-###-####"
,phone_type = UAR_GET_CODE_DISPLAY(ph.phone_type_cd)
,last_updated = ppr.updt_dt_tm
,ppr.person_person_reltn_id
FROM PERSON_PERSON_RELTN ppr
,PERSON p
,(LEFT JOIN PHONE ph ON ph.parent_entity_id = p.person_id
AND ph.end_effective_dt_tm > SYSDATE
AND ph.active_ind = 1)
PLAN ppr WHERE ppr.person_id = ids->person_id
AND ppr.person_reltn_type_cd NOT IN (
1158                ;insured
,4053691        ;family history
,1150                ;default
guarantor
)
AND ppr.end_effective_dt_tm > SYSDATE
AND ppr.active_ind = 1
JOIN p WHERE p.person_id = ppr.related_person_id
JOIN ph
ORDER BY name
ELSEIF($cat =
"patient" AND $pat_rpt = "Employer History")
employer = org.org_name
,occupation = UAR_GET_CODE_DISPLAY(por.empl_occupation_cd)
,current_employer =
IF(por.end_effective_dt_tm > SYSDATE) "yes"
ELSE "no"
ENDIF
,start_rank =
IF(hist.empl_title_cd = 0 OR por.empl_title_cd = 0) ""
ELSE CONCAT(TRIM(UAR_GET_CODE_DISPLAY(hist.empl_title_cd)), " /
",
TRIM(UAR_GET_CODE_DISPLAY(hist.empl_type_cd)))
ENDIF
,end_rank =
IF(hist.empl_title_cd = 0 OR por.empl_title_cd = 0) ""
ELSE CONCAT(TRIM(UAR_GET_CODE_DISPLAY(por.empl_title_cd)), " /
",
TRIM(UAR_GET_CODE_DISPLAY(por.empl_type_cd)))
ENDIF
,por.beg_effective_dt_tm
,por.end_effective_dt_tm
,por.priority_seq
,por.person_org_reltn_id
FROM PERSON_ORG_RELTN por
,(LEFT JOIN (SELECT porh.person_org_reltn_id
,porh.empl_title_cd
,porh.empl_type_cd
,rn = ROW_NUMBER() OVER(PARTITION BY porh.person_org_reltn_id ORDER BY
porh.beg_effective_dt_tm)
FROM PERSON_ORG_RELTN_HIST porh
WHERE porh.active_ind = 1
WITH
SQLTYPE("f8","f8","f8","i4")) hist
ON por.person_org_reltn_id = hist.person_org_reltn_id
AND hist.rn = 1)
,ORGANIZATION org
PLAN por WHERE por.person_id = ids->person_id
AND por.person_org_reltn_cd = 1136 ;employer
AND por.active_ind = 1
JOIN org WHERE org.organization_id = por.organization_id
JOIN hist
ORDER BY current_employer DESC, por.beg_effective_dt_tm DESC,
por.priority_seq
ELSEIF($cat =
"patient" AND $pat_rpt = "External Data")
;TODO anyway to localize the time zones here?
;sort by type, then date.
;move clob data closer
;identify source
;document level?
data_type = UAR_GET_CODE_DISPLAY(edi.data_type_cd)
,requested_action = UAR_GET_CODE_DISPLAY(edi.requested_action_cd)
,requested_dt_tm = edi.requested_action_dt_tm "MM/DD/YYYY
HH:MM;;q"
;        ,edi.action_dt_tm
"MM/DD/YYYY HH:MM;;q"
;        ,action_prsnl
=
;                IF(edi.action_prsnl_id
!= 0)
;                        IF(pr.position_cd
!= 0)
;                                BUILD(TRIM(pr.name_full_formatted),
" (", TRIM(UAR_GET_CODE_DISPLAY(pr.position_cd)), ")")
;                        ELSE
pr.name_full_formatted
;                        ENDIF
;                ELSE
""
;                ENDIF
,data_source = UAR_GET_CODE_DISPLAY(edi.data_source_cd)
;,edi.data_source_name
,data_status = UAR_GET_CODE_DISPLAY(edi.data_status_cd)
,edc.clob_type_txt
,clob_length =
TEXTLEN(edc.data_clob)        ;CLOB can
be ~2 million chars (character long object)
,clob = TRIM(SUBSTRING(1,30000,replace_CRLF(edc.data_clob))) ;max
output in Discern = 31784 characters.
,edi.source_reference_name
,edi.source_reference_id
,edi.chart_reference_name
,edi.chart_reference_id
;identifiers
,edi.encntr_id
,edi.ext_data_info_id
,edi.ext_data_group_id
,edi.ext_data_clob_id
FROM EXT_DATA_INFO edi
,EXT_DATA_CLOB edc
,PERSON p
,PRSNL pr
PLAN edi WHERE edi.person_id = ids->person_id
JOIN edc WHERE edc.ext_data_clob_id = edi.ext_data_clob_id
JOIN p WHERE p.person_id = edi.person_id
JOIN pr WHERE pr.person_id = edi.action_prsnl_id
ORDER BY data_type, edi.requested_action_dt_tm;, edi.action_dt_tm
ELSEIF($cat =
"patient" AND $pat_rpt = "Family History")
condition = n.source_string
,relation = UAR_GET_CODE_DESCRIPTION(ppr.person_reltn_cd) ;cs 40
,value_flag = EVALUATE(fh.fhx_value_flag,
0, "Negative",
1, "Positive",
2, "Unknown",
3, "Unable to Obtain",
4, "Patient Adopted",
"<unmapped value>")
,n.concept_cki
,fh.fhx_activity_id
FROM FHX_ACTIVITY fh
,(LEFT JOIN PERSON rp ON rp.person_id = fh.related_person_id)
,(LEFT JOIN PERSON_PERSON_RELTN ppr ON ppr.person_person_reltn_id =
rp.ft_entity_id
AND ppr.end_effective_dt_tm > SYSDATE
AND ppr.active_ind = 1)
,NOMENCLATURE n
PLAN fh WHERE fh.person_id = ids->person_id
AND fh.end_effective_dt_tm > SYSDATE
AND fh.active_ind = 1
JOIN n WHERE n.nomenclature_id = fh.nomenclature_id
JOIN rp
JOIN ppr
ORDER BY condition, relation
ELSEIF($cat =
"patient" AND $pat_rpt = "Health Plans")
DISTINCT
profile =
IF(profile.profile_type_cd = 0 AND ppr.end_effective_dt_tm <
SYSDATE) "zz Historical"
ELSEIF(profile.profile_type_cd = 0 AND ppr.end_effective_dt_tm >
SYSDATE) "z Unassociated"
ELSE UAR_GET_CODE_DISPLAY(profile.profile_type_cd)
ENDIF
,plan_seq = IF(profile.profile_type_cd = 0) 0
ELSE profile.plan_seq
ENDIF
,health_plan = hp.plan_name
,payer = org.org_name
,financial_class = UAR_GET_CODE_DISPLAY(hp.financial_class_cd)
,subscriber = subscriber.name_full_formatted
,ppr.member_nbr
,ppr.group_nbr
,begin_date = ppr.beg_effective_dt_tm
,plan_type = UAR_GET_CODE_DISPLAY(hp.plan_type_cd)
,service_type = UAR_GET_CODE_DISPLAY(hp.service_type_cd)
,plan_reltn = UAR_GET_CODE_DISPLAY(ppr.person_plan_r_cd)
,signature_on_file = UAR_GET_CODE_DISPLAY(ppr.signature_on_file_cd)
,subscriber_edipi = sub_edipi.alias
,subscriber_agency = govt_agency.org_name
,subscriber_employer = por.ft_org_name
,subscriber_status = UAR_GET_CODE_DISPLAY(por.empl_occupation_cd)
 ,subscriber_rank =
UAR_GET_CODE_DISPLAY(por.empl_title_cd)
 ,subscriber_grade =
UAR_GET_CODE_DISPLAY(por.empl_type_cd)
 ,ppr.person_plan_reltn_id
FROM PERSON_PLAN_RELTN ppr
,(LEFT JOIN (
SELECT
pppr.person_plan_reltn_id
,ppp.profile_type_cd
,plan_seq = pppr.priority_seq
FROM PERSON_PLAN_PROFILE_RELTN pppr
,PERSON_PLAN_PROFILE ppp
WHERE pppr.active_ind = 1
AND ppp.person_plan_profile_id = pppr.person_plan_profile_id
AND ppp.active_ind = 1
WITH SQLTYPE("f8","f8","i4")) profile
ON profile.person_plan_reltn_id = ppr.person_plan_reltn_id)
,HEALTH_PLAN hp
,ORGANIZATION org
,PERSON subscriber
,(LEFT JOIN PERSON_ALIAS sub_edipi ON sub_edipi.person_id =
subscriber.person_id
AND sub_edipi.person_alias_type_cd = 22 ;EDIPI
AND sub_edipi.end_effective_dt_tm > SYSDATE
AND sub_edipi.active_ind =
1)
,(LEFT JOIN PERSON_ORG_RELTN por ON por.person_id =
subscriber.person_id
AND por.person_org_reltn_cd = 1136 ;employer
AND por.active_ind = 1)
,(LEFT JOIN ORGANIZATION govt_agency ON govt_agency.organization_id =
por.organization_id)
PLAN ppr WHERE ppr.person_id = ids->person_id
AND ppr.priority_seq != 0
AND ppr.active_ind = 1
JOIN hp WHERE hp.health_plan_id = ppr.health_plan_id
JOIN org WHERE org.organization_id = ppr.organization_id
JOIN subscriber WHERE subscriber.person_id = ppr.subscriber_person_id
JOIN profile
JOIN por
JOIN sub_edipi
JOIN govt_agency
ORDER BY profile, plan_seq, ppr.person_plan_reltn_id
;ELSEIF($cat
= "patient" AND $pat_rpt = "Health Recommendations")
; TODO
ELSEIF($cat =
"patient" AND $pat_rpt = "Immunizations")
DISTINCT ;needed due to vaccine group duplication
 vg.vaccine_group
 ,immunization =
UAR_GET_CODE_DISPLAY(ce.event_cd)
 ,immunization_dt_tm =
DATETIMEZONEFORMAT(ce.event_end_dt_tm, ce.event_end_tz,
"MM/DD/YYYY;;d")
 ,documented_dt_tm =
DATETIMEZONEFORMAT(ce.performed_dt_tm, ce.performed_tz,
"MM/DD/YYYY;;d")
 ,documented_by =
         IF(pr.person_id != 0)
                 IF(pr.position_cd
!= 0)
                         BUILD(TRIM(pr.name_full_formatted),
" (", TRIM(UAR_GET_CODE_DISPLAY(pr.position_cd)), ")")
                 ELSE
pr.name_full_formatted
                 ENDIF
         ELSE ""
         ENDIF
 ,encntr_type =
UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
 ,fin = fin.alias
 ,facility =
UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
 ,nurse_unit =
UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
 ,reg_dt_tm =
DATETIMEZONEFORMAT(e.reg_dt_tm, DATETIMEZONEBYNAME(tz.time_zone),
"MM/DD/YYYY HH:MM;;q")
 ,ordered_as =
UAR_GET_CODE_DISPLAY(o.catalog_cd)
 ,contrib_system =
UAR_GET_CODE_DISPLAY(ce.contributor_system_cd)
 ,event_source =
UAR_GET_CODE_DISPLAY(ce.source_cd)
 ,event_entry_mode =
UAR_GET_CODE_DISPLAY(ce.entry_mode_cd)
 ,dosage = cmr.admin_dosage
 ,dosage_units =
UAR_GET_CODE_DISPLAY(cmr.dosage_unit_cd)
 ,route =
UAR_GET_CODE_DISPLAY(cmr.admin_route_cd)
 ,admin_site =
UAR_GET_CODE_DISPLAY(cmr.admin_site_cd)
 ,lot_nbr = cmr.substance_lot_number
 ,expire_date = cmr.substance_exp_dt_tm
 ,manufacturer =
UAR_GET_CODE_DISPLAY(cmr.substance_manufacturer_cd)
 ,cvx = EVALUATE2(
 IF(SIZE(TRIM(ccm.concept_cki, 3)) >=
5) SUBSTRING(5,SIZE(ccm.concept_cki),ccm.concept_cki)
 ENDIF)
 ,ce.order_id
 ,ce.event_cd
 ,ce.event_id
 FROM CLINICAL_EVENT ce
,(LEFT JOIN (SELECT
 events.event_cd
 ,vaccine_group =
LISTAGG(cv.display, ",
")        OVER(PARTITION BY
events.event_cd ORDER BY cv.display)
 FROM ((SELECT DISTINCT
ce.event_cd
                 
FROM CLINICAL_EVENT ce
                 
WHERE ce.person_id = ids->person_id
AND ce.event_class_cd = 228 ;immunization
AND ce.result_status_cd NOT IN (28,29,30,31) ;in error
AND ce.valid_until_dt_tm > SYSDATE
 ORDER BY ce.event_cd
 WITH SQLTYPE("f8")
) events )
                 ,CODE_VALUE_GROUP
cvg
                 ,CODE_VALUE
cv
WHERE events.event_cd = cvg.child_code_value
AND cvg.parent_code_value = cv.code_value
AND cv.code_set = 4003106
AND cv.active_ind = 1
 WITH
SQLTYPE("f8","vc")
         ) vg ON vg.event_cd =
ce.event_cd)
 ,(LEFT JOIN CE_MED_RESULT cmr ON
cmr.event_id = ce.event_id)
 ,(LEFT JOIN ORDERS o ON o.order_id =
ce.order_id)
 ,(LEFT JOIN ORDER_CATALOG_SYNONYM ocs
ON ocs.synonym_id = o.synonym_id)
 ,(LEFT JOIN CMT_CROSS_MAP ccm ON
ccm.target_concept_cki = ocs.concept_cki
 AND ccm.map_type_cd = 22901771
;CVX=MULTUM
 AND ccm.active_ind =
1)
 ,ENCOUNTER e
 ,(LEFT JOIN ENCNTR_ALIAS fin ON
fin.encntr_id = e.encntr_id
         AND
fin.encntr_alias_type_cd = 1077 ;FIN
         AND
fin.end_effective_dt_tm > SYSDATE
         AND fin.active_ind = 1)
 ,(LEFT JOIN TIME_ZONE_R tz ON
tz.parent_entity_id = e.loc_facility_cd
         AND
tz.parent_entity_name = "LOCATION")
 ,PRSNL pr
 PLAN ce WHERE ce.person_id =
ids->person_id
 AND ce.event_class_cd = 228
;immunization
 AND ce.publish_flag = 1 ;visible to
user
 AND ce.view_level = 1 ;visible to
application
 AND ce.result_status_cd NOT IN
(28,29,30,31, 36) ;in error, not done
 AND ce.valid_until_dt_tm > SYSDATE
 JOIN e WHERE ce.encntr_id = e.encntr_id
 JOIN pr WHERE pr.person_id =
ce.performed_prsnl_id
 JOIN vg
 JOIN cmr
 JOIN o
 JOIN ocs
 JOIN ccm
 JOIN fin
 JOIN tz
 ORDER BY ce.event_end_dt_tm
ELSEIF($cat =
"patient" AND $pat_rpt = "Medication Dispense History")
medication = o.order_mnemonic
,dispense_dt_tm = DATETIMEZONEFORMAT(dh.dispense_dt_tm, dh.dispense_tz,
"MM/DD/YYYY;;d")
,quantity = dh.disp_qty
,units = UAR_GET_CODE_DISPLAY(dh.disp_qty_unit_cd)
,odisp.days_supply
,fill_type = EVALUATE(dh.fill_nbr, 0, "Initial",
"Refill")
,dh.fill_nbr
,dh.refills_remaining
,dh.qty_remaining
,last_filled_dt_tm = DATETIMEZONEFORMAT(odisp.last_refill_dt_tm,
odisp.last_refill_tz, "MM/DD/YYYY;;d")
,expire_dt_tm = DATETIMEZONEFORMAT(odisp.expire_dt_tm, odisp.expire_tz,
"MM/DD/YYYY;;d")
,rx_nbr = BUILD(TRIM(UAR_GET_CODE_DISPLAY(odisp.rx_nbr_cd)),
"-", CNVTSTRING(odisp.rx_nbr))
,rx_signature = SUBSTRING(1,255,replace_CRLF(odisp.display_line))
,daw_ind = UAR_GET_CODE_DISPLAY(odisp.daw_cd)
,dispense_priority = UAR_GET_CODE_DISPLAY(dh.disp_priority_cd)
,legal_status = UAR_GET_CODE_DISPLAY(odisp.legal_status_cd)
,pharmacy = UAR_GET_CODE_DISPLAY(dh.disp_sr_cd)
,pharmacy_type = UAR_GET_CODE_DISPLAY(dh.pharm_type_cd)
,workstation = UAR_GET_CODE_DISPLAY(dh.level5_cd)
,dispense_prsnl =
IF(run_p.position_cd != 0)
BUILD(run_p.name_full_formatted, " (",
UAR_GET_CODE_DISPLAY(run_p.position_cd), ")")
ELSE run_p.name_full_formatted
ENDIF
,health_plan = hp.plan_name
,dh.authorization_nbr
,dh.order_id
,dh.dispense_hx_id
FROM ORDERS o
,DISPENSE_HX dh
,ORDER_DISPENSE odisp
,PRSNL run_p
,HEALTH_PLAN hp
PLAN o WHERE o.person_id = ids->person_id
JOIN dh WHERE dh.order_id = o.order_id
AND dh.disp_event_type_cd = 685817 ;dispense
AND dh.crdt_dispense_hx_id = 0 ;only return final/parent rows
AND dh.chrg_dispense_hx_id = 0 ;only return final/parent rows
JOIN odisp WHERE odisp.order_id = dh.order_id
JOIN run_p WHERE run_p.person_id = dh.run_user_id
JOIN hp WHERE hp.health_plan_id = dh.health_plan_id
ORDER BY dh.dispense_dt_tm
ELSEIF($cat =
"patient" AND $pat_rpt = "Medication List")
;TODO - test if Discern Distinct being applied here
DISTINCT
medication = BUILD(UAR_GET_CODE_DESCRIPTION(o.catalog_cd), "
(", o.ordered_as_mnemonic, ")")
,status = EVALUATE(o.orig_ord_as_flag,
         1,
"Prescribed",
         2,
"Documented",
         3,
"Deprecated",
         4, "Pharmacy Charge
Only",
         5, "Satellite
(Super Bill) Meds",
         "<unmapped
value>")
,refills_remaining = odisp.refills_remaining
,expiration_dt_tm = DATETIMEZONEFORMAT(odisp.expire_dt_tm,
odisp.expire_tz, "MM/DD/YYYY;;d")
,details = o.clinical_display_line
,pharmacy = UAR_GET_CODE_DESCRIPTION(dh.disp_sr_cd)
,last_filled_dt_tm = DATETIMEZONEFORMAT(odisp.last_refill_dt_tm,
odisp.last_refill_tz, "MM/DD/YYYY;;d")
,o.order_id
,dispense_order_id = odisp.order_id
FROM ORDERS o
,(LEFT JOIN ORDER_DISPENSE odisp ON odisp.parent_order_id = o.order_id)
,(LEFT JOIN DISPENSE_HX dh ON dh.order_id = odisp.order_id
AND dh.disp_event_type_cd = 685817 ;dispense
AND dh.crdt_dispense_hx_id = 0
AND dh.chrg_dispense_hx_id = 0);only return final/parent row
PLAN o WHERE o.person_id = ids->person_id
AND o.catalog_type_cd = 2516 ;pharmacy
AND o.order_status_cd = 2550 ;ordered
AND o.orig_ord_as_flag IN (1, 2) ;prescribed or documented
AND o.rx_mask = 4 ;med - not exactly right, not always 4, but closest
I've found
AND o.active_ind = 1
JOIN odisp
JOIN dh
ORDER BY CNVTUPPER(UAR_GET_CODE_DESCRIPTION(o.catalog_cd)),
o.orig_order_dt_tm
ELSEIF($cat =
"patient" AND $pat_rpt = "Orders (unresulted)")
orderable = oc.description
,order_dt_tm = DATETIMEZONEFORMAT(o.orig_order_dt_tm,
o.current_start_tz, "MM/DD/YYYY HH:MM;;q")
 ,responsible_provider =
         IF(order_p.position_cd
!= 0)
                 BUILD(order_p.name_full_formatted,
" (", TRIM(UAR_GET_CODE_DISPLAY(order_p.position_cd)), ")")
         ELSE
order_p.name_full_formatted
         ENDIF
 ,originating_fin = ofin.alias
 ,activating_fin = fin.alias
,order_detail =
SUBSTRING(1,255,replace_CRLF(o.order_detail_display_line))
 ,catalog_type =
UAR_GET_CODE_DISPLAY(oc.catalog_type_cd)
 ,sub_type =
         IF(oc.activity_subtype_cd
> 0) UAR_GET_CODE_DISPLAY(oc.activity_subtype_cd)
         ELSE
UAR_GET_CODE_DISPLAY(oc.activity_type_cd)
         ENDIF
 ,order_status =
UAR_GET_CODE_DISPLAY(o.order_status_cd)
 ,dept_status =
UAR_GET_CODE_DISPLAY(o.dept_status_cd)
 ,accession =
UAR_FMT_ACCESSION(ca.accession, size(ca.accession, 1))
 ,collection_status =
         IF(o.catalog_type_cd =
2513)
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
 ELSE ""
 ENDIF
 ,container_location =
UAR_GET_CODE_DISPLAY(c.current_location_cd)
 ;LAB TIMING
 ,collect_dt_tm =
DATETIMEZONEFORMAT(c.drawn_dt_tm, o.current_start_tz, "MM/DD/YYYY
HH:MM;;q")
 ,received_dt_tm =
DATETIMEZONEFORMAT(c.received_dt_tm, o.current_start_tz, "MM/DD/YYYY
HH:MM;;q")
;IDENTIFIERS
,o.order_id
FROM ORDERS o
,(LEFT JOIN ORDER_CONTAINER_R ocr ON ocr.order_id = o.order_id)
,(LEFT JOIN CONTAINER c ON c.container_id = ocr.container_id)
,(LEFT JOIN CONTAINER_ACCESSION ca ON ca.container_id = c.container_id)
,(LEFT JOIN ENCNTR_ALIAS ofin ON ofin.encntr_id =
o.originating_encntr_id
AND ofin.encntr_alias_type_cd = 1077 ;FIN
AND ofin.end_effective_dt_tm > SYSDATE
AND ofin.active_ind = 1)
,(LEFT JOIN ENCNTR_ALIAS fin ON fin.encntr_id = o.encntr_id
AND fin.encntr_alias_type_cd = 1077 ;FIN
AND fin.end_effective_dt_tm > SYSDATE
AND fin.active_ind = 1)
,ORDER_ACTION oa
,ORDER_CATALOG oc
,PRSNL
order_p
PLAN o WHERE o.person_id = ids->person_id
AND o.catalog_type_cd IN (2513, 2517) ;lab, rad
 AND o.order_status_cd IN (
;Active Statuses
2550        ;Ordered
,2548        ;InProcess
,2546        ;Future
,2547        ;Incomplete
,2552        ;Suspended
,2549        ;On Hold, Med
Student
 ;Inactive Statuses
 ,643466        ;Pending Complete
 ,2544        ;Voided
 ,643467        ;Voided With
Results
;Unlisted Statuses (on the front-end filter)
 ,2553.00        ;Unscheduled
 ,2551.00        ;Pending Review
)
AND NOT EXISTS (
SELECT 1
FROM CLINICAL_EVENT ce
WHERE ce.order_id = o.order_id
)
AND o.active_ind = 1
JOIN oa WHERE oa.order_id = o.order_id
AND oa.action_type_cd = 2534 ;ordered
JOIN oc WHERE oc.catalog_cd = o.catalog_cd
JOIN order_p WHERE order_p.person_id = oa.order_provider_id
JOIN ocr
JOIN c
JOIN ca
JOIN ofin
JOIN fin
ORDER BY order_dt_tm
ELSEIF($cat =
"patient" AND $pat_rpt = "Passive Alerts")
pal.alert_source
,alert_text = pal.alert_txt
,alert_category = UAR_GET_CODE_DISPLAY(pal.category_cd)
,action_type = pal.action_type_txt
,action_parameter = pal.action_param_txt
,pal.beg_effective_dt_tm "MM/DD/YYYY HH:MM;;q"
,pal.end_effective_dt_tm "MM/DD/YYYY HH:MM;;q"
,pal.active_ind
,pal.allow_dismiss_ind
,fin = fin.alias
,pal.encntr_id
,pal.passive_alert_id
FROM PASSIVE_ALERT pal
,(LEFT JOIN ENCNTR_ALIAS fin ON fin.encntr_id = pal.encntr_id
AND fin.encntr_alias_type_cd = 1077 ;FIN
AND fin.end_effective_dt_tm > SYSDATE
AND fin.active_ind = 1)
PLAN pal WHERE pal.person_id = ids->person_id
JOIN fin
ORDER BY pal.beg_effective_dt_tm
ELSEIF($cat =
"patient" AND $pat_rpt = "Past Encounters")
;TODO
consider adding # of appts
 fin = fin.alias
 ,facility =
UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
 ,start_location =
 IF(hist.loc_nurse_unit_cd > 0)
UAR_GET_CODE_DISPLAY(hist.loc_nurse_unit_cd)
 ELSE
UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
 ENDIF
 ,end_location =
UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
,encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
 ,med_service =
UAR_GET_CODE_DISPLAY(e.med_service_cd)
 ,reg_dt_tm =
         DATETIMEZONEFORMAT(e.reg_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
 ,disch_dt_tm =
         DATETIMEZONEFORMAT(e.disch_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
 ,attending_provider =
         IF(attend.person_id !=
0)
                 IF(attend.position_cd
!= 0)
                         BUILD(TRIM(attend.name_full_formatted),
" (", TRIM(UAR_GET_CODE_DISPLAY(attend.position_cd)), ")")
                 ELSE
attend.name_full_formatted
                 ENDIF
         ELSE ""
         ENDIF
 ;other info
 ,encntr_status =
UAR_GET_CODE_DISPLAY(e.encntr_status_cd)
 ,admit_type =
UAR_GET_CODE_DISPLAY(e.admit_type_cd)
 ,admit_source =
UAR_GET_CODE_DISPLAY(e.admit_src_cd)
 ,admit_mode =
UAR_GET_CODE_DISPLAY(e.admit_mode_cd)
 ,discharge_disposition =
UAR_GET_CODE_DISPLAY(e.disch_disposition_cd)
;other personnel
 ,registration_prsnl =
         IF(reg.person_id != 0)
reg.name_full_formatted
         ELSEIF(reg.person_id = 0
AND prereg.person_id != 0) prereg.name_full_formatted
         ELSE ""
         ENDIF
 ,admitting_provider =
         IF(admit.person_id != 0)
                 IF(admit.position_cd
!= 0)
                         BUILD(TRIM(admit.name_full_formatted),
" (", TRIM(UAR_GET_CODE_DISPLAY(admit.position_cd)), ")")
                 ELSE
admit.name_full_formatted
                 ENDIF
         ELSE ""
         ENDIF
 ,discharge_prsnl =
         IF(disch.person_id != 0)
                 IF(disch.position_cd
!= 0)
                         BUILD(TRIM(disch.name_full_formatted),
" (", TRIM(UAR_GET_CODE_DISPLAY(disch.position_cd)), ")")
                 ELSE
disch.name_full_formatted
                 ENDIF
         ELSE ""
         ENDIF
 ;,e.active_ind
 ,e.encntr_id
 FROM ENCOUNTER e
 ,(LEFT JOIN (SELECT eh.encntr_id
 ,eh.loc_nurse_unit_cd
 ,eh_rank = ROW_NUMBER()
OVER(PARTITION BY eh.encntr_id ORDER BY eh.beg_effective_dt_tm)
 FROM ENCNTR_LOC_HIST eh
 WHERE eh.active_ind = 1
 WITH
SQLTYPE("f8","f8","i2")) hist
 ON e.encntr_id = hist.encntr_id
 AND hist.eh_rank =
1)
 ,(LEFT JOIN PRSNL prereg on
e.pre_reg_prsnl_id = prereg.person_id)
 ,(LEFT JOIN PRSNL reg on e.reg_prsnl_id
= reg.person_id)
 ,(LEFT JOIN PRSNL disch on
e.disch_prsnl_id = disch.person_id)
 ,(LEFT JOIN ENCNTR_PRSNL_RELTN
epr_attend
 ON e.encntr_id =
epr_attend.encntr_id
 AND epr_attend.encntr_prsnl_r_cd =
1119 ;Attending Provider
 AND epr_attend.active_ind = 1
 AND epr_attend.end_effective_dt_tm
> SYSDATE)
 ,(LEFT JOIN PRSNL attend ON
epr_attend.prsnl_person_id = attend.person_id)
 ,(LEFT JOIN ENCNTR_PRSNL_RELTN
epr_admit
 ON e.encntr_id =
epr_admit.encntr_id
 AND epr_admit.encntr_prsnl_r_cd =
1116 ;Admitting Provider
 AND epr_admit.active_ind = 1
 AND epr_admit.end_effective_dt_tm
> SYSDATE)
 ,(LEFT JOIN PRSNL admit ON
epr_admit.prsnl_person_id =
admit.person_id)
 ,(LEFT JOIN ENCNTR_ALIAS fin ON
fin.encntr_id = e.encntr_id
         AND
fin.encntr_alias_type_cd = 1077 ;FIN
         AND
fin.end_effective_dt_tm > SYSDATE
         AND fin.active_ind = 1)
 ,TIME_ZONE_R tz
 PLAN e WHERE e.person_id =
ids->person_id
 AND e.end_effective_dt_tm > SYSDATE
 AND e.active_ind = 1
 JOIN tz WHERE tz.parent_entity_id =
e.loc_facility_cd
         AND
tz.parent_entity_name = "LOCATION"
 JOIN fin
 JOIN hist
 JOIN prereg
 JOIN reg
 JOIN disch
 JOIN epr_attend
 JOIN attend
 JOIN epr_admit
 JOIN
admit
 ORDER BY e.reg_dt_tm
ELSEIF($cat =
"patient" AND $pat_rpt = "Past Encounters (interactive)")
 fin = fin.alias
 ,facility =
UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
 ,start_location =
 IF(hist.loc_nurse_unit_cd > 0)
UAR_GET_CODE_DISPLAY(hist.loc_nurse_unit_cd)
 ELSE
UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
 ENDIF
 ,end_location =
UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
,encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
 ,med_service =
UAR_GET_CODE_DISPLAY(e.med_service_cd)
 ,create_dt_tm =
         DATETIMEZONEFORMAT(e.create_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
 ,reg_dt_tm =
         DATETIMEZONEFORMAT(e.reg_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
 ,disch_dt_tm =
         DATETIMEZONEFORMAT(e.disch_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
 ,complete_dt_tm =
         DATETIMEZONEFORMAT(e.encntr_complete_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
 ,attending_provider =
         IF(attend.person_id !=
0) attend.name_full_formatted
         ELSE ""
         ENDIF
 ,collapsed_reg_dt_tm =
IF(e.reg_dt_tm IS NULL) e.create_dt_tm; "YYYYMMDDHHMM;;q"
ELSE e.reg_dt_tm; "YYYYMMDDHHMM;;q"
ENDIF
 FROM ENCOUNTER e
 ,(LEFT JOIN (SELECT eh.encntr_id
 ,eh.loc_nurse_unit_cd
 ,eh_rank = ROW_NUMBER()
OVER(PARTITION BY eh.encntr_id ORDER BY eh.beg_effective_dt_tm)
 FROM ENCNTR_LOC_HIST eh
 WHERE eh.active_ind = 1
 WITH
SQLTYPE("f8","f8","i2")) hist
 ON e.encntr_id = hist.encntr_id
 AND hist.eh_rank =
1)
 ,(LEFT JOIN ENCNTR_PRSNL_RELTN
epr_attend
 ON e.encntr_id =
epr_attend.encntr_id
 AND epr_attend.encntr_prsnl_r_cd =
1119 ;Attending Provider
 AND epr_attend.active_ind = 1
 AND epr_attend.end_effective_dt_tm
> SYSDATE)
 ,(LEFT JOIN PRSNL attend ON
epr_attend.prsnl_person_id = attend.person_id)
 ,(LEFT JOIN ENCNTR_ALIAS fin ON
fin.encntr_id = e.encntr_id
         AND
fin.encntr_alias_type_cd = 1077 ;FIN
         AND
fin.end_effective_dt_tm > SYSDATE
         AND fin.active_ind = 1)
 ,TIME_ZONE_R tz
 PLAN e WHERE e.person_id =
ids->person_id
 AND e.end_effective_dt_tm > SYSDATE
 AND e.active_ind = 1
 JOIN tz WHERE tz.parent_entity_id =
e.loc_facility_cd
         AND
tz.parent_entity_name = "LOCATION"
 JOIN fin
 JOIN hist
 JOIN epr_attend
 JOIN attend
 ORDER BY collapsed_reg_dt_tm DESC
 HEAD REPORT
i=0
row+1 "<html>"
row+1 "<head>"
row+1 "<meta content='CCLLINK' name='discern'>"
row+1        "<title>Past
Encounters (interactive)</title>"
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
row+1 ^<table border='1'>^
row+1 ^<tr>^
^<th>&nbsp;</th>^
         ^<th>FIN</th>^
         ^<th>Encounter
Type</th>^
^<th>Medical Service</th>^
^<th>Start Location</th>^
^<th>End Location</th>^
         ^<th>Attending
Provider</th>^
         ^<th>Registration</th>^
         ^<th>Discharge</th>^
^</tr>^
DETAIL
i += 1
 collapsed_reg =
IF(e.reg_dt_tm IS NULL) create_dt_tm
ELSE reg_dt_tm
ENDIF
collapsed_disch =
IF(e.disch_dt_tm IS NULL) complete_dt_tm
ELSE disch_dt_tm
ENDIF
lab = eda("encntr", e.encntr_id, "Lab Results",
"Lab")
mbo = eda("encntr", e.encntr_id, "Microbiology
Results", "Micro")
path = eda("encntr", e.encntr_id, "Pathology
Results", "Path")
row+1 ^<tr>^ ;first row with result information
row+1 call print(td(CNVTSTRING(i)))
row+1 ^<td><b>^, fin, ^</b></td>^
row+1 call print(td(encntr_type))
row+1 call print(td(med_service))
row+1 call print(td(start_location))
row+1 call print(td(end_location))
row+1 call print(td(attending_provider))
row+1 call print(td(collapsed_reg))
row+1 call
print(td(collapsed_disch))
^</tr>^
row+1 ^<tr>^
row+1 call print(td(" "))
row+1 call print(td(eda("encntr", e.encntr_id,
"Charges", "<i>Charges")))
row+1 call print(td(eda("encntr", e.encntr_id,
"Diagnoses", "<i>Diagnoses</i>")))
row+1 call print(td(eda("encntr", e.encntr_id, "Clinical
Events (summary)", "<i>Events")))
row+1 call print(td(eda("encntr", e.encntr_id, "Health
Plans", "<i>Insurance")))
row+1 call print(td(eda("encntr", e.encntr_id,
"Documentation (interactive)", "<i>Notes")))
row+1 ^<td><i>Results: ^, lab, ^ | ^, mbo, ^ | ^, path,
^</i></td>^
row+1 call print(td(eda("encntr", e.encntr_id, "Orders
(all)", "<i>Orders")))
row+1 call print(td(eda("encntr", e.encntr_id,
"Procedures", "<i>Procedures")))
^</tr>^
row+1 ^<tr style="border: none; height: 12px; background:
transparent;">^
^<td colspan=9 style="border-left: none; border-right:
none;"></td>^
^</tr>^
FOOT REPORT
row+1 "</table>"
row+1 "</body>"
row+1
"</html>"
ELSEIF($cat =
"patient" AND $pat_rpt = "Pathology Results")
accession_nbr =
IF(ca.accession_id != 0) UAR_FMT_ACCESSION(ca.accession,
size(ca.accession, 1))
ELSE UAR_FMT_ACCESSION(pc.accession_nbr, size(pc.accession_nbr,1))
ENDIF
,study = UAR_GET_CODE_DISPLAY(ce.event_cd)
,study_date = DATETIMEZONEFORMAT(ce.event_end_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY;;d")
,specimen =
IF(cs.case_specimen_id != 0)
CONCAT(TRIM(UAR_GET_CODE_DISPLAY(cs.specimen_cd),3), " (",
TRIM(cs.specimen_description, 3), ")")
ELSE
UAR_GET_CODE_DESCRIPTION(c.specimen_type_cd) ;replaced CE-based field
ENDIF
,ordering_provider =
IF(pc.case_id != 0) phys.name_full_formatted
ELSE op.name_full_formatted
ENDIF
,order_diagnosis = n.source_string
,facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
,fin = fin.alias
,case_year =
IF(pc.case_id != 0) CNVTSTRING(pc.case_year)
ELSE SUBSTRING(6,4, ca.accession)
ENDIF
,case_number =
IF(pc.case_id != 0) pc.case_number
ELSE CNVTINT(SUBSTRING(13,6,ca.accession))
ENDIF
,pathologist =
IF(pc.case_id != 0) path.name_full_formatted
ELSEIF(pc.case_id = 0 AND ce.verified_prsnl_id = 4291727) "See
report"
ELSE vp.name_full_formatted
ENDIF
,specimen_collected_dt_tm =
IF(cs.case_specimen_id != 0)
IF(cs.collect_dt_tm > 0)
DATETIMEZONEFORMAT(cs.collect_dt_tm, DATETIMEZONEBYNAME(tz.time_zone),
"MM/DD/YYYY HH:MM (ZZZ);;q")
ELSE
DATETIMEZONEFORMAT(pc.case_collect_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM (ZZZ);;q")
ENDIF
ELSE
DATETIMEZONEFORMAT(c.drawn_dt_tm, DATETIMEZONEBYNAME(tz.time_zone),
"MM/DD/YYYY HH:MM (ZZZ);;q")
ENDIF
,specimen_received_dt_tm =
IF(cs.case_specimen_id != 0)
IF(cs.received_dt_tm > 0)
DATETIMEZONEFORMAT(cs.received_dt_tm, DATETIMEZONEBYNAME(tz.time_zone),
"MM/DD/YYYY HH:MM (ZZZ);;q")
ELSE
DATETIMEZONEFORMAT(pc.accessioned_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM (ZZZ);;q")
ENDIF
ELSE
DATETIMEZONEFORMAT(c.received_dt_tm, DATETIMEZONEBYNAME(tz.time_zone),
"MM/DD/YYYY HH:MM (ZZZ);;q")
ENDIF
,report_complete_dt_tm =
IF(pc.case_id != 0)
DATETIMEZONEFORMAT(pc.main_report_cmplete_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM (ZZZ);;q")
ELSE ""
;This is past the specimen received date
;DATETIMEZONEFORMAT(ce.verified_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM (ZZZ);;q")
ENDIF
;identifiers
;        ,ce.person_id
;        ,ce.encntr_id
;        ,ce.event_id
;        ,ce.order_id
;        ,pc.case_id
FROM CLINICAL_EVENT ce
,(LEFT JOIN CASE_REPORT cr ON cr.event_id = ce.event_id)
,(LEFT JOIN PATHOLOGY_CASE pc ON pc.case_id = cr.case_id)
,(LEFT JOIN CASE_SPECIMEN cs ON cs.case_id = pc.case_id)
,(LEFT JOIN PRSNL path ON path.person_id =
pc.responsible_pathologist_id
AND path.person_id > 2)
,(LEFT JOIN PRSNL phys ON phys.person_id = pc.requesting_physician_id
AND phys.person_id > 2)
,(LEFT JOIN ORDER_ACTION oa ON oa.order_id = ce.order_id
AND oa.action_type_cd = 2534) ;order
,(LEFT JOIN PRSNL op ON op.person_id = oa.order_provider_id)
,(LEFT JOIN PRSNL vp ON vp.person_id = ce.verified_prsnl_id)
,(LEFT JOIN ORDER_CONTAINER_R ocr ON ocr.order_id = ce.order_id)
,(LEFT JOIN CONTAINER c ON c.container_id = ocr.container_id)
,(LEFT JOIN CONTAINER_ACCESSION ca ON ca.container_id =
c.container_id)
,(LEFT JOIN ENCOUNTER e ON e.encntr_id = ce.encntr_id)
,(LEFT JOIN TIME_ZONE_R tz ON tz.parent_entity_id = e.loc_facility_cd
AND tz.parent_entity_name = "LOCATION")
,(LEFT JOIN ENCNTR_ALIAS fin ON fin.encntr_id = e.encntr_id
AND fin.encntr_alias_type_cd = 1077
AND fin.end_effective_dt_tm > SYSDATE
AND fin.active_ind = 1)
,(LEFT JOIN NOMEN_ENTITY_RELTN ner ON ner.parent_entity_id =
ce.order_id
AND ner.parent_entity_name = "ORDERS"
AND ner.child_entity_name = "DIAGNOSIS"
AND ner.priority = 1)
,(LEFT JOIN NOMENCLATURE n ON n.nomenclature_id = ner.nomenclature_id)
PLAN ce WHERE ce.person_id = ids->person_id
AND ce.event_cd IN (
SELECT ex.event_cd
FROM V500_EVENT_SET_EXPLODE ex
WHERE ex.event_set_cd IN (4003743, 105911751, 24316470357)) ;Pathology
Reports, AP Specimens, Anatomic Pathology
AND ce.event_class_cd IN (226, 231) ;GRP, mdoc
AND ce.valid_until_dt_tm > SYSDATE+1
JOIN cr
JOIN pc
JOIN cs
JOIN path
JOIN phys
JOIN oa
JOIN op
JOIN vp
JOIN ocr
JOIN c
JOIN ca
JOIN e
JOIN tz
JOIN fin
JOIN ner
JOIN n
ORDER BY ce.event_end_dt_tm DESC
 HEAD REPORT
i = 0
;metadata
row+1 ^<html><head><meta content='CCLLINK'
name='discern'>^
row+1 ^<title>Microbiology Results (interactive)</title>^
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
;table & header
row+1 ^<table border='1'>^
row+1 ^<tr>^
^<th>&nbsp;</th>^
         ^<th>Accession</th>^
         ^<th>Study</th>^
         ^<th>Study
Date</th>^
         ^<th>Specimen</th>^
         ^<th>Ordering
Provider</th>^
         ^<th>Order
Diagnosis</th>^
         ^<th>Case
Year</th>^
         ^<th>Case
Number</th>^
         ^<th>Facility</th>^
         ^<th>Encounter
Type</th>^
         ^<th>FIN</th>^
;                
        ^<th>Pathologist</th>^
;                
        ^<th>Specimen Collected
Date/Time</th>^
;                
        ^<th>Specimen Received
Date/Time</th>^
;                
        ^<th>Report Complete
Date/Time</th>^
 ^</tr>^
DETAIL
i += 1
blob_prompt = BUILD(|^MINE^|, |,|,
CNVTSTRING(ce.event_id), |,|,
2, |,|, ;events are two layers deep
4) ;path headers
;first row with result information
row+1 ^<tr>^
call print(td(CNVTSTRING(i)))
call print(td(accession_nbr))
call print(td(reportlink("dev_rpt_blob_out:group1",
blob_prompt, 0, study)))
call print(td(study_date))
call print(td(specimen))
call print(td(ordering_provider))
call print(td(order_diagnosis))
call print(td(case_year))
call print(td(case_number))
call print(td(facility))
call print(td(encntr_type))
call print(td(fin))
;                call
print(td(pathologist))
;                call
print(td(specimen_collected_dt_tm))
;                call
print(td(specimen_received_dt_tm))
;                call
print(td(report_complete_dt_tm))
^</tr>^
FOOT REPORT
row+1 ^</table>^
row+1 ^</body>^
row+1 ^</html>^
ELSEIF($cat =
"patient" AND $pat_rpt = "Person Relationships")
relation_type = UAR_GET_CODE_DISPLAY(ppr.person_reltn_type_cd)
,related_person = rp.name_full_formatted
,relation = UAR_GET_CODE_DISPLAY(ppr.person_reltn_cd)
;,ppr.priority_seq
,start_dt_tm = ppr.beg_effective_dt_tm "MM/DD/YYYY;;d"
,stop_dt_tm = ppr.end_effective_dt_tm "MM/DD/YYYY;;d"
,current_ind = IF(ppr.end_effective_dt_tm > SYSDATE) 1 ELSE 0 ENDIF
,ppr.related_person_id
,ppr.person_person_reltn_id
FROM PERSON p
,PERSON_PERSON_RELTN ppr
,PERSON rp
PLAN p WHERE p.person_id = ids->person_id
JOIN ppr WHERE ppr.person_id = p.person_id
AND ppr.active_ind = 1
JOIN rp WHERE rp.person_id = ppr.related_person_id
ORDER BY relation_type, ppr.priority_seq, ppr.beg_effective_dt_tm
ELSEIF($cat =
"patient" AND $pat_rpt = "Personnel Relationships")
 personnel = p.name_full_formatted
 ,relationship =
UAR_GET_CODE_DISPLAY(ppr.person_prsnl_r_cd)
 ,status = EVALUATE2(
 IF(ppr.end_effective_dt_tm >=
SYSDATE) "active"
 ELSE "not active"
 ENDIF)
 ;,position =
UAR_GET_CODE_DISPLAY(p.position_cd)
 ,start_dt_tm = ppr.beg_effective_dt_tm
"MM/DD/YYYY;;d"
 ,stop_dt_tm = ppr.end_effective_dt_tm
"MM/DD/YYYY;;d"
 ,prsnl_id = p.person_id
 ,ppr.person_prsnl_reltn_id
 FROM PERSON_PRSNL_RELTN ppr
 ,PRSNL p
 PLAN ppr WHERE ppr.person_id =
ids->person_id
 AND ppr.active_ind = 1
 JOIN p WHERE p.person_id =
ppr.prsnl_person_id
 ORDER BY status, relationship,
ppr.end_effective_dt_tm DESC, ppr.beg_effective_dt_tm DESC
ELSEIF($cat =
"patient" AND $pat_rpt = "Problem List")
 DISTINCT
 problem = pr.annotated_display
 ,status =
UAR_GET_CODE_DISPLAY(pr.life_cycle_status_cd)
 ,onset_dt_tm =
DATETIMEZONEFORMAT(pr.onset_dt_tm, pr.onset_tz, "MM/DD/YYYY;;d")
 ,added_dt_tm =
DATETIMEZONEFORMAT(pr.beg_effective_dt_tm, pr.beg_effective_tz,
"MM/DD/YYYY;;d")
 ,last_updated_by =
         IF(p.person_id != 0)
                 IF(p.position_cd
!= 0)
                         BUILD(p.name_full_formatted,
" (", TRIM(UAR_GET_CODE_DISPLAY(p.position_cd)), ")")
                 ELSE
p.name_full_formatted
                 ENDIF
         ELSE ""
         ENDIF
 ,confirmation_status =
UAR_GET_CODE_DISPLAY(pr.confirmation_status_cd)
 ,problem_source =
UAR_GET_CODE_DISPLAY(pr.contributor_system_cd)
,originating_fin = fin.alias
,encntr_location = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
,encntr_med_service = UAR_GET_CODE_DISPLAY(e.med_service_cd)
 ,snomed_ct_code =
PIECE(snomed.concept_cki,"!",2,"parse error")
 ,snomed_ct_description =
snomed.source_string
 ,icd10_code =
PIECE(map.target_concept_cki,"!",2,"mapping not available")
 ,icd10_description = icd.source_string
;identifiers
 ,pr.problem_id
 ,pr.originating_encntr_id
 ,snomed_nomen_id = snomed.nomenclature_id
 ,icd_nomen_id = icd.nomenclature_id
 FROM PROBLEM pr
         ,(LEFT JOIN ENCOUNTER e
ON e.encntr_id = pr.originating_encntr_id)
         ,(LEFT JOIN ENCNTR_ALIAS
fin ON fin.encntr_id = e.encntr_id
                 AND
fin.encntr_alias_type_cd = 1077 ;fin
                 AND
fin.end_effective_dt_tm > SYSDATE
                 AND
fin.active_ind = 1)
         ,(LEFT JOIN PRSNL p ON
p.person_id = pr.updt_id)
 ,NOMENCLATURE snomed
 ,(LEFT JOIN CMT_CROSS_MAP map ON (
 map.concept_cki =
snomed.concept_cki
 AND map.cross_map_flag = 2 ;SNOMED
to ICD
 AND map.beg_effective_dt_tm <
SYSDATE
 AND map.end_effective_dt_tm >
SYSDATE
 AND map.active_ind = 1))
 ,(LEFT JOIN NOMENCLATURE icd ON
icd.concept_cki = map.target_concept_cki)
 PLAN pr WHERE pr.person_id =
ids->person_id
         AND
pr.life_cycle_status_cd IN (3301, 3304) ;active, resolved
         AND pr.active_ind = 1
 JOIN snomed WHERE snomed.nomenclature_id =
pr.nomenclature_id
 JOIN map
 JOIN icd
 JOIN e
 JOIN fin
 JOIN p
 ORDER BY problem, pr.beg_effective_dt_tm
ELSEIF($cat =
"patient" AND $pat_rpt = "Procedures")
 procedure = EVALUATE2(
 IF(TEXTLEN(TRIM(p.procedure_note)) = 0)
n.source_string
 ELSE p.procedure_note
 ENDIF)
 ,procedure_dt_tm = p.proc_dt_tm
 ,added_dt_tm = p.beg_effective_dt_tm
,proc_type = EVALUATE(p.proc_type_flag,
0,"unknown",
1,"associated with encounter",
2,"historical/narrative",
"<unmapped value>")
 ,code = n.source_identifier
 ,vocabulary =
UAR_GET_CODE_DISPLAY(n.source_vocabulary_cd)
 ,category =
UAR_GET_CODE_DISPLAY(n.vocab_axis_cd)
 ,encntr_type = IF(p.proc_type_flag = 1)
UAR_GET_CODE_DISPLAY(e.encntr_type_cd) ENDIF
 ,encntr_fin = IF(p.proc_type_flag = 1)
fin.alias ENDIF
 ,encntr_location = IF(p.proc_type_flag =
1)        UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
ENDIF
 ,encntr_med_service = IF(p.proc_type_flag =
1) UAR_GET_CODE_DISPLAY(e.med_service_cd) ENDIF
 ,contrib_system =
UAR_GET_CODE_DISPLAY(p.contributor_system_cd)
 ,p.encntr_id
 ,p.procedure_id
 FROM ENCOUNTER e
         ,(LEFT JOIN ENCNTR_ALIAS
fin ON fin.encntr_id = e.encntr_id
                 AND
fin.encntr_alias_type_cd = 1077 ;fin
                 AND
fin.end_effective_dt_tm > SYSDATE
                 AND
fin.active_ind = 1)
 ,PROCEDURE p
 ,NOMENCLATURE n
 PLAN e WHERE e.person_id =
ids->person_id
 AND e.end_effective_dt_tm > SYSDATE
 AND e.active_ind = 1
 JOIN p WHERE p.encntr_id = e.encntr_id
 AND p.end_effective_dt_tm >= SYSDATE
 AND p.active_ind = 1
 JOIN n WHERE n.nomenclature_id =
p.nomenclature_id
         AND n.vocab_axis_cd !=
674338 ;E&M codes
 JOIN fin
 ORDER BY procedure, p.proc_dt_tm,
p.beg_effective_dt_tm
ELSEIF($cat =
"patient" AND $pat_rpt = "Referrals")
fin = fin.alias
,referred_to = UAR_GET_CODE_DISPLAY(r.medical_service_cd)
,provisional_diagnosis = n.source_string
,diagnosis_code = n.source_identifier ;"codified reason"
,reason_for_referral = SUBSTRING(1,255,reason.long_text)
,order_comment = SUBSTRING(1,2500,replace_CRLF(com.long_text))
,instructions_to_staff = SUBSTRING(1,255,instruct.long_text)
,type = UAR_GET_CODE_DISPLAY(r.service_type_requested_cd)
,priority = UAR_GET_CODE_DISPLAY(r.referral_priority_cd)
,status = UAR_GET_CODE_DISPLAY(r.referral_status_cd)
,substatus = UAR_GET_CODE_DISPLAY(r.referral_substatus_cd)
,deferred = EVALUATE(r.refer_to_practice_site_id,
18043, "yes",
18049, "yes",
18053, "yes",
18057, "yes",
"no")
;no time zone info for referrals, assume same time zone as encounter
,created_dt_tm =
DATETIMEZONEFORMAT(r.create_dt_tm, DATETIMEZONEBYNAME(tz.time_zone),
"MM/DD/YYYY HH:MM;;q")
,written_dt_tm =
DATETIMEZONEFORMAT(r.referral_written_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
,received_dt_tm =
DATETIMEZONEFORMAT(r.referral_received_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
,requested_start_dt_tm =
DATETIMEZONEFORMAT(r.requested_start_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
,service_by_dt_tm =
DATETIMEZONEFORMAT(r.service_by_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
,last_action = UAR_GET_CODE_DISPLAY(r.last_performed_action_cd)
,last_action_dt_tm =
DATETIMEZONEFORMAT(r.last_performed_action_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
,age_at_last_action = CNVTAGE(r.create_dt_tm,
r.last_performed_action_dt_tm, 0)
,current_age = CNVTAGE(r.create_dt_tm, SYSDATE, 0)
,category = UAR_GET_CODE_DISPLAY(r.referral_category_cd)
,refer_from_location = UAR_GET_CODE_DISPLAY(r.refer_from_loc_cd)
,refer_from_provider = from_prov.name_full_formatted
,refer_to_practice_site = ps.practice_site_display
,refer_to_provider = to_prov.name_full_formatted
;,r.refer_to_organization_id ;this vs practice site
,outbound_assigned_prsnl = out_prsnl.name_full_formatted
,inbound_assigned_prsnl = in_prsnl.name_full_formatted
,last_modified_by = updt_prsnl.name_full_formatted
,last_modified = r.updt_dt_tm "MM/DD/YYYY HH:MM;;q"
;appointment information
,sched_appt_dt_tm = DATETIMEZONEFORMAT(sa.beg_dt_tm,
DATETIMEZONEBYNAME(sa_tz.time_zone), "MM/DD/YYYY HH:MM;;q")
,sched_appt_type = UAR_GET_CODE_DISPLAY(se.appt_type_cd)
,sched_resource = UAR_GET_CODE_DISPLAY(sr.resource_cd)
,r.referral_id
FROM REFERRAL r
,(LEFT JOIN LONG_TEXT reason ON reason.long_text_id =
r.referral_reason_text_id
AND reason.active_ind = 1)
,(LEFT JOIN LONG_TEXT instruct ON instruct.long_text_id =
r.instructions_to_staff_text_id
AND instruct.active_ind = 1)
,(LEFT JOIN NOMEN_ENTITY_RELTN ner ON ner.parent_entity_id = r.order_id
AND ner.parent_entity_name = "ORDERS"
AND ner.child_entity_name = "DIAGNOSIS"
AND ner.priority = 1)
,(LEFT JOIN NOMENCLATURE n ON n.nomenclature_id = ner.nomenclature_id)
,(LEFT JOIN REFERRAL_ENTITY_RELTN rer ON rer.referral_id =
r.referral_id
AND rer.parent_entity_name = "SCH_EVENT"
AND rer.active_ind = 1)
,(LEFT JOIN SCH_EVENT se ON se.sch_event_id = rer.parent_entity_id
AND se.active_ind = 1)
; using the "not a patient" approach will lead to multiple
rows for surgical appointments (multiple resources)
,(LEFT JOIN SCH_APPT sa ON sa.sch_event_id = se.sch_event_id
AND sa.sch_role_cd != 4572 ;patient
AND sa.end_effective_dt_tm > SYSDATE
AND sa.version_dt_tm > SYSDATE
AND sa.active_ind = 1)
,(LEFT JOIN SCH_RESOURCE sr ON sr.resource_cd = sa.resource_cd)
,(LEFT JOIN ENCOUNTER sa_e ON sa_e.encntr_id = sa.encntr_id)
,(LEFT JOIN TIME_ZONE_R sa_tz ON sa_tz.parent_entity_id =
sa_e.loc_facility_cd
AND sa_tz.parent_entity_name = "LOCATION")
,(LEFT JOIN ORDER_COMMENT oc ON oc.order_id = r.order_id)
 ,(LEFT JOIN LONG_TEXT com ON
com.long_text_id = oc.long_text_id)
,ENCOUNTER e
         ,(LEFT JOIN ENCNTR_ALIAS
fin ON fin.encntr_id = e.encntr_id
                 AND
fin.encntr_alias_type_cd = 1077 ;fin
                 AND
fin.end_effective_dt_tm > SYSDATE
                 AND
fin.active_ind =
1)
,TIME_ZONE_R tz
,PERSON p
,PRSNL updt_prsnl
,PRSNL out_prsnl
,PRSNL in_prsnl
,PRSNL from_prov
,PRSNL to_prov
,PRACTICE_SITE ps
PLAN r WHERE r.person_id = ids->person_id
AND r.active_ind = 1
JOIN p WHERE p.person_id = r.person_id
JOIN e WHERE e.encntr_id = r.outbound_encntr_id
JOIN tz WHERE tz.parent_entity_id = e.loc_facility_cd
AND tz.parent_entity_name =
"LOCATION"
JOIN updt_prsnl WHERE updt_prsnl.person_id = r.updt_id
JOIN out_prsnl WHERE out_prsnl.person_id = r.outbound_assigned_prsnl_id
JOIN in_prsnl WHERE in_prsnl.person_id = r.inbound_assigned_prsnl_id
JOIN from_prov WHERE from_prov.person_id = r.refer_from_provider_id
JOIN to_prov WHERE to_prov.person_id = r.refer_to_provider_id
JOIN ps WHERE ps.practice_site_id = r.refer_to_practice_site_id
JOIN fin
JOIN reason
JOIN instruct
JOIN ner
JOIN n
JOIN rer
JOIN se
JOIN sa
JOIN sr
JOIN sa_e
JOIN sa_tz
JOIN oc
JOIN com
ORDER BY r.create_dt_tm
ELSEIF($cat =
"patient" AND $pat_rpt = "Social History")
 DISTINCT
question = UAR_GET_CODE_DISPLAY(resp1.task_assay_cd)
 ,response = EVALUATE2(
 IF(resp1.response_type =
"ALPHA") n.source_string
 ELSE resp1.response_val
 ENDIF)
 ,units =
UAR_GET_CODE_DISPLAY(resp1.response_unit_cd)
 ,shx.unable_to_obtain_ind
 ,performed_dt_tm =
DATETIMEZONEFORMAT(shx.perform_dt_tm, created.action_tz, "MM/DD/YYYY
HH:MM;;q")
 ,created_dt_tm =
DATETIMEZONEFORMAT(created.action_dt_tm, created.action_tz, "MM/DD/YYYY
HH:MM;;q")
 ,modified_dt_tm =
DATETIMEZONEFORMAT(modified.action_dt_tm, modified.action_tz, "MM/DD/YYYY
HH:MM;;q")
 ,reviewed_dt_tm =
DATETIMEZONEFORMAT(reviewed.action_dt_tm, reviewed.action_tz, "MM/DD/YYYY
HH:MM;;q")
 ,created_by =
         IF(creator.person_id !=
0)
                 IF(creator.position_cd
!= 0)
                         BUILD(TRIM(creator.name_full_formatted),
" (", TRIM(UAR_GET_CODE_DISPLAY(creator.position_cd)), ")")
                 ELSE
creator.name_full_formatted
                 ENDIF
         ELSE ""
         ENDIF
 ,modified_by =
         IF(modifier.person_id !=
0)
                 IF(modifier.position_cd
!= 0)
                         BUILD(TRIM(modifier.name_full_formatted),
" (", TRIM(UAR_GET_CODE_DISPLAY(modifier.position_cd)),
")")
                 ELSE
modifier.name_full_formatted
                 ENDIF
         ELSE ""
         ENDIF
 ,reviewed_by =
         IF(reviewer.person_id !=
0)
                 IF(reviewer.position_cd
!= 0)
                         BUILD(TRIM(reviewer.name_full_formatted),
" (", TRIM(UAR_GET_CODE_DISPLAY(reviewer.position_cd)),
")")
                 ELSE
reviewer.name_full_formatted
                 ENDIF
         ELSE ""
         ENDIF
 ,shx.shx_activity_id
 FROM SHX_ACTIVITY shx
 ,(LEFT JOIN SHX_ACTION created
 ON shx.shx_activity_id =
created.shx_activity_id
 AND created.action_type_mean =
"CREATE"
 AND created.active_ind = 1)
 ,(LEFT JOIN PRSNL creator ON
created.prsnl_id = creator.person_id)
 ,(LEFT JOIN SHX_ACTION modified
 ON shx.shx_activity_id =
modified.shx_activity_id
 AND modified.action_type_mean =
"MODIFY"
 AND modified.active_ind = 1)
 ,(LEFT JOIN PRSNL modifier ON
modified.prsnl_id = modifier.person_id)
 ,(LEFT JOIN SHX_ACTION reviewed
 ON shx.shx_activity_id =
reviewed.shx_activity_id
 AND reviewed.action_type_mean =
"REVIEW"
 AND reviewed.active_ind = 1)
 ,(LEFT JOIN PRSNL reviewer ON
reviewed.prsnl_id = reviewer.person_id)
 ,SHX_RESPONSE resp1
 ,(LEFT JOIN SHX_ALPHA_RESPONSE resp2
 ON resp1.shx_response_id =
resp2.shx_response_id
 AND resp2.active_ind = 1)
 ,(LEFT JOIN NOMENCLATURE n ON
resp2.nomenclature_id = n.nomenclature_id)
 PLAN shx WHERE shx.person_id =
ids->person_id
 AND shx.active_ind = 1
 JOIN resp1 WHERE shx.shx_activity_id =
resp1.shx_activity_id
 AND resp1.active_ind = 1
 JOIN created
 JOIN reviewed
 JOIN modified
 JOIN creator
 JOIN modifier
 JOIN reviewer
 JOIN resp2
 JOIN n
 ORDER BY question, shx.perform_dt_tm
ELSEIF($cat =
"patient" AND $pat_rpt = "Special Duty Status (history)")
;ideally this generates one row per encounter, but it seems common that
people are
;documenting on non-associated encounters. Thus - workflow issue, not
query issue
 DISTINCT
 ;p.name_full_formatted
 ;,mil_status =
UAR_GET_CODE_DISPLAY(p.vet_military_status_cd)
 fin = fin.alias
 ,registration = FORMAT(e.reg_dt_tm,
"MM/DD/YYYY;;d")
 ,location =
UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
 ,encntr_type =
UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
 ,duty_status_documented = EVALUATE2(
 IF(ce_old.event_id != 0
 OR arming.event_id != 0
 OR aviation.event_id != 0
 OR dive.event_id != 0
 OR ionizing.event_id != 0
 OR jump.event_id != 0
 OR landing.event_id != 0
 OR nuclear.event_id != 0
 OR prap.event_id != 0
 OR president.event_id != 0
 OR spec_ops.event_id != 0
 OR submarine.event_id != 0)
"yes"
 ELSE "no"
 ENDIF)
 ,arming = IF(arming.event_id != 0)
 BUILD(arming.event_tag, " (",
FORMAT(arming.performed_dt_tm, "MM/DD/YYYY;;d"), ")")
 ENDIF
 ,aviation = IF(aviation.event_id != 0)
 BUILD(aviation.event_tag, "
(", FORMAT(aviation.performed_dt_tm, "MM/DD/YYYY;;d"),
")")
 ENDIF
 ,dive = IF(dive.event_id != 0)
 BUILD(dive.event_tag, " (",
FORMAT(dive.performed_dt_tm, "MM/DD/YYYY;;d"), ")")
 ENDIF
 ,ionizing = IF(ionizing.event_id != 0)
 BUILD(ionizing.event_tag, "
(", FORMAT(ionizing.performed_dt_tm, "MM/DD/YYYY;;d"),
")")
 ENDIF
 ,jump = IF(jump.event_id != 0)
 BUILD(jump.event_tag, " (",
FORMAT(jump.performed_dt_tm, "MM/DD/YYYY;;d"), ")")
 ENDIF
 ,landing = IF(landing.event_id != 0)
 BUILD(landing.event_tag, "
(", FORMAT(landing.performed_dt_tm, "MM/DD/YYYY;;d"),
")")
 ENDIF
 ,nuclear = IF(nuclear.event_id != 0)
 BUILD(nuclear.event_tag, "
(", FORMAT(nuclear.performed_dt_tm, "MM/DD/YYYY;;d"),
")")
 ENDIF
 ,prap = IF(prap.event_id != 0)
 BUILD(prap.event_tag, " (",
FORMAT(prap.performed_dt_tm, "MM/DD/YYYY;;d"), ")")
 ENDIF
 ,presidential = IF(president.event_id != 0)
 BUILD(president.event_tag, "
(", FORMAT(president.performed_dt_tm, "MM/DD/YYYY;;d"),
")")
 ENDIF
 ,spec_ops = IF(spec_ops.event_id != 0)
 BUILD(spec_ops.event_tag, "
(", FORMAT(spec_ops.performed_dt_tm, "MM/DD/YYYY;;d"),
")")
 ENDIF
 ,submarine = IF(submarine.event_id != 0)
 BUILD(submarine.event_tag, "
(", FORMAT(submarine.performed_dt_tm, "MM/DD/YYYY;;d"),
")")
 ENDIF
 ,old_method = IF(ce_old.event_id != 0)
 BUILD(ce_old.event_tag, " (",
FORMAT(ce_old.performed_dt_tm, "MM/DD/YYYY;;d"), ")")
 ENDIF
 FROM PERSON p
         ,ENCOUNTER e
 ,(LEFT JOIN CLINICAL_EVENT ce_old ON
e.encntr_id = ce_old.encntr_id
         AND ce_old.event_cd =
109969727 ;deprecated event for special duty status
         AND
ce_old.result_status_cd NOT IN (28,29,30,31)
         AND
ce_old.valid_until_dt_tm > SYSDATE)
 ,(LEFT JOIN CLINICAL_EVENT arming ON
e.encntr_id = arming.encntr_id
         AND arming.event_cd =
971723825
         AND
arming.result_status_cd NOT IN (28,29,30,31)
         AND
arming.valid_until_dt_tm > SYSDATE)
 ,(LEFT JOIN CLINICAL_EVENT aviation ON
e.encntr_id = aviation.encntr_id
         AND aviation.event_cd =
971729945
         AND
aviation.result_status_cd NOT IN (28,29,30,31)
         AND
aviation.valid_until_dt_tm > SYSDATE)
 ,(LEFT JOIN CLINICAL_EVENT dive ON
e.encntr_id = dive.encntr_id
         AND dive.event_cd =
971729959
         AND
dive.result_status_cd NOT IN (28,29,30,31)
         AND
dive.valid_until_dt_tm > SYSDATE)
 ,(LEFT JOIN CLINICAL_EVENT ionizing ON
e.encntr_id = ionizing.encntr_id
         AND ionizing.event_cd =
971729973
         AND
ionizing.result_status_cd NOT IN (28,29,30,31)
         AND
ionizing.valid_until_dt_tm > SYSDATE)
 ,(LEFT JOIN CLINICAL_EVENT jump ON
e.encntr_id = jump.encntr_id
         AND jump.event_cd =
971731911
         AND
jump.result_status_cd NOT IN (28,29,30,31)
         AND
jump.valid_until_dt_tm > SYSDATE)
 ,(LEFT JOIN CLINICAL_EVENT landing ON
e.encntr_id = landing.encntr_id
         AND landing.event_cd =
971731943
         AND
landing.result_status_cd NOT IN (28,29,30,31)
         AND
landing.valid_until_dt_tm > SYSDATE)
 ,(LEFT JOIN CLINICAL_EVENT nuclear ON
e.encntr_id = nuclear.encntr_id
         AND nuclear.event_cd =
971727747
         AND
nuclear.result_status_cd NOT IN (28,29,30,31)
         AND
nuclear.valid_until_dt_tm > SYSDATE)
 ,(LEFT JOIN CLINICAL_EVENT prap ON
e.encntr_id = prap.encntr_id
         AND prap.event_cd =
971731993
         AND
prap.result_status_cd NOT IN (28,29,30,31)
         AND
prap.valid_until_dt_tm > SYSDATE)
 ,(LEFT JOIN CLINICAL_EVENT president ON
e.encntr_id = president.encntr_id
         AND president.event_cd =
971729993
         AND
president.result_status_cd NOT IN (28,29,30,31)
         AND
president.valid_until_dt_tm > SYSDATE)
 ,(LEFT JOIN CLINICAL_EVENT spec_ops ON
e.encntr_id = spec_ops.encntr_id
         AND spec_ops.event_cd =
971732045
         AND
spec_ops.result_status_cd NOT IN (28,29,30,31)
         AND
spec_ops.valid_until_dt_tm > SYSDATE)
 ,(LEFT JOIN CLINICAL_EVENT submarine ON
e.encntr_id = submarine.encntr_id
         AND submarine.event_cd =
971727761
         AND
submarine.result_status_cd NOT IN (28,29,30,31)
         AND
submarine.valid_until_dt_tm > SYSDATE)
 ,(LEFT JOIN ENCNTR_ALIAS fin ON
e.encntr_id = fin.encntr_id
         AND
fin.encntr_alias_type_cd = 1077 ;FIN
         AND
fin.end_effective_dt_tm > SYSDATE
         AND fin.active_ind = 1)
 PLAN p WHERE p.person_id =
ids->person_id
         JOIN e WHERE e.person_id
= p.person_id
 AND e.end_effective_dt_tm > SYSDATE
 AND e.active_ind = 1
 JOIN fin
 JOIN ce_old
 JOIN arming
 JOIN aviation
 JOIN dive
 JOIN ionizing
 JOIN jump
 JOIN landing
 JOIN nuclear
 JOIN prap
 JOIN president
 JOIN spec_ops
 JOIN submarine
 ORDER BY e.reg_dt_tm
 HEAD REPORT
i=0
row+1 "<html>"
row+1 "<head>"
row+1 "<meta content='CCLLINK' name='discern'>"
row+1        "<title>Special
Duty Status (history)</title>"
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
row+1 "<p><span>Duty status is also captured at the
person-level, but may not match encounter-level documentation. Check
</span>"
row+1 call print(call_eda("person", p.person_id, "User
Defined Fields", "User Defined Fields"))
row+1 ".<br>"
row+1 "The duty status date should match the encounter date.
"
row+1 "Discrepancies occur when the user documents on an old
encounter.</p>"
;table & header
row+1 "<table border='1'>"
row+1 "<tr>"
row+1        "<th>&nbsp;</th>"
row+1
        "<th>FIN</th>"
row+1        "<th>Location</th>"
row+1
        "<th>Registration
Date</th>"
row+1
        "<th>Encounter
Type</th>"
row+1        "<th>Documented</th>"
row+1
        "<th>PRAP</th>"
row+1
        "<th>Arming</th>"
row+1
        "<th>Aviation</th>"
row+1
        "<th>Dive</th>"
row+1
        "<th>Ionizing</th>"
row+1
        "<th>Jump</th>"
row+1
        "<th>Landing</th>"
row+1
        "<th>Nuclear</th>"
row+1
        "<th>Presidential</th>"
row+1
        "<th>SpecOps</th>"
row+1
        "<th>Submarine</th>"
row+1
        "<th>Old
Method</th>"
row+1 "</tr>"
DETAIL
i+=1
row+1 "<tr>"
row+1        call
print(td(CNVTSTRING(i)))
row+1         call
print(td(chartlink(e.person_id, e.encntr_id, fin.alias)))
row+1        call
print(td(location))
row+1        call
print(td(registration))
row+1         call
print(td(encntr_type))
row+1        call
print(td(duty_status_documented))
row+1        call
print(td(prap))
row+1        call
print(td(arming))
row+1        call
print(td(aviation))
row+1        call
print(td(dive))
row+1        call
print(td(ionizing))
row+1        call
print(td(jump))
row+1        call
print(td(landing))
row+1        call
print(td(nuclear))
row+1        call
print(td(presidential))
row+1        call
print(td(spec_ops))
row+1        call
print(td(submarine))
row+1        call
print(td(old_method))
row+1 "</tr>"
FOOT REPORT
row+1 "</table>"
row+1 "</body>"
row+1
"</html>"
ELSEIF($cat =
"patient" AND $pat_rpt = "Transfusion History")
 fin = fin.alias
 ,category =
UAR_GET_CODE_DISPLAY(prod.product_cat_cd)
,prod.product_nbr
,product_type = UAR_GET_CODE_DISPLAY(prod.product_cd)
 ,abo_rh =
CONCAT(TRIM(UAR_GET_CODE_DISPLAY(bp.cur_abo_cd)), " ",
TRIM(UAR_GET_CODE_DISPLAY(bp.cur_rh_cd)))
 ,ordered_dt_tm =
         DATETIMEZONEFORMAT(o_dispense.orig_order_dt_tm,
pe_transfuse.event_tz, "MM/DD/YYYY HH:MM;;q")
 ,dispensed_dt_tm =
DATETIMEZONEFORMAT(pe_dispense.event_dt_tm, pe_dispense.event_tz,
"MM/DD/YYYY HH:MM;;q")
 ,transfused_dt_tm =
DATETIMEZONEFORMAT(pe_transfuse.event_dt_tm, pe_transfuse.event_tz,
"MM/DD/YYYY HH:MM;;q")
 ,xf.transfused_vol
 ,units =
UAR_GET_CODE_DISPLAY(prod.cur_unit_meas_cd)
 ,order_detail =
SUBSTRING(1,255,replace_CRLF(o_dispense.clinical_display_line))
 ,event_type =
UAR_GET_CODE_DISPLAY(pe_transfuse.event_type_cd)
 ,inventory_loc =
UAR_GET_CODE_DISPLAY(prod.cur_inv_locn_cd)
 ,owner =
UAR_GET_CODE_DISPLAY(prod.cur_owner_area_cd)
 ,donation_type =
UAR_GET_CODE_DISPLAY(prod.donation_type_cd)
 ,order_to_dispense =
FORMAT(DATETIMEDIFF(pe_dispense.event_dt_tm, o_dispense.orig_order_dt_tm,
7),"####d.##h.##m")
 ,dispense_to_transfusion =
FORMAT(DATETIMEDIFF(pe_transfuse.event_dt_tm, pe_dispense.event_dt_tm,
7),"####d.##h.##m")
 ,order_to_transfusion =
FORMAT(DATETIMEDIFF(pe_transfuse.event_dt_tm, o_dispense.orig_order_dt_tm,
7),"####d.##h.##m")
 ;identifiers
 ,pe_transfuse.encntr_id
 ,pe_dispense.order_id
 ,xf.product_id
 ,xf.product_event_id
 FROM TRANSFUSION xf
 ,PRODUCT prod
 ,(LEFT JOIN BLOOD_PRODUCT bp ON
bp.product_id = prod.product_id)
 ,PRODUCT_EVENT pe_transfuse
 ,(LEFT JOIN PRODUCT_EVENT pe_dispense
ON pe_dispense.product_event_id = pe_transfuse.related_product_event_id
         AND
pe_dispense.event_type_cd = 1436) ;dispense
 ,(LEFT JOIN ORDERS o_dispense ON
o_dispense.order_id = pe_dispense.order_id
         AND
o_dispense.active_ind = 1)
 ,(LEFT JOIN ENCNTR_ALIAS fin ON
fin.encntr_id = pe_transfuse.encntr_id
         AND
fin.encntr_alias_type_cd = 1077 ;FIN
         AND
fin.end_effective_dt_tm > SYSDATE
         AND fin.active_ind = 1)
 PLAN xf WHERE xf.person_id =
ids->person_id
 AND xf.active_ind = 1
 JOIN prod WHERE xf.product_id =
prod.product_id
 JOIN pe_transfuse WHERE
pe_transfuse.product_event_id = xf.product_event_id
 JOIN bp
 JOIN pe_dispense
 JOIN o_dispense
 JOIN fin
 ORDER BY pe_transfuse.event_dt_tm
ELSEIF($cat =
"patient" AND $pat_rpt = "User Defined Fields")
 info_type =
UAR_GET_CODE_DISPLAY(pi.info_type_cd)
 ,info_subtype =
UAR_GET_CODE_DISPLAY(pi.info_sub_type_cd)
,value =
IF(pi.value_cd != 0) UAR_GET_CODE_DISPLAY(pi.value_cd)
ELSEIF(pi.long_text_id != 0) SUBSTRING(1,500,text.long_text)
ELSEIF(pi.value_numeric_ind != 0) CNVTSTRING(pi.value_numeric, 50,
2);50 chars, 2 decimals
ELSE FORMAT(pi.value_dt_tm, "MM/DD/YYYY HH:MM;;q")
ENDIF
,value_type =
IF(pi.value_cd != 0) "code_value"
ELSEIF(pi.long_text_id != 0) "long_text"
ELSEIF(pi.value_numeric_ind != 0) "numeric"
ELSE "date/time"
ENDIF
,last_updated =
IF(text.long_text_id != 0) FORMAT(text.updt_dt_tm, "MM/DD/YYYY
HH:MM;;q")
ELSE FORMAT(pi.updt_dt_tm, "MM/DD/YYYY HH:MM;;q")
ENDIF
 ,pi.beg_effective_dt_tm "MM/DD/YYYY
HH:MM;;q"
 ,pi.end_effective_dt_tm "MM/DD/YYYY
HH:MM;;q"
 ,pi.person_info_id
 FROM PERSON_INFO pi
 ,(LEFT JOIN LONG_TEXT text ON
text.long_text_id = pi.long_text_id
         AND text.active_ind = 1)
 PLAN pi WHERE pi.person_id =
ids->person_id
         AND pi.active_ind = 1
 JOIN text
 ORDER BY info_type, info_subtype
ENDIF
INTO $OUTDEV
; Default (no valid report selected)
error = "Invalid prompt selections"
,success_ind =
ids->success_ind
,input_category = ids->input_cat
,input_type = ids->input_type
,input = ids->input
,person_id = ids->person_id
,encntr_id = ids->encntr_id
,access_allowed_ind = ids->access_allowed
,encntr_tz = ids->tz
WITH
NOCOUNTER, SEPARATOR=" ", FORMAT, TIME=600, CHECK, EXPAND=2,
MAXCOL=1000
end
go
