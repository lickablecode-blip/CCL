/*
 * Source page  : Working with time zones
 * Source file  : output/working-with-time-zones.md
 * Anchor       : Best Practices - HealtheAnalytics
 * Block index  : 6 of 10
 * Detected lang: unknown
 * Lines        : 2
 *
 * Context (preceding paragraph):
 *   To include the time zone in the date/time format, add TZ:
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

TO_CHAR(e.some_dt_tm,
"YYYY-MM-DD HH:MI TZ") AS "time zone included"
