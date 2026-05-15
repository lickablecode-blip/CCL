/*
 * Source page  : Personnel Detail Audit
 * Source file  : output/personnel-detail-audit.md
 * Anchor       : (top of page)
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 2980
 *
 * Context (preceding paragraph):
 *   Exported: 9/2/25
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

drop program
dev_rpt_prsnl_detail_audit2 go
create
program dev_rpt_prsnl_detail_audit2
/******************************************************************************
 REPORT NAME:
        Personnel Detail Audit
 PROGRAM:                1fed_rpt_prsnl_detail_audit.prg
 DEVELOPER:        David Alt
(david.a.alt2.mil@health.mil)
 PUBLISHED:        Fall 2022
 SNAPSHOT:                12/10/2024
 LOGICAL
PATH:        cust_script:
 NODE:                        <default>
 PURPOSE/DESCRIPTION: Provides audits related to individual
personnel
 TARGET AUDIENCE:
          Personnel maintenance
          Credentialing
          Practice Management
          Providers
          Data Quality
MOD        DATE                DEVELOPER        COMMENT
---        --/--/--        ---------        ----------------------------
001        01/27/23        David
Alt        Added Diagnoses
002        01/30/23        David
Alt        Added Business Contact Info
                                                                 Added
Addresses
                                                                 Added
Phone Numbers
003        01/31/23        David
Alt        Added Report Usage
004        02/02/23        David
Alt        Added Documents (verified)
                                                                 Added
Documents (verified, but not authored)
005        02/07/23        David
Alt        Added Keychains
006        02/13/23        David
Alt        Added encntr_type to the
three Documents reports
007        02/14/23        David
Alt        Added Taxonomy
008        02/15/23        David
Alt        Added Scheduling - Templates
and Slots
009        03/07/23        David
Alt        Made personnel search
results distinct
                                                                 Updated
prompt instructions control
010        03/09/23        David
Alt        Renamed several reports for
clarity
                                                                 Saved
to FEHRM AGB naming convention
         011
03/16/23        David
Alt        Formatting standardization
         012        03/27/23        David
Alt        Added Proxies (historical)
         013        04/05/23        David
Alt        Added Reports and Queries
(JAZZ 571791)
                                                                 Renamed
Report Usage --> Report Usage (summary)
                                                                 Added
replace_CRLF subroutine
                                                                 Formatting
standardization
014        04/17/23        David
Alt        Fixed order truncation by
using ORDER_CATALOG instead of CODE_VALUE
015        07/19/23        David
Alt        Added Orders - Future (JAZZ
547907)
016        01/24/24        David
Alt        Removed *USER* filter from
personnel search
         017        12/12/23        David
Alt        Added Documents (scanned)
(validated Colleen Crowl/VA 6/12/24)
                                                                 Renamed
Orders - Owned --> Orders - Responsible
                                                                 Updated
sorting logic for Orders reports
         018
04/10/24        David
Alt        Renamed Application Login
History --> Application Interaction History
         019        04/24/24        David
Alt        Added Orders - Proposed To
         020        04/25/24        David
Alt        Added Positions
(MyExperience)
                                                                 Renamed
Roles --> Role Types (HNA User)
         021        05/10/24        David
Alt        Added security check to
prompt against privileged location personnel
         022        06/12/24        David
Alt        Removed encounter dependency
from Documents --> Scanned (RITM8910225)
         023        07/30/24        David
Alt        Added Orders - Unresulted
Labs
                                                                 Removed
old "Attending Relationships"
                                                                 Added
demographic details/changed col order in Encounter Relationships (attending)
                                                                 Added
demographic details/changed col order in Encounter Relationships (detail)
                                                                 Removed
"Schedule *" from prompt
         024        08/09/24        David
Alt        Modded Prescribing Locations
- added SPI aliases and relationship timing
Modded Service Resources to include organization, remove old location
field
025 08/16/24        David
Alt        Added template_order_flag
and order status output to Orders -
Entered/Responsible
026        11/20/24        David
Alt        Added facility, nurse unit
to Documents (authored/verified) reports
027        01/28/25        David
Alt        Renamed Patient Empanelment
--> Patient Empanelment (DoD)
         ---- unpublished ----
         028        05/30/25        David
Alt        Added "Encounter
relationships (interactive)"
         029        06/02/25        David
Alt        Updated/renamed Prescribing
Locations --> Prescribing Configuration
         030        06/03/25        David
Alt        Added business fax to
Business Contact Info
         031        06/04/25        David
Alt        Added counts to
"Documents (scanned)"
Changed date/time formatting in Aliases
032 06/10/25        David
Alt        Added "Results -
Patient Labs"
033        07/02/25        David
Alt        Renamed "Role
Type" --> "Role History (HNA User)"
Added "Role Assignment History (HNA User)"
044        07/22/25        David
Alt        Added "Order
Favorites"
Added "Location Associations (HNA User)"
045        07/23/25        David
Alt        Added "PowerPlan
Favorites"
046        08/13/25        David
Alt        Added special duty status to
Patient empanelment (DOD) - DHAINC03255212
047        08/18/25        David
Alt        Added "Results -
Unendorsed"
Added endorse_status to Results - Patient Labs
048        08/19/25        David
Alt        Prompt/program restructured
to support multiple listboxes
Renamed Positions (MyExperience) --> Roles Available (MyExperience);
new fields
Renamed Addresses --> Contact - Addresses
Renamed Business Contact Info --> Contact - Business
Renamed Phone Numbers --> Contact - Phones
Renamed Location assignments --> Work Locations; removed/renamed
fields
Renamed Role Assignment History (HNA User) --> Roles Assigned By
User
Renamed Role History (HNA User) --> Roles Assigned To User
Renamed Orders - Responsible --> Orders (summary)
Added Results - Unendorsed (interactive)
Renamed Orders - Tasks Completed --> Order Tasks Completed
Modded Application Access: new logic, removed a field
Modded Application Login History: renamed a field
Modded Clinical Events (performed): logic, removed many fields
Modded Clinical Events (verified): logic, removed many fields
Modded Documents (authored): logic, removed/renamed fields
Modded Orders - Future: added fields
Modded Orders - Proposed To: removed fields
Modded Patient Empanelment (DoD): added/removed fields
Modded Person Relationships: added/removed fields
Modded Personnel Groups: added field
Renamed Results - Patient Labs --> Results - Lab Orders, changed
fields
/**************************************************************
; DVDev
PROMPT BUILDER
**************************************************************/
prompt
"Output to File/Printer/MINE" = "MINE" ;* Enter or select
the printer or file name to send this repor
;<<hidden>>"Search Term (use * for wildcards) " =
"" ;* After
searching, click in the results to generate the list,
;<<hidden>>"Selected Personnel" = ""
, "Search for personnel, then select report type" = "search"
, "" = 0
, "Reports" = "" ;* Reports with an asterisk (*) will use the date time fields.
, "Reports" = ""
, "Begin Date" = "SYSDATE"
, "End Date" = "SYSDATE"
;<<hidden>>"Instructions" = ""
, "" = ""
with OUTDEV,
tab, prsnl, activity, config, beg_date, end_date, last_tab
/**************************************************************
; Global
Declarations / Includes
**************************************************************/
%I
cust_script:dalt_subroutines.inc
/**************************************************************
; Record
Structures
**************************************************************/
free record
myexp ;MyExperience
record myexp
(
1 pos[*]
2 position = c40
2 position_cd = f8
2 added_by = c200
2 added_on = dq8
1 pos_cnt = i4
) with
protect ;end myexp
free record
fav_fldr ;favorites folder structure
record
fav_fldr (
1 fldr[*]
2 folder_id = f8
2 folder = c500
2 parent_folder_id = f8
2 path = vc
) with
protect ;favorites folder structure
free record
fav ;favorites
record fav (
1 item[*]
; shared fields
2 fav_type = c7 ;"order" or "pathway"
2 path = vc
2 last_saved_dt_tm = dq8
2 last_ordered_dt_tm = dq8
; Orders
2 orderable = c100
2 order_mnemonic = c200
2 order_sentence = c255
2 catalog_type_cd = f8
2 activity_type_cd = f8
2 activity_subtype_cd = f8
2 order_active_ind = i2
2 synonym_active_ind = i2
2 catalog_cd = f8
2 synonym_id = f8
; PowerPlans
2 powerplan = c100
2 powerplan_cust = c100 ;user "favorited" name
2 plan_type = c10 ;"standard" or "customized"
2 version = i4
2 plan_active_ind = c3
2 cust_plan_active_ind = c3
2 pathway_catalog_id = f8
2 pathway_customized_plan_id = f8
1 fav_order_cnt = i4
1 fav_powerplan_cnt = id4
) with
protect ;favorites
/**************************************************************
; Subroutines
- Building the MyExperience list
**************************************************************/
; Extracts
the person_id from an EDIPI
subroutine
(get_prsnl_name_from_person_id(input=f8) = vc)
declare output = vc
         SELECT
INTO "NL:"
                 p.name_full_formatted
FROM PRSNL p
PLAN p WHERE p.person_id = input
detail
output = p.name_full_formatted
with nocounter
return (output)
end
;get_prsnl_name_from_person_id
; Get the
active position from the personnel
subroutine
(get_position_cd_from_person_id(input=f8) = f8)
declare output = f8
SELECT INTO "NL:"
p.position_cd
FROM PRSNL p
PLAN p WHERE p.person_id = input
detail
output = p.position_cd
with nocounter
return (output)
end
;get_position_cd_from_person_id
;Initialize
the MyExperience record
subroutine
(build_myexp(person_id = f8, position_cd = f8) = NULL)
SET myexp->pos_cnt = 0
CALL get_prsnl_role_positions(person_id)
CALL get_position_role_positions(position_cd)
;add current position
CALL ALTERLIST(myexp->pos, size(myexp->pos, 5) + 1)
SET myexp->pos[myexp->pos_cnt + 1].position =
UAR_GET_CODE_DISPLAY(prsnl_position)
SET myexp->pos[myexp->pos_cnt + 1].position_cd = prsnl_position
;de-duplicate not implemented - done with DISTINCT at the report layer
end
;build_myexp
;Get all
positions based on roles assigned in HNA User
subroutine
(get_prsnl_role_positions(input = f8) = NULL)
SELECT INTO "NL:"
FROM PRSNL_ROLE_TYPE prt
,ROLE_TYPE_RELTN rtr
,CODE_VALUE_EXTENSION cve
,POSITION_ROLE_TYPE prt2
,PRSNL p
PLAN prt WHERE prt.person_id = input
AND prt.end_effective_dt_tm > SYSDATE
AND prt.active_ind = 1
JOIN rtr WHERE rtr.role_type_reltn_id =
prt.role_type_reltn_id
JOIN cve WHERE cve.code_value = rtr.role_type_cd
AND cve.code_set = 343575
AND cve.field_name = "AVAILABLE_POSITION_IND"
AND cve.field_value != "1" ;role types available in HNA User
JOIN prt2 WHERE prt2.role_type_cd = rtr.role_type_cd
AND prt2.end_effective_dt_tm > SYSDATE
AND prt2.active_ind = 1
JOIN p WHERE p.person_id = prt.updt_id
HEAD REPORT
i = 0
DETAIL
i += 1
CALL ALTERLIST(myexp->pos, i)
myexp->pos[i].position = UAR_GET_CODE_DISPLAY(prt2.position_cd)
myexp->pos[i].position_cd = prt2.position_cd
myexp->pos[i].added_by = EVALUATE2(
IF(p.position_cd != 0)
BUILD(p.name_full_formatted, " (",
TRIM(UAR_GET_CODE_DISPLAY(p.position_cd)), ")")
ELSE p.name_full_formatted
ENDIF)
myexp->pos[i].added_on = prt.updt_dt_tm
myexp->pos_cnt += 1
end
;get_prsnl_role_positions
;Get all
positions based on roles associated with current position
;This is used
when roles aren't specifically granted in HNA User
subroutine
(get_position_role_positions(input = f8) = NULL)
SELECT INTO "NL:"
FROM POSITION_ROLE_TYPE prt ;get role type associated with active
position
,POSITION_ROLE_TYPE prt2 ;get other positions associated with role type
,CODE_VALUE_EXTENSION cve ;limit to roles not available in HNA User
PLAN prt WHERE prt.position_cd = input
AND prt.active_ind = 1
AND prt.beg_effective_dt_tm < SYSDATE
AND prt.end_effective_dt_tm > SYSDATE
JOIN prt2 WHERE prt2.role_type_cd = prt.role_type_cd
AND prt2.active_ind = 1
AND prt2.beg_effective_dt_tm < SYSDATE
AND prt2.end_effective_dt_tm > SYSDATE
JOIN cve WHERE cve.code_value = prt.role_type_cd
AND cve.code_set = 343575
AND cve.field_name = "AVAILABLE_POSITION_IND"
AND cve.field_value = "1" ;role types not available in HNA
User
HEAD REPORT
i = myexp->pos_cnt
DETAIL
i += 1
CALL ALTERLIST(myexp->pos, i)
myexp->pos[i].position = UAR_GET_CODE_DISPLAY(prt2.position_cd)
myexp->pos[i].position_cd = prt2.position_cd
myexp->pos_cnt += 1
end
;get_position_role_positions
/**************************************************************
; Subroutines
- Building the Favorites List
**************************************************************/
;Step 1 of
building the favorites list
subroutine
(build_folder_list(prsnl_id) = NULL)
SELECT INTO "NL:"
FROM ALT_SEL_CAT fldr
PLAN fldr WHERE fldr.owner_id = prsnl_id
ORDER BY fldr.alt_sel_category_id
HEAD REPORT
i = 0
DETAIL
i += 1
CALL ALTERLIST(fav_fldr->fldr, i)
fav_fldr->fldr[i].folder_id = fldr.alt_sel_category_id
fav_fldr->fldr[i].folder = TRIM(fldr.short_description, 3)
fav_fldr->fldr[i].path = ""
 WITH NULLREPORT
end
;build_folder_list
;Step 2 of
building the favorites list
subroutine(get_parent_folders(NULL)
= NULL)
declare fldr_cnt = i4 with protect, constant(size(fav_fldr->fldr,
5))
declare pos = i4 with protect, noconstant(0)
declare idx = i4 with noconstant(0) ;index for EXPAND or FOR loop
SELECT INTO "NL:"
FROM ALT_SEL_LIST asl
PLAN asl WHERE EXPAND(idx, 1,
fldr_cnt,        asl.child_alt_sel_cat_id,
fav_fldr->fldr[idx].folder_id)
ORDER BY asl.alt_sel_category_id
DETAIL
pos = LOCATEVAL(idx, 1, fldr_cnt, asl.child_alt_sel_cat_id,
fav_fldr->fldr[idx].folder_id)
fav_fldr->fldr[pos].parent_folder_id = asl.alt_sel_category_id
WITH NULLREPORT
end
;get_parent_folders
;Step 3 of
building the favorites list
subroutine(get_path(alt_sel_cat_id
= f8) = vc)
declare fldr_cnt = i4 with protect, constant(size(fav_fldr->fldr,
5))
declare pos = i4 with protect, noconstant(0)
declare idx = i4 with protect, noconstant(0)
declare folder_id = f8 with protect, noconstant(0)
declare parent_id = f8 with protect, noconstant(0)
declare is_root = i2 with protect, noconstant(0)
declare path = vc with protect, noconstant("")
set folder_id = alt_sel_cat_id
set parent_id = fav_fldr->fldr[LOCATEVAL(pos, 1, fldr_cnt,
folder_id, fav_fldr->fldr[pos].folder_id)].parent_folder_id
set is_root = EVALUATE2(IF(parent_id = 0) 1 ELSE 0 ENDIF)
set path = fav_fldr->fldr[LOCATEVAL(pos, 1, fldr_cnt, folder_id,
fav_fldr->fldr[pos].folder_id)].folder
while (is_root = 0) ;not the parent folder
if (parent_id = 0)
set is_root = 1 ;reached the parent, time to stop
else
;find the index of the parent folder
set pos = LOCATEVAL(idx, 1, fldr_cnt, parent_id,
fav_fldr->fldr[idx].folder_id)
if (pos > 0) ;we located the parent folder in the record
set path = BUILD(fav_fldr->fldr[pos].folder, "/", path)
set parent_id = fav_fldr->fldr[pos].parent_folder_id ;update
parent_id to the parent's parent folder_id
endif
endif
endwhile
return (path)
end ;get_path
;Step 4 of
building the favorites list
subroutine(add_paths(NULL)
= NULL)
declare fldr_cnt = i4 with protect, constant(size(fav_fldr->fldr,
5))
declare i = i4 with protect, noconstant(0)
for (i = 1 to fldr_cnt)
set fav_fldr->fldr[i].path =
get_path(fav_fldr->fldr[i].folder_id)
endfor
end
;add_paths
;Step 5 of
building the favorites list
subroutine(build_favorite_list(NULL)
= NULL)
declare fldr_cnt = i4 with protect, constant(size(fav_fldr->fldr,
5))
declare pos = i4 with protect, noconstant(0)
declare idx = i4 with protect,
noconstant(0)
set fav->fav_order_cnt = 0
set fav->fav_powerplan_cnt = 0
; add order favorites and standard powerplans
SELECT INTO "NL:"
FROM ALT_SEL_CAT cat
,ALT_SEL_LIST item
,(LEFT JOIN ORDER_CATALOG_SYNONYM ocs ON ocs.synonym_id =
item.synonym_id)
,(LEFT JOIN ORDER_CATALOG oc ON oc.catalog_cd = ocs.catalog_cd)
,(LEFT JOIN ORDER_SENTENCE os ON os.order_sentence_id =
ocs.order_sentence_id)
,(LEFT JOIN PATHWAY_CATALOG pc ON pc.pathway_catalog_id =
item.pathway_catalog_id)
PLAN cat WHERE cat.owner_id = $prsnl
JOIN item WHERE item.alt_sel_category_id = cat.alt_sel_category_id
AND item.list_type != 1 ;exclude items that are subfolders
JOIN ocs
JOIN oc
JOIN os
JOIN pc
HEAD REPORT
i = 0
DETAIL
i += 1
CALL ALTERLIST(fav->item, i)
pos = LOCATEVAL(idx, 1, fldr_cnt, item.alt_sel_category_id,
fav_fldr->fldr[idx].folder_id)
fav->item[i].path = fav_fldr->fldr[pos].path
fav->item[i].last_saved_dt_tm = item.updt_dt_tm
IF(item.synonym_id != 0)
fav->fav_order_cnt += 1
fav->item[i].fav_type = "order"
fav->item[i].orderable = oc.description
fav->item[i].order_mnemonic = ocs.mnemonic
fav->item[i].order_sentence = TRIM(os.order_sentence_display_line,3)
fav->item[i].catalog_type_cd = oc.catalog_type_cd
fav->item[i].activity_type_cd = oc.activity_type_cd
fav->item[i].activity_subtype_cd = oc.activity_subtype_cd
fav->item[i].order_active_ind = oc.active_ind
fav->item[i].synonym_active_ind = ocs.active_ind
fav->item[i].catalog_cd = oc.catalog_cd
fav->item[i].synonym_id = ocs.synonym_id
ELSEIF(item.pathway_catalog_id != 0)
fav->fav_powerplan_cnt += 1
fav->item[i].fav_type = "pathway"
fav->item[i].powerplan = pc.description
fav->item[i].plan_type = "standard"
;fav->item[i].powerplan_cust = pcp.plan_name
fav->item[i].version = pc.version
fav->item[i].plan_active_ind = CNVTSTRING(pc.active_ind)
fav->item[i].cust_plan_active_ind = "n/a"
fav->item[i].pathway_catalog_id = pc.pathway_catalog_id
;fav->item[i].pathway_customized_plan_id =
pcp.pathway_customized_plan_id
ENDIF
WITH NULLREPORT
; add customized powerplans
SELECT INTO "NL:"
FROM PATHWAY_CUSTOMIZED_PLAN pcp
,PATHWAY_CATALOG pc
PLAN pcp WHERE pcp.prsnl_id = $prsnl
JOIN pc WHERE pc.pathway_catalog_id = pcp.pathway_catalog_id
HEAD REPORT
i = value(size(fav->item, 5))
DETAIL
i += 1
CALL ALTERLIST(fav->item, i)
fav->fav_powerplan_cnt += 1
fav->item[i].path = "My Favorite Plans"
fav->item[i].last_saved_dt_tm = pcp.updt_dt_tm
fav->item[i].fav_type = "pathway"
fav->item[i].powerplan = pc.description
fav->item[i].plan_type = "customized"
fav->item[i].powerplan_cust = pcp.plan_name
fav->item[i].version = pc.version
fav->item[i].plan_active_ind = CNVTSTRING(pc.active_ind)
fav->item[i].cust_plan_active_ind = CNVTSTRING(pcp.active_ind)
fav->item[i].pathway_catalog_id = pc.pathway_catalog_id
fav->item[i].pathway_customized_plan_id =
pcp.pathway_customized_plan_id
WITH NULLREPORT
end
;build_favorite_list
subroutine(get_powerplan_last_ordered(NULL)
= NULL)
DECLARE idx = i4 WITH protect, noconstant(0)
DECLARE num = i4 WITH protect, noconstant(0)
DECLARE pos = i4 WITH protect, noconstant(0)
SELECT INTO "NL:"
p.pathway_catalog_id
,pcp.pathway_customized_plan_id
,last_ordered_dt_tm = MAX(pa.action_dt_tm); "MM/DD/YYYY;;d"
FROM PATHWAY p
 ,(LEFT JOIN
PATHWAY_CUSTOMIZED_PLAN pcp ON pcp.pathway_catalog_id = p.pathway_catalog_id
 AND pcp.prsnl_id =
$prsnl)
 ,PATHWAY_ACTION pa
PLAN p WHERE EXPAND(idx, 1, size(fav->item, 5),
p.pathway_catalog_id, fav->item[idx].pathway_catalog_id)
JOIN pa WHERE pa.pathway_id = p.pathway_id
 AND pa.action_prsnl_id =
$prsnl
 AND pa.action_type_cd = 10752
;order
JOIN pcp
GROUP BY p.pathway_catalog_id, pcp.pathway_customized_plan_id
ORDER BY p.pathway_catalog_id, pcp.pathway_customized_plan_id
DETAIL
;For each combination of pathway_catalog_id and
pathway_customized_plan_id,
;look up the corresponding record and assign last_ordered_dt_tm
pos = LOCATEVAL(num, 1, size(fav->item, 5), p.pathway_catalog_id,
fav->item[num].pathway_catalog_id)
IF(pos != 0 AND fav->item[pos].pathway_customized_plan_id =
pcp.pathway_customized_plan_id)
fav->item[pos].last_ordered_dt_tm = last_ordered_dt_tm
;MAX(pa.action_dt_tm);
ENDIF
WITH NULLREPORT
end
;get_powerplan_last_ordered
;Convenience
routine for building the order favorites list
subroutine(build_favorites(prsnl_id
= f8) = NULL)
CALL build_folder_list(prsnl_id)
CALL get_parent_folders(NULL)
CALL add_paths(NULL)
CALL build_favorite_list(NULL)
IF(fav->fav_powerplan_cnt != 0)
CALL get_powerplan_last_ordered(NULL)
ENDIF
end
;build_favorites
/**************************************************************
; Main
**************************************************************/
SET
prsnl_name = get_prsnl_name_from_person_id($prsnl)
SET
prsnl_position = get_position_cd_from_person_id($prsnl)
IF($prsnl !=
0 AND $tab = "config"
AND $config IN ("Order Favorites", "PowerPlan
Favorites"))
CALL build_favorites($prsnl)
ENDIF
IF($prsnl !=
0 AND $tab = "config"
AND $config IN ("Application Access", "Roles Available
(MyExperience)"))
CALL build_myexp($prsnl, prsnl_position)
ENDIF
/**************************************************************
; Error
Handling
**************************************************************/
SELECT
IF($prsnl =
0)
error = "No personnel selected."
ELSEIF($activity
= "" AND $config = "")
error = "No report selected."
/**************************************************************
; Activity
Reports
**************************************************************/
ELSEIF($last_tab
= "activity" AND $activity = "Application Login History")
personnel = prsnl_name
,application = a.description
,date = d.start_day "MM/DD/YYYY;;d"
,interactions = d.log_ins
FROM OMF_APP_CTX_DAY_ST d
,APPLICATION a
PLAN d WHERE d.person_id = $prsnl
AND d.start_day BETWEEN CNVTDATETIME($beg_date) AND
CNVTDATETIME($end_date)
JOIN a WHERE d.application_number = a.application_number
ORDER BY d.start_day DESC, application
ELSEIF($last_tab
= "activity" AND $activity = "Clinical Events (performed)")
fin = fin.alias
,event = UAR_GET_CODE_DISPLAY(ce.event_cd)
,ce.event_tag
,event_dt_tm = DATETIMEZONEFORMAT(ce.event_end_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
,performed_dt_tm = DATETIMEZONEFORMAT(ce.performed_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
,verified_dt_tm = DATETIMEZONEFORMAT(ce.verified_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
,verifying_prsnl = veri_p.name_full_formatted
,contrib_sys = UAR_GET_CODE_DISPLAY(ce.contributor_system_cd)
,entry_mode = UAR_GET_CODE_DISPLAY(ce.entry_mode_cd)
,event_class = UAR_GET_CODE_DISPLAY(ce.event_class_cd)
,ce.event_id
FROM CLINICAL_EVENT ce
,(LEFT JOIN ORDER_CATALOG oc ON ce.catalog_cd = oc.catalog_cd)
,(LEFT JOIN PRSNL veri_p ON ce.verified_prsnl_id = veri_p.person_id)
,ENCOUNTER e
,(LEFT JOIN TIME_ZONE_R tz ON tz.parent_entity_id = e.loc_facility_cd
AND tz.parent_entity_name = "LOCATION")
,ENCNTR_ALIAS fin
PLAN ce WHERE ce.performed_prsnl_id = $prsnl
AND ce.performed_dt_tm BETWEEN CNVTDATETIME($beg_date) AND
CNVTDATETIME($end_date)
AND (ce.view_level = 1 OR ce.entry_mode_cd = 679378) ;working view
AND ce.valid_until_dt_tm > SYSDATE
AND ce.result_status_cd NOT IN (28,29,30,31) ;IN ERROR
JOIN e WHERE e.encntr_id = ce.encntr_id
JOIN fin WHERE fin.encntr_id = e.encntr_id
AND fin.encntr_alias_type_cd = 1077 ;FIN
AND fin.end_effective_dt_tm > SYSDATE
AND fin.active_ind = 1
JOIN oc
JOIN veri_p
JOIN tz
ORDER BY fin, event
ELSEIF($last_tab
= "activity" AND $activity = "Clinical Events (verified)")
fin = fin.alias
,event = UAR_GET_CODE_DISPLAY(ce.event_cd)
,ce.event_tag
,event_dt_tm = DATETIMEZONEFORMAT(ce.event_end_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
,performed_dt_tm = DATETIMEZONEFORMAT(ce.performed_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
,verified_dt_tm = DATETIMEZONEFORMAT(ce.verified_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
,performing_prsnl = perf_p.name_full_formatted
,contrib_sys = UAR_GET_CODE_DISPLAY(ce.contributor_system_cd)
,entry_mode = UAR_GET_CODE_DISPLAY(ce.entry_mode_cd)
,event_class = UAR_GET_CODE_DISPLAY(ce.event_class_cd)
,ce.event_id
FROM CLINICAL_EVENT ce
,(LEFT JOIN ORDER_CATALOG oc ON ce.catalog_cd = oc.catalog_cd)
,(LEFT JOIN PRSNL perf_p ON ce.performed_prsnl_id = perf_p.person_id)
,ENCOUNTER e
,(LEFT JOIN TIME_ZONE_R tz ON tz.parent_entity_id = e.loc_facility_cd
AND tz.parent_entity_name = "LOCATION")
,ENCNTR_ALIAS fin
PLAN ce WHERE ce.verified_prsnl_id = $prsnl
AND ce.performed_dt_tm BETWEEN CNVTDATETIME($beg_date) AND
CNVTDATETIME($end_date)
AND (ce.view_level = 1 OR ce.entry_mode_cd = 679378) ;working view
AND ce.valid_until_dt_tm > SYSDATE
AND ce.result_status_cd NOT IN (28,29,30,31) ;IN ERROR
JOIN e WHERE e.encntr_id = ce.encntr_id
JOIN fin WHERE fin.encntr_id = e.encntr_id
AND fin.encntr_alias_type_cd = 1077 ;FIN
AND fin.end_effective_dt_tm > SYSDATE
AND fin.active_ind = 1
JOIN oc
JOIN perf_p
JOIN tz
ORDER BY fin, event
ELSEIF($last_tab
= "activity" AND $activity = "Diagnoses (charted)")
personnel = prsnl_name
,diagnosis = n.source_string
,code = PIECE(n.concept_cki,"!",2,"parse error")
,diag_type = UAR_GET_CODE_DISPLAY(d.diag_type_cd)
,nbr_encntrs = COUNT(DISTINCT d.encntr_id)
,nbr_patients = COUNT(DISTINCT d.person_id)
,start_range = CNVTDATETIME($beg_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
FROM DIAGNOSIS d
,NOMENCLATURE n
PLAN d WHERE d.diag_prsnl_id = $prsnl
AND d.diag_dt_tm BETWEEN CNVTDATETIME($beg_date) AND
CNVTDATETIME($end_date)
AND d.end_effective_dt_tm > SYSDATE
AND d.active_ind = 1
JOIN n WHERE d.nomenclature_id = n.nomenclature_id
GROUP BY prsnl_name, n.source_string, n.concept_cki, d.diag_type_cd
ORDER BY diagnosis, diag_type
ELSEIF($last_tab
= "activity" AND $activity = "Documents (authored)")
fin = fin.alias
,e.reg_dt_tm
,facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
,encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
,note_type = UAR_GET_CODE_DISPLAY(ce.event_cd)
,note_title = ce.event_title_text
,note_status = UAR_GET_CODE_DISPLAY(ce.result_status_cd)
,performed_dt_tm = DATETIMEZONEFORMAT(ce.performed_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
,verified_dt_tm = DATETIMEZONEFORMAT(ce.verified_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY
HH:MM;;q")
,author = perf_p.name_full_formatted
,verifying_prsnl = veri_p.name_full_formatted
,note_class_loinc = class_loinc.alias
,note_type_loinc = type_loinc.alias
,contrib_sys = UAR_GET_CODE_DISPLAY(ce.contributor_system_cd)
,entry_mode = UAR_GET_CODE_DISPLAY(ce.entry_mode_cd)
,event_class = UAR_GET_CODE_DISPLAY(ce.event_class_cd)
,ce.event_id
FROM
CLINICAL_EVENT ce
,(LEFT JOIN PRSNL perf_p ON ce.performed_prsnl_id = perf_p.person_id)
,(LEFT JOIN PRSNL veri_p ON ce.verified_prsnl_id = veri_p.person_id)
,(LEFT JOIN CODE_VALUE_OUTBOUND class_loinc ON ce.event_cd =
class_loinc.code_value
AND class_loinc.contributor_source_cd = 18024137 ;LOINC
AND class_loinc.alias_type_meaning = "CLASSCODE")
,(LEFT JOIN CODE_VALUE_OUTBOUND type_loinc ON ce.event_cd =
type_loinc.code_value
AND type_loinc.contributor_source_cd = 18024137 ;LOINC
AND type_loinc.alias_type_meaning = "CONTENTTYPE")
,ENCOUNTER e
,(LEFT JOIN TIME_ZONE_R tz ON tz.parent_entity_id = e.loc_facility_cd
AND tz.parent_entity_name =
"LOCATION")
,ENCNTR_ALIAS fin
PLAN ce WHERE ce.performed_prsnl_id = $prsnl
AND ce.performed_dt_tm BETWEEN CNVTDATETIME($beg_date) AND
CNVTDATETIME($end_date)
AND ce.view_level = 1
AND ce.valid_until_dt_tm > SYSDATE
AND ce.result_status_cd NOT IN (28,29,30,31) ;IN ERROR
AND ce.event_class_cd in (224, 231) ;DOC, MDOC (CS 53)
; might want to add TXT (236) here to show mpage workflow documentation
; there are also a bunch of documents with view_level 0 that might need
consideration
; like radiology reports
JOIN e WHERE ce.encntr_id = e.encntr_id
JOIN fin WHERE fin.encntr_id = e.encntr_id
AND fin.encntr_alias_type_cd = 1077 ;FIN
AND fin.end_effective_dt_tm > SYSDATE
AND fin.active_ind = 1
JOIN perf_p
JOIN veri_p
JOIN class_loinc
JOIN type_loinc
JOIN tz
ORDER BY ce.event_end_dt_tm
ELSEIF($last_tab
= "activity" AND $activity = "Documents (scanned)")
;summary information
personnel = prsnl_name
,cnt.total_scans
,cnt.total_pages
,start_range = CNVTDATETIME($beg_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
;detail information
,document = ctl.doc_type
,ctl.subject
,action = UAR_GET_CODE_DISPLAY(ctl.reason_cd)
,action_type = EVALUATE(ctl.action_type_flag,
0, "Submit",
1, "Failed",
2, "Send to service",
3, "Delete",
4, "Modify",
5, "Single Document Capture",
6, "Receive",
7, "Validate manually",
8, "Migrate",
9, "Update metadata",
10, "Print",
11, "Combine",
12, "Split",
13, "Copy",
"unknown")
,action_dt_tm = DATETIMEZONEFORMAT(
ctl.action_dt_tm, DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY
HH:MM;;q")
,ctl.page_cnt
,patient = ctl.patient_name
,edipi = edipi.alias
,fin = fin.alias
,encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
,facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
,reg_dt_tm = DATETIMEZONEFORMAT(
e.reg_dt_tm, DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY
HH:MM;;q")
,storage_type = EVALUATE(ctl.blob_type_flag,
0, "CLINICAL_EVENT",
1, "BLOB",
2, "EXTERNAL",
"unknown")
FROM CDI_TRANS_LOG ctl
,(LEFT JOIN ENCOUNTER e ON ctl.encntr_id = e.encntr_id
AND e.active_ind = 1)
,(LEFT JOIN TIME_ZONE_R tz ON tz.parent_entity_id = e.loc_facility_cd
AND tz.parent_entity_name =
"LOCATION")
,(LEFT JOIN ENCNTR_ALIAS fin ON e.encntr_id = fin.encntr_id
AND fin.encntr_alias_type_cd = 1077
AND fin.end_effective_dt_tm > SYSDATE
AND fin.active_ind = 1)
,PERSON_ALIAS edipi
,((SELECT log.perf_prsnl_id, total_pages = SUM(log.page_cnt),
total_scans = COUNT(log.cdi_trans_log_id)
FROM CDI_TRANS_LOG log
WHERE log.perf_prsnl_id = $prsnl
AND log.action_dt_tm BETWEEN CNVTDATETIME($beg_date) AND
CNVTDATETIME($end_date)
AND log.active_ind = 1
GROUP BY log.perf_prsnl_id
WITH SQLTYPE("f8","i4","i4")) cnt )
PLAN ctl WHERE ctl.perf_prsnl_id = $prsnl
AND ctl.action_dt_tm BETWEEN CNVTDATETIME($beg_date) AND
CNVTDATETIME($end_date)
AND ctl.active_ind = 1
JOIN edipi WHERE edipi.person_id = ctl.person_id
AND edipi.person_alias_type_cd = 22 ;EDIPI
AND edipi.end_effective_dt_tm > SYSDATE
AND edipi.active_ind = 1
JOIN cnt WHERE cnt.perf_prsnl_id = ctl.perf_prsnl_id
JOIN e
JOIN fin
JOIN tz
ORDER BY
ctl.action_dt_tm
ELSEIF($last_tab
= "activity" AND $activity = "Documents (verified)")
fin = fin.alias
,e.reg_dt_tm
,facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
,encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
,note_type = UAR_GET_CODE_DISPLAY(ce.event_cd)
,note_title = ce.event_title_text
,note_status = UAR_GET_CODE_DISPLAY(ce.result_status_cd)
,performed_dt_tm = DATETIMEZONEFORMAT(ce.performed_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
,verified_dt_tm = DATETIMEZONEFORMAT(ce.verified_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY
HH:MM;;q")
,author = perf_p.name_full_formatted
,verifying_prsnl = prsnl_name
,note_class_loinc = class_loinc.alias
,note_type_loinc = type_loinc.alias
,contrib_sys = UAR_GET_CODE_DISPLAY(ce.contributor_system_cd)
,entry_mode = UAR_GET_CODE_DISPLAY(ce.entry_mode_cd)
,event_class = UAR_GET_CODE_DISPLAY(ce.event_class_cd)
,ce.event_id
FROM
CLINICAL_EVENT ce
,(LEFT JOIN PRSNL perf_p ON ce.performed_prsnl_id = perf_p.person_id)
,(LEFT JOIN CODE_VALUE_OUTBOUND class_loinc ON ce.event_cd =
class_loinc.code_value
AND class_loinc.contributor_source_cd = 18024137 ;LOINC
AND class_loinc.alias_type_meaning = "CLASSCODE")
,(LEFT JOIN CODE_VALUE_OUTBOUND type_loinc ON ce.event_cd =
type_loinc.code_value
AND type_loinc.contributor_source_cd = 18024137 ;LOINC
AND type_loinc.alias_type_meaning = "CONTENTTYPE")
,ENCOUNTER e
,(LEFT JOIN TIME_ZONE_R tz ON tz.parent_entity_id = e.loc_facility_cd
AND tz.parent_entity_name =
"LOCATION")
,ENCNTR_ALIAS fin
PLAN ce WHERE ce.verified_prsnl_id = $prsnl
AND ce.verified_dt_tm BETWEEN CNVTDATETIME($beg_date) AND
CNVTDATETIME($end_date)
AND ce.view_level = 1
AND ce.valid_until_dt_tm > SYSDATE
AND ce.result_status_cd NOT IN (28,29,30,31) ;IN ERROR
AND ce.event_class_cd in (224, 231) ;DOC, MDOC (CS 53)
; might want to add TXT (236) here to show mpage workflow documentation
; there are also a bunch of documents with view_level 0 that might need
consideration
; like radiology reports
JOIN e WHERE ce.encntr_id = e.encntr_id
JOIN fin WHERE fin.encntr_id = e.encntr_id
AND fin.encntr_alias_type_cd = 1077 ;FIN
AND fin.end_effective_dt_tm > SYSDATE
AND fin.active_ind = 1
JOIN perf_p
JOIN class_loinc
JOIN type_loinc
JOIN tz
ORDER BY ce.event_end_dt_tm
ELSEIF($last_tab
= "activity" AND $activity = "Documents (verified, but not
authored)")
fin = fin.alias
,e.reg_dt_tm
,facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
,encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
,note_type = UAR_GET_CODE_DISPLAY(ce.event_cd)
,note_title = ce.event_title_text
,note_status = UAR_GET_CODE_DISPLAY(ce.result_status_cd)
,performed_dt_tm = DATETIMEZONEFORMAT(ce.performed_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
,verified_dt_tm = DATETIMEZONEFORMAT(ce.verified_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY
HH:MM;;q")
,author = perf_p.name_full_formatted
,verifying_prsnl = prsnl_name
,note_class_loinc = class_loinc.alias
,note_type_loinc = type_loinc.alias
,contrib_sys = UAR_GET_CODE_DISPLAY(ce.contributor_system_cd)
,entry_mode = UAR_GET_CODE_DISPLAY(ce.entry_mode_cd)
,event_class = UAR_GET_CODE_DISPLAY(ce.event_class_cd)
,ce.event_id
FROM
CLINICAL_EVENT ce
,(LEFT JOIN PRSNL perf_p ON ce.performed_prsnl_id = perf_p.person_id)
,(LEFT JOIN CODE_VALUE_OUTBOUND class_loinc ON ce.event_cd =
class_loinc.code_value
AND class_loinc.contributor_source_cd = 18024137 ;LOINC
AND class_loinc.alias_type_meaning = "CLASSCODE")
,(LEFT JOIN CODE_VALUE_OUTBOUND type_loinc ON ce.event_cd =
type_loinc.code_value
AND type_loinc.contributor_source_cd = 18024137 ;LOINC
AND type_loinc.alias_type_meaning = "CONTENTTYPE")
,ENCOUNTER e
,(LEFT JOIN TIME_ZONE_R tz ON tz.parent_entity_id = e.loc_facility_cd
AND tz.parent_entity_name =
"LOCATION")
,ENCNTR_ALIAS fin
PLAN ce WHERE ce.verified_prsnl_id = $prsnl
AND ce.performed_prsnl_id != $prsnl
AND ce.verified_dt_tm BETWEEN CNVTDATETIME($beg_date) AND
CNVTDATETIME($end_date)
AND ce.view_level = 1
AND ce.valid_until_dt_tm > SYSDATE
AND ce.result_status_cd NOT IN (28,29,30,31) ;IN ERROR
AND ce.event_class_cd in (224, 231) ;DOC, MDOC (CS 53)
; might want to add TXT (236) here to show mpage workflow documentation
; there are also a bunch of documents with view_level 0 that might need
consideration
; like radiology reports
JOIN e WHERE ce.encntr_id = e.encntr_id
JOIN fin WHERE fin.encntr_id = e.encntr_id
AND fin.encntr_alias_type_cd = 1077 ;FIN
AND fin.end_effective_dt_tm > SYSDATE
AND fin.active_ind = 1
JOIN perf_p
JOIN class_loinc
JOIN type_loinc
JOIN tz
ORDER BY ce.event_end_dt_tm
ELSEIF($last_tab
= "activity" AND $activity = "Encounters Created
(summary)")
personnel = prsnl_name
,year = YEAR(e.create_dt_tm)
,month = MONTH(e.create_dt_tm)
,day = DAY(e.create_dt_tm)
,encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
,encntrs_created = COUNT(*)
FROM ENCOUNTER e
PLAN e WHERE e.create_prsnl_id = $prsnl
AND e.create_dt_tm BETWEEN CNVTDATETIME($beg_date) AND
CNVTDATETIME($end_date)
AND e.end_effective_dt_tm > SYSDATE
AND e.active_ind = 1
GROUP BY prsnl_name, YEAR(e.create_dt_tm), MONTH(e.create_dt_tm),
DAY(e.create_dt_tm), e.encntr_type_cd
ORDER BY personnel, year DESC, month DESC, day DESC, encntr_type
ELSEIF($last_tab
= "activity" AND $activity = "Encounter Relationships
(attending)")
patient = p.name_full_formatted
,edipi = edipi.alias
,age = CNVTAGE(p.birth_dt_tm, e.reg_dt_tm, 0)
,sex = UAR_GET_CODE_DISPLAY(p.sex_cd)
,fin = fin.alias
,reg_dt_tm = DATETIMEZONEFORMAT(e.reg_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
,attending = prsnl_name
;,begin_dt_tm = DATETIMEZONEFORMAT(epr.beg_effective_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
;,expire_dt_tm =
DATETIMEZONEFORMAT(epr.expire_dt_tm,DATETIMEZONEBYNAME(tz.time_zone),
"MM/DD/YYYY HH:MM;;q")
,facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
,encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
,med_service = UAR_GET_CODE_DISPLAY(e.med_service_cd)
FROM ENCNTR_PRSNL_RELTN epr
,(LEFT JOIN ENCNTR_ALIAS fin ON fin.encntr_id = epr.encntr_id
AND fin.encntr_alias_type_cd = 1077 ;FIN
AND fin.end_effective_dt_tm > SYSDATE
AND fin.active_ind = 1)
,ENCOUNTER e
,TIME_ZONE_R tz
,PERSON p
,PERSON_ALIAS edipi
PLAN epr WHERE epr.prsnl_person_id = $prsnl
;Attending Physician, Locum Attending, Mental Health Attending
Physician
AND epr.encntr_prsnl_r_cd IN (1119, 673962, 165930197)
AND epr.transaction_dt_tm BETWEEN CNVTDATETIME($beg_date) AND
CNVTDATETIME($end_date)
AND epr.active_ind =
1
JOIN e WHERE e.encntr_id = epr.encntr_id
JOIN tz WHERE tz.parent_entity_id = e.loc_facility_cd
AND tz.parent_entity_name = "LOCATION"
JOIN p WHERE p.person_id = e.person_id
JOIN edipi WHERE edipi.person_id = p.person_id
AND edipi.person_alias_type_cd = 22 ;edipi
AND edipi.end_effective_dt_tm > SYSDATE
AND edipi.active_ind = 1
JOIN fin
ORDER BY e.reg_dt_tm DESC
/****
ENCOUNTER RELATIONSHIPS (DETAIL) ****/
; unique
encounter relationships, so not exactly number of times chart was accessed
; if someone
accesses the same encounter multiple times before the relationship
; expires, it still only counts as one
prsnl_encntr relationship
ELSEIF($last_tab
= "activity" AND $activity = "Encounter Relationships
(detail)")
patient = p.name_full_formatted
,edipi = edipi.alias
,age = CNVTAGE(p.birth_dt_tm, e.reg_dt_tm, 0)
,sex = UAR_GET_CODE_DISPLAY(p.sex_cd)
,fin = fin.alias
,reg_dt_tm = DATETIMEZONEFORMAT(e.reg_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
,personnel = prsnl_name
,relationship = UAR_GET_CODE_DISPLAY(epr.encntr_prsnl_r_cd)
,transaction_dt_tm = DATETIMEZONEFORMAT(epr.transaction_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
,begin_dt_tm = DATETIMEZONEFORMAT(epr.beg_effective_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
,expire_dt_tm = DATETIMEZONEFORMAT(epr.expire_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
,facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
,encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
,med_service = UAR_GET_CODE_DISPLAY(e.med_service_cd)
FROM ENCNTR_PRSNL_RELTN epr
,(LEFT JOIN ENCNTR_ALIAS fin ON fin.encntr_id = epr.encntr_id
AND fin.encntr_alias_type_cd = 1077 ;FIN
AND fin.end_effective_dt_tm > SYSDATE
AND fin.active_ind = 1)
,ENCOUNTER e
,TIME_ZONE_R tz
,PERSON p
,PERSON_ALIAS edipi
PLAN epr WHERE epr.prsnl_person_id = $prsnl
AND epr.transaction_dt_tm BETWEEN CNVTDATETIME($beg_date) AND
CNVTDATETIME($end_date)
AND epr.active_ind =
1
JOIN e WHERE e.encntr_id = epr.encntr_id
JOIN tz WHERE tz.parent_entity_id = e.loc_facility_cd
AND tz.parent_entity_name = "LOCATION"
JOIN p WHERE p.person_id = e.person_id
JOIN edipi WHERE edipi.person_id = p.person_id
AND edipi.person_alias_type_cd = 22 ;edipi
AND edipi.end_effective_dt_tm > SYSDATE
AND edipi.active_ind = 1
JOIN fin
ORDER BY epr.transaction_dt_tm DESC
ELSEIF($last_tab
= "activity" AND $activity = "Encounter Relationships
(interactive)")
patient = p.name_full_formatted
,edipi = edipi.alias
,age = CNVTAGE(p.birth_dt_tm, e.reg_dt_tm, 0)
,sex = UAR_GET_CODE_DISPLAY(p.sex_cd)
,fin = fin.alias
,reg_dt_tm = DATETIMEZONEFORMAT(e.reg_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
,personnel = prsnl_name
,relationship = UAR_GET_CODE_DISPLAY(epr.encntr_prsnl_r_cd)
,transaction_dt_tm = DATETIMEZONEFORMAT(epr.transaction_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
,begin_dt_tm = DATETIMEZONEFORMAT(epr.beg_effective_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
,expire_dt_tm = DATETIMEZONEFORMAT(epr.expire_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
,facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,location = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
,encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
,med_service = UAR_GET_CODE_DISPLAY(e.med_service_cd)
FROM ENCNTR_PRSNL_RELTN epr
,(LEFT JOIN ENCNTR_ALIAS fin ON fin.encntr_id = epr.encntr_id
AND fin.encntr_alias_type_cd = 1077 ;FIN
AND fin.end_effective_dt_tm > SYSDATE
AND fin.active_ind = 1)
,ENCOUNTER e
,TIME_ZONE_R tz
,PERSON p
,PERSON_ALIAS edipi
PLAN epr WHERE epr.prsnl_person_id = $prsnl
AND epr.transaction_dt_tm BETWEEN CNVTDATETIME($beg_date) AND
CNVTDATETIME($end_date)
AND epr.active_ind =
1
JOIN e WHERE e.encntr_id = epr.encntr_id
JOIN tz WHERE tz.parent_entity_id = e.loc_facility_cd
AND tz.parent_entity_name = "LOCATION"
JOIN p WHERE p.person_id = e.person_id
JOIN edipi WHERE edipi.person_id = p.person_id
AND edipi.person_alias_type_cd = 22 ;edipi
AND edipi.end_effective_dt_tm > SYSDATE
AND edipi.active_ind = 1
JOIN fin
ORDER BY epr.transaction_dt_tm DESC
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
row+1 "<table border='1'>"
row+1 "<tr>"
row+1        "<th>&nbsp;</th>"
row+1        "<th>Patient</th>"
row+1        "<th>Age</th>"
row+1        "<th>Sex</th>"
row+1        "<th>Relationships</th>"
row+1
        "<th>FIN</th>"
row+1
        "<th>Registration
Date</th>"
row+1
        "<th>Transaction
Date</th>"
row+1
        "<th>Facility</th>"
row+1        "<th>Location</th>"
row+1
        "<th>Encounter
Type</th>"
row+1
        "<th>Medical
Service</th>"
row+1 "</tr>"
DETAIL
i+=1
row+1 "<tr>"
row+1        call
print(td(CNVTSTRING(i)))
row+1        call
print(td(patient))
row+1        call
print(td(age))
row+1        call
print(td(sex))
row+1        call
print(td(relationship))
row+1         call
print(td(chartlink(e.person_id, e.encntr_id, fin.alias)))
row+1        call
print(td(reg_dt_tm))
row+1        call
print(td(transaction_dt_tm))
row+1        call
print(td(facility))
row+1        call
print(td(location))
row+1         call
print(td(encntr_type))
row+1        call
print(td(med_service))
row+1 "</tr>"
FOOT REPORT
row+1 "</table>"
row+1 "</body>"
row+1
"</html>"
ELSEIF($last_tab
= "activity" AND $activity = "Encounter Relationships
(summary)")
personnel = prsnl_name
,dmis_id = ag.dmis_code
,ag.visn_code
,facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
,encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
,relationship = UAR_GET_CODE_DISPLAY(epr.encntr_prsnl_r_cd)
,num_encntrs = COUNT(*)
,start_date = CNVTDATETIME($beg_date) "MM/DD/YYYY;;d"
,end_date = CNVTDATETIME($end_date)
"MM/DD/YYYY;;d"
FROM ENCNTR_PRSNL_RELTN epr
,ENCOUNTER e
,(LEFT JOIN CUST_LOC_AGENCY_RELTN ag
ON e.loc_facility_cd = ag.location_cd
AND ag.validated_ind =
1)
PLAN epr WHERE epr.prsnl_person_id = $prsnl
AND epr.transaction_dt_tm BETWEEN CNVTDATETIME($beg_date) AND
CNVTDATETIME($end_date)
AND epr.active_ind = 1
JOIN e WHERE epr.encntr_id = e.encntr_id
JOIN ag
GROUP BY
prsnl_name, ag.dmis_code, ag.visn_code, e.loc_facility_cd,
e.loc_nurse_unit_cd
,e.encntr_type_cd, epr.encntr_prsnl_r_cd
ORDER BY dmis_id, ag.visn_code, facility, nurse_unit, encntr_type,
relationship
ELSEIF($last_tab
= "activity" AND $activity = "Orders (summary)")
personnel = prsnl_name
,category = UAR_GET_CODE_DISPLAY(o.catalog_type_cd)
,orderable = oc.description
,order_status = UAR_GET_CODE_DISPLAY(o.order_status_cd)
,nbr_orders = COUNT(DISTINCT oa.order_action_id)
,nbr_unique_patients = COUNT(DISTINCT o.person_id)
,start_date = CNVTDATETIME($beg_date) "MM/DD/YYYY;;d"
,end_date = CNVTDATETIME($end_date)
"MM/DD/YYYY;;d"
FROM ORDER_ACTION oa
,ORDERS o
,ORDER_CATALOG oc
PLAN oa WHERE oa.action_type_cd = 2534 ;ordered
AND oa.order_provider_id = $prsnl
AND oa.action_dt_tm BETWEEN CNVTDATETIME($beg_date) AND
CNVTDATETIME($end_date)
JOIN o WHERE oa.order_id = o.order_id
;AND o.order_status_cd IN (2543, 2546, 2550) ;completed, future,
ordered
AND o.template_order_flag IN (0,1,5,7) ;exclude auto-generated child
orders
AND o.active_ind = 1
JOIN oc WHERE o.catalog_cd = oc.catalog_cd
GROUP BY prsnl_name, o.catalog_type_cd, oc.description,
o.order_status_cd
ORDER BY category, CNVTUPPER(oc.description), order_status
ELSEIF($last_tab
= "activity" AND $activity = "Orders - Entered")
personnel = prsnl_name
,category = UAR_GET_CODE_DISPLAY(o.catalog_type_cd)
,orderable = oc.description
,order_status = UAR_GET_CODE_DISPLAY(o.order_status_cd)
,nbr_placed = COUNT(DISTINCT oa.order_action_id)
,nbr_unique_patients = COUNT(DISTINCT o.person_id)
,start_date = CNVTDATETIME($beg_date) "MM/DD/YYYY;;d"
,end_date = CNVTDATETIME($end_date)
"MM/DD/YYYY;;d"
FROM ORDER_ACTION oa
,ORDERS o
,ORDER_CATALOG oc
PLAN oa WHERE oa.action_type_cd = 2534 ;ordered
AND oa.action_personnel_id = $prsnl
AND oa.action_dt_tm BETWEEN CNVTDATETIME($beg_date) AND
CNVTDATETIME($end_date)
JOIN o WHERE oa.order_id = o.order_id
;AND o.order_status_cd IN (2543, 2546, 2550) ;completed, future,
ordered
AND o.template_order_flag IN (0,1,5,7) ;exclude auto-generated child
orders
AND o.active_ind = 1
JOIN oc WHERE o.catalog_cd = oc.catalog_cd
GROUP BY prsnl_name, o.catalog_type_cd, oc.description,
o.order_status_cd
ORDER BY category, CNVTUPPER(oc.description), order_status
ELSEIF($last_tab
= "activity" AND $activity = "Orders - Future")
provider = prsnl_name
,patient = p.name_full_formatted
,edipi = edipi.alias
,mrn = mrn.alias
,future_order = oc.description
,o.ordered_as_mnemonic
,category = UAR_GET_CODE_DISPLAY(o.catalog_type_cd)
,order_dt_tm = o.orig_order_dt_tm
,o.originating_encntr_id
,o.order_id
FROM ORDER_ACTION oa
,ORDERS o
,ORDER_CATALOG oc
,PERSON p
,PERSON_ALIAS edipi
,PERSON_ALIAS mrn
PLAN oa WHERE oa.action_type_cd = 2534 ;ordered
AND oa.order_provider_id = $prsnl
JOIN o WHERE oa.order_id = o.order_id
AND o.order_status_cd = 2546 ;future
AND o.template_order_flag IN (0,1,5,7) ;exclude auto-generated child
orders
AND o.active_ind = 1
JOIN oc WHERE o.catalog_cd = oc.catalog_cd
JOIN p WHERE o.person_id = p.person_id
JOIN edipi WHERE p.person_id = edipi.person_id
AND edipi.person_alias_type_cd = 22 ;EDIPI
AND edipi.end_effective_dt_tm > SYSDATE
AND edipi.active_ind =
1
JOIN mrn WHERE p.person_id = mrn.person_id
AND mrn.person_alias_type_cd = 10 ;MRN
AND mrn.end_effective_dt_tm > SYSDATE
AND mrn.active_ind = 1
ORDER BY patient, future_order, order_dt_tm
ELSEIF($last_tab
= "activity" AND $activity = "Orders - Proposed To")
order_provider = pr_respons.name_full_formatted
,proposed_order = op.order_mnemonic
,order_detail = op.clinical_display_line
,proposed_location =
UAR_GET_CODE_DISPLAY(op.future_location_nurse_unit_cd)
,proposed_action = UAR_GET_CODE_DISPLAY(op.proposed_action_type_cd)
,proposal_status = UAR_GET_CODE_DISPLAY(op.proposal_status_cd)
,order_status = UAR_GET_CODE_DISPLAY(o.order_status_cd)
,created_dt_tm = DATETIMEZONEFORMAT(op.created_dt_tm, op.created_tz,
"MM/DD/YY HH:MM;;q")
,resolved_dt_tm = DATETIMEZONEFORMAT(op.resolved_dt_tm, op.resolved_tz,
"MM/DD/YY HH:MM;;q")
,resolve_time = CNVTAGE(op.created_dt_tm, op.resolved_dt_tm, 0)
,proposed_by =
IF(pr_enter.position_cd != 0)
BUILD(pr_enter.name_full_formatted, " (",
TRIM(UAR_GET_CODE_DISPLAY(pr_enter.position_cd)), ")")
ELSE pr_enter.name_full_formatted
ENDIF
,resolved_by =
IF(pr_resolve.position_cd != 0)
BUILD(pr_resolve.name_full_formatted, " (",
TRIM(UAR_GET_CODE_DISPLAY(pr_resolve.position_cd)), ")")
ELSE pr_resolve.name_full_formatted
ENDIF
,order_communication_type =
UAR_GET_CODE_DISPLAY(op.communication_type_cd)
,proposal_source_type =
UAR_GET_CODE_DISPLAY(op.proposal_source_type_cd)
,med_order_type = UAR_GET_CODE_DISPLAY(op.med_order_type_cd)
,origin_location = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
,origin_fin = fin.alias
,origin_encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
,patient = p.name_full_formatted
,edipi = edipi.alias
,op.order_id
FROM ORDER_PROPOSAL op
,(LEFT JOIN ORDERS o ON o.order_id = op.order_id AND o.active_ind = 1)
,(LEFT JOIN ENCOUNTER e ON ((e.encntr_id = op.originating_encntr_id AND
op.originating_encntr_id > 0)
OR (e.encntr_id = op.encntr_id AND op.originating_encntr_id = 0))
AND e.active_ind = 1)
,(LEFT JOIN ENCNTR_ALIAS fin ON fin.encntr_id = e.encntr_id
AND fin.encntr_alias_type_cd = 1077 ;FIN
AND fin.end_effective_dt_tm > SYSDATE
AND fin.active_ind = 1)
,PRSNL pr_respons
,PRSNL pr_enter
,PRSNL pr_resolve
,PERSON p
,PERSON_ALIAS edipi
PLAN op WHERE op.responsible_prsnl_id = $prsnl
AND op.created_dt_tm BETWEEN CNVTDATETIME($beg_date) AND
CNVTDATETIME($end_date)
AND op.entered_by_prsnl_id != op.responsible_prsnl_id ;exclude orders
the provider submitted themselves
JOIN pr_respons WHERE pr_respons.person_id = op.responsible_prsnl_id
JOIN pr_enter WHERE pr_enter.person_id = op.entered_by_prsnl_id
JOIN pr_resolve WHERE pr_resolve.person_id = op.resolved_by_prsnl_id
JOIN p WHERE p.person_id = op.person_id
JOIN edipi WHERE edipi.person_id = op.person_id
AND edipi.person_alias_type_cd = 22 ;EDIPI
AND edipi.end_effective_dt_tm > SYSDATE
AND edipi.active_ind = 1
JOIN o
JOIN e
JOIN fin
ORDER BY op.created_dt_tm
ELSEIF($last_tab
= "activity" AND $activity = "Orders - Unresulted Labs")
 patient = p.name_full_formatted
 ,edipi = edipi.alias
 ,orderable = oc.description
 ,originating_fin = ofin.alias
 ,activating_fin = fin.alias
 ; ORDER INFORMATION
 ,o.ordered_as_mnemonic ;often contains
brand name
 ,catalog_type =
UAR_GET_CODE_DISPLAY(oc.catalog_type_cd)
 ,sub_type =
         IF(oc.activity_subtype_cd
> 0) UAR_GET_CODE_DISPLAY(oc.activity_subtype_cd)
         ELSE
UAR_GET_CODE_DISPLAY(oc.activity_type_cd)
         ENDIF
 ,order_detail =
SUBSTRING(1,100,replace_CRLF(o.order_detail_display_line))
 ,order_status =
UAR_GET_CODE_DISPLAY(o.order_status_cd)
 ,dept_status =
UAR_GET_CODE_DISPLAY(o.dept_status_cd)
 ,accession =
UAR_FMT_ACCESSION(ca.accession, size(ca.accession, 1))
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
 ,container_location =
UAR_GET_CODE_DISPLAY(c.current_location_cd)
 ; TIMING
 ,order_age = CNVTAGE(o.orig_order_dt_tm,
SYSDATE, 0)
 ,order_dt_tm =
DATETIMEZONEFORMAT(o.orig_order_dt_tm, o.current_start_tz, "MM/DD/YYYY
HH:MM;;q")
 ,collect_dt_tm =
DATETIMEZONEFORMAT(c.drawn_dt_tm, o.current_start_tz, "MM/DD/YYYY
HH:MM;;q")
 ,received_dt_tm =
DATETIMEZONEFORMAT(c.received_dt_tm, o.current_start_tz, "MM/DD/YYYY
HH:MM;;q")
; IDENTIFIERS
,o.order_id
FROM ORDER_ACTION oa
,ORDERS o
,(LEFT JOIN ENCNTR_ALIAS ofin ON ofin.encntr_id =
o.originating_encntr_id
AND ofin.encntr_alias_type_cd = 1077
AND ofin.active_ind = 1
AND ofin.end_effective_dt_tm > SYSDATE)
,(LEFT JOIN ENCNTR_ALIAS fin ON fin.encntr_id = o.encntr_id
AND fin.encntr_alias_type_cd = 1077
AND fin.active_ind = 1
AND fin.end_effective_dt_tm >
SYSDATE)
,(LEFT JOIN ORDER_CONTAINER_R ocr ON ocr.order_id = o.order_id)
,(LEFT JOIN CONTAINER c ON c.container_id = ocr.container_id)
,(LEFT JOIN CONTAINER_ACCESSION ca ON ca.container_id = c.container_id)
,ORDER_CATALOG oc
,PERSON p
,PERSON_ALIAS edipi
PLAN oa WHERE oa.action_type_cd = 2534 ;ordered
AND oa.order_provider_id = $prsnl
AND oa.action_dt_tm BETWEEN CNVTDATETIME($beg_date) AND
CNVTDATETIME($end_date)
JOIN o WHERE oa.order_id = o.order_id
AND o.catalog_type_cd = 2513 ;lab
AND o.activity_type_cd != 705 ;pharmacy
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
JOIN oc WHERE o.catalog_cd = oc.catalog_cd
JOIN p WHERE p.person_id = o.person_id
JOIN edipi WHERE edipi.person_id = p.person_id
AND edipi.person_alias_type_cd = 22 ;EDIPI
AND edipi.end_effective_dt_tm > SYSDATE
AND edipi.active_ind = 1
JOIN ofin
JOIN fin
JOIN ocr
JOIN c
JOIN ca
ORDER BY patient, catalog_type, order_dt_tm
;consider
looking at the task activity tables to see if missing something here
ELSEIF($last_tab
= "activity" AND $activity = "Order Tasks Completed")
personnel = prsnl_name
,category = UAR_GET_CODE_DISPLAY(o.catalog_type_cd)
,orderable = oc.description
,nbr_completed = COUNT(DISTINCT oa.order_action_id)
,nbr_unique_patients = COUNT(DISTINCT o.person_id)
,start_date = CNVTDATETIME($beg_date) "MM/DD/YYYY;;d"
,end_date = CNVTDATETIME($end_date)
"MM/DD/YYYY;;d"
FROM ORDER_ACTION oa
,ORDERS o
,ORDER_CATALOG oc
PLAN oa WHERE oa.action_type_cd = 2529 ;complete
AND oa.action_personnel_id = $prsnl
AND oa.action_dt_tm BETWEEN CNVTDATETIME($beg_date) AND
CNVTDATETIME($end_date)
JOIN o WHERE oa.order_id = o.order_id
AND o.active_ind = 1
JOIN oc WHERE o.catalog_cd = oc.catalog_cd
AND oc.active_ind =
1
GROUP BY prsnl_name, o.catalog_type_cd, oc.description
ORDER BY category, CNVTUPPER(oc.description)
ELSEIF($last_tab
= "activity" AND $activity = "Patients Registered
(summary)")
personnel = prsnl_name
,year = YEAR(p.create_dt_tm)
,month = MONTH(p.create_dt_tm)
,day = DAY(p.create_dt_tm)
,patients_registered = COUNT(*)
FROM PERSON p
PLAN p WHERE p.create_prsnl_id = $prsnl
AND p.create_dt_tm BETWEEN CNVTDATETIME($beg_date) AND
CNVTDATETIME($end_date)
AND p.end_effective_dt_tm > SYSDATE
AND p.active_ind = 1
GROUP BY prsnl_name, YEAR(p.create_dt_tm), MONTH(p.create_dt_tm),
DAY(p.create_dt_tm)
ORDER BY personnel, year DESC, month DESC, day DESC
ELSEIF($last_tab
= "activity" AND $activity = "Referrals Placed")
provider = prsnl_name
,referrals_to = od.oe_field_display_value
,nbr_referrals = COUNT(DISTINCT o.order_id)
,nbr_unique_patients = COUNT(DISTINCT o.person_id)
,start_date = CNVTDATETIME($beg_date) "MM/DD/YYYY;;d"
,end_date = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
FROM ORDERS o
,ORDER_ACTION oa
,ORDER_DETAIL od
PLAN o WHERE o.catalog_cd IN (384117187, 352106571)
;Referral Request 2.0, Ambulatory Referral - VA
AND o.order_status_cd != 2343 ;canceled
AND o.orig_order_dt_tm BETWEEN CNVTDATETIME($beg_date) AND
CNVTDATETIME($end_date)
AND o.active_ind = 1
JOIN oa WHERE oa.order_id = o.order_id
AND oa.action_type_cd = 2534 ;order
AND oa.order_provider_id = $prsnl
JOIN od WHERE od.order_id = o.order_id
AND od.oe_field_id = 166104745 ;refer to location
GROUP BY prsnl_name, od.oe_field_display_value
ORDER BY provider, referrals_to
ELSEIF($last_tab
= "activity" AND $activity = "Report Usage (summary)")
DISTINCT
report_name =
IF(TEXTLEN(df.report_alias_name) > 1) df.report_alias_name
ELSE cra.object_name
ENDIF
,cra.object_name
,cra.object_type
,nbr_runs = COUNT(DISTINCT cra.report_event_id)
,start_range = CNVTDATETIME($beg_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date)
"MM/DD/YYYY;;d"
FROM CCL_REPORT_AUDIT cra
,(LEFT JOIN DA_REPORT dr ON CNVTUPPER(dr.report_name) =
CNVTUPPER(cra.object_name))
,(LEFT JOIN DA_FOLDER_REPORT_RELTN df ON df.da_report_id =
dr.da_report_id)
PLAN cra WHERE cra.updt_id = $prsnl
AND cra.status = "SUCCESS"
AND cra.object_type IN ("CCLREPORT", "DADATACUBE",
"DAREPORT", "BOREPORT")
AND cra.end_dt_tm BETWEEN CNVTDATETIME($beg_date) AND
CNVTDATETIME($end_date)
JOIN dr
JOIN df
GROUP BY df.report_alias_name, cra.object_name, cra.object_type
ORDER BY report_name
ELSEIF($last_tab
= "activity" AND $activity = "Reports and Queries")
cra.object_name
,object_type = EVALUATE2(
IF(cra.omf_object_cd = 0 AND cra.object_name != "AD HOC
QUERY" AND cra.object_type = "QUERY") "Report Query"
ELSEIF(cra.omf_object_cd > 0)
UAR_GET_CODE_DISPLAY(cra.omf_object_cd)
ELSE cra.object_type
ENDIF)
,event_dt_tm = cra.updt_dt_tm "MM/DD/YYYY HH:MM;;q"
,cra.status
,discern_alias = dfr.report_alias_name
,cra.object_params
,query_details = SUBSTRING(1,1000,replace_CRLF(lt.long_text))
;truncated
,application = app.description
,cra.report_event_id
,start_range = CNVTDATETIME($beg_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date)
"MM/DD/YYYY;;d"
FROM CCL_REPORT_AUDIT cra
,(LEFT JOIN DA_REPORT rep ON CNVTUPPER(rep.report_name) =
cra.object_name)
,(LEFT JOIN DA_FOLDER_REPORT_RELTN dfr ON dfr.da_report_id =
rep.da_report_id)
,APPLICATION app
,LONG_TEXT lt
PLAN cra WHERE cra.updt_id = $prsnl
AND cra.updt_dt_tm BETWEEN CNVTDATETIME($beg_date) AND
CNVTDATETIME($end_date)
JOIN app WHERE app.application_number = cra.application_nbr
JOIN lt WHERE lt.long_text_id = cra.long_text_id
JOIN rep
JOIN dfr
ORDER BY cra.updt_dt_tm DESC
ELSEIF($last_tab
= "activity" AND $activity = "Results - Lab Orders")
 patient = p.name_full_formatted
 ,edipi = edipi.alias
,order_dt_tm = DATETIMEZONEFORMAT(o.orig_order_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
 ,orderable = oc.description
 ,event = UAR_GET_CODE_DISPLAY(ce.event_cd)
 ,result = ce.result_val
 ,result_units =
UAR_GET_CODE_DISPLAY(ce.result_units_cd)
 ,result_flag = BUILD(
         TRIM(UAR_GET_CODE_DISPLAY(ce.normalcy_cd)),
" (",
         TRIM(UAR_GET_CODE_DESCRIPTION(ce.normalcy_cd)),
")")
,endorsed = IF(endorse.event_id != 0) "endorsed" ELSE
"not endorsed" ENDIF
,endorsed_status =
UAR_GET_CODE_DISPLAY(endorse_status.endorse_status_cd)
 ;REFERENCE RANGES
 ,ce.critical_low
 ,ce.normal_low
 ,ce.normal_high
 ,ce.critical_high
,performing_lab = UAR_GET_CODE_DISPLAY(perf_resource.location_cd)
,activity_subtype = UAR_GET_CODE_DISPLAY(oc.activity_subtype_cd)
,accession_formatted = UAR_FMT_ACCESSION(ca.accession,
size(ca.accession, 1))
,specimen_type = UAR_GET_CODE_DISPLAY(c.specimen_type_cd)
 ,collection_method =
UAR_GET_CODE_DISPLAY(c.collection_method_cd)
 ;,result_status =
UAR_GET_CODE_DISPLAY(ce.result_status_cd)
 ;TIMING
 ,collect_dt_tm =
DATETIMEZONEFORMAT(c.drawn_dt_tm, DATETIMEZONEBYNAME(tz.time_zone),
"MM/DD/YYYY HH:MM;;q")
 ,received_dt_tm =
DATETIMEZONEFORMAT(c.received_dt_tm, DATETIMEZONEBYNAME(tz.time_zone),
"MM/DD/YYYY HH:MM;;q")
 ,performed_dt_tm =
DATETIMEZONEFORMAT(ce.performed_dt_tm, DATETIMEZONEBYNAME(tz.time_zone),
"MM/DD/YYYY HH:MM;;q")
 ,verified_dt_tm =
DATETIMEZONEFORMAT(ce.verified_dt_tm, DATETIMEZONEBYNAME(tz.time_zone),
"MM/DD/YYYY HH:MM;;q")
 ,endorsed_dt_tm =
DATETIMEZONEFORMAT(endorse.action_dt_tm, DATETIMEZONEBYNAME(tz.time_zone),
"MM/DD/YYYY HH:MM;;q")
 ;IDENTIFIERS
 ,originating_fin = ofin.alias
 ,activating_fin = fin.alias
,o.order_id
,ce.event_id
FROM ORDER_ACTION oa
,ORDERS o
,(LEFT JOIN ENCNTR_ALIAS ofin ON ofin.encntr_id =
o.originating_encntr_id
AND ofin.encntr_alias_type_cd = 1077 ;FIN
AND ofin.end_effective_dt_tm > SYSDATE
AND ofin.active_ind = 1)
,(LEFT JOIN ENCNTR_ALIAS fin ON fin.encntr_id = o.encntr_id
AND fin.encntr_alias_type_cd = 1077 ;FIN
AND fin.end_effective_dt_tm > SYSDATE
AND fin.active_ind =
1)
,ORDER_CATALOG oc
,PERSON p
,PERSON_ALIAS edipi
,CLINICAL_EVENT ce
,(LEFT JOIN ORDER_CONTAINER_R ocr ON ocr.order_id = ce.order_id)
,(LEFT JOIN CONTAINER c ON c.container_id = ocr.container_id)
,(LEFT JOIN CONTAINER_ACCESSION ca ON ca.container_id =
c.container_id)
 ,(LEFT JOIN V500_SPECIMEN spec ON
spec.specimen_id = c.specimen_id)
 ,(LEFT JOIN SERVICE_RESOURCE
perf_resource ON ce.resource_cd = perf_resource.service_resource_cd)
 ,(LEFT JOIN CE_EVENT_PRSNL endorse ON
endorse.event_id = ce.event_id
         AND
endorse.action_type_cd IN (678654, 106) ;endorse, review
         AND
endorse.valid_until_dt_tm > SYSDATE)
 ,(LEFT JOIN CE_EVENT_ACTION
endorse_status ON endorse_status.event_id = ce.event_id)
 ,ENCOUNTER e
 ,TIME_ZONE_R
tz
PLAN oa WHERE oa.action_type_cd = 2534 ;ordered
AND oa.order_provider_id = $prsnl
AND oa.action_dt_tm BETWEEN CNVTDATETIME($beg_date) AND
CNVTDATETIME($end_date)
JOIN o WHERE oa.order_id = o.order_id
AND o.catalog_type_cd = 2513 ;lab
AND o.active_ind = 1
JOIN oc WHERE o.catalog_cd = oc.catalog_cd
JOIN p WHERE p.person_id = o.person_id
JOIN edipi WHERE edipi.person_id = p.person_id
AND edipi.person_alias_type_cd = 22 ;EDIPI
AND edipi.end_effective_dt_tm > SYSDATE
AND edipi.active_ind = 1
JOIN ce WHERE ce.order_id = o.order_id
AND ce.view_level = 1
AND ce.result_status_cd NOT IN (28,29,30,31)
AND ce.valid_until_dt_tm > SYSDATE
JOIN e WHERE e.encntr_id = ce.encntr_id
JOIN tz WHERE tz.parent_entity_id = e.loc_facility_cd
AND tz.parent_entity_name = "LOCATION"
JOIN ofin
JOIN fin
 JOIN ocr
 JOIN c
 JOIN ca
 JOIN spec
 JOIN perf_resource
 JOIN endorse
 JOIN endorse_status
ORDER BY patient, order_dt_tm DESC, o.order_id, event
ELSEIF($last_tab
= "activity" AND $activity = "Results - Unendorsed")
 patient = p.name_full_formatted
 ,edipi = edipi.alias
,order_dt_tm = DATETIMEZONEFORMAT(o.orig_order_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
 ,orderable = oc.description
 ,event = UAR_GET_CODE_DISPLAY(ce.event_cd)
 ,result = ce.result_val
 ,result_units =
UAR_GET_CODE_DISPLAY(ce.result_units_cd)
 ,result_flag =
         IF(ce.normalcy_cd = 0)
""
         ELSE BUILD(
         TRIM(UAR_GET_CODE_DISPLAY(ce.normalcy_cd)),
" (",
         TRIM(UAR_GET_CODE_DESCRIPTION(ce.normalcy_cd)),
")")
 ENDIF
,endorse_status = UAR_GET_CODE_DISPLAY(cea.endorse_status_cd)
 ,performed_dt_tm =
DATETIMEZONEFORMAT(ce.performed_dt_tm, DATETIMEZONEBYNAME(tz.time_zone),
"MM/DD/YYYY HH:MM;;q")
 ,verified_dt_tm =
DATETIMEZONEFORMAT(ce.verified_dt_tm, DATETIMEZONEBYNAME(tz.time_zone),
"MM/DD/YYYY HH:MM;;q")
 ,encntr_type =
UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
 ,encntr_location =
UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
 ,order_placed_by =
         IF(oe_prsnl.position_cd
!= 0)
                 BUILD(oe_prsnl.name_full_formatted,
" (", TRIM(UAR_GET_CODE_DISPLAY(oe_prsnl.position_cd)),
")")
         ELSE
oe_prsnl.name_full_formatted
         ENDIF
 ,order_status =
UAR_GET_CODE_DISPLAY(o.order_status_cd)
 ,originating_fin = ofin.alias
 ,activating_fin = fin.alias
,o.order_id
,ce.event_id
FROM ORDER_ACTION oa
,PRSNL oe_prsnl
,ORDERS o
,(LEFT JOIN ENCNTR_ALIAS ofin ON ofin.encntr_id =
o.originating_encntr_id
AND ofin.encntr_alias_type_cd = 1077
AND ofin.active_ind = 1
AND ofin.end_effective_dt_tm > SYSDATE)
,(LEFT JOIN ENCNTR_ALIAS fin ON fin.encntr_id = o.encntr_id
AND fin.encntr_alias_type_cd = 1077
AND fin.active_ind = 1
AND fin.end_effective_dt_tm >
SYSDATE)
,ORDER_CATALOG oc
,PERSON p
,PERSON_ALIAS edipi
,CLINICAL_EVENT ce
 ,(LEFT JOIN CE_EVENT_PRSNL endorse ON
endorse.event_id = ce.event_id
         AND
endorse.action_type_cd IN (
                 678654        ;endorse
                 ,106        ;review
         )
         AND
endorse.valid_until_dt_tm > SYSDATE)
 ,CE_EVENT_ACTION cea
 ,ENCOUNTER e
 ,TIME_ZONE_R
tz
PLAN oa WHERE oa.action_type_cd = 2534 ;ordered
AND oa.order_provider_id = $prsnl
AND oa.action_dt_tm BETWEEN CNVTDATETIME($beg_date) AND
CNVTDATETIME($end_date)
JOIN oe_prsnl WHERE oe_prsnl.person_id = oa.action_personnel_id
JOIN o WHERE oa.order_id = o.order_id
AND o.catalog_type_cd IN (2513, 2517) ;lab/rad
AND o.order_status_cd NOT IN (2542, 2544) ;canceled, voided with
results
AND o.active_ind = 1
JOIN oc WHERE o.catalog_cd = oc.catalog_cd
AND oc.active_ind =
1
JOIN p WHERE p.person_id = o.person_id
AND p.active_ind = 1
JOIN edipi WHERE edipi.person_id = p.person_id
AND edipi.person_alias_type_cd = 22 ;EDIPI
AND edipi.end_effective_dt_tm > SYSDATE
AND edipi.active_ind = 1
JOIN ce WHERE ce.order_id = o.order_id
AND ce.view_level = 1
AND ce.result_status_cd NOT IN (28,29,30,31)
AND ce.valid_until_dt_tm > SYSDATE
JOIN cea WHERE cea.event_id = ce.event_id
JOIN e WHERE e.encntr_id = ce.encntr_id
AND e.encntr_type_class_cd != 391 ;exclude inpatient (do we need ED
excluded?)
JOIN tz WHERE tz.parent_entity_id = e.loc_facility_cd
AND tz.parent_entity_name = "LOCATION"
JOIN ofin
JOIN fin
 JOIN endorse
ORDER BY patient, order_dt_tm DESC, o.order_id, event
ELSEIF($last_tab
= "activity" AND $activity = "Results - Unendorsed
(interactive)")
 patient = p.name_full_formatted
 ,edipi = edipi.alias
,order_dt_tm = DATETIMEZONEFORMAT(o.orig_order_dt_tm,
DATETIMEZONEBYNAME(tz.time_zone), "MM/DD/YYYY HH:MM;;q")
 ,orderable = oc.description
 ,event = UAR_GET_CODE_DISPLAY(ce.event_cd)
 ,result = ce.result_val
 ,result_units =
UAR_GET_CODE_DISPLAY(ce.result_units_cd)
 ,result_flag =
         IF(ce.normalcy_cd = 0)
""
         ELSE BUILD(
         TRIM(UAR_GET_CODE_DISPLAY(ce.normalcy_cd)),
" (",
         TRIM(UAR_GET_CODE_DESCRIPTION(ce.normalcy_cd)),
")")
 ENDIF
,endorse_status = UAR_GET_CODE_DISPLAY(cea.endorse_status_cd)
 ,performed_dt_tm =
DATETIMEZONEFORMAT(ce.performed_dt_tm, DATETIMEZONEBYNAME(tz.time_zone),
"MM/DD/YYYY HH:MM;;q")
 ,verified_dt_tm =
DATETIMEZONEFORMAT(ce.verified_dt_tm, DATETIMEZONEBYNAME(tz.time_zone),
"MM/DD/YYYY HH:MM;;q")
 ,encntr_type =
UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
 ,encntr_location =
UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
 ,order_placed_by =
         IF(oe_prsnl.position_cd
!= 0)
                 BUILD(oe_prsnl.name_full_formatted,
" (", TRIM(UAR_GET_CODE_DISPLAY(oe_prsnl.position_cd)),
")")
         ELSE
oe_prsnl.name_full_formatted
         ENDIF
 ,order_status =
UAR_GET_CODE_DISPLAY(o.order_status_cd)
 ,originating_fin = ofin.alias
 ,activating_fin = fin.alias
,o.order_id
,ce.event_id
FROM ORDER_ACTION oa
,PRSNL oe_prsnl
,ORDERS o
,(LEFT JOIN ENCNTR_ALIAS ofin ON ofin.encntr_id =
o.originating_encntr_id
AND ofin.encntr_alias_type_cd = 1077
AND ofin.active_ind = 1
AND ofin.end_effective_dt_tm > SYSDATE)
,(LEFT JOIN ENCNTR_ALIAS fin ON fin.encntr_id = o.encntr_id
AND fin.encntr_alias_type_cd = 1077
AND fin.active_ind = 1
AND fin.end_effective_dt_tm >
SYSDATE)
,ORDER_CATALOG oc
,PERSON p
,PERSON_ALIAS edipi
,CLINICAL_EVENT ce
 ,(LEFT JOIN CE_EVENT_PRSNL endorse ON
endorse.event_id = ce.event_id
         AND
endorse.action_type_cd IN (
                 678654        ;endorse
                 ,106        ;review
         )
         AND
endorse.valid_until_dt_tm > SYSDATE)
 ,CE_EVENT_ACTION cea
 ,ENCOUNTER e
 ,TIME_ZONE_R
tz
PLAN oa WHERE oa.action_type_cd = 2534 ;ordered
AND oa.order_provider_id = $prsnl
AND oa.action_dt_tm BETWEEN CNVTDATETIME($beg_date) AND
CNVTDATETIME($end_date)
JOIN oe_prsnl WHERE oe_prsnl.person_id = oa.action_personnel_id
JOIN o WHERE oa.order_id = o.order_id
AND o.catalog_type_cd IN (2513, 2517) ;lab/rad
AND o.order_status_cd NOT IN (2542, 2544) ;canceled, voided with
results
AND o.active_ind = 1
JOIN oc WHERE o.catalog_cd = oc.catalog_cd
AND oc.active_ind =
1
JOIN p WHERE p.person_id = o.person_id
AND p.active_ind = 1
JOIN edipi WHERE edipi.person_id = p.person_id
AND edipi.person_alias_type_cd = 22 ;EDIPI
AND edipi.end_effective_dt_tm > SYSDATE
AND edipi.active_ind = 1
JOIN ce WHERE ce.order_id = o.order_id
AND ce.view_level = 1
AND ce.result_status_cd NOT IN (28,29,30,31)
AND ce.valid_until_dt_tm > SYSDATE
JOIN cea WHERE cea.event_id = ce.event_id
JOIN e WHERE e.encntr_id = ce.encntr_id
AND e.encntr_type_class_cd != 391 ;exclude inpatient (do we need ED
excluded?)
JOIN tz WHERE tz.parent_entity_id = e.loc_facility_cd
AND tz.parent_entity_name = "LOCATION"
JOIN ofin
JOIN fin
 JOIN endorse
ORDER BY patient, order_dt_tm DESC, o.order_id, event
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
row+1 "<table border='1'>"
row+1 "<tr>"
row+1        "<th>&nbsp;</th>"
row+1        "<th>Patient</th>"
row+1        "<th>EDIPI</th>"
row+1        "<th>FIN</th>"
row+1
        "<th>Encounter
Type</th>"
row+1        "<th>Orderable</th>"
row+1
        "<th>Event</th>"
row+1
        "<th>Result</th>"
row+1 "</tr>"
DETAIL
i+=1
row+1 "<tr>"
row+1        call
print(td(CNVTSTRING(i)))
row+1        call
print(td(patient))
row+1        call
print(td(edipi))
row+1        call
print(td(chartlink(e.person_id, e.encntr_id, fin.alias)))
row+1         call
print(td(encntr_type))
row+1         call
print(td(orderable))
row+1        call
print(td(event))
row+1         call
print(td(TRIM(BUILD(result, " (", result_units, ")"))))
row+1 "</tr>"
FOOT REPORT
row+1 "</table>"
row+1 "</body>"
row+1
"</html>"
ELSEIF($last_tab
= "activity" AND $activity = "UICs Seen as Attending")
attending_provider = CONCAT(TRIM(p.name_full_formatted)," (",
TRIM(UAR_GET_CODE_DISPLAY(p.position_cd)), ")")
,assigned_unit = uic.alias
,nbr_patients = COUNT(DISTINCT e.person_id)
,nbr_encntrs = COUNT(DISTINCT epr.encntr_id)
,start_range = CNVTDATETIME($beg_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
FROM ENCNTR_PRSNL_RELTN epr
,ENCOUNTER e
,(LEFT JOIN PERSON_MILITARY pm ON pm.person_id = e.person_id
AND pm.active_ind = 1)
,(LEFT JOIN ORGANIZATION_ALIAS uic ON uic.organization_id =
pm.assigned_unit_org_id
AND uic.org_alias_type_cd = 1129 ;Employer Code
AND uic.active_ind = 1)
,PRSNL p
PLAN epr WHERE epr.prsnl_person_id = $prsnl
AND epr.encntr_prsnl_r_cd = 1119 ;attending provider
AND epr.active_ind = 1
JOIN e WHERE e.encntr_id = epr.encntr_id
AND e.reg_dt_tm BETWEEN CNVTDATETIME($beg_date) AND
CNVTDATETIME($end_date)
AND e.active_ind = 1
JOIN p WHERE p.person_id = epr.prsnl_person_id
JOIN pm
JOIN uic
GROUP BY p.name_full_formatted, p.position_cd, uic.alias
ORDER BY attending_provider, assigned_unit
/**************************************************************
; Config
Reports
**************************************************************/
ELSEIF($last_tab
= "config" AND $config = "Aliases")
personnel = prsnl_name
,alias_type = UAR_GET_CODE_DISPLAY(pa.prsnl_alias_type_cd)
,alias_pool = UAR_GET_CODE_DISPLAY(pa.alias_pool_cd)
,pa.alias
,pa.prsnl_alias_type_cd
,pa.alias_pool_cd
,last_updated = pa.updt_dt_tm "MM/DD/YYYY HH:MM;;q"
FROM PRSNL_ALIAS pa
PLAN pa WHERE pa.person_id = $prsnl
AND pa.end_effective_dt_tm > SYSDATE
AND pa.active_ind = 1
ORDER BY alias_type
ELSEIF($last_tab
= "config" AND $config = "Application Access")
DISTINCT
position = myexp->pos[d.seq].position
,app_group = UAR_GET_CODE_DISPLAY(ag.app_group_cd)
,application = a.description
,a.application_number
,a.object_name
FROM (DUMMYT d WITH seq = size(myexp->pos, 5))
,APPLICATION_GROUP ag
,APPLICATION_ACCESS aa
,APPLICATION a
PLAN d WHERE CNVTUPPER(myexp->pos[d.seq].position) != "Z*"
JOIN ag WHERE ag.position_cd = myexp->pos[d.seq].position_cd
AND ag.end_effective_dt_tm > SYSDATE
JOIN aa WHERE aa.app_group_cd = ag.app_group_cd
AND aa.active_ind = 1
JOIN a WHERE a.application_number = aa.application_number
AND a.active_ind = 1
ORDER BY CNVTUPPER(myexp->pos[d.seq].position)
,CNVTUPPER(UAR_GET_CODE_DISPLAY(ag.app_group_cd))
,CNVTUPPER(a.description)
,a.object_name
,a.application_number
ELSEIF($last_tab
= "config" AND $config = "Contact - Addresses")
personnel = prsnl_name
,address_type = UAR_GET_CODE_DISPLAY(a.address_type_cd)
,sequence = a.address_type_seq
,a.street_addr
,a.street_addr2
,a.street_addr3
,a.street_addr4
,a.city
,state =
IF(a.state_cd > 0) UAR_GET_CODE_DISPLAY(a.state_cd)
ELSE a.state
ENDIF
,a.zipcode
,a.zipcode_key
,county =
IF(a.county_cd > 0) UAR_GET_CODE_DISPLAY(a.county_cd)
ELSE a.county
ENDIF
,country =
IF(a.country_cd > 0) UAR_GET_CODE_DISPLAY(a.country_cd)
ELSE a.country
ENDIF
,contrib_sys = UAR_GET_CODE_DISPLAY(a.contributor_system_cd)
,last_updated = a.updt_dt_tm "MM/DD/YYYY HH:MM;;q"
,updated_by = updt_p.name_full_formatted
FROM ADDRESS a
,PRSNL updt_p
PLAN a WHERE a.parent_entity_id = $prsnl
AND a.parent_entity_name = "PERSON"
AND a.active_ind = 1
JOIN updt_p WHERE a.updt_id = updt_p.person_id
ORDER BY address_type, a.address_type_seq
ELSEIF($last_tab
= "config" AND $config = "Contact - Business")
personnel = p.name_full_formatted
,business_phone = bus_phone.phone_num_key "###-###-####"
,business_fax = bus_fax.phone_num_key "###-###-####"
,business_address1 = bus_addr.street_addr
,business_address2 = bus_addr.street_addr2
,bus_addr.city
,bus_addr.state
,bus_addr.zipcode
,p.email
FROM PRSNL p
,(LEFT JOIN (SELECT
person_id = parent_entity_id
,phone_num_key
,rn = ROW_NUMBER() OVER(PARTITION BY parent_entity_id ORDER BY
phone_type_seq)
FROM PHONE
WHERE 1=1
AND phone_type_cd = 163 ;business phone
AND active_ind = 1
AND end_effective_dt_tm > SYSDATE
WITH SQLTYPE("f8", "c20", "i2"))
bus_phone
ON p.person_id = bus_phone.person_id
AND bus_phone.rn = 1)
,(LEFT JOIN (SELECT
person_id = parent_entity_id
,phone_num_key
,rn = ROW_NUMBER() OVER(PARTITION BY parent_entity_id ORDER BY
phone_type_seq)
FROM PHONE
WHERE 1=1
AND phone_type_cd = 166 ;business fax
AND active_ind = 1
AND end_effective_dt_tm > SYSDATE
WITH SQLTYPE("f8", "c20", "i2")) bus_fax
ON p.person_id = bus_fax.person_id
AND bus_fax.rn =
1)
,(LEFT JOIN (SELECT
person_id = a.parent_entity_id
,a.street_addr
,a.street_addr2
,a.city
,state = cv.display
,a.zipcode
,rn = ROW_NUMBER() OVER(PARTITION BY a.parent_entity_id ORDER BY
a.address_type_seq)
FROM ADDRESS a, CODE_VALUE cv
WHERE 1=1
AND a.address_type_cd = 754 ;business
AND a.active_ind = 1
AND a.end_effective_dt_tm > SYSDATE
AND a.state_cd = cv.code_value
WITH SQLTYPE("f8", "c100", "c100",
"c100", "c4", "c20", "i2")) bus_addr
ON p.person_id = bus_addr.person_id
AND bus_addr.rn =
1)
PLAN p WHERE p.person_id = $prsnl
JOIN bus_phone
JOIN bus_fax
JOIN bus_addr
ELSEIF($last_tab
= "config" AND $config = "Contact - Phones")
personnel = prsnl_name
,ph.phone_num "###-###-####"
,phone_type = UAR_GET_CODE_DISPLAY(ph.phone_type_cd)
,sequence = ph.phone_type_seq
,last_updated = ph.updt_dt_tm "MM/DD/YYYY HH:MM;;q"
,updated_by = updt_p.name_full_formatted
FROM PHONE ph
,PRSNL updt_p
PLAN ph WHERE ph.parent_entity_id = $prsnl
JOIN ph WHERE p.person_id = ph.parent_entity_id
AND ph.parent_entity_name = "PERSON"
AND ph.active_ind = 1
JOIN updt_p WHERE ph.updt_id = updt_p.person_id
ORDER BY phone_type, ph.phone_type_seq
ELSEIF($last_tab
= "config" AND $config = "Keychains")
personnel = prsnl_name
,so.mnemonic
,association_type = UAR_GET_CODE_DISPLAY(sa.assoc_type_cd)
,association_added_dt_tm = sa.beg_effective_dt_tm "MM/DD/YYYY
HH:MM;;q"
,association_updated_dt_tm = sa.updt_dt_tm "MM/DD/YYYY
HH:MM;;q"
,association_updated_by =
IF(sa_p.position_cd != 0)
BUILD(sa_p.name_full_formatted, " (",
TRIM(UAR_GET_CODE_DISPLAY(sa_p.position_cd)), ")")
ELSE sa_p.name_full_formatted
ENDIF
FROM PRSNL p
,SCH_ASSOC sa
,SCH_OBJECT so
,PRSNL sa_p
PLAN sa WHERE sa.child_id = $prsnl
AND sa.end_effective_dt_tm > SYSDATE
AND sa.active_ind =
1
JOIN so WHERE so.sch_object_id = sa.parent_id
AND sa.parent_table = "SCH_OBJECT"
AND so.end_effective_dt_tm > SYSDATE
AND so.active_ind =
1
JOIN sa_p WHERE sa_p.person_id = sa.updt_id
ORDER BY association_type, so.mnemonic
ELSEIF($last_tab
= "config" AND $config = "Location Associations (HNA
User)")
personnel = prsnl_name
,location_type = UAR_GET_CODE_DISPLAY(loc.location_type_cd)
,location = UAR_GET_CODE_DISPLAY(loc.location_cd)
,pr.beg_effective_dt_tm
,last_updated_on = pr.updt_dt_tm
,last_updated_by = updt_p.name_full_formatted
FROM PRSNL_RELTN pr
,LOCATION loc
,PRSNL updt_p
PLAN pr WHERE pr.person_id = $prsnl
AND pr.reltn_type_cd = 3539696 ;personnel location relation
AND pr.end_effective_dt_tm > SYSDATE
AND pr.active_ind = 1
JOIN loc WHERE loc.location_cd = pr.parent_entity_id
AND pr.parent_entity_name = "LOCATION"
JOIN updt_p WHERE updt_p.person_id = pr.updt_id
ORDER BY location_type, location
ELSEIF($last_tab
= "config" AND $config = "Order Favorites")
path = SUBSTRING(1,1000,fav->item[d.seq].path)
,orderable = fav->item[d.seq].orderable
,order_mnemonic = fav->item[d.seq].order_mnemonic
,order_sentence = fav->item[d.seq].order_sentence
,catalog_type =
UAR_GET_CODE_DISPLAY(fav->item[d.seq].catalog_type_cd)
,activity_type =
UAR_GET_CODE_DISPLAY(fav->item[d.seq].activity_type_cd)
,activity_subtype =
UAR_GET_CODE_DISPLAY(fav->item[d.seq].activity_subtype_cd)
,last_saved_dt_tm = fav->item[d.seq].last_saved_dt_tm
"MM/DD/YYYY HH:MM;;q"
,catalog_cd = fav->item[d.seq].catalog_cd
,synonym_id = fav->item[d.seq].synonym_id
;,orderable_active_ind = fav->item[d.seq].order_active_ind
;,synonym_active_ind = fav->item[d.seq].synonym_active_ind
FROM (DUMMYT d with seq = value(size(fav->item, 5)))
PLAN d WHERE fav->item[d.seq].fav_type = "order"
ORDER BY path, CNVTUPPER(fav->item[d.seq].orderable)
ELSEIF($last_tab
= "config" AND $config = "Organization Relationships")
personnel = prsnl_name
,ag.agency
,organization = org.org_name
,confidence_level = UAR_GET_CODE_DISPLAY(por.confid_level_cd)
,por.beg_effective_dt_tm
FROM PRSNL_ORG_RELTN por
,ORGANIZATION org
,(LEFT JOIN CUST_LOC_AGENCY_RELTN ag ON org.organization_id =
ag.organization_id)
PLAN por WHERE por.person_id = $prsnl
AND por.end_effective_dt_tm > SYSDATE
AND por.active_ind = 1
JOIN org WHERE por.organization_id = org.organization_id
JOIN ag
ORDER BY ag.agency, org.org_name
ELSEIF($last_tab
= "config" AND $config = "Organization Set Relationships")
personnel = prsnl_name
,organization_set = os.name
,ospr.beg_effective_dt_tm
FROM ORG_SET_PRSNL_R ospr
,ORG_SET os
PLAN ospr WHERE ospr.prsnl_id = $prsnl
AND ospr.org_set_type_cd = 673001 ;security
AND ospr.active_ind = 1
JOIN os WHERE os.org_set_id = ospr.org_set_id
AND os.active_ind = 1
ORDER BY organization_set
ELSEIF($last_tab
= "config" AND $config = "Patient Empanelment (DoD)")
personnel = prsnl_name
,relationship = UAR_GET_CODE_DISPLAY(ppr.person_prsnl_r_cd)
,patient = CNVTUPPER(p.name_full_formatted)
,edipi = edipi.alias
,birth_dt_tm = DateBirthFormat(p.birth_dt_tm, p.birth_tz,
p.birth_prec_flag, "@SHORTDATETIME")
,current_age = CNVTAGE(p.birth_dt_tm, SYSDATE, 0)
,sex = UAR_GET_CODE_DISPLAY(p.sex_cd)
;,race = UAR_GET_CODE_DISPLAY(p.race_cd)
;,ethnicity = UAR_GET_CODE_DISPLAY(p.ethnic_grp_cd)
,special_duties = TRIM(PIECE(pal.alert_txt, ":", 2,
""),3)
,reltn_start_date = ppr.beg_effective_dt_tm
,reltn_end_date = ppr.end_effective_dt_tm
,e_reltn.num_encntrs
,a_reltn.as_attending
,as_other = e_reltn.total_encntr_reltn - a_reltn.as_attending
,e_reltn.total_encntr_reltn
,e_reltn.distinct_encntr_reltn
FROM PERSON_PRSNL_RELTN ppr
,PERSON p
,(LEFT JOIN PERSON_ALIAS edipi
ON p.person_id = edipi.person_id
AND edipi.person_alias_type_cd = 22 ;EDIPI
AND edipi.active_ind = 1
AND edipi.end_effective_dt_tm > SYSDATE)
,(LEFT JOIN PASSIVE_ALERT pal ON pal.person_id = p.person_id
AND pal.alert_source = "SZ_V2_SPECIAL_DUTY_STATUS"
AND pal.end_effective_dt_tm > SYSDATE)
,(LEFT JOIN (
SELECT
e.person_id
,num_encntrs = COUNT(DISTINCT epr.encntr_id)
,total_encntr_reltn = COUNT(epr.encntr_prsnl_reltn_id)
,distinct_encntr_reltn = COUNT(DISTINCT
epr.encntr_prsnl_r_cd)
FROM ENCNTR_PRSNL_RELTN epr
,ENCOUNTER e
WHERE epr.prsnl_person_id = $prsnl AND epr.active_ind = 1
AND e.encntr_id = epr.encntr_id AND e.active_ind = 1
GROUP BY e.person_id
WITH
SQLTYPE("f8","i4","i4","i4")
) e_reltn
ON p.person_id = e_reltn.person_id
)
,(LEFT JOIN (
SELECT
e.person_id
,as_attending = COUNT(epr.encntr_prsnl_reltn_id)
FROM ENCNTR_PRSNL_RELTN epr
,ENCOUNTER e
WHERE epr.prsnl_person_id = $prsnl
AND epr.encntr_prsnl_r_cd = 1119
AND epr.active_ind = 1
AND e.encntr_id = epr.encntr_id
AND e.active_ind = 1
GROUP BY e.person_id
WITH SQLTYPE("f8","i4")
) a_reltn
ON p.person_id = a_reltn.person_id
)
PLAN ppr WHERE ppr.prsnl_person_id = $prsnl
AND ppr.active_ind = 1
AND ppr.end_effective_dt_tm > SYSDATE
JOIN p WHERE ppr.person_id = p.person_id
JOIN edipi
JOIN pal
JOIN e_reltn
JOIN a_reltn
ORDER BY relationship, patient
ELSEIF($last_tab
= "config" AND $config = "Person Relationships *")
personnel = prsnl_name
,patient = CNVTUPPER(p.name_full_formatted)
,relationship = UAR_GET_CODE_DISPLAY(ppr.person_prsnl_r_cd)
,status =
         IF(ppr.active_ind = 1
AND ppr.end_effective_dt_tm > SYSDATE) "Current/Active"
         ELSEIF(ppr.active_ind =
1 AND ppr.end_effective_dt_tm <= SYSDATE) "Historical/Active"
         ELSEIF(ppr.active_ind =
0 AND ppr.end_effective_dt_tm > SYSDATE) "Current/Inactive"
         ELSEIF(ppr.active_ind =
0 AND ppr.end_effective_dt_tm <= SYSDATE) "Historical/Inactive"
         ELSE "unmapped
value"
         ENDIF
,ppr.beg_effective_dt_tm
,ppr.end_effective_dt_tm
,ppr.priority_seq
,ppr.active_ind
FROM PERSON_PRSNL_RELTN ppr
,PERSON p
PLAN ppr WHERE ppr.prsnl_person_id = $prsnl
AND ppr.beg_effective_dt_tm BETWEEN CNVTDATETIME($beg_date) AND
CNVTDATETIME($end_date)
OR ppr.end_effective_dt_tm > SYSDATE
JOIN p WHERE ppr.person_id = p.person_id
ORDER BY status, patient, ppr.beg_effective_dt_tm
ELSEIF($last_tab
= "config" AND $config = "Personnel Groups")
personnel = prsnl_name
,pg.prsnl_group_name
,prsnl_group_type = UAR_GET_CODE_DISPLAY(pg.prsnl_group_type_cd)
,added_on = pgr.updt_dt_tm
FROM PRSNL_GROUP_RELTN pgr
,PRSNL_GROUP pg
PLAN pgr WHERE pgr.person_id = $prsnl
AND pgr.end_effective_dt_tm > SYSDATE
AND pgr.active_ind = 1
JOIN pg WHERE pgr.prsnl_group_id = pg.prsnl_group_id
ORDER BY pg.prsnl_group_name, prsnl_group_type
ELSEIF($last_tab
= "config" AND $config = "PowerPlan Favorites")
path = SUBSTRING(1,1000,fav->item[d.seq].path)
,powerplan = fav->item[d.seq].powerplan
,favorited_name = fav->item[d.seq].powerplan_cust
,plan_type = fav->item[d.seq].plan_type
,version = fav->item[d.seq].version
,favorited_dt_tm = fav->item[d.seq].last_saved_dt_tm
"MM/DD/YYYY HH:MM;;q"
,last_ordered_dt_tm = fav->item[d.seq].last_ordered_dt_tm
"MM/DD/YYYY HH:MM;;q"
,plan_active_ind = fav->item[d.seq].plan_active_ind
,cust_plan_active_ind = fav->item[d.seq].cust_plan_active_ind
,pathway_catalog_id = fav->item[d.seq].pathway_catalog_id
,pathway_customized_plan_id =
fav->item[d.seq].pathway_customized_plan_id
;        ,p.order_dt_tm
;        ,p.pathway_customized_plan_id
FROM (DUMMYT d with seq = value(size(fav->item, 5)))
;                ,(LEFT
JOIN PATHWAY p ON p.pathway_catalog_id = fav->item[d.seq].pathway_catalog_id
;                        AND
p.active_ind = 1)
PLAN d WHERE fav->item[d.seq].fav_type = "pathway"
;        JOIN
p
ORDER BY path, CNVTUPPER(fav->item[d.seq].powerplan)
ELSEIF($last_tab
= "config" AND $config = "Prescribing Configuration")
personnel = p.name_full_formatted
,position = UAR_GET_CODE_DISPLAY(p.position_cd)
,p.physician_ind
,npi = npi.alias
,dea = dea.alias
,spi = spi.alias
,active =
IF(ed.end_effective_dt_tm > SYSDATE AND ed.service_level_nbr > 0)
"Yes"
ELSE "No"
ENDIF
,prescribing_location = UAR_GET_CODE_DESCRIPTION(pr.parent_entity_id)
,eprescribe_start = ed.beg_effective_dt_tm "MM/DD/YYYY;;d"
,eprescribe_end = ed.end_effective_dt_tm "MM/DD/YYYY;;d"
,epcs_nominated = IF(ed.cs_nominator_id > 0) "Yes" ELSE
"No" ENDIF
,epcs_permitted = IF(ed.cs_approver_sig_txt != NULL) "Yes"
ELSE "No" ENDIF
FROM PRSNL p
,(LEFT JOIN PRSNL_ALIAS npi ON npi.person_id = p.person_id
AND npi.prsnl_alias_type_cd = 4038127 ;NPIA
AND npi.end_effective_dt_tm > SYSDATE
AND npi.active_ind = 1)
,(LEFT JOIN PRSNL_ALIAS dea ON dea.person_id = p.person_id
AND dea.prsnl_alias_type_cd = 1084 ;DEA
AND dea.end_effective_dt_tm > SYSDATE
AND dea.active_ind =
1)
,PRSNL_RELTN pr
,EPRESCRIBE_DETAIL ed
,PRSNL_RELTN_CHILD prc
,PRSNL_ALIAS spi
PLAN p WHERE p.person_id = $prsnl
JOIN pr WHERE pr.person_id = p.person_id
AND pr.reltn_type_cd = 19162988 ;ePrescribing Relationship
AND pr.parent_entity_name = "LOCATION"
AND pr.active_ind = 1
JOIN ed WHERE ed.prsnl_reltn_id = pr.prsnl_reltn_id
AND ed.status_cd = 4053728 ;delivered (to SureScripts)
JOIN prc WHERE prc.prsnl_reltn_id = pr.prsnl_reltn_id
AND prc.parent_entity_name = "PRSNL_ALIAS"
JOIN spi WHERE spi.prsnl_alias_id = prc.parent_entity_id
AND spi.prsnl_alias_type_cd = 4045114 ;SureScripts Prescriber Index
AND spi.active_ind = 1
JOIN npi
JOIN dea
ORDER BY prescribing_location, npi, dea, spi, active DESC,
eprescribe_start
ELSEIF($last_tab
= "config" AND $config = "Proxies (current)")
DISTINCT
user_proxied = p.name_full_formatted
,user_position = UAR_GET_CODE_DISPLAY(p.position_cd)
,user_location =
 IF(va_loc.prsnl_alias_id !=
0) va_loc.alias
 ELSEIF(dod_loc.predicted_fac_cd != 0)
UAR_GET_CODE_DISPLAY(dod_loc.predicted_fac_cd)
 ELSE "unknown"
 ENDIF
,proxy_name = proxy_user.name_full_formatted
,proxy_position = UAR_GET_CODE_DISPLAY(proxy_user.position_cd)
,prox.beg_effective_dt_tm "MM/DD/YYYY;;d"
,prox.end_effective_dt_tm "MM/DD/YYYY;;d"
,prox.take_proxy_status_flag
,take_proxy_status = EVALUATE(prox.take_proxy_status_flag,
0, "Not a proxy row",
1, "Another user can take proxy",
2, "Another user has taken proxy",
3, "User acknowledges proxy was taken",
"Unknown flag value")
FROM PROXY prox
,PRSNL p
 ,(LEFT JOIN
CUST_DOD_PRSNL_LOC_RELTN dod_loc ON dod_loc.person_id = p.person_id)
 ,(LEFT JOIN PRSNL_ALIAS
va_loc ON va_loc.person_id = p.person_id
 AND va_loc.alias_pool_cd
= 364958627 ;VA employee primary location
 AND
va_loc.end_effective_dt_tm > SYSDATE
 AND va_loc.active_ind =
1)
,PRSNL proxy_user
PLAN prox WHERE prox.person_id = $prsnl
AND prox.end_effective_dt_tm > SYSDATE
AND prox.active_ind =
1
JOIN p WHERE prox.person_id = p.person_id
JOIN proxy_user WHERE proxy_user.person_id = prox.proxy_person_id
JOIN dod_loc
JOIN va_loc
ORDER BY p.name_full_formatted, prox.beg_effective_dt_tm
ELSEIF($last_tab
= "config" AND $config = "Proxies (historical)")
DISTINCT
user_proxied = p.name_full_formatted
,user_position = UAR_GET_CODE_DISPLAY(p.position_cd)
,user_location =
 IF(va_loc.prsnl_alias_id !=
0) va_loc.alias
 ELSEIF(dod_loc.predicted_fac_cd != 0)
UAR_GET_CODE_DISPLAY(dod_loc.predicted_fac_cd)
 ELSE "unknown"
 ENDIF
,proxy_name = proxy_user.name_full_formatted
,proxy_position = UAR_GET_CODE_DISPLAY(proxy_user.position_cd)
,prox.beg_effective_dt_tm "MM/DD/YYYY;;d"
,prox.end_effective_dt_tm "MM/DD/YYYY;;d"
,prox.take_proxy_status_flag
,take_proxy_status = EVALUATE(prox.take_proxy_status_flag,
0, "Not a proxy row",
1, "Another user can take proxy",
2, "Another user has taken proxy",
3, "User acknowledges proxy was taken",
"Unknown flag value")
FROM PROXY prox
,PRSNL p
 ,(LEFT JOIN
CUST_DOD_PRSNL_LOC_RELTN dod_loc ON dod_loc.person_id = p.person_id)
 ,(LEFT JOIN PRSNL_ALIAS
va_loc ON va_loc.person_id = p.person_id
 AND va_loc.alias_pool_cd
= 364958627 ;VA employee primary location
 AND
va_loc.end_effective_dt_tm > SYSDATE
 AND va_loc.active_ind =
1)
,PRSNL proxy_user
PLAN prox WHERE prox.person_id = $prsnl
AND prox.active_ind =
1
JOIN p WHERE prox.person_id = p.person_id
JOIN proxy_user WHERE proxy_user.person_id = prox.proxy_person_id
JOIN dod_loc
JOIN va_loc
ORDER BY p.name_full_formatted, prox.beg_effective_dt_tm
ELSEIF($last_tab
= "config" AND $config = "Roles Assigned By User")
assigner = p.name_full_formatted
,role_type = UAR_GET_CODE_DISPLAY(rtr.role_type_cd)
,assignee = pr.name_full_formatted
,assignee_username = pr.username
,action_taken = EVALUATE(prt.active_ind, 1, "granted",
"removed")
,action_dt_tm = prt.updt_dt_tm
,status =
         IF(prt.active_ind = 1
AND prt.end_effective_dt_tm > SYSDATE) "Active/Current"
         ELSEIF(prt.active_ind =
1 AND prt.end_effective_dt_tm <= SYSDATE) "Active/Historical"
         ELSEIF(prt.active_ind =
0 AND prt.end_effective_dt_tm > SYSDATE) "Inactive/Current"
         ELSEIF(prt.active_ind =
0 AND prt.end_effective_dt_tm <= SYSDATE) "Inactive/Historical"
         ELSE "unmapped
value"
         ENDIF
,prt.beg_effective_dt_tm
,prt.end_effective_dt_tm
,prt.active_ind
FROM PRSNL p
,PRSNL_ROLE_TYPE prt
,PRSNL pr
,ROLE_TYPE_RELTN rtr
,CODE_VALUE_EXTENSION cve
PLAN p WHERE p.person_id = $prsnl
JOIN prt WHERE prt.updt_id = p.person_id
JOIN pr WHERE pr.person_id = prt.person_id
JOIN rtr WHERE rtr.role_type_reltn_id =
prt.role_type_reltn_id
JOIN cve WHERE cve.code_value = rtr.role_type_cd
AND cve.code_set = 343575
AND cve.field_name = "AVAILABLE_POSITION_IND"
AND cve.field_value != "1" ;role types available in HNA User
ORDER BY assigner, role_type, assignee, prt.updt_dt_tm,
prt.end_effective_dt_tm
ELSEIF($last_tab
= "config" AND $config = "Roles Assigned To User")
personnel = p.name_full_formatted
,role_type = UAR_GET_CODE_DISPLAY(rtr.role_type_cd)
,role_active = EVALUATE(prt.active_ind, 1, "yes",
"no")
,prt.beg_effective_dt_tm
,prt.end_effective_dt_tm
,last_updated_dt_tm = prt.updt_dt_tm
,updated_by = prt_prsnl.name_full_formatted
,updater_position = UAR_GET_CODE_DISPLAY(prt_prsnl.position_cd)
,updater_username = prt_prsnl.username
,updater_email = prt_prsnl.email
FROM PRSNL p
,PRSNL_ROLE_TYPE prt
,ROLE_TYPE_RELTN rtr
,CODE_VALUE_EXTENSION cve
,PRSNL prt_prsnl
PLAN p WHERE p.person_id = $prsnl
JOIN prt WHERE prt.person_id = p.person_id
JOIN rtr WHERE rtr.role_type_reltn_id =
prt.role_type_reltn_id
JOIN prt_prsnl WHERE prt_prsnl.person_id = prt.updt_id
JOIN cve WHERE cve.code_value = rtr.role_type_cd
AND cve.code_set = 343575
AND cve.field_name = "AVAILABLE_POSITION_IND"
AND cve.field_value != "1" ;only role types available in HNA
User
ORDER BY personnel, role_type, prt.beg_effective_dt_tm
ELSEIF($last_tab
= "config" AND $config = "Roles Available (MyExperience)")
DISTINCT
position = myexp->pos[d.seq].position
,added_on = myexp->pos[d.seq].added_on "MM/DD/YYYY;;d"
,added_by = myexp->pos[d.seq].added_by
;,position_cd = myexp->pos[d.seq].position_cd
FROM (DUMMYT d WITH seq = size(myexp->pos, 5))
PLAN d WHERE CNVTUPPER(myexp->pos[d.seq].position) != "Z*"
ORDER BY CNVTUPPER(myexp->pos[d.seq].position)
ELSEIF($last_tab
= "config" AND $config = "Schedulable Locations")
resource = UAR_GET_CODE_DISPLAY(res.resource_cd)
,schedulable_location = UAR_GET_CODE_DISPLAY(appt_loc.location_cd)
,appointment_type = UAR_GET_CODE_DISPLAY(appt_loc.appt_type_cd)
,status = UAR_GET_CODE_DISPLAY(list_res.res_sch_cd)
,prsnl_name = p.name_full_formatted
,prsnl_position = UAR_GET_CODE_DISPLAY(p.position_cd)
,prsnl_person_id = p.person_id
,prsnl_resource_cd = res.resource_cd
FROM SCH_RESOURCE res
,SCH_LIST_RES list_res
,SCH_LIST_ROLE list_role
,SCH_RESOURCE_LIST res_list
,SCH_APPT_LOC appt_loc
,PRSNL p
PLAN res WHERE res.person_id = $prsnl
AND res.res_type_flag = 2 ;personnel
AND res.active_ind = 1
JOIN list_res WHERE list_res.resource_cd = res.resource_cd
AND list_res.end_effective_dt_tm > SYSDATE
AND list_res.active_ind = 1
JOIN list_role WHERE list_role.list_role_id = list_res.list_role_id
AND list_role.end_effective_dt_tm > SYSDATE
AND list_role.active_ind = 1
JOIN res_list WHERE res_list.res_list_id = list_role.res_list_id
AND res_list.end_effective_dt_tm > SYSDATE
AND res_list.active_ind =
1
JOIN appt_loc WHERE appt_loc.res_list_id = res_list.res_list_id
AND appt_loc.end_effective_dt_tm > SYSDATE
AND appt_loc.active_ind = 1
JOIN p WHERE res.person_id = p.person_id
ORDER BY resource, schedulable_location, appointment_type, status
ELSEIF($last_tab
= "config" AND $config = "Service Resources")
organization = org.org_name
,service_resource =
SUBSTRING(1,40,REPLACE_CRLF(UAR_GET_CODE_DISPLAY(res.service_resource_cd)))
,category = UAR_GET_CODE_DISPLAY(res.discipline_type_cd)
,activity_type = UAR_GET_CODE_DISPLAY(res.activity_type_cd)
,resource_type = UAR_GET_CODE_DISPLAY(res.service_resource_type_cd)
,res.service_resource_cd
FROM PRSNL_SERVICE_RESOURCE_RELTN psr
,SERVICE_RESOURCE res
,ORGANIZATION org
PLAN psr WHERE psr.prsnl_id = $prsnl
JOIN res WHERE res.service_resource_cd = psr.service_resource_cd
AND res.end_effective_dt_tm > SYSDATE
AND res.active_ind =
1
JOIN org WHERE org.organization_id = res.organization_id
AND org.active_ind = 1
ORDER BY organization, category, activity_type, resource_type,
service_resource
ELSEIF($last_tab
= "config" AND $config = "Taxonomy")
personnel = p.name_full_formatted
,position = UAR_GET_CODE_DISPLAY(p.position_cd)
,p.physician_ind
,npi = npi.alias
,tax.taxonomy
,classification = UAR_GET_CODE_DISPLAY(tax.classification_cd)
,provider_type = UAR_GET_CODE_DISPLAY(tax.provider_type_cd)
,specialization = UAR_GET_CODE_DISPLAY(tax.specialization_cd)
,prsnl_id = p.person_id
FROM EEM_PROV_TAX_RELTN eptr
,PRSNL p
,(LEFT JOIN PRSNL_ALIAS npi ON npi.person_id = p.person_id
AND npi.prsnl_alias_type_cd = 4038127 ;NPI
AND npi.end_effective_dt_tm > SYSDATE
AND npi.active_ind = 1)
,PROVIDER_TAXONOMY tax
PLAN eptr WHERE eptr.parent_entity_id = $prsnl
AND eptr.end_effective_dt_tm > SYSDATE
AND eptr.active_ind = 1
JOIN p WHERE p.person_id = eptr.parent_entity_id
JOIN tax WHERE tax.taxonomy_id = eptr.taxonomy_id
AND tax.active_ind = 1
JOIN npi
ORDER BY classification, provider_type, specialization
ELSEIF($last_tab
= "config" AND $config = "Templates and Slots")
resource = UAR_GET_CODE_DISPLAY(sda.resource_cd)
,template = sds.mnemonic
,applied_from = sda.beg_dt_tm
,applied_to = sda.end_dt_tm
,m = evaluate(substring(2,1,sda.days_of_week), "X",
"M", "")
,t = evaluate(substring(3,1,sda.days_of_week), "X",
"T", "")
,w = evaluate(substring(4,1,sda.days_of_week), "X",
"W", "")
,th = evaluate(substring(5,1,sda.days_of_week), "X",
"Th", "")
,f = evaluate(substring(6,1,sda.days_of_week), "X",
"F", "")
,sa = evaluate(substring(7,1,sda.days_of_week), "X",
"Sa", "")
,su = evaluate(substring(1,1,sda.days_of_week), "X",
"Su", "")
; Slot info
,day_begin = sds.beg_tm "##:##"
,day_end = sds.end_tm "##:##"
,slot_type = slot.slot_mnemonic
,slot_start =
CNVTLOOKAHEAD(BUILD(slot.beg_offset,",MIN"),
CNVTDATETIME(BUILD("01-JAN-1900 ",
FORMAT(CNVTSTRING(sds.beg_tm), "##:##")))) "HH:MM;;q"
,slot_end =
CNVTLOOKAHEAD(BUILD((slot.beg_offset+slot.duration),",MIN"),
CNVTDATETIME(BUILD("01-JAN-1900 ",
FORMAT(CNVTSTRING(sds.beg_tm), "##:##")))) "HH:MM;;q"
,slot.duration
,slot_interval = slot.interval
,slot_release =
IF(slot.vis_beg_units_cd > 0) "SLOT RELEASE TO"
ELSEIF(slot.vis_end_units_cd > 0) "SLOT RELEASE FROM"
ELSE "UNKNOWN"
ENDIF
,release_value =
IF(slot.vis_beg_units > 0 OR slot.vis_beg_units < -1)
CNVTSTRING(slot.vis_beg_units)
ELSE ""
ENDIF
,release_unit = slot.vis_beg_units_meaning
; Template application info
,applied_on = sda.apply_dt_tm "MM/DD/YYYY HH:MM;;q"
,next_applied_dt_tm = sf.next_dt_tm "MM/DD/YYYY
HH:MM;;q"
,applied_pattern = sf.freq_pattern_meaning
,applied_status = sf.freq_state_meaning
,applied_range = EVALUATE(sf.apply_range, 0, "Default Range",
TRIM(CNVTSTRING(sf.apply_range),3))
,applied_by = BUILD(TRIM(apply_p.name_full_formatted), " (",
TRIM(UAR_GET_CODE_DISPLAY(apply_p.position_cd)),
")")
,template_status = sda.def_state_meaning
,template_last_updated_on = sds.updt_dt_tm
,template_last_updated_by = updt_p.name_full_formatted
FROM SCH_RESOURCE sr
,SCH_DEF_APPLY sda
,SCH_FREQ sf
,SCH_DEF_SCHED sds
,PRSNL apply_p
,SCH_DEF_SLOT slot
,PRSNL updt_p
PLAN sr WHERE sr.person_id = $prsnl
JOIN sda WHERE sda.resource_cd = sr.resource_cd
AND sda.end_dt_tm > SYSDATE
AND sda.active_ind = 1
JOIN sf WHERE sf.parent_id = sda.def_apply_id
AND sf.version_dt_tm > SYSDATE
AND sf.active_ind = 1
JOIN sds WHERE sds.def_sched_id = sda.def_sched_id
AND sds.active_ind = 1
JOIN apply_p WHERE apply_p.person_id = sda.apply_prsnl_id
JOIN slot WHERE slot.def_sched_id = sda.def_sched_id
JOIN updt_p WHERE updt_p.person_id = sds.updt_id
ORDER BY template, sda.beg_dt_tm
ELSEIF($last_tab
= "config" AND $config = "Work Locations")
personnel = prsnl_name
,p.email
,agency =
IF(        (vloc.prsnl_alias_id
!= 0 AND dloc.person_id = 0)
OR CNVTUPPER(p.email) = "*VA*") "VA"
ELSEIF(vloc.prsnl_alias_id = 0 AND dloc.person_id != 0)
IF(CNVTUPPER(p.email) = "*USCG*") "USCG"
ELSE "DOD"
ENDIF
ELSE "ambiguous"
ENDIF
,va_location = vloc.alias
,dod_predicted_facility = UAR_GET_CODE_DISPLAY(dloc.predicted_fac_cd)
,dod_predicted_location = UAR_GET_CODE_DISPLAY(dloc.predicted_loc_cd)
,dod_assigned_facility = UAR_GET_CODE_DISPLAY(dloc.assigned_fac_cd)
,dod_assigned_location = UAR_GET_CODE_DISPLAY(dloc.assigned_loc_cd)
FROM PRSNL p
,(LEFT JOIN CUST_DOD_PRSNL_LOC_RELTN dloc ON dloc.person_id =
p.person_id)
,(LEFT JOIN PRSNL_ALIAS vloc ON vloc.person_id = p.person_id
AND vloc.alias_pool_cd = 364958627 ;VA employee primary location
AND vloc.end_effective_dt_tm > SYSDATE
AND vloc.active_ind = 1)
PLAN p WHERE p.person_id = $prsnl
JOIN dloc
JOIN vloc
ENDIF
INTO $OUTDEV
;error = "Invalid prompt selections"
debug_reached = "true"
,prsnl = $prsnl
,tab = $tab
,activity = $activity
,config = $config
,beg_date = $beg_date
,end_date = $end_date
WITH
NOCOUNTER, SEPARATOR=" ", FORMAT, TIME=600, CHECK, MAXCOL=1000
end
go
