/*
 * Source page  : UAR_GET_CODE_DESCRIPTION
 * Source file  : output/uar-get-code-description.md
 * Anchor       : Example (UAR_GET_CODE_DESCRIPTION)
 * Block index  : 1 of 2
 * Detected lang: ccl
 * Lines        : 7
 *
 * Context (preceding paragraph):
 *   For quick queries, you can also use UAR_CODE(E) or UAR_CODE(E,1) in the WITH clause.
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
encntr_type = UAR_GET_CODE_DESCRIPTION(e.encntr_type_cd)
,disch_disp = UAR_GET_CODE_DESCRIPTION(e.disch_disposition_cd)
FROM
ENCOUNTER e
PLAN e WHERE
e.active_ind = 1
