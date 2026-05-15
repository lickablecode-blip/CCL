/*
 * Source page  : Working with time zones
 * Source file  : output/working-with-time-zones.md
 * Anchor       : Best Practices - HealtheAnalytics
 * Block index  : 7 of 10
 * Detected lang: unknown
 * Lines        : 2
 *
 * Context (preceding paragraph):
 *   To include this field, add the following statement to your SELECT clause:
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

TO_CHAR(e.some_dt_tm,
'TZ') AS "times displayed as"
