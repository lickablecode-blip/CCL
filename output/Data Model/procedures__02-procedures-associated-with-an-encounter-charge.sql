/*
 * Source page  : Procedures
 * Source file  : output/procedures.md
 * Anchor       : Procedures associated with an encounter (CHARGE)
 * Block index  : 2 of 3
 * Detected lang: ccl
 * Lines        : 68
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
ord_p.name_full_formatted
 ,performing_provider =
perf_p.name_full_formatted
 ,verifying_provider =
verify_p.name_full_formatted
 ,tier_group =
UAR_GET_CODE_DISPLAY(c.tier_group_cd)
 ,charge_type =
UAR_GET_CODE_DISPLAY(c.charge_type_cd)
 ,mod_type =
UAR_GET_CODE_DISPLAY(cm.charge_mod_type_cd)
 ,mod_source =
UAR_GET_CODE_DISPLAY(cm.charge_mod_source_cd)
 ,service_dt_tm = c.service_dt_tm
"MM/DD/YYYY HH:MM;;q"
 ,credited_dt_tm = c.credited_dt_tm
"MM/DD/YYYY HH:MM;;q"
 ; IDENTIFIERS
 ,c.order_id
 ,c.bill_item_id
 ,c.charge_item_id
 ,cm.charge_mod_id
FROM
CHARGE c
 ,(LEFT JOIN PRSNL ord_p ON c.ord_phys_id =
ord_p.person_id)
 ,(LEFT JOIN PRSNL perf_p ON c.perf_phys_id
= perf_p.person_id)
 ,(LEFT JOIN PRSNL verify_p ON
c.verify_phys_id = verify_p.person_id)
 ,CHARGE_MOD cm
 ,NOMENCLATURE n
PLAN c WHERE
c.encntr_id = <insert encntr_id>
 AND c.end_effective_dt_tm > SYSDATE
 AND c.active_ind = 1
JOIN cm WHERE
cm.charge_item_id = c.charge_item_id
 AND cm.end_effective_dt_tm > SYSDATE
 AND cm.active_ind = 1
JOIN n WHERE
n.nomenclature_id = cm.nomen_id AND n.principle_type_cd != 1252 ;Disease or
Syndrome
JOIN ord_p
JOIN perf_p
JOIN verify_p
ORDER BY
activity_type, c.charge_item_id, cm.charge_mod_id
WITH TIME=30
