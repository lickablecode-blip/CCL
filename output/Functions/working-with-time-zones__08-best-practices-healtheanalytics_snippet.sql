/*
 * Source page  : Working with time zones
 * Source file  : output/working-with-time-zones.md
 * Anchor       : Best Practices - HealtheAnalytics
 * Block index  : 8 of 10
 * Detected lang: unknown
 * Lines        : 3
 *
 * Context (preceding paragraph):
 *   Some tables will have time zone fields. Where these occur, they can be used to
 *   reconstitute the Facility Time. For example, the table FEDERAL_P0630.CLINICAL_EVENT has
 *   performed_dt_tm and performed_tz_name. You can use this to display performed_dt_tm in
 *   Facility Time like this:
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

TO_CHAR(ce.performed_dt_tm
AT TIMEZONE ce.performed_tz_name, 'YYYY-MM-DD HH:MI') AS "facility
dt_tm"
