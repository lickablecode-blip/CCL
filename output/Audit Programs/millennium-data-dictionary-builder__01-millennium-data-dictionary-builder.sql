/*
 * Source page  : Millennium Data Dictionary Builder
 * Source file  : output/millennium-data-dictionary-builder.md
 * Anchor       : (top of page)
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 812
 *
 * Context (preceding paragraph):
 *   Exported: 5/22/25
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

drop program
dev_rpt_mill_data_dict go
create
program dev_rpt_mill_data_dict
/******************************************************************************
 REPORT NAME:
        Millennium Data Dictionary
Builder
 PROGRAM:                1fed_rpt_mill_data_dict.prg
 DEV
PROGRAM:        dev_rpt_mill_data_dict.prg
 DEVELOPER:        David Alt
(david.a.alt2.mil@health.mil)
 PUBLISHED:        2021?
 SNAPSHOT:                04/10/25
 LOGICAL
PATH:        cust_script:
 NODE:                        <default>
 PURPOSE/DESCRIPTION:        Used
to build a data dictionary that is exportable
                                                 to
Excel. Additional information about custom tables
                                                 is
also available.
 TARGET AUDIENCE:
          Report developers
          Users involved in
system configuration
 DEPENDENCIES: none
MOD        DATE                DEVELOPER        COMMENT
---        --/--/--        ---------        ----------------------------
001        01/18/23        David
Alt        added bit mask options
002        03/29/23        David
Alt        added CDF meanings
removed search functionality (better in Code Set Audit)
003        02/18/25        David
Alt        added minimal output for
CUST_DOD_PRSNL_LOC_RELTN
004        02/20/25        David
Alt        removed redundant
"Facility Codes" output
005        04/10/25        David
Alt        added "Purged
Tables"
---- NOT PUBLISHED ----
006 09/03/25        David
Alt        added "Requests"
007        10/01/25        David
Alt        added model to field output
008        04/07/26        David
Alt        removed "WITH
NULLREPORT"
******************************************************************************/
prompt
"Output to File/Printer/MINE" = "MINE" ;* Enter or select the printer or file name
to send this report to.
, "" = ""
;<<hidden>>"" = ""
with OUTDEV,
dict_type
/**************************************************************
; Global
Declarations
**************************************************************/
declare
replace_CRLF(input = vc) = vc with protect
declare
error_msg = vc with noconstant("No Data")
declare
tab_idx = i4 with protect, noconstant(0)
declare
col_idx = i4 with protect, noconstant(0)
/**************************************************************
; Record
Structures
**************************************************************/
FREE RECORD
rec
RECORD rec
(
 1 tab [*]
 2 table_name = c40
 2 table_desc = c100
 2 table_def = c300
 2 model_sec = c40
 2 num_rows = i4
 2 table_analyzed = dq8
 2 table_owner = c20
 2 col [*]
         3 col_name = c40
         3 col_desc = c100
         3 col_def = c300
         3 primary_key_ind = c1
         3 data_type = c15
         3 data_length = i4
         3 class_name = c10
         3 join_to_tab = c40
         3 join_to_col = c40
         3 code_set = i4
         3 nullable = c10
         3 data_default = c40
         3 num_distinct = i4
         3 num_nulls = i4
         3 density = f8
         3 col_seq = i4
         3 col_analyzed = dq8
) with
protect ;end dictionary record
free record
cb ;change bits
record cb (
1 tlist[*]
2 table_name = c50
2 field_name = c50
2 blist[*]
3 bit = i4
3 int = f8
3 value = c100
) with
protect ;end cb record
/**************************************************************
; Subroutines
**************************************************************/
subroutine
replace_CRLF(input)
; HT = char(9) horizontal tab
; LF = char(10) line feed
; CR = char(13) carriage return
declare output = vc with protect, noconstant("")
declare CRLF = vc with protect, constant(concat(char(13), char(10)))
declare CR = vc with protect, constant(char(13))
declare LF = vc with protect, constant(char(10))
declare HT = vc with protect, constant(char(9))
declare REPLACEMENT = vc with constant(" ")
; remove carriage return+line feed at the beginning and end of the
string
; option 3 -> Trim leading and trailing spaces
set output = trim(input, 3)
; replace carriage return+line feed inside string
set output = replace(output, CRLF, REPLACEMENT)
set output = replace(output, CR, REPLACEMENT)
set output = replace(output, LF, REPLACEMENT)
set output = replace(output, HT, REPLACEMENT)
return (output)
end
/**************************************************************
; Main
**************************************************************/
;SELECT INTO
"nl:"
;HEAD REPORT
;subroutine(build_cb(input=NULL)=NULL)
;Although the record structure uses 1-based indexing,
;the bit mask itself uses 0-based indexing.
CALL ALTERLIST(cb->tlist, 3) ;3 tables
CALL ALTERLIST(cb->tlist[1].blist, 26) ;26 values for
ENCNTR_FLEX_HIST.change_bit
CALL ALTERLIST(cb->tlist[2].blist, 26) ;26 values for
ENCNTR_LOC_HIST.change_bit
CALL ALTERLIST(cb->tlist[3].blist, 32) ;32 values for
CLINICAL_EVENT.subtable_bit_map
;ENCNTR_FLEX_HIST
set cb->tlist[1].table_name = "ENCNTR_FLEX_HIST"
set cb->tlist[1].field_name = "CHANGE_BIT"
set cb->tlist[1].blist[1].bit = 0
set cb->tlist[1].blist[1].int = 1
set cb->tlist[1].blist[1].value = "accommodation_cd"
set cb->tlist[1].blist[2].bit = 1
set cb->tlist[1].blist[2].int = 2
set cb->tlist[1].blist[2].value =
"accommodation_reason_cd"
set cb->tlist[1].blist[3].bit = 2
set cb->tlist[1].blist[3].int = 4
set cb->tlist[1].blist[3].value =
"accommodation_request_cd"
set cb->tlist[1].blist[4].bit = 3
set cb->tlist[1].blist[4].int = 8
set cb->tlist[1].blist[4].value =
"admit_type_cd"
set cb->tlist[1].blist[5].bit = 4
set cb->tlist[1].blist[5].int = 16
set cb->tlist[1].blist[5].value = "alt_lvl_care_cd"
set cb->tlist[1].blist[6].bit = 5
set cb->tlist[1].blist[6].int = 32
set cb->tlist[1].blist[6].value = "alc_decomp_dt_tm"
set cb->tlist[1].blist[7].bit = 6
set cb->tlist[1].blist[7].int = 64
set cb->tlist[1].blist[7].value = "alt_lvl_care_dt_tm"
set cb->tlist[1].blist[8].bit = 7
set cb->tlist[1].blist[8].int = 128
set cb->tlist[1].blist[8].value = "alc_reason_cd"
set cb->tlist[1].blist[9].bit = 8
set cb->tlist[1].blist[9].int = 256
set cb->tlist[1].blist[9].value = "arrive_dt_tm"
set cb->tlist[1].blist[10].bit = 9
set cb->tlist[1].blist[10].int = 512
set cb->tlist[1].blist[10].value = "depart_dt_tm"
set cb->tlist[1].blist[11].bit = 10
set cb->tlist[1].blist[11].int = 1024
set cb->tlist[1].blist[11].value = "encntr_type_cd"
set cb->tlist[1].blist[12].bit = 11
set cb->tlist[1].blist[12].int = 2048
set cb->tlist[1].blist[12].value = "encntr_type_class_cd"
set cb->tlist[1].blist[13].bit = 12
set cb->tlist[1].blist[13].int = 4096
set cb->tlist[1].blist[13].value = "isolation_cd"
set cb->tlist[1].blist[14].bit = 13
set cb->tlist[1].blist[14].int = 8192
set cb->tlist[1].blist[14].value = "location_cd"
set cb->tlist[1].blist[15].bit = 14
set cb->tlist[1].blist[15].int = 16384
set cb->tlist[1].blist[15].value = "loc_facility_cd"
set cb->tlist[1].blist[16].bit = 15
set cb->tlist[1].blist[16].int = 32768
set cb->tlist[1].blist[16].value = "loc_building_cd"
set cb->tlist[1].blist[17].bit = 16
set cb->tlist[1].blist[17].int = 65536
set cb->tlist[1].blist[17].value = "loc_nurse_unit_cd"
set cb->tlist[1].blist[18].bit = 17
set cb->tlist[1].blist[18].int = 131072
set cb->tlist[1].blist[18].value = "loc_room_cd"
set cb->tlist[1].blist[19].bit = 18
set cb->tlist[1].blist[19].int = 262144
set cb->tlist[1].blist[19].value = "loc_bed_cd"
set cb->tlist[1].blist[20].bit = 19
set cb->tlist[1].blist[20].int = 524288
set cb->tlist[1].blist[20].value = "program_service_cd"
set cb->tlist[1].blist[21].bit = 20
set cb->tlist[1].blist[21].int = 1048576
set cb->tlist[1].blist[21].value = "specialty_unit_cd"
set cb->tlist[1].blist[22].bit = 21
set cb->tlist[1].blist[22].int = 2097152
set cb->tlist[1].blist[22].value = "organization_id"
set cb->tlist[1].blist[23].bit = 22
set cb->tlist[1].blist[23].int = 4194304
set cb->tlist[1].blist[23].value = "med_service_cd"
set cb->tlist[1].blist[24].bit = 23
set cb->tlist[1].blist[24].int = 8388608
set cb->tlist[1].blist[24].value =
"placement_auth_prsnl_id"
set cb->tlist[1].blist[25].bit = 24
set cb->tlist[1].blist[25].int = 16777216
set cb->tlist[1].blist[25].value = "security_access_cd"
set cb->tlist[1].blist[26].bit = 25
set cb->tlist[1].blist[26].int = 33554432
set cb->tlist[1].blist[26].value = "service_category_cd"
;ENCNTR_LOC_HIST
set cb->tlist[2].table_name = "ENCNTR_LOC_HIST"
set cb->tlist[2].field_name = "CHANGE_BIT"
set cb->tlist[2].blist[1].bit = 0
set cb->tlist[2].blist[1].int = 1
set cb->tlist[2].blist[1].value = "accommodation_cd"
set cb->tlist[2].blist[2].bit = 1
set cb->tlist[2].blist[2].int = 2
set cb->tlist[2].blist[2].value =
"accommodation_reason_cd"
set cb->tlist[2].blist[3].bit = 2
set cb->tlist[2].blist[3].int = 4
set cb->tlist[2].blist[3].value =
"accommodation_request_cd"
set cb->tlist[2].blist[4].bit = 3
set cb->tlist[2].blist[4].int = 8
set cb->tlist[2].blist[4].value =
"admit_type_cd"
set cb->tlist[2].blist[5].bit = 4
set cb->tlist[2].blist[5].int = 16
set cb->tlist[2].blist[5].value = "alt_lvl_care_cd"
set cb->tlist[2].blist[6].bit = 5
set cb->tlist[2].blist[6].int = 32
set cb->tlist[2].blist[6].value = "alc_decomp_dt_tm"
set cb->tlist[2].blist[7].bit = 6
set cb->tlist[2].blist[7].int = 64
set cb->tlist[2].blist[7].value = "alt_lvl_care_dt_tm"
set cb->tlist[2].blist[8].bit = 7
set cb->tlist[2].blist[8].int = 128
set cb->tlist[2].blist[8].value = "alc_reason_cd"
set cb->tlist[2].blist[9].bit = 8
set cb->tlist[2].blist[9].int = 256
set cb->tlist[2].blist[9].value = "arrive_dt_tm"
set cb->tlist[2].blist[10].bit = 9
set cb->tlist[2].blist[10].int = 512
set cb->tlist[2].blist[10].value = "depart_dt_tm"
set cb->tlist[2].blist[11].bit = 10
set cb->tlist[2].blist[11].int = 1024
set cb->tlist[2].blist[11].value = "encntr_type_cd"
set cb->tlist[2].blist[12].bit = 11
set cb->tlist[2].blist[12].int = 2048
set cb->tlist[2].blist[12].value = "encntr_type_class_cd"
set cb->tlist[2].blist[13].bit = 12
set cb->tlist[2].blist[13].int = 4096
set cb->tlist[2].blist[13].value = "isolation_cd"
set cb->tlist[2].blist[14].bit = 13
set cb->tlist[2].blist[14].int = 8192
set cb->tlist[2].blist[14].value = "location_cd"
set cb->tlist[2].blist[15].bit = 14
set cb->tlist[2].blist[15].int = 16384
set cb->tlist[2].blist[15].value = "loc_facility_cd"
set cb->tlist[2].blist[16].bit = 15
set cb->tlist[2].blist[16].int = 32768
set cb->tlist[2].blist[16].value = "loc_building_cd"
set cb->tlist[2].blist[17].bit = 16
set cb->tlist[2].blist[17].int = 65536
set cb->tlist[2].blist[17].value = "loc_nurse_unit_cd"
set cb->tlist[2].blist[18].bit = 17
set cb->tlist[2].blist[18].int = 131072
set cb->tlist[2].blist[18].value = "loc_room_cd"
set cb->tlist[2].blist[19].bit = 18
set cb->tlist[2].blist[19].int = 262144
set cb->tlist[2].blist[19].value = "loc_bed_cd"
set cb->tlist[2].blist[20].bit = 19
set cb->tlist[2].blist[20].int = 524288
set cb->tlist[2].blist[20].value = "program_service_cd"
set cb->tlist[2].blist[21].bit = 20
set cb->tlist[2].blist[21].int = 1048576
set cb->tlist[2].blist[21].value = "specialty_unit_cd"
set cb->tlist[2].blist[22].bit = 21
set cb->tlist[2].blist[22].int = 2097152
set cb->tlist[2].blist[22].value = "organization_id"
set cb->tlist[2].blist[23].bit = 22
set cb->tlist[2].blist[23].int = 4194304
set cb->tlist[2].blist[23].value = "med_service_cd"
set cb->tlist[2].blist[24].bit = 23
set cb->tlist[2].blist[24].int = 8388608
set cb->tlist[2].blist[24].value =
"placement_auth_prsnl_id"
set cb->tlist[2].blist[25].bit = 24
set cb->tlist[2].blist[25].int = 16777216
set cb->tlist[2].blist[25].value = "security_access_cd"
set cb->tlist[2].blist[26].bit = 25
set cb->tlist[2].blist[26].int = 33554432
set cb->tlist[2].blist[26].value = "service_category_cd"
;CLINICAL_EVENT
set cb->tlist[3].table_name = "CLINICAL_EVENT"
set cb->tlist[3].field_name = "SUBTABLE_BIT_MAP"
set cb->tlist[3].blist[1].bit = 0
set cb->tlist[3].blist[1].int = 1
set cb->tlist[3].blist[1].value = "CE_EVENT_PRSNL"
set cb->tlist[3].blist[2].bit = 1
set cb->tlist[3].blist[2].int = 2
set cb->tlist[3].blist[2].value = "CE_EVENT_NOTE"
set cb->tlist[3].blist[3].bit = 2
set cb->tlist[3].blist[3].int = 4
set cb->tlist[3].blist[3].value = "CE_MED_RESULT"
set cb->tlist[3].blist[4].bit = 3
set cb->tlist[3].blist[4].int = 8
set cb->tlist[3].blist[4].value = "CE_INTAKE_OUTPUT_RESULT vs
CE_IO_RESULT"
set cb->tlist[3].blist[5].bit = 4
set cb->tlist[3].blist[5].int = 16
set cb->tlist[3].blist[5].value = "CE_SPECIMEN_COLL"
set cb->tlist[3].blist[6].bit = 5
set cb->tlist[3].blist[6].int = 32
set cb->tlist[3].blist[6].value = "CE_IO_TOTAL_RESULT vs
CE_SPECIMEN_TRANS"
set cb->tlist[3].blist[7].bit = 6
set cb->tlist[3].blist[7].int = 64
set cb->tlist[3].blist[7].value = "CE_CONTRIBUTOR_LINK vs
CE_APPARATUS"
set cb->tlist[3].blist[8].bit = 7
set cb->tlist[3].blist[8].int = 128
set cb->tlist[3].blist[8].value = "CE_CALCULATION_RESULT vs
CE_ASSISTANT"
set cb->tlist[3].blist[9].bit = 8
set cb->tlist[3].blist[9].int = 256
set cb->tlist[3].blist[9].value = "CE_BLOB_RESULT"
set cb->tlist[3].blist[10].bit = 9
set cb->tlist[3].blist[10].int = 512
set cb->tlist[3].blist[10].value = "CE_BLOB"
set cb->tlist[3].blist[11].bit = 10
set cb->tlist[3].blist[11].int = 1024
set cb->tlist[3].blist[11].value = "CE_LINKED_RESULT"
set cb->tlist[3].blist[12].bit = 11
set cb->tlist[3].blist[12].int = 2048
set cb->tlist[3].blist[12].value = "CE_BLOB_SUMMARY"
set cb->tlist[3].blist[13].bit = 12
set cb->tlist[3].blist[13].int = 4096
set cb->tlist[3].blist[13].value = "CE_EVENT_MODIFIER"
set cb->tlist[3].blist[14].bit = 13
set cb->tlist[3].blist[14].int = 8192
set cb->tlist[3].blist[14].value = "CE_STRING_RESULT"
set cb->tlist[3].blist[15].bit = 14
set cb->tlist[3].blist[15].int = 16384
set cb->tlist[3].blist[15].value = "CE_INTERP_COMP"
set cb->tlist[3].blist[16].bit = 15
set cb->tlist[3].blist[16].int = 32768
set cb->tlist[3].blist[16].value = "CE_CODED_RESULT"
set cb->tlist[3].blist[17].bit = 16
set cb->tlist[3].blist[17].int = 65536
set cb->tlist[3].blist[17].value = "CE_MICROBIOLOGY"
set cb->tlist[3].blist[18].bit = 17
set cb->tlist[3].blist[18].int = 131072
set cb->tlist[3].blist[18].value = "CE_SUSCEPTIBILITY"
set cb->tlist[3].blist[19].bit = 18
set cb->tlist[3].blist[19].int = 262144
set cb->tlist[3].blist[19].value = "CE_MED_ADMIN_IDENTIFER vs
CE_BLOOD_TRANSFUSE"
set cb->tlist[3].blist[20].bit = 19
set cb->tlist[3].blist[20].int = 524288
set cb->tlist[3].blist[20].value = "CE_EVENT_ORDER_LINK vs
CE_EXAM_RESULT"
set cb->tlist[3].blist[21].bit = 20
set cb->tlist[3].blist[21].int = 1048576
set cb->tlist[3].blist[21].value = "CE_PRODUCT"
set cb->tlist[3].blist[22].bit = 21
set cb->tlist[3].blist[22].int = 2097152
set cb->tlist[3].blist[22].value = "CE_PRODUCT_ANTIGEN"
set cb->tlist[3].blist[23].bit = 22
set cb->tlist[3].blist[23].int = 4194304
set cb->tlist[3].blist[23].value = "CE_DATE_RESULT"
set cb->tlist[3].blist[24].bit = 23
set cb->tlist[3].blist[24].int = 8388608
set cb->tlist[3].blist[24].value = "CE_SUSCEP_FOOTNOTE_R"
set cb->tlist[3].blist[25].bit = 24
set cb->tlist[3].blist[25].int = 16777216
set cb->tlist[3].blist[25].value = "CE_SUSCEP_FOOTNOTE"
set cb->tlist[3].blist[26].bit = 25
set cb->tlist[3].blist[26].int = 33554432
set cb->tlist[3].blist[26].value = "CE_INVENTORY_RESULT"
set cb->tlist[3].blist[27].bit = 26
set cb->tlist[3].blist[27].int = 67108864
set cb->tlist[3].blist[27].value = "CE_IMPLANT_RESULT"
set cb->tlist[3].blist[28].bit = 27
set cb->tlist[3].blist[28].int = 134217728
set cb->tlist[3].blist[28].value = "CE_INV_TIME_RESULT"
set cb->tlist[3].blist[29].bit = 28
set cb->tlist[3].blist[29].int = 268435456
set cb->tlist[3].blist[29].value = "CE_PARENT_EVENT_NOTE"
set cb->tlist[3].blist[30].bit = 29
set cb->tlist[3].blist[30].int = 536870912
set cb->tlist[3].blist[30].value = "CE_EVENT_ACTION_MODIFIER vs
<blank>"
set cb->tlist[3].blist[31].bit = 30
set cb->tlist[3].blist[31].int = 1073741824
set cb->tlist[3].blist[31].value = "CE_RESULT_SET_LINK vs
<blank>"
set cb->tlist[3].blist[32].bit = 31
set cb->tlist[3].blist[32].int = 2147483648
set cb->tlist[3].blist[32].value =
"CE_DYNAMIC_LABEL"
;Retrieve
Table info - only if a table/column report is selected
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
/**************************************************************
; Output
**************************************************************/
SELECT
IF($dict_type
= "Tables")
table_name = rec->tab[dt.seq].table_name
,table_description = rec->tab[dt.seq].table_desc
,table_definition = rec->tab[dt.seq].table_def
,model_section = rec->tab[dt.seq].model_sec
,num_rows = rec->tab[dt.seq].num_rows
,table_analyzed = rec->tab[dt.seq].table_analyzed
"MM/DD/YYYY;;D"
,table_owner = rec->tab[dt.seq].table_owner
,run_date = SYSDATE "MM/DD/YYYY;;D"
FROM (DUMMYT dt WITH seq = size(rec->tab, 5))
ORDER BY table_name
ELSEIF($dict_type
= "Fields (tables A-L)")
model = rec->tab[dt.seq].model_sec
,table_name = rec->tab[dt.seq].table_name
,field_name = rec->tab[dt.seq].col[dc.seq].col_name
,field_description = rec->tab[dt.seq].col[dc.seq].col_desc
,field_definition = rec->tab[dt.seq].col[dc.seq].col_def
,primary_key_ind = rec->tab[dt.seq].col[dc.seq].primary_key_ind
,data_type = rec->tab[dt.seq].col[dc.seq].data_type
,length = rec->tab[dt.seq].col[dc.seq].data_length
,class_name = rec->tab[dt.seq].col[dc.seq].class_name
,join_to_table = rec->tab[dt.seq].col[dc.seq].join_to_tab
,join_to_field = rec->tab[dt.seq].col[dc.seq].join_to_col
,code_set = rec->tab[dt.seq].col[dc.seq].code_set
,nullable = rec->tab[dt.seq].col[dc.seq].nullable
,default_value = rec->tab[dt.seq].col[dc.seq].data_default
,num_distinct = rec->tab[dt.seq].col[dc.seq].num_distinct
,num_nulls = rec->tab[dt.seq].col[dc.seq].num_nulls
,density = rec->tab[dt.seq].col[dc.seq].density
,field_seq = rec->tab[dt.seq].col[dc.seq].col_seq
,field_analyzed = rec->tab[dt.seq].col[dc.seq].col_analyzed
"MM/DD/YYYY;;D"
,run_date = SYSDATE "MM/DD/YYYY;;D"
FROM (DUMMYT dt WITH seq = size(rec->tab, 5))
,(DUMMYT dc WITH seq = 1)
PLAN dt
WHERE MAXREC(dc,SIZE(rec->tab[dt.seq].col, 5))
AND SUBSTRING(1,1,rec->tab[dt.seq].table_name) IN ("A",
"B", "C", "D", "E", "F",
"G", "H", "I", "J", "K",
"L")
JOIN dc
ORDER BY table_name, field_name
ELSEIF($dict_type
= "Fields (tables M-Z)")
model = rec->tab[dt.seq].model_sec
,table_name = rec->tab[dt.seq].table_name
,field_name = rec->tab[dt.seq].col[dc.seq].col_name
,field_description = rec->tab[dt.seq].col[dc.seq].col_desc
,field_definition = rec->tab[dt.seq].col[dc.seq].col_def
,primary_key_ind = rec->tab[dt.seq].col[dc.seq].primary_key_ind
,data_type = rec->tab[dt.seq].col[dc.seq].data_type
,length = rec->tab[dt.seq].col[dc.seq].data_length
,class_name = rec->tab[dt.seq].col[dc.seq].class_name
,join_to_table = rec->tab[dt.seq].col[dc.seq].join_to_tab
,join_to_field = rec->tab[dt.seq].col[dc.seq].join_to_col
,code_set = rec->tab[dt.seq].col[dc.seq].code_set
,nullable = rec->tab[dt.seq].col[dc.seq].nullable
,default_value = rec->tab[dt.seq].col[dc.seq].data_default
,num_distinct = rec->tab[dt.seq].col[dc.seq].num_distinct
,num_nulls = rec->tab[dt.seq].col[dc.seq].num_nulls
,density = rec->tab[dt.seq].col[dc.seq].density
,field_seq = rec->tab[dt.seq].col[dc.seq].col_seq
,field_analyzed = rec->tab[dt.seq].col[dc.seq].col_analyzed
"MM/DD/YYYY;;D"
,run_date = SYSDATE "MM/DD/YYYY;;D"
FROM (DUMMYT dt WITH seq = size(rec->tab, 5))
,(DUMMYT dc WITH seq = 1)
PLAN dt
WHERE MAXREC(dc,SIZE(rec->tab[dt.seq].col, 5))
AND SUBSTRING(1,1,rec->tab[dt.seq].table_name) IN ("M",
"N", "O", "P", "Q", "R",
"S", "T", "U", "V", "W",
"X", "Y", "Z")
JOIN dc
ORDER BY table_name, field_name
ELSEIF($dict_type
= "Flags")
f.table_name
,f.column_name
,f.flag_value
,f.description
,f.definition
,run_date = SYSDATE "MM/DD/YYYY;;D"
FROM DM_FLAGS f
ORDER BY f.table_name, f.column_name, f.flag_value
ELSEIF($dict_type
= "Bit Masks")
table_name = cb->tlist[d.seq].table_name
,field_name = cb->tlist[d.seq].field_name
,bit = cb->tlist[d.seq].blist[d1.seq].bit
,int = CNVTSTRING(cb->tlist[d.seq].blist[d1.seq].int)
,value = cb->tlist[d.seq].blist[d1.seq].value
FROM (DUMMYT d WITH seq=VALUE(SIZE(cb->tlist, 5)))
,(DUMMYT d1 WITH seq=1)
PLAN d WHERE MAXREC(d1, size(cb->tlist[d.seq].blist, 5))
JOIN d1
ORDER BY table_name, field_name, bit
ELSEIF($dict_type
= "Code Sets")
CODE_SET = cs.code_set
,DISPLAY = SUBSTRING(1,40,replace_CRLF(cs.display))
,DESCRIPTION = SUBSTRING(1,120,replace_CRLF(cs.description))
,active_cnt.active_codes
,inactive_cnt.inactive_codes
,ACTIVE_CODE_SET = EVALUATE2(
IF(active_cnt.active_codes > 0) "yes"
ELSE "no"
ENDIF)
,run_date = SYSDATE "MM/DD/YYYY;;D"
FROM CODE_VALUE_SET cs
,(LEFT JOIN (SELECT cv.code_set, ACTIVE_CODES = COUNT(*)
FROM CODE_VALUE cv
WHERE cv.active_ind = 1
GROUP BY cv.code_set
WITH SQLTYPE("f8","i4")) active_cnt
ON cs.code_set = active_cnt.code_set)
,(LEFT JOIN (SELECT cv.code_set, INACTIVE_CODES = COUNT(*)
FROM CODE_VALUE cv
WHERE cv.active_ind = 0
GROUP BY cv.code_set
WITH SQLTYPE("f8","i4")) inactive_cnt
ON cs.code_set = inactive_cnt.code_set)
PLAN cs
JOIN active_cnt
JOIN inactive_cnt
ORDER BY cs.code_set, cs.display
ELSEIF($dict_type
= "CDF Meanings")
cdf.cdf_meaning
,cdf.display
,cdf.definition
,cdf.code_set
,code_set_name = cs.display
,in_use_ind = IF(in_use.in_use = 1) "yes" ELSE "no"
ENDIF
FROM COMMON_DATA_FOUNDATION cdf
,(LEFT JOIN (
SELECT DISTINCT cv.code_set, cv.cdf_meaning, in_use = 1
FROM CODE_VALUE cv
WHERE cv.active_ind = 1
ORDER BY cv.cdf_meaning, cv.code_set
WITH SQLTYPE("i4","vc12", "i2") )in_use
ON cdf.cdf_meaning = in_use.cdf_meaning
AND cdf.code_set = in_use.code_set)
,CODE_VALUE_SET cs
PLAN cdf
JOIN cs WHERE cdf.code_set = cs.code_set
JOIN in_use
ORDER BY cdf.cdf_meaning, cdf.code_set
ELSEIF($dict_type
= "Facility-Agency Reltn")
ag.agency
,facility_display = UAR_GET_CODE_DISPLAY(ag.location_cd)
,facility_description = UAR_GET_CODE_DESCRIPTION(ag.location_cd)
,ag.dmis_code
,dmis_path = dmis.alias
,ag.visn_code
,ag.division_code
,ag.location_cd
,ag.organization_id
,ag.validated_ind
,ag.updt_dt_tm "MM/DD/YYYY HH:MM;;q"
,run_date = SYSDATE "MM/DD/YYYY;;d"
FROM CUST_LOC_AGENCY_RELTN ag
,(LEFT JOIN CODE_VALUE_OUTBOUND dmis ON ag.location_cd =
dmis.code_value
AND dmis.code_set = 220
AND dmis.contributor_source_cd = 105099617 ;DHMSM
AND alias_type_meaning = "FACILITY")
PLAN ag
JOIN dmis
ORDER BY ag.agency,
facility_display
;Had to chop
out all the fields - too much data to return
ELSEIF($dict_type
= "Prsnl-Location Reltn")
p.name_full_formatted
,p.person_id
;,position = UAR_GET_CODE_DISPLAY(p.position_cd)
,position_at_scan = UAR_GET_CODE_DISPLAY(plr.ref_position_cd)
,assigned_facility = UAR_GET_CODE_DISPLAY(plr.assigned_fac_cd)
,assigned_nurse_unit = UAR_GET_CODE_DISPLAY(plr.assigned_loc_cd)
,predicted_facility = UAR_GET_CODE_DISPLAY(plr.predicted_fac_cd)
,predicted_nurse_unit = UAR_GET_CODE_DISPLAY(plr.predicted_loc_cd)
;,plr.method_used
;,plr.method_hits
;,plr.message
,plr.eval_beg_dt_tm
,plr.eval_end_dt_tm
,last_scan_dt_tm = plr.updt_dt_tm
;,plr.assigned_fac_cd
;,plr.assigned_loc_cd
;,plr.predicted_fac_cd
;,plr.predicted_loc_cd
FROM CUST_DOD_PRSNL_LOC_RELTN plr
,PRSNL p
PLAN plr
JOIN p WHERE p.person_id = plr.person_id
ORDER BY p.name_full_formatted
ELSEIF($dict_type
= "Purged Tables")
ptmp.template_nbr
,ptmp.feature_nbr
,dpj.job_id
,ptmp.name
,ptmp.program_str
,template_status =
IF(ptmp.active_ind = 1) "active"
ELSEIF(ptmp.active_ind = 2 OR ptmp.active_ind = NULL)
"inactive"
ELSE CONCAT(TRIM(CNVTSTRING(ptmp.active_ind)), "-undefined")
ENDIF
,job_status =
IF(dpj.active_flag = 1) "active"
ELSEIF(dpj.active_flag = 2 OR dpj.active_flag = NULL)
"inactive"
ELSEIF(dpj.active_flag = 3) "inactive (template changed)"
ELSE CONCAT(TRIM(CNVTSTRING(dpj.active_flag)), "-undefined")
ENDIF
,dpj.last_run_dt_tm "MM/DD/YYYY HH:MM;;q"
,last_run_status = EVALUATE(dpj.last_run_status_flag,
1, "success",
2, "failure",
"undefined")
,run_mode = EVALUATE(dpj.purge_flag,
1, "purge with job-level logging",
2, "purge with table-level logging",
3, "don't purge - audit only",
"undefined")
,dpj.max_rows
,dpt.purge_type_flag
,purge_type =
CONCAT(TRIM(CNVTSTRING(dpt.purge_type_flag)),"-",TRIM(df.description))
,dpt.parent_table
,dpt.child_table
FROM DM_PURGE_TEMPLATE ptmp
,(LEFT JOIN DM_PURGE_JOB dpj ON dpj.template_nbr = ptmp.template_nbr)
,DM_PURGE_TABLE dpt
,(LEFT JOIN DM_FLAGS df ON df.flag_value = dpt.purge_type_flag
AND df.table_name = "DM_PURGE_TABLE"
AND df.column_name = "PURGE_TYPE_FLAG")
PLAN ptmp WHERE ptmp.program_str != "XNT"
JOIN dpt WHERE dpt.template_nbr = ptmp.template_nbr
JOIN dpj
JOIN df
ORDER BY CNVTUPPER(ptmp.name), dpt.purge_type_flag, dpt.parent_table,
dpt.child_table
ELSEIF($dict_type
= "Requests")
r.request_number
,r.request_name
,r.description
,r.text
,r.active_dt_tm
,r.requestclass
,r.processclass
,r.prolog_script
,r.epilog_script
,r.binding_override
,r.cachegrace
,r.cachestale
,r.cachetime
,r.cachetrim
,r.write_to_que_ind
FROM REQUEST r
PLAN r WHERE r.active_ind = 1
ORDER BY r.request_number
ENDIF
INTO $OUTDEV
error =
"You must select a report"
WITH
NOCOUNTER, SEPARATOR=" ", FORMAT, CHECK, TIME=360
end
go
