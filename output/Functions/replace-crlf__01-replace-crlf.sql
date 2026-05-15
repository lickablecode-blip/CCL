/*
 * Source page  : replace_CRLF
 * Source file  : output/replace-crlf.md
 * Anchor       : (top of page)
 * Block index  : 1 of 1
 * Detected lang: unknown
 * Lines        : 22
 *
 * Context (preceding paragraph):
 *   Removes all line feeds/carriage returns/tabs from a string
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

subroutine
(replace_CRLF(input = vc) = vc)
; HT = char(9) horizontal tab
; LF = char(10) line feed
; CR = char(13) carriage return
declare output = vc with protect, noconstant("")
declare CRLF = vc with protect, constant(concat(char(13), char(10)))
declare CR = vc with protect, constant(char(13))
declare LF = vc with protect, constant(char(10))
declare HT = vc with protect, constant(char(9))
declare REPLACEMENT = vc with constant(" ")
; remove carriage return+line feed at the beginning and end of the
string
; option 3 -> Trim leading and trailing spaces
set output = trim(input, 3)
; replace carriage return+line feed inside string
set output = replace(output, CRLF, REPLACEMENT)
set output = replace(output, CR, REPLACEMENT)
set output = replace(output, LF, REPLACEMENT)
set output = replace(output, HT, REPLACEMENT)
return (output)
end
