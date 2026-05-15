/*
 * Source page  : Discern Developer
 * Source file  : output/discern-developer.md
 * Anchor       : (top of page)
 * Block index  : 1 of 4
 * Detected lang: ccl
 * Lines        : 29
 *
 * Context (preceding paragraph):
 *   (no preceding paragraph)
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
em.module_name
,title = em.maint_title
,filename = em.maint_filename ;max 25 characters
,duration_begin_dt_tm = em.maint_dur_begin_dt_tm
,duration_end_dt_tm = em.maint_dur_end_dt_tm
,em.updt_dt_tm
,em.release_dt_tm
,last_revision_dt_tm = em.last_rev_dt_tm
,validation = em.maint_validation
,em.version
,author = em.maint_author
,specialist = em.maint_specialist
,institution = em.maint_institution
,module_priority = em.know_priority
,optimization = EVALUATE(em.optimize_flag,
0, "Use default system-level setting",
1, "Optimize this module",
2, "Do not optimize this module",
"Unknown flag value")
,em.active_flag
FROM
EKS_MODULE em
PLAN em WHERE
em.module_name = "DALT_TEST_MODULE"
AND em.active_flag = "A"
ORDER BY
em.module_name, em.version
WITH TIME=30
