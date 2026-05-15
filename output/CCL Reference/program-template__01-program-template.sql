/*
 * Source page  : Program template
 * Source file  : output/program-template.md
 * Anchor       : (top of page)
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 82
 *
 * Context (preceding paragraph):
 *   (no preceding paragraph)
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

/******************************************************************************
 REPORT NAME:
 PROGRAM:
 DEV
PROGRAM:
 DEVELOPER:
 PUBLISHED:
 SNAPSHOT:
 LOGICAL
PATH:        cust_script
 NODE:                <default>
 PURPOSE/DESCRIPTION:
 TARGET AUDIENCE:
 DEPENDENCIES:
 CAVEATS:
MOD        DATE                DEVELOPER        COMMENT
---        --/--/--        ---------        ----------------------------
TODO:
BUGS:
CONSIDER:
******************************************************************************/
prompt
"Output to File/Printer/MINE" = "MINE" ;* Enter or select the printer or file name
to send this report to.
with OUTDEV
/**************************************************************
; Global
Declarations
**************************************************************/
/**************************************************************
; Record
Structures
**************************************************************/
/**************************************************************
; Subroutines
**************************************************************/
; Removes all
line feeds/carriage returns/tabs from a string
subroutine
(replace_CRLF(input = vc) = vc)
declare output = vc with protect, noconstant("")
declare CRLF = vc with protect, constant(concat(char(13), char(10)))
declare CR = vc with protect, constant(char(13)) ;carriage return
declare LF = vc with protect, constant(char(10)) ;line feed
declare HT = vc with protect, constant(char(9)) ;horizontal tab
declare REPLACEMENT = vc with constant(" ")
; remove carriage return+line feed at the beginning and end of the
string
set output = trim(input, 3) ; option 3 -> Trim leading and trailing
spaces
; replace carriage return+line feed inside string
set output = replace(output, CRLF, REPLACEMENT)
set output = replace(output, CR, REPLACEMENT)
set output = replace(output, LF, REPLACEMENT)
set output = replace(output, HT, REPLACEMENT)
set output = TRIM(output)
return (output)
end
/**************************************************************
; Main
**************************************************************/
/**************************************************************
; Output
**************************************************************/
SELECT ;INTO
$OUTDEV
; Check for
empty record and inform user gracefully
IF(<some
condition>)
error = "not implemented"
ELSEIF(<some
condition>)
error = "not implemented"
ENDIF
INTO $OUTDEV
error = "fallback reached"
WITH
NOCOUNTER, SEPARATOR=" ", FORMAT, CHECK
,EXPAND=2, MAXCOL=1000, TIME=1000
end
go
