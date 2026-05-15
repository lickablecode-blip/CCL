/*
 * Source page  : Unknown Queue and Scheduling List
 * Source file  : output/unknown-queue-and-scheduling-list.md
 * Anchor       : What appointment types are associated with a request list?
 * Block index  : 7 of 8
 * Detected lang: ccl
 * Lines        : 28
 *
 * Context (preceding paragraph):
 *   WITH TIME=30, UAR_CODE(D)
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
request_list = so.description
,associated_appt_type = UAR_GET_CODE_DISPLAY(sar.appt_type_cd)
,nbr_locations = COUNT(DISTINCT sar.location_cd)
;,appt_loc = UAR_GET_CODE_DISPLAY(sar.location_cd)
;,action = sar.action_meaning
;,sar.sch_flex_id
FROM
SCH_OBJECT so
,SCH_APPT_ROUTING sar
PLAN so WHERE
1=1 ;so.sch_object_id =
$req_list
AND so.object_type_cd = 625790 ;request list queue
AND so.active_ind = 1
AND so.end_effective_dt_tm > SYSDATE
AND so.version_dt_tm > SYSDATE
JOIN sar
WHERE sar.routing_id = so.sch_object_id
AND sar.action_meaning = "SCHEDULE"
AND sar.active_ind = 1
AND sar.end_effective_dt_tm > SYSDATE
AND sar.version_dt_tm > SYSDATE
GROUP BY
so.description, sar.appt_type_cd
ORDER BY
request_list, associated_appt_type
WITH TIME=30
