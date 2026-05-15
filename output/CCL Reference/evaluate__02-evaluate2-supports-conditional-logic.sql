/*
 * Source page  : Evaluate
 * Source file  : output/evaluate.md
 * Anchor       : EVALUATE2 (supports conditional logic)
 * Block index  : 2 of 4
 * Detected lang: unknown
 * Lines        : 7
 *
 * Context (preceding paragraph):
 *   [https://wiki.cerner.com/display/1101discernHP/EVALUATE+2+Using+Discern+Explorer](https
 *   ://wiki.cerner.com/display/1101discernHP/EVALUATE+2+Using+Discern+Explorer)
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

test_methodology
= EVALUATE2(
IF(o.catalog_cd IN (370435813, 380764311)) "nucleic acid
amplification"
ELSEIF(o.catalog_cd IN (395371083, 396308175)) "immunoassay"
ELSE "UNKNOWN"
ENDIF)
