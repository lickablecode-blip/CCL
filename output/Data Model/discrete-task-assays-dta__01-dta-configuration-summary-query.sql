/*
 * Source page  : Discrete Task Assays (DTA)
 * Source file  : output/discrete-task-assays-dta.md
 * Anchor       : DTA Configuration Summary query
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 151
 *
 * Context (preceding paragraph):
 *   See [Event set hierarchy (ESH)](onenote:#Event%20set%20hierarchy%20(ESH)&section-
 *   id={3A32472C-2C84-4CDE-B609-CFCD47A33197}&page-
 *   id={26EA0E06-E29E-4CE0-8006-A69638CF7FE4}&end&base-path=https://militaryhealth-
 *   my.sharepoint-mil.us/personal/david_a_alt2_mil_health_mil/Documents/Documents/OneNote%2
 *   0Notebooks/Development-Shared/CCL%20-%20Content.one) for more information on how DTAs,
 *   events, and event sets interact.
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
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
FROM
DISCRETE_TASK_ASSAY dta
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
PLAN dta
WHERE dta.task_assay_cd = < .. .. >
JOIN p
JOIN ar_cnt
JOIN cvr_cnt
JOIN dm_cnt
JOIN eq_cnt
JOIN rrf_cnt
ORDER BY
activity_type, CNVTUPPER(dta.description)
