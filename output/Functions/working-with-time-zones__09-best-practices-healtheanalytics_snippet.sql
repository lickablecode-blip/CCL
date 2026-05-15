/*
 * Source page  : Working with time zones
 * Source file  : output/working-with-time-zones.md
 * Anchor       : Best Practices - HealtheAnalytics
 * Block index  : 9 of 10
 * Detected lang: unknown
 * Lines        : 2
 *
 * Context (preceding paragraph):
 *   Example of an individual whose birth date is 12/16/1980. Because the HealtheAnalytics
 *   Query Tool uses the Vertica server time (CST), six hours were subtracted in the
 *   conversion from UTC, shifting the birth date to the previous display. The output is
 *   corrected by using the AT TIMEZONE function:
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

TO_CHAR(p.birth_dt_tm
AT TIMEZONE p.birth_tz_name, 'YYYY-MM-DD') AS "DOB"
