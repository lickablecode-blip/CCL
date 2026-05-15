/*
 * Source page  : Evaluate
 * Source file  : output/evaluate.md
 * Anchor       : Why use EVALUATE2 when you can just use IF... statements directly?
 * Block index  : 3 of 4
 * Detected lang: unknown
 * Lines        : 11
 *
 * Context (preceding paragraph):
 *   This is valid:
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

subroutine
(my_sub(a = i2, b = i2) = i2)
declare output = i2
output = EVALUATE2(
IF(a = 1) ....
ELSEIF(b = 2) .....
ELSE ....
ENDIF
)
return (output)
end
