/*
 * Source page  : Inline tables
 * Source file  : output/inline-tables.md
 * Anchor       : LEFT JOIN to an inline UNION table:
 * Block index  : 6 of 7
 * Detected lang: ccl
 * Lines        : 39
 *
 * Context (preceding paragraph):
 *   The key difference here is in the parentheses around the LEFT JOIN - because there is
 *   already the outer left parenthesis due to the left join, you only need a single one for
 *   the inline table.
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
cv.code_set
,cv.code_value
,cv.display
,source = UAR_GET_CODE_DISPLAY(aliases.contributor_source_cd)
,aliases.direction
,aliases.alias
,aliases.alias_type_meaning
FROM
CODE_VALUE cv
,(LEFT JOIN
(SELECT
code_set = ib.code_set
,code_value = ib.code_value
,contributor_source_cd = ib.contributor_source_cd
,alias = ib.alias
,alias_type_meaning = ib.alias_type_meaning
,direction =
"inbound"
FROM CODE_VALUE_ALIAS ib WHERE ib.code_set = 34
UNION
(SELECT
code_set = ob.code_set
,code_value = ob.code_value
,contributor_source_cd = ob.contributor_source_cd
,alias = ob.alias
,alias_type_meaning = ob.alias_type_meaning
,direction = "outbound"
FROM CODE_VALUE_OUTBOUND ob WHERE ob.code_set = 34
) WITH SQLTYPE("i4", "f8", "f8",
"c100", "c12", "c8"), RDBUNION) aliases
ON cv.code_set = aliases.code_set AND cv.code_value =
aliases.code_value)
PLAN cv WHERE
cv.code_set = 34
JOIN aliases
ORDER BY
cv.display_key, source, aliases.direction
WITH TIME=30
