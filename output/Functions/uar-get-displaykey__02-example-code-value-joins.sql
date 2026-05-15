/*
 * Source page  : UAR_GET_DISPLAYKEY
 * Source file  : output/uar-get-displaykey.md
 * Anchor       : Example (CODE_VALUE joins)
 * Block index  : 2 of 2
 * Detected lang: ccl
 * Lines        : 13
 *
 * Context (preceding paragraph):
 *   Retrieves a code value display_key from a given code value
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
encntr_type = encntr_type.display_key
,disch_disp = disch_disp.display_key
FROM
ENCOUNTER e
,CODE_VALUE encntr_type
,CODE_VALUE disch_disp
PLAN e WHERE
e.active_ind = 1
JOIN
encntr_type WHERE encntr_type.code_value = e.encntr_type_cd
JOIN
disch_disp WHERE disch_disp.code_value = e.disch_disposition_cd
