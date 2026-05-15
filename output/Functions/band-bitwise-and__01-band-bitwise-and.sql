/*
 * Source page  : BAND (Bitwise AND)
 * Source file  : output/band-bitwise-and.md
 * Anchor       : (top of page)
 * Block index  : 1 of 1
 * Detected lang: unknown
 * Lines        : 29
 *
 * Context (preceding paragraph):
 *   Example from PowerForm Detail Audit
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

; Evaluate
where the search results were found
subroutine
(eval_result_bit(result_bit=i4) = vc)
declare output = vc with protect
declare change_cnt = i2 with protect
declare trunc_len = i2 with protect
set output = ""
set change_cnt = 0
IF(BAND(result_bit, form_bit) = form_bit)
set output = CONCAT(output, "form,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(result_bit, section_bit) = section_bit)
set output = CONCAT(output, "section,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(result_bit, question_bit) = question_bit)
set output = CONCAT(output, "question (DTA),")
set change_cnt = change_cnt + 1
ENDIF
;if there is text with a trailing comma, remove the last comma
IF(change_cnt > 0)
set output = REPLACE(output, ",", ", ")
set trunc_len = TEXTLEN(output) - 1
set output = SUBSTRING(1,trunc_len,output)
ENDIF
return (output)
end
