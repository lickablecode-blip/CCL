/*
 * Source page  : Procedures
 * Source file  : output/procedures.md
 * Anchor       : Procedures associated with an encounter (PROCEDURE)
 * Block index  : 1 of 3
 * Detected lang: ccl
 * Lines        : 54
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
 e.encntr_id
 ,procedure = EVALUATE2(
 IF(TEXTLEN(TRIM(p.procedure_note)) = 0)
n.source_string
 ELSE p.procedure_note
 ENDIF)
 ,p.proc_dt_tm
 ,proc_type = EVALUATE(p.proc_type_flag,
0, "unknown",
1, "associated with encounter",
2, "historical/narrative",
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
 ;IDENTIFIERS
 ,p.procedure_id
 ,p.nomenclature_id
FROM
ENCOUNTER e
 ,PROCEDURE p
 ,(LEFT JOIN PROC_MODIFIER pm ON
pm.parent_entity_id = p.procedure_id
 AND pm.parent_entity_name =
"PROCEDURE"
 AND pm.active_ind = 1)
 ,(LEFT JOIN NOMENCLATURE pmn ON
pmn.nomenclature_id = pm.nomenclature_id
 AND pmn.active_ind = 1)
 ,NOMENCLATURE n
PLAN e WHERE
e.encntr_id = <insert encntr_id>
JOIN p WHERE
p.encntr_id = e.encntr_id
 AND p.proc_type_flag != 2 ;exclude narrated
(aka historical) procedures
 AND p.end_effective_dt_tm >= SYSDATE
 AND p.active_ind = 1
JOIN n WHERE
n.nomenclature_id = p.nomenclature_id
 ;AND n.data_status_cd != 39 ;Unauth
JOIN pm
JOIN pmn
ORDER BY
p.proc_dt_tm DESC, p.proc_priority
WITH TIME=30
