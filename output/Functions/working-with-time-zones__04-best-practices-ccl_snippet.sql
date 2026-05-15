/*
 * Source page  : Working with time zones
 * Source file  : output/working-with-time-zones.md
 * Anchor       : Best Practices - CCL
 * Block index  : 4 of 10
 * Detected lang: unknown
 * Lines        : 4
 *
 * Context (preceding paragraph):
 *   The DateDeceasedFormat function is similar, with slightly different field names:
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

formatted_deceased_dt_tm
=
DateDeceasedFormat(p.deceased_dt_tm, p.deceased_tz,
p.deceased_dt_tm_prec_flag, "@SHORTDATETIME")
