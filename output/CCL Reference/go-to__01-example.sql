/*
 * Source page  : GO TO
 * Source file  : output/go-to.md
 * Anchor       : Example
 * Block index  : 1 of 1
 * Detected lang: unknown
 * Lines        : 12
 *
 * Context (preceding paragraph):
 *   The GO TO command allows you to arbitrarily jump to another part of the script, for
 *   example to exit gracefully on an error. The section it links to must be defined with a
 *   #.
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

set status =
initializeVariables(NULL)
if(status =
FAIL)
 go to EXIT_SCRIPT
endif
<… program code …>
#EXIT_SCRIPT
;for
debugging purposes
call
echorecord(inputParam)
