/*
 * Source page  : Evaluate
 * Source file  : output/evaluate.md
 * Anchor       : EVALUATE
 * Block index  : 1 of 4
 * Detected lang: unknown
 * Lines        : 8
 *
 * Context (preceding paragraph):
 *   Evaluate functions are useful when you want to convert values from a given field to
 *   something else. For example, if you have a flag field in your results and the values on
 *   DM_FLAG aren't very descriptive, you would use EVALUATE to provide your own
 *   descriptions to the flag values.
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

orig_ord_as_flag
= EVALUATE(o.orig_ord_as_flag,
1, "Prescribed",
2, "Documented",
3, "Deprecated",
4, "Pharmacy Charge Only",
5, "Satellite (Super Bill) Meds",
"Other")
