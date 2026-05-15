/*
 * Source page  : DTA Detail Audit
 * Source file  : output/dta-detail-audit.md
 * Anchor       : (top of page)
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 936
 *
 * Context (preceding paragraph):
 *   Exported 4/24/26
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

drop program
dev_rpt_dta_detail_audit go
create
program dev_rpt_dta_detail_audit
/******************************************************************************
 REPORT NAME:
        DTA Detail Audit
 PROGRAM:                dev_rpt_dta_detail_audit.prg
 DEVELOPER:        David Alt
(david.a.alt2.mil@health.mil)
 CREATED:                06/24/25
 PUBLISHED:
 SNAPSHOT:
 LOGICAL
PATH:        cust_script:
 NODE:                        <default>
 PURPOSE/DESCRIPTION:
         Audits around discrete
task assay (DTA) configuration and associations.
 TARGET AUDIENCE: solution owners/experts
 DEPENDENCIES: none
MOD        DATE                DEVELOPER                COMMENT
---        --/--/--        ---------                ----------------------------
000        06/24/25        David
Alt                File
created
001        03/24/26        David
Alt                Prompt
rebuild, LOINC (SR detail), fixed bad joins
---- unpublished ----
 TODO / CONSIDER:
categories of reports: config/assoc, audits (e.g. bedrock)
prompt error checking? not sure if needed
Look at "Lab Reference Ranges" to get additional fields, like
CLIA
******************************************************************************/
prompt
"Output to File/Printer/MINE" = "MINE" ;* Enter or select the printer or file name
to send this report to.
, "Search" = ""
, "Activity Type" = VALUE(0.0)
, "Results" = VALUE(0.0)
, "Report Type" = "config"
, "Report" = ""
, "Audit" = ""
, "" = "config"
with OUTDEV,
search, act_type, results, tab, rpt, audit, last_tab
/**************************************************************
; Global
Declarations
**************************************************************/
declare
act_var = c2 with protect ;operator variable for Activity Type prompt
declare idx =
i4 with protect, noconstant(0) ;used for EXPAND
declare
error_ind = i2 with protect, noconstant(0)
/**************************************************************
; Prompt
Magic - accounting for "Any (*)" options
**************************************************************/
;ACT_VAR -
Activity Type prompt inflection
IF(substring(1,1,reflect(parameter(3,0)))
= "L") ;multiple selection
 SET act_var = "IN"
ELSEIF(parameter(3,1)=
0.0) ;"Any" selected (must define as 0.0 in prompt)
 SET act_var = ">="
ELSE ;single
value selected
 SET act_var = "="
ENDIF
/**************************************************************
; Record
Structures
**************************************************************/
free record
dta ;stores the DTAs from the prompt
record dta (
1 list[*]
2 description = c100
2 task_assay_cd = f8
; events not implemented
2 events[*]
3 event_cd = f8
3 event_src = c20 ;DISCRETE_TASK_ASSAY, CODE_VALUE_EVENT_R
3 event_set_cd = f8
3 event_set_name = c40
) with
protect
free record
map ;stores band-section-event set-event-task assay associations
record map (
1 list[*]
2 band_id = f8
2 section_id = f8
2 item_id = f8
2 primitive_event_set_cd = f8
2 event_cd = f8
2 task_assay_cd = f8
2 task_assay2_cd = f8
2 band = c40
2 band_version = i4
2 section = c40
2 section_type = c10 ;'Event Set' or 'IV Drip'
2 section_event_set_name = c40
2 event_set_included_ind = i2
2 event_set_required_ind = i2
2 parent_event_set_name = c40
2 primitive_event_set_name = c40
2 primitive_event_set_disp = c40
2 event = c40
2 task_assay = c100
2 task_assay2 = c100
) with
protect
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
; Populate
the list of task assays from the prompt
subroutine
(build_dta_record(input = NULL) = NULL)
declare i = i4 with protect, noconstant(0)
IF($results = 0.0) ;"Any" - reproduce the search list
SELECT INTO "NL:"
FROM CODE_VALUE cv
,DISCRETE_TASK_ASSAY dta
PLAN cv WHERE cv.code_set = 14003
AND CNVTUPPER(cv.display) =
PATSTRING(CONCAT("*",$search,"*"))
AND cv.active_ind = 1
JOIN dta WHERE dta.task_assay_cd = cv.code_value
AND OPERATOR(dta.activity_type_cd, act_var, $act_type)
AND dta.active_ind = 1
ORDER BY CNVTUPPER(cv.display)
DETAIL
i += 1
CALL ALTERLIST(dta->list, i)
dta->list[i].task_assay_cd = cv.code_value
WITH NOCOUNTER
ELSE
SELECT INTO "NL:"
FROM CODE_VALUE cv
PLAN cv WHERE cv.code_value = $results
ORDER BY CNVTUPPER(cv.display)
DETAIL
i += 1
CALL ALTERLIST(dta->list, i)
dta->list[i].task_assay_cd = cv.code_value
WITH NOCOUNTER
ENDIF
end
;build_dta_record
; Populate
the map record structure
subroutine
(build_map_record(input = NULL) = NULL)
declare i = i4 with protect, noconstant(0)
SELECT INTO "NL:"
FROM WORKING_VIEW wv
,WORKING_VIEW_SECTION wvs
;wvi needs left join, else it loses IV Drip section types
,(LEFT JOIN WORKING_VIEW_ITEM wvi ON wvi.working_view_section_id =
wvs.working_view_section_id)
,(LEFT JOIN V500_EVENT_SET_CODE esc ON esc.event_set_name =
wvi.primitive_event_set_name)
,(LEFT JOIN V500_EVENT_SET_EXPLODE ese ON ese.event_set_cd =
esc.event_set_cd)
,(LEFT JOIN DISCRETE_TASK_ASSAY dta ON dta.event_cd = ese.event_cd
AND dta.end_effective_dt_tm > SYSDATE
AND dta.active_ind = 1)
,(LEFT JOIN CODE_VALUE_EVENT_R cvr ON cvr.event_cd = ese.event_cd)
,(LEFT JOIN DISCRETE_TASK_ASSAY cvr_dta ON cvr_dta.task_assay_cd =
cvr.parent_cd
AND cvr_dta.end_effective_dt_tm > SYSDATE
AND cvr_dta.active_ind = 1)
PLAN wv WHERE 1=1
AND wv.end_effective_dt_tm > SYSDATE
AND wv.active_ind = 1
JOIN wvs WHERE wvs.working_view_id = wv.working_view_id
JOIN wvi
JOIN esc
JOIN ese
JOIN dta
JOIN cvr
JOIN cvr_dta
ORDER BY wv.working_view_id, wvs.working_view_section_id,
wvi.working_view_item_id
,esc.event_set_cd, ese.event_cd, dta.task_assay_cd, cvr.parent_cd
DETAIL
i += 1
CALL ALTERLIST(map->list, i)
map->list[i].band_id = wv.working_view_id
map->list[i].section_id = wvs.working_view_section_id
map->list[i].item_id = wvi.working_view_item_id
map->list[i].primitive_event_set_cd = esc.event_set_cd
map->list[i].event_cd = ese.event_cd
map->list[i].task_assay_cd = dta.task_assay_cd
map->list[i].task_assay2_cd = cvr.parent_cd
map->list[i].band = wv.display_name
map->list[i].band_version = wv.version_num
map->list[i].section = wvs.display_name
map->list[i].section_type = EVALUATE(wvs.section_type_flag, 0,
"Event Set", 1, "IV Drip", "Unknown flag value")
map->list[i].section_event_set_name = wvs.event_set_name
map->list[i].event_set_included_ind = wvs.included_ind
map->list[i].event_set_required_ind = wvs.required_ind
map->list[i].parent_event_set_name = wvi.parent_event_set_name
map->list[i].primitive_event_set_name = wvi.primitive_event_set_name
map->list[i].primitive_event_set_disp = esc.event_set_cd_disp
map->list[i].event = UAR_GET_CODE_DISPLAY(ese.event_cd)
map->list[i].task_assay = dta.description
map->list[i].task_assay2 = cvr_dta.description
WITH NOCOUNTER
end
;build_map_record
/**************************************************************
; Main
**************************************************************/
CALL
build_dta_record(NULL)
IF($last_tab
= "config" AND $rpt = "IView")
CALL build_map_record(NULL)
ENDIF
/**************************************************************
; Output
**************************************************************/
SELECT
IF(error_ind
= 1)
error = "Failsafe triggered"
/*****
CONFIGURATION REPORTS *****/
ELSEIF($last_tab
= "config" AND $rpt = "Summary")
activity_type = UAR_GET_CODE_DISPLAY(dta.activity_type_cd)
,task_assay = dta.description
,dta.mnemonic
,result_type = UAR_GET_CODE_DISPLAY(dta.default_result_type_cd)
,numeric_range_cnt = dm_cnt.num_rows
,alpha_response_cnt = ar_cnt.num_rows
,ref_range_cnt = rrf_cnt.num_rows
;i/o ind - not yet found
,equation_cnt = eq_cnt.num_rows
,code_set = EVALUATE(dta.code_set,0,
"",CNVTSTRING(dta.code_set))
,event_cd =
IF(dta.event_cd != 0) CNVTSTRING(dta.event_cd)
ELSEIF(cvr_cnt.num_rows != 0) "(multiple)"
ELSE ""
ENDIF
,event =
IF(dta.event_cd != 0) UAR_GET_CODE_DISPLAY(dta.event_cd)
ELSEIF(cvr_cnt.num_rows != 0) "(see Clinical Events association
map)"
ELSE ""
ENDIF
,default_value = EVALUATE(dta.default_type_flag,
0, "No defaults",
1, "From reference range",
2, "From last charted value",
3, "From template script",
"Unknown flag value")
,default_template = EVALUATE(dta.template_script_cd, 0, "",
UAR_GET_CODE_DISPLAY(dta.template_script_cd))
,intake_output_flag = EVALUATE(dta.io_flag,
0, "0 = Do not include in I&O",
1, "1 = Include in Intake",
2, "2 = Include in Output",
"Unknown flag value")
,delta_checking_flag = EVALUATE(dta.delta_lvl_flag,
0, "No delta checking",
1, "Current result only",
2, "Current and previous result",
"Unknown flag value")
;        ,dta.icd_code_ind
;        ,dta.rel_assay_ind
;        ,dta.sci_notation_ind
;        ,dta.signature_line_ind
;,look_back_min_for_related_results
;,look_back_min_BMDI
;,look_forward_min_BMDI
;numerical map: max, min, dec -
data_map
,use_modifier = EVALUATE(dta.modifier_ind, 1, "Yes",
"No")
,first_alpha_single_select = EVALUATE(dta.single_select_ind, 1,
"Yes", "No")
;witness required = not yet found
,label_template_id = EVALUATE(dta.label_template_id, 0, "",
CNVTSTRING(dta.label_template_id))
,dta.concept_cki
,version = CNVTSTRING(dta.version_number)
,dta.beg_effective_dt_tm
,last_updated_on = dta.updt_dt_tm
,last_updated_by = p.name_full_formatted
,dta.task_assay_cd
FROM DISCRETE_TASK_ASSAY dta
;,(LEFT JOIN CODE_VALUE_EVENT_R cvr ON dta.task_assay_cd =
cvr.parent_cd)
;Alpha Response counts
,(LEFT JOIN (SELECT rrf.task_assay_cd, num_rows =
COUNT(ar.nomenclature_id)
 FROM REFERENCE_RANGE_FACTOR rrf
         
,ALPHA_RESPONSES ar
 WHERE EXPAND(idx, 1,
size(dta->list,5), rrf.task_assay_cd, dta->list[idx].task_assay_cd)
         AND
ar.reference_range_factor_id = rrf.reference_range_factor_id
         AND
rrf.end_effective_dt_tm > SYSDATE
         AND
rrf.active_ind = 1
         AND
ar.end_effective_dt_tm > SYSDATE
         AND
ar.active_ind = 1
 GROUP BY rrf.task_assay_cd
 WITH
SQLTYPE("f8","i4")) ar_cnt
 ON ar_cnt.task_assay_cd =
dta.task_assay_cd)
;Code Value Event Reltn counts
,(LEFT JOIN (SELECT cvr.parent_cd, num_rows = COUNT(*)
 FROM CODE_VALUE_EVENT_R cvr
 WHERE EXPAND(idx, 1,
size(dta->list,5), cvr.parent_cd, dta->list[idx].task_assay_cd)
 GROUP BY cvr.parent_cd
 WITH
SQLTYPE("f8","i4")) cvr_cnt
 ON cvr_cnt.parent_cd =
dta.task_assay_cd)
;Data Map (numeric range) counts
,(LEFT JOIN (SELECT dm.task_assay_cd, num_rows = COUNT(*)
 FROM DATA_MAP dm
 WHERE EXPAND(idx, 1,
size(dta->list,5), dm.task_assay_cd, dta->list[idx].task_assay_cd)
         AND
dm.end_effective_dt_tm > SYSDATE
         AND
dm.active_ind = 1
 GROUP BY dm.task_assay_cd
 WITH
SQLTYPE("f8","i4")) dm_cnt
 ON dm_cnt.task_assay_cd =
dta.task_assay_cd)
;Equation counts
,(LEFT JOIN (SELECT e.task_assay_cd, num_rows = COUNT(*)
 FROM EQUATION e
 WHERE EXPAND(idx, 1,
size(dta->list,5), e.task_assay_cd, dta->list[idx].task_assay_cd)
         AND
e.active_ind = 1
 GROUP BY e.task_assay_cd
 WITH
SQLTYPE("f8","i4")) eq_cnt
 ON eq_cnt.task_assay_cd =
dta.task_assay_cd)
;Reference Range Factor counts
,(LEFT JOIN (SELECT rrf.task_assay_cd, num_rows = COUNT(*)
 FROM REFERENCE_RANGE_FACTOR rrf
 WHERE EXPAND(idx, 1,
size(dta->list,5), rrf.task_assay_cd, dta->list[idx].task_assay_cd)
         AND
rrf.end_effective_dt_tm > SYSDATE
         AND
rrf.active_ind = 1
 GROUP BY rrf.task_assay_cd
 WITH
SQLTYPE("f8","i4")) rrf_cnt
 ON rrf_cnt.task_assay_cd =
dta.task_assay_cd)
,(LEFT JOIN PRSNL p ON p.person_id = dta.updt_id)
PLAN dta WHERE EXPAND(idx, 1, size(dta->list,5), dta.task_assay_cd,
dta->list[idx].task_assay_cd)
JOIN p
JOIN ar_cnt
JOIN cvr_cnt
JOIN dm_cnt
JOIN eq_cnt
JOIN rrf_cnt
ORDER BY activity_type, CNVTUPPER(dta.description)
ELSEIF($last_tab
= "config" AND $rpt = "Alpha Responses")
activity_type = UAR_GET_CODE_DISPLAY(dta.activity_type_cd)
,task_assay = dta.description
,response = n.source_string
,service_resource = UAR_GET_CODE_DISPLAY(rrf.service_resource_cd)
,a.sequence
,a.result_value
,a.concept_cki
,truth_state = UAR_GET_CODE_DISPLAY(a.truth_state_cd)
,a.default_ind
,rrf.task_assay_cd
,a.reference_range_factor_id
,a.nomenclature_id
FROM DISCRETE_TASK_ASSAY dta
,REFERENCE_RANGE_FACTOR rrf
,ALPHA_RESPONSES a
,(LEFT JOIN NOMENCLATURE n ON n.nomenclature_id = a.nomenclature_id
AND n.end_effective_dt_tm > SYSDATE
AND n.active_ind = 1)
PLAN dta WHERE EXPAND(idx, 1, size(dta->list,5), dta.task_assay_cd,
dta->list[idx].task_assay_cd)
JOIN rrf WHERE rrf.task_assay_cd = dta.task_assay_cd
AND rrf.end_effective_dt_tm > SYSDATE
AND rrf.active_ind = 1
JOIN a WHERE a.reference_range_factor_id =
rrf.reference_range_factor_id
AND a.end_effective_dt_tm > SYSDATE
AND a.active_ind = 1
JOIN n
ORDER BY activity_type, CNVTUPPER(dta.description), service_resource,
a.sequence
ELSEIF($last_tab
= "config" AND $rpt = "Clinical Events")
activity_type = UAR_GET_CODE_DISPLAY(dta.activity_type_cd)
,task_assay = dta.description
,dta.task_assay_cd
,event =
IF(cvr.event_cd != 0) UAR_GET_CODE_DISPLAY(cvr.event_cd)
ELSEIF(dta.event_cd != 0) UAR_GET_CODE_DISPLAY(dta.event_cd)
ELSE ""
ENDIF
,event_cd =
IF(cvr.event_cd != 0) CNVTSTRING(cvr.event_cd)
ELSEIF(dta.event_cd != 0) CNVTSTRING(dta.event_cd)
ELSE ""
ENDIF
,map_source =
IF(cvr.event_cd != 0) "CODE_VALUE_EVENT_R"
ELSEIF(dta.event_cd != 0) "DISCRETE_TASK_ASSAY"
ELSE "N/A"
ENDIF
,event_set =
IF(cvr.event_cd != 0) es2.event_set_name
ELSEIF(dta.event_cd != 0) es1.event_set_name
ELSE ""
ENDIF
,event_set_cd =
IF(cvr.event_cd != 0) CNVTSTRING(esc2.event_set_cd)
ELSEIF(dta.event_cd != 0) CNVTSTRING(esc1.event_set_cd)
ELSE ""
ENDIF
FROM DISCRETE_TASK_ASSAY dta
,(LEFT JOIN CODE_VALUE_EVENT_R cvr ON dta.task_assay_cd =
cvr.parent_cd)
,(LEFT JOIN V500_EVENT_CODE es1 ON es1.event_cd = dta.event_cd
AND dta.event_cd !=0)
,(LEFT JOIN V500_EVENT_SET_CODE esc1 ON esc1.event_set_name =
es1.event_set_name
AND esc1.event_set_cd != 0)
,(LEFT JOIN V500_EVENT_CODE es2 ON es2.event_cd = cvr.event_cd
AND cvr.event_cd !=0)
,(LEFT JOIN V500_EVENT_SET_CODE esc2 ON esc2.event_set_name =
es2.event_set_name
AND esc2.event_set_cd != 0)
PLAN dta WHERE EXPAND(idx, 1, size(dta->list,5), dta.task_assay_cd,
dta->list[idx].task_assay_cd)
JOIN cvr
JOIN es1
JOIN esc1
JOIN es2
JOIN esc2
ORDER BY activity_type, CNVTUPPER(dta.description), event
ELSEIF($last_tab
= "config" AND $rpt = "Equations")
activity_type = UAR_GET_CODE_DISPLAY(dta.activity_type_cd)
,task_assay = dta.description
,equation = e.equation_description
,start_age =
IF(UAR_GET_CODE_MEANING(e.age_from_units_cd) = "MINUTES")
CONCAT(TRIM(CNVTSTRING((e.age_from_minutes))), " ",
UAR_GET_CODE_DISPLAY(e.age_from_units_cd))
ELSEIF(UAR_GET_CODE_MEANING(e.age_from_units_cd) = "HOURS")
CONCAT(TRIM(CNVTSTRING((e.age_from_minutes/60))), " ",
UAR_GET_CODE_DISPLAY(e.age_from_units_cd))
ELSEIF(UAR_GET_CODE_MEANING(e.age_from_units_cd) = "DAYS")
CONCAT(TRIM(CNVTSTRING((e.age_from_minutes/60/24))), " ",
UAR_GET_CODE_DISPLAY(e.age_from_units_cd))
ELSEIF(UAR_GET_CODE_MEANING(e.age_from_units_cd) = "WEEKS")
CONCAT(TRIM(CNVTSTRING((e.age_from_minutes/60/24/7))), " ",
UAR_GET_CODE_DISPLAY(e.age_from_units_cd))
ELSEIF(UAR_GET_CODE_MEANING(e.age_from_units_cd) = "MONTHS")
CONCAT(TRIM(CNVTSTRING((e.age_from_minutes/60/24/31))), " ",
UAR_GET_CODE_DISPLAY(e.age_from_units_cd))
ELSEIF(UAR_GET_CODE_MEANING(e.age_from_units_cd) = "YEARS")
CONCAT(TRIM(CNVTSTRING((e.age_from_minutes/60/24/365))), " ",
UAR_GET_CODE_DISPLAY(e.age_from_units_cd))
ENDIF
,end_age =
IF(UAR_GET_CODE_MEANING(e.age_to_units_cd) = "MINUTES")
CONCAT(TRIM(CNVTSTRING((e.age_to_minutes))), " ",
UAR_GET_CODE_DISPLAY(e.age_to_units_cd))
ELSEIF(UAR_GET_CODE_MEANING(e.age_to_units_cd) = "HOURS")
CONCAT(TRIM(CNVTSTRING((e.age_to_minutes/60))), " ",
UAR_GET_CODE_DISPLAY(e.age_to_units_cd))
ELSEIF(UAR_GET_CODE_MEANING(e.age_to_units_cd) = "DAYS")
CONCAT(TRIM(CNVTSTRING((e.age_to_minutes/60/24))), " ",
UAR_GET_CODE_DISPLAY(e.age_to_units_cd))
ELSEIF(UAR_GET_CODE_MEANING(e.age_to_units_cd) = "WEEKS")
CONCAT(TRIM(CNVTSTRING((e.age_to_minutes/60/24/7))), " ",
UAR_GET_CODE_DISPLAY(e.age_to_units_cd))
ELSEIF(UAR_GET_CODE_MEANING(e.age_to_units_cd) = "MONTHS")
CONCAT(TRIM(CNVTSTRING((e.age_to_minutes/60/24/31))), " ",
UAR_GET_CODE_DISPLAY(e.age_to_units_cd))
ELSEIF(UAR_GET_CODE_MEANING(e.age_to_units_cd) = "YEARS")
CONCAT(TRIM(CNVTSTRING((e.age_to_minutes/60/24/365))), " ",
UAR_GET_CODE_DISPLAY(e.age_to_units_cd))
ENDIF
;,e.gestational_age_ind
,service_resource =
IF(e.service_resource_cd = 0) "(All)"
ELSE UAR_GET_CODE_DISPLAY(e.service_resource_cd)
ENDIF
,sex =
IF(e.sex_cd = 0) "(All)"
ELSE UAR_GET_CODE_DISPLAY(e.sex_cd)
ENDIF
,species =
IF(e.species_cd = 0) "(All)"
ELSE UAR_GET_CODE_DISPLAY(e.species_cd)
ENDIF
,e.unknown_age_ind
,e.default_ind
,last_updated_on = e.updt_dt_tm
,last_updated_by = p.name_full_formatted
,dta.task_assay_cd
,e.equation_id
FROM DISCRETE_TASK_ASSAY dta
,EQUATION e
,(LEFT JOIN PRSNL p ON p.person_id = e.updt_id)
PLAN dta WHERE EXPAND(idx, 1, size(dta->list,5), dta.task_assay_cd,
dta->list[idx].task_assay_cd)
JOIN e WHERE e.task_assay_cd = dta.task_assay_cd
AND e.active_ind = 1
JOIN p
ORDER BY activity_type, CNVTUPPER(dta.description), service_resource,
equation
ELSEIF($last_tab
= "config" AND $rpt = "Equation Components")
activity_type = UAR_GET_CODE_DISPLAY(dta.activity_type_cd)
,task_assay = dta.description
,component = ec.name
,equation = e.equation_description
,value =
IF(ec.included_assay_cd != 0)
UAR_GET_CODE_DESCRIPTION(ec.included_assay_cd)
ELSE CNVTSTRING(ec.constant_value)
ENDIF
,units = UAR_GET_CODE_DISPLAY(ec.units_cd)
,result_required_flag = EVALUATE(ec.result_req_flag,
0, "Not required",
1, "Required",
"Unknown flag value")
,default_value = EVALUATE(ec.result_req_flag,
0, CNVTSTRING(ec.default_value),
1, "N/A") ;default value only used if result is not required
,look_time_direction = EVALUATE(ec.look_time_direction_flag,
0, "Look back first",
1, "Look ahead first",
"Unknown flag value")
,ec.time_window_minutes
,ec.time_window_back_minutes
,component_type = EVALUATE(ec.component_flag,
1, "Procedure",
2, "Variable",
3, "Constant",
"Unknown flag value")
,value_source =
IF(ec.included_assay_cd != 0) "DTA"
ELSE "Constant"
ENDIF
,last_updated_on = ec.updt_dt_tm
,last_updated_by = p.name_full_formatted
,e.task_assay_cd
,e.equation_id
,ec.sequence
FROM DISCRETE_TASK_ASSAY dta
,EQUATION e
,(LEFT JOIN EQUATION_COMPONENT ec ON ec.equation_id = e.equation_id)
,(LEFT JOIN PRSNL p ON p.person_id = ec.updt_id)
PLAN dta WHERE EXPAND(idx, 1, size(dta->list,5), dta.task_assay_cd,
dta->list[idx].task_assay_cd)
JOIN e WHERE e.task_assay_cd = dta.task_assay_cd
AND e.active_ind = 1
JOIN ec
JOIN p
ORDER BY activity_type, CNVTUPPER(dta.description), ec.sequence
ELSEIF($last_tab
= "config" AND $rpt = "IView")
task_assay = map->list[d.seq].task_assay
,task_assay2 = map->list[d.seq].task_assay2
,band = map->list[d.seq].band
,section = map->list[d.seq].section
,section_type = map->list[d.seq].section_type
,section_event_set = map->list[d.seq].section_event_set_name
,event_set_included_ind = map->list[d.seq].event_set_included_ind
,event_set_required_ind = map->list[d.seq].event_set_required_ind
,parent_event_set_name = map->list[d.seq].parent_event_set_name
,primitive_event_set_name =
map->list[d.seq].primitive_event_set_name
,primitive_event_set_disp =
map->list[d.seq].primitive_event_set_disp
,event = map->list[d.seq].event
,band_version = map->list[d.seq].band_version
,band_id = map->list[d.seq].band_id
,section_id = map->list[d.seq].section_id
,item_id = map->list[d.seq].item_id
,primitive_event_set_cd = map->list[d.seq].primitive_event_set_cd
,event_cd = map->list[d.seq].event_cd
,task_assay_cd = map->list[d.seq].task_assay_cd
,task_assay2_cd = map->list[d.seq].task_assay2_cd
FROM (DUMMYT d WITH seq = value(size(map->list, 5)))
PLAN d WHERE 1=1
AND (EXPAND(idx, 1, size(dta->list,5),
map->list[d.seq].task_assay_cd, dta->list[idx].task_assay_cd)
OR         EXPAND(idx, 1,
size(dta->list,5), map->list[d.seq].task_assay2_cd,
dta->list[idx].task_assay_cd))
ORDER BY task_assay, task_assay2, band, section,
primitive_event_set_name
ELSEIF($last_tab
= "config" AND $rpt = "LOINC")
activity_type = UAR_GET_CODE_DISPLAY(dta.activity_type_cd)
,task_assay = dta.description
,loinc = PIECE(cid.concept_cki, "!", 2, "")
,loinc_type = EVALUATE(cid.concept_type_flag, 1, "Analyte",
2, "Assessment", "")
,specimen_type = UAR_GET_CODE_DISPLAY(cid.specimen_type_cd)
,mapped_resources = CNVTSTRING(COUNT(DISTINCT cid.service_resource_cd))
,dta.task_assay_cd
FROM DISCRETE_TASK_ASSAY dta
,(LEFT JOIN CONCEPT_IDENTIFIER_DTA cid ON cid.task_assay_cd =
dta.task_assay_cd
AND cid.concept_cki = "LOINC*"
AND cid.end_effective_dt_tm > SYSDATE
AND cid.active_ind = 1)
PLAN dta WHERE EXPAND(idx, 1, size(dta->list,5), dta.task_assay_cd,
dta->list[idx].task_assay_cd)
JOIN cid
GROUP BY dta.activity_type_cd, dta.description, dta.task_assay_cd,
cid.concept_cki,
cid.concept_type_flag, cid.specimen_type_cd
ORDER BY activity_type, CNVTUPPER(dta.description), loinc,
specimen_type
ELSEIF($last_tab
= "config" AND $rpt = "LOINC (SR detail)")
activity_type = UAR_GET_CODE_DISPLAY(dta.activity_type_cd)
,task_assay = dta.description
,loinc = PIECE(cid.concept_cki, "!", 2, "")
,loinc_type = EVALUATE(cid.concept_type_flag, 1, "Analyte",
2, "Assessment", "")
,specimen_type = UAR_GET_CODE_DISPLAY(cid.specimen_type_cd)
,service_resource = UAR_GET_CODE_DISPLAY(cid.service_resource_cd)
,dta.task_assay_cd
FROM DISCRETE_TASK_ASSAY dta
,(LEFT JOIN CONCEPT_IDENTIFIER_DTA cid ON cid.task_assay_cd =
dta.task_assay_cd
AND cid.concept_cki = "LOINC*"
AND cid.end_effective_dt_tm > SYSDATE
AND cid.active_ind = 1)
PLAN dta WHERE EXPAND(idx, 1, size(dta->list,5), dta.task_assay_cd,
dta->list[idx].task_assay_cd)
JOIN cid
ORDER BY activity_type, CNVTUPPER(dta.description), loinc,
specimen_type, service_resource
ELSEIF($last_tab
= "config" AND $rpt = "Numeric Ranges")
activity_type = UAR_GET_CODE_DISPLAY(dta.activity_type_cd)
,task_assay = dta.description
,service_resource = EVALUATE(dm.service_resource_cd, 0,
"(All)", UAR_GET_CODE_DISPLAY(dm.service_resource_cd))
,result_type = UAR_GET_CODE_DISPLAY(dta.default_result_type_cd)
,dm.min_digits
,dm.max_digits
,dm.min_decimal_places
,dta.task_assay_cd
FROM DISCRETE_TASK_ASSAY dta
,DATA_MAP dm
PLAN dta WHERE EXPAND(idx, 1, size(dta->list,5), dta.task_assay_cd,
dta->list[idx].task_assay_cd)
JOIN dm WHERE dm.task_assay_cd = dta.task_assay_cd
AND dm.end_effective_dt_tm > SYSDATE
AND dm.active_ind = 1
ORDER BY activity_type, CNVTUPPER(dta.description), service_resource
ELSEIF($last_tab
= "config" AND $rpt = "Orders")
activity_type = UAR_GET_CODE_DISPLAY(dta.activity_type_cd)
,task_assay = dta.description
,orderable = oc.description
,dta.task_assay_cd
,oc.catalog_cd
FROM DISCRETE_TASK_ASSAY dta
,PROFILE_TASK_R ptr
,ORDER_CATALOG oc
PLAN dta WHERE EXPAND(idx, 1, size(dta->list,5), dta.task_assay_cd,
dta->list[idx].task_assay_cd)
JOIN ptr WHERE ptr.task_assay_cd = dta.task_assay_cd
AND ptr.end_effective_dt_tm > SYSDATE
AND ptr.active_ind = 1
JOIN oc WHERE oc.catalog_cd = ptr.catalog_cd
AND oc.active_ind = 1
ORDER BY activity_type, CNVTUPPER(dta.description),
CNVTUPPER(oc.description)
ELSEIF($last_tab
= "config" AND $rpt = "PowerForms")
activity_type = UAR_GET_CODE_DISPLAY(dta.activity_type_cd)
,task_assay = dta.description
,powerform_display_name = f.description
,powerform_unique_name = f.definition
,section_display_name = s.description
,section_unique_name = s.definition
;,section_sequence = fd.section_seq
,input_description = i.description
;,input_sequence = i.input_ref_seq
,input_type = EVALUATE(i.input_type
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
,BUILD("Unmapped (",CNVTSTRING(i.input_type), ")")
)
,dta_result_type = UAR_GET_CODE_DISPLAY(dta.default_result_type_cd)
,dta_default_value = EVALUATE(dta.default_type_flag,
0, "No default value",
1, "Default from the reference range",
2, "Default from last charted value (any encounter)",
3, "Default from the template script",
"Unknown flag value")
;idenfitiers
,f.dcp_forms_ref_id
,s.dcp_section_ref_id
,dta.task_assay_cd
FROM DISCRETE_TASK_ASSAY dta
,NAME_VALUE_PREFS nvp
,DCP_INPUT_REF i
,DCP_SECTION_REF s
,DCP_FORMS_DEF fd
,DCP_FORMS_REF f
PLAN dta WHERE EXPAND(idx, 1, size(dta->list,5), dta.task_assay_cd,
dta->list[idx].task_assay_cd)
JOIN nvp WHERE dta.task_assay_cd = nvp.merge_id
AND nvp.merge_name = "DISCRETE_TASK_ASSAY"
JOIN i WHERE nvp.parent_entity_name = "DCP_INPUT_REF"
AND nvp.parent_entity_id = i.dcp_input_ref_id
AND i.active_ind = 1
JOIN s WHERE i.dcp_section_instance_id = s.dcp_section_instance_id
AND s.dcp_section_ref_id = i.dcp_section_ref_id
AND CNVTUPPER(s.description) != "ZZ*"
AND s.end_effective_dt_tm > SYSDATE
AND s.active_ind = 1
JOIN fd WHERE s.dcp_section_ref_id = fd.dcp_section_ref_id
AND fd.active_ind = 1
JOIN f WHERE fd.dcp_form_instance_id = f.dcp_form_instance_id
AND CNVTUPPER(f.definition) != "ZZ*"
AND f.end_effective_dt_tm > SYSDATE
AND f.active_ind = 1
ORDER BY activity_type, CNVTUPPER(dta.description),
powerform_display_name, fd.section_seq, i.input_ref_seq
ELSEIF($last_tab
= "config" AND $rpt = "Reference Ranges")
activity_type = UAR_GET_CODE_DISPLAY(dta.activity_type_cd)
,task_assay = dta.description
,organization = org.org_name
,service_resource = EVALUATE(rrf.service_resource_cd, 0,
"(All)", UAR_GET_CODE_DISPLAY(rrf.service_resource_cd))
,result_type = UAR_GET_CODE_DISPLAY(dta.default_result_type_cd)
,rrf.default_result
,units_of_measure = UAR_GET_CODE_DISPLAY(rrf.units_cd)
,species = UAR_GET_CODE_DISPLAY(rrf.species_cd)
,sex =
IF(rrf.sex_cd != 0) UAR_GET_CODE_DISPLAY(rrf.sex_cd)
ELSE "(All)"
ENDIF
,start_age =
IF(UAR_GET_CODE_MEANING(rrf.age_from_units_cd) = "MINUTES")
CONCAT(TRIM(CNVTSTRING((rrf.age_from_minutes))), " ",
UAR_GET_CODE_DISPLAY(rrf.age_from_units_cd))
ELSEIF(UAR_GET_CODE_MEANING(rrf.age_from_units_cd) = "HOURS")
CONCAT(TRIM(CNVTSTRING((rrf.age_from_minutes/60))), " ",
UAR_GET_CODE_DISPLAY(rrf.age_from_units_cd))
ELSEIF(UAR_GET_CODE_MEANING(rrf.age_from_units_cd) = "DAYS")
CONCAT(TRIM(CNVTSTRING((rrf.age_from_minutes/60/24))), " ",
UAR_GET_CODE_DISPLAY(rrf.age_from_units_cd))
ELSEIF(UAR_GET_CODE_MEANING(rrf.age_from_units_cd) = "WEEKS")
CONCAT(TRIM(CNVTSTRING((rrf.age_from_minutes/60/24/7))), " ",
UAR_GET_CODE_DISPLAY(rrf.age_from_units_cd))
ELSEIF(UAR_GET_CODE_MEANING(rrf.age_from_units_cd) =
"MONTHS")
CONCAT(TRIM(CNVTSTRING((rrf.age_from_minutes/60/24/31))), "
", UAR_GET_CODE_DISPLAY(rrf.age_from_units_cd))
ELSEIF(UAR_GET_CODE_MEANING(rrf.age_from_units_cd) = "YEARS")
CONCAT(TRIM(CNVTSTRING((rrf.age_from_minutes/60/24/365))), "
", UAR_GET_CODE_DISPLAY(rrf.age_from_units_cd))
ENDIF
,end_age =
IF(UAR_GET_CODE_MEANING(rrf.age_to_units_cd) = "MINUTES")
CONCAT(TRIM(CNVTSTRING((rrf.age_to_minutes))), " ",
UAR_GET_CODE_DISPLAY(rrf.age_to_units_cd))
ELSEIF(UAR_GET_CODE_MEANING(rrf.age_to_units_cd) = "HOURS")
CONCAT(TRIM(CNVTSTRING((rrf.age_to_minutes/60))), " ",
UAR_GET_CODE_DISPLAY(rrf.age_to_units_cd))
ELSEIF(UAR_GET_CODE_MEANING(rrf.age_to_units_cd) = "DAYS")
CONCAT(TRIM(CNVTSTRING((rrf.age_to_minutes/60/24))), " ",
UAR_GET_CODE_DISPLAY(rrf.age_to_units_cd))
ELSEIF(UAR_GET_CODE_MEANING(rrf.age_to_units_cd) = "WEEKS")
CONCAT(TRIM(CNVTSTRING((rrf.age_to_minutes/60/24/7))), " ",
UAR_GET_CODE_DISPLAY(rrf.age_to_units_cd))
ELSEIF(UAR_GET_CODE_MEANING(rrf.age_to_units_cd) = "MONTHS")
CONCAT(TRIM(CNVTSTRING((rrf.age_to_minutes/60/24/31))), " ",
UAR_GET_CODE_DISPLAY(rrf.age_to_units_cd))
ELSEIF(UAR_GET_CODE_MEANING(rrf.age_to_units_cd) = "YEARS")
CONCAT(TRIM(CNVTSTRING((rrf.age_to_minutes/60/24/365))), " ",
UAR_GET_CODE_DISPLAY(rrf.age_to_units_cd))
ENDIF
,minutes_back = rrf.mins_back
,flexing_rules = rrf.ref_range_rule_ind
/* REFERENCE RANGES */
,rrf.normal_low
,rrf.normal_high
,rrf.critical_low
,rrf.critical_high
,rrf.feasible_low
,rrf.feasible_high
,rrf.review_low
,rrf.review_high
,rrf.linear_low
,rrf.linear_high
,rrf.sensitive_low
,rrf.sensitive_high
/* INDICATORS */
,rrf.feasible_ind
,rrf.review_ind
,rrf.linear_ind
,rrf.sensitive_ind
,rrf.def_result_ind        ;default
results
,rrf.delta_chk_flag ;type of delta checking performed
,rrf.dilute_ind        ;is
dilution required for results that exceed linear limits?
,rrf.gestational_ind
,rrf.precedence_sequence ;determines which ref range is used when
multiple meet the criteria
,rrf.unknown_age_ind
/* TIMING/UPDATE INFORMATION */
,rrf.beg_effective_dt_tm
,last_updated_on = rrf.updt_dt_tm
,last_updated_by = p.name_full_formatted
,dta.task_assay_cd
,rrf.reference_range_factor_id
FROM DISCRETE_TASK_ASSAY dta
,REFERENCE_RANGE_FACTOR rrf
,(LEFT JOIN PRSNL p        ON
p.person_id = rrf.updt_id) ;update personnel
,SERVICE_RESOURCE
sr        ;needed for labs
,ORGANIZATION
org                ;needed
for labs
PLAN dta WHERE EXPAND(idx, 1, size(dta->list,5), dta.task_assay_cd,
dta->list[idx].task_assay_cd)
JOIN rrf WHERE dta.task_assay_cd = rrf.task_assay_cd
AND rrf.end_effective_dt_tm > SYSDATE
AND rrf.active_ind = 1
JOIN sr WHERE rrf.service_resource_cd = sr.service_resource_cd
JOIN org WHERE sr.organization_id = org.organization_id
JOIN p
ORDER BY activity_type, CNVTUPPER(dta.description), organization,
service_resource, species, sex
/***** AUDIT
REPORTS *****/
ELSEIF($last_tab
= "audit" AND $audit = "DTAs without event codes")
dta.mnemonic
,activity_type = UAR_GET_CODE_DISPLAY(dta.activity_type_cd)
,dta.task_assay_cd
FROM DISCRETE_TASK_ASSAY dta
PLAN dta WHERE EXPAND(idx, 1, size(dta->list,5), dta.task_assay_cd,
dta->list[idx].task_assay_cd)
AND dta.event_cd = 0
AND NOT EXISTS(
SELECT 1
FROM CODE_VALUE_EVENT_R cvr
WHERE cvr.parent_cd = dta.task_assay_cd)
ORDER BY dta.mnemonic
ELSE
;error = "invalid prompt"
act_var = act_var
,task_assay = UAR_GET_CODE_DISPLAY(dta->list[d.seq].task_assay_cd)
,task_assay_cd = dta->list[d.seq].task_assay_cd
FROM (DUMMYT d WITH seq = value(size(dta->list, 5)))
PLAN d
ORDER BY
CNVTUPPER(UAR_GET_CODE_DISPLAY(dta->list[d.seq].task_assay_cd))
ENDIF
INTO $OUTDEV
WITH
NOCOUNTER, SEPARATOR=" ", FORMAT, TIME=600, CHECK, EXPAND=2
end
go
