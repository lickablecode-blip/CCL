/*
 * Source page  : Code Set Audit
 * Source file  : output/code-set-audit.md
 * Anchor       : (top of page)
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 2550
 *
 * Context (preceding paragraph):
 *   Exported: 4/15/26
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

drop program
dev_rpt_code_set_audit go
create
program dev_rpt_code_set_audit
/******************************************************************************
 REPORT NAME:
        Code Set Audit
 PROGRAM:                1fed_rpt_code_set_audit.prg
 DEV
PROGRAM:        dev_rpt_code_set_audit.prg
 DEVELOPER:        David Alt
(david.a.alt2.mil@health.mil)
 PUBLISHED:        6/30/2021
 SNAPSHOT:                4/15/2026
 LOGICAL
PATH:        cust_script
 NODE:                        <default>
 PURPOSE/DESCRIPTION:
         Provides tools for the
maintenance and exploration of code sets.
 GLOSSARY:
         CS = code set; a
collection of code values
         CV = code value; an
individual element within a code set
         CVG = code value
grouping; parent-child associations between code sets
         CSE = code set
extension; adds CS-specific fields beyond the CODE_VALUE table
         CVE = code value
extension; data populated in the CSE
         CVF = code value filter;
one mechanism for displaying partial code sets
         IA = inbound alias; maps
inbound data from external systems to CVs
         OA = outbound alias;
maps outbound data from CVs to external systems
         OEF = order entry
format; part of order configuration
 TARGET AUDIENCE:
          Users involved in code
set configuration (solution owners/experts)
          Report
developers/analysts looking for database
identifiers
 DEPENDENCIES: none
MOD        DATE                DEVELOPER        COMMENT
---        --/--/--        ---------        ----------------------------
 001 01/25/22 David
Alt        Added clinical event,
location, and order catalog searches
 002 04/11/22 David Alt Revised logic for change detail audit
 003 05/16/22 David
Alt        Added filtered change audit
 004 09/15/22 David
Alt        Added powerforms, med
identifier searches
 005 10/21/22 David Alt Added change summary, active-expired audits
 006 10/24/22 David Alt Added anesthesia actions search
 007 01/11/23 David
Alt        Renamed CVG report to Code
Value Group (P)
                                                                 Added
Code Value Group (C) report
                                                                 Added
header
                                                                 Republished
with CCL naming convention in cust_script: and <default> domain
 008 01/24/23 David Alt Fixed "Tables" report & moved to "reports"
 009 02/09/23 David
Alt        Added input type mapping to
PowerForms
 010 02/10/23 David
Alt        Added Audits->ESH orphans
                                                                 Replaced
Inbound/Outbound aliase with Code Value Aliases
                                                                 General
code clean-up
 011 02/15/23 David Alt Added Audits->PowerForm DTAs without event codes
                                                                 Added
Search->Location (facilities)
 012 02/27/23 David
Alt        Added Search->Schedulable
Resources (non-personnel)
                                                                 Updated
search prompt descriptions
 013 03/08/23 David
Alt        Added Search->Event Sets
                                                                 Added
Search->Resource Groups
         014        03/09/23        David
Alt        Added Search->Locations
(facilities by parent)
         015
03/14/23        David
Alt        Updated "Order
Formats" -> "Order Entry Formats"
         016        03/14/23        David
Alt        Added Search->Order
Catalog (by bill code)
         017        03/17/23        David
Alt        Rewrote logic for
Search->Order Catalog (by bill code)
         018
03/23/23        David
Alt        Added Search->Clinical
Events (by order)
                                                                 Added
Search->Nomenclature
         019        03/24/23        David
Alt        Added Search->Order Entry
Fields
         020
03/27/23        David
Alt        Added Reports->CDF
Meanings
         021        03/28/23        David
Alt        Removed two fields from
Search->Order Catalog, renamed code_value
         022        04/17/23        David
Alt        Fixed order truncation by
using ORDER_CATALOG instead of CODE_VALUE
         023
04/18/23        David
Alt        Added Search->PowerForms
                                                                 Renamed
Search->PowerForms (sections) to PowerForm Config - Sections
                                                                 Renamed
Search->PowerForms (forms) to PowerForm Config - Forms
         024        05/15/23        David
Alt        Set default report options
in the prompt
         025        07/18/23        David
Alt        Added last update personnel
to Reports->Code Values (Active)
                                                                 Added
has_children/has_parents to Reports->All Code Sets
                                                                 Added
has_children/has_parents to Reports->Code Set Summary
         026        07/19/23        David
Alt        Added Search->Order
Catalog (by OE format)
         027        07/24/23        David
Alt        Fixed bug in PRSNL join
leading to fewer than expected results
         028        07/31/23        David
Alt        Added text field to
Search->Applications
         029        10/06/23        David
Alt        Fixed join in
Search->Discrete Task Assay that prevented DTAs
                                                                         with
an event_cd of 0 from displaying in search results
         030        09/21/23        David
Alt        Added catalog_cd,
bill_item_id to Search->Order Catalog (by bill code)
         031        10/09/23        David
Alt        Removed Audit->PowerForm
DTAs without event codes (faulty premise)
                                                                 Added
Search->Code Values (active, by code value)
                                                                 Added
Search->Order Catalog (by synonym)
                                                                 Fixed
Clinical Events (by order): logic update (CVR)
Fixed Discrete Task Assays: logic update (CVR)
Fixed PowerForm Config - Forms: logic (CVR)/field updates
Fixed PowerForm Config - Sections: logic (CVR)/field updates
Moved "Search" to the middle tab option
032        10/10/23        David
Alt        Prompt
overhaul/modernization - added info control, manual layout
Added implicit wildcard to all searches
033        10/16/23        David
Alt        Added code set name/count
info to prompt
034        10/24/23        David
Alt        Added Search->Code Values
(active, by CDF meaning)
Added Search->Code Values (active, by CKI)
035        11/21/23        David
Alt        Added implict wildcards to
PowerForm search
036        12/01/23        David
Alt        Added result_type to DTA
search
037        12/22/23        David
Alt        Added Search->Clinical
Events (by event set)
038 01/02/24        David
Alt        Change
Search->Schedulable Resources to include all resource types
039        05/07/24        David
Alt        Added Reports->Code Set
Grouping
---- published but not in catalog ----
040        07/01/24        David
Alt        Added Search->Health
Plans
041        07/30/24        David
Alt        Mod Search->PowerForms -
removed erroneous folder, added unique vs display names
042        09/10/24        David
Alt        Added Search->Locations
(ERSA sites)
043        09/13/24        David
Alt        Mod Search->Schedulable
Resource - added resource_cd, person_id
044        10/01/24        David
Alt        Added Search->Scheduling
Request Lists
045        11/26/24        David
Alt        Added
Search->Recommendations (Health Maintenance Expectations, technically)
046        11/27/24        David
Alt        Added Search->PowerPlan
Added implicit leading wildcards to all searches
047        05/14/24        David
Alt        Added Search->Pathways
048        09/04/25        David
Alt        Added Search->Mpages
049        02/03/26        David
Alt        Added
Search->Organizations
050        03/26/26        David
Alt        Added Search->Insurance
Profiles
051        04/15/26        David
Alt        Added alternate query for
large code set dumps
---- unpublished ----
 TODO:
         Search->Mpages (by
viewpoint)
         investigate why PRAP
form doesn't show up in powerforms search for special duty status
         search->billing
entity
         search->medication
(returns drug identifier)
         search->organization
         search->practice site
         grouping summary: type (parent-child or child-parent), then
counts for each by code set
          goal: identify easily which code sets are
involved in each grouping type
          "Tell me what code sets are involved in
grouping" vs the current "Show me specific grouping
relationships"
         rewrite queries with
DTA-->event_cd mapping
         search->clinical
events (by DTA)
******************************************************************************/
prompt
"Output to File/Printer/MINE" = "MINE" ;* Enter or select the printer or file name
to send this report to.
, "Report Type:" = "reports"
, "Code Set:" = 0
;<<hidden>>"Name:" = ""
;<<hidden>>"Size:" = ""
, "Search:" = ""
, "Start Date:" = "SYSDATE"
, "End Date:" = "SYSDATE"
, "Select report:" = ""
, " " = ""
, "Select report:" = ""
, "Info" = ""
with OUTDEV,
tab, single_cs, search_term, start_date, end_date, report_list,
search_list, audit_list, info
/**************************************************************
; Global
Declarations
**************************************************************/
declare IDX =
i4 with noconstant(0) ;index for EXPAND
declare NUM =
i4 with noconstant(0) ;indices for LOCATEVAL
declare POS =
i4 with noconstant(0) ;indices for LOCATEVAL
declare
form_bit = i4 with protect,constant(1)
declare
section_bit = i4 with protect,constant(2)
declare
question_bit = i4 with protect,constant(4)
/**************************************************************
; Record
Structures
**************************************************************/
; used for
orphaned events
free record
ec
record ec (
1 list[*]
2 event_cd = f8
2 in_use_ind = i2
2 event_set_name_ind = i2
2 event_set_parent_ind = i2
2 orphan_ind = i2
) with
protect
; used for
powerform search
free record
pf
record pf (
1 list[*]
2 dcp_forms_ref_id = f8
2 powerform_display_name = c200
2 powerform_unique_name = c200
2 folder = c40
2 result_bit = i4
) with
protect
/**************************************************************
; Subroutines
**************************************************************/
; Removes all
line feeds/carriage returns/tabs from a string
subroutine
(replace_CRLF(input = vc) = vc)
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
; Builds the
EC audit record, but only if that report is selected
subroutine
(build_ec_record(NULL) = NULL)
SELECT INTO "NL:"
FROM V500_EVENT_CODE vec
,(LEFT JOIN (SELECT ve.event_cd
FROM V500_EVENT_CODE ve
WHERE EXISTS(SELECT 1 FROM CLINICAL_EVENT ce WHERE ve.event_cd =
ce.event_cd)
WITH SQLTYPE("f8") ) in_use ON vec.event_cd =
in_use.event_cd)
,(LEFT JOIN (SELECT DISTINCT vx.event_cd
FROM V500_EVENT_SET_EXPLODE vx
WITH SQLTYPE("f8") ) has_parent ON vec.event_cd =
has_parent.event_cd)
PLAN vec WHERE vec.event_cd > 0
JOIN in_use
JOIN has_parent
ORDER BY vec.event_cd
HEAD REPORT
i = 0
DETAIL
i += 1
CALL ALTERLIST(ec->list, i)
ec->list[i].event_cd = vec.event_cd
ec->list[i].in_use_ind = IF(in_use.event_cd > 0) 1 ELSE 0 ENDIF
ec->list[i].event_set_name_ind =
IF(TEXTLEN(TRIM(vec.event_set_name))>1)
1        ELSE 0 ENDIF
ec->list[i].event_set_parent_ind = IF(has_parent.event_cd > 0) 1
ELSE 0 ENDIF
ec->list[i].orphan_ind = IF(ec->list[i].event_set_name_ind = 0 OR
ec->list[i].event_set_parent_ind = 0) 1 ELSE 0 ENDIF
WITH NULLREPORT
end
; Evaluate
where the search results were found
subroutine
(eval_result_bit(result_bit=i4) = vc)
declare output = vc with protect
declare change_cnt = i2 with protect
declare trunc_len = i2 with protect
set output = ""
set change_cnt = 0
IF(BAND(result_bit, form_bit) = form_bit)
set output = CONCAT(output, "form,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(result_bit, section_bit) = section_bit)
set output = CONCAT(output, "section,")
set change_cnt = change_cnt + 1
ENDIF
IF(BAND(result_bit, question_bit) = question_bit)
set output = CONCAT(output, "question (DTA),")
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
; Builds the
PF (PowerForm) record, but only if that report is selected
subroutine
(build_pf_record(NULL) = NULL)
;check in forms
SELECT INTO "NL:"
FROM DCP_FORMS_REF f
PLAN f WHERE CNVTUPPER(f.definition) =
PATSTRING(CONCAT("*",$search_term,"*"))
AND CNVTUPPER(f.definition) != "ZZ*"
AND f.active_ind = 1
AND f.end_effective_dt_tm > SYSDATE
ORDER BY f.dcp_forms_ref_id
HEAD REPORT
i = 0
DETAIL
i += 1
CALL ALTERLIST(pf->list, i)
pf->list[i].dcp_forms_ref_id = f.dcp_forms_ref_id
pf->list[i].powerform_unique_name = f.definition
pf->list[i].powerform_display_name = f.description
pf->list[i].result_bit = form_bit
WITH NULLREPORT
;check in sections
SELECT INTO "NL:"
FROM DCP_SECTION_REF s
,DCP_FORMS_DEF fd
,DCP_FORMS_REF f
PLAN s WHERE CNVTUPPER(s.description) =
PATSTRING(CONCAT("*",$search_term,"*"))
AND CNVTUPPER(s.description) != "ZZ*"
AND s.active_ind = 1
AND s.end_effective_dt_tm > SYSDATE
JOIN fd WHERE s.dcp_section_ref_id = fd.dcp_section_ref_id
AND fd.active_ind = 1
JOIN f WHERE fd.dcp_form_instance_id = f.dcp_form_instance_id
AND CNVTUPPER(f.definition) != "ZZ*"
AND f.active_ind = 1
AND f.end_effective_dt_tm > SYSDATE
ORDER BY f.dcp_forms_ref_id
HEAD REPORT
i = size(pf->list, 5)
DETAIL
;check if already exists
pos = LOCATEVAL(num, 1, size(pf->list, 5),
f.dcp_forms_ref_id,
pf->list[num].dcp_forms_ref_id)
IF(pos > 0) ;already exists, flag it
IF(BAND(pf->list[pos].result_bit, section_bit) != section_bit)
pf->list[pos].result_bit += section_bit
ENDIF
ELSE ;needs to be added to the record
i += 1
CALL ALTERLIST(pf->list, i)
pf->list[i].dcp_forms_ref_id = f.dcp_forms_ref_id
pf->list[i].powerform_unique_name = f.definition
pf->list[i].powerform_display_name = f.description
pf->list[i].result_bit = section_bit
ENDIF
WITH NULLREPORT
;check in DTAs
SELECT INTO "NL:"
FROM DISCRETE_TASK_ASSAY dta
,NAME_VALUE_PREFS nvp
,DCP_INPUT_REF i
,DCP_SECTION_REF s
,DCP_FORMS_DEF fd
,DCP_FORMS_REF f
PLAN dta WHERE 1=1
AND CNVTUPPER(dta.mnemonic) =
PATSTRING(CONCAT("*",$search_term,"*"))
AND dta.mnemonic_key_cap != "ZZ*"
AND dta.active_ind = 1
AND dta.end_effective_dt_tm > SYSDATE
JOIN nvp WHERE dta.task_assay_cd = nvp.merge_id
AND nvp.merge_name = "DISCRETE_TASK_ASSAY"
JOIN i WHERE nvp.parent_entity_name = "DCP_INPUT_REF"
AND nvp.parent_entity_id = i.dcp_input_ref_id
AND i.active_ind = 1
JOIN s WHERE i.dcp_section_instance_id = s.dcp_section_instance_id
AND s.dcp_section_ref_id = i.dcp_section_ref_id
AND CNVTUPPER(s.description) != "ZZ*"
AND s.active_ind = 1
AND s.end_effective_dt_tm > SYSDATE
JOIN fd WHERE s.dcp_section_ref_id = fd.dcp_section_ref_id
AND fd.active_ind = 1
JOIN f WHERE fd.dcp_form_instance_id = f.dcp_form_instance_id
AND CNVTUPPER(f.definition) != "ZZ*"
AND f.active_ind = 1
AND f.end_effective_dt_tm > SYSDATE
ORDER BY f.dcp_forms_ref_id
HEAD REPORT
i = size(pf->list, 5); - 1
DETAIL
;check if already exists
pos = LOCATEVAL(num, 1, size(pf->list, 5),
f.dcp_forms_ref_id,
pf->list[num].dcp_forms_ref_id)
IF(pos > 0) ;already exists, flag it
IF(BAND(pf->list[pos].result_bit, question_bit) != question_bit)
pf->list[pos].result_bit += question_bit
ENDIF
ELSE ;needs to be added to the record
i += 1
CALL ALTERLIST(pf->list, i)
pf->list[i].dcp_forms_ref_id = f.dcp_forms_ref_id
pf->list[i].powerform_unique_name = f.definition
pf->list[i].powerform_display_name = f.description
pf->list[i].result_bit = question_bit
ENDIF
WITH NULLREPORT
;Finally, populate the folder names
;DA - these aren't the folders, they're task types
/*
SELECT INTO "NL:"
FROM ORDER_TASK t
PLAN t WHERE EXPAND(idx, 1, size(pf->list, 5),
t.dcp_forms_ref_id,
pf->list[idx].dcp_forms_ref_id)
AND t.active_ind = 1
DETAIL
pos = LOCATEVAL(num, 1, size(pf->list, 5),
t.dcp_forms_ref_id,
pf->list[num].dcp_forms_ref_id)
IF(pos > 0)
pf->list[pos].folder = UAR_GET_CODE_DISPLAY(t.task_type_cd)
ENDIF
WITH NULLREPORT
*/
end
/**************************************************************
; Main
**************************************************************/
IF($tab =
"audits" AND $audit_list = "ESH orphans") CALL
build_ec_record(NULL)
ELSEIF($tab =
"search" AND $search_list = "PowerForms*") CALL
build_pf_record(NULL)
ENDIF
/**************************************************************
; Output
**************************************************************/
SELECT
IF($tab =
"reports" AND $report_list = "All Code Sets")
cs.code_set
,cs.display
,cs.description
,active_code_set = EVALUATE2(
IF(active_cnt.active_codes > 0) "yes"
ELSE "no"
ENDIF)
,active_cnt.active_codes
,inactive_cnt.inactive_codes
,inbound_aliasing = IF(inbound.inbound_aliases > 0) "yes"
ELSE "no" ENDIF
,outbound_aliasing = IF(outbound.outbound_aliases > 0)
"yes" ELSE "no" ENDIF
,grouping = IF(groupings.groupings > 0) "yes" ELSE
"no" ENDIF
,has_parents = IF(parents.groupings > 0) "yes" ELSE
"no" ENDIF
,has_children = IF(children.groupings > 0) "yes" ELSE
"no"
ENDIF
,extensions = IF(cs.extension_ind > 0) "yes" ELSE
"no" ENDIF
,filtering = IF(filters.filters > 0) "yes" ELSE
"no" ENDIF
FROM CODE_VALUE_SET cs
,(LEFT JOIN (SELECT cv.code_set, active_codes = COUNT(*)
FROM CODE_VALUE cv
WHERE cv.active_ind = 1
GROUP BY cv.code_set
WITH SQLTYPE("f8","i4")) active_cnt
ON cs.code_set = active_cnt.code_set)
,(LEFT JOIN (SELECT cv.code_set, inactive_codes = COUNT(*)
FROM CODE_VALUE cv
WHERE cv.active_ind = 0
GROUP BY cv.code_set
WITH SQLTYPE("f8","i4")) inactive_cnt
ON cs.code_set = inactive_cnt.code_set)
,(LEFT JOIN (SELECT cvi.code_set, inbound_aliases = COUNT(*)
FROM CODE_VALUE_ALIAS cvi
GROUP BY cvi.code_set
WITH SQLTYPE("f8","i4")) inbound
ON cs.code_set = inbound.code_set)
,(LEFT JOIN (SELECT cvo.code_set, outbound_aliases = COUNT(*)
FROM CODE_VALUE_OUTBOUND cvo
GROUP BY cvo.code_set
WITH SQLTYPE("f8","i4")) outbound
ON cs.code_set = outbound.code_set)
,(LEFT JOIN (SELECT cvg.code_set, groupings = COUNT(*)
FROM CODE_VALUE_GROUP cvg
GROUP BY cvg.code_set
WITH SQLTYPE("f8","i4")) groupings
ON cs.code_set = groupings.code_set)
,(LEFT JOIN (SELECT child.code_set, groupings = COUNT(*)
FROM CODE_VALUE child
,CODE_VALUE_GROUP parent
WHERE child.active_ind = 1
AND child.code_value = parent.child_code_value
GROUP BY child.code_set
WITH SQLTYPE("f8","i4")) parents
ON cs.code_set = parents.code_set)
,(LEFT JOIN (SELECT parent.code_set, groupings = COUNT(*)
FROM CODE_VALUE parent
,CODE_VALUE_GROUP child
WHERE parent.active_ind = 1
AND parent.code_value = child.parent_code_value
GROUP BY parent.code_set
WITH SQLTYPE("f8","i4")) children
ON cs.code_set =
children.code_set)
,(LEFT JOIN (SELECT cvf.code_set, filters = COUNT(*)
FROM CODE_VALUE_FILTER cvf
GROUP BY cvf.code_set
WITH SQLTYPE("f8","i4")) filters
ON cs.code_set = filters.code_set)
PLAN cs
JOIN active_cnt
JOIN inactive_cnt
JOIN inbound
JOIN outbound
JOIN groupings
JOIN parents
JOIN children
JOIN
filters
ORDER BY cs.code_set, cs.display
ELSEIF($tab =
"reports" AND $report_list = "Code Set Summary")
cs.code_set
,cs.display
,cs.description
,active_code_set = EVALUATE2(
IF(active_cnt.active_codes > 0) "yes"
ELSE "no"
ENDIF)
,active_cnt.active_codes
,inactive_cnt.inactive_codes
,inbound_aliasing = IF(inbound.inbound_aliases > 0) "yes"
ELSE "no" ENDIF
,outbound_aliasing = IF(outbound.outbound_aliases > 0)
"yes" ELSE "no" ENDIF
,grouping = IF(groupings.groupings > 0) "yes" ELSE
"no" ENDIF
,has_parents = IF(parents.groupings > 0) "yes" ELSE
"no" ENDIF
,has_children = IF(children.groupings > 0) "yes" ELSE
"no" ENDIF
,extensions = IF(cs.extension_ind > 0) "yes" ELSE
"no" ENDIF
,filtering = IF(filters.filters > 0) "yes" ELSE
"no" ENDIF
FROM CODE_VALUE_SET cs
,(LEFT JOIN (SELECT cv.code_set, active_codes = COUNT(*)
FROM CODE_VALUE cv
WHERE cv.active_ind = 1
GROUP BY cv.code_set
WITH SQLTYPE("f8","i4")) active_cnt
ON cs.code_set = active_cnt.code_set)
,(LEFT JOIN (SELECT cv.code_set, inactive_codes = COUNT(*)
FROM CODE_VALUE cv
WHERE cv.active_ind = 0
GROUP BY cv.code_set
WITH SQLTYPE("f8","i4")) inactive_cnt
ON cs.code_set = inactive_cnt.code_set)
,(LEFT JOIN (SELECT cvi.code_set, inbound_aliases = COUNT(*)
FROM CODE_VALUE_ALIAS cvi
GROUP BY cvi.code_set
WITH SQLTYPE("f8","i4")) inbound
ON cs.code_set = inbound.code_set)
,(LEFT JOIN (SELECT cvo.code_set, outbound_aliases = COUNT(*)
FROM CODE_VALUE_OUTBOUND cvo
GROUP BY cvo.code_set
WITH SQLTYPE("f8","i4")) outbound
ON cs.code_set = outbound.code_set)
,(LEFT JOIN (SELECT cvg.code_set, groupings = COUNT(*)
FROM CODE_VALUE_GROUP cvg
GROUP BY cvg.code_set
WITH SQLTYPE("f8","i4")) groupings
ON cs.code_set = groupings.code_set)
,(LEFT JOIN (SELECT child.code_set, groupings = COUNT(*)
FROM CODE_VALUE child
,CODE_VALUE_GROUP parent
WHERE child.active_ind = 1
AND child.code_value = parent.child_code_value
GROUP BY child.code_set
WITH SQLTYPE("f8","i4")) parents
ON cs.code_set = parents.code_set)
,(LEFT JOIN (SELECT parent.code_set, groupings = COUNT(*)
FROM CODE_VALUE parent
,CODE_VALUE_GROUP child
WHERE parent.active_ind = 1
AND parent.code_value = child.parent_code_value
GROUP BY parent.code_set
WITH SQLTYPE("f8","i4")) children
ON cs.code_set =
children.code_set)
,(LEFT JOIN (SELECT cvf.code_set, filters = COUNT(*)
FROM CODE_VALUE_FILTER cvf
GROUP BY cvf.code_set
WITH SQLTYPE("f8","i4")) filters
ON cs.code_set = filters.code_set)
PLAN cs WHERE cs.code_set = $single_cs
JOIN active_cnt
JOIN inactive_cnt
JOIN inbound
JOIN outbound
JOIN groupings
JOIN parents
JOIN children
JOIN
filters
ORDER BY cs.code_set, cs.display
ELSEIF($tab =
"reports" AND $report_list = "Code Set Extensions")
cse.code_set
,cse.field_name
,cse.field_seq
,cse.field_type
,cse.field_len
,cse.field_help
,cse.field_default
,cse.field_prompt
,cse.field_in_mask
,cse.field_out_mask
,cse.validation_condition
,cse.validation_code_set
FROM CODE_SET_EXTENSION cse
PLAN cse WHERE cse.code_set = $single_cs
ORDER BY cse.code_set, cse.field_seq
ELSEIF($tab =
"reports" AND $report_list = "Code Set Grouping")
cv.code_set
,grouping_type = "parent"
,grouped_set = parent.code_set
,grouped_set_name = cs.display
,nbr_groupings = COUNT(*)
FROM CODE_VALUE cv
,CODE_VALUE_GROUP cvg
,CODE_VALUE parent
,CODE_VALUE_SET cs
PLAN cv WHERE cv.code_set = $single_cs
AND cv.active_ind = 1
AND cv.end_effective_dt_tm > SYSDATE
JOIN cvg WHERE cv.code_set = cvg.code_set AND cv.code_value =
cvg.child_code_value
JOIN parent WHERE cvg.parent_code_value = parent.code_value
JOIN cs WHERE parent.code_set = cs.code_set
GROUP BY cv.code_set, parent.code_set, cs.display
UNION(
SELECT
cv.code_set
,grouping_type = "child"
,grouped_set = child.code_set
,grouped_set_name = cs.display
,nbr_groupings = COUNT(*)
FROM CODE_VALUE cv
,CODE_VALUE_GROUP cvg
,CODE_VALUE child
,CODE_VALUE_SET cs
WHERE cv.code_set = $single_cs
AND cv.active_ind = 1
AND cv.end_effective_dt_tm > SYSDATE
AND cvg.parent_code_value = cv.code_value
AND child.code_value = cvg.child_code_value
AND cs.code_set = child.code_set
GROUP BY cv.code_set, child.code_set, cs.display
)
WITH TIME=360, RDBUNION, FORMAT, SEPARATOR=" "
; CS 72, 93,
200, 220, 14003 are too large to display with all the usual columns
ELSEIF($tab =
"reports" AND $report_list = "Code Values (active)"
AND $single_cs IN (72, 93, 200, 220, 14003))
         cv.code_set
,code_set_name = SUBSTRING(1,40,replace_CRLF(cs.display))
,cv.code_value
,display = SUBSTRING(1,40,replace_CRLF(cv.display))
,cv.cdf_meaning
,description = SUBSTRING(1,60,replace_CRLF(cv.description))
;,definition = SUBSTRING(1,100,replace_CRLF(cv.definition))
,cv.cki
;,cv.updt_dt_tm "MM/DD/YYYY;;D"
FROM CODE_VALUE cv
,CODE_VALUE_SET cs
PLAN cv        WHERE
cv.code_set = $single_cs
;AND cv.end_effective_dt_tm > SYSDATE ; left out because excludes
some incorrectly configured codes
AND cv.active_ind = 1
JOIN cs WHERE cv.code_set = cs.code_set
ORDER BY CNVTUPPER(cv.display), CNVTUPPER(cv.description),
cv.cdf_meaning
ELSEIF($tab =
"reports" AND $report_list = "Code Values (active)"
AND $single_cs NOT IN (72, 93, 200, 220, 14003))
cv.code_set
,code_set_name = SUBSTRING(1,40,replace_CRLF(cs.display))
,cv.code_value
,display = SUBSTRING(1,40,replace_CRLF(cv.display))
,cv.cdf_meaning
,description = SUBSTRING(1,60,replace_CRLF(cv.description))
,definition = SUBSTRING(1,100,replace_CRLF(cv.definition))
,cv.cki
,cv.concept_cki
,cv.collation_seq
,cv.active_dt_tm "MM/DD/YYYY;;D"
,cv.updt_dt_tm "MM/DD/YYYY;;D"
,cv.begin_effective_dt_tm "MM/DD/YYYY;;D"
,cv.end_effective_dt_tm "MM/DD/YYYY;;D"
,updated_by = p.name_full_formatted
,email = IF (p.person_id = 0) "" ELSE p.email ENDIF
,p.username
         ,prsnl_id
= cv.updt_id
FROM CODE_VALUE cv
,(LEFT JOIN PRSNL p ON cv.updt_id = p.person_id)
,CODE_VALUE_SET cs
PLAN cv        WHERE
cv.code_set = $single_cs
;AND cv.end_effective_dt_tm > SYSDATE ; left out because excludes
some incorrectly configured codes
AND cv.active_ind = 1
JOIN cs WHERE cv.code_set = cs.code_set
JOIN p
ORDER BY CNVTUPPER(cv.display), CNVTUPPER(cv.description),
cv.cdf_meaning
ELSEIF($tab =
"reports" AND $report_list = "Code Values (inactive)")
cv.code_set
,code_set_name = SUBSTRING(1,40,replace_CRLF(cs.display))
,cv.code_value
,display = SUBSTRING(1,40,replace_CRLF(cv.display))
,description = SUBSTRING(1,100,replace_CRLF(cv.description))
,definition = SUBSTRING(1,300,replace_CRLF(cv.definition))
,cv.cdf_meaning
,cv.active_ind
,cv.begin_effective_dt_tm "MM/DD/YYYY;;D"
,cv.end_effective_dt_tm "MM/DD/YYYY;;D"
,cv.inactive_dt_tm "MM/DD/YYYY;;D"
,cv.updt_dt_tm "MM/DD/YYYY;;D"
FROM CODE_VALUE cv
,CODE_VALUE_SET cs
PLAN cv        WHERE
cv.code_set = $single_cs
AND cv.active_ind = 0
JOIN cs WHERE cv.code_set = cs.code_set
ORDER BY cv.code_set, cv.display_key
ELSEIF($tab =
"reports" AND $report_list = "Code Value Aliases")
cv.code_set
,cv.code_value
,cv.display
,source = UAR_GET_CODE_DISPLAY(aliases.contributor_source_cd)
,aliases.direction
,aliases.alias
,aliases.alias_type_meaning
FROM CODE_VALUE cv
,(LEFT JOIN
(SELECT
code_set = ib.code_set
,code_value = ib.code_value
,contributor_source_cd = ib.contributor_source_cd
,alias = ib.alias
,alias_type_meaning = ib.alias_type_meaning
,direction =
"inbound"
FROM CODE_VALUE_ALIAS ib WHERE ib.code_set = $single_cs
UNION
(SELECT
code_set = ob.code_set
,code_value = ob.code_value
,contributor_source_cd = ob.contributor_source_cd
,alias = ob.alias
,alias_type_meaning = ob.alias_type_meaning
,direction = "outbound"
FROM CODE_VALUE_OUTBOUND ob WHERE ob.code_set = $single_cs
) WITH SQLTYPE("i4", "f8", "f8",
"c100", "c12", "c8"), RDBUNION) aliases
ON cv.code_set = aliases.code_set AND cv.code_value =
aliases.code_value)
PLAN cv WHERE cv.code_set = $single_cs
JOIN aliases
ORDER BY cv.display_key, source, aliases.direction
ELSEIF($tab =
"reports" AND $report_list = "Code Value Extensions")
cv.code_set
,cv.code_value
,display = SUBSTRING(1,40,replace_CRLF(cv.display))
,cve.field_name
,cve.field_type
,cve.field_value
FROM CODE_VALUE cv
,(LEFT JOIN CODE_VALUE_EXTENSION cve ON cv.code_set = cve.code_set
AND cv.code_value = cve.code_value)
PLAN cv        WHERE
cv.code_set = $single_cs
AND cv.active_ind = 1
JOIN cve
ORDER BY cv.display_key
ELSEIF($tab =
"reports" AND $report_list = "Code Value Filters")
cvf.code_set
,filter_type = UAR_GET_CODE_DISPLAY(cvf.filter_type_cd)
,filter = EVALUATE2(
IF(cvf.filter_ind = 0) "inclusive"
ELSEIF(cvf.filter_ind = 1) "exclusive"
ELSE "unknown"
ENDIF)
,target_code_value = cvf.flex1_id
,target_code_display = UAR_GET_CODE_DISPLAY(cvf.flex1_id)
,target_code_set = cs.code_set
,target_code_set_display = cs.display
,filter_active_dt_tm = cvf.active_status_dt_tm
FROM CODE_VALUE_FILTER cvf
,CODE_VALUE cv
,CODE_VALUE_SET cs
PLAN cvf WHERE cvf.code_set = $single_cs
AND cvf.active_ind = 1
JOIN cv WHERE cvf.flex1_id = cv.code_value
JOIN cs WHERE cv.code_set = cs.code_set
ORDER BY cvf.code_set, target_code_display
ELSEIF($tab =
"reports" AND $report_list = "Code Value Groups (P)")
cv.code_set
,child_code_value = cv.code_value
,child_code_display = SUBSTRING(1,40,replace_CRLF(cv.display))
,parent_set = parent.code_set
,parent_name = SUBSTRING(1,40,replace_CRLF(cs.display))
,parent_code_value = UAR_GET_CODE_DISPLAY(cvg.parent_code_value)
,last_updated = cvg.updt_dt_tm "MM/DD/YYYY HH:MM;;q"
FROM CODE_VALUE cv
,(LEFT JOIN CODE_VALUE_GROUP cvg ON cv.code_set = cvg.code_set
AND cv.code_value = cvg.child_code_value)
,(LEFT JOIN CODE_VALUE parent ON cvg.parent_code_value =
parent.code_value)
,(LEFT JOIN CODE_VALUE_SET cs ON parent.code_set = cs.code_set)
PLAN cv WHERE cv.code_set = $single_cs
AND cv.active_ind = 1
JOIN cvg
JOIN parent
JOIN cs
ORDER BY cv.code_set, child_code_display, parent_set, parent_code_value
ELSEIF($tab =
"reports" AND $report_list = "Code Value Groups (C)")
parent_cs = cs_parent.code_set
,parent_cs_disp = cs_parent.display
,parent_cv = cv_parent.code_value
,parent_cv_disp = cv_parent.display
,child_cs = cs_child.code_set
,child_cs_disp = cs_child.display
,child_cv = cv_child.code_value
,child_cv_disp = cv_child.display
,child_cv_desc = cv_child.description
,cg.updt_dt_tm "MM/DD/YYYY HH:MM;;q"
FROM CODE_VALUE cv_parent
,(LEFT JOIN CODE_VALUE_GROUP cg ON cv_parent.code_value =
cg.parent_code_value)
,(LEFT JOIN CODE_VALUE cv_child ON cg.child_code_value =
cv_child.code_value
AND cv_child.active_ind = 1
AND cv_child.end_effective_dt_tm > SYSDATE)
,(LEFT JOIN CODE_VALUE_SET cs_child ON cv_child.code_set =
cs_child.code_set)
,CODE_VALUE_SET cs_parent
PLAN cv_parent WHERE cv_parent.code_set = $single_cs
AND cv_parent.active_ind = 1
AND cv_parent.end_effective_dt_tm > SYSDATE
JOIN cs_parent WHERE cv_parent.code_set = cs_parent.code_set
JOIN cg
JOIN cv_child
JOIN cs_child
ORDER BY cs_parent.code_set, cv_parent.display, cv_child.code_set,
cv_child.display
ELSEIF($tab =
"reports" AND $report_list = "CDF Meanings")
cdf.code_set
,code_set_name = SUBSTRING(1,40,replace_CRLF(cs.display))
,cdf.cdf_meaning
,cdf.display
,cdf.definition
,nbr_mapped = CNVTINT(COUNT(DISTINCT cv.code_value))
FROM COMMON_DATA_FOUNDATION cdf
,(LEFT JOIN CODE_VALUE cv ON cdf.code_set = cv.code_set
AND cdf.cdf_meaning = cv.cdf_meaning
AND cv.active_ind = 1)
,CODE_VALUE_SET cs
PLAN cdf WHERE cdf.code_set = $single_cs
JOIN cs WHERE cdf.code_set = cs.code_set
JOIN cv
GROUP BY cdf.code_set, cs.display, cdf.cdf_meaning, cdf.display,
cdf.definition
ORDER BY cdf.cdf_meaning
ELSEIF($tab =
"reports" AND $report_list = "Order Entry Formats")
code_set = oe_fields.codeset
,catalog_type = UAR_GET_CODE_DISPLAY(oef.catalog_type_cd)
,oef.oe_format_name
,order_name = ocs.mnemonic
,field_name = oe_fields.description
,label = off.label_text
,ocs.catalog_cd
,oef.oe_format_id
,oe_fields.oe_field_id
FROM ORDER_ENTRY_FIELDS oe_fields
,OE_FORMAT_FIELDS off
,ORDER_ENTRY_FORMAT oef
,(LEFT JOIN ORDER_CATALOG_SYNONYM ocs
ON oef.oe_format_id = ocs.oe_format_id
AND ocs.mnemonic_type_cd = 2583 ;primary
AND ocs.active_ind = 1)
PLAN oe_fields WHERE oe_fields.codeset = $single_cs
JOIN off WHERE oe_fields.oe_field_id = off.oe_field_id
JOIN oef WHERE off.oe_format_id = oef.oe_format_id
AND oef.action_type_cd = 2534 ;Order
JOIN ocs
ORDER BY code_set, catalog_type, oef.oe_format_name, order_name
ELSEIF($tab =
"reports" AND $report_list = "Tables")
dcd.code_set
,dcd.table_name
,dcd.column_name
,dcd.description
FROM DM_COLUMNS_DOC dcd
PLAN dcd WHERE dcd.code_set = $single_cs
AND dcd.root_entity_name = "CODE_VALUE"
AND dcd.table_name != "*1*"
AND dcd.table_name != "*2*"
AND dcd.table_name != "*3*"
AND dcd.table_name != "*4*"
AND dcd.table_name != "*5*"
AND dcd.table_name != "*6*"
AND dcd.table_name != "*7*"
AND dcd.table_name != "*8*"
AND dcd.table_name != "*9*"
AND dcd.table_name != "*0*"
AND dcd.table_name != "*$*"
ORDER BY dcd.table_name,
dcd.column_name
/***********************************************************************/
ELSEIF($tab =
"audits" AND $audit_list = "Changes (summary) *")
cs.code_set
,code_set_name = cs.display
,cs.description
,updated_codes.nbr_codes_updated
,active_cnt.active_codes
,inactive_cnt.inactive_codes
,start_range = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_range = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
FROM CODE_VALUE_SET cs
,(INNER JOIN (SELECT cv.code_set, nbr_codes_updated = COUNT(*)
FROM CODE_VALUE cv
WHERE cv.updt_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
GROUP BY cv.code_set
WITH SQLTYPE("f8","i4")) updated_codes
ON cs.code_set =
updated_codes.code_set)
,(LEFT JOIN (SELECT cv.code_set, active_codes = COUNT(*)
FROM CODE_VALUE cv
WHERE cv.active_ind = 1
GROUP BY cv.code_set
WITH SQLTYPE("f8","i4")) active_cnt
ON cs.code_set = active_cnt.code_set)
,(LEFT JOIN (SELECT cv.code_set, inactive_codes = COUNT(*)
FROM CODE_VALUE cv
WHERE cv.active_ind = 0
GROUP BY cv.code_set
WITH SQLTYPE("f8","i4")) inactive_cnt
ON cs.code_set = inactive_cnt.code_set)
PLAN cs
JOIN updated_codes
JOIN active_cnt
JOIN inactive_cnt
ORDER BY cs.code_set
ELSEIF($tab =
"audits" AND $audit_list = "Changes (detail) *")
cv.code_set
,code_set_name = SUBSTRING(1,40,replace_CRLF(cs.display))
,cv.code_value
,display = SUBSTRING(1,40,replace_CRLF(cv.display))
,description = SUBSTRING(1,100,replace_CRLF(cv.description))
,definition = SUBSTRING(1,100,replace_CRLF(cv.definition))
,cv.cdf_meaning
,change =
IF ((cv.active_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND cv.active_ind = 1)) "activated"
ELSEIF ((cv.inactive_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND cv.active_ind = 0)) "deactivated"
ELSE "other"
ENDIF
,change_dt =
IF((cv.active_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND cv.active_ind = 1)) FORMAT(cv.active_dt_tm,
"MM/DD/YYYY;;D")
ELSEIF ((cv.inactive_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND cv.active_ind = 0)) FORMAT(cv.inactive_dt_tm,
"MM/DD/YYYY;;D")
ELSE FORMAT(cv.updt_dt_tm, "MM/DD/YYYY;;D")
                 ENDIF
,cv.active_ind
,personnel = p.name_full_formatted
,email = IF (p.person_id = 0) "" ELSE p.email ENDIF
,p.username
         ,prsnl_id
=
cv.updt_id
FROM CODE_VALUE cv
,(LEFT JOIN PRSNL p ON cv.updt_id = p.person_id)
,CODE_VALUE_SET cs
PLAN cv WHERE cv.updt_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
JOIN cs WHERE cv.code_set = cs.code_set
JOIN p
ORDER BY cv.code_set, change, cv.display
ELSEIF($tab =
"audits" AND $audit_list = "Changes (filtered) *")
cv.code_set
,code_set_name = SUBSTRING(1,40,replace_CRLF(cs.display))
,cv.code_value
,display = SUBSTRING(1,40,replace_CRLF(cv.display))
,description = SUBSTRING(1,100,replace_CRLF(cv.description))
,definition = SUBSTRING(1,100,replace_CRLF(cv.definition))
,cv.cdf_meaning
,change =
IF ((cv.active_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND cv.active_ind = 1)) "activated"
ELSEIF ((cv.inactive_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND cv.active_ind = 0)) "deactivated"
ELSE "other"
ENDIF
,change_dt =
IF((cv.active_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND cv.active_ind = 1)) FORMAT(cv.active_dt_tm,
"MM/DD/YYYY;;D")
ELSEIF ((cv.inactive_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND cv.active_ind = 0)) FORMAT(cv.inactive_dt_tm,
"MM/DD/YYYY;;D")
ELSE FORMAT(cv.updt_dt_tm, "MM/DD/YYYY;;D")
ENDIF
,cv.active_ind
,personnel = p.name_full_formatted
,email = IF (p.person_id = 0) "" ELSE p.email ENDIF
,p.username
,prsnl_id = cv.updt_id
         FROM
CODE_VALUE cv
                 ,(LEFT
JOIN PRSNL p ON cv.updt_id = p.person_id)
                 ,CODE_VALUE_SET
cs
         PLAN
cv WHERE cv.updt_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
                 ;event
set, DTA, order catalog, location, service resource, scheduling resources
                 AND
cv.code_set NOT IN (72,93,200,220,221,4508,14003,14231)
         JOIN
cs WHERE cv.code_set = cs.code_set
         JOIN
p
ORDER BY cv.code_set, change, cv.display
ELSEIF($tab =
"audits" AND $audit_list = "ESH orphans *")
event_cd = ec->list[d.seq].event_cd
,event_display = UAR_GET_CODE_DISPLAY(ec->list[d.seq].event_cd)
,in_use_ind = ec->list[d.seq].in_use_ind
,orphan_ind = ec->list[d.seq].orphan_ind
,event_set_name_ind = ec->list[d.seq].event_set_name_ind
,event_set_parent_ind = ec->list[d.seq].event_set_parent_ind
,cv.concept_cki
,cv.cki
,cv.active_dt_tm
,cv.updt_dt_tm
,updated_by = p.name_full_formatted
,email =
IF (p.person_id = 0) ""
ELSE p.email
ENDIF
FROM (DUMMYT d WITH seq = value(size(ec->list, 5)))
,CODE_VALUE cv
,(LEFT JOIN PRSNL p ON cv.updt_id = p.updt_id)
PLAN d WHERE ec->list[d.seq].orphan_ind = 1
JOIN cv WHERE ec->list[d.seq].event_cd = cv.code_value
AND cv.code_set = 72
AND cv.active_ind = 1
AND cv.end_effective_dt_tm > SYSDATE
AND cv.active_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
JOIN p
ORDER BY event_display
ELSEIF($tab =
"audits" AND $audit_list = "Expired active codes")
cv.code_set
,code_set_name = cs.display
,cv.code_value
,cv.display
,cv.description
,cv.cdf_meaning
,status =
IF(cv.active_ind = 0) "inactive"
ELSEIF(cv.active_ind = 1
AND cv.end_effective_dt_tm > SYSDATE
AND (cv.end_effective_dt_tm != CNVTDATETIME("31-Dec-2100
00:00:00"))) "active - non-standard"
ELSEIF(cv.active_ind = 1 AND NOT cv.end_effective_dt_tm > SYSDATE)
"active - expired"
ELSEIF(cv.active_ind = 1 AND cv.end_effective_dt_tm > SYSDATE)
"active"
ELSE "unknown"
ENDIF
,cv.active_ind
,cv.end_effective_dt_tm "MM/DD/YYYY;;d"
,last_updated = cv.updt_dt_tm "MM/DD/YYYY;;d"
,personnel = p.name_full_formatted
,email = IF (p.person_id = 0) "" ELSE p.email ENDIF
,p.username
,prsnl_id =
cv.updt_id
FROM CODE_VALUE cv
,(LEFT JOIN PRSNL p ON cv.updt_id = p.person_id)
,CODE_VALUE_SET cs
PLAN cv WHERE cv.active_ind = 1 AND cv.end_effective_dt_tm < SYSDATE
JOIN cs WHERE cv.code_set = cs.code_set
JOIN p
ORDER BY cv.code_set, cv.display
ELSEIF($tab =
"audits" AND $audit_list = "Non-standard active codes")
cv.code_set
,code_set_name = cs.display
,cv.code_value
,cv.display
,cv.description
,cv.cdf_meaning
,status =
IF(cv.active_ind = 0) "inactive"
ELSEIF(cv.active_ind = 1
AND cv.end_effective_dt_tm > SYSDATE
AND (cv.end_effective_dt_tm != CNVTDATETIME("31-Dec-2100
00:00:00"))) "active - non-standard"
ELSEIF(cv.active_ind = 1 AND NOT cv.end_effective_dt_tm > SYSDATE)
"active - expired"
ELSEIF(cv.active_ind = 1 AND cv.end_effective_dt_tm > SYSDATE)
"active"
ELSE "unknown"
ENDIF
,cv.active_ind
,cv.end_effective_dt_tm "MM/DD/YYYY;;d"
,last_updated = cv.updt_dt_tm "MM/DD/YYYY;;d"
,personnel = p.name_full_formatted
,email = IF (p.person_id = 0) "" ELSE p.email ENDIF
,p.username
,prsnl_id =
cv.updt_id
FROM CODE_VALUE cv
,(LEFT JOIN PRSNL p ON cv.updt_id = p.person_id)
,CODE_VALUE_SET cs
PLAN cv WHERE cv.active_ind = 1
AND cv.end_effective_dt_tm BETWEEN SYSDATE AND
CNVTDATETIME("30-Dec-2100 23:59:00")
;AND cv.end_effective_dt_tm != CNVTDATETIME("31-Dec-2100
00:00:00")
JOIN cs WHERE cv.code_set = cs.code_set
JOIN p
ORDER BY cv.code_set,
cv.display
/***********************************************************************/
ELSEIF($tab =
"search" AND $search_list = "Alerts")
ed.dlg_name
,ed.title
,ed.program_name
,ed.active_ind
,ed.beg_effective_dt_tm
,ed.end_effective_dt_tm
,ed.updt_dt_tm
,ed.version_major
,ed.version_minor
,ed.updt_id
,updt_prsnl = p.name_full_formatted
FROM EKS_DLG ed
,PRSNL p
PLAN ed        WHERE
(CNVTUPPER(ed.dlg_name) =
PATSTRING(CONCAT("*",$search_term,"*"))
OR CNVTUPPER(ed.title) =
PATSTRING(CONCAT("*",$search_term,"*")))
JOIN p WHERE ed.updt_id = p.person_id
ORDER BY ed.dlg_name, ed.active_ind DESC, ed.end_effective_dt_tm DESC
ELSEIF($tab =
"search" AND $search_list = "Alpha Responses (by DTA)")
dta = dta.display
,alpha_response = n.source_string
,a.sequence
,rrf.task_assay_cd
,a.reference_range_factor_id
,n.nomenclature_id
FROM CODE_VALUE dta
,REFERENCE_RANGE_FACTOR rrf
,ALPHA_RESPONSES a
,NOMENCLATURE n
PLAN dta WHERE dta.code_set = 14003
AND (CNVTUPPER(dta.display) =
PATSTRING(CONCAT("*",$search_term,"*"))
OR CNVTUPPER(dta.description) =
PATSTRING(CONCAT("*",$search_term,"*")))
AND dta.active_ind = 1
JOIN rrf WHERE dta.code_value = rrf.task_assay_cd
AND rrf.active_ind = 1
JOIN a WHERE a.reference_range_factor_id =
rrf.reference_range_factor_id
AND a.active_ind = 1
JOIN n WHERE a.nomenclature_id = n.nomenclature_id
AND n.active_ind = 1
ORDER BY dta, a.sequence, alpha_response
ELSEIF($tab =
"search" AND $search_list = "Anesthesia Actions")
ref.sa_ref_action_id
,ref.action_name
,ref.action_name_key
,task_assay = UAR_GET_CODE_DISPLAY(ref.task_assay_cd)
,ref.task_assay_cd
FROM SA_REF_ACTION ref
PLAN ref WHERE CNVTUPPER(ref.action_name) =
PATSTRING(CONCAT("*",$search_term,"*"))
AND ref.active_ind = 1
ORDER BY ref.action_name_key
ELSEIF($tab =
"search" AND $search_list = "Applications")
a.application_number
,a.description
,a.object_name
,a.owner
,a.text
FROM APPLICATION a
PLAN a WHERE CNVTUPPER(a.description) =
PATSTRING(CONCAT("*",$search_term,"*"))
AND a.active_ind = 1
ORDER BY a.description
; not
implemented in prompt!
; talk to
Jamie about other fields - have not explored with SO/SME
/*
ELSEIF($tab =
"search" AND $search_list = "Billing Entities")
be.billing_entity_id
,billing_entity = be.be_name
,description = be.be_desc
,organization = org.org_name
,be.place_of_service
,be.beg_effective_dt_tm
,be.end_effective_dt_tm
,last_updated = be.updt_dt_tm
,last_updated_by = p.name_full_formatted
;,be.*
FROM BILLING_ENTITY be
,ORGANIZATION org
,PRSNL p
PLAN be WHERE CNVTUPPER(be.be_name) =
PATSTRING(CONCAT($search_term,"*"))
AND be.be_name != be.be_desc
AND CNVTUPPER(be.be_name) != "ZZ*"
AND be.active_ind = 1
JOIN org WHERE org.organization_id = be.organization_id
JOIN p WHERE p.person_id = be.updt_id
ORDER BY CNVTUPPER(be.be_name)
*/
ELSEIF($tab =
"search" AND $search_list = "Clinical Events")
cv.code_set
,code_set_name = cs.display
,cv.code_value
,display = SUBSTRING(1,40,replace_CRLF(cv.display))
,description = SUBSTRING(1,100,replace_CRLF(cv.description))
,definition = SUBSTRING(1,300,replace_CRLF(cv.definition))
,cv.cdf_meaning
,cv.collation_seq
,cv.cki
,cv.concept_cki
,cv.active_dt_tm "MM/DD/YYYY;;D"
,cv.updt_dt_tm "MM/DD/YYYY;;D"
FROM CODE_VALUE cv
,CODE_VALUE_SET cs
PLAN cv        WHERE
cv.active_ind = 1
AND cv.end_effective_dt_tm > SYSDATE
AND cv.code_set = 72
AND (CNVTUPPER(cv.display) =
PATSTRING(CONCAT("*",$search_term,"*"))
OR CNVTUPPER(cv.description) =
PATSTRING(CONCAT("*",$search_term,"*")))
JOIN cs WHERE cv.code_set = cs.code_set
ORDER BY cv.code_set, cv.display
ELSEIF($tab =
"search" AND $search_list = "Clinical Events (by event
set)")
event_set = UAR_GET_CODE_DISPLAY(ex.event_set_cd)
,ex.event_set_cd
,event = UAR_GET_CODE_DISPLAY(ex.event_cd)
,ex.event_cd
,used_last_30_days = COUNT(DISTINCT ce.event_id)
FROM CODE_VALUE cv
,V500_EVENT_SET_EXPLODE ex
,(LEFT JOIN CLINICAL_EVENT ce
ON ce.event_cd = ex.event_cd
AND ce.event_end_dt_tm > SYSDATE-30
AND ce.valid_until_dt_tm > SYSDATE
AND ce.result_status_cd NOT IN (28,29,30,31)
AND ce.view_level = 1
)
PLAN cv        WHERE
cv.active_ind = 1
AND cv.end_effective_dt_tm > SYSDATE
AND cv.code_set = 93
AND (CNVTUPPER(cv.display) =
PATSTRING(CONCAT("*",$search_term,"*"))
OR CNVTUPPER(cv.description) =
PATSTRING(CONCAT("*",$search_term,"*")))
JOIN ex WHERE ex.event_set_cd = cv.code_value
JOIN ce
GROUP BY ex.event_set_cd, ex.event_cd
ORDER BY event_set, ex.event_set_cd, event, ex.event_cd
ELSEIF($tab =
"search" AND $search_list = "Clinical Events (by order)")
orderable = oc.description
,catalog_cd = cv.code_value
,task_assay = UAR_GET_CODE_DISPLAY(dta.task_assay_cd)
,dta.task_assay_cd
,event =
IF(cvr.event_cd > 0) UAR_GET_CODE_DISPLAY(cvr.event_cd)
ELSE UAR_GET_CODE_DISPLAY(dta.event_cd)
ENDIF
,event_cd =
IF(cvr.event_cd > 0) cvr.event_cd
ELSE dta.event_cd
ENDIF
FROM ORDER_CATALOG oc
,CODE_VALUE cv
,PROFILE_TASK_R ptr
,DISCRETE_TASK_ASSAY dta
,(LEFT JOIN CODE_VALUE_EVENT_R cvr ON dta.task_assay_cd =
cvr.parent_cd)
PLAN oc WHERE CNVTUPPER(oc.description) =
PATSTRING(CONCAT("*",$search_term,"*"))
AND oc.active_ind = 1
JOIN cv WHERE oc.catalog_cd = cv.code_value
AND cv.active_ind = 1
JOIN ptr WHERE cv.code_value = ptr.catalog_cd
AND ptr.active_ind = 1
JOIN dta WHERE ptr.task_assay_cd = dta.task_assay_cd
JOIN cvr
ORDER BY orderable, event
ELSEIF($tab =
"search" AND $search_list = "Code Sets")
cs.code_set
,display = SUBSTRING(1,40,replace_CRLF(cs.display))
,description = SUBSTRING(1,100,replace_CRLF(cs.description))
,active_cnt.active_codes
,inactive_cnt.inactive_codes
,active_code_set = EVALUATE2(
IF(active_cnt.active_codes > 0) "yes"
ELSE "no"
ENDIF)
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
PLAN cs        WHERE
CNVTUPPER(cs.display) =
PATSTRING(CONCAT("*",$search_term,"*"))
OR CNVTUPPER(cs.description) =
PATSTRING(CONCAT("*",$search_term,"*"))
JOIN active_cnt
JOIN inactive_cnt
ORDER BY cs.code_set, cs.display
ELSEIF($tab =
"search" AND $search_list = "Code Values (active)")
cv.code_set
,code_set_name = SUBSTRING(1,40,replace_CRLF(cs.display))
,cv.code_value
,display = SUBSTRING(1,40,replace_CRLF(cv.display))
,description = SUBSTRING(1,100,replace_CRLF(cv.description))
,definition = SUBSTRING(1,300,replace_CRLF(cv.definition))
,cv.cdf_meaning
,cv.collation_seq
,cv.cki
,cv.concept_cki
,cv.active_dt_tm "MM/DD/YYYY;;D"
,cv.updt_dt_tm "MM/DD/YYYY;;D"
FROM CODE_VALUE cv
,CODE_VALUE_SET cs
PLAN cv        WHERE
cv.active_ind = 1
AND cv.end_effective_dt_tm > SYSDATE
AND (CNVTUPPER(cv.display) =
PATSTRING(CONCAT("*",$search_term,"*"))
OR CNVTUPPER(cv.description) =
PATSTRING(CONCAT("*",$search_term,"*")))
JOIN cs WHERE cv.code_set = cs.code_set
ORDER BY cv.code_set, cv.display
ELSEIF($tab =
"search" AND $search_list = "Code Values (active, by code
value)")
cv.code_set
,code_set_name = SUBSTRING(1,40,replace_CRLF(cs.display))
,cv.code_value
,display = SUBSTRING(1,40,replace_CRLF(cv.display))
,description = SUBSTRING(1,100,replace_CRLF(cv.description))
,definition = SUBSTRING(1,300,replace_CRLF(cv.definition))
,cv.cdf_meaning
,cv.collation_seq
,cv.cki
,cv.concept_cki
,cv.active_dt_tm "MM/DD/YYYY;;D"
,cv.updt_dt_tm "MM/DD/YYYY;;D"
FROM CODE_VALUE cv
,CODE_VALUE_SET cs
PLAN cv        WHERE
cv.active_ind = 1
AND cv.end_effective_dt_tm > SYSDATE
AND cv.code_value = CNVTREAL($search_term)
JOIN cs WHERE cv.code_set = cs.code_set
ORDER BY cv.code_set,
cv.display
ELSEIF($tab =
"search" AND $search_list = "Code Values (active, by CDF
meaning)")
cv.code_set
,code_set_name = SUBSTRING(1,40,replace_CRLF(cs.display))
,cv.code_value
,display = SUBSTRING(1,40,replace_CRLF(cv.display))
,description = SUBSTRING(1,100,replace_CRLF(cv.description))
,definition = SUBSTRING(1,300,replace_CRLF(cv.definition))
,cv.cdf_meaning
,cv.collation_seq
,cv.cki
,cv.concept_cki
,cv.active_dt_tm "MM/DD/YYYY;;D"
,cv.updt_dt_tm "MM/DD/YYYY;;D"
FROM CODE_VALUE cv
,CODE_VALUE_SET cs
PLAN cv        WHERE
cv.active_ind = 1
AND cv.end_effective_dt_tm > SYSDATE
AND CNVTUPPER(cv.cdf_meaning) = $search_term
JOIN cs WHERE cv.code_set = cs.code_set
ORDER BY cv.code_set,
cv.display
ELSEIF($tab =
"search" AND $search_list = "Code Values (active, by CKI)")
cv.code_set
,code_set_name = SUBSTRING(1,40,replace_CRLF(cs.display))
,cv.code_value
,display = SUBSTRING(1,40,replace_CRLF(cv.display))
,description = SUBSTRING(1,100,replace_CRLF(cv.description))
,definition = SUBSTRING(1,300,replace_CRLF(cv.definition))
,cv.cdf_meaning
,cv.collation_seq
,cv.cki
,cv.concept_cki
,cv.active_dt_tm "MM/DD/YYYY;;D"
,cv.updt_dt_tm "MM/DD/YYYY;;D"
FROM CODE_VALUE cv
,CODE_VALUE_SET cs
PLAN cv        WHERE
cv.active_ind = 1
AND cv.end_effective_dt_tm > SYSDATE
AND CNVTUPPER(cv.cki) = $search_term
JOIN cs WHERE cv.code_set = cs.code_set
ORDER BY cv.code_set, cv.display
ELSEIF($tab =
"search" AND $search_list = "Code Values (inactive)")
cv.code_set
,code_set_name = SUBSTRING(1,40,replace_CRLF(cs.display))
,cv.code_value
,display = SUBSTRING(1,40,replace_CRLF(cv.display))
,description = SUBSTRING(1,100,replace_CRLF(cv.description))
,definition = SUBSTRING(1,300,replace_CRLF(cv.definition))
,cv.cdf_meaning
,cv.active_ind
,cv.begin_effective_dt_tm "MM/DD/YYYY;;D"
,cv.end_effective_dt_tm "MM/DD/YYYY;;D"
,cv.inactive_dt_tm "MM/DD/YYYY;;D"
,cv.updt_dt_tm "MM/DD/YYYY;;D"
FROM CODE_VALUE cv
,CODE_VALUE_SET cs
PLAN cv        WHERE
cv.active_ind = 0
AND (CNVTUPPER(cv.display) =
PATSTRING(CONCAT("*",$search_term,"*"))
OR CNVTUPPER(cv.description) =
PATSTRING(CONCAT("*",$search_term,"*")))
JOIN cs WHERE cv.code_set = cs.code_set
ORDER BY cv.code_set, cv.display
ELSEIF($tab =
"search" AND $search_list = "Discrete Task Assays")
dta_mnemonic = dta.mnemonic
,dta_description = dta.description
,result_type = UAR_GET_CODE_DISPLAY(dta.default_result_type_cd)
,dta.task_assay_cd
,event_cd =
IF(cvr.event_cd > 0) cvr.event_cd
ELSE dta.event_cd
ENDIF
,event_display =
IF(cvr.event_cd > 0) cv.display
ELSE cv_dta.display
ENDIF
,event_description =
IF(cvr.event_cd > 0) cv.description
ELSE cv_dta.description
ENDIF
,cv.cdf_meaning
,cv.collation_seq
,cv.cki
,cv.concept_cki
,cv.active_dt_tm "MM/DD/YYYY;;D"
,cv.updt_dt_tm "MM/DD/YYYY;;D"
FROM DISCRETE_TASK_ASSAY dta
,(LEFT JOIN CODE_VALUE cv_dta ON dta.event_cd =
cv_dta.code_value)
,(LEFT JOIN CODE_VALUE_EVENT_R cvr ON dta.task_assay_cd =
cvr.parent_cd)
,(LEFT JOIN CODE_VALUE cv ON cvr.event_cd = cv.code_value)
PLAN dta WHERE dta.active_ind = 1
AND dta.end_effective_dt_tm > SYSDATE
AND (CNVTUPPER(dta.mnemonic) =
PATSTRING(CONCAT("*",$search_term,"*"))
OR CNVTUPPER(dta.description) =
PATSTRING(CONCAT("*",$search_term,"*")))
JOIN cv_dta
JOIN cvr
JOIN cv
ORDER BY dta.mnemonic
ELSEIF($tab =
"search" AND $search_list = "Event Sets")
cv.code_set
,code_set_name = cs.display
,cv.code_value
,display = SUBSTRING(1,40,replace_CRLF(cv.display))
,description = SUBSTRING(1,100,replace_CRLF(cv.description))
,definition = SUBSTRING(1,300,replace_CRLF(cv.definition))
,cv.cdf_meaning
,cv.collation_seq
,cv.cki
,cv.concept_cki
,cv.active_dt_tm "MM/DD/YYYY;;D"
,cv.updt_dt_tm "MM/DD/YYYY;;D"
FROM CODE_VALUE cv
,CODE_VALUE_SET cs
PLAN cv        WHERE
cv.active_ind = 1
AND cv.end_effective_dt_tm > SYSDATE
AND cv.code_set = 93
AND (CNVTUPPER(cv.display) =
PATSTRING(CONCAT("*",$search_term,"*"))
OR CNVTUPPER(cv.description) =
PATSTRING(CONCAT("*",$search_term,"*")))
JOIN cs WHERE cv.code_set = cs.code_set
ORDER BY cv.code_set, cv.display
ELSEIF($tab =
"search" AND $search_list = "Health Plans")
hp.health_plan_id
,hp.plan_name
,service_type = UAR_GET_CODE_DISPLAY(hp.service_type_cd)
,financial_class = UAR_GET_CODE_DISPLAY(hp.financial_class_cd)
,plan_type = UAR_GET_CODE_DISPLAY(hp.plan_type_cd)
,hp.beg_effective_dt_tm
,hp.end_effective_dt_tm
,last_updated = hp.updt_dt_tm
,last_updated_by = p.name_full_formatted
FROM HEALTH_PLAN hp
,PRSNL p
PLAN hp WHERE CNVTUPPER(hp.plan_name) =
PATSTRING(CONCAT("*",$search_term,"*"))
AND hp.active_ind = 1
JOIN p WHERE p.person_id = hp.updt_id
ORDER BY CNVTUPPER(hp.plan_name), hp.beg_effective_dt_tm
ELSEIF($tab =
"search" AND $search_list = "HL7 Aliases (outbound)")
cbo.code_set
,code_set_name = cs.display
,code_value_display = UAR_GET_CODE_DISPLAY(cbo.code_value)
,cbo.code_value
,outbound_system = UAR_GET_CODE_DISPLAY(cbo.contributor_source_cd)
,cbo.alias
,cbo.alias_type_meaning
FROM CODE_VALUE_OUTBOUND cbo
,CODE_VALUE_SET cs
PLAN cbo WHERE CNVTUPPER(cbo.alias) =
PATSTRING(CONCAT("*",$search_term,"*"))
AND cbo.contributor_source_cd IN (
18024123 ;HL7
,3310544 ;HL7 ALIASES
,23274495) ;HL7 v2
JOIN cs WHERE cbo.code_set = cs.code_set
ORDER BY cbo.code_set, outbound_system, cbo.alias
ELSEIF($tab =
"search" AND $search_list = "Insurance Profiles")
display = SUBSTRING(1,40,replace_CRLF(cv.display))
,cv.code_value
,cv.begin_effective_dt_tm "MM/DD/YYYY;;d"
,cv.end_effective_dt_tm "MM/DD/YYYY;;d"
FROM CODE_VALUE cv
PLAN cv        WHERE
cv.code_set = 368
AND (CNVTUPPER(cv.display) =
PATSTRING(CONCAT("*",$search_term,"*"))
OR CNVTUPPER(cv.description) =
PATSTRING(CONCAT("*",$search_term,"*")))
AND cv.active_ind = 1
ORDER BY CNVTUPPER(cv.display)
ELSEIF($tab =
"search" AND $search_list = "Locations (all)")
cv.code_set
,code_set_name = SUBSTRING(1,40,replace_CRLF(cs.display))
,hierarchy_meaning =
IF(cv.cdf_meaning = "FACILITY") "1 - Facility"
ELSEIF(cv.cdf_meaning = "BUILDING") "2 - Building"
ELSEIF(cv.cdf_meaning IN ("AMBULATORY",
"NURSEUNIT")) "3 - Ambulatory/Nurse Unit"
ELSEIF(cv.cdf_meaning = "ROOM") "4 - Room"
ELSEIF(cv.cdf_meaning = "BED") "5 - Bed"
ELSE BUILD("OTHER-", cv.cdf_meaning)
ENDIF
,facility_org_id = loc.organization_id
,location_cd = cv.code_value
,display = SUBSTRING(1,40,replace_CRLF(cv.display))
,description = SUBSTRING(1,100,replace_CRLF(cv.description))
,definition = SUBSTRING(1,300,replace_CRLF(cv.definition))
,cv.collation_seq
,cv.cki
,cv.concept_cki
,cv.active_dt_tm "MM/DD/YYYY;;D"
,cv.updt_dt_tm "MM/DD/YYYY;;D"
FROM CODE_VALUE cv
,CODE_VALUE_SET cs
,LOCATION loc
PLAN cv        WHERE
cv.active_ind = 1
AND cv.end_effective_dt_tm > SYSDATE
AND cv.code_set = 220 ;location
AND (CNVTUPPER(cv.display) =
PATSTRING(CONCAT("*",$search_term,"*"))
OR CNVTUPPER(cv.description) =
PATSTRING(CONCAT("*",$search_term,"*")))
JOIN cs WHERE cv.code_set = cs.code_set
JOIN loc WHERE cv.code_value = loc.location_cd
ORDER BY hierarchy_meaning, cv.display
ELSEIF($tab =
"search" AND $search_list = "Locations (ERSA sites)")
dmis_id = oa.alias
,ersa_site = o.org_name
,o.organization_id
FROM ORGANIZATION o
,ORGANIZATION_ALIAS oa
PLAN o WHERE CNVTUPPER(o.org_name) =
PATSTRING(CONCAT("*",$search_term,"*"))
AND CNVTUPPER(o.org_name) = "*-ERS-*"
AND o.end_effective_dt_tm > SYSDATE
AND o.active_ind = 1
JOIN oa WHERE oa.organization_id = o.organization_id
AND oa.org_alias_type_cd = 1130 ;DMIS ID
AND oa.end_effective_dt_tm > SYSDATE
AND oa.active_ind = 1
ORDER BY dmis_id, ersa_site
ELSEIF($tab =
"search" AND $search_list = "Locations (facilities)")
cv.code_set
,code_set_name = SUBSTRING(1,40,replace_CRLF(cs.display))
,hierarchy_meaning = cv.cdf_meaning
,facility_org_id = loc.organization_id
,location_cd = cv.code_value
,display = SUBSTRING(1,40,replace_CRLF(cv.display))
,description = SUBSTRING(1,100,replace_CRLF(cv.description))
,definition = SUBSTRING(1,300,replace_CRLF(cv.definition))
,cv.collation_seq
,cv.cki
,cv.concept_cki
,cv.active_dt_tm "MM/DD/YYYY;;D"
,cv.updt_dt_tm "MM/DD/YYYY;;D"
FROM CODE_VALUE cv
,CODE_VALUE_SET cs
,LOCATION loc
PLAN cv        WHERE
cv.active_ind = 1
AND cv.end_effective_dt_tm > SYSDATE
AND cv.code_set = 220 ;location
AND cv.cdf_meaning = "FACILITY"
AND (CNVTUPPER(cv.display) =
PATSTRING(CONCAT("*",$search_term,"*"))
OR CNVTUPPER(cv.description) =
PATSTRING(CONCAT("*",$search_term,"*")))
JOIN cs WHERE cv.code_set = cs.code_set
JOIN loc WHERE cv.code_value = loc.location_cd
ORDER BY hierarchy_meaning,
cv.display
ELSEIF($tab =
"search" AND $search_list = "Locations (facilities by
parent)")
 parent =
         IF(TEXTLEN(ag.dmis_code)>1)ag.dmis_code
         ELSE ag.visn_code
         ENDIF
 ,facility =
UAR_GET_CODE_DISPLAY(ag.location_cd)
 ,description =
UAR_GET_CODE_DESCRIPTION(ag.location_cd)
 ,ag.location_cd
 ,ag.organization_id
 FROM CUST_LOC_AGENCY_RELTN ag
 PLAN ag WHERE ag.validated_ind = 1
         AND (ag.dmis_code =
PATSTRING(CONCAT("*",$search_term,"*"))
                 OR
ag.visn_code = PATSTRING(CONCAT("*",$search_term,"*")))
 ORDER BY parent, facility
ELSEIF($tab =
"search" AND $search_list = "Med Identifiers")
item = mi.value
,mi.item_id
,mi.med_identifier_id
FROM MED_IDENTIFIER mi
PLAN mi WHERE CNVTUPPER(mi.value) =
PATSTRING(CONCAT("*",$search_term,"*"))
AND mi.med_identifier_type_cd = 3097 ;description
AND mi.med_product_id = 0 ;not manufacturer-level
AND mi.active_ind = 1
ORDER BY item, mi.item_id
ELSEIF($tab =
"search" AND $search_list = "Mpages")
DISTINCT
topic = mp.category_name
,view_display_name = v.freetext_desc
,type = EVALUATE(mp.category_type_flag,
0, "Lighthouse",
1, "Mpage",
2, "NHIQM",
"Unknown flag value")
,layout = EVALUATE(mp.layout_flag,
0, "Summary layout",
1, "Workflow layout",
2, "Smart Template",
3, "Quick Orders and Charges",
4, "Patient Organizer View",
5, "Dashboard",
6, "Organizer View - Provider",
7, "Emergent Event",
8, "SCM Purchase Order Organizer",
9, "SCM Inventory Management Organizer",
"Unknown flag value")
,mp.br_datamart_category_id
FROM BR_DATAMART_CATEGORY mp
,(LEFT JOIN BR_DATAMART_FILTER f ON f.br_datamart_category_id =
mp.br_datamart_category_id
AND f.filter_mean = "VIEWPOINT_LABEL")
,(LEFT JOIN BR_DATAMART_VALUE v ON v.br_datamart_filter_id =
f.br_datamart_filter_id)
PLAN mp
JOIN f
JOIN v
WHERE (CNVTUPPER(mp.category_name) =
PATSTRING(CONCAT("*",$search_term,"*"))
OR CNVTUPPER(v.freetext_desc) =
PATSTRING(CONCAT("*",$search_term,"*")))
ORDER BY CNVTUPPER(mp.category_name), view_display_name, type, layout,
mp.br_datamart_category_id
ELSEIF($tab =
"search" AND $search_list = "Nomenclature")
code = n.source_identifier
,description = n.source_string
,vocabulary = UAR_GET_CODE_DISPLAY(n.source_vocabulary_cd)
,type = UAR_GET_CODE_DISPLAY(n.principle_type_cd)
,axis = UAR_GET_CODE_DISPLAY(n.vocab_axis_cd)
,primary_term = EVALUATE(n.primary_vterm_ind, 1, "yes",
"no")
;,n.primary_cterm_ind
;,contrib_system = UAR_GET_CODE_DISPLAY(n.contributor_system_cd)
,n.concept_cki
,n.nomenclature_id
FROM NOMENCLATURE n
PLAN n WHERE 1=1
AND (n.source_identifier_keycap =
PATSTRING(CONCAT("*",$search_term,"*"))
OR CNVTUPPER(n.source_string) =
PATSTRING(CONCAT("*",$search_term,"*")))
;OR n.source_string_keycap = $search_term)
AND n.primary_vterm_ind = 1
AND n.active_ind = 1
AND n.end_effective_dt_tm > SYSDATE
ORDER BY vocabulary, type, axis, code
ELSEIF($tab =
"search" AND $search_list = "Order Catalog")
cv.code_set
,code_set_name = SUBSTRING(1,40,replace_CRLF(cs.display))
,catalog_cd = cv.code_value
,description = oc.description
,primary_mnemonic = SUBSTRING(1,300,replace_CRLF(oc.primary_mnemonic))
,catalog_type = UAR_GET_CODE_DISPLAY(oc.catalog_type_cd)
,activity_type = UAR_GET_CODE_DISPLAY(oc.activity_type_cd)
,activity_subtype = UAR_GET_CODE_DISPLAY(oc.activity_subtype_cd)
,cv.cdf_meaning
,cv.collation_seq
,cv.cki
,cv.concept_cki
,cv.active_dt_tm "MM/DD/YYYY;;D"
,cv.updt_dt_tm "MM/DD/YYYY;;D"
FROM ORDER_CATALOG oc
,CODE_VALUE_SET cs
,CODE_VALUE cv
PLAN oc WHERE CNVTUPPER(oc.description) =
PATSTRING(CONCAT("*",$search_term,"*"))
AND oc.active_ind = 1
JOIN cv WHERE oc.catalog_cd = cv.code_value
JOIN cs WHERE cv.code_set = cs.code_set
ORDER BY cv.code_set, cv.display
ELSEIF($tab =
"search" AND $search_list = "Order Catalog (by bill code)")
DISTINCT
orderable = bi.ext_description
,bill_code = BUILD(n.source_identifier, " (",
TRIM(UAR_GET_CODE_DISPLAY(n.source_vocabulary_cd)), ")")
,catalog_type =
UAR_GET_CODE_DISPLAY(oc.catalog_type_cd)
,activity_type = UAR_GET_CODE_DISPLAY(bi.ext_owner_cd)
,oc.catalog_cd
,bi.bill_item_id
;,vocab = UAR_GET_CODE_DISPLAY(n.source_vocabulary_cd)
;        ,schedule_type
= cv.display
;        ,type
= UAR_GET_CODE_DISPLAY(n.principle_type_cd)
;        ,description
= n.source_string
FROM NOMENCLATURE n
,BILL_ITEM_MODIFIER bim
,CODE_VALUE cv
,BILL_ITEM bi
,ORDER_CATALOG oc
PLAN n WHERE 1=1
AND (n.source_string =
PATSTRING(CONCAT("*",$search_term,"*"))
OR n.source_identifier_keycap =
PATSTRING(CONCAT("*",$search_term,"*")))
AND n.active_ind = 1
AND n.end_effective_dt_tm > SYSDATE
JOIN bim WHERE n.nomenclature_id = bim.key3_id
AND bim.key3_entity_name = "NOMENCLATURE"
AND bim.bill_item_type_cd = 3459 ;bill code
AND bim.active_ind = 1
AND bim.end_effective_dt_tm > SYSDATE
JOIN cv WHERE bim.key1_id = cv.code_value
AND bim.key1_entity_name = "CODE_VALUE"
AND cv.active_ind = 1
AND cv.end_effective_dt_tm > SYSDATE
JOIN bi WHERE bim.bill_item_id = bi.bill_item_id
AND bi.ext_parent_contributor_cd = 3443 ;order catalog
AND bi.active_ind = 1
AND bi.end_effective_dt_tm > SYSDATE
JOIN oc WHERE bi.ext_parent_reference_id = oc.catalog_cd
AND oc.active_ind = 1
ORDER BY bill_code, catalog_type, activity_type, orderable;, vocab
ELSEIF($tab =
"search" AND $search_list = "Order Catalog (by OE format)")
oefmt.oe_format_name
,oefmt.oe_format_id
,orderable = oc.description
,catalog_type = UAR_GET_CODE_DISPLAY(oc.catalog_type_cd)
,oc.catalog_cd
FROM ORDER_ENTRY_FORMAT oefmt
,ORDER_CATALOG oc
PLAN oefmt WHERE oefmt.action_type_cd = 2534 ;order
AND CNVTUPPER(oefmt.oe_format_name) =
PATSTRING(CONCAT("*",$search_term,"*"))
JOIN oc WHERE oefmt.oe_format_id = oc.oe_format_id
AND oc.active_ind = 1
ORDER BY oefmt.oe_format_name, catalog_type,
orderable
ELSEIF($tab =
"search" AND $search_list = "Order Catalog (by synonym)")
orderable = oc.description
,ocs.mnemonic
,mnemonic_type = UAR_GET_CODE_DISPLAY(ocs.mnemonic_type_cd)
,catalog_type = UAR_GET_CODE_DISPLAY(ocs.catalog_type_cd)
,activity_type = UAR_GET_CODE_DISPLAY(ocs.activity_type_cd)
,activity_subtype = UAR_GET_CODE_DISPLAY(ocs.activity_subtype_cd)
,ocs.catalog_cd
,ocs.synonym_id
FROM ORDER_CATALOG_SYNONYM ocs
,ORDER_CATALOG oc
PLAN ocs WHERE CNVTUPPER(ocs.mnemonic) =
PATSTRING(CONCAT("*",$search_term,"*"))
AND ocs.active_ind = 1
JOIN oc WHERE ocs.catalog_cd = oc.catalog_cd
AND oc.active_ind = 1
ORDER BY orderable, ocs.mnemonic, mnemonic_type
ELSEIF($tab =
"search" AND $search_list = "Order Entry Fields")
format_name = oef.oe_format_name
,field_label =
off.label_text
,field_description = oefld.description
,field_state = EVALUATE(off.accept_flag,
0, "Required",
1, "Optional",
2, "No Display",
3, "Display Only",
"Unknown")
,field_type = EVALUATE(oefld.field_type_flag,
0, "Alphanumeric",
1, "Integer",
2, "Decimal",
3, "Date",
; no 4 in DM_FLAGS
5, "Date/Time",
6, "Code Set",
7, "Yes/No",
8, "Provider",
9, "Location",
10, "ICD",
11, "Printer",
12, "List",
13, "User/Personnel",
14, "Accession",
15, "Surgical Duration",
"Unknown")
,code_set =
oefld.codeset
,field_meaning = ofm.description
,orderable = UAR_GET_CODE_DESCRIPTION(ocs.catalog_cd)
,synonym = ocs.mnemonic
,synonym_type = UAR_GET_CODE_DISPLAY(ocs.mnemonic_type_cd)
,catalog_type = UAR_GET_CODE_DISPLAY(ocs.catalog_type_cd)
,clinical_category = UAR_GET_CODE_DISPLAY(ocs.dcp_clin_cat_cd)
,off.oe_format_id
,oefld.oe_field_id
,ocs.catalog_cd
,ocs.synonym_id
FROM ORDER_ENTRY_FIELDS oefld
,OE_FIELD_MEANING ofm
,OE_FORMAT_FIELDS off
,ORDER_ENTRY_FORMAT oef
,ORDER_CATALOG_SYNONYM ocs
PLAN oefld WHERE CNVTUPPER(oefld.description) =
PATSTRING(CONCAT("*",$search_term,"*"))
JOIN ofm WHERE oefld.oe_field_meaning_id = ofm.oe_field_meaning_id
JOIN off WHERE oefld.oe_field_id = off.oe_field_id AND
off.action_type_cd = 2534 ;order
JOIN oef WHERE off.oe_format_id = oef.oe_format_id AND
oef.action_type_cd = off.action_type_cd
JOIN ocs WHERE oef.oe_format_id = ocs.oe_format_id AND ocs.active_ind =
1
ORDER BY format_name, field_label, field_description, orderable,
synonym_type DESC, synonym
ELSEIF($tab =
"search" AND $search_list = "Organizations")
org.org_name
,org.organization_id
,org.beg_effective_dt_tm
,org.end_effective_dt_tm
FROM ORGANIZATION org
PLAN org WHERE CNVTUPPER(org.org_name) =
PATSTRING(CONCAT("*",$search_term,"*"))
AND org.active_ind = 1
ORDER BY org.org_name
/* Removing
for now - currently this is just a copy of PowerPlans
ELSEIF($tab =
"search" AND $search_list = "Pathways")
pathway = pc.description
,pc.type_mean
,pc.version
,pc.pathway_catalog_id
FROM PATHWAY_CATALOG pc
PLAN pc WHERE CNVTUPPER(pc.description) =
PATSTRING(CONCAT("*",$search_term,"*"))
AND pc.type_mean = "CAREPLAN" ;powerplans
AND pc.active_ind = 1
ORDER BY pathway, pc.type_mean
*/
/*
ELSEIF($tab =
"search" AND $search_list = "Organizations")
org.org_name
,org.organization_id
*/
ELSEIF($tab =
"search" AND $search_list = "PowerForms")
;adhoc_folder = TRIM(pf->list[d.seq].folder)
DISTINCT
powerform_display_name =
TRIM(pf->list[d.seq].powerform_display_name)
,powerform_unique_name = TRIM(pf->list[d.seq].powerform_unique_name)
,dcp_forms_ref_id = pf->list[d.seq].dcp_forms_ref_id
,search_term = $search_term
,found_in = SUBSTRING(1,500,
eval_result_bit(pf->list[d.seq].result_bit))
FROM (DUMMYT d WITH seq = value(size(pf->list, 5)))
PLAN d
ORDER BY powerform_display_name, powerform_unique_name,
dcp_forms_ref_id, search_term, found_in
ELSEIF($tab =
"search" AND $search_list = "PowerForm Config - Forms")
form_definition = forms_ref.definition
,form_description = forms_ref.description
,section_definition = sec_ref.definition
,section_description = sec_ref.description
,section_sequence = forms_def.section_seq
,input_description = input_ref.description
,input_sequence = input_ref.input_ref_seq
,input_type = EVALUATE(input_ref.input_type
, 4, "Alpha List"
, 6, "Free Text (255 char)"
, 7, "Calculated Field"
, 9, "Alpha Combo Box"
,10, "Date/Time"
,13, "Rich Text"
,14, "Discrete Grid"
,17, "Power Grid"
,18, "Provider Selection"
,19, "Ultra Grid"
,21, "Conversion Control"
,22, "Numeric"
,BUILD("Unmapped (",CNVTSTRING(input_ref.input_type),
")")
)
,dta_mnemonic = dta.mnemonic
,dta_result_type = UAR_GET_CODE_DISPLAY(dta.default_result_type_cd)
,dta.task_assay_cd
,event_name =
IF(cvr.event_cd > 0) UAR_GET_CODE_DISPLAY(cvr.event_cd)
ELSE UAR_GET_CODE_DISPLAY(dta.event_cd)
ENDIF
,event_cd =
IF(cvr.event_cd > 0) cvr.event_cd
ELSE dta.event_cd
ENDIF
,dta.default_type_flag
,default_value = EVALUATE(dta.default_type_flag,
0, "No default value",
1, "Default from the reference range",
2, "Default from last charted value (any encounter)",
3, "Default from the template script",
"Unknown flag value")
,required_field = required.pvc_value
,free_text = free_text.pvc_value
,multi_select = multi_select.pvc_value
,first_alpha_single_select = first_alpha_single_select.pvc_value
,lookback_minutes = lookback.offset_min_nbr
,forms_ref.dcp_forms_ref_id
FROM DCP_FORMS_REF forms_ref
,DCP_FORMS_DEF forms_def
,DCP_SECTION_REF sec_ref
,DCP_INPUT_REF input_ref
,(LEFT JOIN NAME_VALUE_PREFS required ON input_ref.dcp_input_ref_id =
required.parent_entity_id
AND required.parent_entity_name = "DCP_INPUT_REF"
AND required.pvc_name = "required")
,(LEFT JOIN NAME_VALUE_PREFS free_text ON input_ref.dcp_input_ref_id =
free_text.parent_entity_id
AND free_text.parent_entity_name = "DCP_INPUT_REF"
AND free_text.pvc_name = "freetext")
,(LEFT JOIN NAME_VALUE_PREFS multi_select ON input_ref.dcp_input_ref_id
= multi_select.parent_entity_id
AND multi_select.parent_entity_name = "DCP_INPUT_REF"
AND multi_select.pvc_name = "mult*select")
,(LEFT JOIN NAME_VALUE_PREFS first_alpha_single_select
ON input_ref.dcp_input_ref_id =
first_alpha_single_select.parent_entity_id
AND first_alpha_single_select.parent_entity_name =
"DCP_INPUT_REF"
AND first_alpha_single_select.pvc_name = "exclude_first_ar")
,NAME_VALUE_PREFS nvp
,DISCRETE_TASK_ASSAY dta
,(LEFT JOIN DTA_OFFSET_MIN lookback
ON lookback.task_assay_cd = dta.task_assay_cd
AND lookback.active_ind = 1
AND lookback.end_effective_dt_tm > SYSDATE)
,(LEFT JOIN CODE_VALUE_EVENT_R cvr ON dta.task_assay_cd =
cvr.parent_cd)
; NOTE: doing inner join to NVP/DTA likely excluding input controls not
tied to DTAs, like labels
PLAN forms_ref WHERE (CNVTUPPER(forms_ref.description) =
PATSTRING(CONCAT("*",$search_term,"*"))
OR CNVTUPPER(forms_ref.definition) =
PATSTRING(CONCAT("*",$search_term,"*")))
AND forms_ref.active_ind = 1
AND forms_ref.end_effective_dt_tm > SYSDATE
JOIN forms_def WHERE forms_ref.dcp_form_instance_id =
forms_def.dcp_form_instance_id
AND forms_def.active_ind = 1
JOIN sec_ref WHERE forms_def.dcp_section_ref_id =
sec_ref.dcp_section_ref_id
AND sec_ref.active_ind = 1
AND sec_ref.end_effective_dt_tm > SYSDATE
JOIN input_ref WHERE sec_ref.dcp_section_instance_id =
input_ref.dcp_section_instance_id
AND input_ref.active_ind = 1
JOIN nvp WHERE input_ref.dcp_input_ref_id = nvp.parent_entity_id
AND nvp.parent_entity_name = "DCP_INPUT_REF"
AND nvp.merge_name = "DISCRETE_TASK_ASSAY"
JOIN dta WHERE nvp.merge_id = dta.task_assay_cd
AND dta.active_ind = 1
AND dta.end_effective_dt_tm > SYSDATE
JOIN required
JOIN free_text
JOIN multi_select
JOIN first_alpha_single_select
JOIN lookback
JOIN cvr
ORDER BY forms_ref.definition, forms_ref.description,
forms_def.section_seq, input_ref.input_ref_seq
ELSEIF($tab =
"search" AND $search_list = "PowerForm Config - Sections")
section_definition = sec_ref.definition
,section_description = sec_ref.description
,input_description = input_ref.description
,input_sequence = input_ref.input_ref_seq
,input_type = EVALUATE(input_ref.input_type
, 4, "Alpha List"
, 6, "Free Text (255 char)"
, 7, "Calculated Field"
, 9, "Alpha Combo Box"
,10, "Date/Time"
,13, "Rich Text"
,14, "Discrete Grid"
,17, "Power Grid"
,18, "Provider Selection"
,19, "Ultra Grid"
,21, "Conversion Control"
,22, "Numeric"
,BUILD("Unmapped (",CNVTSTRING(input_ref.input_type),
")")
)
,dta_mnemonic = dta.mnemonic
,dta_result_type = UAR_GET_CODE_DISPLAY(dta.default_result_type_cd)
,dta.task_assay_cd
,event_name =
IF(cvr.event_cd > 0) UAR_GET_CODE_DISPLAY(cvr.event_cd)
ELSE UAR_GET_CODE_DISPLAY(dta.event_cd)
ENDIF
,event_cd =
IF(cvr.event_cd > 0) cvr.event_cd
ELSE dta.event_cd
ENDIF
,dta.default_type_flag
,default_value = EVALUATE(dta.default_type_flag,
0, "No default value",
1, "Default from the reference range",
2, "Default from last charted value (any encounter)",
3, "Default from the template script",
"Unknown flag value")
,required_field = required.pvc_value
,free_text = free_text.pvc_value
,multi_select = multi_select.pvc_value
,first_alpha_single_select = first_alpha_single_select.pvc_value
,lookback_minutes = lookback.offset_min_nbr
,sec_ref.dcp_section_ref_id
FROM DCP_SECTION_REF sec_ref
,DCP_INPUT_REF input_ref
,(LEFT JOIN NAME_VALUE_PREFS required ON input_ref.dcp_input_ref_id =
required.parent_entity_id
AND required.parent_entity_name = "DCP_INPUT_REF"
AND required.pvc_name = "required")
,(LEFT JOIN NAME_VALUE_PREFS free_text ON input_ref.dcp_input_ref_id =
free_text.parent_entity_id
AND free_text.parent_entity_name = "DCP_INPUT_REF"
AND free_text.pvc_name = "freetext")
,(LEFT JOIN NAME_VALUE_PREFS multi_select ON input_ref.dcp_input_ref_id
= multi_select.parent_entity_id
AND multi_select.parent_entity_name = "DCP_INPUT_REF"
AND multi_select.pvc_name = "mult*select")
,(LEFT JOIN NAME_VALUE_PREFS first_alpha_single_select
ON input_ref.dcp_input_ref_id =
first_alpha_single_select.parent_entity_id
AND first_alpha_single_select.parent_entity_name =
"DCP_INPUT_REF"
AND first_alpha_single_select.pvc_name = "exclude_first_ar")
,NAME_VALUE_PREFS nvp
,DISCRETE_TASK_ASSAY dta
,(LEFT JOIN DTA_OFFSET_MIN lookback
ON lookback.task_assay_cd = dta.task_assay_cd
AND lookback.active_ind = 1
AND lookback.end_effective_dt_tm > SYSDATE)
,(LEFT JOIN CODE_VALUE_EVENT_R cvr ON dta.task_assay_cd =
cvr.parent_cd)
; NOTE: doing inner join to NVP/DTA likely excluding input controls not
tied to DTAs, like labels
PLAN sec_ref WHERE CNVTUPPER(sec_ref.description) =
PATSTRING(CONCAT("*",$search_term,"*"))
AND sec_ref.active_ind = 1
AND sec_ref.end_effective_dt_tm > SYSDATE
JOIN input_ref WHERE sec_ref.dcp_section_instance_id =
input_ref.dcp_section_instance_id
AND input_ref.active_ind = 1
JOIN nvp WHERE input_ref.dcp_input_ref_id = nvp.parent_entity_id
AND nvp.parent_entity_name = "DCP_INPUT_REF"
AND nvp.merge_name = "DISCRETE_TASK_ASSAY"
JOIN dta WHERE nvp.merge_id = dta.task_assay_cd
AND dta.active_ind = 1
AND dta.end_effective_dt_tm > SYSDATE
JOIN required
JOIN free_text
JOIN multi_select
JOIN first_alpha_single_select
JOIN lookback
JOIN cvr
ORDER BY section_definition, section_description,
input_ref.input_ref_seq
ELSEIF($tab =
"search" AND $search_list = "PowerPlans")
powerplan = pc.description
,pc.type_mean
,pc.version
,pc.pathway_catalog_id
FROM PATHWAY_CATALOG pc
PLAN pc WHERE CNVTUPPER(pc.description) =
PATSTRING(CONCAT("*",$search_term,"*"))
AND pc.type_mean = "CAREPLAN" ;powerplans
AND pc.active_ind = 1
ORDER BY powerplan, pc.version
ELSEIF($tab =
"search" AND $search_list = "Recommendations")
he.expect_name
,he.expect_meaning
,he.expect_id
,he.expect_series_id
FROM HM_EXPECT he
PLAN he WHERE CNVTUPPER(he.expect_name) =
PATSTRING(CONCAT("*",$search_term,"*"))
AND he.end_effective_dt_tm > SYSDATE
AND he.active_ind = 1
ORDER BY he.expect_name
ELSEIF($tab =
"search" AND $search_list = "Resource Groups")
srg.mnemonic
,srg.description
,srg.res_group_id
FROM SCH_RES_GROUP srg
PLAN srg WHERE CNVTUPPER(srg.mnemonic) =
PATSTRING(CONCAT("*",$search_term,"*"))
AND srg.active_ind = 1
AND srg.end_effective_dt_tm > SYSDATE
AND srg.version_dt_tm > SYSDATE
ORDER BY srg.mnemonic_key
ELSEIF($tab =
"search" AND $search_list = "Schedulable Resources")
resource_type = EVALUATE(sr.res_type_flag,
1, "1-General",
2, "2-Personnel",
3, "3-Service Resource",
4, "4-Supply Chain",
5, "5-Other",
"Unknown")
,cv.display
,cv.description
,sr.mnemonic
,last_updated = sr.updt_dt_tm
,updated_by = sr_updt.name_full_formatted
,sr.resource_cd
,sr.person_id
FROM CODE_VALUE cv
,SCH_RESOURCE sr
,PRSNL sr_updt
PLAN cv WHERE cv.active_ind = 1
AND cv.end_effective_dt_tm > SYSDATE
AND cv.code_set = 14231 ;scheduling resources
AND (CNVTUPPER(cv.display) =
PATSTRING(CONCAT("*",$search_term,"*"))
OR CNVTUPPER(cv.description) =
PATSTRING(CONCAT("*",$search_term,"*")))
JOIN sr WHERE cv.code_value = sr.resource_cd
;AND sr.res_type_flag != 2 ;anything but "personnel"
resources ;removed 1/2/24
AND sr.active_ind = 1
AND sr.end_effective_dt_tm > SYSDATE
JOIN sr_updt WHERE sr.updt_id = sr_updt.person_id
ORDER BY cv.display_key
ELSEIF($tab =
"search" AND $search_list = "Scheduling Request Lists")
so.mnemonic
,queue_id = so.sch_object_id
FROM SCH_OBJECT so
PLAN so WHERE CNVTUPPER(so.mnemonic) =
PATSTRING(CONCAT("*",$search_term,"*"))
AND so.object_type_cd = 625790 ;scheduling request list
AND so.end_effective_dt_tm > SYSDATE
AND so.version_dt_tm > SYSDATE
AND so.active_ind = 1
ORDER BY CNVTUPPER(so.mnemonic)
ELSEIF($tab =
"search" AND $search_list = "Service Resources")
cv.code_set
,CODE_SET_NAME = SUBSTRING(1,40,replace_CRLF(cs.display))
,hierarchy_meaning =
IF(cv.cdf_meaning = "INSTITUTION") "1 -
Institution"
ELSEIF(cv.cdf_meaning = "DEPARTMENT") "2 -
Department"
ELSEIF(cv.cdf_meaning IN ("SECTION", "SURGAREA"))
"3 - Section/Surg Area"
ELSEIF(cv.cdf_meaning IN ("SUBSECTION",
"SURGSTAGE")) "4 - Subsection/Surg Staging"
ELSEIF(cv.cdf_meaning IN (
"CARDEXAMROOM", "BENCH", "INSTRUMENT",
"PHARMDEVICE", "PHARMWS", "RADEXAMROOM",
"SURGOP")
) "5 - Bench/Device/WS/Surg Op"
ELSE BUILD("OTHER-", cv.cdf_meaning)
ENDIF
,facility_org_id = sr.organization_id
,service_resource_cd = cv.code_value
,display = SUBSTRING(1,40,replace_CRLF(cv.display))
,description = SUBSTRING(1,100,replace_CRLF(cv.description))
,definition = SUBSTRING(1,300,replace_CRLF(cv.definition))
,cv.collation_seq
,cv.cki
,cv.concept_cki
,cv.active_dt_tm "MM/DD/YYYY;;D"
,cv.updt_dt_tm "MM/DD/YYYY;;D"
FROM CODE_VALUE cv
,CODE_VALUE_SET cs
,SERVICE_RESOURCE sr
PLAN cv        WHERE
cv.active_ind = 1
AND cv.end_effective_dt_tm > SYSDATE
AND cv.code_set = 221 ;service resource
AND (CNVTUPPER(cv.display) =
PATSTRING(CONCAT("*",$search_term,"*"))
OR CNVTUPPER(cv.description) =
PATSTRING(CONCAT("*",$search_term,"*")))
JOIN cs WHERE cv.code_set = cs.code_set
JOIN sr WHERE cv.code_value = sr.service_resource_cd
ORDER BY hierarchy_meaning, cv.display
ELSEIF($tab =
"search" AND $search_list = "Tables (by field)")
table_name = SUBSTRING(1,100,replace_crlf(dcd.table_name))
,field_name = SUBSTRING(1,100,replace_crlf(dcd.column_name))
,field_description = SUBSTRING(1,100,replace_crlf(dcd.description))
,field_definition = SUBSTRING(1,300,replace_crlf(dcd.definition))
,primary_key_ind =
IF( TRIM(dcd.root_entity_name) = TRIM(dcd.table_name)
AND TRIM(dcd.root_entity_attr) = TRIM(dcd.column_name)) "Y"
ELSE " "
ENDIF
,dtc.data_type
,dtc.data_length
,dcd.class_name
,join_to_table = dcd.root_entity_name
,join_to_field = dcd.root_entity_attr
,dcd.code_set
,dtc.nullable
,default_value = SUBSTRING(1,100,replace_crlf(dtc.data_default))
,dtc.num_distinct
,dtc.num_nulls
,dtc.density
,field_seq = dtc.column_id
,dtc.last_analyzed
FROM DM_COLUMNS_DOC dcd
,DM_TABLES_DOC dtd
,DBA_TAB_COLS dtc
PLAN dcd WHERE CNVTUPPER(dcd.column_name) =
PATSTRING(CONCAT("*",$search_term,"*"))
JOIN dtd WHERE dcd.table_name = dtd.table_name
AND dtd.drop_ind != 1
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
JOIN dtc WHERE dcd.table_name = dtc.table_name
AND dcd.column_name =
dtc.column_name
ORDER BY dcd.table_name, dcd.column_name
ELSEIF($tab =
"search" AND $search_list = "Tables (by table)")
dtd.table_name
,table_description = SUBSTRING(1,100,replace_crlf(dtd.description))
,table_definition = SUBSTRING(1,300,replace_crlf(dtd.definition))
,model = dtd.data_model_section
,a.num_rows
,a.last_analyzed
,dtd.owner
FROM DM_TABLES_DOC dtd
,ALL_TABLES a
PLAN dtd WHERE CNVTUPPER(dtd.table_name) =
PATSTRING(CONCAT("*",$search_term,"*"))
AND dtd.drop_ind != 1
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
ORDER BY dtd.table_name
ENDIF
INTO $OUTDEV
; Runs by default, or if "Code Values" is selected
ERROR = "Invalid prompt selections."
WITH
NOCOUNTER, SEPARATOR=" ", FORMAT, TIME=600, CHECK
END
GO
