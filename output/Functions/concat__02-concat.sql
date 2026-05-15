/*
 * Source page  : Concat
 * Source file  : output/concat.md
 * Anchor       : (top of page)
 * Block index  : 2 of 2
 * Detected lang: ccl
 * Lines        : 12
 *
 * Context (preceding paragraph):
 *   Example :
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
provider_with_position =
CONCAT(pr.name_full_formatted
," ("
,TRIM(UAR_GET_CODE_DISPLAY(pr.position_cd))
,")"
)
FROM PRSNL pr
PLAN pr WHERE
pr.position_cd != 0
WITH TIME=30,
MAXREC=30
