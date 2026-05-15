/*
 * Source page  : Table indexes
 * Source file  : output/table-indexes.md
 * Anchor       : (top of page)
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 21
 *
 * Context (preceding paragraph):
 *   Indexes can also be queried from the metadata :
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
di.owner
 ,di.table_name
 ,di.index_name
 ,dic.column_name
 ,dic.column_position
 ,di.uniqueness
 ,di.status
 ,di.last_analyzed
 ,dic.descend
FROM
DBA_INDEXES di
,DBA_IND_COLUMNS dic
PLAN di WHERE
CNVTUPPER(di.table_name) = <table name>
JOIN dic
WHERE dic.table_name = di.table_name
AND dic.index_name = di.index_name
ORDER BY
di.table_name, di.index_name, dic.column_position
WITH TIME=30
