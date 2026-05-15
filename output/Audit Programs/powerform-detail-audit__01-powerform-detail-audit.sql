/*
 * Source page  : PowerForm Detail Audit
 * Source file  : output/powerform-detail-audit.md
 * Anchor       : (top of page)
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 1500
 *
 * Context (preceding paragraph):
 *   Exported: 4/13/26
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

drop program
dev_rpt_pf_detail_audit go
create
program dev_rpt_pf_detail_audit
/******************************************************************************
 REPORT NAME:
        PowerForm Detail Audit
 PROGRAM:                1fed_rpt_pf_detail_audit.prg
 DEV_VERS:                dev_rpt_pf_detail_audit.prg
 DEVELOPER:        David Alt
(david.a.alt2.mil@health.mil)
 PUBLISHED:        11/19/2024
 SNAPSHOT:
        08/06/2025
 LOGICAL
PATH:        cust_script
 NODE:                        <default>
 PURPOSE/DESCRIPTION: These reports are intended to support
solution owners/experts with
                                                 PowerForm
configuration. The adhoc reports show PowerForm availability
                                                 via
the Adhoc menu in PowerChart and do not include PowerForms that are
                                                 not
configured for direct user access. The PowerForm list and search
                                                 reports
do not have that restriciton. Usage reports are designed to show
                                                 general
activity to assist configuration decisions and should not be used
                                                 for
PowerForm workflow compliance monitoring.
 TARGET AUDIENCE: Solution owners/experts involved in
PowerForm configuration.
 FAQS:
         Q: Why doesn't the "Adhoc search by
position" report include a position column?
         A: The user isn't actually selecting a position
in the prompt - they're selecting a root folder id,
                 which
is associated with a combination of a position and application. The record
structures
                 used
in that report don't include position information, thus it can't be included in
the output.
         Q:        Why
don't you combine "Adhoc position-root map" and "Adhoc root-task
map" into a single output?
         A:        There
is too much data to display, and it would be very duplicative - basically
repeating the same
                 hierarchy
for position after position. The two can be combined in Excel for users that
need a single
                 comprehensive
output.
MOD        DATE                DEVELOPER                COMMENT
---        --/--/--        ---------                ----------------------------
001        01/26/23        David
Alt                First
version published
002        08/07/24        David
Alt                Post-validation
changes; prompt redesign (val POC: Jessica Rennaker)
003        08/28/24        David
Alt                Post-validation
changes (val POC: Rebekah Campbell)
004        08/30/24        David
Alt                Fixed
path-task assignment issue (val POC: Colby Uptegraft)
005        10/01/24        David
Alt                Added
Usage (by position) (val POC: Jennifer Wilson)
006        11/05/24        David
Alt                Added
parent event set/textual rendition to PowerForm List
007        11/19/24        David
Alt                Initial
approval by AGB - published
008        03/04/25        David
Alt                Added
nbr_unique_patients to usage reports
009        06/30/25        David
Alt                Added
Layout
Added dcp_form_instance_id to Configuration
010        07/22/25        David
Alt                Increased
character limits for PowerForm search results
011        08/06/25        David
Alt                Added
input_default_value to Configuration
--- pending changes ---
TODO:
Add textual rendition associations (associated note/event_cd/ESH
parent/LOINC/etc.)
Add event set info for forms
Consider prompt redesign to include agency/facility filters for usage
audits
******************************************************************************/
prompt
"Output to File/Printer/MINE" = "MINE" ;* Enter or select the printer or file name
to send this report to.
, "Report" = ""
;<<hidden>>"Info" = ""
, "Search" = "*"
, "Search Result" = 0
, "Position" = 0
, "Usage Start Date" = "SYSDATE"
, "Usage End Date" = "SYSDATE"
with OUTDEV,
rpt, search, search_result, position, start_date, end_date
/**************************************************************
; Global
Declarations
**************************************************************/
declare IDX =
i4 with noconstant(0) ;index for EXPAND
declare NUM =
i4 with noconstant(0) ;indices for LOCATEVAL
declare POS =
i4 with noconstant(0) ;indices for LOCATEVAL
declare
form_bit = i4 with protect,constant(1)
declare
section_bit = i4 with protect,constant(2)
declare
question_bit = i4 with protect,constant(4)
/**************************************************************
; Record
Structures
**************************************************************/
free record
prm ;position-root map
record prm (
1 pos[*]
2 position_cd = f8
2 position = c40
2 agency = c5
2 application = c60
2 alt_sel_category_id = f8
2 adhoc_root = c60
) with
protect ;position-root map
free record
ftm ;folder-task map
record ftm (
1 fldr[*]
2 alt_sel_category_id = f8
2 folder = c60
2 task_cnt = i4
2 task[*]
3 reference_task_id = f8
3 task = c40
3 sequence = i4
3 dcp_forms_ref_id = f8
3 powerform_display_name = c40
3 powerform_unique_name = c40
) with
protect ;folder-task map
free record
fm ;folder map
record fm (
1 fldr[*]
2 folder_id = f8 ;alt_sel_category_id
2 parent_id = f8 ;alt_sel_category_id
2 root_id = f8 ;alt_sel_category_id
2 root_ind = i2
2 folder = c60
2 folder_unique = c60
2 parent = c60
2 root = c60
2 root_unique = c60
2 path = vc
2 task_cnt = i4
2 task[*]
3 reference_task_id = f8
3 task = c40
3 sequence = i4
3 dcp_forms_ref_id = f8
3 powerform_display_name = c40
3 powerform_unique_name =
c40
) with
protect ;folder map
free record
map
record map (
1 list[*]
2 folder_id = f8 ;alt_sel_category_id
2 parent_id = f8 ;alt_sel_category_id
2 root_id = f8 ;alt_sel_category_id
2 root_ind = i2
2 folder = c60
2 parent = c60
2 root = c60
2 path = vc
2 reference_task_id = f8
2 task = c40
2 sequence = i4
2 dcp_forms_ref_id = f8
2 powerform_display_name = c40
2 powerform_unique_name =
c40
) with
protect ;map
; used for
powerform search
free record
pf
record pf (
1 list[*]
2 dcp_forms_ref_id = f8
2 form_display_name = c100
2 form_unique_name = c100
2 reference_task_id = f8
2 task = c60
2 result_bit = i4
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
(build_prm_record(input=NULL) = NULL)
         SELECT
INTO "NL:"
FROM APP_PREFS ap
,APPLICATION a
,NAME_VALUE_PREFS nvp
,ALT_SEL_CAT r
PLAN ap WHERE ap.active_ind = 1
AND ap.position_cd > 0
AND ap.prsnl_id = 0
AND EXISTS(SELECT 1
FROM CODE_VALUE cv
WHERE cv.code_value = ap.position_cd
AND cv.code_set = 88
AND cv.active_ind = 1)
JOIN a WHERE ap.application_number = a.application_number
AND a.active_ind = 1
JOIN nvp WHERE ap.app_prefs_id = nvp.parent_entity_id
AND nvp.parent_entity_name = "APP_PREFS"
AND nvp.pvc_name = "ADHOC_ROOT"
JOIN r WHERE r.alt_sel_category_id = CNVTREAL(TRIM(nvp.pvc_value))
AND r.adhoc_ind = 1
;ORDER BY position, application
 HEAD REPORT
 i = 0
 DETAIL
 i += 1
 CALL ALTERLIST(prm->pos, i)
 prm->pos[i].position_cd =
ap.position_cd
 prm->pos[i].position =
UAR_GET_CODE_DISPLAY(ap.position_cd)
         IF(UAR_GET_CODE_DISPLAY(ap.position_cd)
= "VA*") prm->pos[i].agency = "VA"
         ELSE
prm->pos[i].agency = "DOD"
         ENDIF
 prm->pos[i].application =
a.description
 prm->pos[i].alt_sel_category_id =
r.alt_sel_category_id
 prm->pos[i].adhoc_root =
r.short_description
WITH nocounter
end
;build_prm_record
subroutine
(build_ftm_record(input = NULL) = NULL)
SELECT INTO "NL:"
FROM ALT_SEL_CAT c        
        ;category
,ALT_SEL_LIST ctr
        ;category-task reltn
,ORDER_TASK ot        
        ;task-form reltn
,(LEFT JOIN DCP_FORMS_REF
f        ON f.dcp_forms_ref_id =
ot.dcp_forms_ref_id
AND f.active_ind = 1
AND f.end_effective_dt_tm > SYSDATE)
PLAN c WHERE c.adhoc_ind = 1 ;only get adhoc folders
JOIN ctr WHERE ctr.alt_sel_category_id = c.alt_sel_category_id
AND ctr.list_type = 4 ;reference tasks - ensure we only get
bottom-level folders
JOIN ot WHERE ot.reference_task_id = ctr.reference_task_id
AND ot.active_ind = 1
JOIN f
ORDER BY c.alt_sel_category_id, ot.reference_task_id
HEAD REPORT
i = 0 ;category
j = 0 ;task
HEAD c.alt_sel_category_id ;each folder
i += 1
j = 0 ;reset task counter
CALL ALTERLIST(ftm->fldr, i)
ftm->fldr[i].alt_sel_category_id = c.alt_sel_category_id
ftm->fldr[i].folder = c.short_description
ftm->fldr[i].task_cnt = 0
DETAIL ; ot.reference_task_id ;each task (adhoc) in the folder
IF(ot.reference_task_id > 0)
j += 1
CALL ALTERLIST(ftm->fldr[i].task, j)
ftm->fldr[i].task_cnt += 1
ftm->fldr[i].task[j].reference_task_id = ctr.reference_task_id
ftm->fldr[i].task[j].sequence = ctr.sequence
ftm->fldr[i].task[j].task = ot.task_description
ftm->fldr[i].task[j].dcp_forms_ref_id = ot.dcp_forms_ref_id
ftm->fldr[i].task[j].powerform_display_name = f.description
ftm->fldr[i].task[j].powerform_unique_name = f.definition
ENDIF
WITH nocounter
end
;build_ftm_record
subroutine
(build_fm_record(input = NULL) = NULL)
SELECT INTO "NL:"
FROM ALT_SEL_CAT c1
,ALT_SEL_LIST cr1
,(LEFT JOIN ALT_SEL_CAT c2 ON c2.alt_sel_category_id =
cr1.child_alt_sel_cat_id)
,(LEFT JOIN ALT_SEL_LIST cr2 ON cr2.alt_sel_category_id =
c2.alt_sel_category_id
AND cr2.list_type = 1) ;folder
,(LEFT JOIN ALT_SEL_CAT c3 ON c3.alt_sel_category_id =
cr2.child_alt_sel_cat_id)
,(LEFT JOIN ALT_SEL_LIST cr3 ON cr3.alt_sel_category_id =
c3.alt_sel_category_id
AND cr3.list_type = 1) ;folder
,(LEFT JOIN ALT_SEL_CAT c4 ON c4.alt_sel_category_id =
cr3.child_alt_sel_cat_id)
,(LEFT JOIN ALT_SEL_LIST cr4 ON cr4.alt_sel_category_id =
c4.alt_sel_category_id
AND cr4.list_type = 1) ;folder
,(LEFT JOIN ALT_SEL_CAT c5 ON c5.alt_sel_category_id =
cr4.child_alt_sel_cat_id)
,(LEFT JOIN ALT_SEL_LIST cr5 ON cr5.alt_sel_category_id =
c5.alt_sel_category_id
AND cr5.list_type = 1)
;folder
,(LEFT JOIN ALT_SEL_CAT c6 ON c6.alt_sel_category_id =
cr5.child_alt_sel_cat_id)
,(LEFT JOIN ALT_SEL_LIST cr6 ON cr6.alt_sel_category_id =
c6.alt_sel_category_id
AND cr6.list_type = 1)
;folder
,(LEFT JOIN ALT_SEL_CAT c7 ON c7.alt_sel_category_id =
cr6.child_alt_sel_cat_id)
,(LEFT JOIN ALT_SEL_LIST cr7 ON cr7.alt_sel_category_id =
c7.alt_sel_category_id
AND cr7.list_type = 1) ;folder
,(LEFT JOIN ALT_SEL_CAT c8 ON c8.alt_sel_category_id =
cr7.child_alt_sel_cat_id)
,(LEFT JOIN ALT_SEL_LIST cr8 ON cr8.alt_sel_category_id =
c8.alt_sel_category_id
AND cr8.list_type = 1)
;folder
PLAN c1 WHERE CNVTUPPER(c1.short_description) = "ROOT*"
AND c1.adhoc_ind = 1
JOIN cr1 WHERE cr1.alt_sel_category_id = c1.alt_sel_category_id
AND cr1.list_type = 1 ;folder
JOIN c2
JOIN cr2
JOIN c3
JOIN cr3
JOIN c4
JOIN cr4
JOIN c5
JOIN cr5
JOIN c6
JOIN cr6
JOIN c7
JOIN cr7
JOIN c8
JOIN cr8
ORDER BY c1.alt_sel_category_id, cr1.sequence, cr2.sequence,
cr3.sequence, cr4.sequence,
 cr5.sequence, cr6.sequence,
cr7.sequence, cr8.sequence
HEAD REPORT
i = 0
HEAD c1.alt_sel_category_id ;root folders
i += 1
CALL ALTERLIST(fm->fldr,
i)
fm->fldr[i].folder_id = c1.alt_sel_category_id
fm->fldr[i].folder = c1.short_description
fm->fldr[i].folder_unique = c1.long_description
fm->fldr[i].root_ind = 1
fm->fldr[i].root_id = c1.alt_sel_category_id
fm->fldr[i].root = c1.short_description
fm->fldr[i].root_unique = c1.long_description
fm->fldr[i].parent_id = 0 ;root folder
fm->fldr[i].parent = ""
fm->fldr[i].path = c1.short_description
HEAD c2.alt_sel_category_id ;level 2
IF(c2.alt_sel_category_id > 0)
i += 1
CALL ALTERLIST(fm->fldr,
i)
fm->fldr[i].folder_id = c2.alt_sel_category_id
fm->fldr[i].folder = c2.short_description
fm->fldr[i].folder_unique = c2.long_description
fm->fldr[i].root_ind = 0
fm->fldr[i].root_id = c1.alt_sel_category_id
fm->fldr[i].root = c1.short_description
fm->fldr[i].root_unique = c1.long_description
fm->fldr[i].parent_id = c1.alt_sel_category_id
fm->fldr[i].parent = c1.short_description
fm->fldr[i].path =
BUILD(        c1.short_description,
"\",
c2.short_description)
ENDIF
HEAD c3.alt_sel_category_id ;level 3
IF(c3.alt_sel_category_id > 0)
i += 1
CALL ALTERLIST(fm->fldr,
i)
fm->fldr[i].folder_id = c3.alt_sel_category_id
fm->fldr[i].folder = c3.short_description
fm->fldr[i].folder_unique = c3.long_description
fm->fldr[i].root_ind = 0
fm->fldr[i].root_id = c1.alt_sel_category_id
fm->fldr[i].root = c1.short_description
fm->fldr[i].root_unique = c1.long_description
fm->fldr[i].parent_id = c2.alt_sel_category_id
fm->fldr[i].parent = c2.short_description
fm->fldr[i].path =
BUILD(        c1.short_description,
"\",
c2.short_description, "\",
c3.short_description)
ENDIF
HEAD c4.alt_sel_category_id ;level 4
IF(c4.alt_sel_category_id > 0)
i += 1
CALL ALTERLIST(fm->fldr,
i)
fm->fldr[i].folder_id = c4.alt_sel_category_id
fm->fldr[i].folder = c4.short_description
fm->fldr[i].folder_unique = c4.long_description
fm->fldr[i].root_ind = 0
fm->fldr[i].root_id = c1.alt_sel_category_id
fm->fldr[i].root = c1.short_description
fm->fldr[i].root_unique = c1.long_description
fm->fldr[i].parent_id = c3.alt_sel_category_id
fm->fldr[i].parent = c3.short_description
fm->fldr[i].path =
BUILD(        c1.short_description,
"\",
c2.short_description, "\",
c3.short_description, "\",
c4.short_description)
ENDIF
HEAD c5.alt_sel_category_id ;level 5
IF(c5.alt_sel_category_id > 0)
i += 1
CALL ALTERLIST(fm->fldr,
i)
fm->fldr[i].folder_id = c5.alt_sel_category_id
fm->fldr[i].folder = c5.short_description
fm->fldr[i].folder_unique = c5.long_description
fm->fldr[i].root_ind = 0
fm->fldr[i].root_id = c1.alt_sel_category_id
fm->fldr[i].root = c1.short_description
fm->fldr[i].root_unique = c1.long_description
fm->fldr[i].parent_id = c4.alt_sel_category_id
fm->fldr[i].parent = c4.short_description
fm->fldr[i].path =
BUILD(        c1.short_description,
"\",
c2.short_description, "\",
c3.short_description, "\",
c4.short_description, "\",
c5.short_description)
ENDIF
HEAD c6.alt_sel_category_id ;level 6
IF(c6.alt_sel_category_id > 0)
i += 1
CALL ALTERLIST(fm->fldr,
i)
fm->fldr[i].folder_id = c6.alt_sel_category_id
fm->fldr[i].folder = c6.short_description
fm->fldr[i].folder_unique = c6.long_description
fm->fldr[i].root_ind = 0
fm->fldr[i].root_id = c1.alt_sel_category_id
fm->fldr[i].root = c1.short_description
fm->fldr[i].root_unique = c1.long_description
fm->fldr[i].parent_id = c5.alt_sel_category_id
fm->fldr[i].parent = c5.short_description
fm->fldr[i].path =
BUILD(        c1.short_description,
"\",
c2.short_description, "\",
c3.short_description, "\",
c4.short_description, "\",
c5.short_description, "\",
c6.short_description)
ENDIF
HEAD c7.alt_sel_category_id ;level 7
IF(c7.alt_sel_category_id > 0)
i += 1
CALL ALTERLIST(fm->fldr,
i)
fm->fldr[i].folder_id = c7.alt_sel_category_id
fm->fldr[i].folder = c7.short_description
fm->fldr[i].folder_unique = c7.long_description
fm->fldr[i].root_ind = 0
fm->fldr[i].root_id = c1.alt_sel_category_id
fm->fldr[i].root = c1.short_description
fm->fldr[i].root_unique = c1.long_description
fm->fldr[i].parent_id = c6.alt_sel_category_id
fm->fldr[i].parent = c6.short_description
fm->fldr[i].path =
BUILD(        c1.short_description,
"\",
c2.short_description, "\",
c3.short_description, "\",
c4.short_description, "\",
c5.short_description, "\",
c6.short_description, "\",
c7.short_description)
ENDIF
HEAD c8.alt_sel_category_id ;level 8
IF(c8.alt_sel_category_id > 0)
i += 1
CALL ALTERLIST(fm->fldr,
i)
fm->fldr[i].folder_id = c8.alt_sel_category_id
fm->fldr[i].folder = c8.short_description
fm->fldr[i].folder_unique = c8.long_description
fm->fldr[i].root_ind = 0
fm->fldr[i].root_id = c1.alt_sel_category_id
fm->fldr[i].root = c1.short_description
fm->fldr[i].root_unique = c1.long_description
fm->fldr[i].parent_id = c7.alt_sel_category_id
fm->fldr[i].parent = c7.short_description
fm->fldr[i].path =
BUILD(        c1.short_description,
"\",
c2.short_description, "\",
c3.short_description, "\",
c4.short_description, "\",
c5.short_description, "\",
c6.short_description, "\",
c7.short_description, "\",
c8.short_description)
ENDIF
WITH nocounter
end
;build_fm_record
subroutine
(add_tasks_to_fm_record(input = NULL) = NULL)
declare pos = i4 with protect, noconstant(0)
declare idx = i4 with protect, noconstant(0)
;for each row in the folder map
 FOR (i = 1 TO size(fm->fldr, 5))
         ;locate the matching
folder in ftm
         SET pos =
LOCATEVALSORT(idx, 1, size(ftm->fldr, 5), ;index variable, start, end
fm->fldr[i].folder_id, ;what you're looking for
ftm->fldr[idx].alt_sel_category_id) ;where you're looking
IF(pos > 0) ;child folder with tasks
SET fm->fldr[i].task_cnt = ftm->fldr[pos].task_cnt
CALL ALTERLIST(fm->fldr[i].task, ftm->fldr[pos].task_cnt)
FOR (j = 1 TO ftm->fldr[pos].task_cnt)
SET fm->fldr[i].task[j].task = ftm->fldr[pos].task[j].task
SET fm->fldr[i].task[j].sequence =
ftm->fldr[pos].task[j].sequence
SET fm->fldr[i].task[j].reference_task_id =
ftm->fldr[pos].task[j].reference_task_id
SET fm->fldr[i].task[j].powerform_display_name =
ftm->fldr[pos].task[j].powerform_display_name
SET fm->fldr[i].task[j].powerform_unique_name =
ftm->fldr[pos].task[j].powerform_unique_name
SET fm->fldr[i].task[j].dcp_forms_ref_id =
ftm->fldr[pos].task[j].dcp_forms_ref_id
ENDFOR
ELSE ;parent folder with no tasks
CALL ALTERLIST(fm->fldr[i].task, 1)
SET fm->fldr[i].task[1].task = ""
SET fm->fldr[i].task[1].sequence = 0
SET fm->fldr[i].task[1].reference_task_id = 0
SET fm->fldr[i].task[1].powerform_display_name = ""
SET fm->fldr[i].task[1].powerform_unique_name = ""
SET fm->fldr[i].task[1].dcp_forms_ref_id = 0
ENDIF
 ENDFOR
end
;add_tasks_to_fm_record
subroutine
(build_map_record(input = NULL) = NULL)
declare adhoc_cnt = i4 with noconstant(0)
FOR (i = 1 TO size(fm->fldr, 5))
IF(size(fm->fldr[i].task, 5) > 0)
FOR (j = 1 TO size(fm->fldr[i].task, 5))
SET adhoc_cnt += 1
CALL ALTERLIST(map->list, adhoc_cnt)
SET map->list[adhoc_cnt].folder_id = fm->fldr[i].folder_id
SET map->list[adhoc_cnt].parent_id = fm->fldr[i].parent_id
SET map->list[adhoc_cnt].root_id = fm->fldr[i].root_id
SET map->list[adhoc_cnt].folder = fm->fldr[i].folder
SET map->list[adhoc_cnt].parent = fm->fldr[i].parent
SET map->list[adhoc_cnt].root = fm->fldr[i].root
SET map->list[adhoc_cnt].path = fm->fldr[i].path
SET map->list[adhoc_cnt].reference_task_id =
fm->fldr[i].task[j].reference_task_id
SET map->list[adhoc_cnt].task = fm->fldr[i].task[j].task
SET map->list[adhoc_cnt].sequence = fm->fldr[i].task[j].sequence
SET map->list[adhoc_cnt].dcp_forms_ref_id =
fm->fldr[i].task[j].dcp_forms_ref_id
SET map->list[adhoc_cnt].powerform_display_name =
fm->fldr[i].task[j].powerform_display_name
SET map->list[adhoc_cnt].powerform_unique_name =
fm->fldr[i].task[j].powerform_unique_name
ENDFOR
ENDIF
ENDFOR
end
;build_map_record
; Evaluate
where the search results were found
subroutine
(eval_result_bit(result_bit=i4) = vc)
declare output = vc with protect
declare change_cnt = i2 with protect
declare trunc_len = i2 with protect
set output = ""
set change_cnt = 0
IF(BAND(result_bit, form_bit) = form_bit)
set output = CONCAT(output, "form,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(result_bit, section_bit) = section_bit)
set output = CONCAT(output, "section,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(result_bit, question_bit) = question_bit)
set output = CONCAT(output, "question (DTA),")
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
; Builds the
PF (PowerForm) record, but only if that report is selected
subroutine
(build_pf_record(NULL) = NULL)
;check in forms
SELECT INTO "NL:"
FROM DCP_FORMS_REF f
PLAN f WHERE CNVTUPPER(f.definition) =
PATSTRING(CONCAT("*",$search,"*"))
AND CNVTUPPER(f.definition) != "ZZ*"
AND f.active_ind = 1
AND f.end_effective_dt_tm > SYSDATE
ORDER BY f.dcp_forms_ref_id
HEAD REPORT
i = 0
DETAIL
i += 1
CALL ALTERLIST(pf->list, i)
pf->list[i].dcp_forms_ref_id = f.dcp_forms_ref_id
pf->list[i].form_display_name = f.description
pf->list[i].form_unique_name = f.definition
pf->list[i].result_bit = form_bit
WITH NULLREPORT
;check in sections
SELECT INTO "NL:"
FROM DCP_SECTION_REF s
,DCP_FORMS_DEF fd
,DCP_FORMS_REF f
PLAN s WHERE CNVTUPPER(s.description) =
PATSTRING(CONCAT("*",$search,"*"))
AND CNVTUPPER(s.description) != "ZZ*"
AND s.active_ind = 1
AND s.end_effective_dt_tm > SYSDATE
JOIN fd WHERE s.dcp_section_ref_id = fd.dcp_section_ref_id
AND fd.active_ind = 1
JOIN f WHERE fd.dcp_form_instance_id = f.dcp_form_instance_id
AND CNVTUPPER(f.definition) != "ZZ*"
AND f.active_ind = 1
AND f.end_effective_dt_tm > SYSDATE
ORDER BY f.dcp_forms_ref_id
HEAD REPORT
i = size(pf->list, 5)
DETAIL
;check if already exists
pos = LOCATEVAL(num, 1, size(pf->list, 5),
f.dcp_forms_ref_id,
pf->list[num].dcp_forms_ref_id)
IF(pos > 0) ;already exists, flag it
IF(BAND(pf->list[pos].result_bit, section_bit) != section_bit)
pf->list[pos].result_bit += section_bit
ENDIF
ELSE ;needs to be added to the record
i += 1
CALL ALTERLIST(pf->list, i)
pf->list[i].dcp_forms_ref_id = f.dcp_forms_ref_id
pf->list[i].form_display_name = f.description
pf->list[i].form_unique_name = f.definition
pf->list[i].result_bit = section_bit
ENDIF
WITH NULLREPORT
;check in DTAs
SELECT INTO "NL:"
FROM DISCRETE_TASK_ASSAY dta
,NAME_VALUE_PREFS nvp
,DCP_INPUT_REF i
,DCP_SECTION_REF s
,DCP_FORMS_DEF fd
,DCP_FORMS_REF f
PLAN dta WHERE 1=1
AND CNVTUPPER(dta.mnemonic) =
PATSTRING(CONCAT("*",$search,"*"))
AND dta.mnemonic_key_cap != "ZZ*"
AND dta.active_ind = 1
AND dta.end_effective_dt_tm > SYSDATE
JOIN nvp WHERE dta.task_assay_cd = nvp.merge_id
AND nvp.merge_name = "DISCRETE_TASK_ASSAY"
JOIN i WHERE nvp.parent_entity_name = "DCP_INPUT_REF"
AND nvp.parent_entity_id = i.dcp_input_ref_id
AND i.active_ind = 1
JOIN s WHERE i.dcp_section_instance_id = s.dcp_section_instance_id
AND s.dcp_section_ref_id = i.dcp_section_ref_id
AND CNVTUPPER(s.description) != "ZZ*"
AND s.active_ind = 1
AND s.end_effective_dt_tm > SYSDATE
JOIN fd WHERE s.dcp_section_ref_id = fd.dcp_section_ref_id
AND fd.active_ind = 1
JOIN f WHERE fd.dcp_form_instance_id = f.dcp_form_instance_id
AND CNVTUPPER(f.definition) != "ZZ*"
AND f.active_ind = 1
AND f.end_effective_dt_tm > SYSDATE
ORDER BY f.dcp_forms_ref_id
HEAD REPORT
i = size(pf->list, 5); - 1
DETAIL
;check if already exists
pos = LOCATEVAL(num, 1, size(pf->list, 5),
f.dcp_forms_ref_id,
pf->list[num].dcp_forms_ref_id)
IF(pos > 0) ;already exists, flag it
IF(BAND(pf->list[pos].result_bit, question_bit) != question_bit)
pf->list[pos].result_bit += question_bit
ENDIF
ELSE ;needs to be added to the record
i += 1
CALL ALTERLIST(pf->list, i)
pf->list[i].dcp_forms_ref_id = f.dcp_forms_ref_id
pf->list[i].form_display_name = f.description
pf->list[i].form_unique_name = f.definition
pf->list[i].result_bit = question_bit
ENDIF
WITH NULLREPORT
;Finally, populate the reference task ids
SELECT INTO "NL:"
FROM ORDER_TASK t
PLAN t WHERE EXPAND(idx, 1, size(pf->list, 5),
t.dcp_forms_ref_id,
pf->list[idx].dcp_forms_ref_id)
AND t.active_ind = 1
DETAIL
pos = LOCATEVAL(num, 1, size(pf->list, 5),
t.dcp_forms_ref_id,
pf->list[num].dcp_forms_ref_id)
IF(pos > 0)
pf->list[pos].task = t.task_description
pf->list[pos].reference_task_id = t.reference_task_id
ENDIF
WITH NULLREPORT
end
/**************************************************************
; Main
**************************************************************/
;only call
these if relevant report selected
IF($rpt =
"Adhoc*")
IF($rpt = "Adhoc search*")
CALL build_pf_record(NULL) ;search results
ENDIF
CALL build_prm_record(NULL)
CALL build_ftm_record(NULL)
CALL build_fm_record(NULL)
CALL add_tasks_to_fm_record(NULL)
CALL build_map_record(NULL)
ELSEIF($rpt =
"PowerForm search")
CALL build_pf_record(NULL) ;search results
ENDIF
/**************************************************************
; Output
**************************************************************/
SELECT
;Error
checking - report requires powerform selection
IF($rpt IN
("Configuration", "Layout", "Mpages", "Order
tasks", "Usage*")
AND $search_result = 0)
error = "You must select at least one PowerForm"
;Error
checking = report requires position selection
ELSEIF($rpt
IN ("Adhoc by position")
AND $position = 0)
error = "You must select a position"
ELSEIF($rpt =
"Adhoc by position")
path = SUBSTRING(1,512, fm->fldr[f.seq].path)
,task = fm->fldr[f.seq].task[t.seq].task
,task_seq = fm->fldr[f.seq].task[t.seq].sequence
,powerform_display_name =
fm->fldr[f.seq].task[t.seq].powerform_display_name
,powerform_unique_name =
fm->fldr[f.seq].task[t.seq].powerform_unique_name
,folder = fm->fldr[f.seq].folder
,root = fm->fldr[f.seq].root
,root_ind = fm->fldr[f.seq].root_ind
,root_id = fm->fldr[f.seq].root_id
,parent_id = fm->fldr[f.seq].parent_id
,folder_id = fm->fldr[f.seq].folder_id
,task_id = fm->fldr[f.seq].task[t.seq].reference_task_id
,dcp_forms_ref_id = fm->fldr[f.seq].task[t.seq].dcp_forms_ref_id
FROM (DUMMYT f WITH seq = value(size(fm->fldr, 5)))
,(DUMMYT t WITH seq = 1)
PLAN f WHERE maxrec(t, size(fm->fldr[f.seq].task, 5))
AND fm->fldr[f.seq].root_id = $position
JOIN t
ORDER BY path, task_seq, task
ELSEIF($rpt =
"Adhoc search")
DISTINCT
position = prm->pos[d3.seq].position
,task = map->list[d2.seq].task
,path = SUBSTRING(1,512, map->list[d2.seq].path)
,search_term = $search
,found_in = SUBSTRING(1,500,
eval_result_bit(pf->list[d.seq].result_bit))
,powerform_display_name = map->list[d2.seq].powerform_display_name
,dcp_forms_ref_id = pf->list[d.seq].dcp_forms_ref_id
FROM (DUMMYT d WITH seq = value(size(pf->list, 5)))
,(DUMMYT d2 WITH seq = value(size(map->list, 5)))
,(DUMMYT d3 WITH seq = value(size(prm->pos, 5)))
PLAN d
JOIN d2 WHERE map->list[d2.seq].dcp_forms_ref_id =
pf->list[d.seq].dcp_forms_ref_id
JOIN d3 WHERE prm->pos[d3.seq].alt_sel_category_id =
map->list[d2.seq].root_id
ORDER BY position, task, path, search_term, found_in,
powerform_display_name,
dcp_forms_ref_id
ELSEIF($rpt =
"Adhoc search by position")
task = map->list[d2.seq].task
,path = SUBSTRING(1,512, map->list[d2.seq].path)
,search_term = $search
,found_in = SUBSTRING(1,500,
eval_result_bit(pf->list[d.seq].result_bit))
,powerform_display_name = map->list[d2.seq].powerform_display_name
,dcp_forms_ref_id = pf->list[d.seq].dcp_forms_ref_id
FROM (DUMMYT d WITH seq = value(size(pf->list, 5)))
,(DUMMYT d2 with seq = value(size(map->list, 5)))
PLAN d
JOIN d2 WHERE map->list[d2.seq].dcp_forms_ref_id =
pf->list[d.seq].dcp_forms_ref_id
AND map->list[d2.seq].root_id = $position
ORDER BY task, path, search_term, found_in, powerform_display_name,
dcp_forms_ref_id
ELSEIF($rpt =
"Adhoc position-root map")
agency = prm->pos[d.seq].agency
,position = prm->pos[d.seq].position
,application = prm->pos[d.seq].application
,adhoc_root = prm->pos[d.seq].adhoc_root
,alt_sel_category_id = prm->pos[d.seq].alt_sel_category_id
FROM (DUMMYT d WITH seq = value(size(prm->pos, 5)))
PLAN d
ORDER BY agency, position, application
ELSEIF($rpt =
"Adhoc root-task map")
path = SUBSTRING(1,512, fm->fldr[f.seq].path)
,task = fm->fldr[f.seq].task[t.seq].task
,task_seq = fm->fldr[f.seq].task[t.seq].sequence
,powerform_display_name =
fm->fldr[f.seq].task[t.seq].powerform_display_name
,powerform_unique_name =
fm->fldr[f.seq].task[t.seq].powerform_unique_name
,folder = fm->fldr[f.seq].folder
,root = fm->fldr[f.seq].root
,root_ind = fm->fldr[f.seq].root_ind
,root_id = fm->fldr[f.seq].root_id
,parent_id = fm->fldr[f.seq].parent_id
,folder_id = fm->fldr[f.seq].folder_id
,task_id = fm->fldr[f.seq].task[t.seq].reference_task_id
,dcp_forms_ref_id = fm->fldr[f.seq].task[t.seq].dcp_forms_ref_id
FROM (DUMMYT f WITH seq = value(size(fm->fldr, 5)))
,(DUMMYT t WITH seq = 1)
PLAN f WHERE maxrec(t, size(fm->fldr[f.seq].task, 5))
JOIN t
ORDER BY path, task_seq, task
ELSEIF($rpt =
"Configuration")
powerform_display_name = forms_ref.description
,powerform_unique_name = forms_ref.definition
,section_display_name = sec_ref.description
,section_unique_name = sec_ref.definition
,section_sequence = forms_def.section_seq
,input_description = input_ref.description
,input_sequence = input_ref.input_ref_seq
,input_type = EVALUATE(input_ref.input_type
, 1, "Label"
, 4, "Alpha List"
, 6, "Free Text (255 char)"
, 7, "Calculated Field"
, 9, "Alpha Combo Box"
,10, "Date/Time"
,13, "Rich Text"
,14, "Discrete Grid"
,17, "Power Grid"
,18, "Provider Selection"
,19, "Ultra Grid"
,21, "Conversion Control"
,22, "Numeric"
,BUILD("Unmapped (",CNVTSTRING(input_ref.input_type),
")")
)
;,input_defaults.pvc_name
;,df_flag = input_defaults.pvc_value
,input_default_value =
IF(input_defaults.name_value_prefs_id != 0 AND input_defaults.pvc_value
IS NOT NULL)
IF(input_ref.input_type = 4) ;alpha list
EVALUATE(CNVTINT(input_defaults.pvc_value),
1, "Default from reference range",
2, "Default from last charted value (any encounter)",
3, "Use interpretation",
4, "Default from last charted value (this encounter)",
"Unknown flag value")
ELSEIF(input_ref.input_type = 6) ;free text
EVALUATE(CNVTINT(input_defaults.pvc_value),
1, "Default from last charted value (any encounter)",
2, "Custom default value",
3, "Default from the template script",
4, "Default from last charted value (this encounter)",
"Unknown flag value")
ELSEIF(input_ref.input_type = 9) ;alpha combo box
EVALUATE(CNVTINT(input_defaults.pvc_value),
1, "Default from reference range",
2, "Default from last charted value (any encounter)",
3, "Use interpretation",
4, "Default from last charted value (this encounter)",
"Unknown flag
value")
ELSEIF(input_ref.input_type = 10) ;date/time
EVALUATE(CNVTINT(input_defaults.pvc_value),
1, "Default from last charted value (any encounter)",
2, "Default to current date/time",
4, "Default from last charted value (this encounter)",
"Unknown flag value")
ELSEIF(input_ref.input_type = 13) ;rich text
EVALUATE(CNVTINT(input_defaults.pvc_value),
2, "Default from last charted value (any encounter)",
4, "Default from last charted value (this encounter)",
"Unknown flag value")
ELSEIF(input_ref.input_type = 14) ;discrete grid
EVALUATE(CNVTINT(input_defaults.pvc_value),
1, "Default from reference range",
2, "Default from last charted value (any encounter)",
4, "Default from last charted value (this encounter)",
"Unknown flag value")
ELSEIF(input_ref.input_type = 18) ;provider
EVALUATE(CNVTINT(input_defaults.pvc_value),
1, "Default from last charted value (any encounter)",
2, "Default current user",
4, "Default from last charted value (this encounter)",
"Unknown flag
value")
ELSEIF(input_ref.input_type = 19) ;ultragrid
EVALUATE(CNVTINT(input_defaults.pvc_value),
1, "Default from reference range",
2, "Default from last charted value (any encounter)",
4, "Default from last charted value (this encounter)",
"Unknown flag
value")
ELSEIF(input_ref.input_type = 22) ;numeric
EVALUATE(CNVTINT(input_defaults.pvc_value),
1, "Default from reference range",
2, "Default from last charted value (any encounter)",
4, "Default from last charted value (this encounter)",
"Unknown flag
value")
ELSE
BUILD("Unmapped combination; flag value=",
input_defaults.pvc_value)
ENDIF
ELSEIF(input_defaults.name_value_prefs_id != 0 AND
input_defaults.pvc_value IS NULL)
"No default value"
ELSE "N/A"
ENDIF
,dta_mnemonic = dta.mnemonic
,dta_result_type = UAR_GET_CODE_DISPLAY(dta.default_result_type_cd)
;,dta.default_type_flag
,dta_default_value = EVALUATE(dta.default_type_flag,
0, "No default value",
1, "Default from the reference range",
2, "Default from last charted value (any encounter)",
3, "Default from the template script",
"Unknown flag value")
,dta.task_assay_cd
,event_name =
IF(cvr.event_cd > 0) UAR_GET_CODE_DISPLAY(cvr.event_cd)
ELSE UAR_GET_CODE_DISPLAY(dta.event_cd)
ENDIF
,event_cd =
IF(cvr.event_cd > 0) cvr.event_cd
ELSE dta.event_cd
ENDIF
,required_field = required.pvc_value
,free_text = free_text.pvc_value
,multi_select = multi_select.pvc_value
,first_alpha_single_select = first_alpha_single_select.pvc_value
,lookback_minutes = lookback.offset_min_nbr
,forms_ref.dcp_forms_ref_id
,forms_ref.dcp_form_instance_id
FROM DCP_FORMS_REF forms_ref
,DCP_FORMS_DEF forms_def
,DCP_SECTION_REF sec_ref
,DCP_INPUT_REF input_ref
,(LEFT JOIN NAME_VALUE_PREFS required ON input_ref.dcp_input_ref_id =
required.parent_entity_id
AND required.parent_entity_name = "DCP_INPUT_REF"
AND required.pvc_name = "required")
,(LEFT JOIN NAME_VALUE_PREFS free_text ON input_ref.dcp_input_ref_id =
free_text.parent_entity_id
AND free_text.parent_entity_name = "DCP_INPUT_REF"
AND free_text.pvc_name = "freetext")
,(LEFT JOIN NAME_VALUE_PREFS multi_select ON input_ref.dcp_input_ref_id
= multi_select.parent_entity_id
AND multi_select.parent_entity_name = "DCP_INPUT_REF"
AND multi_select.pvc_name = "mult*select")
,(LEFT JOIN NAME_VALUE_PREFS first_alpha_single_select
ON input_ref.dcp_input_ref_id =
first_alpha_single_select.parent_entity_id
AND first_alpha_single_select.parent_entity_name =
"DCP_INPUT_REF"
AND first_alpha_single_select.pvc_name = "exclude_first_ar")
,(LEFT JOIN NAME_VALUE_PREFS input_defaults ON
input_ref.dcp_input_ref_id = input_defaults.parent_entity_id
AND input_defaults.parent_entity_name = "DCP_INPUT_REF"
AND input_defaults.pvc_name = "*default")
;AND input_defaults.pvc_name != "default_freetext")
,NAME_VALUE_PREFS nvp
,DISCRETE_TASK_ASSAY dta
,(LEFT JOIN DTA_OFFSET_MIN lookback
ON lookback.task_assay_cd = dta.task_assay_cd
AND lookback.end_effective_dt_tm > SYSDATE
AND lookback.active_ind = 1)
,(LEFT JOIN CODE_VALUE_EVENT_R cvr ON dta.task_assay_cd =
cvr.parent_cd)
; NOTE: doing inner join to NVP/DTA excludes input controls not tied to
DTAs, like labels
PLAN forms_ref WHERE forms_ref.dcp_forms_ref_id = $search_result
AND forms_ref.end_effective_dt_tm > SYSDATE
AND forms_ref.active_ind = 1
JOIN forms_def WHERE forms_ref.dcp_form_instance_id =
forms_def.dcp_form_instance_id
AND forms_def.active_ind = 1
JOIN sec_ref WHERE forms_def.dcp_section_ref_id =
sec_ref.dcp_section_ref_id
AND sec_ref.active_ind = 1
AND sec_ref.end_effective_dt_tm > SYSDATE
JOIN input_ref WHERE sec_ref.dcp_section_instance_id =
input_ref.dcp_section_instance_id
AND input_ref.active_ind = 1
JOIN nvp WHERE input_ref.dcp_input_ref_id = nvp.parent_entity_id
AND nvp.parent_entity_name = "DCP_INPUT_REF"
AND nvp.merge_name = "DISCRETE_TASK_ASSAY"
JOIN dta WHERE nvp.merge_id = dta.task_assay_cd
AND dta.end_effective_dt_tm > SYSDATE
AND dta.active_ind = 1
JOIN required
JOIN free_text
JOIN multi_select
JOIN first_alpha_single_select
JOIN input_defaults
JOIN lookback
JOIN cvr
ORDER BY powerform_display_name, forms_def.section_seq,
input_ref.input_ref_seq
ELSEIF($rpt =
"Layout")
powerform_display_name = forms_ref.description
,powerform_unique_name = forms_ref.definition
,section_display_name = sec_ref.description
,section_unique_name = sec_ref.definition
,section_sequence = forms_def.section_seq
,input_description =
IF(caption.name_value_prefs_id != 0) replace_crlf(caption.pvc_value)
ELSE input_ref.description
ENDIF
,input_sequence = input_ref.input_ref_seq
,input_type = EVALUATE(input_ref.input_type
, 1, "Label"
, 4, "Alpha List"
, 6, "Free Text (255 char)"
, 7, "Calculated Field"
, 9, "Alpha Combo Box"
,10, "Date/Time"
,13, "Rich Text"
,14, "Discrete Grid"
,17, "Power Grid"
,18, "Provider Selection"
,19, "Ultra Grid"
,21, "Conversion Control"
,22, "Numeric"
,BUILD("Unmapped (",CNVTSTRING(input_ref.input_type),
")")
)
,left = PIECE(position.pvc_value, ",", 1, "not
found")
,top = PIECE(position.pvc_value, ",", 2, "not
found")
;,right = PIECE(position.pvc_value, ",", 3, "not
found")
;,bottom = PIECE(position.pvc_value, ",", 4, "not
found")
,width = CNVTINT(PIECE(position.pvc_value, ",", 3, "not
found")) - CNVTINT(PIECE(position.pvc_value, ",", 1, "not
found"))
,height = CNVTINT(PIECE(position.pvc_value, ",", 4, "not
found")) - CNVTINT(PIECE(position.pvc_value, ",", 2, "not
found"))
,forecolor =
IF(TEXTLEN(TRIM(forecolor.pvc_value)) != 0)
CONCAT("#", CNVTB10B16(CNVTINT(forecolor.pvc_value), 6))
ELSE ""
ENDIF
,backcolor = ;CNVTB10B16(CNVTINT(backcolor.pvc_value), 6)
IF(TEXTLEN(TRIM(backcolor.pvc_value)) != 0)
CONCAT("#", CNVTB10B16(CNVTINT(backcolor.pvc_value), 6))
ELSE ""
ENDIF
,font = font.pvc_value
,font_size = fontsize.pvc_value
,font_effects = fonteffects.pvc_value
;1, "bold",
,forms_ref.dcp_forms_ref_id
,input_ref.dcp_section_ref_id
,input_ref.dcp_input_ref_id
FROM DCP_FORMS_REF forms_ref
,DCP_FORMS_DEF forms_def
,DCP_SECTION_REF sec_ref
,DCP_INPUT_REF input_ref
,(LEFT JOIN NAME_VALUE_PREFS caption ON caption.parent_entity_id =
input_ref.dcp_input_ref_id
AND caption.parent_entity_name = "DCP_INPUT_REF"
AND caption.pvc_name = "caption")
,(LEFT JOIN NAME_VALUE_PREFS position ON position.parent_entity_id =
input_ref.dcp_input_ref_id
AND position.parent_entity_name = "DCP_INPUT_REF"
AND position.pvc_name = "position")
,(LEFT JOIN NAME_VALUE_PREFS forecolor ON forecolor.parent_entity_id =
input_ref.dcp_input_ref_id
AND forecolor.parent_entity_name = "DCP_INPUT_REF"
AND forecolor.pvc_name = "forecolor")
,(LEFT JOIN NAME_VALUE_PREFS backcolor ON backcolor.parent_entity_id =
input_ref.dcp_input_ref_id
AND backcolor.parent_entity_name = "DCP_INPUT_REF"
AND backcolor.pvc_name = "backcolor")
,(LEFT JOIN NAME_VALUE_PREFS font ON font.parent_entity_id =
input_ref.dcp_input_ref_id
AND font.parent_entity_name = "DCP_INPUT_REF"
AND font.pvc_name = "facename")
,(LEFT JOIN NAME_VALUE_PREFS fontsize ON fontsize.parent_entity_id =
input_ref.dcp_input_ref_id
AND fontsize.parent_entity_name = "DCP_INPUT_REF"
AND fontsize.pvc_name = "pointsize")
,(LEFT JOIN NAME_VALUE_PREFS fonteffects ON
fonteffects.parent_entity_id = input_ref.dcp_input_ref_id
AND fonteffects.parent_entity_name = "DCP_INPUT_REF"
AND fonteffects.pvc_name = "fonteffects")
PLAN forms_ref WHERE forms_ref.dcp_forms_ref_id = $search_result
AND forms_ref.end_effective_dt_tm > SYSDATE
AND forms_ref.active_ind = 1
JOIN forms_def WHERE forms_ref.dcp_form_instance_id =
forms_def.dcp_form_instance_id
AND forms_def.active_ind = 1
JOIN sec_ref WHERE forms_def.dcp_section_ref_id =
sec_ref.dcp_section_ref_id
AND sec_ref.active_ind = 1
AND sec_ref.end_effective_dt_tm > SYSDATE
JOIN input_ref WHERE sec_ref.dcp_section_instance_id =
input_ref.dcp_section_instance_id
AND input_ref.active_ind = 1
JOIN caption
JOIN position
JOIN forecolor
JOIN backcolor
JOIN font
JOIN fontsize
JOIN fonteffects
ORDER BY powerform_display_name, forms_def.section_seq,
input_ref.input_ref_seq
ELSEIF($rpt =
"Mpages")
powerform_display_name = form.description
,powerform_unique_name = form.definition
,mpage = mp.category_name
,component = c.report_name
,mpage_id = mp.br_datamart_category_id
,component_id = c.br_datamart_report_id
,filter_id = f.br_datamart_filter_id
,form_id = form.dcp_forms_ref_id
FROM DCP_FORMS_REF form
,BR_DATAMART_VALUE v
,BR_DATAMART_FILTER f
,BR_DATAMART_REPORT_FILTER_R cf
,BR_DATAMART_REPORT c
,BR_DATAMART_CATEGORY mp
PLAN form WHERE 1=1
AND form.dcp_forms_ref_id = $search_result
AND form.active_ind = 1
AND form.end_effective_dt_tm > SYSDATE
JOIN v WHERE v.parent_entity_id = form.dcp_forms_ref_id
AND v.parent_entity_name = "DCP_FORMS_REF"
AND v.end_effective_dt_tm > SYSDATE
JOIN f WHERE f.br_datamart_filter_id = v.br_datamart_filter_id
JOIN cf WHERE cf.br_datamart_filter_id = f.br_datamart_filter_id
JOIN c WHERE c.br_datamart_report_id = cf.br_datamart_report_id
JOIN mp WHERE mp.br_datamart_category_id = c.br_datamart_category_id
AND mp.category_type_flag = 1 ;mpage
AND mp.br_datamart_category_id > 0
ORDER BY powerform_display_name, mpage, component
ELSEIF($rpt =
"Order tasks")
powerform_display_name = f.description
,powerform_unique_name = f.definition
,ot.task_description
;indicators
,ot.active_ind
,ot.capture_bill_info_ind
,ot.ignore_req_ind
,chart_as_done_ind = ot.quick_chart_done_ind
,ot.quick_chart_ind
,neither_ind = ot.quick_chart_notdone_ind ;naming bugs me
,ot.chart_not_cmplt_ind ;not on UI
,overdue_time_frame = ot.overdue_min
,overdue_units = EVALUATE(ot.overdue_units,
1, "minutes",
2, "hours",
"")
;retention
,retained_time_frame = ot.retain_time
,retained_time_units = EVALUATE(ot.retain_units,
1, "minutes",
2, "hours",
3, "days",
4, "weeks",
5, "months",
"")
;other
,task_type = UAR_GET_CODE_DISPLAY(ot.task_type_cd)
,task_activity = UAR_GET_CODE_DISPLAY(ot.task_activity_cd)
,ot.grace_period_mins
,reschedule_time = BUILD(ot.reschedule_time, " hours") ;add
"hours"
;event code
,event = UAR_GET_CODE_DISPLAY(ot.event_cd)
;positions
,ot.allpositionchart_ind
,pos_cnt.nbr_positions
;not on UI
;,ot.app_object_name
;,process_location = UAR_GET_CODE_DISPLAY(ot.process_location_cd)
,f.dcp_forms_ref_id
,ot.reference_task_id
FROM DCP_FORMS_REF f
,ORDER_TASK ot
,(LEFT JOIN (
SELECT xr.reference_task_id, nbr_positions = COUNT(*)
FROM ORDER_TASK_POSITION_XREF xr
,CODE_VALUE cv
WHERE xr.position_cd = cv.code_value
AND cv.code_set = 88
AND cv.active_ind = 1
GROUP BY xr.reference_task_id
WITH SQLTYPE("f8","i4")) pos_cnt
 ON ot.reference_task_id =
pos_cnt.reference_task_id)
PLAN f WHERE f.dcp_forms_ref_id = $search_result
AND f.active_ind = 1
AND f.end_effective_dt_tm > SYSDATE
JOIN ot WHERE ot.dcp_forms_ref_id = f.dcp_forms_ref_id
AND ot.active_ind = 1
JOIN pos_cnt
ORDER BY powerform_display_name, ot.task_description
;TODO - add
more useful output
ELSEIF($rpt =
"PowerForm list")
 powerform_display_name = f.description
 ,powerform_unique_name = f.definition
 ,f.dcp_forms_ref_id
 ,f.dcp_form_instance_id
 ,form_event_set = f.event_set_name
 ,form_event =
UAR_GET_CODE_DISPLAY(f.event_cd)
 ,form_event_cd = f.event_cd
,text_rendition_event = UAR_GET_CODE_DISPLAY(f.text_rendition_event_cd)
,text_rendition_parent =
UAR_GET_CODE_DISPLAY(pesc.parent_event_set_cd)
 ,f.text_rendition_event_cd
,trnt.note_type_id
 ,f.active_ind
 ,f.end_effective_dt_tm
 FROM DCP_FORMS_REF f
,(LEFT JOIN V500_EVENT_CODE vec ON vec.event_cd =
f.text_rendition_event_cd)
,(LEFT JOIN V500_EVENT_SET_CODE vesc ON
CNVTUPPER(TRIM(vesc.event_set_name)) = CNVTUPPER(TRIM(vec.event_set_name)))
,(LEFT JOIN V500_EVENT_SET_CANON pesc ON pesc.event_set_cd =
vesc.event_set_cd)
,(LEFT JOIN NOTE_TYPE trnt ON trnt.event_cd =
f.text_rendition_event_cd)
 PLAN f WHERE f.dcp_forms_ref_id > 0
 AND f.active_ind = 1
JOIN vec
JOIN vesc
JOIN pesc
JOIN trnt
ORDER BY CNVTUPPER(f.description), f.end_effective_dt_tm DESC
ELSEIF($rpt =
"PowerForm search")
DISTINCT
powerform_display_name = pf->list[d.seq].form_display_name
;,form_unique_name = pf->list[d.seq].form_unique_name
,dcp_forms_ref_id = pf->list[d.seq].dcp_forms_ref_id
,search_term = $search
,found_in = SUBSTRING(1,500,
eval_result_bit(pf->list[d.seq].result_bit))
FROM (DUMMYT d WITH seq = value(size(pf->list,
5)))
PLAN d
ORDER BY powerform_display_name, dcp_forms_ref_id, search_term,
found_in
ELSEIF($rpt =
"Usage (by agency) *")
 powerform_display_name = f.description
 ,ag.agency
,nbr_forms_placed = COUNT(DISTINCT dfa.dcp_forms_activity_id)
,nbr_unique_patients = COUNT(DISTINCT dfa.person_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
,powerform_unique_name = f.definition
,f.dcp_forms_ref_id
FROM DCP_FORMS_ACTIVITY dfa
,DCP_FORMS_REF f
,ENCOUNTER e
,CUST_LOC_AGENCY_RELTN ag
PLAN dfa WHERE dfa.dcp_forms_ref_id = $search_result
AND dfa.beg_activity_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND dfa.active_ind = 1
JOIN f WHERE f.dcp_forms_ref_id = dfa.dcp_forms_ref_id
AND f.active_ind = 1
JOIN e WHERE e.encntr_id = dfa.encntr_id
AND e.active_ind = 1
AND e.end_effective_dt_tm >
SYSDATE
JOIN ag WHERE e.loc_facility_cd = ag.location_cd
GROUP BY f.description, f.definition, ag.agency, f.dcp_forms_ref_id
ORDER BY f.description, f.definition, ag.agency
ELSEIF($rpt =
"Usage (by facility) *")
 powerform_display_name = f.description
,ag.agency
,facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,nbr_forms_placed = COUNT(DISTINCT dfa.dcp_forms_activity_id)
,nbr_unique_patients = COUNT(DISTINCT dfa.person_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
,powerform_unique_name = f.definition
,f.dcp_forms_ref_id
FROM DCP_FORMS_ACTIVITY dfa
,DCP_FORMS_REF f
,ENCOUNTER e
,CUST_LOC_AGENCY_RELTN ag
PLAN dfa WHERE dfa.dcp_forms_ref_id = $search_result
AND dfa.beg_activity_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND dfa.active_ind = 1
JOIN f WHERE f.dcp_forms_ref_id = dfa.dcp_forms_ref_id
AND f.active_ind = 1
JOIN e WHERE e.encntr_id = dfa.encntr_id
AND e.active_ind = 1
AND e.end_effective_dt_tm >
SYSDATE
JOIN ag WHERE e.loc_facility_cd = ag.location_cd
GROUP BY f.description, f.definition, ag.agency, e.loc_facility_cd,
f.dcp_forms_ref_id
ORDER BY f.description, f.definition, ag.agency, facility
ELSEIF($rpt =
"Usage (by nurse unit) *")
 powerform_display_name = f.description
,ag.agency
,facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
,nbr_forms_placed = COUNT(DISTINCT dfa.dcp_forms_activity_id)
,nbr_unique_patients = COUNT(DISTINCT dfa.person_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
,powerform_unique_name = f.definition
,f.dcp_forms_ref_id
FROM DCP_FORMS_ACTIVITY dfa
,DCP_FORMS_REF f
,ENCOUNTER e
,CUST_LOC_AGENCY_RELTN ag
PLAN dfa WHERE dfa.dcp_forms_ref_id = $search_result
AND dfa.beg_activity_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND dfa.active_ind = 1
JOIN f WHERE f.dcp_forms_ref_id = dfa.dcp_forms_ref_id
AND f.active_ind = 1
JOIN e WHERE e.encntr_id = dfa.encntr_id
AND e.active_ind = 1
AND e.end_effective_dt_tm >
SYSDATE
JOIN ag WHERE e.loc_facility_cd = ag.location_cd
GROUP BY f.description, f.definition, ag.agency, e.loc_facility_cd,
e.loc_nurse_unit_cd, f.dcp_forms_ref_id
ORDER BY f.description, f.definition, ag.agency, facility, nurse_unit
ELSEIF($rpt =
"Usage (by position) *")
 powerform_display_name = f.description
 ,position =
UAR_GET_CODE_DISPLAY(p.position_cd)
,nbr_forms_placed = COUNT(DISTINCT dfa.dcp_forms_activity_id)
,nbr_unique_patients = COUNT(DISTINCT dfa.person_id)
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
,powerform_unique_name = f.definition
,f.dcp_forms_ref_id
FROM DCP_FORMS_ACTIVITY dfa
,DCP_FORMS_REF f
,DCP_FORMS_ACTIVITY_PRSNL dfap
,PRSNL p
PLAN dfa WHERE dfa.dcp_forms_ref_id = $search_result
AND dfa.beg_activity_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND dfa.active_ind = 1
JOIN f WHERE f.dcp_forms_ref_id = dfa.dcp_forms_ref_id
AND f.active_ind = 1
JOIN dfap WHERE dfap.dcp_forms_activity_id = dfa.dcp_forms_activity_id
JOIN p WHERE p.person_id = dfap.prsnl_id
GROUP BY f.description, f.definition, p.position_cd, f.dcp_forms_ref_id
ORDER BY f.description, f.definition, position
ENDIF
INTO $OUTDEV
error = "Please select a report"
WITH
NOCOUNTER, SEPARATOR=" ", FORMAT, CHECK, TIME=600
end
go
