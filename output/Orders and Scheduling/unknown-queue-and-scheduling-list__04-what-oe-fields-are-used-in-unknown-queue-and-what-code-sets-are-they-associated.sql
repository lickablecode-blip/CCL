/*
 * Source page  : Unknown Queue and Scheduling List
 * Source file  : output/unknown-queue-and-scheduling-list.md
 * Anchor       : What OE fields are used in unknown queue, and what code sets are they associated with?
 * Block index  : 4 of 8
 * Detected lang: sql
 * Lines        : 28
 *
 * Context (preceding paragraph):
 *   WITH TIME=30, UAR_CODE(D)
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
oe_field_id
,description
,codeset
FROM
ORDER_ENTRY_FIELDS
WHERE
oe_field_id IN (
25786615                ;Scheduling
Location (CS 100301)
,37024091                ;Scheduling
Locations - Non Radiology (CS 100173)
,137811739                ;procedure
scheduling location 20min (CS 100820)
,137812971                ;procedure
scheduling location 60min (CS 100860)
,162596819                ;Card
Procedure Scheduling Location (CS 100990)
,162769267                ;Scheduling
Location - Infusion (CS 102124)
,352109491                ;VA
Scheduling Location (CS 100999)
,1007380489                ;DOD
Clinic Follow Up Location (CS 100414)
)
ORDER BY
description
WITH TIME=30
