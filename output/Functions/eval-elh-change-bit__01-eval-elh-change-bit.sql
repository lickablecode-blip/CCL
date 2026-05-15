/*
 * Source page  : eval_elh_change_bit
 * Source file  : output/eval-elh-change-bit.md
 * Anchor       : (top of page)
 * Block index  : 1 of 1
 * Detected lang: unknown
 * Lines        : 170
 *
 * Context (preceding paragraph):
 *   ; Alternative approach at: [https://community.cerner.com/t5/CCL-Discern-Explorer-
 *   Client-and-Cerner-Collaboration/Subroutine-to-evaluate-ENCNTR-LOC-HIST-change-
 *   bit/td-p/1629874](https://community.cerner.com/t5/CCL-Discern-Explorer-Client-and-
 *   Cerner-Collaboration/Subroutine-to-evaluate-ENCNTR-LOC-HIST-change-bit/td-p/1629874)
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

subroutine
(eval_elh_change_bit(change_bit=i4) = vc)
declare output = vc with protect
declare change_cnt = i2 with protect
declare trunc_len = i2 with protect
declare cb_accommodation_cd = i4
with protect,constant(1)
declare cb_accommodation_reason_cd = i4
with protect,constant(2)
declare cb_accommodation_request_cd = i4
with protect,constant(4)
declare cb_admit_type_cd = i4 with protect,constant(8)
declare cb_alt_lvl_care_cd = i4
with protect,constant(16)
declare cb_alc_decomp_dt_tm = i4
with protect,constant(32)
declare cb_alt_lvl_care_dt_tm = i4
with protect,constant(64)
declare cb_alc_reason_cd = i4
with protect,constant(128)
declare cb_arrive_dt_tm = i4 with protect,constant(256)
declare cb_depart_dt_tm = i4 with protect,constant(512)
declare cb_encntr_type_cd = i4
with protect,constant(1024)
declare cb_encntr_type_class_cd = i4
with protect,constant(2048)
declare cb_isolation_cd = i4
with protect,constant(4096)
declare cb_location_cd = i4 with protect,constant(8192)
declare cb_loc_facility_cd = i4
with protect,constant(16384)
declare cb_loc_building_cd = i4
with protect,constant(32768)
declare cb_loc_nurse_unit_cd = i4
with protect,constant(65536)
declare cb_loc_room_cd = i4
with protect,constant(131072)
declare cb_loc_bed_cd = i4
with protect,constant(262144)
declare cb_program_service_cd = i4
with protect,constant(524288)
declare cb_specialty_unit_cd = i4
with protect,constant(1048576)
declare cb_organization_id = i4
with protect,constant(2097152)
declare cb_med_service_cd = i4
with protect,constant(4194304)
declare cb_placement_auth_prsnl_id = i4
with protect,constant(8388608)
declare cb_security_access_cd = i4
with protect,constant(16777216)
declare cb_service_category_cd = i4
with protect,constant(33554432)
set output = ""
set change_cnt = 0
IF(BAND(change_bit, cb_accommodation_cd) = cb_accommodation_cd)
set output = CONCAT(output, "accommodation_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_accommodation_reason_cd) =
cb_accommodation_reason_cd)
set output = CONCAT(output, "accommodation_reason_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_accommodation_request_cd) =
cb_accommodation_request_cd)
set output = CONCAT(output, "accommodation_request_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_admit_type_cd) = cb_admit_type_cd)
set output = CONCAT(output, "admit_type_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_alt_lvl_care_cd) = cb_alt_lvl_care_cd)
set output = CONCAT(output, "alt_lvl_care_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_alc_decomp_dt_tm) = cb_alc_decomp_dt_tm)
set output = CONCAT(output, "alc_decomp_dt_tm,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_alt_lvl_care_dt_tm) = cb_alt_lvl_care_dt_tm)
set output = CONCAT(output, "alt_lvl_care_dt_tm,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_alc_reason_cd) = cb_alc_reason_cd)
set output = CONCAT(output, "alc_reason_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_arrive_dt_tm) = cb_arrive_dt_tm)
set output = CONCAT(output, "arrive_dt_tm,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_depart_dt_tm) = cb_depart_dt_tm)
set output = CONCAT(output, "depart_dt_tm,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_encntr_type_cd) = cb_encntr_type_cd)
set output = CONCAT(output, "encntr_type_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_encntr_type_class_cd) = cb_encntr_type_class_cd)
set output = CONCAT(output, "encntr_type_class_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_isolation_cd) = cb_isolation_cd)
set output = CONCAT(output, "isolation_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_location_cd) = cb_location_cd)
set output = CONCAT(output, "location_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_loc_facility_cd) = cb_loc_facility_cd)
set output = CONCAT(output, "loc_facility_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_loc_building_cd) = cb_loc_building_cd)
set output = CONCAT(output, "loc_building_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_loc_nurse_unit_cd) = cb_loc_nurse_unit_cd)
set output = CONCAT(output, "loc_nurse_unit_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_loc_room_cd) = cb_loc_room_cd)
set output = CONCAT(output, "loc_room_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_loc_bed_cd) = cb_loc_bed_cd)
set output = CONCAT(output, "loc_bed_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_program_service_cd) = cb_program_service_cd)
set output = CONCAT(output, "program_service_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_specialty_unit_cd) = cb_specialty_unit_cd)
set output = CONCAT(output, "specialty_unit_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_organization_id) = cb_organization_id)
set output = CONCAT(output, "organization_id,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_med_service_cd) = cb_med_service_cd)
set output = CONCAT(output, "med_service_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_placement_auth_prsnl_id) =
cb_placement_auth_prsnl_id)
set output = CONCAT(output, "placement_auth_prsnl_id,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_security_access_cd) = cb_security_access_cd)
set output = CONCAT(output, "security_access_cd,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(change_bit, cb_service_category_cd) = cb_service_category_cd)
set output = CONCAT(output, "service_category_cd,")
set change_cnt = change_cnt + 1
ENDIF
;if there is text with a trailing comma, remove the last comma
IF(change_cnt > 0)
set output = REPLACE(output, ",", ", ")
set trunc_len = TEXTLEN(output) - 1
set output = SUBSTRING(1,trunc_len,output)
ENDIF
return (output)
end
