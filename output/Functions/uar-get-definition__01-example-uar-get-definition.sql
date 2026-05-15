/*
 * Source page  : UAR_GET_DEFINITION
 * Source file  : output/uar-get-definition.md
 * Anchor       : Example (UAR_GET_DEFINITION)
 * Block index  : 1 of 2
 * Detected lang: ccl
 * Lines        : 7
 *
 * Context (preceding paragraph):
 *   Retrieves a code value definition from a given code value
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
encntr_type = UAR_GET_DEFINITION(e.encntr_type_cd)
,disch_disp = UAR_GET_DEFINITION(e.disch_disposition_cd)
FROM
ENCOUNTER e
PLAN e WHERE
e.active_ind = 1
