/*
 * Source page  : Working with time zones
 * Source file  : output/working-with-time-zones.md
 * Anchor       : Best Practices - HealtheAnalytics
 * Block index  : 10 of 10
 * Detected lang: unknown
 * Lines        : 2
 *
 * Context (preceding paragraph):
 *   Deceased date works similarly:
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

TO_CHAR(p.deceased_dt_tm
AT TIMEZONE p.deceased_tz_name, 'YYYY-MM-DD') AS "Deceased Date"
