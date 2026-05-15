/*
 * Source page  : Procedures
 * Source file  : output/procedures.md
 * Anchor       : Procedure History (PROCEDURE)
 * Block index  : 3 of 3
 * Detected lang: ccl
 * Lines        : 58
 *
 * Context (preceding paragraph):
 *   The key flag for distinguishing a procedure performed at an encounter vs merely
 *   documented is PROCEDURE.proc_type_flag. If the value is 1, then the procedure was
 *   performed at the encounter. This is also the key to creating a "past surgical history"
 *   view - by including all flag types and ignoring the encntr_ids.
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
 procedure = EVALUATE2(
 IF(TEXTLEN(TRIM(p.procedure_note)) = 0)
n.source_string
 ELSE p.procedure_note
 ENDIF)
 ,procedure_dt_tm = p.proc_dt_tm
 ,added_dt_tm = p.beg_effective_dt_tm
 ,proc_type = EVALUATE(p.proc_type_flag,
0, "unknown",
1, "associated with encounter",
2, "historical/narrative",
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
 ,encntr_location = IF(p.proc_type_flag = 1)
UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd) ENDIF
 ,encntr_med_service = IF(p.proc_type_flag =
1) UAR_GET_CODE_DISPLAY(e.med_service_cd) ENDIF
 ,contrib_system =
UAR_GET_CODE_DISPLAY(p.contributor_system_cd)
 ;IDENTIFIERS
 ,p.encntr_id
 ,p.procedure_id
FROM
ENCOUNTER e
 ,(LEFT JOIN ENCNTR_ALIAS fin ON
fin.encntr_id = e.encntr_id
 AND fin.encntr_alias_type_cd = 1077
;fin
 AND fin.end_effective_dt_tm >
SYSDATE
 AND fin.active_ind = 1)
 ,PROCEDURE p
 ,NOMENCLATURE n
PLAN e WHERE
e.person_id = <insert encntr_id>
 AND e.end_effective_dt_tm > SYSDATE
 AND e.active_ind = 1
JOIN p WHERE
p.encntr_id = e.encntr_id
 AND p.end_effective_dt_tm >= SYSDATE
 AND p.active_ind = 1
JOIN n WHERE
n.nomenclature_id = p.nomenclature_id
 AND n.vocab_axis_cd != 674338 ;exclude
E&M codes
JOIN fin
ORDER BY
procedure, p.proc_dt_tm, p.beg_effective_dt_tm
WITH TIME=30
