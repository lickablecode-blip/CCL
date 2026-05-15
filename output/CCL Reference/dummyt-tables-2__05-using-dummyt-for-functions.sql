/*
 * Source page  : DUMMYT tables
 * Source file  : output/dummyt-tables-2.md
 * Anchor       : Using DUMMYT for functions
 * Block index  : 5 of 5
 * Detected lang: ccl
 * Lines        : 7
 *
 * Context (preceding paragraph):
 *   "The MONTH function is not allowed by Oracle but we want our query results to only
 *   return rows that were updated in September."
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
p.updt_dt_tm
FROM PERSON p
,DUMMYT d
PLAN p
JOIN d WHERE
MONTH(p.updt_dt_tm) = 9
