/*
 * Source page  : RegExpLike
 * Source file  : output/regexplike.md
 * Anchor       : RegEx in a compiled program
 * Block index  : 5 of 5
 * Detected lang: sql
 * Lines        : 6
 *
 * Context (preceding paragraph):
 *   If you use the regular expression in a program, you can define the function in CCL and
 *   then you can use it directly without needing the SQLPASSTHRU.
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

declare
REGEXP_SUBSTR()=vc
SELECT
temp1=REGEXP_SUBSTR('Whos
fleece was white as snow','\w* was \w*')
FROM DUAL
