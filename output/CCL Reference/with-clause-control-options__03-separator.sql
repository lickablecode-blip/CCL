/*
 * Source page  : WITH clause (control options)
 * Source file  : output/with-clause-control-options.md
 * Anchor       : SEPARATOR
 * Block index  : 3 of 8
 * Detected lang: ccl
 * Lines        : 12
 *
 * Context (preceding paragraph):
 *   Example output from a program without SEPARATOR. Note the column names aren't displayed
 *   - some of the data is displaying there - and the values aren't contained within
 *   individual fields.
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
e.reg_dt_tm
,encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
,facility = UAR_GET_CODE_DESCRIPTION(e.loc_facility_cd)
,discharge = UAR_GET_CODE_DISPLAY(e.disch_disposition_cd)
FROM
ENCOUNTER e
PLAN e WHERE
e.active_ind = 1
WITH TIME=30,
MAXREC=5 ; WARNING - MISSING "SEPARATOR"
OPTION
