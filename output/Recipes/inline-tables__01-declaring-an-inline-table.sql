/*
 * Source page  : Inline tables
 * Source file  : output/inline-tables.md
 * Anchor       : Declaring an inline table
 * Block index  : 1 of 7
 * Detected lang: sql
 * Lines        : 11
 *
 * Context (preceding paragraph):
 *   See [SQLTYPE](onenote:#WITH%20clause%20(WIP)&section-
 *   id={366D31C5-27D7-4F27-B3DE-5EADBA845F75}&page-
 *   id={AAD5811F-9A32-4E78-827F-1411DDB8F5C8}&object-
 *   id={6D343FE2-22E9-07F7-2700-1F3F7EFE4335}&97&base-path=https://militaryhealth-
 *   my.sharepoint-mil.us/personal/david_a_alt2_mil_health_mil/Documents/Documents/OneNote%2
 *   0Notebooks/Development-Shared/CCL%20-%20Technical.one) for more details.
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT *
FROM
(
 (
 SELECT p.name_full_formatted
 FROM PERSON p
 WHERE p.person_id =
<person_id>
 WITH SQLTYPE("vc")
 ) name_of_inline_table
)
