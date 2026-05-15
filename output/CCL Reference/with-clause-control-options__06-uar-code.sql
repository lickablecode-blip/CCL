/*
 * Source page  : WITH clause (control options)
 * Source file  : output/with-clause-control-options.md
 * Anchor       : UAR_CODE
 * Block index  : 6 of 8
 * Detected lang: sql
 * Lines        : 7
 *
 * Context (preceding paragraph):
 *   Example - display values only:
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
e.encntr_type_cd
,e.disch_disposition_cd
FROM
ENCOUNTER e
WITH
UAR_CODE(D,1), MAXREC=3, TIME=30
