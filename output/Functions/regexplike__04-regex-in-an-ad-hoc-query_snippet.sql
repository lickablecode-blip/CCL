/*
 * Source page  : RegExpLike
 * Source file  : output/regexplike.md
 * Anchor       : RegEx in an ad hoc query
 * Block index  : 4 of 5
 * Detected lang: sql
 * Lines        : 4
 *
 * Context (preceding paragraph):
 *   If you use a regular expression (besides the OPERATOR function) in an AD_HOC query, you
 *   must put it in a SQLPASSTHRU function:
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
temp1=(sqlpassthru("REGEXP_SUBSTR('Mary
had a little lamb','had.*?lamb')",150))
FROM DUAL
