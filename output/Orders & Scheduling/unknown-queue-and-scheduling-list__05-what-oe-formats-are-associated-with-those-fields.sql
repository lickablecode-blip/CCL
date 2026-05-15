/*
 * Source page  : Unknown Queue and Scheduling List
 * Source file  : output/unknown-queue-and-scheduling-list.md
 * Anchor       : What OE formats are associated with those fields?
 * Block index  : 5 of 8
 * Detected lang: ccl
 * Lines        : 29
 *
 * Context (preceding paragraph):
 *   WITH TIME=30, UAR_CODE(D)
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
DISTINCT
fld.oe_field_id
,fld.description
,fld.codeset
,off.oe_format_id
,fmt.oe_format_name
FROM
ORDER_ENTRY_FIELDS fld
,OE_FORMAT_FIELDS off
,ORDER_ENTRY_FORMAT fmt
PLAN fld
WHERE fld.oe_field_id IN (
25786615 ;Scheduling Location
,37024091 ;Scheduling Locations - Non Radiology
,137811739 ;procedure scheduling location 20min
,137812971 ;procedure scheduling location 60min
,162596819 ;Card Procedure Scheduling Location
,162769267 ;Scheduling Location - Infusion
,352109491 ;VA Scheduling Location
,1007380489 ;DOD Clinic Follow Up Location
)
JOIN off
WHERE off.oe_field_id = fld.oe_field_id
JOIN fmt
WHERE fmt.oe_format_id = off.oe_format_id
ORDER BY
fld.description
WITH TIME=30
