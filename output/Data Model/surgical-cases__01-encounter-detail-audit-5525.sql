/*
 * Source page  : Surgical cases
 * Source file  : output/surgical-cases.md
 * Anchor       : Encounter Detail Audit, 5/5/25
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 90
 *
 * Context (preceding paragraph):
 *   (no preceding paragraph)
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

ELSEIF($cat =
"encounter" AND $enc_rpt = "Surgical Case Info")
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
         IF(surgeon.person_id
> 0)
                 CONCAT(TRIM(surgeon.name_full_formatted),
" (",
                                 TRIM(UAR_GET_CODE_DISPLAY(surgeon.position_cd)),
")")
         ELSE ""
         ENDIF
 ,surgeon_specialty =
surg_spec.prsnl_group_name
 ,primary_anesthesiologist =
         IF(anesth.person_id >
0)
                 CONCAT(TRIM(anesth.name_full_formatted),
" (",
                                 TRIM(UAR_GET_CODE_DISPLAY(anesth.position_cd)),
")")
         ELSE ""
         ENDIF
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
 JOIN preop WHERE sc.preop_diag_text_id =
preop.long_text_id
 JOIN postop WHERE sc.postop_diag_text_id =
postop.long_text_id
 JOIN surgeon WHERE sc.surgeon_prsnl_id =
surgeon.person_id
 JOIN anesth WHERE sc.anesth_prsnl_id =
anesth.person_id
 JOIN surg_spec WHERE sc.surg_specialty_id =
surg_spec.prsnl_group_id
