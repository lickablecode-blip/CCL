/*
 * Source page  : Metadata
 * Source file  : output/metadata.md
 * Anchor       : Example of assembling a record with table and field (column) information
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 86
 *
 * Context (preceding paragraph):
 *   This is an excerpt from [Millennium Data Dictionary
 *   Builder](onenote:Exports.one#Millennium%20Data%20Dictionary%20Builder&section-
 *   id={13CA4C02-8242-4D22-BF25-1793BF4ADB54}&page-
 *   id={EC694D3B-088A-4017-8B5C-31E2C374B94E}&end&base-path=https://militaryhealth-
 *   my.sharepoint-mil.us/personal/david_a_alt2_mil_health_mil/Documents/Documents/OneNote%2
 *   0Notebooks/Development-Shared) .
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

IF($dict_type
IN ("Tables", "Fields (tables A-L)", "Fields (tables
M-Z)"))
SELECT INTO "nl:"
FROM DM_TABLES_DOC dtd
,ALL_TABLES a
,DM_COLUMNS_DOC dcd
,DBA_TAB_COLS dtc
PLAN dtd
WHERE dtd.drop_ind != 1
AND dtd.data_model_section IS NOT NULL
AND dtd.table_name != "*1*"
AND dtd.table_name != "*2*"
AND dtd.table_name != "*3*"
AND dtd.table_name != "*4*"
AND dtd.table_name != "*5*"
AND dtd.table_name != "*6*"
AND dtd.table_name != "*7*"
AND dtd.table_name != "*8*"
AND dtd.table_name != "*9*"
AND dtd.table_name != "*0*"
AND dtd.table_name != "*$*"
JOIN a WHERE dtd.table_name = a.table_name
JOIN dcd WHERE dtd.table_name = dcd.table_name
JOIN dtc WHERE dcd.table_name = dtc.table_name
AND dcd.column_name = dtc.column_name
ORDER BY dtd.table_name, dcd.column_name
HEAD REPORT
tab_idx = 0
CALL ALTERLIST(rec->tab,8000); allocate room for 8,000 tables
initially
HEAD dtd.table_name ; this should loop once per table
tab_idx = tab_idx + 1
col_idx = 0 ; reset the col index for each loop
; Check to see if we need more space for tables
CALL ALTERLIST(rec->tab, tab_idx+1)
;IF(MOD(tab_idx,10) = 1)
;        CALL
ALTERLIST(rec->tab, tab_idx + 10)
;ENDIF
; Allocate initial memory for table columns (50)
CALL ALTERLIST(rec->tab[tab_idx].col, 50)
; Store table information
rec->tab[tab_idx].table_name = dtd.table_name
rec->tab[tab_idx].table_desc = SUBSTRING(1,100,dtd.description)
rec->tab[tab_idx].table_def = SUBSTRING(1,300,dtd.definition)
rec->tab[tab_idx].model_sec = dtd.data_model_section
rec->tab[tab_idx].num_rows = a.num_rows
rec->tab[tab_idx].table_analyzed = a.last_analyzed
rec->tab[tab_idx].table_owner = dtd.owner
;HEAD dcd.column_name ; left for organizational clarity
DETAIL
col_idx += 1
; Check to see if we need more space for columns
CALL ALTERLIST(rec->tab[tab_idx].col, col_idx+1)
; Store column information
rec->tab[tab_idx].col[col_idx].col_name = dcd.column_name
 rec->tab[tab_idx].col[col_idx].col_desc =
SUBSTRING(1,100,replace_CRLF(dcd.description))
rec->tab[tab_idx].col[col_idx].col_def =
SUBSTRING(1,300,replace_CRLF(dcd.definition))
rec->tab[tab_idx].col[col_idx].primary_key_ind =
IF( TRIM(dcd.root_entity_name) = TRIM(dcd.table_name)
AND TRIM(dcd.root_entity_attr) =
TRIM(dcd.column_name)) "Y"
ELSE " "
ENDIF
rec->tab[tab_idx].col[col_idx].data_type = dtc.data_type
rec->tab[tab_idx].col[col_idx].data_length = dtc.data_length
rec->tab[tab_idx].col[col_idx].class_name = dcd.class_name
rec->tab[tab_idx].col[col_idx].join_to_tab = dcd.root_entity_name
rec->tab[tab_idx].col[col_idx].join_to_col = dcd.root_entity_attr
rec->tab[tab_idx].col[col_idx].code_set = dcd.code_set
rec->tab[tab_idx].col[col_idx].nullable = dtc.nullable
rec->tab[tab_idx].col[col_idx].data_default = dtc.data_default
rec->tab[tab_idx].col[col_idx].num_distinct = dtc.num_distinct
rec->tab[tab_idx].col[col_idx].num_nulls = dtc.num_nulls
rec->tab[tab_idx].col[col_idx].density = dtc.density
rec->tab[tab_idx].col[col_idx].col_seq = dtc.column_id
rec->tab[tab_idx].col[col_idx].col_analyzed = dtc.last_analyzed
FOOT dcd.column_name ; left for organizational clarity
CALL ALTERLIST(rec->tab[tab_idx].col, col_idx) ;deallocate any
unused column slots
FOOT dtd.table_name
CALL ALTERLIST(rec->tab, tab_idx) ;deallocate any unused table slots
ENDIF
