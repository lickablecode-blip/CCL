/*
 * Source page  : WITH clause (control options)
 * Source file  : output/with-clause-control-options.md
 * Anchor       : SEPARATOR
 * Block index  : 2 of 8
 * Detected lang: ccl
 * Lines        : 6
 *
 * Context (preceding paragraph):
 *   SEPARATOR tells Discern Output Viewer what symbol to use for separating columns. While
 *   optional for ad hoc queries, compiled programs will not display their output correctly
 *   without it. Any character can be used, although for "typical" output, a blank space is
 *   customary. Similarly, compiled programs need FORMAT in the WITH clause for proper
 *   display as well, although it doesn't require any parameters in that case.
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

WITH
SEPARATOR=" " ; space
WITH
SEPARATOR="|" ; pipe
WITH
SEPARATOR=CHAR(9) ; tab
