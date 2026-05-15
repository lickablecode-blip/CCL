/*
 * Source page  : DateTimeDiff
 * Source file  : output/datetimediff.md
 * Anchor       : (top of page)
 * Block index  : 2 of 2
 * Detected lang: ccl
 * Lines        : 13
 *
 * Context (preceding paragraph):
 *   [https://wiki.cerner.com/display/public/1101discernHP/DATETIMEDIFF+Using+Discern+Explor
 *   er](https://wiki.cerner.com/display/public/1101discernHP/DATETIMEDIFF+Using+Discern+Exp
 *   lorer)
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
e.reg_dt_tm "MM/DD/YYYY HH:MM;;q"
,e.disch_dt_tm "MM/DD/YYYY HH:MM;;q"
,tat_min = DATETIMEDIFF(e.disch_dt_tm, e.reg_dt_tm, 4)
,tat_hrs = DATETIMEDIFF(e.disch_dt_tm, e.reg_dt_tm, 3)
,tat_days = DATETIMEDIFF(e.disch_dt_tm, e.reg_dt_tm, 1)
,tat_weeks = DATETIMEDIFF(e.disch_dt_tm, e.reg_dt_tm, 2)
,tat_formatted = FORMAT(DATETIMEDIFF(e.disch_dt_tm, e.reg_dt_tm, 7),
"####d.##h.##m")
FROM
ENCOUNTER e
PLAN e WHERE
e.encntr_id = <encntr_id>
