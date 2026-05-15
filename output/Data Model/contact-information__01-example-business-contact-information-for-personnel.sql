/*
 * Source page  : Contact information
 * Source file  : output/contact-information.md
 * Anchor       : Example - Business Contact Information for Personnel
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 66
 *
 * Context (preceding paragraph):
 *   Stored in the ADDRESS and PHONE tables. See the individual pages (
 *   [Address](onenote:#Address&section-id={3A32472C-2C84-4CDE-B609-CFCD47A33197}&page-
 *   id={D742290B-EBE0-4428-A0E2-73AF8501656F}&end&base-path=https://militaryhealth-
 *   my.sharepoint-mil.us/personal/david_a_alt2_mil_health_mil/Documents/Documents/OneNote%2
 *   0Notebooks/Development-Shared/CCL%20-%20Content.one) , [Email](onenote:#Email&section-
 *   id={3A32472C-2C84-4CDE-B609-CFCD47A33197}&page-id={6001F835-4477-4B2C-ABCB-
 *   DE71D72BCC6D}&end&base-path=https://militaryhealth-my.sharepoint-mil.us/personal/david_
 *   a_alt2_mil_health_mil/Documents/Documents/OneNote%20Notebooks/Development-
 *   Shared/CCL%20-%20Content.one) , [Phone](onenote:#Phone&section-
 *   id={3A32472C-2C84-4CDE-B609-CFCD47A33197}&page-
 *   id={6BA6FE3F-8669-4987-B8CE-E71A4BE12CA6}&end&base-path=https://militaryhealth-
 *   my.sharepoint-mil.us/personal/david_a_alt2_mil_health_mil/Documents/Documents/OneNote%2
 *   0Notebooks/Development-Shared/CCL%20-%20Content.one) ) for isolated queries.
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
personnel = p.name_full_formatted
,business_phone = bus_phone.phone_num_key "###-###-####"
,business_fax = bus_fax.phone_num_key "###-###-####"
,business_address1 = bus_addr.street_addr
,business_address2 = bus_addr.street_addr2
,bus_addr.city
,bus_addr.state
,bus_addr.zipcode
,p.email
FROM PRSNL p
,(LEFT JOIN (SELECT
person_id = parent_entity_id
,phone_num_key
,rn = ROW_NUMBER() OVER(PARTITION BY parent_entity_id ORDER BY
phone_type_seq)
FROM PHONE
WHERE 1=1
AND phone_type_cd = 163 ;business phone
AND active_ind = 1
AND end_effective_dt_tm > SYSDATE
WITH SQLTYPE("f8", "c20", "i2"))
bus_phone
ON p.person_id = bus_phone.person_id
AND bus_phone.rn = 1)
,(LEFT JOIN (SELECT
person_id = parent_entity_id
,phone_num_key
,rn = ROW_NUMBER() OVER(PARTITION BY parent_entity_id ORDER BY
phone_type_seq)
FROM PHONE
WHERE 1=1
AND phone_type_cd = 166 ;business fax
AND active_ind = 1
AND end_effective_dt_tm > SYSDATE
WITH SQLTYPE("f8", "c20", "i2")) bus_fax
ON p.person_id = bus_fax.person_id
AND bus_fax.rn =
1)
,(LEFT JOIN (SELECT
person_id = a.parent_entity_id
,a.street_addr
,a.street_addr2
,a.city
,state = cv.display
,a.zipcode
,rn = ROW_NUMBER() OVER(PARTITION BY a.parent_entity_id ORDER BY
a.address_type_seq)
FROM ADDRESS a, CODE_VALUE cv
WHERE 1=1
AND a.address_type_cd = 754 ;business
AND a.active_ind = 1
AND a.end_effective_dt_tm > SYSDATE
AND a.state_cd = cv.code_value
WITH SQLTYPE("f8", "c100", "c100",
"c100", "c4", "c20", "i2")) bus_addr
ON p.person_id = bus_addr.person_id
AND bus_addr.rn =
1)
PLAN p WHERE
p.person_id = <personnel person_id>
JOIN
bus_phone
JOIN bus_fax
JOIN bus_addr
WITH TIME=30
