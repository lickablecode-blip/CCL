/*
 * Source page  : CUST_LOC_AGENCY_RELTN
 * Source file  : output/cust-loc-agency-reltn.md
 * Anchor       : (top of page)
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 12
 *
 * Context (preceding paragraph):
 *   Note: this table is designed for syndicated data feeds and is dynamically populated;
 *   not every location that exists in the location build will be represented here or fully
 *   populated. Thus, a LEFT join might be more safer.
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
ag.agency
,facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
,encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
,e.reg_dt_tm
FROM
ENCOUNTER e
,CUST_LOC_AGENCY_RELTN ag
PLAN e WHERE
e.reg_dt_tm > SYSDATE - 10
JOIN ag WHERE
e.loc_facility_cd = ag.location_cd
