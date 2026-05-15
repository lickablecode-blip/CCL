/*
 * Source page  : DateDeceasedFormat
 * Source file  : output/datedeceasedformat.md
 * Anchor       : (top of page)
 * Block index  : 1 of 2
 * Detected lang: unknown
 * Lines        : 4
 *
 * Context (preceding paragraph):
 *   Example of an individual whose birth date is 12/16/1980. When there is no time
 *   associated with the date, it is assumed to be 00:00. Because the query was run in the
 *   EST time zone, five hours were subtracted in the conversion from UTC, shifting the
 *   birth date to the previous display. The output can be corrected by using the
 *   DateBirthFormat function:
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

formatted_birth_dt_tm
=
DateBirthFormat(p.birth_dt_tm, p.birth_tz, p.birth_prec_flag,
"@SHORTDATETIME")
