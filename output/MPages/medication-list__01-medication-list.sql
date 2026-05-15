/*
 * Source page  : Medication List
 * Source file  : output/medication-list.md
 * Anchor       : (top of page)
 * Block index  : 1 of 2
 * Detected lang: ccl
 * Lines        : 72
 *
 * Context (preceding paragraph):
 *   Got a lot closer to reproducing the PowerChart front-end. This does not include order
 *   proposals, since those come from a different table – would need to be combined either
 *   via union, or preferably, via a record structure. Interactions, formulary status, and
 *   dose adjustment columns were blank for this test patient, so didn’t pursue those. This
 *   query pulls MORE than the numbers listed by Steve, and haven’t tracked down those
 *   discrepancies yet. For example, if I pull in all the “inactive” statuses, I’ve got
 *   three rows for Vicodin that don’t show up in PowerChart – but there may be an intrinsic
 *   date/time filter in PowerChart that raw queries aren’t constrained by.
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
;interactions (blank)
;formulary status (blank)
order_name = BUILD(oc.description, " (",
o.ordered_as_mnemonic, ")")
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
,order_status = UAR_GET_CODE_DISPLAY(o.order_status_cd)
,dept_status = UAR_GET_CODE_DISPLAY(o.dept_status_cd)
,odisp.refills_remaining
,expiration_dt_tm = DATETIMEZONEFORMAT(odisp.expire_dt_tm,
odisp.expire_tz, "MM/DD/YYYY;;d")
;,dose_adjustment = ?
,details = o.clinical_display_line
,o.orig_order_dt_tm
,o.order_id
 FROM ORDERS o
         ,(LEFT JOIN
ORDER_DISPENSE odisp ON odisp.order_id = o.order_id
                 AND
odisp.dept_status_cd > 0)
         ,ORDER_CATALOG oc
         ;,ORDER_PROPOSAL op -
needs to be added via union/record structure due to different source
 PLAN o WHERE 1=1
         AND o.person_id =
9104036 ;test patient "CHDRZZZTEST, CHDRFOUR FRANK"
 AND o.active_ind = 1
 AND o.catalog_type_cd = 2516 ;pharmacy
 AND o.order_status_cd IN (
 ;Active Statuses
 2550.00        ;Ordered
 ,2548.00        ;InProcess
 ,2546.00        ;Future
 ,2547.00        ;Incomplete
 ,2552.00        ;Suspended
 ,2549.00        ;On Hold, Med
Student
 ;Inactive Statuses
; ,2545.00        ;Discontinued
; ,2542.00                ;Canceled
;                 ,2543.00        ;Completed
;                 ,643466.00        ;Pending
Complete
;                 ,2544.00        ;Voided
;                 ,643467.00        ;Voided With
Results
;                 ,614538.00        ;Transfer/Canceled
;Unlisted Statuses (on the front-end filter
 ,2553.00        ;Unscheduled
 ,2551.00        ;Pending Review
)
 JOIN oc WHERE oc.catalog_cd = o.catalog_cd
         AND oc.active_ind = 1
 JOIN odisp
ORDER BY o.orig_order_dt_tm DESC
WITH TIME=30,
UAR_CODE(D)
