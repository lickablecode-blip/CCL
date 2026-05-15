/*
 * Source page  : Facility Detail Audit
 * Source file  : output/facility-detail-audit.md
 * Anchor       : Measuring sub-report usage in Facility Detail Audit
 * Block index  : 2 of 2
 * Detected lang: ccl
 * Lines        : 17
 *
 * Context (preceding paragraph):
 *   Exported: 11/20/25
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

See: https://community.oracle.com/oraclehealth/discussion/1776948/using-piece-on-ccl-report-audit-object-parameters/p1?new=1
SELECT
DISTINCT
cra.object_name
,event_dt_tm = cra.updt_dt_tm "MM/DD/YYYY HH:MM;;q"
,cra.object_params
,sub_report = PIECE(SUBSTRING(
FINDSTRING(")", cra.object_params, 1, 0),
TEXTLEN(cra.object_params),
cra.object_params),
",", 3, "not found")
,cra.report_event_id
FROM CCL_REPORT_AUDIT cra
PLAN cra WHERE CNVTUPPER(cra.object_name) =
"*FACILITY_DETAIL_AUDIT*"
AND cra.updt_dt_tm > SYSDATE-60
WITH TIME=360
