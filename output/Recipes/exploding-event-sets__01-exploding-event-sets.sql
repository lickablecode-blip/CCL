/*
 * Source page  : Exploding event sets
 * Source file  : output/exploding-event-sets.md
 * Anchor       : (top of page)
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 15
 *
 * Context (preceding paragraph):
 *   Example:
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
event_set = UAR_GET_CODE_DISPLAY(es_code.event_set_cd)
,es_code.event_set_cd
,event = UAR_GET_CODE_DISPLAY(es_expl.event_cd)
,es_expl.event_cd
FROM
V500_EVENT_SET_CODE es_code
,V500_EVENT_SET_EXPLODE es_expl
PLAN es_code
WHERE es_code.event_set_name_key = "MILITARYSPECIALDUTYSTATUS"
JOIN es_expl
WHERE es_code.event_set_cd = es_expl.event_set_cd
ORDER BY
UAR_GET_CODE_DISPLAY(es_expl.event_cd)
WITH TIME=30
