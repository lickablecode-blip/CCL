/*
 * Source page  : Facility Detail Audit
 * Source file  : output/facility-detail-audit.md
 * Anchor       : (top of page)
 * Block index  : 1 of 2
 * Detected lang: ccl
 * Lines        : 1987
 *
 * Context (preceding paragraph):
 *   Exported: 11/20/25
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

/******************************************************************************
 REPORT NAME:
        Facility Detail Audit
 PROGRAM:                1fed_rpt_facility_detail_audit.prg
 DEV
PROGRAM:        dev_rpt_facility_detail_audit.prg
 DEVELOPER:        David Alt
(david.a.alt2.mil@health.mil)
 PUBLISHED:        Fall 2022
 SNAPSHOT:                8/18/2025
 LOGICAL
PATH:        cust_script:
 NODE:                        <default>
 PURPOSE/DESCRIPTION:
         Provides audits to look
at facility configuration and activity
          Appointments by type: list # appts by appt type per nurse unit
          Diagnoses (charted): list # diagnoses directly charted by provider
          Encounters by personnel: list # encntrs by personnel, relationship
          Encounters by type: list # encntrs by encntr type per nurse unit
          Location Build (PCL): output the structure of the location build
          Location Build (SRL): output the structure of the service resource
build
          Location Usage: list # encntrs/location over time
          Med orders by position: # med orders by
location/type/comms/position/prsnl
          Order Catalog: virtual view of orders available to facility
          Personnel (DoD assigned):
          Personnel (DoD predicted):
          Personnel Groups: lists of personnel associated with
organization
          PowerPlan Catalog: virtual view of powerplans available to
facility
          User count by position (DoD, predicted):
 TARGET AUDIENCE:
          Users involved in
facility oversight (directors, data managers)
          Users involved in build
configuration (solution owners/experts)
MOD        DATE                DEVELOPER        COMMENT
         ---        --/--/--        ---------        ---------------------------
001        01/22/23        David
Alt        Encounters by type - added %
         002        01/25/23        David
Alt        Added Appointments by type
         003        01/27/23        David
Alt        Added Diagnoses (by
provider)
         004        01/27/23        David
Alt        Added Encounters by
personnel
         005        02/01/23        David
Alt        Added Vaccinations by
encounter type
         006        02/02/23        David
Alt        Added Encounters, active
deceased
         007        03/07/23        David
Alt        Added Providers by medical
service
         008        03/09/23        David
Alt        Renamed per FEHRM AGB
convention
         009        03/16/23        David
Alt        Added Encounters with
multiple appointments
         010        03/28/23        David
Alt        Added Discharges by
disposition
         011        03/29/23        David
Alt        Added PowerForm usage
         012
04/17/23        David
Alt        Fixed order truncation by
using ORDER_CATALOG instead of CODE_VALUE
         013        05/02/23        David
Alt        Added Encounters by admit
mode
                                                                 Added
Encounters by admit source
                                                                 Added
Encounters by admit type
                                                                 Added
Encounters by accommodation
                                                                 Renamed
Discharges by disposition --> Encounters by discharge disposition
                                                                 Fixed
"all facility" orders in order catalog view
         014        05/04/23        David
Alt        Added UICs seen by attending
provider
         015        05/05/23        David
Alt        Added Encounters by
financial class
                                                                 Added
Encounters by profile and plan
         016        10/13/23        David
Alt        Added alternate room display
to Location build (PCL)
         017        11/13/23        David
Alt        Added Location aliases (PCL)
         018        11/14/23        David
Alt        Added PowerPlan usage
         019        01/05/24        David
Alt        Updated naming/order for
personnel location assignment reports
                                                                 Added
Personnel (DOD, assigned or predicted)
020        01/31/24        David
Alt        Added Personnel (DOD,
prescribers)
                                                                 Removed
Personnel (DOD, assigned) & Personnel (DOD, predicted)
                                                                 Removed
User count by position (DOD, predicted)
                                                                 Added
start/end range to Providers by medical service
                                                                 Added
Schedulable resources
         021        03/26/24        David
Alt        Added NHSN unit, CDC label
display to Location Build (PCL); renamed columns
         022        04/12/24        David
Alt        Added Encounters by medical
service
                                                                 Increased
time-out to 600
023        05/10/24        David
Alt        Added filtering for
privileged locations in prompt search
         024        08/02/24        David
Alt        Fixed prompt logic in
$facility resulting in missing organization_ids
         025        08/20/24        David
Alt        Added search
by-->organization
         026        08/26/24        David
Alt        Added primary facility to
Personnel (DOD, prescribers)
         027        02/19/25        David
Alt        Fixed PLAN in PowerPlan
Catalog
         028        03/03/25        David
Alt        Added "Bed status"
         029        03/31/25        David
Alt        Enhanced prompt security
         030        05/19/25        David
Alt        Added organization_id to
Location build (PCL)
                                                                 Added
organization_id to Location build (SRL)
                                                                 Added
"Addresses"
         031        06/02/25        David
Alt        Added unit_updated_dt_tm to
Location build (PCL) (DMFEHRM-21593)
         032        06/04/25        David
Alt        Added "Prescriber
configuration"
                                                                 Removed
"Personnel (DoD, prescribers)"
         033        06/24/25        David
Alt        Added "Phone
numbers"
         034        08/18/25        David
Alt        Added "Lab
orderable-service resource map"
         ---- unpublished ----
         035
10/14/25        David
Alt        Added "Blood products
(available)"
         TODO:
                 Add
taxonomy to Personnel (DOD, prescriber) without breaking grain (and fix DEA/NPI
grain)
                 Add
"Schedulable resources" - list of schedulable resources for each
clinic
                 Add
encntrs by attending provider, encntr type
         Consider: remove pharmacy locations from PCL output
******************************************************************************/
drop program
dev_rpt_facility_detail_audit go
create
program dev_rpt_facility_detail_audit
prompt
"Output to File/Printer/MINE" = "MINE" ;* Enter or select the
printer or file name to send this report to.
, "Search for facility, then select Reports" =
"search"
;<<hidden>>"Search Term (use * for wildcards)" =
""
;<<hidden>>"Search By" = "Facility"
, "" = 0
, "Help" = ""
, "Report" = ""
, "Start Date" = "CURDATE"
, "End Date" = "CURDATE"
with OUTDEV,
tab, facility, help, rpt, start_date, end_date
/**************************************************************
; Global
Declarations
**************************************************************/
; indices for
LOCATEVAL
DECLARE NUM =
i4 WITH noconstant(0)
DECLARE POS =
i4 WITH noconstant(0)
DECLARE
fac_idx = i4 WITH protect, noconstant(0) ;for expanding fac record
/**************************************************************
; Record
Structures
**************************************************************/
free record
nu
record nu (
1 list[*]
2 nu_cd = f8
2 ecnt = i4
) with
protect
free record
ec
record ec (
1 list[*]
2 fac_cd = f8
2 bld_cd = f8
2 nu_cd = f8
2 etype_cd = f8
2 ecnt = i4 ;encntrs per NU/etype
2 pcnt = i4 ;patients per NU/etype
2 nu_ecnt = i4 ;encntrs per NU
2 nu_pct = f8
) with
protect
free record
fac ;stores prompt selections
record fac (
1 list[*]
2 location_cd = f8
2 organization_id = f8
2 display = c40
2 description = c60
2 agency = c4
2 parent_dmis = c4
2 division = c40
2 visn = c2
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
return (output)
end
;return_CRLF
subroutine
(build_fac_record(input = NULL) = NULL)
SELECT INTO "NL:"
FROM CUST_LOC_AGENCY_RELTN ag
PLAN ag WHERE ag.organization_id = $facility
ORDER BY ag.location_cd
HEAD REPORT
i = 0
DETAIL
i += 1
CALL ALTERLIST(fac->list, i)
fac->list[i].location_cd = ag.location_cd
fac->list[i].organization_id = ag.organization_id
fac->list[i].display = UAR_GET_CODE_DISPLAY(ag.location_cd)
fac->list[i].description = UAR_GET_CODE_DESCRIPTION(ag.location_cd)
fac->list[i].agency = ag.agency
fac->list[i].parent_dmis = ag.dmis_code
fac->list[i].division = ag.division_code
fac->list[i].visn = ag.visn_code
WITH NOCOUNTER
end
;build_fac_record
/**************************************************************
; Init
**************************************************************/
CALL
build_fac_record(NULL)
IF($rpt =
"Encounters by type *")
; nurse unit totals
SELECT INTO "NL:"
ecnt = COUNT(*)
FROM ENCOUNTER e
PLAN e WHERE EXPAND(fac_idx, 1, size(fac->list, 5),
e.loc_facility_cd, fac->list[fac_idx].location_cd)
AND e.reg_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND e.loc_nurse_unit_cd > 0
AND e.active_ind = 1
AND e.end_effective_dt_tm > SYSDATE
GROUP BY e.loc_facility_cd, e.loc_building_cd, e.loc_nurse_unit_cd
HEAD REPORT
i = 0
DETAIL
i += 1
CALL ALTERLIST(nu->list, i)
nu->list[i].nu_cd = e.loc_nurse_unit_cd
nu->list[i].ecnt = ecnt
WITH NULLREPORT
; etype totals
SELECT INTO "NL:"
ecnt = COUNT(*)
,pcnt = COUNT(DISTINCT e.person_id)
FROM ENCOUNTER e
PLAN e WHERE EXPAND(fac_idx, 1, size(fac->list, 5),
e.loc_facility_cd, fac->list[fac_idx].location_cd)
AND e.reg_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND e.loc_nurse_unit_cd > 0
AND e.active_ind = 1
AND e.end_effective_dt_tm > SYSDATE
GROUP BY e.loc_facility_cd, e.loc_building_cd, e.loc_nurse_unit_cd,
e.encntr_type_cd
HEAD REPORT
i = 0
DETAIL
i += 1
CALL ALTERLIST(ec->list, i)
ec->list[i].fac_cd = e.loc_facility_cd
ec->list[i].bld_cd = e.loc_building_cd
ec->list[i].nu_cd = e.loc_nurse_unit_cd
ec->list[i].etype_cd = e.encntr_type_cd
ec->list[i].ecnt = ecnt
ec->list[i].pcnt = pcnt
POS = LOCATEVAL(NUM, 1, size(nu->list,5), ec->list[i].nu_cd,
nu->list[NUM].nu_cd)
ec->list[i].nu_ecnt = nu->list[POS].ecnt
ec->list[i].nu_pct = CNVTREAL(ec->list[i].ecnt) /
CNVTREAL(ec->list[i].nu_ecnt)
WITH NULLREPORT
ENDIF
/**************************************************************
; Report
**************************************************************/
SELECT
IF($facility
= 0 OR TEXTLEN(TRIM($rpt)) = 0)
error = "You must select both a facility and a report!"
,facility_was_selected =
IF($facility > 0) "ok"
ELSE "missing"
ENDIF
,report_was_selected =
IF(TEXTLEN(TRIM($rpt)) > 0) "ok"
ELSE "missing"
ENDIF
ELSEIF($rpt =
"Addresses")
 organization = org.org_name
 ,type =
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
,ORGANIZATION org
PLAN a WHERE a.parent_entity_id = $facility
AND a.parent_entity_name = "ORGANIZATION"
AND a.end_effective_dt_tm > SYSDATE
AND a.active_ind = 1
JOIN org WHERE org.organization_id = a.parent_entity_id
ORDER BY organization, type
ELSEIF($rpt =
"Appointments by status *")
facility = UAR_GET_CODE_DISPLAY(fac.location_cd)
,building = UAR_GET_CODE_DISPLAY(fac_bld.child_loc_cd)
,nurse_unit = UAR_GET_CODE_DISPLAY(nu.location_cd)
,appt_status = UAR_GET_CODE_DISPLAY(sa.sch_state_cd)
,nbr_appts = COUNT(DISTINCT sa.sch_appt_id)
,nbr_patients = COUNT(DISTINCT sa.person_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date)
"MM/DD/YYYY;;d"
FROM LOCATION fac
,LOCATION_GROUP fac_bld
,LOCATION_GROUP bld_nu
,LOCATION nu
,SCH_APPT sa
PLAN fac WHERE fac.organization_id = $facility
AND fac.location_type_cd = 783 ;facility
JOIN fac_bld WHERE fac_bld.parent_loc_cd = fac.location_cd
AND fac_bld.root_loc_cd = 0
AND fac_bld.location_group_type_cd = 783 ;facility
AND fac_bld.active_ind = 1
JOIN bld_nu WHERE bld_nu.parent_loc_cd = fac_bld.child_loc_cd
AND bld_nu.root_loc_cd = 0
AND bld_nu.location_group_type_cd = 778 ;building
AND bld_nu.active_ind = 1
JOIN nu WHERE bld_nu.child_loc_cd = nu.location_cd
AND nu.location_type_cd IN (772, 794) ;ambulatory, nurse unit
AND nu.active_ind = 1
JOIN sa WHERE nu.location_cd = sa.appt_location_cd
AND sa.beg_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND sa.sch_role_cd = 4572
;patient
AND sa.active_ind = 1
GROUP BY fac.location_cd, fac_bld.child_loc_cd, nu.location_cd,
sa.sch_state_cd
ORDER BY facility, building, nurse_unit, appt_status
ELSEIF($rpt =
"Appointments by type *")
facility = UAR_GET_CODE_DISPLAY(f.location_cd)
,building = UAR_GET_CODE_DISPLAY(f_b.child_loc_cd)
,unit = UAR_GET_CODE_DISPLAY(unit.location_cd)
,appt_type = UAR_GET_CODE_DISPLAY(se.appt_type_cd)
,nbr_appts = COUNT(DISTINCT sa.sch_appt_id)
,nbr_patients = COUNT(DISTINCT sa.person_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date)
"MM/DD/YYYY;;d"
FROM LOCATION f
,LOCATION_GROUP f_b
,LOCATION_GROUP b_u
,LOCATION unit
,SCH_APPT sa
,SCH_EVENT se
PLAN f WHERE f.organization_id = $facility
AND f.location_type_cd = 783 ;facility
AND f.active_ind = 1
AND f.end_effective_dt_tm > SYSDATE
JOIN f_b WHERE f_b.parent_loc_cd = f.location_cd
AND f_b.root_loc_cd = 0
AND f_b.active_ind = 1
AND f_b.end_effective_dt_tm > SYSDATE
JOIN b_u WHERE b_u.parent_loc_cd = f_b.child_loc_cd
AND b_u.root_loc_cd = 0
AND b_u.active_ind = 1
AND b_u.end_effective_dt_tm > SYSDATE
JOIN unit WHERE b_u.child_loc_cd = unit.location_cd
AND unit.location_type_cd IN (772, 794) ;ambulatory, nurse_unit
AND unit.active_ind = 1
AND unit.end_effective_dt_tm > SYSDATE
JOIN sa WHERE unit.location_cd = sa.appt_location_cd
AND sa.active_ind = 1
AND sa.sch_state_cd = 4537 ;checked out
AND sa.sch_role_cd = 4572 ;patient
AND sa.beg_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
JOIN se WHERE sa.sch_event_id = se.sch_event_id
AND se.active_ind = 1
AND se.end_effective_dt_tm >
SYSDATE
GROUP BY f.location_cd, f_b.child_loc_cd, unit.location_cd,
se.appt_type_cd
ORDER BY facility, building, unit,
appt_type
ELSEIF($rpt =
"Bed status")
facility =
substring(1,40,replace_crlf(UAR_GET_CODE_DISPLAY(f.location_cd)))
,building =
substring(1,40,replace_crlf(UAR_GET_CODE_DISPLAY(f_b.child_loc_cd)))
,unit =
substring(1,40,replace_crlf(UAR_GET_CODE_DISPLAY(b_u.child_loc_cd)))
,room = UAR_GET_CODE_DISPLAY(u_r.child_loc_cd)
,room_extension = alt_room.field_value
,bed = UAR_GET_CODE_DISPLAY(r_b.child_loc_cd)
,bed_status = UAR_GET_CODE_DISPLAY(b.bed_status_cd)
,encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
,med_service = UAR_GET_CODE_DISPLAY(e.med_service_cd)
,fin = fin.alias
,reg_dt_tm = DATETIMEZONEFORMAT(e.reg_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
,patient_age = IF(p.person_id != 0) CNVTAGE(p.birth_dt_tm, e.reg_dt_tm,
0) ENDIF
,patient_sex = UAR_GET_CODE_DISPLAY(p.sex_cd)
FROM LOCATION f
,LOCATION_GROUP f_b
,LOCATION_GROUP b_u
,LOCATION_GROUP u_r
,LOCATION_GROUP r_b
,LOCATION unit
,LOCATION room
,(LEFT JOIN CODE_VALUE_EXTENSION alt_room ON room.location_cd =
alt_room.code_value
AND alt_room.field_name = "ALT_DISPLAY")
,BED b
,(LEFT JOIN ENCOUNTER e ON e.loc_bed_cd = b.location_cd
AND e.disch_dt_tm IS NULL
AND e.end_effective_dt_tm > SYSDATE
AND e.active_ind = 1)
,(LEFT JOIN ENCNTR_ALIAS fin ON fin.encntr_id = e.encntr_id
AND fin.encntr_alias_type_cd = 1077 ;FIN
AND fin.end_effective_dt_tm > SYSDATE
AND fin.active_ind = 1)
,(LEFT JOIN TIME_ZONE_R tz ON tz.parent_entity_id = e.loc_facility_cd
AND tz.parent_entity_name = "LOCATION")
,(LEFT JOIN PERSON p ON p.person_id = e.person_id)
PLAN f WHERE f.organization_id = $facility
AND f.location_type_cd = 783 ;facility
AND f.end_effective_dt_tm > SYSDATE
AND f.active_ind = 1
JOIN f_b WHERE f_b.parent_loc_cd = f.location_cd
AND f_b.root_loc_cd = 0
AND f_b.location_group_type_cd = 783 ;facility
AND f_b.end_effective_dt_tm > SYSDATE
AND f_b.active_ind = 1
JOIN b_u WHERE b_u.parent_loc_cd = f_b.child_loc_cd
AND b_u.root_loc_cd = 0
AND b_u.location_group_type_cd = 778 ;building
AND b_u.end_effective_dt_tm > SYSDATE
AND b_u.active_ind = 1
JOIN u_r WHERE u_r.parent_loc_cd = b_u.child_loc_cd
AND u_r.root_loc_cd = 0
AND u_r.end_effective_dt_tm > SYSDATE
AND u_r.active_ind = 1
JOIN r_b WHERE r_b.parent_loc_cd = u_r.child_loc_cd
AND r_b.root_loc_cd = 0
AND r_b.end_effective_dt_tm > SYSDATE
AND r_b.active_ind = 1
JOIN unit WHERE b_u.child_loc_cd = unit.location_cd
AND unit.location_cd NOT IN (
SELECT code_value
FROM CODE_VALUE
WHERE code_set = 220
AND display_key = "ZZ*"
AND active_ind = 1
)
AND unit.end_effective_dt_tm > SYSDATE
AND unit.active_ind = 1
JOIN room WHERE room.location_cd = u_r.child_loc_cd
AND room.end_effective_dt_tm > SYSDATE
AND room.active_ind = 1
JOIN b WHERE b.location_cd = r_b.child_loc_cd
AND b.end_effective_dt_tm > SYSDATE
AND b.active_ind = 1
JOIN alt_room
JOIN e
JOIN fin
JOIN tz
JOIN p
ORDER BY facility, building, unit, room, bed
ELSEIF($rpt =
"Blood products (available)")
facility = UAR_GET_CODE_DISPLAY(inv_facility.location_cd)
,inventory_area = UAR_GET_CODE_DISPLAY(p.cur_inv_area_cd)
,category = UAR_GET_CODE_DISPLAY(p.product_cat_cd)
,p.product_nbr
,product = UAR_GET_CODE_DISPLAY(p.product_cd)
,volume = BUILD(bp.cur_volume, CONCAT(" ",
UAR_GET_CODE_DISPLAY(p.cur_unit_meas_cd)))
,abo_rh = CONCAT(
TRIM(UAR_GET_CODE_DISPLAY(bp.cur_abo_cd))
,"-"
,TRIM(UAR_GET_CODE_DISPLAY(bp.cur_rh_cd)))
,donation_type = UAR_GET_CODE_DISPLAY(p.donation_type_cd)
,supplier = supplier.org_name
,expire_dt_tm = p.cur_expire_dt_tm "MM/DD/YYYY
HH:MM;;q"
,shipping_condition = UAR_GET_CODE_DISPLAY(p.orig_ship_cond_cd)
,storage_temp = UAR_GET_CODE_DISPLAY(p.storage_temp_cd)
,visual_inspection = UAR_GET_CODE_DISPLAY(p.orig_vis_insp_cd)
;indicators
;        ,pooled_component_ind
= IF(p.pooled_product_id != 0) 1 ELSE 0 ENDIF
;        ,p.pooled_product_ind
;1 for the combined/pooled product, not for components of it
;        ,modified_child_ind
= IF(p.modified_product_id != 0) 1 ELSE 0 ENDIF
;        ,modified_parent_ind
= p.modified_product_ind ;1 for parent product, not modified children
;        ,p.locked_ind
;locked for update by particular blood bank transaction
;        ,p.corrected_ind
;whether product has been corrected, e.g. demographics updated
;        ,prod_demo_scan_ind
= p.electronic_entry_flag ;1=demographics electronically scanned, 0=not
necessarily
;        ,p.req_label_verify_ind
;product requires label verification
;        ,bp.autologous_ind
;donated by the intended recipient
;        ,bp.directed_ind
;donated with intent to use on specific person
;identifiers
,p.product_id
;,product_code = CNVTUPPER(p.product_type_barcode)
FROM LOCATION inv_area_loc
,PRODUCT p
,(LEFT JOIN BLOOD_PRODUCT bp ON bp.product_id = p.product_id
AND bp.active_ind = 1)
,PRODUCT_EVENT pe
,ORGANIZATION supplier
,LOCATION inv_facility
PLAN inv_area_loc WHERE inv_area_loc.organization_id = $facility
AND inv_area_loc.location_type_cd = 775 ;BB Inventory Area
AND inv_area_loc.active_ind = 1
JOIN p WHERE p.cur_inv_area_cd = inv_area_loc.location_cd
AND p.cur_expire_dt_tm > SYSDATE
AND p.product_id != 0
AND p.active_ind = 1
JOIN pe WHERE pe.product_id = p.product_id
AND pe.event_type_cd = 1431 ;available
AND pe.active_ind = 1
JOIN supplier WHERE supplier.organization_id = p.cur_supplier_id
JOIN inv_facility WHERE inv_facility.organization_id =
inv_area_loc.organization_id
AND inv_facility.location_type_cd = 783 ;facility
JOIN bp
ORDER BY facility, inventory_area, category, p.product_nbr, product
ELSEIF($rpt =
"Diagnoses (charted) *")
facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,building = UAR_GET_CODE_DISPLAY(e.loc_building_cd)
,nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
,diagnosis = n.source_string
,code = PIECE(n.concept_cki,"!",2,"parse error")
,diag_type = UAR_GET_CODE_DISPLAY(d.diag_type_cd)
,nbr_encntrs = COUNT(DISTINCT d.encntr_id)
,nbr_patients = COUNT(DISTINCT d.person_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
FROM ENCOUNTER e
,DIAGNOSIS d
,NOMENCLATURE n
PLAN e WHERE EXPAND(fac_idx, 1, size(fac->list, 5),
e.loc_facility_cd, fac->list[fac_idx].location_cd)
AND e.reg_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND e.active_ind = 1
AND e.end_effective_dt_tm > SYSDATE
JOIN d WHERE e.encntr_id = d.encntr_id
AND d.diag_prsnl_id > 0
AND d.active_ind = 1
AND d.end_effective_dt_tm > SYSDATE
JOIN n WHERE d.nomenclature_id = n.nomenclature_id
GROUP BY e.loc_facility_cd, e.loc_building_cd, e.loc_nurse_unit_cd,
n.source_string, n.concept_cki, d.diag_type_cd
ORDER BY facility, building, nurse_unit, diagnosis, diag_type
ELSEIF($rpt =
"Encounters, open and
deceased")
facility = UAR_GET_CODE_DISPLAY(ed.loc_facility_cd)
,building = UAR_GET_CODE_DISPLAY(ed.loc_building_cd)
,nurse_unit = UAR_GET_CODE_DISPLAY(ed.loc_nurse_unit_cd)
,patient = p.name_full_formatted
,deceased_state = UAR_GET_CODE_DISPLAY(p.deceased_cd)
,p.deceased_dt_tm
,fin = fin.alias
,encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
,e.create_dt_tm
,e.reg_dt_tm
,e.disch_dt_tm
,e.encntr_id
,p.person_id
FROM ENCOUNTER e
,ENCNTR_DOMAIN ed
,(LEFT JOIN ENCNTR_ALIAS fin ON ed.encntr_id = fin.encntr_id
AND fin.encntr_alias_type_cd = 1077
AND fin.active_ind = 1
AND fin.end_effective_dt_tm > SYSDATE)
,PERSON p
PLAN e WHERE EXPAND(fac_idx, 1, size(fac->list, 5),
e.loc_facility_cd, fac->list[fac_idx].location_cd)
AND e.active_ind = 1
AND e.disch_dt_tm IS NULL
JOIN ed WHERE e.encntr_id = ed.encntr_id
AND ed.active_ind = 1
JOIN p WHERE ed.person_id = p.person_id
AND p.active_ind = 1
AND p.deceased_cd = 684729 ;deceased
JOIN fin
ORDER BY facility, building, nurse_unit,
CNVTUPPER(p.name_full_formatted), e.reg_dt_tm
ELSEIF($rpt =
"Encounters by accommodation *")
facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,building = UAR_GET_CODE_DISPLAY(e.loc_building_cd)
,nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
,accommodation = UAR_GET_CODE_DISPLAY(e.accommodation_cd)
,nbr_encntrs = COUNT(DISTINCT e.encntr_id)
,nbr_patients = COUNT(DISTINCT e.person_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
FROM ENCOUNTER e
PLAN e WHERE EXPAND(fac_idx, 1, size(fac->list, 5),
e.loc_facility_cd, fac->list[fac_idx].location_cd)
AND e.reg_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND e.active_ind = 1
AND e.end_effective_dt_tm > SYSDATE
GROUP BY e.loc_facility_cd, e.loc_building_cd, e.loc_nurse_unit_cd,
e.accommodation_cd
ORDER BY facility, building, nurse_unit, accommodation
ELSEIF($rpt =
"Encounters by admit mode *")
facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,building = UAR_GET_CODE_DISPLAY(e.loc_building_cd)
,nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
,admit_mode = UAR_GET_CODE_DISPLAY(e.admit_mode_cd)
,nbr_encntrs = COUNT(DISTINCT e.encntr_id)
,nbr_patients = COUNT(DISTINCT e.person_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
FROM ENCOUNTER e
PLAN e WHERE EXPAND(fac_idx, 1, size(fac->list, 5),
e.loc_facility_cd, fac->list[fac_idx].location_cd)
AND e.reg_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND e.active_ind = 1
AND e.end_effective_dt_tm > SYSDATE
GROUP BY e.loc_facility_cd, e.loc_building_cd, e.loc_nurse_unit_cd,
e.admit_mode_cd
ORDER BY facility, building, nurse_unit, admit_mode
ELSEIF($rpt =
"Encounters by admit source *")
facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,building = UAR_GET_CODE_DISPLAY(e.loc_building_cd)
,nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
,admit_source = UAR_GET_CODE_DISPLAY(e.admit_src_cd)
,nbr_encntrs = COUNT(DISTINCT e.encntr_id)
,nbr_patients = COUNT(DISTINCT e.person_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
FROM ENCOUNTER e
PLAN e WHERE EXPAND(fac_idx, 1, size(fac->list, 5),
e.loc_facility_cd, fac->list[fac_idx].location_cd)
AND e.reg_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND e.active_ind = 1
AND e.end_effective_dt_tm > SYSDATE
GROUP BY e.loc_facility_cd, e.loc_building_cd, e.loc_nurse_unit_cd,
e.admit_src_cd
ORDER BY facility, building, nurse_unit, admit_source
ELSEIF($rpt =
"Encounters by admit type *")
facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,building = UAR_GET_CODE_DISPLAY(e.loc_building_cd)
,nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
,admit_type = UAR_GET_CODE_DISPLAY(e.admit_type_cd)
,nbr_encntrs = COUNT(DISTINCT e.encntr_id)
,nbr_patients = COUNT(DISTINCT e.person_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
FROM ENCOUNTER e
PLAN e WHERE EXPAND(fac_idx, 1, size(fac->list, 5),
e.loc_facility_cd, fac->list[fac_idx].location_cd)
AND e.reg_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND e.active_ind = 1
AND e.end_effective_dt_tm > SYSDATE
GROUP BY e.loc_facility_cd, e.loc_building_cd, e.loc_nurse_unit_cd,
e.admit_type_cd
ORDER BY facility, building, nurse_unit, admit_type
ELSEIF($rpt =
"Encounters by discharge disposition *")
facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,building = UAR_GET_CODE_DISPLAY(e.loc_building_cd)
,nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
,disposition = UAR_GET_CODE_DISPLAY(e.disch_disposition_cd)
,nbr_encntrs = COUNT(DISTINCT e.encntr_id)
,nbr_patients = COUNT(DISTINCT e.person_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
FROM ENCOUNTER e
PLAN e WHERE EXPAND(fac_idx, 1, size(fac->list, 5),
e.loc_facility_cd, fac->list[fac_idx].location_cd)
AND e.disch_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND e.active_ind = 1
AND e.end_effective_dt_tm > SYSDATE
GROUP BY e.loc_facility_cd, e.loc_building_cd, e.loc_nurse_unit_cd,
e.disch_disposition_cd
ORDER BY facility, building, nurse_unit, disposition
ELSEIF($rpt =
"Encounters by financial class *")
facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,building = UAR_GET_CODE_DISPLAY(e.loc_building_cd)
,nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
,financial_class = UAR_GET_CODE_DISPLAY(hp.financial_class_cd)
,epr.priority_seq
,nbr_encntrs = COUNT(DISTINCT epr.encntr_id)
,nbr_patients = COUNT(DISTINCT e.person_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
 FROM ENCOUNTER e
 ,ENCNTR_PLAN_RELTN epr
 ,HEALTH_PLAN hp
 PLAN e WHERE EXPAND(fac_idx, 1,
size(fac->list, 5),
e.loc_facility_cd, fac->list[fac_idx].location_cd)
AND e.reg_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND e.active_ind = 1
AND e.end_effective_dt_tm > SYSDATE
 JOIN epr WHERE e.encntr_id = epr.encntr_id
         ;AND epr.priority_seq =
1
 AND epr.active_ind = 1
 AND epr.end_effective_dt_tm >
SYSDATE
 JOIN hp WHERE epr.health_plan_id =
hp.health_plan_id
 AND hp.active_ind = 1
 GROUP BY e.loc_facility_cd,
e.loc_building_cd, e.loc_nurse_unit_cd,
                 
hp.financial_class_cd, epr.priority_seq
 ORDER BY facility, building, nurse_unit,
financial_class, epr.priority_seq
ELSEIF($rpt =
"Encounters by medical service and type*")
facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,building = UAR_GET_CODE_DISPLAY(e.loc_building_cd)
,nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
,med_service = UAR_GET_CODE_DISPLAY(e.med_service_cd)
,encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
,nbr_encntrs = COUNT(DISTINCT e.encntr_id)
,nbr_patients = COUNT(DISTINCT e.person_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
 FROM ENCOUNTER e
 PLAN e WHERE EXPAND(fac_idx, 1,
size(fac->list, 5),
e.loc_facility_cd, fac->list[fac_idx].location_cd)
AND e.reg_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND e.active_ind = 1
AND e.end_effective_dt_tm > SYSDATE
 GROUP BY e.loc_facility_cd,
e.loc_building_cd, e.loc_nurse_unit_cd, e.med_service_cd, e.encntr_type_cd
 ORDER BY facility, building, nurse_unit,
med_service, encntr_type
ELSEIF($rpt =
"Encounters by personnel *")
facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,building = UAR_GET_CODE_DISPLAY(e.loc_building_cd)
,nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
,personnel = CONCAT(TRIM(p.name_full_formatted)," (",
TRIM(UAR_GET_CODE_DISPLAY(p.position_cd)), ")")
,relationship = UAR_GET_CODE_DISPLAY(epr.encntr_prsnl_r_cd)
,nbr_encntrs = COUNT(DISTINCT epr.encntr_id)
,nbr_patients = COUNT(DISTINCT e.person_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
FROM ENCOUNTER e
,ENCNTR_PRSNL_RELTN epr
,PRSNL p
PLAN e WHERE EXPAND(fac_idx, 1, size(fac->list, 5),
e.loc_facility_cd, fac->list[fac_idx].location_cd)
AND e.reg_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND e.active_ind = 1
AND e.end_effective_dt_tm > SYSDATE
JOIN epr WHERE e.encntr_id = epr.encntr_id
AND epr.active_ind = 1
JOIN p WHERE epr.prsnl_person_id = p.person_id
GROUP BY e.loc_facility_cd, e.loc_building_cd, e.loc_nurse_unit_cd,
 p.name_full_formatted,
p.position_cd, epr.encntr_prsnl_r_cd
ORDER BY facility, building, nurse_unit, personnel, relationship
ELSEIF($rpt =
"Encounters by profile and plan *")
facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,building = UAR_GET_CODE_DISPLAY(e.loc_building_cd)
,nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
 ,profile =
UAR_GET_CODE_DISPLAY(e.person_plan_profile_type_cd)
 ,health_plan = hp.plan_name
 ;,service_type =
UAR_GET_CODE_DISPLAY(hp.service_type_cd)
,nbr_encntrs = COUNT(DISTINCT epr.encntr_id)
,nbr_patients = COUNT(DISTINCT e.person_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
 FROM ENCOUNTER e
 ,ENCNTR_PLAN_RELTN epr
 ,HEALTH_PLAN hp
 PLAN e WHERE EXPAND(fac_idx, 1,
size(fac->list, 5),
e.loc_facility_cd, fac->list[fac_idx].location_cd)
AND e.reg_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND e.active_ind = 1
AND e.end_effective_dt_tm > SYSDATE
 JOIN epr WHERE e.encntr_id = epr.encntr_id
         AND epr.priority_seq = 1
 AND epr.active_ind = 1
 AND epr.end_effective_dt_tm >
SYSDATE
 JOIN hp WHERE epr.health_plan_id =
hp.health_plan_id
 AND hp.active_ind = 1
 GROUP BY e.loc_facility_cd,
e.loc_building_cd, e.loc_nurse_unit_cd,
                 
e.person_plan_profile_type_cd, hp.plan_name
 ORDER BY facility, building, nurse_unit,
profile, health_plan
ELSEIF($rpt =
"Encounters by type *")
facility = UAR_GET_CODE_DISPLAY(ec->list[d.seq].fac_cd)
,building = UAR_GET_CODE_DISPLAY(ec->list[d.seq].bld_cd)
,nurse_unit = UAR_GET_CODE_DISPLAY(ec->list[d.seq].nu_cd)
,encntr_type = UAR_GET_CODE_DISPLAY(ec->list[d.seq].etype_cd)
,patients = ec->list[d.seq].pcnt
,encntrs = ec->list[d.seq].ecnt
,nurse_unit_total = ec->list[d.seq].nu_ecnt
,nurse_unit_percent = format(ec->list[d.seq].nu_pct * 100,
"###.#%;;f")
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
FROM (DUMMYT d WITH seq = value(size(ec->list, 5)))
PLAN d
ORDER BY facility, building, nurse_unit, encntr_type
ELSEIF($rpt =
"Encounters with multiple appointments *")
facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,building = UAR_GET_CODE_DISPLAY(e.loc_building_cd)
,nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
,encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
,nbr_encntrs = COUNT(DISTINCT e.encntr_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
FROM ENCOUNTER e
,( (
SELECT sa.encntr_id, nbr_appts = COUNT(DISTINCT sa.sch_appt_id)
FROM SCH_APPT sa
WHERE sa.role_meaning = "PATIENT"
AND sa.sch_state_cd IN (4537, 4538) ;checked out, confirmed
AND sa.active_ind = 1
GROUP BY sa.encntr_id
HAVING COUNT(DISTINCT sa.sch_appt_id) > 1
WITH SQLTYPE("f8","i4")
) appt_cnt )
PLAN e WHERE EXPAND(fac_idx, 1, size(fac->list, 5),
e.loc_facility_cd, fac->list[fac_idx].location_cd)
AND e.reg_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND e.encntr_type_class_cd NOT IN (395, 397) ;pre-encounters, recurring
AND e.encntr_type_cd NOT IN (225058293, 389489525) ;between visit, care
not rendered
AND e.active_ind = 1
AND e.end_effective_dt_tm > SYSDATE
JOIN appt_cnt WHERE e.encntr_id = appt_cnt.encntr_id
GROUP BY e.loc_facility_cd, e.loc_building_cd, e.loc_nurse_unit_cd,
e.encntr_type_cd
ORDER BY facility, building, nurse_unit, encntr_type
ELSEIF($rpt =
"Lab orderable-service resource map")
DISTINCT
facility =
IF(ofr.facility_cd = 0) "<All facility access>"
ELSE UAR_GET_CODE_DISPLAY(ofr.facility_cd)
ENDIF
,orderable = oc.description
,activity_type = UAR_GET_CODE_DISPLAY(oc.activity_type_cd)
,activity_subtype = UAR_GET_CODE_DISPLAY(oc.activity_subtype_cd)
,service_resource = UAR_GET_CODE_DISPLAY(srl.service_resource_cd)
,resource_type = UAR_GET_CODE_DISPLAY(srl.service_resource_type_cd)
,oc.catalog_cd
,srl.service_resource_cd
;,resource_location = UAR_GET_CODE_DISPLAY(srl.location_cd)
FROM LOCATION fac
,OCS_FACILITY_R ofr
,ORDER_CATALOG_SYNONYM ocs
,ORDER_CATALOG oc
,(LEFT JOIN (
SELECT
sr.organization_id
,orl.service_resource_cd
,orl.catalog_cd
,sr.service_resource_type_cd
,sr.location_cd
FROM SERVICE_RESOURCE sr
,ORC_RESOURCE_LIST orl
WHERE sr.organization_id = $facility
AND sr.end_effective_dt_tm > SYSDATE
AND sr.active_ind = 1
AND orl.service_resource_cd = sr.service_resource_cd
AND orl.end_effective_dt_tm > SYSDATE
AND orl.active_ind = 1
WITH
SQLTYPE("f8","f8","f8","f8","f8"))
srl ON srl.catalog_cd = oc.catalog_cd)
         PLAN
fac WHERE fac.organization_id = $facility
AND fac.location_type_cd = 783 ;facility
AND fac.end_effective_dt_tm > SYSDATE
AND fac.active_ind = 1
JOIN ofr WHERE fac.location_cd = ofr.facility_cd OR ofr.facility_cd = 0
JOIN ocs WHERE ofr.synonym_id = ocs.synonym_id
AND ocs.catalog_type_cd = 2513 ;laboratory
AND ocs.active_ind = 1
JOIN oc WHERE ocs.catalog_cd = oc.catalog_cd
AND oc.active_ind = 1
JOIN srl
ORDER BY facility, activity_type, activity_subtype, orderable,
resource_type, service_resource
ELSEIF($rpt =
"Location aliases (PCL)")
facility = UAR_GET_CODE_DISPLAY(ag.location_cd)
,location = UAR_GET_CODE_DISPLAY(loc.location_cd)
,location_description = UAR_GET_CODE_DESCRIPTION(loc.location_cd)
,loc.location_cd
,location_type = EVALUATE(loc.location_type_cd,
783, "1-Facility",
778, "2-Building",
772, "3-Ambulatory",
794, "3-Nurse Unit",
801, "4-Room",
820, "4-Waiting Room",
777, "5-Bed",
UAR_GET_CODE_DISPLAY(loc.location_type_cd)
)
,source = UAR_GET_CODE_DISPLAY(aliases.contributor_source_cd)
,aliases.direction
,aliases.alias
,aliases.alias_type_meaning
FROM CUST_LOC_AGENCY_RELTN ag
,LOCATION loc
,(LEFT JOIN
(SELECT
code_set = ib.code_set
,code_value = ib.code_value
,contributor_source_cd = ib.contributor_source_cd
,alias = ib.alias
,alias_type_meaning = ib.alias_type_meaning
,direction =
"inbound"
FROM CODE_VALUE_ALIAS ib WHERE ib.code_set = 220
UNION
(SELECT
code_set = ob.code_set
,code_value = ob.code_value
,contributor_source_cd = ob.contributor_source_cd
,alias = ob.alias
,alias_type_meaning = ob.alias_type_meaning
,direction = "outbound"
FROM CODE_VALUE_OUTBOUND ob WHERE ob.code_set = 220
) WITH SQLTYPE("i4", "f8", "f8",
"c100", "c12", "c8"), RDBUNION) aliases
ON loc.location_cd = aliases.code_value)
PLAN ag WHERE ag.organization_id = $facility
JOIN loc WHERE loc.organization_id = ag.organization_id
AND loc.active_ind = 1
JOIN aliases
ORDER BY facility, location_type, location, source, aliases.direction
ELSEIF($rpt =
"Location build (PCL)")
facility =
substring(1,40,replace_crlf(UAR_GET_CODE_DISPLAY(f.location_cd)))
,building =
substring(1,40,replace_crlf(UAR_GET_CODE_DISPLAY(f_b.child_loc_cd)))
,unit =
substring(1,40,replace_crlf(UAR_GET_CODE_DISPLAY(b_u.child_loc_cd)))
;,unit_type = UAR_GET_CODE_DISPLAY(unit.location_type_cd)
,unit_type = cv_unit.cdf_meaning
,room = UAR_GET_CODE_DISPLAY(u_r.child_loc_cd)
,room_extension = alt_room.field_value
,room_type = UAR_GET_CODE_DISPLAY(room.location_type_cd)
,bed = UAR_GET_CODE_DISPLAY(r_b.child_loc_cd)
,dmis_id = ag.dmis_code
,dhmsm_alias = unit_dmis.alias
,meprs_alias = meprs.alias
,nhsn_unit_label = nhsn.nhsn_unit_disp_name
,cdc_location_label = UAR_GET_CODE_DISPLAY(nhsn.cdc_location_label_cd)
,unit_updated_dt_tm = cv_unit.updt_dt_tm
,ag.division_code
,ag.visn_code
,facility_description =
substring(1,60,replace_crlf(UAR_GET_CODE_DESCRIPTION(f.location_cd)))
,building_description =
substring(1,60,replace_crlf(UAR_GET_CODE_DESCRIPTION(f_b.child_loc_cd)))
,unit_description =
substring(1,60,replace_crlf(UAR_GET_CODE_DESCRIPTION(b_u.child_loc_cd)))
,room_description = UAR_GET_CODE_DESCRIPTION(u_r.child_loc_cd)
,bed_description = UAR_GET_CODE_DESCRIPTION(r_b.child_loc_cd)
,f.organization_id
,facility_cd = f.location_cd
,building_cd = f_b.child_loc_cd
,unit_cd = b_u.child_loc_cd
,room_cd = u_r.child_loc_cd
,bed_cd = r_b.child_loc_cd
FROM LOCATION f
,(LEFT JOIN CUST_LOC_AGENCY_RELTN ag ON f.location_cd = ag.location_cd
AND ag.validated_ind = 1)
,(LEFT JOIN LOCATION_GROUP f_b
ON f_b.parent_loc_cd = f.location_cd
AND f_b.root_loc_cd = 0
AND f_b.location_group_type_cd = 783 ;facility
AND f_b.end_effective_dt_tm > SYSDATE
AND f_b.active_ind = 1)
,(LEFT JOIN LOCATION_GROUP b_u
ON b_u.parent_loc_cd = f_b.child_loc_cd
AND b_u.root_loc_cd = 0
AND b_u.location_group_type_cd = 778 ;building
AND b_u.end_effective_dt_tm > SYSDATE
AND b_u.active_ind = 1)
,(LEFT JOIN CODE_VALUE cv_unit ON cv_unit.code_value =
b_u.child_loc_cd)
,(LEFT JOIN LOCATION unit ON b_u.child_loc_cd = unit.location_cd
AND unit.end_effective_dt_tm > SYSDATE
AND unit.active_ind = 1)
,(LEFT JOIN CODE_VALUE_OUTBOUND meprs
ON unit.location_cd = meprs.code_value
AND meprs.code_set = 220
AND meprs.contributor_source_cd = 108418263)
;"Legacy_Values")
,(LEFT JOIN LH_CNT_NHSN_LOCATION_MAP nhsn ON nhsn.nurse_loc_cd =
unit.location_cd
AND nhsn.active_ind = 1)
,(LEFT JOIN CODE_VALUE_OUTBOUND unit_dmis
ON unit.location_cd = unit_dmis.code_value
AND unit_dmis.code_set = 220
AND unit_dmis.contributor_source_cd = 105099617) ;DHMSM
,(LEFT JOIN LOCATION_GROUP u_r
ON u_r.parent_loc_cd = b_u.child_loc_cd
AND u_r.root_loc_cd = 0
AND u_r.end_effective_dt_tm > SYSDATE
AND u_r.active_ind = 1)
,(LEFT JOIN LOCATION room ON u_r.child_loc_cd = room.location_cd)
,(LEFT JOIN CODE_VALUE_EXTENSION alt_room ON room.location_cd =
alt_room.code_value
AND alt_room.field_name = "ALT_DISPLAY")
,(LEFT JOIN LOCATION_GROUP r_b
ON r_b.parent_loc_cd = u_r.child_loc_cd
AND r_b.root_loc_cd = 0
AND r_b.end_effective_dt_tm > SYSDATE
AND r_b.active_ind = 1)
PLAN f WHERE f.organization_id = $facility
AND f.location_type_cd = 783 ;facility
AND f.end_effective_dt_tm > SYSDATE
AND f.active_ind =
1
JOIN ag
JOIN f_b
JOIN b_u
JOIN u_r
JOIN r_b
JOIN unit
JOIN cv_unit
JOIN room
JOIN alt_room
JOIN meprs
JOIN nhsn
JOIN unit_dmis
ORDER BY facility, building, unit, room, bed
ELSEIF($rpt =
"Location build (SRL)")
organization = org.org_name
,institution =
substring(1,40,replace_crlf(UAR_GET_CODE_DISPLAY(inst.service_resource_cd)))
,department =
substring(1,40,replace_crlf(UAR_GET_CODE_DISPLAY(dept_sect.parent_service_resource_cd)))
,section =
substring(1,40,replace_crlf(UAR_GET_CODE_DISPLAY(sect.service_resource_cd)))
,subsection =
substring(1,40,replace_crlf(UAR_GET_CODE_DISPLAY(ss.service_resource_cd)))
,resource =
substring(1,40,replace_crlf(UAR_GET_CODE_DISPLAY(res.service_resource_cd)))
,resource_type = UAR_GET_CODE_DISPLAY(res.service_resource_type_cd)
,discipline = UAR_GET_CODE_DISPLAY(sect.discipline_type_cd)
,activity_type = UAR_GET_CODE_DISPLAY(sect.activity_type_cd)
,activity_subtype = UAR_GET_CODE_DISPLAY(res.activity_subtype_cd)
,location =
IF(sect.location_cd > 0) UAR_GET_CODE_DISPLAY(sect.location_cd)
ELSEIF(ss.location_cd > 0) UAR_GET_CODE_DISPLAY(ss.location_cd)
ELSEIF(res.location_cd > 0) UAR_GET_CODE_DISPLAY(res.location_cd)
ELSE ""
ENDIF
,pharmacy_type = UAR_GET_CODE_DISPLAY(sect.pharmacy_type_cd)
,inventory_loc = UAR_GET_CODE_DISPLAY(ss.inv_location_cd)
,pathnet_login_loc = UAR_GET_CODE_DISPLAY(res.cs_login_loc_cd)
,meprs_alias =
IF(TEXTLEN(TRIM(meprs4.alias)) > 0) meprs4.alias
ELSE meprs5.alias
ENDIF
,dmis_id = ag.dmis_code
,ag.division_code
,ag.visn_code
,inst.organization_id
,institution_cd = inst.service_resource_cd
,department_cd = dept_sect.parent_service_resource_cd
,section_cd = sect.service_resource_cd
,subsection_cd = ss.service_resource_cd
,resource_cd = res.service_resource_cd
FROM SERVICE_RESOURCE inst
,(LEFT JOIN RESOURCE_GROUP inst_dept ON
inst_dept.parent_service_resource_cd = inst.service_resource_cd
AND inst_dept.root_service_resource_cd = 0 ;master view
AND inst_dept.active_ind = 1
AND inst_dept.end_effective_dt_tm > SYSDATE)
,(LEFT JOIN RESOURCE_GROUP dept_sect ON
inst_dept.child_service_resource_cd = dept_sect.parent_service_resource_cd
AND dept_sect.resource_group_type_cd = 824 ;department
AND dept_sect.root_service_resource_cd = 0 ;master view
AND dept_sect.active_ind = 1
AND dept_sect.end_effective_dt_tm > SYSDATE)
,(LEFT JOIN SERVICE_RESOURCE sect ON
dept_sect.child_service_resource_cd = sect.service_resource_cd
AND sect.active_ind = 1
AND sect.end_effective_dt_tm > SYSDATE)
,(LEFT JOIN RESOURCE_GROUP sect_ss ON
sect_ss.parent_service_resource_cd = sect.service_resource_cd
AND sect_ss.root_service_resource_cd = 0 ;master view
AND sect_ss.active_ind = 1
AND sect_ss.end_effective_dt_tm > SYSDATE)
,(LEFT JOIN SERVICE_RESOURCE ss ON sect_ss.child_service_resource_cd =
ss.service_resource_cd
AND ss.active_ind = 1
AND ss.end_effective_dt_tm > SYSDATE)
,(LEFT JOIN CODE_VALUE_OUTBOUND meprs4
ON ss.service_resource_cd = meprs4.code_value
AND meprs4.code_set = 221
AND meprs4.contributor_source_cd = 108418263) ;Legacy Values ==
MEPRS
,(LEFT JOIN RESOURCE_GROUP ss_res ON ss_res.parent_service_resource_cd
= ss.service_resource_cd
AND ss_res.root_service_resource_cd = 0
AND ss_res.active_ind = 1
AND ss_res.end_effective_dt_tm >
SYSDATE)
,(LEFT JOIN SERVICE_RESOURCE res ON ss_res.child_service_resource_cd =
res.service_resource_cd
AND res.active_ind = 1
AND res.end_effective_dt_tm > SYSDATE)
,(LEFT JOIN CODE_VALUE_OUTBOUND meprs5
ON res.service_resource_cd = meprs5.code_value
AND meprs5.code_set = 221
AND meprs5.contributor_source_cd = 108418263) ;Legacy Values ==
MEPRS
,ORGANIZATION org
,(LEFT JOIN CUST_LOC_AGENCY_RELTN ag ON org.organization_id =
ag.organization_id
AND ag.validated_ind = 1)
PLAN inst WHERE inst.organization_id = $facility
AND inst.service_resource_type_cd = 826 ;institution
AND inst.active_ind = 1
AND inst.end_effective_dt_tm > SYSDATE
JOIN org WHERE inst.organization_id = org.organization_id
JOIN inst_dept
JOIN dept_sect
JOIN sect_ss
JOIN ss_res
JOIN sect
JOIN ss
JOIN res
JOIN meprs4
JOIN meprs5
JOIN ag
ORDER BY organization, institution, department, section, subsection,
resource
ELSEIF($rpt =
"Location usage *")
facility = UAR_GET_CODE_DISPLAY(loc.facility_cd)
,building = UAR_GET_CODE_DISPLAY(loc.building_cd)
,nurse_unit = UAR_GET_CODE_DISPLAY(loc.nurse_unit_cd)
,location_age_days = loc.nurse_unit_age
,nbr_encntrs_in_range = COUNT(DISTINCT e.encntr_id)
,utilization = (COUNT(DISTINCT e.encntr_id) / loc.nurse_unit_age)
,location_cd = loc.nurse_unit_cd
,location_type = UAR_GET_CODE_DISPLAY(loc.location_type_cd)
FROM (( SELECT
unit.location_type_cd
,facility_cd = fac_bld.parent_loc_cd
,building_cd = bld_unit.parent_loc_cd
,nurse_unit_cd = unit.location_cd
,nurse_unit_age = DATETIMECMP(SYSDATE, unit.beg_effective_dt_tm)
FROM LOCATION fac
,LOCATION_GROUP fac_bld
,LOCATION_GROUP bld_unit
,LOCATION unit
WHERE fac.organization_id = $facility
AND fac.location_type_cd = 783 ;facility
AND fac.active_ind = 1
AND fac.end_effective_dt_tm > SYSDATE
AND fac_bld.parent_loc_cd = fac.location_cd
AND fac_bld.root_loc_cd = 0
AND fac_bld.active_ind = 1
AND fac_bld.end_effective_dt_tm > SYSDATE
AND fac_bld.child_loc_cd = bld_unit.parent_loc_cd
AND bld_unit.root_loc_cd = 0
AND bld_unit.active_ind = 1
AND bld_unit.end_effective_dt_tm > SYSDATE
AND bld_unit.child_loc_cd = unit.location_cd
AND unit.location_type_cd IN (772, 794) ;ambulatory, nurse unit
AND unit.active_ind = 1
AND unit.end_effective_dt_tm > SYSDATE
WITH
SQLTYPE("f8","f8","f8","f8","i4")
) loc )
,(LEFT JOIN ENCOUNTER e ON loc.nurse_unit_cd = e.loc_nurse_unit_cd
AND e.active_ind = 1
AND e.end_effective_dt_tm > SYSDATE
AND e.reg_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
)
PLAN loc
JOIN e
GROUP BY loc.facility_cd, loc.building_cd, loc.nurse_unit_cd,
loc.nurse_unit_age, loc.nurse_unit_cd, loc.location_type_cd
ORDER BY facility, building, nurse_unit
/* Med orders
by position - USE CASE from Cara Lee
 Let me tell you the issue - non RNs have been
assigned the Ambulatory RN position (across the Enterprise). The risk
 associated with this is that the Ambulatory
RN position has the ability to order medications via clinical algorithm to
include
 most meds in the catalog in addition to
immunizations. The rationale that sites have used is that the Amb LPN cannot
order
 immunizations via clinical algorithm - thus
cannot be documented by the LPN until the provider signs the order - because
 they have a closed medication catalog,
allowing only proposed ordering for meds. I want to evaluate the volume of non
rn
 users that are ordering meds OTHER than
immunizations to determine if there is an issue or not. It helps paint the
picture
 to the MTF Command the level of risk they are
taking by assigning positions in this manner. */
ELSEIF($rpt =
"Med orders by position *")
facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,building = UAR_GET_CODE_DISPLAY(e.loc_building_cd)
,nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
,med_type =
IF(cve.field_value = "1") "Immunization"
ELSE "Medication"
ENDIF
,comms_type = UAR_GET_CODE_DISPLAY(o.latest_communication_type_cd)
,order_entry_position = UAR_GET_CODE_DISPLAY(order_enter.position_cd)
,personnel = order_enter.name_full_formatted
,order_enter.physician_ind
,edipi = edipi.alias
,orders_placed = COUNT(DISTINCT o.order_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date)
"MM/DD/YYYY;;d"
FROM ENCOUNTER e
,ORDERS o
,(LEFT JOIN CODE_VALUE_EXTENSION cve
ON o.catalog_cd = cve.code_value
AND cve.code_set = 200
AND cve.field_name = "IMMUNIZATIONIND")
,ORDER_ACTION oa
,PRSNL order_enter
,PRSNL_ALIAS edipi
PLAN e WHERE EXPAND(fac_idx, 1, size(fac->list, 5),
e.loc_facility_cd, fac->list[fac_idx].location_cd)
AND e.active_ind = 1
AND e.end_effective_dt_tm > SYSDATE
JOIN o WHERE e.encntr_id = o.encntr_id
AND o.activity_type_cd = 705 ;Pharmacy
AND o.order_status_cd IN (2543) ;completed
AND o.orig_order_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND o.active_ind = 1
JOIN oa WHERE o.order_id = oa.order_id AND oa.action_type_cd = 2534
JOIN order_enter WHERE oa.action_personnel_id = order_enter.person_id
JOIN edipi WHERE order_enter.person_id = edipi.person_id
AND edipi.alias_pool_cd = 106935631 ;EDIPI
AND edipi.active_ind = 1
AND edipi.end_effective_dt_tm > SYSDATE
JOIN cve
GROUP BY
e.loc_facility_cd, e.loc_building_cd, e.loc_nurse_unit_cd,
cve.field_value, o.latest_communication_type_cd,
order_enter.position_cd,
order_enter.name_full_formatted, order_enter.physician_ind, edipi.alias
ORDER BY facility, building, nurse_unit, med_type, comms_type,
order_entry_position
ELSEIF($rpt =
"Order catalog")
facility =
IF(ofr.facility_cd = 0) "<All facility access>"
ELSE UAR_GET_CODE_DISPLAY(ofr.facility_cd)
ENDIF
,orderable = oc.description
,ocs.mnemonic
,mnemonic_type = UAR_GET_CODE_DISPLAY(ocs.mnemonic_type_cd)
,catalog_type = UAR_GET_CODE_DISPLAY(oc.catalog_type_cd)
,activity_type = UAR_GET_CODE_DISPLAY(oc.activity_type_cd)
,activity_subtype = UAR_GET_CODE_DISPLAY(oc.activity_subtype_cd)
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
,HIDE_FLAG = IF(ocs.hide_flag = 0) "show synonym" ELSE
"hide synonym" ENDIF
,oefmt.oe_format_name
,ocs.catalog_cd
,ocs.oe_format_id
,last_updated = ocs.updt_dt_tm "YYYY-MM-DD;;d"
,updater = p.name_full_formatted
,updater_position = UAR_GET_CODE_DISPLAY(p.position_cd)
,updater_username = p.username
,updater_email = p.email
FROM LOCATION fac
,OCS_FACILITY_R ofr
,(LEFT JOIN CUST_LOC_AGENCY_RELTN ag ON ofr.facility_cd =
ag.location_cd AND ag.validated_ind = 1)
,ORDER_CATALOG_SYNONYM ocs
,ORDER_CATALOG oc
,ORDER_ENTRY_FORMAT oefmt
,PRSNL p
         PLAN
fac WHERE fac.organization_id = $facility
AND fac.location_type_cd = 783 ;facility
AND fac.active_ind = 1
AND fac.end_effective_dt_tm > SYSDATE
JOIN ofr WHERE fac.location_cd = ofr.facility_cd OR ofr.facility_cd = 0
JOIN ocs WHERE ofr.synonym_id = ocs.synonym_id
AND ocs.active_ind = 1
JOIN oc WHERE ocs.catalog_cd = oc.catalog_cd
AND oc.active_ind = 1
JOIN oefmt WHERE oc.oe_format_id = oefmt.oe_format_id
AND oefmt.action_type_cd = 2534 ;order
JOIN p WHERE ocs.updt_id = p.person_id
JOIN ag
ORDER BY facility, catalog_type, activity_type, activity_subtype,
orderable, mnemonic_type, ocs.mnemonic
ELSEIF($rpt =
"Personnel (DOD, assigned or predicted)")
personnel = p.name_full_formatted
,position = UAR_GET_CODE_DISPLAY(p.position_cd)
,assigned_facility = UAR_GET_CODE_DESCRIPTION(p_loc.assigned_fac_cd)
,assigned_location =
UAR_GET_CODE_DISPLAY(p_loc.assigned_loc_cd)
,predicted_facility = UAR_GET_CODE_DESCRIPTION(p_loc.predicted_fac_cd)
,predicted_location = UAR_GET_CODE_DISPLAY(p_loc.predicted_loc_cd)
,facility_match =
IF(p_loc.assigned_fac_cd = p_loc.predicted_fac_cd) "YES"
ELSE "NO"
ENDIF
,location_match =
IF(p_loc.assigned_loc_cd = p_loc.predicted_loc_cd) "YES"
ELSE "NO"
ENDIF
,p_loc.eval_beg_dt_tm "MM/DD/YYYY HH:MM;;q"
,p_loc.eval_end_dt_tm "MM/DD/YYYY HH:MM;;q"
,prediction_method = p_loc.method_used
,p_loc.method_hits
,p_loc.message
,p_loc.updt_dt_tm "MM/DD/YYYY HH:MM;;q"
,p_loc.manual_assign_dt_tm "MM/DD/YYYY HH:MM;;q"
,manual_assign_prsnl = p2.name_full_formatted
,p_loc.person_id
,p_loc.username
,p.physician_ind
,p_loc.machine_name
;,p_loc.inactive_person_ind
FROM LOCATION fac
,CUST_DOD_PRSNL_LOC_RELTN p_loc
,(LEFT JOIN PRSNL p2 ON p2.person_id = p_loc.manual_assign_updt_id)
,PRSNL p
PLAN fac WHERE fac.organization_id = $facility
AND fac.location_type_cd = 783 ;facility
AND fac.active_ind = 1
AND fac.end_effective_dt_tm > SYSDATE
JOIN p_loc WHERE 1=1
AND (fac.location_cd = p_loc.predicted_fac_cd
OR fac.location_cd =
p_loc.assigned_fac_cd)
JOIN p WHERE p_loc.person_id = p.person_id
AND p.active_ind = 1
AND p.end_effective_dt_tm > SYSDATE
JOIN p2
ORDER BY CNVTUPPER(p.name_full_formatted)
ELSEIF($rpt =
"Personnel groups")
DISTINCT
facility = org.org_name
,personnel_group = pg.prsnl_group_name
,personnel = p.name_full_formatted
,edipi = edipi.alias
,position = UAR_GET_CODE_DISPLAY(p.position_cd)
,p.physician_ind
;        ,npi
= npi.alias
;        ,tax.taxonomy
;        ,classification
= UAR_GET_CODE_DISPLAY(tax.classification_cd)
;        ,provider_type
= UAR_GET_CODE_DISPLAY(tax.provider_type_cd)
;        ,specialization
=
UAR_GET_CODE_DISPLAY(tax.specialization_cd)
FROM PRSNL_GROUP_ORG_RELTN pgor
,ORGANIZATION org
,PRSNL_GROUP pg
,PRSNL_GROUP_RELTN pgr
,PRSNL p
,(LEFT JOIN PRSNL_ALIAS edipi ON p.person_id = edipi.person_id
AND edipi.prsnl_alias_type_cd = 685806
AND edipi.active_ind = 1
AND edipi.end_effective_dt_tm > SYSDATE)
;                ,(LEFT
JOIN PRSNL_ALIAS npi ON npi.person_id = p.person_id
;                        AND
npi.prsnl_alias_type_cd = 4038127
;                        AND
npi.active_ind = 1
;                        AND
npi.end_effective_dt_tm > SYSDATE)
;                ,(LEFT
JOIN EEM_PROV_TAX_RELTN eptr ON eptr.parent_entity_id = p.person_id
;                        AND
eptr.active_ind = 1
;                        AND
eptr.end_effective_dt_tm > SYSDATE)
;                ,(LEFT
JOIN PROVIDER_TAXONOMY tax ON tax.taxonomy_id = eptr.taxonomy_id
;                        AND
tax.active_ind = 1)
PLAN pgor WHERE pgor.organization_id = $facility
JOIN org WHERE pgor.organization_id = org.organization_id
JOIN pg WHERE pgor.prsnl_group_id = pg.prsnl_group_id
AND pg.active_ind = 1
JOIN pgr WHERE pg.prsnl_group_id = pgr.prsnl_group_id
AND pgr.active_ind = 1
JOIN p WHERE pgr.person_id = p.person_id
AND p.active_ind = 1
JOIN edipi
;        JOIN
npi
;        JOIN
eptr
;        JOIN
tax
ORDER BY facility, personnel_group, personnel
ELSEIF($rpt =
"Phone numbers")
organization = org.org_name
,type = UAR_GET_CODE_DISPLAY(ph.phone_type_cd)
,phone_number_fmt = ph.phone_num_key "###-###-####"
,phone_number_raw = ph.phone_num
,format = UAR_GET_CODE_DISPLAY(ph.phone_format_cd)
,last_updated = ph.updt_dt_tm "MM/DD/YYYY HH:MM;;q"
,sequence = ph.phone_type_seq
,ph.phone_id
FROM PHONE ph
,ORGANIZATION org
PLAN ph WHERE ph.parent_entity_id = $facility
AND ph.parent_entity_name = "ORGANIZATION"
AND ph.end_effective_dt_tm > SYSDATE
AND ph.active_ind = 1
JOIN org WHERE org.organization_id = ph.parent_entity_id
ORDER BY org.org_name, type, sequence
ELSEIF($rpt =
"PowerForm usage *")
facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,building = UAR_GET_CODE_DISPLAY(e.loc_building_cd)
,nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
,powerform = dfa.description
,nbr_forms = COUNT(DISTINCT dfa.dcp_forms_activity_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
FROM ENCOUNTER e
,DCP_FORMS_ACTIVITY dfa
PLAN e WHERE EXPAND(fac_idx, 1, size(fac->list, 5),
e.loc_facility_cd, fac->list[fac_idx].location_cd)
AND e.reg_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND e.active_ind = 1
AND e.end_effective_dt_tm > SYSDATE
JOIN dfa WHERE e.encntr_id = dfa.encntr_id
AND dfa.active_ind = 1
GROUP BY e.loc_facility_cd, e.loc_building_cd, e.loc_nurse_unit_cd,
dfa.description
ORDER BY facility, building, nurse_unit, powerform
ELSEIF($rpt =
"PowerPlan catalog")
facility = UAR_GET_CODE_DISPLAY(flex.parent_entity_id)
,display_name = pc.display_description
,backend_description = pc.description
,plan_type = UAR_GET_CODE_DISPLAY(pc.pathway_type_cd)
,display_method = UAR_GET_CODE_DISPLAY(pc.display_method_cd)
,status =
IF(pc.beg_effective_dt_tm > SYSDATE) "Testing"
ELSE "Production"
ENDIF
,pc.version
,pc.beg_effective_dt_tm
,pc.end_effective_dt_tm
,structure =
IF(pc.type_mean = "PATHWAY") "Multiphase"
ELSEIF(pc.type_mean = "CAREPLAN") "Single phase"
ELSEIF(pc.type_mean = "SUBPHASE") "Subphase"
ELSE pc.type_mean
ENDIF
,sub_phase =
EVALUATE(pc.sub_phase_ind,0,"No",1,"Yes")
,diagnosis_propagation =
EVALUATE(pc.diagnosis_capture_ind,0,"No",1,"Yes")
,hide_flexed =
EVALUATE(pc.hide_flexed_comp_ind,0,"No",1,"Yes")
,cycle_settings =
EVALUATE(pc.cycle_ind,0,"No",1,"Yes")
,default_view =
IF (pc.default_view_mean = "CHEMOREV") "Chemotherapy
Review"
ELSEIF (pc.default_view_mean is null) "None"
ENDIF
,prompt_for_provider =
EVALUATE(pc.provider_prompt_ind,0,"No",1,"Yes")
,copy_forward =
EVALUATE(pc.cross_encntr_ind,0,"No",1,"Yes")
,alerts_planning =
EVALUATE(pc.alerts_on_plan_ind,0,"No",1,"Yes")
,alert_plan_updt =
EVALUATE(pc.alerts_on_plan_upd_ind,0,"No",1,"Yes")
,classification = UAR_GET_CODE_DISPLAY(pc.pathway_class_cd)
,route_for_review =
EVALUATE(pc.review_required_sig_count,0,"None",1,"One
signature",2,"Two signatures")
,resched_reason =
IF (pc.reschedule_reason_accept_flag=0) "Off"
ELSEIF (pc.reschedule_reason_accept_flag=1) "Optional"
ELSEIF (pc.reschedule_reason_accept_flag=2) "Required"
ENDIF
,restrictions =
IF(pc.restricted_actions_bitmask=0) "No restrictions"
ELSEIF(pc.restricted_actions_bitmask=1) "No proposing"
ELSEIF(pc.restricted_actions_bitmask=2) "No Favoriting"
ELSEIF(pc.restricted_actions_bitmask=3) "No proposing or
favoriting"
ENDIF
,override_missing_details =
EVALUATE(pc.override_mrd_on_plan_ind,0,"No",1,"Yes")
,last_updated = pc.updt_dt_tm "MM/DD/YYYY;;d"
,update_prsnl = p.name_full_formatted
FROM PW_CAT_FLEX flex
,PATHWAY_CATALOG pc
,PRSNL p
PLAN flex WHERE EXPAND(fac_idx, 1, size(fac->list, 5),
flex.parent_entity_id, fac->list[fac_idx].location_cd)
JOIN pc WHERE flex.pathway_catalog_id = pc.pathway_catalog_id
AND pc.active_ind = 1
AND pc.type_mean NOT IN ("PHASE","DOT")
JOIN p WHERE p.person_id = pc.updt_id
ORDER BY facility, pc.description, pc.display_description
ELSEIF($rpt =
"PowerPlan usage *")
facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,building = UAR_GET_CODE_DISPLAY(e.loc_building_cd)
,nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
,powerplan = pc.description
,p.pathway_catalog_id
,nbr_ordered = COUNT(DISTINCT p.pathway_id)
,nbr_patients = COUNT(DISTINCT p.person_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date)
"MM/DD/YYYY;;d"
FROM ENCOUNTER e
,PATHWAY p
,PATHWAY_CATALOG pc
PLAN e WHERE EXPAND(fac_idx, 1, size(fac->list, 5),
e.loc_facility_cd, fac->list[fac_idx].location_cd)
AND e.active_ind = 1
JOIN p WHERE e.encntr_id = p.encntr_id
AND p.order_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND p.type_mean != "DOT"
AND p.active_ind = 1
JOIN pc WHERE p.pathway_catalog_id = pc.pathway_catalog_id
GROUP BY e.loc_facility_cd, e.loc_building_cd, e.loc_nurse_unit_cd,
pc.description, p.pathway_catalog_id
ORDER BY facility, building, nurse_unit, powerplan
ELSEIF($rpt =
"Prescriber configuration")
DISTINCT
prescribing_location = UAR_GET_CODE_DESCRIPTION(pr.parent_entity_id)
,personnel = p.name_full_formatted
,position = UAR_GET_CODE_DISPLAY(p.position_cd)
,p.physician_ind
,npi = CNVTUPPER(TRIM(npi.alias))
,dea = CNVTUPPER(TRIM(dea.alias))
,spi = CNVTUPPER(TRIM(spi.alias))
,active =
IF(ed.end_effective_dt_tm > SYSDATE AND ed.service_level_nbr > 0)
"Yes"
ELSE "No"
ENDIF
,eprescribe_start = ed.beg_effective_dt_tm "MM/DD/YYYY;;d"
,eprescribe_end = ed.end_effective_dt_tm "MM/DD/YYYY;;d"
,epcs_nominated = IF(ed.cs_nominator_id > 0) "Yes" ELSE
"No" ENDIF
,epcs_permitted = IF(ed.cs_approver_sig_txt != NULL) "Yes"
ELSE "No" ENDIF
;identifiers
,prsnl_id = p.person_id
FROM PRSNL_RELTN pr
,PRSNL p
,(LEFT JOIN PRSNL_ALIAS npi ON npi.person_id = p.person_id
AND npi.prsnl_alias_type_cd = 4038127 ;NPI
;AND TEXTLEN(TRIM(npi.alias)) = 10 ;excludes valid data with invalid
format
AND npi.end_effective_dt_tm > SYSDATE
AND npi.active_ind = 1)
,(LEFT JOIN PRSNL_ALIAS dea ON dea.person_id = p.person_id
AND dea.prsnl_alias_type_cd = 1084 ;DEA
;AND TEXTLEN(TRIM(dea.alias)) = 9 ;excludes valid data with invalid
format
AND dea.end_effective_dt_tm > SYSDATE
AND dea.active_ind =
1)
,PRSNL_RELTN pr
,EPRESCRIBE_DETAIL ed
,PRSNL_RELTN_CHILD prc
,PRSNL_ALIAS spi
PLAN pr WHERE EXPAND(fac_idx, 1, size(fac->list, 5),
pr.parent_entity_id, fac->list[fac_idx].location_cd)
AND pr.parent_entity_name = "LOCATION"
AND pr.reltn_type_cd = 19162988 ;ePrescribing Relationship
AND pr.active_ind = 1
JOIN p WHERE p.person_id = pr.person_id
AND p.active_ind = 1
JOIN ed WHERE ed.prsnl_reltn_id = pr.prsnl_reltn_id
AND ed.status_cd = 4053728 ;delivered (to SureScripts)
JOIN prc WHERE prc.prsnl_reltn_id = pr.prsnl_reltn_id
AND prc.parent_entity_name = "PRSNL_ALIAS"
JOIN spi WHERE spi.prsnl_alias_id = prc.parent_entity_id
AND spi.prsnl_alias_type_cd = 4045114 ;SureScripts Prescriber Index
AND spi.active_ind = 1
JOIN npi
JOIN dea
;ORDER BY prescribing_location, CNVTUPPER(p.name_full_formatted),
active DESC, TRIM(spi.alias), eprescribe_start
ORDER BY ;have to be specific because it triggers a Discern DISTINCT
function
prescribing_location
,CNVTUPPER(p.name_full_formatted)
,active DESC
,CNVTUPPER(TRIM(npi.alias))
,CNVTUPPER(TRIM(dea.alias))
,CNVTUPPER(TRIM(spi.alias))
,epcs_nominated
,epcs_permitted
,p.person_id
ELSEIF($rpt =
"Providers by medical service *")
facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,med_service = UAR_GET_CODE_DISPLAY(e.med_service_cd)
,provider = p.name_full_formatted
,position = UAR_GET_CODE_DISPLAY(p.position_cd)
,relationship = UAR_GET_CODE_DISPLAY(epr.encntr_prsnl_r_cd)
,nbr_encntrs = COUNT(DISTINCT e.encntr_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date)
"MM/DD/YYYY;;d"
FROM ENCOUNTER e
,ENCNTR_PRSNL_RELTN epr
,PRSNL p
PLAN e WHERE EXPAND(fac_idx, 1, size(fac->list, 5),
e.loc_facility_cd, fac->list[fac_idx].location_cd)
AND e.reg_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND e.med_service_cd > 0
AND e.active_ind = 1
AND e.end_effective_dt_tm > SYSDATE
JOIN epr WHERE e.encntr_id = epr.encntr_id
AND epr.active_ind = 1
JOIN p WHERE epr.prsnl_person_id = p.person_id
AND p.physician_ind = 1
GROUP BY e.loc_facility_cd, e.med_service_cd, p.name_full_formatted,
p.position_cd, epr.encntr_prsnl_r_cd
ORDER BY facility, med_service, provider, relationship
ELSEIF($rpt =
"Schedulable resources")
DISTINCT
nurse_unit = UAR_GET_CODE_DISPLAY(sal.location_cd)
,resource = UAR_GET_CODE_DISPLAY(sl_res.resource_cd)
,resource_type = EVALUATE(sr.res_type_flag,
1, "1-General",
2, "2-Personnel",
3, "3-Service Resource",
4, "4-Supply Chain",
5, "5-Other",
"Unknown")
,personnel = p.name_full_formatted
,sr.resource_cd
,p.person_id
FROM LOCATION loc
,SCH_APPT_LOC sal
,SCH_LIST_ROLE sl_role
,SCH_LIST_RES sl_res
,SCH_RESOURCE sr
,(LEFT JOIN PRSNL p ON p.person_id = sr.person_id
AND p.active_ind = 1)
PLAN loc WHERE loc.organization_id = $facility
AND loc.active_ind = 1
AND loc.end_effective_dt_tm > SYSDATE
JOIN sal WHERE sal.location_cd = loc.location_cd
AND sal.active_ind = 1
AND sal.end_effective_dt_tm > SYSDATE
AND sal.version_dt_tm > SYSDATE
JOIN sl_role WHERE sal.res_list_id = sl_role.res_list_id
AND sl_role.res_list_id > 0
AND sl_role.sch_role_cd != 4572 ;patient
AND sl_role.active_ind = 1
JOIN sl_res WHERE sl_role.list_role_id = sl_res.list_role_id
AND sl_res.active_ind = 1
JOIN sr WHERE sr.resource_cd = sl_res.resource_cd
AND CNVTUPPER(sr.mnemonic) != "ZZ*"
AND sr.active_ind = 1
AND sr.end_effective_dt_tm > SYSDATE
JOIN p
ORDER BY nurse_unit,
resource
ELSEIF($rpt =
"Test patient activity *")
facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,building = UAR_GET_CODE_DISPLAY(e.loc_building_cd)
,nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
,test_patient_category = IF(pi.value_cd > 0)
UAR_GET_CODE_DISPLAY(pi.value_cd) ELSE "Unassigned" ENDIF
,nbr_encntrs = COUNT(DISTINCT e.encntr_id)
,nbr_patients = COUNT(DISTINCT e.person_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date)
"MM/DD/YYYY;;d"
FROM ENCOUNTER e
,PERSON p
,(LEFT JOIN PERSON_INFO pi ON p.person_id = pi.person_id
AND pi.info_sub_type_cd = 2678703703
AND pi.active_ind = 1)
PLAN e WHERE EXPAND(fac_idx, 1, size(fac->list, 5),
e.loc_facility_cd, fac->list[fac_idx].location_cd)
AND e.disch_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND e.active_ind = 1
AND e.end_effective_dt_tm >
SYSDATE
JOIN p WHERE e.person_id = p.person_id
AND EXISTS(SELECT 1
FROM PERSON_INFO pi
WHERE pi.person_id = p.person_id
AND pi.info_sub_type_cd = 2678703703 ;test patient indicator
AND pi.value_cd != 2678703509 ;not a test patient
AND pi.active_ind = 1)
JOIN pi
GROUP BY e.loc_facility_cd, e.loc_building_cd, e.loc_nurse_unit_cd,
pi.value_cd
ORDER BY facility, building, nurse_unit, test_patient_category
ELSEIF($rpt =
"UICs seen by attending provider *")
facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,building = UAR_GET_CODE_DISPLAY(e.loc_building_cd)
,nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
,attending_provider = CONCAT(TRIM(p.name_full_formatted),"
(", TRIM(UAR_GET_CODE_DISPLAY(p.position_cd)), ")")
,assigned_unit = uic.alias
,nbr_patients = COUNT(DISTINCT e.person_id)
,nbr_encntrs = COUNT(DISTINCT epr.encntr_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
FROM ENCOUNTER e
,(LEFT JOIN PERSON_MILITARY pm ON e.person_id = pm.person_id
AND pm.active_ind = 1)
,(LEFT JOIN ORGANIZATION_ALIAS uic ON pm.assigned_unit_org_id =
uic.organization_id
AND uic.org_alias_type_cd = 1129 ;Employer Code
AND uic.active_ind = 1)
,ENCNTR_PRSNL_RELTN epr
,PRSNL p
PLAN e WHERE EXPAND(fac_idx, 1, size(fac->list, 5),
e.loc_facility_cd, fac->list[fac_idx].location_cd)
AND e.reg_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND e.active_ind = 1
AND e.end_effective_dt_tm > SYSDATE
JOIN epr WHERE e.encntr_id = epr.encntr_id
AND epr.encntr_prsnl_r_cd = 1119 ;attending provider
AND epr.active_ind = 1
JOIN p WHERE epr.prsnl_person_id = p.person_id
JOIN pm
JOIN uic
GROUP BY e.loc_facility_cd, e.loc_building_cd, e.loc_nurse_unit_cd,
 p.name_full_formatted,
p.position_cd, uic.alias
ORDER BY facility, building, nurse_unit,
attending_provider, assigned_unit
ELSEIF($rpt =
"Vaccines by encounter type *")
facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,building = UAR_GET_CODE_DISPLAY(e.loc_building_cd)
,nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
,encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
,vaccine = UAR_GET_CODE_DISPLAY(ce.event_cd)
,nbr_immunizations = COUNT(DISTINCT ce.event_id)
,nbr_patients = COUNT(DISTINCT ce.person_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date)
"MM/DD/YYYY;;d"
FROM ENCOUNTER e
,CLINICAL_EVENT ce
PLAN e WHERE EXPAND(fac_idx, 1, size(fac->list, 5),
e.loc_facility_cd, fac->list[fac_idx].location_cd)
AND e.reg_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND e.active_ind = 1
AND e.end_effective_dt_tm > SYSDATE
JOIN ce WHERE e.encntr_id = ce.encntr_id
AND ce.event_cd IN (SELECT event_cd FROM V500_EVENT_SET_EXPLODE WHERE
event_set_cd = 100919753) ;immunizations
AND ce.event_end_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND ce.result_status_cd NOT IN (28,29,30,31)
AND ce.view_level = 1
AND ce.valid_until_dt_tm > SYSDATE
GROUP BY e.loc_facility_cd, e.loc_building_cd, e.loc_nurse_unit_cd,
e.encntr_type_cd, ce.event_cd
ORDER BY facility, building, nurse_Unit, encntr_type,
vaccine
ENDIF
INTO $OUTDEV
error = "Unknown error occurred."
WITH
NOCOUNTER, SEPARATOR=" ", FORMAT, TIME=600, EXPAND=2, CHECK
end
go
