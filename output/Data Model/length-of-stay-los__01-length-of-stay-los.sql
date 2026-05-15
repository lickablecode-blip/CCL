/*
 * Source page  : Length of stay (LOS)
 * Source file  : output/length-of-stay-los.md
 * Anchor       : (top of page)
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 13
 *
 * Context (preceding paragraph):
 *   Length of stay can be calculated using the DATETIMEDIFF function. See
 *   [DateTimeDiff](onenote:CCL%20-%20Technical.one#DateTimeDiff&section-
 *   id={366D31C5-27D7-4F27-B3DE-5EADBA845F75}&page-
 *   id={51A1172F-C982-452F-8210-C2AB5D4789A0}&end&base-path=https://militaryhealth-
 *   my.sharepoint-mil.us/personal/david_a_alt2_mil_health_mil/Documents/Documents/OneNote%2
 *   0Notebooks/Development-Shared) for full details.
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
e.reg_dt_tm "MM/DD/YYYY HH:MM;;q"
,e.disch_dt_tm "MM/DD/YYYY HH:MM;;q"
,los_min = DATETIMEDIFF(e.disch_dt_tm, e.reg_dt_tm, 4)
,los_hrs = DATETIMEDIFF(e.disch_dt_tm, e.reg_dt_tm, 3)
,los_days = DATETIMEDIFF(e.disch_dt_tm, e.reg_dt_tm, 1)
,los_weeks = DATETIMEDIFF(e.disch_dt_tm, e.reg_dt_tm, 2)
,los_formatted = FORMAT(DATETIMEDIFF(e.disch_dt_tm, e.reg_dt_tm, 7),
"####d.##h.##m")
FROM
ENCOUNTER e
PLAN e WHERE
e.encntr_id = <encntr_id>
