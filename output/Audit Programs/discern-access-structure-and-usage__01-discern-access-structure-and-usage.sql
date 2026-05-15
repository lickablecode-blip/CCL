/*
 * Source page  : Discern Access, Structure, and Usage
 * Source file  : output/discern-access-structure-and-usage.md
 * Anchor       : (top of page)
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 1919
 *
 * Context (preceding paragraph):
 *   Exported: 5/22/25
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

drop program
dev_rpt_discern_audits go
create
program dev_rpt_discern_audits
/******************************************************************************
 REPORT NAME:
        Discern Audit (Access,
Structure, Usage)
 PROGRAM:                dev_rpt_discern_audits.prg
 DEVELOPER:        David Alt
(david.a.alt2.mil@health.mil)
 PUBLISHED:        2022
 SNAPSHOT:                12/26/2024
 LOGICAL
PATH:        cust_script:
 NODE:                        <default>
 PURPOSE/DESCRIPTION:
 This information will be used to guide
Discern maintenance by the reports
 teams of both agencies. Access reports are
used to ensure there is adequate
 security coverage and that data are neither
exposed nor restricted
 unintentionally. Structure reports are used
to evaluate consistency with
 naming conventions and content. Usage reports
guide convergence and archival
 efforts, as well as triage what reports are
most likely to benefit from
 detailed training sheets.
 TARGET AUDIENCE:
          Users involved in
Discern administration and reports
governance
MOD        DATE                DEVELOPER        COMMENT
---        --/--/--        ---------        ----------------------------
001        10/16/22        David
Alt        initial version
002        10/05/23        David
Alt        added email to usage by
personnel reports
003 10/10/23        David
Alt        added General->Access
(user-specific)
004        11/07/23        David
Alt        fixed missing data cube
issue
005 12/12/23        David
Alt        increased timeout to 600
seconds
006        03/11/24        David
Alt        added agency, email,
updated_by to Group members report
007        12/26/24        David
Alt        fixed filters excluding
records from security group listings
### TODO ###
- error
checking for prompt lists (e.g. by folder, but no folder selected)
- add
user-specific access (total, folder-level, report-level)
******************************************************************************/
prompt
"Output" = "MINE" ;* Enter or select the printer or
file name to send this report to.
, "Report Type" = "general"
, "" = ""
, "" = ""
, "" = ""
, "" = ""
, "" = ""
, "" = ""
, "" = 0
, "" = 0
, "" = 0
, "" = 0
;<<hidden>>"" = "OWNERGROUP"
, "Start" = "CURDATE"
, "End" = "CURDATE"
with OUTDEV,
rpt_type, rpt_general, rpt_by_folder, rpt_by_report,
rpt_by_position, rpt_by_group, info, by_folder, by_report, by_position,
by_group, start_date,
end_date
/**************************************************************
; Global
Declarations
**************************************************************/
declare idx =
i4 ;index variable for EXPAND()
;declare pdx
= i4 ;position variable for LOCATEVAL()
declare
READ_PRIV = f8 with protect, constant(19176506)
declare
CREATE_PRIV = f8 with protect, constant(19176482)
declare
DELETE_PRIV = f8 with protect, constant(19176516)
declare
COPY_PRIV = f8 with protect, constant(19176510)
declare
WRITE_PRIV = f8 with protect, constant(19176480)
declare
ADMIN_PRIV = f8 with protect, constant(19176494)
declare
EXTEND_PRIV = f8 with protect, constant(19176492)
declare
SCHEDULE_PRIV = f8 with protect, constant(19176490)
declare
REPORT_ON_PRIV = f8 with protect, constant(19176478)
declare YES =
c3 with protect, constant("yes")
declare
YES_GLOBAL = c19 with protect, constant("yes (global access)")
declare NO =
c2 with protect, constant("no")
declare
NO_NOSEC = c16 with protect, constant("no (no security)")
/**************************************************************
; Record
Structures
**************************************************************/
free record
fr
record fr (
1 all_rpt_cnt = i4 ;nbr reports in record
1 fld[*]
2 folder_id = f8
2 parent_folder_id = f8
2 root_ind = i2
2 folder = c100
2 path = c200
2 root = c40
2 rpt_cnt = i4 ;nbr reports in folder
2 root_cnt = i4 ;nbr reports in root folder
2 rpt[*]
3 report_id = f8
3 report_uuid = c200
3 report_root = c200
3 report_path = c200
3 report_title = c100
3 report_name = c100
3 object_name = c40
3 report_desc = c1000
3 report_type = c40
3 report_owner_group = c40
3 cerner_standard = i2
) with
protect ;folder-report
free record
fsec
record fsec (
 1 list [*]
 2 type = c10
;POSITION/SECGROUP/OWNERGROUP
 2 display = c40
 2 code_value = f8
 2 active_status = c16
 2 security_ind = c3
 2 discern_access = c3
 2 discern_admin = c3
 2 explorer_menu = c3
 2 schedule_mgr = c3
 2 fld_gread = c3
 2 fld_gdelete = c3
 2 fld_gcopy = c3
 2 fld_gadd_remove_rpts = c3
 2 fld_gadd_remove_ccl = c3
 2 fld_gcreate = c3
 2 fld [*]
 3 folder_id = f8
 3 folder = c100
 3 path = c200
 3 fld_read = c20
 3 fld_delete = c20
 3 fld_copy = c20
 3 fld_add_remove_rpts = c20
 3 fld_add_remove_ccl = c20
 3 fld_create = c20
) with
protect ;folder security
free record
rsec
record rsec (
 1 list [*]
 2 type = c10
;POSITION/SECGROUP/OWNERGROUP
 2 display = c40
 2 code_value = f8
 2 active_status = c16
 2 security_ind = c3
2 rpt_grun = c3
2 rpt_gmodify = c3
2 rpt_gdelete = c3
2 rpt_gcopy = c3
2 rpt_gextend = c3
2 rpt_gschedule = c3
 2 rpt [*]
 3 report_id = f8
 3 report_title = c100
 3 report_path = c200
 3 rpt_run = c20
 3 rpt_modify = c20
 3 rpt_delete = c20
 3 rpt_copy = c20
 3 rpt_extend = c20
 3 rpt_schedule = c20
) with
protect ;report security
/**************************************************************
; Subroutines
**************************************************************/
; Removes all
line feeds/carriage returns/tabs from a string
subroutine
(replace_CRLF(input = vc) = vc)
declare output = vc with protect, noconstant("")
declare CRLF = vc with protect, constant(concat(char(13), char(10)))
declare CR = vc with protect, constant(char(13)) ;carriage return
declare LF = vc with protect, constant(char(10)) ;line feed
declare HT = vc with protect, constant(char(9)) ;horizontal tab
declare REPLACEMENT = vc with constant(" ")
; remove carriage return+line feed at the beginning and end of the
string
set output = trim(input, 3) ; option 3 -> Trim leading and trailing
spaces
; replace carriage return+line feed inside string
set output = replace(output, CRLF, REPLACEMENT)
set output = replace(output, CR, REPLACEMENT)
set output = replace(output, LF, REPLACEMENT)
set output = replace(output, HT, REPLACEMENT)
return (output)
end
;############################ STRUCTURE ##############################
subroutine
(init_fr_record(NULL) = NULL)
SET fr->all_rpt_cnt = 0
 CALL build_folder_list(NULL)
 CALL build_folder_data(NULL)
 CALL build_root_counts(NULL)
end
;init_fr_record
subroutine
(build_folder_list(NULL) = NULL)
 SELECT INTO "NL:"
 FROM DA_FOLDER df
 PLAN df WHERE df.public_ind = 1
 ORDER BY df.da_folder_id
 HEAD REPORT
 i = 0
 DETAIL
 i += 1
 CALL ALTERLIST(fr->fld, i)
 fr->fld[i].folder_id =
df.da_folder_id
 fr->fld[i].parent_folder_id =
df.parent_folder_id
 fr->fld[i].root_ind =
 IF(df.parent_folder_id = 0) 1
 ELSE 0
 ENDIF
 fr->fld[i].folder =
TRIM(df.da_folder_name, 3)
 fr->fld[i].path = ""
 WITH NULLREPORT
end
;build_folder_list
subroutine
(build_folder_data(NULL) = NULL)
 declare fld_cnt = i4 with protect,
constant(size(fr->fld, 5))
 declare rpt_cnt = i4 with protect,
noconstant(0)
 declare i = i4 with protect, noconstant(0)
declare pos = i4 with protect, noconstant(0)
declare idx = i4 with protect, noconstant(0)
 ;get path and root for each folder
 for (i = 1 to fld_cnt)
 set fr->fld[i].path =
get_path(fr->fld[i].folder_id)
 set fr->fld[i].root =
get_root(fr->fld[i].folder_id)
 endfor
 ;get reports for each folder
 SELECT INTO "NL:"
 FROM DA_REPORT dr
 ,DA_FOLDER_REPORT_RELTN dfrr
 ,DA_FOLDER df ;this join removes
unpublished reports
 PLAN dr WHERE dr.active_ind = 1
 JOIN dfrr WHERE dr.da_report_id =
dfrr.da_report_id
 JOIN df WHERE dfrr.da_folder_id =
df.da_folder_id
 AND df.public_ind = 1
 ORDER BY df.da_folder_id, dr.da_report_id
 HEAD df.da_folder_id ;folder-level
 rpt_cnt = 0
 ;get the folder index
 pos = LOCATEVAL(idx, 1, fld_cnt,
df.da_folder_id, fr->fld[idx].folder_id)
 DETAIL ;report-level
 fr->all_rpt_cnt += 1 ;increment the
report counter
 rpt_cnt += 1
 CALL ALTERLIST(fr->fld[pos].rpt,
rpt_cnt)
 fr->fld[pos].rpt[rpt_cnt].report_id
= dr.da_report_id
 fr->fld[pos].rpt[rpt_cnt].report_uuid = dr.report_uuid
 fr->fld[pos].rpt[rpt_cnt].report_root = get_root(dfrr.da_folder_id)
 fr->fld[pos].rpt[rpt_cnt].report_path = get_path(dfrr.da_folder_id)
 fr->fld[pos].rpt[rpt_cnt].report_title =
IF(dr.report_type_cd =
19176835        AND
TEXTLEN(TRIM(dfrr.report_alias_name)) > 0) dfrr.report_alias_name
ELSEIF(dr.report_type_cd =
19176835        AND
TEXTLEN(TRIM(dfrr.report_alias_name)) = 0) dr.report_name
ELSE dr.report_name
ENDIF
 fr->fld[pos].rpt[rpt_cnt].report_name = dr.report_name
 fr->fld[pos].rpt[rpt_cnt].object_name =
TRIM(CNVTUPPER(SUBSTRING(1,40,dr.report_name)))
 fr->fld[pos].rpt[rpt_cnt].report_desc =
replace_crlf(TRIM(dr.short_desc, 3))
 fr->fld[pos].rpt[rpt_cnt].report_type =
UAR_GET_CODE_DISPLAY(dr.report_type_cd)
 fr->fld[pos].rpt[rpt_cnt].report_owner_group =
UAR_GET_CODE_DISPLAY(dr.owner_group_cd)
 fr->fld[pos].rpt[rpt_cnt].cerner_standard = dr.core_ind
 FOOT df.da_folder_id ;set the report count
 fr->fld[pos].rpt_cnt = rpt_cnt
 WITH NULLREPORT
 ;Now get the data cubes
 SELECT INTO "NL:"
 FROM DA_QUERY dq
,DA_FOLDER_QUERY_RELTN dfqr
,DA_FOLDER df ;this join removes unpublished reports
PLAN dq WHERE dq.active_ind = 1
AND dq.public_ind = 1
JOIN dfqr WHERE dq.da_query_id = dfqr.da_query_id
JOIN df WHERE dfqr.da_folder_id = df.da_folder_id
AND df.public_ind = 1
ORDER BY df.da_folder_id, dq.da_query_id
 HEAD df.da_folder_id ;folder-level
 pos = LOCATEVAL(idx, 1, fld_cnt,
df.da_folder_id, fr->fld[idx].folder_id) ;get the folder index
 rpt_cnt = fr->fld[pos].rpt_cnt ;set
rpt_cnt to existing folder rpt_cnt
 DETAIL ;report-level
 fr->all_rpt_cnt += 1 ;increment the
report counter
 rpt_cnt += 1
 CALL ALTERLIST(fr->fld[pos].rpt,
rpt_cnt)
 fr->fld[pos].rpt[rpt_cnt].report_id
= dq.da_query_id
 fr->fld[pos].rpt[rpt_cnt].report_uuid = dq.query_uuid
 fr->fld[pos].rpt[rpt_cnt].report_root = get_root(dfqr.da_folder_id)
 fr->fld[pos].rpt[rpt_cnt].report_path = get_path(dfqr.da_folder_id)
 fr->fld[pos].rpt[rpt_cnt].report_title =
         IF(TEXTLEN(TRIM(dfqr.query_alias_name))
> 0) dfqr.query_alias_name
         ELSE dq.query_name
ENDIF
 fr->fld[pos].rpt[rpt_cnt].report_name = dq.query_name
 fr->fld[pos].rpt[rpt_cnt].object_name =
TRIM(CNVTUPPER(SUBSTRING(1,40,dq.query_name)))
 fr->fld[pos].rpt[rpt_cnt].report_desc =
replace_crlf(TRIM(dq.query_desc, 3))
 fr->fld[pos].rpt[rpt_cnt].report_type =
UAR_GET_CODE_DISPLAY(dq.query_type_cd)
 fr->fld[pos].rpt[rpt_cnt].report_owner_group =
UAR_GET_CODE_DISPLAY(dq.owner_group_cd)
 fr->fld[pos].rpt[rpt_cnt].cerner_standard = dq.core_ind
 FOOT df.da_folder_id ;set the report count
 fr->fld[pos].rpt_cnt = rpt_cnt
 WITH
NULLREPORT
end
;build_folder_data
subroutine
(build_root_counts(NULL) = NULL)
declare fld_cnt = i4 with protect, constant(size(fr->fld,5))
declare pos = i4 with protect, noconstant(0)
declare idx = i4 with protect, noconstant(0) ;locateval index
declare final_root_cnt = i4 with protect, noconstant(0)
declare current_root = vc with protect, noconstant("")
SELECT INTO "nl:"
root = fr->fld[d.seq].root
,cnt = fr->fld[d.seq].rpt_cnt
FROM (DUMMYT d WITH seq=size(fr->fld, 5))
PLAN d
ORDER BY root
FOOT root
for (i = 1 to fld_cnt)
if (fr->fld[i].root_ind = 1 AND fr->fld[i].root = root)
fr->fld[i].root_cnt = SUM(cnt)
endif
endfor
; Now iterate through the folders; if a root folder, store the count,
and place it in all the subfolders
FOOT report
for (i = 1 to fld_cnt)
current_root = fr->fld[i].root
if(fr->fld[i].root_ind = 0)
fr->fld[i].root_cnt =
fr->fld[LOCATEVAL(idx, 1, fld_cnt,1,
fr->fld[idx].root_ind,
current_root,fr->fld[idx].root)].root_cnt
endif
endfor
WITH NULLREPORT
end
;build_root_counts
; Retrieve
the full path for a given folder_id
subroutine
(get_path(da_folder_id = f8) = vc)
declare fld_cnt = i4 with protect, constant(size(fr->fld, 5))
declare pos = i4 with protect, noconstant(0)
declare idx = i4 with protect, noconstant(0)
declare folder_id = f8 with protect, noconstant(0)
declare parent_id = f8 with protect, noconstant(0)
declare is_root = i2 with protect, noconstant(0)
declare path = vc with protect, noconstant("")
set folder_id = da_folder_id
set parent_id = fr->fld[LOCATEVAL(pos, 1, fld_cnt, folder_id,
fr->fld[pos].folder_id)].parent_folder_id
set is_root = fr->fld[LOCATEVAL(pos, 1, fld_cnt, folder_id,
fr->fld[pos].folder_id)].root_ind
set path = fr->fld[LOCATEVAL(pos, 1, fld_cnt, folder_id,
fr->fld[pos].folder_id)].folder
while (is_root = 0) ;not the parent folder
if (parent_id = 0)
set is_root = 1 ;reached the parent, time to stop
else
;find the index of the parent folder
set pos = LOCATEVAL(idx, 1, fld_cnt, parent_id,
fr->fld[idx].folder_id)
if (pos > 0) ;we located the parent folder in the record
set path = BUILD(fr->fld[pos].folder, "/", path)
set parent_id = fr->fld[pos].parent_folder_id ;update parent_id to
the parent's parent folder_id
endif
endif
endwhile
return (path)
end
;get_folder_path
; Retrieve
the root folder for a given folder_id
subroutine
(get_root(da_folder_id = f8) = vc)
declare fld_cnt = i4 with protect, constant(size(fr->fld, 5))
declare pos = i4 with protect, noconstant(0)
declare idx = i4 with protect, noconstant(0)
declare folder_id = f8 with protect, noconstant(0)
declare parent_id = f8 with protect, noconstant(0)
declare is_root = i2 with protect, noconstant(0)
declare root = vc with protect, noconstant("")
set folder_id = da_folder_id
set parent_id = fr->fld[LOCATEVAL(pos, 1, fld_cnt, folder_id,
fr->fld[pos].folder_id)].parent_folder_id
set is_root = fr->fld[LOCATEVAL(pos, 1, fld_cnt, folder_id,
fr->fld[pos].folder_id)].root_ind
set root = fr->fld[LOCATEVAL(pos, 1, fld_cnt, folder_id,
fr->fld[pos].folder_id)].folder
while (is_root = 0) ;not the parent folder
if (parent_id = 0)
set is_root = 1 ;reached the parent, time to stop
else
;find the index of the parent folder
set pos = LOCATEVAL(idx, 1, fld_cnt, parent_id,
fr->fld[idx].folder_id)
if (pos > 0) ;we located the parent folder in the record
set root = fr->fld[pos].folder
set parent_id = fr->fld[pos].parent_folder_id ;update parent_id to
the parent's parent folder_id
endif
endif
endwhile
return (root)
end
;get_folder_root
;############################ ACCESS & SECURITY ##############################
subroutine
(init_fsec_records(NULL) = NULL)
CALL build_fsec_global(NULL)
CALL build_fsec_folder_lists(NULL)
CALL build_fsec_folder_settings(NULL)
end
;init_sec_record
subroutine
(build_fsec_global(NULL) = NULL)
SELECT INTO "NL:"
FROM CODE_VALUE grp
,(LEFT JOIN (SELECT dgs.security_group_cd, row_cnt = COUNT(*)
 FROM DA_GROUP_SECURITY dgs
 WHERE dgs.active_ind = 1
 GROUP BY dgs.security_group_cd
 ORDER BY dgs.security_group_cd
 WITH
SQLTYPE("f8","i4")
 ) sec_cnt
ON grp.code_value = sec_cnt.security_group_cd)
; APPLICATION ACCESS
,(LEFT JOIN DA_GROUP_SECURITY da2_access
ON grp.code_value = da2_access.security_group_cd
AND da2_access.parent_entity_name = "ADMINISTRATOR"
AND da2_access.parent_entity_id = 0
AND da2_access.security_assignment_cd = REPORT_ON_PRIV
AND da2_access.active_ind =
1)
,(LEFT JOIN DA_GROUP_SECURITY explorer
ON grp.code_value = explorer.security_group_cd
AND explorer.parent_entity_name = "ADMINISTRATOR"
AND explorer.parent_entity_id = 0
AND explorer.security_assignment_cd = READ_PRIV
AND explorer.active_ind = 1)
,(LEFT JOIN DA_GROUP_SECURITY da2_admin
ON grp.code_value = da2_admin.security_group_cd
AND da2_admin.parent_entity_name = "ADMINISTRATOR"
AND da2_admin.parent_entity_id = 0
AND da2_admin.security_assignment_cd = ADMIN_PRIV
AND da2_admin.active_ind = 1)
,(LEFT JOIN DA_GROUP_SECURITY schedule
ON grp.code_value = schedule.security_group_cd
AND schedule.parent_entity_name = "DA_BATCH_SCHED"
AND schedule.parent_entity_id = 0
AND schedule.security_assignment_cd = SCHEDULE_PRIV
AND schedule.active_ind =
1)
; GLOBAL FOLDER SECURITY
,(LEFT JOIN DA_GROUP_SECURITY folder_read
ON grp.code_value = folder_read.security_group_cd
AND folder_read.parent_entity_name = "DA_FOLDER"
AND folder_read.parent_entity_id = 0
AND folder_read.security_assignment_cd = READ_PRIV
AND folder_read.active_ind = 1)
,(LEFT JOIN DA_GROUP_SECURITY folder_create
ON grp.code_value = folder_create.security_group_cd
AND folder_create.parent_entity_name = "DA_FOLDER"
AND folder_create.parent_entity_id = 0
AND folder_create.security_assignment_cd = CREATE_PRIV
AND folder_create.active_ind = 1)
,(LEFT JOIN DA_GROUP_SECURITY folder_delete
ON grp.code_value = folder_delete.security_group_cd
AND folder_delete.parent_entity_name = "DA_FOLDER"
AND folder_delete.parent_entity_id = 0
AND folder_delete.security_assignment_cd = DELETE_PRIV
AND folder_delete.active_ind =
1)
,(LEFT JOIN DA_GROUP_SECURITY folder_copy
ON grp.code_value = folder_copy.security_group_cd
AND folder_copy.parent_entity_name = "DA_FOLDER"
AND folder_copy.parent_entity_id = 0
AND folder_copy.security_assignment_cd = COPY_PRIV
AND folder_copy.active_ind = 1)
,(LEFT JOIN DA_GROUP_SECURITY add_rpt
ON grp.code_value = add_rpt.security_group_cd
AND add_rpt.parent_entity_name = "DA_FOLDER"
AND add_rpt.parent_entity_id = 0
AND add_rpt.security_assignment_cd = WRITE_PRIV
AND add_rpt.active_ind =
1)
,(LEFT JOIN DA_GROUP_SECURITY add_ccl
ON grp.code_value = add_ccl.security_group_cd
AND add_ccl.parent_entity_name = "DA_FOLDER"
AND add_ccl.parent_entity_id = 0
AND add_ccl.security_assignment_cd = ADMIN_PRIV
AND add_ccl.active_ind = 1)
PLAN grp WHERE grp.code_set IN (88, 4002360)
AND grp.active_ind = 1
JOIN sec_cnt
JOIN da2_admin
JOIN da2_access
JOIN explorer
JOIN folder_read
JOIN folder_create
JOIN folder_delete
JOIN folder_copy
JOIN add_rpt
JOIN add_ccl
JOIN schedule
ORDER BY grp.code_value
HEAD REPORT
i = 0
DETAIL ;position/group
i += 1
;populate fsec record
CALL ALTERLIST(fsec->list, i)
IF(grp.code_set = 88) fsec->list[i].type = "POSITION"
ELSE fsec->list[i].type = grp.cdf_meaning
ENDIF
fsec->list[i].display = grp.display
fsec->list[i].code_value = grp.code_value
fsec->list[i].active_status =
IF(grp.active_ind = 0) "inactive"
ELSEIF(grp.active_ind = 1 AND grp.end_effective_dt_tm > SYSDATE)
"active"
ELSEIF(grp.active_ind = 1 AND NOT grp.end_effective_dt_tm > SYSDATE)
"active - expired"
ELSE "unknown"
ENDIF
fsec->list[i].security_ind = IF(sec_cnt.row_cnt > 0) YES ELSE NO
ENDIF
fsec->list[i].discern_access = IF(da2_access.security_assignment_cd
> 0) YES ELSE NO ENDIF
fsec->list[i].discern_admin = IF(da2_admin.security_assignment_cd
> 0) YES ELSE NO ENDIF
fsec->list[i].explorer_menu = IF(explorer.security_assignment_cd
> 0) YES ELSE NO ENDIF
fsec->list[i].schedule_mgr = IF(schedule.security_assignment_cd >
0) YES ELSE NO ENDIF
;global folder settings, stored at the group level
fsec->list[i].fld_gread = IF(folder_read.security_assignment_cd >
0) YES_GLOBAL ELSE NO ENDIF
fsec->list[i].fld_gdelete = IF(folder_delete.security_assignment_cd
> 0) YES_GLOBAL ELSE NO ENDIF
fsec->list[i].fld_gcopy = IF(folder_copy.security_assignment_cd >
0) YES_GLOBAL ELSE NO ENDIF
fsec->list[i].fld_gadd_remove_rpts =
IF(add_rpt.security_assignment_cd > 0) YES_GLOBAL ELSE NO ENDIF
fsec->list[i].fld_gadd_remove_ccl =
IF(add_ccl.security_assignment_cd > 0) YES_GLOBAL ELSE NO ENDIF
fsec->list[i].fld_gcreate = IF(folder_create.security_assignment_cd
> 0) YES_GLOBAL ELSE NO ENDIF
;create a dummy folder item for the global settings, stored at the
folder level
CALL ALTERLIST(fsec->list[i].fld, 1)
fsec->list[i].fld[1].folder_id = 0.0
fsec->list[i].fld[1].folder = "< Global Folder Settings
>"
fsec->list[i].fld[1].path = ""
fsec->list[i].fld[1].fld_read =
IF(folder_read.security_assignment_cd > 0) YES_GLOBAL ELSE NO ENDIF
fsec->list[i].fld[1].fld_delete =
IF(folder_delete.security_assignment_cd > 0) YES_GLOBAL ELSE NO ENDIF
fsec->list[i].fld[1].fld_copy =
IF(folder_copy.security_assignment_cd > 0) YES_GLOBAL ELSE NO ENDIF
fsec->list[i].fld[1].fld_add_remove_rpts =
IF(add_rpt.security_assignment_cd > 0) YES_GLOBAL ELSE NO ENDIF
fsec->list[i].fld[1].fld_add_remove_ccl =
IF(add_ccl.security_assignment_cd > 0) YES_GLOBAL ELSE NO ENDIF
fsec->list[i].fld[1].fld_create =
IF(folder_create.security_assignment_cd > 0) YES_GLOBAL ELSE NO ENDIF
WITH NULLREPORT
end
;build_fsec_global
subroutine
(build_fsec_folder_lists(NULL) = NULL)
;add each folder from fr to fsec, starting at index 2, b/c 1 holds
global access settings
declare grp_cnt = i4 with noconstant(size(fsec->list, 5))
declare fld_cnt = i4 with noconstant(size(fr->fld, 5))
declare grp = i4
declare fld = i4
declare offset = i4
FOR (grp = 1 TO grp_cnt)
CALL ALTERLIST(fsec->list[grp].fld, fld_cnt+1)
FOR (fld = 1 TO fld_cnt)
SET offset = fld + 1
SET fsec->list[grp].fld[offset].folder_id =
fr->fld[fld].folder_id
SET fsec->list[grp].fld[offset].folder = fr->fld[fld].folder
SET fsec->list[grp].fld[offset].path = fr->fld[fld].path
;If no security, default to NO_NOSEC
IF(fsec->list[grp].security_ind = NO)
SET fsec->list[grp].fld[offset].fld_read = NO_NOSEC
SET fsec->list[grp].fld[offset].fld_delete = NO_NOSEC
SET fsec->list[grp].fld[offset].fld_copy = NO_NOSEC
SET fsec->list[grp].fld[offset].fld_add_remove_rpts = NO_NOSEC
SET fsec->list[grp].fld[offset].fld_add_remove_ccl = NO_NOSEC
SET fsec->list[grp].fld[offset].fld_create = NO_NOSEC
ELSE ;has security
;Global read
IF(fsec->list[grp].fld_gread = YES)
SET fsec->list[grp].fld[offset].fld_read = YES_GLOBAL
ELSE
SET fsec->list[grp].fld[offset].fld_read = NO ;default to no
ENDIF
;Global delete
IF(fsec->list[grp].fld_gdelete = YES)
SET fsec->list[grp].fld[offset].fld_delete = YES_GLOBAL
ELSE
SET fsec->list[grp].fld[offset].fld_delete = NO ;default to no
ENDIF
;Global copy
IF(fsec->list[grp].fld_gcopy = YES)
SET fsec->list[grp].fld[offset].fld_copy = YES_GLOBAL
ELSE
SET fsec->list[grp].fld[offset].fld_copy = NO ;default to no
ENDIF
;Global add/remove reports
IF(fsec->list[grp].fld_gadd_remove_rpts = YES)
SET fsec->list[grp].fld[offset].fld_add_remove_rpts = YES_GLOBAL
ELSE
SET fsec->list[grp].fld[offset].fld_add_remove_rpts = NO ;default to
no
ENDIF
;Global add/remove CCL
IF(fsec->list[grp].fld_gadd_remove_ccl = YES)
SET fsec->list[grp].fld[offset].fld_add_remove_ccl = YES_GLOBAL
ELSE
SET fsec->list[grp].fld[offset].fld_add_remove_ccl = NO ;default to
no
ENDIF
;Global create
IF(fsec->list[grp].fld_gcreate = YES)
SET fsec->list[grp].fld[offset].fld_create = YES_GLOBAL
ELSE
SET fsec->list[grp].fld[offset].fld_create = NO ;default to no
ENDIF
ENDIF
ENDFOR
ENDFOR
end
;build_fsec_folder_lists
subroutine
(build_fsec_folder_settings(NULL) = NULL)
declare gnum = i4 with noconstant(0)
declare gpos = i4 with noconstant(0)
declare fnum = i4 with noconstant(0)
declare fpos = i4 with noconstant(0)
;read
SELECT INTO "NL:"
FROM DA_GROUP_SECURITY dgs
,CODE_VALUE grp
PLAN dgs WHERE dgs.active_ind = 1
AND dgs.parent_entity_name = "DA_FOLDER"
AND dgs.parent_entity_id > 0
AND dgs.security_assignment_cd = READ_PRIV
JOIN grp WHERE dgs.security_group_cd = grp.code_value
AND grp.active_ind = 1
ORDER BY dgs.security_group_cd, dgs.parent_entity_id
HEAD dgs.security_group_cd ;position/secgroup
gpos = LOCATEVAL(gnum, 1, size(fsec->list, 5),
 dgs.security_group_cd,
fsec->list[gnum].code_value)
HEAD dgs.parent_entity_id ;folder
fpos = LOCATEVAL(fnum, 1, size(fsec->list[gpos].fld, 5),
 dgs.parent_entity_id,
fsec->list[gpos].fld[fnum].folder_id)
IF(fsec->list[gpos].fld_gread = YES)
fsec->list[gpos].fld[fpos].fld_read = YES_GLOBAL
ELSE fsec->list[gpos].fld[fpos].fld_read = YES
ENDIF ;if not global and no security setting found, remains defaulted
to "no"
WITH NULLREPORT
;delete
SELECT INTO "NL:"
FROM DA_GROUP_SECURITY dgs
,CODE_VALUE grp
PLAN dgs WHERE dgs.active_ind = 1
AND dgs.parent_entity_name = "DA_FOLDER"
AND dgs.parent_entity_id > 0
AND dgs.security_assignment_cd = DELETE_PRIV
JOIN grp WHERE dgs.security_group_cd = grp.code_value
AND grp.active_ind = 1
ORDER BY dgs.security_group_cd, dgs.parent_entity_id
HEAD dgs.security_group_cd ;position/secgroup
gpos = LOCATEVAL(gnum, 1, size(fsec->list, 5),
 dgs.security_group_cd,
fsec->list[gnum].code_value)
HEAD dgs.parent_entity_id ;folder
fpos = LOCATEVAL(fnum, 1, size(fsec->list[gpos].fld, 5),
 dgs.parent_entity_id,
fsec->list[gpos].fld[fnum].folder_id)
IF(fsec->list[gpos].fld_gdelete = YES)
fsec->list[gpos].fld[fpos].fld_delete = YES_GLOBAL
ELSE fsec->list[gpos].fld[fpos].fld_delete = YES
ENDIF ;if not global and no security setting found, remains defaulted
to "no"
WITH NULLREPORT
;copy
SELECT INTO "NL:"
FROM DA_GROUP_SECURITY dgs
,CODE_VALUE grp
PLAN dgs WHERE dgs.active_ind = 1
AND dgs.parent_entity_name = "DA_FOLDER"
AND dgs.parent_entity_id > 0
AND dgs.security_assignment_cd = COPY_PRIV
JOIN grp WHERE dgs.security_group_cd = grp.code_value
AND grp.active_ind = 1
ORDER BY dgs.security_group_cd, dgs.parent_entity_id
HEAD dgs.security_group_cd ;position/secgroup
gpos = LOCATEVAL(gnum, 1, size(fsec->list, 5),
 dgs.security_group_cd,
fsec->list[gnum].code_value)
HEAD dgs.parent_entity_id ;folder
fpos = LOCATEVAL(fnum, 1, size(fsec->list[gpos].fld, 5),
 dgs.parent_entity_id,
fsec->list[gpos].fld[fnum].folder_id)
IF(fsec->list[gpos].fld_gcopy = YES)
fsec->list[gpos].fld[fpos].fld_copy = YES_GLOBAL
ELSE fsec->list[gpos].fld[fpos].fld_copy = YES
ENDIF ;if not global and no security setting found, remains defaulted
to "no"
WITH NULLREPORT
;add/remove reports
SELECT INTO "NL:"
FROM DA_GROUP_SECURITY dgs
,CODE_VALUE grp
PLAN dgs WHERE dgs.active_ind = 1
AND dgs.parent_entity_name = "DA_FOLDER"
AND dgs.parent_entity_id > 0
AND dgs.security_assignment_cd = WRITE_PRIV
JOIN grp WHERE dgs.security_group_cd = grp.code_value
AND grp.active_ind = 1
ORDER BY dgs.security_group_cd, dgs.parent_entity_id
HEAD dgs.security_group_cd ;position/secgroup
gpos = LOCATEVAL(gnum, 1, size(fsec->list, 5),
 dgs.security_group_cd,
fsec->list[gnum].code_value)
HEAD dgs.parent_entity_id ;folder
fpos = LOCATEVAL(fnum, 1, size(fsec->list[gpos].fld, 5),
 dgs.parent_entity_id,
fsec->list[gpos].fld[fnum].folder_id)
IF(fsec->list[gpos].fld_gadd_remove_rpts = YES)
fsec->list[gpos].fld[fpos].fld_add_remove_rpts = YES_GLOBAL
ELSE fsec->list[gpos].fld[fpos].fld_add_remove_rpts = YES
ENDIF ;if not global and no security setting found, remains defaulted
to "no"
WITH NULLREPORT
;add/remove CCL
SELECT INTO "NL:"
FROM DA_GROUP_SECURITY dgs
,CODE_VALUE grp
PLAN dgs WHERE dgs.active_ind = 1
AND dgs.parent_entity_name = "DA_FOLDER"
AND dgs.parent_entity_id > 0
AND dgs.security_assignment_cd = ADMIN_PRIV
JOIN grp WHERE dgs.security_group_cd = grp.code_value
AND grp.active_ind = 1
ORDER BY dgs.security_group_cd, dgs.parent_entity_id
HEAD dgs.security_group_cd ;position/secgroup
gpos = LOCATEVAL(gnum, 1, size(fsec->list, 5),
 dgs.security_group_cd,
fsec->list[gnum].code_value)
HEAD dgs.parent_entity_id ;folder
fpos = LOCATEVAL(fnum, 1, size(fsec->list[gpos].fld, 5),
 dgs.parent_entity_id,
fsec->list[gpos].fld[fnum].folder_id)
IF(fsec->list[gpos].fld_gadd_remove_ccl = YES)
fsec->list[gpos].fld[fpos].fld_add_remove_ccl = YES_GLOBAL
ELSE fsec->list[gpos].fld[fpos].fld_add_remove_ccl = YES
ENDIF ;if not global and no security setting found, remains defaulted
to "no"
WITH NULLREPORT
;create
SELECT INTO "NL:"
FROM DA_GROUP_SECURITY dgs
,CODE_VALUE grp
PLAN dgs WHERE dgs.active_ind = 1
AND dgs.parent_entity_name = "DA_FOLDER"
AND dgs.parent_entity_id > 0
AND dgs.security_assignment_cd = CREATE_PRIV
JOIN grp WHERE dgs.security_group_cd = grp.code_value
AND grp.active_ind = 1
ORDER BY dgs.security_group_cd, dgs.parent_entity_id
HEAD dgs.security_group_cd ;position/secgroup
gpos = LOCATEVAL(gnum, 1, size(fsec->list, 5),
 dgs.security_group_cd,
fsec->list[gnum].code_value)
HEAD dgs.parent_entity_id ;folder
fpos = LOCATEVAL(fnum, 1, size(fsec->list[gpos].fld, 5),
 dgs.parent_entity_id,
fsec->list[gpos].fld[fnum].folder_id)
IF(fsec->list[gpos].fld_gcreate = YES)
fsec->list[gpos].fld[fpos].fld_create = YES_GLOBAL
ELSE fsec->list[gpos].fld[fpos].fld_create = YES
ENDIF ;if not global and no security setting found, remains defaulted
to "no"
WITH NULLREPORT
end
;build_fsec_folder_settings
subroutine
(init_rsec_records(NULL) = NULL)
CALL build_rsec_global(NULL)
CALL build_rsec_report_lists(NULL)
CALL build_rsec_report_settings(NULL)
end
;init_rsec_records
subroutine
(build_rsec_global(NULL) = NULL)
SELECT INTO "NL:"
FROM CODE_VALUE grp
,(LEFT JOIN (SELECT dgs.security_group_cd, row_cnt = COUNT(*)
 FROM DA_GROUP_SECURITY dgs
 WHERE dgs.active_ind = 1
 GROUP BY dgs.security_group_cd
 ORDER BY dgs.security_group_cd
 WITH
SQLTYPE("f8","i4")
 ) sec_cnt
ON grp.code_value = sec_cnt.security_group_cd)
; GLOBAL REPORT SECURITY
,(LEFT JOIN DA_GROUP_SECURITY rpt_read
ON grp.code_value = rpt_read.security_group_cd
AND rpt_read.parent_entity_name = "DA_REPORT"
AND rpt_read.parent_entity_id = 0
AND rpt_read.security_assignment_cd = READ_PRIV
AND rpt_read.active_ind = 1)
,(LEFT JOIN DA_GROUP_SECURITY rpt_write
ON grp.code_value = rpt_write.security_group_cd
AND rpt_write.parent_entity_name = "DA_REPORT"
AND rpt_write.parent_entity_id = 0
AND rpt_write.security_assignment_cd = WRITE_PRIV
AND rpt_write.active_ind =
1)
,(LEFT JOIN DA_GROUP_SECURITY rpt_extend
ON grp.code_value = rpt_extend.security_group_cd
AND rpt_extend.parent_entity_name = "DA_REPORT"
AND rpt_extend.parent_entity_id = 0
AND rpt_extend.security_assignment_cd = EXTEND_PRIV
AND rpt_extend.active_ind = 1)
,(LEFT JOIN DA_GROUP_SECURITY rpt_delete
ON grp.code_value = rpt_delete.security_group_cd
AND rpt_delete.parent_entity_name = "DA_REPORT"
AND rpt_delete.parent_entity_id = 0
AND rpt_delete.security_assignment_cd = DELETE_PRIV
AND rpt_delete.active_ind = 1)
,(LEFT JOIN DA_GROUP_SECURITY rpt_copy
ON grp.code_value = rpt_copy.security_group_cd
AND rpt_copy.parent_entity_name = "DA_REPORT"
AND rpt_copy.parent_entity_id = 0
AND rpt_copy.security_assignment_cd = COPY_PRIV
AND rpt_copy.active_ind = 1)
,(LEFT JOIN DA_GROUP_SECURITY rpt_schedule
ON grp.code_value = rpt_schedule.security_group_cd
AND rpt_schedule.parent_entity_name = "DA_REPORT"
AND rpt_schedule.parent_entity_id = 0
AND rpt_schedule.security_assignment_cd = SCHEDULE_PRIV
AND rpt_schedule.active_ind =
1)
PLAN grp WHERE grp.code_set IN (88, 4002360)
AND grp.active_ind = 1
JOIN sec_cnt
JOIN rpt_read
JOIN rpt_write
JOIN rpt_extend
JOIN rpt_delete
JOIN rpt_copy
JOIN rpt_schedule
ORDER BY grp.code_value
HEAD REPORT
i = 0
DETAIL ;position/group
i += 1
;populate rsec record
CALL ALTERLIST(rsec->list, i)
IF(grp.code_set = 88) rsec->list[i].type = "POSITION"
ELSE rsec->list[i].type = grp.cdf_meaning
ENDIF
rsec->list[i].display = grp.display
rsec->list[i].code_value = grp.code_value
rsec->list[i].active_status =
IF(grp.active_ind = 0) "inactive"
ELSEIF(grp.active_ind = 1 AND grp.end_effective_dt_tm > SYSDATE)
"active"
ELSEIF(grp.active_ind = 1 AND NOT grp.end_effective_dt_tm > SYSDATE)
"active - expired"
ELSE "unknown"
ENDIF
rsec->list[i].security_ind = IF(sec_cnt.row_cnt > 0) YES ELSE NO
ENDIF
;global report settings, stored at the group level
rsec->list[i].rpt_grun = IF(rpt_read.security_assignment_cd > 0)
YES_GLOBAL ELSE NO ENDIF
rsec->list[i].rpt_gmodify = IF(rpt_write.security_assignment_cd >
0) YES_GLOBAL ELSE NO ENDIF
rsec->list[i].rpt_gdelete = IF(rpt_delete.security_assignment_cd
> 0) YES_GLOBAL ELSE NO ENDIF
rsec->list[i].rpt_gcopy = IF(rpt_copy.security_assignment_cd > 0)
YES_GLOBAL ELSE NO ENDIF
rsec->list[i].rpt_gextend = IF(rpt_extend.security_assignment_cd
> 0) YES_GLOBAL ELSE NO ENDIF
rsec->list[i].rpt_gschedule = IF(rpt_schedule.security_assignment_cd
> 0) YES_GLOBAL ELSE NO ENDIF
;create a dummy report item for the global settings, stored at the
report level
CALL ALTERLIST(rsec->list[i].rpt, 1)
rsec->list[i].rpt[1].report_id = 0.0
rsec->list[i].rpt[1].report_title = "< Global Report
Settings >"
rsec->list[i].rpt[1].report_path = ""
rsec->list[i].rpt[1].rpt_run = IF(rpt_read.security_assignment_cd
> 0) YES_GLOBAL ELSE NO ENDIF
rsec->list[i].rpt[1].rpt_modify =
IF(rpt_write.security_assignment_cd > 0) YES_GLOBAL ELSE NO ENDIF
rsec->list[i].rpt[1].rpt_delete =
IF(rpt_delete.security_assignment_cd > 0) YES_GLOBAL ELSE NO ENDIF
rsec->list[i].rpt[1].rpt_copy = IF(rpt_copy.security_assignment_cd
> 0) YES_GLOBAL ELSE NO ENDIF
rsec->list[i].rpt[1].rpt_extend =
IF(rpt_extend.security_assignment_cd > 0) YES_GLOBAL ELSE NO ENDIF
rsec->list[i].rpt[1].rpt_schedule =
IF(rpt_schedule.security_assignment_cd > 0) YES_GLOBAL ELSE NO ENDIF
WITH NULLREPORT
end
;build_rsec_global
;very poor
performance!
subroutine
(build_rsec_report_lists(NULL) = NULL)
declare grp = i4
declare grp_cnt = i4 with noconstant(size(rsec->list, 5))
declare all_rpt_cnt = i4 with noconstant(fr->all_rpt_cnt)
FOR (grp = 1 TO grp_cnt)
 SELECT INTO "NL:"
 FROM DA_REPORT dr
 ,DA_FOLDER_REPORT_RELTN
dfrr
 ,DA_FOLDER df ;this join
removes unpublished reports
 PLAN dr WHERE dr.active_ind =
1
 JOIN dfrr WHERE
dr.da_report_id = dfrr.da_report_id
 JOIN df WHERE
dfrr.da_folder_id = df.da_folder_id
 AND df.public_ind = 1
 ORDER BY
dr.da_report_id;df.da_folder_id, dr.da_report_id
 HEAD REPORT
         i = 0
         CALL
ALTERLIST(rsec->list[grp].rpt, all_rpt_cnt)
         DETAIL
         i += 1
         rsec->list[grp].rpt[i].report_id
= dr.da_report_id
         rsec->list[grp].rpt[i].report_path
= get_path(df.da_folder_id)
         rsec->list[grp].rpt[i].report_title
=
IF(dr.report_type_cd =
19176835        AND
TEXTLEN(TRIM(dfrr.report_alias_name)) > 0) dfrr.report_alias_name
ELSEIF(dr.report_type_cd =
19176835        AND
TEXTLEN(TRIM(dfrr.report_alias_name)) = 0) dr.report_name
ELSE dr.report_name
ENDIF
;If no security, default to NO_NOSEC
IF(rsec->list[grp].security_ind = NO)
rsec->list[grp].rpt[i].rpt_run = NO_NOSEC
rsec->list[grp].rpt[i].rpt_modify = NO_NOSEC
rsec->list[grp].rpt[i].rpt_delete = NO_NOSEC
rsec->list[grp].rpt[i].rpt_copy = NO_NOSEC
rsec->list[grp].rpt[i].rpt_extend = NO_NOSEC
rsec->list[grp].rpt[i].rpt_schedule = NO_NOSEC
ELSE ;has security
;Global run
IF(rsec->list[grp].rpt_grun = YES)
rsec->list[grp].rpt[i].rpt_run = YES_GLOBAL
ELSE rsec->list[grp].rpt[i].rpt_run = NO ;default to no
ENDIF
;Global modify
IF(rsec->list[grp].rpt_gmodify = YES)
rsec->list[grp].rpt[i].rpt_modify = YES_GLOBAL
ELSE rsec->list[grp].rpt[i].rpt_modify = NO ;default to no
ENDIF
;Global delete
IF(rsec->list[grp].rpt_gdelete = YES)
rsec->list[grp].rpt[i].rpt_delete = YES_GLOBAL
ELSE rsec->list[grp].rpt[i].rpt_delete = NO ;default to no
ENDIF
;Global copy
IF(rsec->list[grp].rpt_gcopy = YES)
rsec->list[grp].rpt[i].rpt_copy = YES_GLOBAL
ELSE rsec->list[grp].rpt[i].rpt_copy = NO ;default to no
ENDIF
;Global extend
IF(rsec->list[grp].rpt_gextend = YES)
rsec->list[grp].rpt[i].rpt_extend = YES_GLOBAL
ELSE rsec->list[grp].rpt[i].rpt_extend = NO ;default to no
ENDIF
;Global schedule
IF(rsec->list[grp].rpt_gschedule = YES)
rsec->list[grp].rpt[i].rpt_schedule = YES_GLOBAL
ELSE rsec->list[grp].rpt[i].rpt_schedule = NO ;default to no
ENDIF
ENDIF
ENDFOR
end
;build_rsec_report_lists
subroutine
(build_rsec_report_settings(NULL) = NULL)
CALL ECHO("Do nothing")
declare gnum = i4 with noconstant(0)
declare gpos = i4 with noconstant(0)
declare rnum = i4 with noconstant(0)
declare rpos = i4 with noconstant(0)
;run
SELECT INTO "NL:"
FROM DA_GROUP_SECURITY dgs
,CODE_VALUE grp
PLAN dgs WHERE dgs.active_ind = 1
AND dgs.parent_entity_name = "DA_REPORT"
AND dgs.parent_entity_id > 0
AND dgs.security_assignment_cd = READ_PRIV
JOIN grp WHERE dgs.security_group_cd = grp.code_value
AND grp.active_ind = 1
ORDER BY dgs.security_group_cd, dgs.parent_entity_id
HEAD dgs.security_group_cd ;position/group
gpos = LOCATEVAL(gnum, 1, size(rsec->list, 5),
 dgs.security_group_cd,
rsec->list[gnum].code_value)
HEAD dgs.parent_entity_id ;report
rpos = LOCATEVAL(rnum, 1, size(rsec->list[gpos].rpt, 5),
 dgs.parent_entity_id,
rsec->list[gpos].rpt[rnum].report_id)
IF(rsec->list[gpos].rpt_grun = YES)
rsec->list[gpos].rpt[rpos].rpt_run = YES_GLOBAL
ELSE rsec->list[gpos].rpt[rpos].rpt_run = YES
ENDIF ;not global and no security found; remain defaulted to
"no"
WITH NULLREPORT
;modify
SELECT INTO "NL:"
FROM DA_GROUP_SECURITY dgs
,CODE_VALUE grp
PLAN dgs WHERE dgs.active_ind = 1
AND dgs.parent_entity_name = "DA_REPORT"
AND dgs.parent_entity_id > 0
AND dgs.security_assignment_cd = WRITE_PRIV
JOIN grp WHERE dgs.security_group_cd = grp.code_value
AND grp.active_ind = 1
ORDER BY dgs.security_group_cd, dgs.parent_entity_id
HEAD dgs.security_group_cd ;position/group
gpos = LOCATEVAL(gnum, 1, size(rsec->list, 5),
 dgs.security_group_cd,
rsec->list[gnum].code_value)
HEAD dgs.parent_entity_id ;report
rpos = LOCATEVAL(rnum, 1, size(rsec->list[gpos].rpt, 5),
 dgs.parent_entity_id,
rsec->list[gpos].rpt[rnum].report_id)
IF(rsec->list[gpos].rpt_gmodify = YES)
rsec->list[gpos].rpt[rpos].rpt_modify = YES_GLOBAL
ELSE rsec->list[gpos].rpt[rpos].rpt_modify = YES
ENDIF ;not global and no security found; remain defaulted to
"no"
WITH NULLREPORT
;delete
SELECT INTO "NL:"
FROM DA_GROUP_SECURITY dgs
,CODE_VALUE grp
PLAN dgs WHERE dgs.active_ind = 1
AND dgs.parent_entity_name = "DA_REPORT"
AND dgs.parent_entity_id > 0
AND dgs.security_assignment_cd = DELETE_PRIV
JOIN grp WHERE dgs.security_group_cd = grp.code_value
AND grp.active_ind = 1
ORDER BY dgs.security_group_cd, dgs.parent_entity_id
HEAD dgs.security_group_cd ;position/group
gpos = LOCATEVAL(gnum, 1, size(rsec->list, 5),
 dgs.security_group_cd,
rsec->list[gnum].code_value)
HEAD dgs.parent_entity_id ;report
rpos = LOCATEVAL(rnum, 1, size(rsec->list[gpos].rpt, 5),
 dgs.parent_entity_id,
rsec->list[gpos].rpt[rnum].report_id)
IF(rsec->list[gpos].rpt_gdelete = YES)
rsec->list[gpos].rpt[rpos].rpt_delete = YES_GLOBAL
ELSE rsec->list[gpos].rpt[rpos].rpt_delete = YES
ENDIF ;not global and no security found; remain defaulted to
"no"
WITH NULLREPORT
;copy
SELECT INTO "NL:"
FROM DA_GROUP_SECURITY dgs
,CODE_VALUE grp
PLAN dgs WHERE dgs.active_ind = 1
AND dgs.parent_entity_name = "DA_REPORT"
AND dgs.parent_entity_id > 0
AND dgs.security_assignment_cd = COPY_PRIV
JOIN grp WHERE dgs.security_group_cd = grp.code_value
AND grp.active_ind = 1
ORDER BY dgs.security_group_cd, dgs.parent_entity_id
HEAD dgs.security_group_cd ;position/group
gpos = LOCATEVAL(gnum, 1, size(rsec->list, 5),
 dgs.security_group_cd,
rsec->list[gnum].code_value)
HEAD dgs.parent_entity_id ;report
rpos = LOCATEVAL(rnum, 1, size(rsec->list[gpos].rpt, 5),
 dgs.parent_entity_id,
rsec->list[gpos].rpt[rnum].report_id)
IF(rsec->list[gpos].rpt_gcopy = YES)
rsec->list[gpos].rpt[rpos].rpt_copy = YES_GLOBAL
ELSE rsec->list[gpos].rpt[rpos].rpt_copy = YES
ENDIF ;not global and no security found; remain defaulted to
"no"
WITH NULLREPORT
;extend
SELECT INTO "NL:"
FROM DA_GROUP_SECURITY dgs
,CODE_VALUE grp
PLAN dgs WHERE dgs.active_ind = 1
AND dgs.parent_entity_name = "DA_REPORT"
AND dgs.parent_entity_id > 0
AND dgs.security_assignment_cd = EXTEND_PRIV
JOIN grp WHERE dgs.security_group_cd = grp.code_value
AND grp.active_ind = 1
ORDER BY dgs.security_group_cd, dgs.parent_entity_id
HEAD dgs.security_group_cd ;position/group
gpos = LOCATEVAL(gnum, 1, size(rsec->list, 5),
 dgs.security_group_cd,
rsec->list[gnum].code_value)
HEAD dgs.parent_entity_id ;report
rpos = LOCATEVAL(rnum, 1, size(rsec->list[gpos].rpt, 5),
 dgs.parent_entity_id,
rsec->list[gpos].rpt[rnum].report_id)
IF(rsec->list[gpos].rpt_gextend = YES)
rsec->list[gpos].rpt[rpos].rpt_extend = YES_GLOBAL
ELSE rsec->list[gpos].rpt[rpos].rpt_extend = YES
ENDIF ;not global and no security found; remain defaulted to
"no"
WITH NULLREPORT
;schedule
SELECT INTO "NL:"
FROM DA_GROUP_SECURITY dgs
,CODE_VALUE grp
PLAN dgs WHERE dgs.active_ind = 1
AND dgs.parent_entity_name = "DA_REPORT"
AND dgs.parent_entity_id > 0
AND dgs.security_assignment_cd = SCHEDULE_PRIV
JOIN grp WHERE dgs.security_group_cd = grp.code_value
AND grp.active_ind = 1
ORDER BY dgs.security_group_cd, dgs.parent_entity_id
HEAD dgs.security_group_cd ;position/group
gpos = LOCATEVAL(gnum, 1, size(rsec->list, 5),
 dgs.security_group_cd,
rsec->list[gnum].code_value)
HEAD dgs.parent_entity_id ;report
rpos = LOCATEVAL(rnum, 1, size(rsec->list[gpos].rpt, 5),
 dgs.parent_entity_id,
rsec->list[gpos].rpt[rnum].report_id)
IF(rsec->list[gpos].rpt_gschedule = YES)
rsec->list[gpos].rpt[rpos].rpt_schedule = YES_GLOBAL
ELSE rsec->list[gpos].rpt[rpos].rpt_schedule = YES
ENDIF ;not global and no security found; remain defaulted to
"no"
WITH NULLREPORT
end
;build_rsec_report_settings
/**************************************************************
; Main
**************************************************************/
CALL
init_fr_record(NULL)
; Only build
the access records when necessary (for performance)
IF($rpt_type
= "general" AND $rpt_general = "Access*") CALL
init_fsec_records(NULL)
ELSEIF($rpt_type
= "by_folder" AND $rpt_by_folder = "Access*") CALL
init_fsec_records(NULL)
ELSEIF($rpt_type
= "by_report" AND $rpt_by_report = "Access*") CALL
init_rsec_records(NULL)
ELSEIF($rpt_type
= "by_position" AND $rpt_by_position = "Access (f*") CALL
init_fsec_records(NULL)
ELSEIF($rpt_type
= "by_position" AND $rpt_by_position = "Access (r*") CALL
init_rsec_records(NULL)
ELSEIF($rpt_type
= "by_group" AND $rpt_by_group = "Access (f*") CALL
init_fsec_records(NULL)
ELSEIF($rpt_type
= "by_group" AND $rpt_by_group = "Access (r*") CALL
init_rsec_records(NULL)
ENDIF
/**************************************************************
; Output
**************************************************************/
SELECT
;works 5/15
IF($rpt_type
= "general" AND $rpt_general = "Access (general)")
group = fsec->list[d.seq].display
,type = fsec->list[d.seq].type
,status = fsec->list[d.seq].active_status
,security_enabled = fsec->list[d.seq].security_ind
,discern_access = fsec->list[d.seq].discern_access
,discern_admin = fsec->list[d.seq].discern_admin
,explorer_menu = fsec->list[d.seq].explorer_menu
,schedule_manager = fsec->list[d.seq].schedule_mgr
,fldr_gbl_read = fsec->list[d.seq].fld_gread
,fldr_gbl_delete = fsec->list[d.seq].fld_gdelete
,fldr_gbl_copy = fsec->list[d.seq].fld_gcopy
,fldr_gbl_add_rem_rpts = fsec->list[d.seq].fld_gadd_remove_rpts
,fldr_gbl_add_rem_ccl = fsec->list[d.seq].fld_gadd_remove_ccl
,fldr_gbl_create = fsec->list[d.seq].fld_gcreate
FROM (DUMMYT d WITH seq = value(size(fsec->list, 5)))
PLAN d
ORDER BY type, group
ELSEIF($rpt_type
= "general" AND $rpt_general = "Access (user-specific)")
organization =
IF(CNVTUPPER(p.email) = "*.MIL") "DOD"
ELSEIF(CNVTUPPER(p.email) = "*VA.GOV") "VA"
ELSEIF(CNVTUPPER(p.email) = "*CERNER*" OR CNVTUPPER(p.email)
= "*ORACLE*") "Oracle"
ELSEIF(p.username != "*.0") "Oracle"
ELSE "unmapped"
ENDIF
,personnel = p.name_full_formatted
,fldr_cnt.folder_cnt
,rpt_cnt.report_cnt
,p.username
,p.email
,position = UAR_GET_CODE_DISPLAY(p.position_cd)
,p.person_id
FROM PRSNL p
,(LEFT JOIN (
SELECT dus.prsnl_id, folder_cnt = COUNT(DISTINCT df.da_folder_id)
FROM DA_USER_SECURITY dus
,DA_FOLDER df
WHERE dus.parent_entity_name = "DA_FOLDER"
AND dus.parent_entity_id > 0
AND dus.prsnl_id > 0
AND dus.active_ind = 1
AND dus.parent_entity_id = df.da_folder_id
AND df.public_ind = 1
GROUP BY dus.prsnl_id
WITH SQLTYPE("f8", "i4")
) fldr_cnt ON p.person_id = fldr_cnt.prsnl_id)
,(LEFT JOIN (
SELECT dus.prsnl_id, report_cnt = COUNT(DISTINCT dr.da_report_id)
FROM DA_USER_SECURITY dus
,DA_REPORT dr
WHERE dus.parent_entity_name = "DA_REPORT"
AND dus.parent_entity_id > 0
AND dus.prsnl_id > 0
AND dus.active_ind = 1
AND dus.parent_entity_id = dr.da_report_id
GROUP BY dus.prsnl_id
WITH SQLTYPE("f8", "i4")
) rpt_cnt ON p.person_id =
rpt_cnt.prsnl_id)
PLAN p WHERE p.active_ind = 1
AND p.person_id IN (
SELECT prsnl_id
FROM DA_USER_SECURITY
WHERE parent_entity_name IN ("DA_REPORT",
"DA_FOLDER")
AND parent_entity_id > 0
AND security_assignment_cd = 19176506 ;read
AND active_ind = 1
)
JOIN fldr_cnt
JOIN rpt_cnt
ORDER BY organization, personnel
ELSEIF($rpt_type
= "general" AND $rpt_general = "Folder structure")
root = fr->fld[d.seq].root
,path = fr->fld[d.seq].path
,folder = fr->fld[d.seq].folder
,root_ind = fr->fld[d.seq].root_ind
,nbr_reports_in_folder = fr->fld[d.seq].rpt_cnt
,nbr_reports_in_root = fr->fld[d.seq].root_cnt
,folder_id = fr->fld[d.seq].folder_id
FROM (DUMMYT d WITH seq = value(size(fr->fld, 5)))
PLAN d
ORDER BY CNVTUPPER(fr->fld[d.seq].path)
ELSEIF($rpt_type
= "general" AND $rpt_general = "Reports extract")
root = fr->fld[f.seq].root
,path = fr->fld[f.seq].path
,title = fr->fld[f.seq].rpt[r.seq].report_title
,name = fr->fld[f.seq].rpt[r.seq].report_name
,description = fr->fld[f.seq].rpt[r.seq].report_desc
,report_type = fr->fld[f.seq].rpt[r.seq].report_type
,owner_group = fr->fld[f.seq].rpt[r.seq].report_owner_group
,cerner_standard = fr->fld[f.seq].rpt[r.seq].cerner_standard
,report_uuid = fr->fld[f.seq].rpt[r.seq].report_uuid
,report_id = fr->fld[f.seq].rpt[r.seq].report_id
FROM (DUMMYT f WITH seq = value(size(fr->fld, 5)))
,(DUMMYT r WITH seq = 1)
PLAN f WHERE MAXREC(r, size(fr->fld[f.seq].rpt, 5))
JOIN r
ORDER BY CNVTUPPER(fr->fld[f.seq].path), title
ELSEIF($rpt_type
= "general" AND $rpt_general = "Usage (overall) *")
path =
fr->fld[f.seq].rpt[r.seq].report_path
,title = fr->fld[f.seq].rpt[r.seq].report_title
,nbr_runs = COUNT(cra.report_event_id)
,nbr_users = COUNT(DISTINCT cra.updt_id)
,start_date = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_date = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
,root = fr->fld[f.seq].rpt[r.seq].report_root
,object_name = fr->fld[f.seq].rpt[r.seq].object_name
FROM (DUMMYT f WITH seq = value(size(fr->fld, 5)))
,(DUMMYT r WITH seq = 1)
,CCL_REPORT_AUDIT cra
PLAN f WHERE MAXREC(r, size(fr->fld[f.seq].rpt, 5))
JOIN r
JOIN cra WHERE fr->fld[f.seq].rpt[r.seq].object_name =
cra.object_name
AND cra.updt_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND cra.object_type IN ("CCLREPORT", "BOREPORT",
"DAREPORT", "URLREPORT",
"DADATACUBE")
GROUP BY cra.object_name
ORDER BY path, title
ELSEIF($rpt_type
= "general" AND $rpt_general = "Usage (by position) *")
path =
fr->fld[f.seq].rpt[r.seq].report_path
,title = fr->fld[f.seq].rpt[r.seq].report_title
,position = UAR_GET_CODE_DISPLAY(p.position_cd)
,nbr_runs = COUNT(cra.report_event_id)
,nbr_users = COUNT(DISTINCT cra.updt_id)
,start_date = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_date = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
,root = fr->fld[f.seq].rpt[r.seq].report_root
,object_name = fr->fld[f.seq].rpt[r.seq].object_name
FROM (DUMMYT f WITH seq = value(size(fr->fld, 5)))
,(DUMMYT r WITH seq = 1)
,CCL_REPORT_AUDIT cra
,PRSNL p
PLAN f WHERE MAXREC(r, size(fr->fld[f.seq].rpt, 5))
JOIN r
JOIN cra WHERE fr->fld[f.seq].rpt[r.seq].object_name =
cra.object_name
AND cra.updt_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND cra.object_type IN ("CCLREPORT", "BOREPORT",
"DAREPORT", "URLREPORT",
"DADATACUBE")
JOIN p WHERE cra.updt_id = p.person_id
GROUP BY cra.object_name, p.position_cd
ORDER BY path, title, position
/**********************************************************************************/
ELSEIF($rpt_type
= "by_folder" AND $rpt_by_folder = "Access (folders)")
path = fsec->list[d.seq].fld[f.seq].path
,folder = fsec->list[d.seq].fld[f.seq].folder
,group = fsec->list[d.seq].display
,type = fsec->list[d.seq].type
,status = fsec->list[d.seq].active_status
,security_enabled = fsec->list[d.seq].security_ind
,read_priv = fsec->list[d.seq].fld[f.seq].fld_read
,delete_priv = fsec->list[d.seq].fld[f.seq].fld_delete
,copy_priv = fsec->list[d.seq].fld[f.seq].fld_copy
,add_remove_rpts = fsec->list[d.seq].fld[f.seq].fld_add_remove_rpts
,add_remove_ccl = fsec->list[d.seq].fld[f.seq].fld_add_remove_ccl
,create_priv = fsec->list[d.seq].fld[f.seq].fld_create
FROM (DUMMYT d WITH seq = value(size(fsec->list, 5)))
,(DUMMYT f WITH seq = 1)
,DA_FOLDER df
PLAN d WHERE MAXREC(f, size(fsec->list[d.seq].fld, 5))
JOIN f
JOIN df WHERE fsec->list[d.seq].fld[f.seq].folder_id =
df.da_folder_id
AND df.da_folder_id = $by_folder
ORDER BY path, folder, type, group
ELSEIF($rpt_type
= "by_folder" AND $rpt_by_folder = "Reports extract")
root = fr->fld[f.seq].root
,path = fr->fld[f.seq].path
,title = fr->fld[f.seq].rpt[r.seq].report_title
,name = fr->fld[f.seq].rpt[r.seq].report_name
,description = fr->fld[f.seq].rpt[r.seq].report_desc
,report_type = fr->fld[f.seq].rpt[r.seq].report_type
,owner_group = fr->fld[f.seq].rpt[r.seq].report_owner_group
,cerner_standard = fr->fld[f.seq].rpt[r.seq].cerner_standard
,report_uuid = fr->fld[f.seq].rpt[r.seq].report_uuid
,report_id = fr->fld[f.seq].rpt[r.seq].report_id
FROM (DUMMYT f WITH seq = value(size(fr->fld, 5)))
,(DUMMYT r WITH seq = 1)
,DA_FOLDER df
PLAN f WHERE MAXREC(r, size(fr->fld[f.seq].rpt, 5))
JOIN r
JOIN df WHERE fr->fld[f.seq].folder_id = df.da_folder_id
AND df.da_folder_id = $by_folder
ORDER BY CNVTUPPER(fr->fld[f.seq].path), title
ELSEIF($rpt_type
= "by_folder" AND $rpt_by_folder = "Usage (overall) *")
path =
fr->fld[f.seq].rpt[r.seq].report_path
,title = fr->fld[f.seq].rpt[r.seq].report_title
,nbr_runs = COUNT(cra.report_event_id)
,nbr_users = COUNT(DISTINCT cra.updt_id)
,start_date = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_date = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
,root = fr->fld[f.seq].rpt[r.seq].report_root
,object_name = fr->fld[f.seq].rpt[r.seq].object_name
FROM (DUMMYT f WITH seq = value(size(fr->fld, 5)))
,(DUMMYT r WITH seq = 1)
,DA_FOLDER df
,CCL_REPORT_AUDIT cra
PLAN f WHERE MAXREC(r, size(fr->fld[f.seq].rpt, 5))
JOIN r
JOIN df WHERE fr->fld[f.seq].folder_id = df.da_folder_id
AND df.da_folder_id = $by_folder
JOIN cra WHERE fr->fld[f.seq].rpt[r.seq].object_name =
cra.object_name
AND cra.updt_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND cra.object_type IN ("CCLREPORT", "BOREPORT",
"DAREPORT", "URLREPORT",
"DADATACUBE")
GROUP BY cra.object_name
ORDER BY path, title
ELSEIF($rpt_type
= "by_folder" AND $rpt_by_folder = "Usage (by position) *")
path =
fr->fld[f.seq].rpt[r.seq].report_path
,title = fr->fld[f.seq].rpt[r.seq].report_title
,position = UAR_GET_CODE_DISPLAY(p.position_cd)
,nbr_runs = COUNT(cra.report_event_id)
,nbr_users = COUNT(DISTINCT cra.updt_id)
,start_date = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_date = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
,root = fr->fld[f.seq].rpt[r.seq].report_root
,object_name = fr->fld[f.seq].rpt[r.seq].object_name
FROM (DUMMYT f WITH seq = value(size(fr->fld, 5)))
,(DUMMYT r WITH seq = 1)
,DA_FOLDER
df
,CCL_REPORT_AUDIT cra
,PRSNL p
PLAN f WHERE MAXREC(r, size(fr->fld[f.seq].rpt, 5))
JOIN r
JOIN df WHERE fr->fld[f.seq].folder_id = df.da_folder_id
AND df.da_folder_id = $by_folder
JOIN cra WHERE fr->fld[f.seq].rpt[r.seq].object_name =
cra.object_name
AND cra.updt_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND cra.object_type IN ("CCLREPORT", "BOREPORT",
"DAREPORT", "URLREPORT",
"DADATACUBE")
JOIN p WHERE cra.updt_id = p.person_id
GROUP BY cra.object_name, p.position_cd
ORDER BY path, title, position
/**********************************************************************************/
ELSEIF($rpt_type
= "by_report" AND $rpt_by_report = "Access (reports)")
path = rsec->list[d.seq].rpt[r.seq].report_path
,report_title = rsec->list[d.seq].rpt[r.seq].report_title
,group = rsec->list[d.seq].display
,type = rsec->list[d.seq].type
,status = rsec->list[d.seq].active_status
,security_enabled = rsec->list[d.seq].security_ind
,run_priv = rsec->list[d.seq].rpt[r.seq].rpt_run
,modify_priv = rsec->list[d.seq].rpt[r.seq].rpt_modify
,delete_priv = rsec->list[d.seq].rpt[r.seq].rpt_delete
,copy_priv = rsec->list[d.seq].rpt[r.seq].rpt_copy
,extend_priv = rsec->list[d.seq].rpt[r.seq].rpt_extend
,schedule_priv = rsec->list[d.seq].rpt[r.seq].rpt_schedule
FROM (DUMMYT d WITH seq = value(size(rsec->list, 5)))
,(DUMMYT r WITH seq = 1)
,DA_REPORT dr
PLAN d WHERE MAXREC(r, size(rsec->list[d.seq].rpt, 5))
JOIN r
JOIN dr WHERE rsec->list[d.seq].rpt[r.seq].report_id =
dr.da_report_id
AND dr.da_report_id = $by_report
ORDER BY path, report_title, type, group
ELSEIF($rpt_type
= "by_report" AND $rpt_by_report = "Usage (overall) *")
path =
fr->fld[f.seq].rpt[r.seq].report_path
,title = fr->fld[f.seq].rpt[r.seq].report_title
,nbr_runs = COUNT(cra.report_event_id)
,nbr_users = COUNT(DISTINCT cra.updt_id)
,start_date = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_date = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
,root = fr->fld[f.seq].rpt[r.seq].report_root
,object_name = fr->fld[f.seq].rpt[r.seq].object_name
FROM (DUMMYT f WITH seq = value(size(fr->fld, 5)))
,(DUMMYT r WITH seq = 1)
,DA_REPORT dr
,CCL_REPORT_AUDIT cra
PLAN f WHERE MAXREC(r, size(fr->fld[f.seq].rpt, 5))
JOIN r
JOIN dr WHERE fr->fld[f.seq].rpt[r.seq].report_id = dr.da_report_id
AND dr.da_report_id = $by_report
JOIN cra WHERE TRIM(CNVTUPPER(SUBSTRING(1,40,dr.report_name))) =
cra.object_name
AND cra.updt_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND cra.object_type IN ("CCLREPORT", "BOREPORT",
"DAREPORT", "URLREPORT",
"DADATACUBE")
GROUP BY cra.object_name
ORDER BY path, title
ELSEIF($rpt_type
= "by_report" AND $rpt_by_report = "Usage (by position) *")
path =
fr->fld[f.seq].rpt[r.seq].report_path
,title = fr->fld[f.seq].rpt[r.seq].report_title
,position = UAR_GET_CODE_DISPLAY(p.position_cd)
,nbr_runs = COUNT(cra.report_event_id)
,nbr_users = COUNT(DISTINCT cra.updt_id)
,start_date = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_date = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
,root = fr->fld[f.seq].rpt[r.seq].report_root
,object_name = fr->fld[f.seq].rpt[r.seq].object_name
FROM (DUMMYT f WITH seq = value(size(fr->fld, 5)))
,(DUMMYT r WITH seq = 1)
,DA_REPORT dr
,CCL_REPORT_AUDIT cra
,PRSNL p
PLAN f WHERE MAXREC(r, size(fr->fld[f.seq].rpt, 5))
JOIN r
JOIN dr WHERE fr->fld[f.seq].rpt[r.seq].report_id = dr.da_report_id
AND dr.da_report_id = $by_report
JOIN cra WHERE TRIM(CNVTUPPER(SUBSTRING(1,40,dr.report_name))) =
cra.object_name
AND cra.updt_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND cra.object_type IN ("CCLREPORT", "BOREPORT",
"DAREPORT", "URLREPORT",
"DADATACUBE")
JOIN p WHERE cra.updt_id = p.person_id
GROUP BY cra.object_name, p.position_cd
ORDER BY path, title, position
ELSEIF($rpt_type
= "by_report" AND $rpt_by_report = "Usage (by personnel)
*")
path =
fr->fld[f.seq].rpt[r.seq].report_path
,title = fr->fld[f.seq].rpt[r.seq].report_title
,user = p.name_full_formatted
,position = UAR_GET_CODE_DISPLAY(p.position_cd)
,p.email
,nbr_runs = COUNT(cra.report_event_id)
,start_date = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_date = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
,root = fr->fld[f.seq].rpt[r.seq].report_root
,object_name = fr->fld[f.seq].rpt[r.seq].object_name
FROM (DUMMYT f WITH seq = value(size(fr->fld, 5)))
,(DUMMYT r WITH seq = 1)
,DA_REPORT dr
,CCL_REPORT_AUDIT cra
,PRSNL p
PLAN f WHERE MAXREC(r, size(fr->fld[f.seq].rpt, 5))
JOIN r
JOIN dr WHERE fr->fld[f.seq].rpt[r.seq].report_id = dr.da_report_id
AND dr.da_report_id = $by_report
JOIN cra WHERE TRIM(CNVTUPPER(SUBSTRING(1,40,dr.report_name))) =
cra.object_name
AND cra.updt_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND cra.object_type IN ("CCLREPORT", "BOREPORT",
"DAREPORT", "URLREPORT",
"DADATACUBE")
JOIN p WHERE cra.updt_id = p.person_id
GROUP BY cra.object_name, p.name_full_formatted, p.position_cd, p.email
ORDER BY path, title, user, position
/**********************************************************************************/
ELSEIF($rpt_type
= "by_position" AND $rpt_by_position = "Access (folders)")
group = fsec->list[d.seq].display
,type = fsec->list[d.seq].type
,status = fsec->list[d.seq].active_status
,security_enabled = fsec->list[d.seq].security_ind
,path = fsec->list[d.seq].fld[f.seq].path
,folder = fsec->list[d.seq].fld[f.seq].folder
,read_priv = fsec->list[d.seq].fld[f.seq].fld_read
,delete_priv = fsec->list[d.seq].fld[f.seq].fld_delete
,copy_priv = fsec->list[d.seq].fld[f.seq].fld_copy
,add_remove_rpts = fsec->list[d.seq].fld[f.seq].fld_add_remove_rpts
,add_remove_ccl = fsec->list[d.seq].fld[f.seq].fld_add_remove_ccl
,create_priv = fsec->list[d.seq].fld[f.seq].fld_create
FROM (DUMMYT d WITH seq = value(size(fsec->list, 5)))
,(DUMMYT f WITH seq = 1)
,CODE_VALUE grp
PLAN d WHERE MAXREC(f, size(fsec->list[d.seq].fld, 5))
JOIN f
JOIN grp WHERE fsec->list[d.seq].code_value = grp.code_value
AND grp.code_value = $by_position
ORDER BY group, path, folder
ELSEIF($rpt_type
= "by_position" AND $rpt_by_position = "Access (reports)")
group = rsec->list[d.seq].display
,type = rsec->list[d.seq].type
,status = rsec->list[d.seq].active_status
,security_enabled = rsec->list[d.seq].security_ind
,path = rsec->list[d.seq].rpt[r.seq].report_path
,report_title = rsec->list[d.seq].rpt[r.seq].report_title
,run_priv = rsec->list[d.seq].rpt[r.seq].rpt_run
,modify_priv = rsec->list[d.seq].rpt[r.seq].rpt_modify
,delete_priv = rsec->list[d.seq].rpt[r.seq].rpt_delete
,copy_priv = rsec->list[d.seq].rpt[r.seq].rpt_copy
,extend_priv = rsec->list[d.seq].rpt[r.seq].rpt_extend
,schedule_priv = rsec->list[d.seq].rpt[r.seq].rpt_schedule
FROM (DUMMYT d WITH seq = value(size(rsec->list, 5)))
,(DUMMYT r WITH seq = 1)
,CODE_VALUE grp
PLAN d WHERE MAXREC(r, size(rsec->list[d.seq].rpt, 5))
JOIN r
JOIN grp WHERE rsec->list[d.seq].code_value = grp.code_value
AND grp.code_value = $by_position
ORDER BY type, group, path, report_title
ELSEIF($rpt_type
= "by_position" AND $rpt_by_position = "Usage (by position)
*")
position = UAR_GET_CODE_DISPLAY(p.position_cd)
,path =
fr->fld[f.seq].rpt[r.seq].report_path
,title = fr->fld[f.seq].rpt[r.seq].report_title
,nbr_runs = COUNT(cra.report_event_id)
,nbr_users = COUNT(DISTINCT cra.updt_id)
,start_date = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_date = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
,root = fr->fld[f.seq].rpt[r.seq].report_root
,object_name = fr->fld[f.seq].rpt[r.seq].object_name
FROM (DUMMYT f WITH seq = value(size(fr->fld, 5)))
,(DUMMYT r WITH seq = 1)
,CCL_REPORT_AUDIT cra
,PRSNL p
PLAN f WHERE MAXREC(r, size(fr->fld[f.seq].rpt, 5))
JOIN r
JOIN cra WHERE fr->fld[f.seq].rpt[r.seq].object_name =
cra.object_name
AND cra.updt_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND cra.object_type IN ("CCLREPORT", "BOREPORT",
"DAREPORT", "URLREPORT",
"DADATACUBE")
JOIN p WHERE cra.updt_id = p.person_id
AND p.position_cd = $by_position
GROUP BY p.position_cd, cra.object_name
ORDER BY position, path, title
ELSEIF($rpt_type
= "by_position" AND $rpt_by_position = "Usage (by personnel)
*")
position = UAR_GET_CODE_DISPLAY(p.position_cd)
,path =
fr->fld[f.seq].rpt[r.seq].report_path
,title = fr->fld[f.seq].rpt[r.seq].report_title
,user = p.name_full_formatted
,p.email
,nbr_runs = COUNT(cra.report_event_id)
,nbr_users = COUNT(DISTINCT cra.updt_id)
,start_date = CNVTDATETIME($start_date) "MM/DD/YYYY;;d"
,end_date = CNVTDATETIME($end_date) "MM/DD/YYYY;;d"
,root = fr->fld[f.seq].rpt[r.seq].report_root
,object_name = fr->fld[f.seq].rpt[r.seq].object_name
FROM (DUMMYT f WITH seq = value(size(fr->fld, 5)))
,(DUMMYT r WITH seq = 1)
,CCL_REPORT_AUDIT cra
,PRSNL p
PLAN f WHERE MAXREC(r, size(fr->fld[f.seq].rpt, 5))
JOIN r
JOIN cra WHERE fr->fld[f.seq].rpt[r.seq].object_name =
cra.object_name
AND cra.updt_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND cra.object_type IN ("CCLREPORT", "BOREPORT",
"DAREPORT", "URLREPORT",
"DADATACUBE")
JOIN p WHERE cra.updt_id = p.person_id
AND p.position_cd = $by_position
GROUP BY p.position_cd, cra.object_name, p.name_full_formatted, p.email
ORDER BY position, path, title, user
/**********************************************************************************/
ELSEIF($rpt_type
= "by_group" AND $rpt_by_group = "Access (folders)")
group = fsec->list[d.seq].display
,type = fsec->list[d.seq].type
,status = fsec->list[d.seq].active_status
,security_enabled = fsec->list[d.seq].security_ind
,path = fsec->list[d.seq].fld[f.seq].path
,folder = fsec->list[d.seq].fld[f.seq].folder
,read_priv = fsec->list[d.seq].fld[f.seq].fld_read
,delete_priv = fsec->list[d.seq].fld[f.seq].fld_delete
,copy_priv = fsec->list[d.seq].fld[f.seq].fld_copy
,add_remove_rpts = fsec->list[d.seq].fld[f.seq].fld_add_remove_rpts
,add_remove_ccl = fsec->list[d.seq].fld[f.seq].fld_add_remove_ccl
,create_priv = fsec->list[d.seq].fld[f.seq].fld_create
FROM (DUMMYT d WITH seq = value(size(fsec->list, 5)))
,(DUMMYT f WITH seq = 1)
,CODE_VALUE grp
PLAN d WHERE MAXREC(f, size(fsec->list[d.seq].fld, 5))
JOIN f
JOIN grp WHERE fsec->list[d.seq].code_value = grp.code_value
AND grp.code_value = $by_group
ORDER BY group, path, folder
ELSEIF($rpt_type
= "by_group" AND $rpt_by_group = "Access (reports)")
group = rsec->list[d.seq].display
,type = rsec->list[d.seq].type
,status = rsec->list[d.seq].active_status
,security_enabled = rsec->list[d.seq].security_ind
,path = rsec->list[d.seq].rpt[r.seq].report_path
,report_title = rsec->list[d.seq].rpt[r.seq].report_title
,run_priv = rsec->list[d.seq].rpt[r.seq].rpt_run
,modify_priv = rsec->list[d.seq].rpt[r.seq].rpt_modify
,delete_priv = rsec->list[d.seq].rpt[r.seq].rpt_delete
,copy_priv = rsec->list[d.seq].rpt[r.seq].rpt_copy
,extend_priv = rsec->list[d.seq].rpt[r.seq].rpt_extend
,schedule_priv = rsec->list[d.seq].rpt[r.seq].rpt_schedule
FROM (DUMMYT d WITH seq = value(size(rsec->list, 5)))
,(DUMMYT r WITH seq = 1)
,CODE_VALUE grp
PLAN d WHERE MAXREC(r, size(rsec->list[d.seq].rpt, 5))
JOIN r
JOIN grp WHERE rsec->list[d.seq].code_value = grp.code_value
AND grp.code_value = $by_group
ORDER BY type, group, path, report_title
ELSEIF($rpt_type
= "by_group" AND $rpt_by_group = "Group members")
group_name = groups.display
 ,group_type = EVALUATE(groups.cdf_meaning,
 "OWNERGROUP","Owner
Group",
 "SECGROUP","Security
Group",
 "Unknown Group Type")
 ,name_last = CNVTUPPER(p.name_last)
 ,name_first = CNVTUPPER(p.name_first)
 ,position =
UAR_GET_CODE_DISPLAY(p.position_cd)
 ,agency =
         IF(
                 CNVTUPPER(p.email)
= "*CERNER*" OR
                 CNVTUPPER(p.email)
= "*ORACLE*" OR
                 CNVTUPPER(p.name_full_formatted)
= "*CERNER*" OR
                 CNVTUPPER(p.name_full_formatted)
= "*ORACLE*") "Oracle"
         ELSEIF(
                 va_loc.prsnl_alias_id
> 0 OR
                 CNVTUPPER(p.email)
= "*VA.GOV") "VA"
         ELSEIF(
                 dod_loc.assigned_fac_cd
> 0 OR
                 dod_loc.assigned_loc_cd
> 0 OR
                 dod_loc.predicted_fac_cd
> 0 OR
                 dod_loc.predicted_loc_cd
> 0 OR
                 CNVTUPPER(p.email)
= "*.MIL" OR
                 CNVTUPPER(p.email)
= "*LEIDOS*" OR
                 CNVTUPPER(p.email)
= "*LPDH*" OR
                 CNVTUPPER(p.email)
= "*DODIG*") "DOD"
         ELSE
"unmapped"
         ENDIF
,location =
 IF(va_loc.prsnl_alias_id >
0) va_loc.alias
 ELSEIF(dod_loc.assigned_fac_cd > 0)
UAR_GET_CODE_DISPLAY(dod_loc.assigned_loc_cd)
 ELSEIF(dod_loc.assigned_fac_cd = 0 AND dod_loc.predicted_fac_cd > 0)
UAR_GET_CODE_DISPLAY(dod_loc.predicted_fac_cd)
 ENDIF
 ,edipi = edipi.alias
,p.username
,p.email
 ,prsnl_id =
p.person_id
 ,last_updated = dgur.updt_dt_tm
"MM/DD/YYYY;;d"
 ,updated_by = updt_p.name_full_formatted
FROM CODE_VALUE groups
,DA_GROUP_USER_RELTN dgur
,PRSNL p
 ,(LEFT JOIN PRSNL_ALIAS edipi
 ON p.person_id =
edipi.person_id
 AND
edipi.prsnl_alias_type_cd = 685806 ;EDIPI
 AND TEXTLEN(edipi.alias)
= 10
 AND edipi.active_ind = 1
 AND
edipi.end_effective_dt_tm > SYSDATE)
 ,(LEFT JOIN
CUST_DOD_PRSNL_LOC_RELTN dod_loc ON p.person_id = dod_loc.person_id)
 ,(LEFT JOIN PRSNL_ALIAS
va_loc ON p.person_id = va_loc.person_id
 AND va_loc.alias_pool_cd
= 364958627 ;VA employee primary location
 AND va_loc.active_ind = 1
 AND
va_loc.end_effective_dt_tm > SYSDATE)
 ,PRSNL
updt_p
PLAN groups WHERE 1=1
AND groups.code_set = 4002360
AND groups.code_value = $by_group
AND groups.active_ind = 1
JOIN dgur WHERE groups.code_value = dgur.group_cd
JOIN p WHERE dgur.prsnl_id = p.person_id
JOIN updt_p WHERE dgur.updt_id = updt_p.person_id
JOIN edipi
JOIN dod_loc
JOIN va_loc
ORDER BY group_name, CNVTUPPER(p.name_last), CNVTUPPER(p.name_first),
p.username
ENDIF
INTO $OUTDEV
error = "Invalid prompt selections"
WITH
NOCOUNTER, SEPARATOR=" ", FORMAT, CHECK, TIME=900, UAR_CODE(D)
end
go
