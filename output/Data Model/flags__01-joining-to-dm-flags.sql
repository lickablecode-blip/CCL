/*
 * Source page  : Flags
 * Source file  : output/flags.md
 * Anchor       : Joining to DM_FLAGS
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 9
 *
 * Context (preceding paragraph):
 *   The DM_FLAGS table can be exported using the Discern report "Millennium Data Dictionary
 *   Builder".
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
template_flag = flag.description
FROM ORDERS o
,DM_FLAGS flag
PLAN o
JOIN flag
WHERE flag.flag_value = o.template_order_flag
AND flag.table_name = "ORDERS"
AND flag.column_name = "TEMPLATE_ORDER_FLAG"
