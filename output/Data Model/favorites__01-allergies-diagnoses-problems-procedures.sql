/*
 * Source page  : Favorites
 * Source file  : output/favorites.md
 * Anchor       : Allergies, Diagnoses, Problems, Procedures
 * Block index  : 1 of 3
 * Detected lang: ccl
 * Lines        : 16
 *
 * Context (preceding paragraph):
 *   For example, to see what diagnosis categories are defined and available at the global
 *   level:
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
nc.category_name
,category_type = UAR_GET_CODE_DISPLAY(nc.category_type_cd)
,nc.parent_entity_name
,nc.parent_entity_id
FROM
NOMEN_CATEGORY nc
PLAN nc WHERE
nc.category_type_cd = 639016 ;Diagnosis
AND nc.parent_entity_name = "GENERAL"
AND nc.parent_entity_id = 0
ORDER BY
category_type, nc.category_name
These
categories are maintained in the "Maintain Nomenclature Categories"
tool:
