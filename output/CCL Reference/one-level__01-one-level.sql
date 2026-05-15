/*
 * Source page  : One level
 * Source file  : output/one-level.md
 * Anchor       : (top of page)
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 31
 *
 * Context (preceding paragraph):
 *   This demonstrates a simple record structure used to store static values. These are not
 *   generally loaded from a query, although they can be. Single-level record structures are
 *   useful for storing program-level information. For example, the report "Encounter Detail
 *   Audit" lets users enter a variety of identifiers in the prompt, like encntr_id, FIN, or
 *   MRN. These are all converted to encntr_id and stored in a record structure. All the
 *   subsequent queries can reference the encntr_id in the record structure regardless of
 *   what identifier the user entered in the prompt, simplifying the code.
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

/**************************************************************
; Declarations
**************************************************************/
FREE RECORD
identifiers
RECORD
identifiers (
1 person_id = f8
1 encntr_id = f8
) with
protect
/**************************************************************
; Init
**************************************************************/
;Load the record structure - use direct assignment.
Because there is only
; a single row, you don't need to allocate memory to
a list
SET
identifiers->person_id = <some person_id>
SET
identifiers->encntr_id = <some encntr_id>
/**************************************************************
; Report
**************************************************************/
SELECT INTO
$OUTDEV
person_id = identifiers->person_id
,encntr_id = identifiers->encntr_id
WITH
NOCOUNTER, SEPARATOR=" ", FORMAT, TIME=30
