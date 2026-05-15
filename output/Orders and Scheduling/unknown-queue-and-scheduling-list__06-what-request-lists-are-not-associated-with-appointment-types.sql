/*
 * Source page  : Unknown Queue and Scheduling List
 * Source file  : output/unknown-queue-and-scheduling-list.md
 * Anchor       : What request lists are not associated with appointment types?
 * Block index  : 6 of 8
 * Detected lang: ccl
 * Lines        : 20
 *
 * Context (preceding paragraph):
 *   WITH TIME=30, UAR_CODE(D)
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
request_list_not_associated_to_appt_types = so.mnemonic
,list_created_dt_tm = so.beg_effective_dt_tm
FROM
SCH_OBJECT so
PLAN so WHERE
1=1
AND so.object_type_cd = 625790 ;request list queue
AND NOT EXISTS (
SELECT sar.routing_id
FROM SCH_APPT_ROUTING sar
WHERE sar.routing_id = so.sch_object_id
AND sar.active_ind = 1
AND sar.end_effective_dt_tm > SYSDATE
AND sar.version_dt_tm > SYSDATE)
AND so.active_ind = 1
AND so.end_effective_dt_tm > SYSDATE
AND so.version_dt_tm > SYSDATE
ORDER BY 1
WITH TIME=30
