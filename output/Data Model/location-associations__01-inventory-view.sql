/*
 * Source page  : Location Associations
 * Source file  : output/location-associations.md
 * Anchor       : Inventory View
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 19
 *
 * Context (preceding paragraph):
 *   Remove location_type_cd filter for all location associations
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
personnel = p.name_full_formatted
,pr.beg_effective_dt_tm
,location = UAR_GET_CODE_DISPLAY(loc.location_cd)
,location_type = UAR_GET_CODE_DISPLAY(loc.location_type_cd)
FROM PRSNL p
,PRSNL_RELTN pr
,LOCATION loc
PLAN p WHERE p.person_id IN (50614270, 6356158, 18933872)
JOIN pr WHERE pr.person_id = p.person_id
AND pr.reltn_type_cd = 3539696 ;personnel location relation
AND pr.end_effective_dt_tm > SYSDATE
AND pr.active_ind = 1
JOIN loc WHERE loc.location_cd = pr.parent_entity_id
AND pr.parent_entity_name = "LOCATION"
AND loc.location_type_cd = 790 ;inventory view
ORDER BY p.name_full_formatted
WITH TIME=30,
UAR_CODE(D)
