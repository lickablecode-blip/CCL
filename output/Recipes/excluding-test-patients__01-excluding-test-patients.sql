/*
 * Source page  : Excluding test patients
 * Source file  : output/excluding-test-patients.md
 * Anchor       : (top of page)
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 21
 *
 * Context (preceding paragraph):
 *   See CCL - Content/ [Test
 *   patients](onenote:CCL%20-%20Content.one#Test%20patients&section-
 *   id={3A32472C-2C84-4CDE-B609-CFCD47A33197}&page-
 *   id={7ED543A7-2B85-4EC5-A3D3-3127813FD20F}&end&base-path=https://militaryhealth-
 *   my.sharepoint-mil.us/personal/david_a_alt2_mil_health_mil/Documents/Documents/OneNote%2
 *   0Notebooks/Development-Shared) for full details.
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
p.name_full_formatted
,test_patient_identifier = UAR_GET_CODE_DISPLAY(tpi.value_cd)
FROM PERSON p
,PERSON_INFO tpi
PLAN p WHERE
p.active_ind = 1
AND NOT EXISTS (
SELECT 1
FROM PERSON_INFO tpi
WHERE tpi.person_id = p.person_id
AND tpi.info_sub_type_cd = 2678703703 ;test patient identifier
AND tpi.value_cd != 2678703509 ;"not a test patient"
AND tpi.active_ind = 1
)
JOIN tpi
WHERE tpi.person_id = p.person_id
AND tpi.info_sub_type_cd = 2678703703 ;test patient identifier
AND tpi.active_ind = 1
WITH TIME=30,
MAXREC=30
