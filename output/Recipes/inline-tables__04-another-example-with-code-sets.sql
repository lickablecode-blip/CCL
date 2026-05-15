/*
 * Source page  : Inline tables
 * Source file  : output/inline-tables.md
 * Anchor       : Another example with code sets
 * Block index  : 4 of 7
 * Detected lang: ccl
 * Lines        : 20
 *
 * Context (preceding paragraph):
 *   CAVEAT : You can't use PLAN/JOIN in inline tables. Use the old-style joins in the WHERE
 *   clause. Example:
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
DISTINCT
OUTBOUND_SOURCE = UAR_GET_CODE_DISPLAY(tmp.contributor_source_cd)
,CODE_SETS = LISTAGG(tmp.code_set, ", ")
WITHIN GROUP(ORDER BY tmp.code_set)
OVER(PARTITION BY
tmp.contributor_source_cd)
FROM
((
 SELECT DISTINCT cvo.code_set,
cvo.contributor_source_cd
 FROM CODE_VALUE_OUTBOUND cvo
 WHERE cvo.code_set > 0
 ORDER cvo.code_set,
cvo.contributor_source_cd
 WITH SQLTYPE("i4",
"f8")
 ) tmp )
ORDER
OUTBOUND_SOURCE, CODE_SETS
