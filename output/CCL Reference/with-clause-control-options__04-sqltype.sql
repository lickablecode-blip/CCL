/*
 * Source page  : WITH clause (control options)
 * Source file  : output/with-clause-control-options.md
 * Anchor       : SQLTYPE
 * Block index  : 4 of 8
 * Detected lang: sql
 * Lines        : 19
 *
 * Context (preceding paragraph):
 *   SQLTYPE is used to map data types to fields on in-line tables. The number of parameters
 *   passed to SQLTYPE must match the number of columns in the in-line table. See [Inline
 *   tables](onenote:#Inline%20tables&section-
 *   id={366D31C5-27D7-4F27-B3DE-5EADBA845F75}&page-
 *   id={FDE87EEB-6D6F-4C85-B16D-564CC0EE48AC}&end&base-path=https://militaryhealth-
 *   my.sharepoint-mil.us/personal/david_a_alt2_mil_health_mil/Documents/Documents/OneNote%2
 *   0Notebooks/Development-Shared/CCL%20-%20Technical.one) for more examples.
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
inline_table.*
FROM
(
 (SELECT
 p.person_id
 ,nbr_encntrs =
COUNT(e.encntr_id)
 FROM
 ENCOUNTER e
,PERSON p
 WHERE e.person_id =
p.person_id
 GROUP BY p.person_id
 WITH
SQLTYPE("f8","i4") ; float, integer
 ) inline_table
)
WITH TIME=30
