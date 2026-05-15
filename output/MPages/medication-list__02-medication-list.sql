/*
 * Source page  : Medication List
 * Source file  : output/medication-list.md
 * Anchor       : (top of page)
 * Block index  : 2 of 2
 * Detected lang: ccl
 * Lines        : 32
 *
 * Context (preceding paragraph):
 *   Reproducing "Status"
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

,status =
IF(o.order_status_cd = 2550 AND o.orig_ord_as_flag IN (1, 2))
EVALUATE(o.orig_ord_as_flag,
         1,
"Prescribed",
         2,
"Documented",
         3,
"Deprecated",
         4, "Pharmacy Charge
Only",
         5, "Satellite
(Super Bill) Meds",
         "Other")
ELSE UAR_GET_CODE_DISPLAY(o.order_status_cd)
ENDIF
,order_status
= UAR_GET_CODE_DISPLAY(o.order_status_cd)
,dept_status
= UAR_GET_CODE_DISPLAY(o.dept_status_cd)
 ,flag = EVALUATE(o.orig_ord_as_flag,
         1,
"Prescribed",
         2,
"Documented",
         3,
"Deprecated",
         4, "Pharmacy Charge
Only",
         5, "Satellite
(Super Bill) Meds",
                 "Unmapped")
