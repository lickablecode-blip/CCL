/*
 * Source page  : Conditional clauses (parser)
 * Source file  : output/conditional-clauses-parser.md
 * Anchor       : (top of page)
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 53
 *
 * Context (preceding paragraph):
 *   In this example, a clause is prepared to restrict the output (a list of patients) to
 *   those with encounters. The prompt has a radio button ($has_encntrs) to restrict the
 *   results to patients with encounter.
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

; Create a variable to hold the parser value
declare
has_encntrs_parser = vc with protect, noconstant("0=1")
; Set the parser value based on the user's prompt
selection
IF(value($has_encntrs)
= "yes")
SET has_encntrs_parser =
CONCAT(
"EXISTS (",
"SELECT 1",
"FROM ENCOUNTER e",
"WHERE e.person_id = p.person_id"
")"
)
ELSE
SET has_encntrs_parser = "1=1"
ENDIF
; Run the
actual query
SELECT
p.person_id
FROM PERSON p
PLAN p WHERE
p.active_ind = 1
AND PARSER(has_encntrs_parser)
; If the user chose "yes"
SELECT
p.person_id
FROM PERSON p
PLAN p WHERE
p.active_ind = 1
AND EXISTS (
SELECT 1
FROM ENCOUNTER e
WHERE e.person_id = p.person_id
)
; If the user didn't choose "yes"
SELECT
p.person_id
FROM PERSON p
PLAN p WHERE
p.active_ind = 1
AND 1=1 ;this will always be true, and thus ignored
; If the prompt value is invalid, variable default is
"0=1"
SELECT
p.person_id
FROM PERSON p
PLAN p WHERE
p.active_ind = 1
AND 0=1 ;this will always fail because
it's always false
