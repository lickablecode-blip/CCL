/*
 * Source page  : Appointments by UIC
 * Source file  : output/appointments-by-uic.md
 * Anchor       : (top of page)
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 263
 *
 * Context (preceding paragraph):
 *   Exported: 11/25/25
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

/******************************************************************************
 REPORT NAME:
        Appointments by UIC
 PROGRAM:                1fed_rpt_appts_by_uic.prg
 DEV
PROGRAM:        dev_rpt_appt_stat_det_uic.prg
 DEVELOPER:        David Alt
(david.a.alt2.mil@health.mil)
 PUBLISHED:        11/25/25
 LOGICAL
PATH:        cust_script:
 NODE:                        <default>
 PURPOSE/DESCRIPTION:
Provide detail lists of appointments of the given appointment status,
organized by military unit. This data can be used to generate a no-show
report, look at late arrivals, or simply see appointment activity by
military unit.
 TARGET AUDIENCE:
          Executive leadership
(unit commanders)
          Practice Management
MOD        DATE                DEVELOPER        COMMENT
---        --/--/--        ---------        ----------------------------
001        05/10/23        David
Alt        File created
002        06/24/25        David
Alt        Added special duty status
003        11/20/25        David
Alt        Moved rank/special duties to
record level d/t rank duplications
004        11/24/25        David
Alt        Reconfigured prompt to
include timestamps
******************************************************************************/
drop program
dev_rpt_appt_stat_det_uic go
create
program dev_rpt_appt_stat_det_uic
prompt
"Output to File/Printer/MINE" = "MINE"
, "Appt Start" = "SYSDATE" ;* Enter the earliest date time
the medication was dispensed.
, "Appt End" = "SYSDATE" ;* Enter the latest date time
the medication was dispensed.
, "UIC" = ""
, "List" = 0
, "Appt Status" = VALUE(0.0)
, "Info" = ""
with OUTDEV,
start_date, end_date, uic_search, uic, appt_status, info
/**************************************************************
; Global
Declarations
**************************************************************/
declare
stat_var = C2 with protect ;operator variable for appointment status prompt
/**************************************************************
; Record
Structures
**************************************************************/
free record
pt ;patients
record pt (
1 list[*]
2 person_id = f8
2 name = c100
2 edipi = c10
2 unit = c10 ;assigned unit alias
2 attached_unit = c10 ;attached unit alias
2 mil_status = c40
2 rank = c40
2 special_duties = c255
) with
protect
/**************************************************************
; Subroutines
**************************************************************/
subroutine
(get_patients_by_uic(NULL) = NULL)
SELECT INTO "NL:"
FROM PERSON_MILITARY pm
,(LEFT JOIN ORGANIZATION_ALIAS uic ON uic.organization_id =
pm.assigned_unit_org_id
AND pm.assigned_unit_org_id != 0
AND uic.org_alias_type_cd = 1129) ;Employer Code
,(LEFT JOIN ORGANIZATION_ALIAS attached_uic ON
attached_uic.organization_id = pm.attached_unit_org_id
AND pm.attached_unit_org_id != 0
AND attached_uic.org_alias_type_cd = 1129) ;Employer Code
,PERSON p
,(LEFT JOIN PERSON_ALIAS edipi ON edipi.person_id = p.person_id
AND edipi.person_alias_type_cd = 22 ;edipi
AND TEXTLEN(edipi.alias) = 10
AND edipi.end_effective_dt_tm > SYSDATE
AND edipi.active_ind = 1)
,(LEFT JOIN PASSIVE_ALERT pal ON pal.person_id = p.person_id
AND pal.alert_source = "*SPECIAL_DUTY_STATUS"
;SZ_V2_SPECIAL_DUTY_STATUS
AND pal.end_effective_dt_tm > SYSDATE
AND pal.active_ind = 1)
,(LEFT JOIN PERSON_ORG_RELTN mil ON mil.person_id = p.person_id
AND mil.person_org_reltn_cd = 1136 ;employer
AND mil.empl_title_cd != 0
AND mil.end_effective_dt_tm > SYSDATE
AND mil.active_ind = 1)
PLAN pm WHERE (pm.assigned_unit_org_id = $uic OR
pm.attached_unit_org_id = $uic)
AND pm.active_ind = 1
JOIN p WHERE pm.person_id = p.person_id
JOIN uic
JOIN attached_uic
JOIN edipi
JOIN pal
JOIN mil
ORDER BY pm.person_id
HEAD REPORT
i = 0
DETAIL
i += 1
CALL ALTERLIST(pt->list, i)
pt->list[i].person_id = pm.person_id
pt->list[i].name = TRIM(p.name_full_formatted)
pt->list[i].edipi = TRIM(edipi.alias)
pt->list[i].unit = TRIM(uic.alias)
pt->list[i].attached_unit = TRIM(attached_uic.alias)
pt->list[i].mil_status =
TRIM(UAR_GET_CODE_DISPLAY(p.vet_military_status_cd))
pt->list[i].rank = TRIM(UAR_GET_CODE_DISPLAY(mil.empl_title_cd))
pt->list[i].special_duties = EVALUATE2(
IF(pal.passive_alert_id != 0) PIECE(pal.alert_txt, ": ", 2,
"not found")
ELSE ""
ENDIF)
WITH NULLREPORT
end
;get_patients_by_uic
/**************************************************************
; Main
**************************************************************/
CALL
get_patients_by_uic(NULL)
IF(substring(1,1,reflect(parameter(6,0)))
= "L") ;multiple selection
 SET stat_var = "IN"
ELSEIF(parameter(6,1)=
0.0) ;"Any" selected (must define as 0.0 in prompt)
 SET stat_var = ">="
ELSE ;single
value selected
 SET stat_var = "="
ENDIF
/**************************************************************
; Output
**************************************************************/
SELECT INTO
$OUTDEV
patient = pt->list[d.seq].name
,edipi = pt->list[d.seq].edipi
,appt_location = UAR_GET_CODE_DISPLAY(sa.appt_location_cd)
,appt_dt_tm = DATETIMEZONEFORMAT(sa.beg_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
;,sa.duration
,appt_type = UAR_GET_CODE_DISPLAY(se.appt_type_cd)
,appt_status =
IF(sa.state_meaning = "CHECK*") "KEPT"
ELSE sa.state_meaning
ENDIF
,scheduled_resource = UAR_GET_CODE_DISPLAY(sa_r.resource_cd)
;supplemental appt/encntr info
,facility = org.org_name
,encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
,fin = fin.alias
,cancel_window =
IF(cancel.sch_event_id != 0)
IF(DATETIMEDIFF(cancel.action_dt_tm, sa.beg_dt_tm, 4)/60 < -72)
"> 72 hours"
ELSEIF(DATETIMEDIFF(cancel.action_dt_tm, sa.beg_dt_tm, 4)/60 > -24)
"< 24 hours"
ELSE "24-72 hours"
ENDIF
ELSE ""
ENDIF
;supplemental person info
,military_status = pt->list[d.seq].mil_status
,rank = pt->list[d.seq].rank
,attached_unit = pt->list[d.seq].attached_unit
,assigned_unit = pt->list[d.seq].unit
,special_duties = pt->list[d.seq].special_duties
FROM (DUMMYT
d WITH seq = value(size(pt->list, 5)))
,SCH_APPT sa
,(LEFT JOIN LOCATION appt_loc ON appt_loc.location_cd =
sa.appt_location_cd
AND appt_loc.end_effective_dt_tm > SYSDATE
AND appt_loc.active_ind = 1)
,(LEFT JOIN ORGANIZATION org ON org.organization_id =
appt_loc.organization_id)
,(LEFT JOIN LOCATION appt_fac ON appt_fac.organization_id =
appt_loc.organization_id
AND appt_fac.location_type_cd = 783 ;facility
AND appt_fac.active_ind = 1)
,(LEFT JOIN TIME_ZONE_R tz ON tz.parent_entity_id =
appt_fac.location_cd
AND tz.parent_entity_name = "LOCATION")
 ,(LEFT JOIN SCH_EVENT_ACTION cancel ON
cancel.sch_event_id = sa.sch_event_id
         AND sa.sch_state_cd =
4535 ;canceled
         AND cancel.sch_action_cd
= 4518 ;cancel
         AND
cancel.end_effective_dt_tm > SYSDATE
         AND cancel.version_dt_tm
> SYSDATE
         AND cancel.active_ind =
1)
,(LEFT JOIN ENCNTR_ALIAS fin ON fin.encntr_id = sa.encntr_id
AND fin.encntr_alias_type_cd = 1077 ;fin
AND fin.end_effective_dt_tm > SYSDATE
AND fin.active_ind = 1)
,(LEFT JOIN ENCOUNTER e ON e.encntr_id = sa.encntr_id
AND e.end_effective_dt_tm > SYSDATE
AND e.active_ind = 1)
 ,SCH_APPT sa_r
 ,SCH_EVENT se
PLAN d
JOIN sa WHERE
pt->list[d.seq].person_id = sa.person_id
 AND sa.role_meaning = "PATIENT"
 AND OPERATOR(sa.sch_state_cd, stat_var,
$appt_status)
 AND sa.beg_dt_tm BETWEEN
CNVTDATETIME($start_date) AND CNVTDATETIME($end_date)
 AND sa.end_effective_dt_tm > SYSDATE
 AND sa.version_dt_tm > SYSDATE
 AND sa.active_ind = 1
JOIN sa_r
WHERE sa_r.sch_event_id = sa.sch_event_id
AND sa_r.role_meaning != "PATIENT"
AND sa_r.sch_state_cd = sa.sch_state_cd
AND sa_r.primary_role_ind+0 = 1
AND sa_r.resource_cd+0 != 0
AND sa_r.end_effective_dt_tm > SYSDATE
AND sa_r.version_dt_tm > SYSDATE
AND sa_r.active_ind = 1
JOIN se WHERE
se.sch_event_id = sa.sch_event_id
AND se.end_effective_dt_tm > SYSDATE
AND se.version_dt_tm > SYSDATE
AND se.active_ind = 1
JOIN fin
JOIN e
JOIN cancel
JOIN appt_loc
JOIN org
JOIN appt_fac
JOIN tz
ORDER BY
patient, appt_dt_tm
WITH
NOCOUNTER, SEPARATOR=" ", FORMAT, CHECK, TIME=180
end
go
