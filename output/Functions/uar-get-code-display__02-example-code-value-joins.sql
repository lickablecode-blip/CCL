/*
 * Source page  : UAR_GET_CODE_DISPLAY
 * Source file  : output/uar-get-code-display.md
 * Anchor       : Example (CODE_VALUE joins)
 * Block index  : 2 of 2
 * Detected lang: ccl
 * Lines        : 13
 *
 * Context (preceding paragraph):
 *   For quick queries, you can also use UAR_CODE(D) or UAR_CODE(D,1) in the WITH clause.
 *   See [UAR_CODE](onenote:#WITH%20clause%20(WIP)&section-
 *   id={366D31C5-27D7-4F27-B3DE-5EADBA845F75}&page-
 *   id={AAD5811F-9A32-4E78-827F-1411DDB8F5C8}&object-
 *   id={FA4066B0-3C79-0397-27E9-31D99B05134B}&8F&base-path=https://militaryhealth-
 *   my.sharepoint-mil.us/personal/david_a_alt2_mil_health_mil/Documents/Documents/OneNote%2
 *   0Notebooks/Development-Shared/CCL%20-%20Technical.one) for more details.
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
encntr_type = encntr_type.display
,disch_disp = disch_disp.display
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
