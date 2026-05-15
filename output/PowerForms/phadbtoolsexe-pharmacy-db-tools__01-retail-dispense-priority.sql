/*
 * Source page  : phadbtools.exe - Pharmacy DB Tools
 * Source file  : output/phadbtoolsexe-pharmacy-db-tools.md
 * Anchor       : Retail --> Dispense Priority
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 82
 *
 * Context (preceding paragraph):
 *   Without service resource associations
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
dispense_priority = UAR_GET_CODE_DISPLAY(dp.disp_priority_cd)
,description = UAR_GET_CODE_DESCRIPTION(dp.disp_priority_cd)
,on_file = EVALUATE(dp.onfile_ind, 1, "yes", "no")
,on_hold = EVALUATE(dp.onhold_ind, 1, "yes", "no")
,dispense_sequence =
IF(dp.disp_seq_cd != 0) UAR_GET_CODE_DISPLAY(dp.disp_seq_cd)
ELSE "NONE"
ENDIF
,high_priority = EVALUATE(dp.high_priority_ind, 1, "yes",
"no")
,time_setting =
IF(dp.onfile_ind = 1 OR dp.onhold_ind = 1) "Disabled"
ELSEIF(dp.use_time_ind = 1) "Current Time"
ELSEIF(dp.use_time_ind = 0) "Fixed Time"
ENDIF
,allow_time_change = EVALUATE(dp.allow_time_chg_ind, 1,
"yes", "no")
,use_next_day = EVALUATE(dp.next_day_ind, 1, "yes",
"no")
,warn_user_of_date_change = EVALUATE(dp.warn_user_ind, 1,
"yes", "no")
,dp.fixed_time
,cv.active_ind
,last_updated = dp.updt_dt_tm
,last_updated_by = updt_p.name_full_formatted
,updater_position = UAR_GET_CODE_DISPLAY(updt_p.position_cd)
FROM
DISP_PRIORITY dp
,CODE_VALUE cv
,PRSNL updt_p
PLAN dp
JOIN cv WHERE
cv.code_value = dp.disp_priority_cd
AND cv.active_ind = 1 ;this excludes
inactive dispense priorities
JOIN updt_p
WHERE updt_p.person_id = dp.updt_id
ORDER BY
dispense_priority
WITH TIME=30
With service resource associations
SELECT
dispense_priority = UAR_GET_CODE_DISPLAY(dp.disp_priority_cd)
,description = UAR_GET_CODE_DESCRIPTION(dp.disp_priority_cd)
,on_file = EVALUATE(dp.onfile_ind, 1, "yes", "no")
,on_hold = EVALUATE(dp.onhold_ind, 1, "yes", "no")
,dispense_sequence =
IF(dp.disp_seq_cd != 0) UAR_GET_CODE_DISPLAY(dp.disp_seq_cd)
ELSE "NONE"
ENDIF
,high_priority = EVALUATE(dp.high_priority_ind, 1, "yes",
"no")
,time_setting =
IF(dp.onfile_ind = 1 OR dp.onhold_ind = 1) "Disabled"
ELSEIF(dp.use_time_ind = 1) "Current Time"
ELSEIF(dp.use_time_ind = 0) "Fixed Time"
ENDIF
,allow_time_change = EVALUATE(dp.allow_time_chg_ind, 1,
"yes", "no")
,use_next_day = EVALUATE(dp.next_day_ind, 1, "yes",
"no")
,warn_user_of_date_change = EVALUATE(dp.warn_user_ind, 1,
"yes", "no")
,default_fixed_time = dp.fixed_time
,service_resource = UAR_GET_CODE_DISPLAY(srr.serv_res_cd)
,sr_default_ind = srr.default_ind
,sr_fixed_time = srr.fixed_time
FROM
DISP_PRIORITY dp
,(LEFT JOIN DISP_PRIORITY_SR_R srr ON srr.disp_priority_cd =
dp.disp_priority_cd)
,CODE_VALUE cv
PLAN dp
JOIN cv WHERE
cv.code_value = dp.disp_priority_cd
AND cv.active_ind = 1 ;this excludes
inactive dispense priorities
JOIN srr
ORDER BY
dispense_priority, service_resource
WITH TIME=30
