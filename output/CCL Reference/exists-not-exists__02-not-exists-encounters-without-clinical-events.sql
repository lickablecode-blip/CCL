/*
 * Source page  : EXISTS / NOT EXISTS
 * Source file  : output/exists-not-exists.md
 * Anchor       : NOT EXISTS - Encounters without clinical events
 * Block index  : 2 of 2
 * Detected lang: ccl
 * Lines        : 13
 *
 * Context (preceding paragraph):
 *   CCL does not support the use of EXISTS in the SELECT clause!
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
e.encntr_id
FROM
ENCOUNTER e
PLAN e WHERE
e.active_ind = 1
AND e.end_effective_dt_tm > SYSDATE
AND e.reg_dt_tm > SYSDATE-7
AND NOT EXISTS (SELECT 1
FROM CLINICAL_EVENT ce
WHERE e.encntr_id = ce.encntr_id)
WITH TIME=30,
MAXREC=100
