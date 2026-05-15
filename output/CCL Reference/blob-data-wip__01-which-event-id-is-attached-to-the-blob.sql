/*
 * Source page  : BLOB data (WIP)
 * Source file  : output/blob-data-wip.md
 * Anchor       : Which event_id is attached to the BLOB?
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 25
 *
 * Context (preceding paragraph):
 *   Pathology report example:
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
parent_event_id = ce.event_id
,child_event_id = ce2.event_id
,ce2.view_level
,ce_blob = IF(cb.event_id != 0) "yes" ELSE "no"
ENDIF
,cb.blob_length
,event = UAR_GET_CODE_DISPLAY(ce2.event_cd)
,ce2.event_title_text
FROM
CLINICAL_EVENT ce
,CLINICAL_EVENT ce2
,(LEFT JOIN CE_BLOB cb ON cb.event_id = ce2.event_id
AND cb.valid_until_dt_tm > SYSDATE)
PLAN ce WHERE
ce.event_id = <document event_id>
AND ce.valid_until_dt_tm > SYSDATE
JOIN ce2
WHERE ce2.parent_event_id = ce.event_id
AND ce2.valid_until_dt_tm > SYSDATE
JOIN cb
ORDER BY
ce2.view_level DESC, ce2.event_end_dt_tm
WITH TIME=30,
UAR_CODE(D,1)
