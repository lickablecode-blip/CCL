/*
 * Source page  : Discern Developer
 * Source file  : output/discern-developer.md
 * Anchor       : (top of page)
 * Block index  : 2 of 4
 * Detected lang: ccl
 * Lines        : 34
 *
 * Context (preceding paragraph):
 *   {"storageItem":{"templateAliases":[{"id":"E1","alias":"","num":1,"type":"E","descriptio
 *   n":"","uuid":"bf4c60d1-710a-43ab-8d70-
 *   1dfba1d14049","dataElement":""},{"id":"L1","alias":"","num":2,"type":"L","description":
 *   "L1 Logic Description","uuid":"c2b3042b-ed18-4a74-8826-
 *   896b419a4d70","dataElement":"CKI.CODEVALUE!4129144967"},{"id":"A1","alias":"","num":3,"
 *   type":"A","description":"","uuid":"1c79b826-44a6-453b-a751-
 *   2a3287141978","dataElement":""}],"groupingAliases":[],"actionGroupAliases":[]}}
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
em.module_name
,em.version
,data_type = EVALUATE(ems.data_type,
1, "1 - Purpose",
2, "2 - Explanation",
3, "3 - Keywords",
4, "4 - Citations, Funding",
5, "5 - ???",
6, "6 - ???",
7, "7 - Evoke Section",
8, "8 - Logic Section",
9, "9 - Action Section",
10, "10 - Impact",
11, "11 - Query",
12, "12 - Evoke/Logic/Action Aliases",
13, "13 - Reconciliation Failures",
"Unknown flag value")
,ems.data_seq
,ems.ekm_info
FROM
EKS_MODULE em
,EKS_MODULESTORAGE ems
PLAN em WHERE
em.module_name = "DALT_TEST_MODULE"
AND em.active_flag = "A"
JOIN ems
WHERE ems.module_name = em.module_name
AND ems.version = em.version
ORDER BY
em.module_name, em.version, ems.data_type, ems.data_seq
WITH TIME=30
Here's an
example that shows reconciliation failures:
