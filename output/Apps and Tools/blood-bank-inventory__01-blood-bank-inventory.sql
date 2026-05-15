/*
 * Source page  : Blood Bank Inventory
 * Source file  : output/blood-bank-inventory.md
 * Anchor       : (top of page)
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 391
 *
 * Context (preceding paragraph):
 *   Exported on 12/11/2025
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

/******************************************************************************
 REPORT NAME:
        Blood Bank Inventory
 PROGRAM:
 DEV
PROGRAM:        dev_rpt_bb_inventory.prg
 DEVELOPER:        David Alt
(david.a.alt2.mil@health.mil)
 PUBLISHED:
 SNAPSHOT:
 LOGICAL
PATH:        cust_script:
 NODE:                        <default>
 PURPOSE/DESCRIPTION:
 TARGET AUDIENCE: Blood Bank
MOD        DATE                DEVELOPER        COMMENT
         ---        --/--/--        ---------        ---------------------------
001        11/05/25        David
Alt        file created
         ---- unpublished ----
         TODO:
         Consider:
******************************************************************************/
drop program
dev_rpt_bb_inventory go
create
program dev_rpt_bb_inventory
prompt
"Output to File/Printer/MINE" = "MINE" ;* Enter or select the printer or file name
to send this report to.
, "Facility" = 0
, "Status" = VALUE( 1431.00)
, "Report" = ""
, "Include expired products" = "0"
with OUTDEV,
facility, event_type, rpt, expired_ind
/**************************************************************
; Global
Declarations
**************************************************************/
; indices for
LOCATEVAL
DECLARE NUM =
i4 WITH noconstant(0)
DECLARE POS =
i4 WITH noconstant(0)
/**************************************************************
; Record
Structures
**************************************************************/
free record
bld ;used for detail report
record bld (
1 list[*]
;product information
2 product_id = f8
2 product_event_id = f8
2 din = vc ;product.product_nbr
2 status = c40 ;product_event.event_type_cd
2 facility = c40
2 owner = c40
2 inventory_area = c40
2 product_cat = c40
2 product = c10
2 product_desc = c40
2 volume = c20
2 abo = c2
2 aborh = c20
2 donation_type = c40
2 supplier = c100 ;organization
2 event_dt_tm = dq8
2 event_dt_tm_local = c16
2 expire_dt_tm = dq8
2 expire_dt_tm_local = c16
2 shipping_condition = c40
2 storage_temp = c40
2 visual_inspection = c40
; modification indicators
;                2
pooled_component_ind = i2
;                2
pooled_product_ind = i2
;                2
modified_child_ind = i2
;                2
modified_parent_ind = i2
;                2
locked_ind = i2
;                2
corrected_ind = i2
;                2
prod_demo_scan_ind = i2
;                2
req_label_verify_ind = i2
; special tests and exceptions
2 special_tests = vc
2 container_nbr = i4 ;indicates 1st/2nd/3rd container etc.
2 leukoreduced_ind = i2 ;115845015
2 apheresis_ind =
i2        ;115920223
2 cmv_neg_ind =
i2                ;4510236
2 hgb_s_neg_ind =
i2        ;23382482
2 irradiated_ind =
i2        ;4510382
2 low_titer_o_ind =
i2        ;21370529499
2 frozen_ind =
i2                ;4510295
2 frozen_24hr_ind = i2 ;frozen <= 24 hr
2 other_test_ind = i2
2 tests[*]
3 test = c40
3 special_testing_id = f8
3 result_id = f8
) with
protect ;bld
free record
bld2 ;used for summary by expiration date
record bld2 (
1 list[*]
2 facility = c40
2 product_cat = c40
2 expire_dt_tm = c10
2 aneg_cnt = i4
2 apos_cnt = i4
2 bneg_cnt = i4
2 bpos_cnt = i4
2 abneg_cnt = i4
2 abpos_cnt = i4
2 oneg_cnt = i4
2 opos_cnt = i4
) with
protect ;bld2
/**************************************************************
; Subroutines
**************************************************************/
subroutine(build_bld(input=NULL)=NULL)
SELECT
IF($expired_ind = "1")
PLAN inv_area_loc WHERE inv_area_loc.organization_id = $facility
AND inv_area_loc.location_type_cd = 775 ;BB Inventory Area
AND inv_area_loc.active_ind = 1
JOIN p WHERE p.cur_inv_area_cd = inv_area_loc.location_cd
;AND p.cur_expire_dt_tm > SYSDATE
AND p.product_id != 0
AND p.active_ind = 1
JOIN pe WHERE pe.product_id = p.product_id
AND pe.event_type_cd = $event_type
AND pe.active_ind = 1
JOIN supplier WHERE supplier.organization_id = p.cur_supplier_id
JOIN inv_facility WHERE inv_facility.organization_id =
inv_area_loc.organization_id
AND inv_facility.location_type_cd = 783 ;facility
JOIN bp
JOIN st
ENDIF
INTO "NL:"
FROM LOCATION inv_area_loc
,PRODUCT p
,(LEFT JOIN BLOOD_PRODUCT bp ON bp.product_id = p.product_id
AND bp.active_ind = 1)
,(LEFT JOIN SPECIAL_TESTING st ON st.product_id = p.product_id
AND st.active_ind = 1)
,PRODUCT_EVENT pe
,ORGANIZATION supplier
,LOCATION inv_facility
PLAN inv_area_loc WHERE inv_area_loc.organization_id = $facility
AND inv_area_loc.location_type_cd = 775 ;BB Inventory Area
AND inv_area_loc.active_ind = 1
JOIN p WHERE p.cur_inv_area_cd = inv_area_loc.location_cd
AND p.cur_expire_dt_tm > SYSDATE
AND p.product_id != 0
AND p.active_ind = 1
JOIN pe WHERE pe.product_id = p.product_id
AND pe.event_type_cd = $event_type
AND pe.active_ind = 1
JOIN supplier WHERE supplier.organization_id = p.cur_supplier_id
JOIN inv_facility WHERE inv_facility.organization_id =
inv_area_loc.organization_id
AND inv_facility.location_type_cd = 783 ;facility
JOIN bp
JOIN st
ORDER BY p.product_id, st.special_testing_id
HEAD REPORT
i = 0
HEAD p.product_id
i += 1
j = 0
CALL ALTERLIST(bld->list, i)
bld->list[i].product_id = p.product_id
bld->list[i].product_event_id = pe.product_event_id
bld->list[i].din = p.product_nbr
bld->list[i].product_desc = UAR_GET_CODE_DISPLAY(p.product_cd)
bld->list[i].product = PIECE(bld->list[i].product_desc, "
", 1, "error")
bld->list[i].product_cat = UAR_GET_CODE_DISPLAY(p.product_cat_cd)
bld->list[i].status = UAR_GET_CODE_DISPLAY(pe.event_type_cd)
bld->list[i].aborh =
CONCAT(TRIM(UAR_GET_CODE_DISPLAY(bp.cur_abo_cd))
,"-",TRIM(UAR_GET_CODE_DISPLAY(bp.cur_rh_cd)))
bld->list[i].abo = UAR_GET_CODE_DISPLAY(bp.cur_abo_cd)
bld->list[i].facility =
UAR_GET_CODE_DISPLAY(inv_facility.location_cd)
bld->list[i].owner = UAR_GET_CODE_DISPLAY(p.cur_owner_area_cd)
bld->list[i].inventory_area =
UAR_GET_CODE_DISPLAY(p.cur_inv_area_cd)
bld->list[i].volume = BUILD(bp.cur_volume, CONCAT(" ",
UAR_GET_CODE_DISPLAY(p.cur_unit_meas_cd)))
bld->list[i].donation_type =
UAR_GET_CODE_DISPLAY(p.donation_type_cd)
bld->list[i].supplier = supplier.org_name
bld->list[i].event_dt_tm = pe.event_dt_tm
bld->list[i].event_dt_tm_local = DATETIMEZONEFORMAT(pe.event_dt_tm,
pe.event_tz, "MM/DD/YYYY HH:MM;;q")
bld->list[i].expire_dt_tm = p.cur_expire_dt_tm
bld->list[i].expire_dt_tm_local =
DATETIMEZONEFORMAT(p.cur_expire_dt_tm, pe.event_tz, "MM/DD/YYYY
HH:MM;;q")
bld->list[i].shipping_condition =
UAR_GET_CODE_DISPLAY(p.orig_ship_cond_cd)
bld->list[i].storage_temp = UAR_GET_CODE_DISPLAY(p.storage_temp_cd)
bld->list[i].visual_inspection =
UAR_GET_CODE_DISPLAY(p.orig_vis_insp_cd)
DETAIL ;st.special_testing_id
IF(st.special_testing_id != 0)
j += 1
CALL ALTERLIST(bld->list[i].tests, j)
bld->list[i].tests[j].special_testing_id = st.special_testing_id
bld->list[i].tests[j].test =
UAR_GET_CODE_DISPLAY(st.special_testing_cd)
bld->list[i].special_tests =
CONCAT(TRIM(UAR_GET_CODE_DISPLAY(st.special_testing_cd)),
", ", bld->list[i].special_tests)
;set indicators
IF(st.special_testing_cd = 115845015) bld->list[i].leukoreduced_ind
= 1
ELSEIF(st.special_testing_cd = 115920223) bld->list[i].apheresis_ind
= 1
ELSEIF(st.special_testing_cd = 4510236) bld->list[i].cmv_neg_ind = 1
ELSEIF(st.special_testing_cd = 23382482) bld->list[i].hgb_s_neg_ind
= 1
ELSEIF(st.special_testing_cd = 4510382) bld->list[i].irradiated_ind
= 1
ELSEIF(st.special_testing_cd = 21370529499)
bld->list[i].low_titer_o_ind = 1
ELSEIF(st.special_testing_cd = 4510295) bld->list[i].frozen_ind = 1
ELSEIF(st.special_testing_cd = 4510278) bld->list[i].frozen_24hr_ind
= 1
ELSE bld->list[i].other_test_ind = 1
ENDIF
;container number
IF(st.special_testing_cd = 4510292) bld->list[i].container_nbr = 1
ENDIF
IF(st.special_testing_cd = 4510290) bld->list[i].container_nbr = 2
ENDIF
IF(st.special_testing_cd = 4510288) bld->list[i].container_nbr = 3
ENDIF
IF(st.special_testing_cd = 4510286) bld->list[i].container_nbr = 4
ENDIF
ENDIF
FOOT p.product_id
IF(TEXTLEN(bld->list[i].special_tests)>2)
bld->list[i].special_tests =
SUBSTRING(1,TEXTLEN(bld->list[i].special_tests)-1,
bld->list[i].special_tests)
ENDIF
WITH NOCOUNTER
end
;build_bld
/**************************************************************
; Init
**************************************************************/
CALL
build_bld(NULL)
/**************************************************************
; Output
**************************************************************/
SELECT
IF($rpt =
"Summary (by ABO/Rh)")
facility = UAR_GET_CODE_DISPLAY(inv_facility.location_cd)
,inventory_area = UAR_GET_CODE_DISPLAY(p.cur_inv_area_cd)
,category = UAR_GET_CODE_DISPLAY(p.product_cat_cd)
,abo_rh = CONCAT(TRIM(UAR_GET_CODE_DISPLAY(bp.cur_abo_cd))
,"-",TRIM(UAR_GET_CODE_DISPLAY(bp.cur_rh_cd)))
,nbr_units = COUNT(*)
FROM LOCATION inv_area_loc
,PRODUCT p
,(LEFT JOIN BLOOD_PRODUCT bp ON bp.product_id = p.product_id
AND bp.active_ind = 1)
,PRODUCT_EVENT pe
,LOCATION inv_facility
PLAN inv_area_loc WHERE inv_area_loc.organization_id = $facility
AND inv_area_loc.location_type_cd = 775 ;BB Inventory Area
AND inv_area_loc.active_ind = 1
JOIN p WHERE p.cur_inv_area_cd = inv_area_loc.location_cd
AND p.cur_expire_dt_tm > SYSDATE
AND p.product_id != 0
AND p.active_ind = 1
JOIN pe WHERE pe.product_id = p.product_id
AND pe.event_type_cd = $event_type
AND pe.active_ind = 1
JOIN inv_facility WHERE inv_facility.organization_id =
inv_area_loc.organization_id
AND inv_facility.location_type_cd = 783 ;facility
JOIN bp
GROUP BY inv_facility.location_cd, p.cur_inv_area_cd, p.product_cat_cd,
bp.cur_abo_cd, bp.cur_rh_cd
ORDER BY facility, inventory_area, category
ELSEIF($rpt =
"Summary (by expiration date)")
facility = UAR_GET_CODE_DISPLAY(inv_facility.location_cd)
,inventory_area = UAR_GET_CODE_DISPLAY(p.cur_inv_area_cd)
,category = UAR_GET_CODE_DISPLAY(p.product_cat_cd)
,expire_date = DATETIMEZONEFORMAT(p.cur_expire_dt_tm, pe.event_tz,
"MM/DD/YYYY;;d")
,abo_rh = CONCAT(TRIM(UAR_GET_CODE_DISPLAY(bp.cur_abo_cd))
,"-",TRIM(UAR_GET_CODE_DISPLAY(bp.cur_rh_cd)))
,nbr_units = COUNT(*)
FROM LOCATION inv_area_loc
,PRODUCT p
,(LEFT JOIN BLOOD_PRODUCT bp ON bp.product_id = p.product_id
AND bp.active_ind = 1)
,PRODUCT_EVENT pe
,LOCATION inv_facility
PLAN inv_area_loc WHERE inv_area_loc.organization_id = $facility
AND inv_area_loc.location_type_cd = 775 ;BB Inventory Area
AND inv_area_loc.active_ind = 1
JOIN p WHERE p.cur_inv_area_cd = inv_area_loc.location_cd
AND p.cur_expire_dt_tm > SYSDATE
AND p.product_id != 0
AND p.active_ind = 1
JOIN pe WHERE pe.product_id = p.product_id
AND pe.event_type_cd = $event_type
AND pe.active_ind = 1
JOIN inv_facility WHERE inv_facility.organization_id =
inv_area_loc.organization_id
AND inv_facility.location_type_cd = 783 ;facility
JOIN bp
GROUP BY inv_facility.location_cd, p.cur_inv_area_cd, p.product_cat_cd
,p.cur_expire_dt_tm, bp.cur_abo_cd, bp.cur_rh_cd
ORDER BY facility, inventory_area, category, expire_date, abo_rh
ELSEIF($rpt =
"Detail")
facility = bld->list[d.seq].facility
,inventory_area = bld->list[d.seq].inventory_area
,category = bld->list[d.seq].product_cat
,product = bld->list[d.seq].product
,product_desc = bld->list[d.seq].product_desc
,product_nbr = bld->list[d.seq].din
,volume = bld->list[d.seq].volume
,abo_rh = bld->list[d.seq].aborh
,attributes = SUBSTRING(1,1000,bld->list[d.seq].special_tests)
,status = bld->list[d.seq].status
,status_dt_tm = bld->list[d.seq].event_dt_tm_local
,expire_dt_tm = bld->list[d.seq].expire_dt_tm_local
,supplier = bld->list[d.seq].supplier
,product_id = bld->list[d.seq].product_id
;        ,container_nbr
= bld->list[d.seq].container_nbr
;        ,leukoreduced_ind
= bld->list[d.seq].leukoreduced_ind
;        ,irradiated_ind
= bld->list[d.seq].irradiated_ind
;        ,apheresis_ind
= bld->list[d.seq].apheresis_ind
;        ,cmv_neg_ind
= bld->list[d.seq].cmv_neg_ind
;        ,hgb_s_neg_ind
= bld->list[d.seq].hgb_s_neg_ind
;        ,frozen_ind
= bld->list[d.seq].frozen_ind
;        ,frozen_24hr_ind
= bld->list[d.seq].frozen_24hr_ind
;        ,low_titer_o_ind
= bld->list[d.seq].low_titer_o_ind
;        ,other_test_ind
= bld->list[d.seq].other_test_ind
FROM (DUMMYT d with seq = value(size(bld->list, 5)))
PLAN d
ORDER BY facility, inventory_area, category, product, product_desc,
expire_dt_tm
ENDIF
INTO $OUTDEV
error = "Unknown error occurred."
WITH
NOCOUNTER, SEPARATOR=" ", FORMAT, TIME=60, EXPAND=2, CHECK
end
go
