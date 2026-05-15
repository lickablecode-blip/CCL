/*
 * Source page  : Document events (WIP)
 * Source file  : output/document-events-wip.md
 * Anchor       : Encounter Detail Audit query, 5/5/2025
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 119
 *
 * Context (preceding paragraph):
 *   (no preceding paragraph)
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

ELSEIF($cat =
"encounter" AND $enc_rpt = "Documentation")
fin = ids->fin
,note_type = UAR_GET_CODE_DISPLAY(ce.event_cd) ;this is what's
displayed in
,note_title = ce.event_title_text
,authored_dt_tm = DATETIMEZONEFORMAT(ce.performed_dt_tm, ids->tz,
"MM/DD/YYYY HH:MM;;q")
,signed_dt_tm = DATETIMEZONEFORMAT(ce.verified_dt_tm, ids->tz,
"MM/DD/YYYY HH:MM;;q")
,note_status =
IF(ce.view_level = 1 AND ce.publish_flag = 0 AND ce.result_status_cd =
33)
"in progress (open draft)"
ELSEIF(ce.view_level = 1 AND ce.publish_flag = 1 AND
ce.result_status_cd = 33)
"in progress (closed draft)"
ELSEIF(latest.event_id > 0) "complete"
ELSE "unknown"
ENDIF
,sign_status =
IF(cep2.ce_event_prsnl_id = 0 AND latest.event_id > 0)
"signed"
ELSEIF(cep2.ce_event_prsnl_id = 0 AND latest.event_id = 0) "needs
signature"
ELSEIF(cep2.ce_event_prsnl_id > 0 AND cosigner.person_id !=
latest.action_prsnl_id) "needs cosignature"
ELSEIF(cep2.ce_event_prsnl_id > 0 AND cosigner.person_id =
latest.action_prsnl_id) "cosigned"
ELSE "unknown"
ENDIF
,author = author.name_full_formatted
,signed = IF(latest.event_id > 0) "yes" ELSE
"no" ENDIF
,cosign_author = cosigner.name_full_formatted
,cosigned =
IF(cep2.ce_event_prsnl_id = 0) "n/a"
ELSEIF(cep2.ce_event_prsnl_id > 0 AND cosigner.person_id =
latest.action_prsnl_id) "yes"
ELSE "no"
ENDIF
,pending_sign = IF(cep1.ce_event_prsnl_id > 0) "yes" ELSE
"no" ENDIF
,pending_cosign = IF(cep2.ce_event_prsnl_id > 0 AND
cep2.action_status_cd = 657) "yes" ELSE "no" ENDIF
,last_sign_action =
CNVTLOWER(UAR_GET_CODE_DISPLAY(latest.action_type_cd))
,last_signed_by = last_sign_p.name_full_formatted
,last_signed_dt_tm = DATETIMEZONEFORMAT(latest.action_dt_tm,
ids->tz, "MM/DD/YYYY HH:MM;;q")
,note_class_loinc = class_loinc.alias
 ,note_type_loinc = type_loinc.alias
,entry_mode = UAR_GET_CODE_DISPLAY(ce.entry_mode_cd)
,ce.event_cd
,ce.event_id
FROM CLINICAL_EVENT ce
 ,(LEFT JOIN CODE_VALUE_OUTBOUND
class_loinc ON ce.event_cd = class_loinc.code_value
 AND
class_loinc.contributor_source_cd = 18024137 ;LOINC
 AND class_loinc.alias_type_meaning
= "CLASSCODE")
 ,(LEFT JOIN CODE_VALUE_OUTBOUND
type_loinc ON ce.event_cd = type_loinc.code_value
 AND
type_loinc.contributor_source_cd = 18024137 ;LOINC
 AND type_loinc.alias_type_meaning =
"CONTENTTYPE")
,(LEFT JOIN CE_EVENT_PRSNL cep1
ON ce.event_id = cep1.event_id
AND cep1.action_type_cd = 107 ;sign
AND cep1.action_status_cd = 614384 ;pending
AND cep1.valid_until_dt_tm > SYSDATE)
,(LEFT JOIN CE_EVENT_PRSNL cep2 ;cosign
ON ce.event_id = cep2.event_id
AND cep2.request_prsnl_id = ce.performed_prsnl_id
AND cep2.action_prsnl_id != cep2.request_prsnl_id
AND cep2.action_type_cd = 107 ;sign
AND cep2.valid_until_dt_tm > SYSDATE)
,(LEFT JOIN PRSNL cosigner ON cep2.action_prsnl_id =
cosigner.person_id)
,(LEFT JOIN (
SELECT cep.event_id
,cep.ce_event_prsnl_id
,cep.action_prsnl_id
,cep.action_type_cd
,cep.action_dt_tm
,cep_rank = ROW_NUMBER() OVER(PARTITION BY cep.event_id ORDER BY
cep.action_dt_tm DESC)
FROM CE_EVENT_PRSNL cep
,PRSNL p
WHERE cep.action_type_cd IN (107, 112) ;sign, verify
AND cep.action_status_cd = 653
AND cep.valid_until_dt_tm > SYSDATE
AND cep.action_prsnl_id = p.person_id
WITH
SQLTYPE("f8","f8","f8","f8","dq8","i2"))
latest
ON ce.event_id = latest.event_id AND latest.cep_rank = 1)
,(LEFT JOIN PRSNL last_sign_p ON latest.action_prsnl_id =
last_sign_p.person_id)
,PRSNL author
PLAN ce WHERE ce.encntr_id = ids->encntr_id
AND (ce.event_class_cd = 231 ;mdoc
OR (ce.event_class_cd = 234 AND ce.entry_mode_cd != 677004) ;radiology,
but not undefined
)
AND ce.view_level = 1
AND ce.result_status_cd NOT IN (28,29,30,31)
AND ce.valid_until_dt_tm > SYSDATE
JOIN author WHERE ce.performed_prsnl_id = author.person_id
JOIN class_loinc
JOIN type_loinc
JOIN cep1
JOIN cep2
JOIN cosigner
JOIN latest
JOIN last_sign_p
ORDER BY ce.performed_dt_tm
