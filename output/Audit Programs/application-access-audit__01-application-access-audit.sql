/*
 * Source page  : Application Access Audit
 * Source file  : output/application-access-audit.md
 * Anchor       : (top of page)
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 324
 *
 * Context (preceding paragraph):
 *   Exported: 5/22/25
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

/******************************************************************************
 REPORT NAME:
        Application Access Audit
 PROGRAM:                1FED_RPT_APP_ACCESS_AUDIT.prg
 DEVELOPER:        David Alt
(david.a.alt2.mil@health.mil)
 PUBLISHED:        1/26/2023
 LOGICAL
PATH:        cust_script
 NODE:                <default>
 PURPOSE/DESCRIPTION:
         Provides audits that
assist with position maintenance.
         Reports all return
information on application groups, applications, and tasks
                 from
each of those perspectives, as well as how they relate to positions.
         Example use case:
"What applications can <xyz> position access?"
                                          "What positions have access to
<xyz> application?"
                                          etc
 TARGET AUDIENCE:
          Users involved in
position configuration (solution owners/experts)
 KNOWN BUGS:
 Duplicate app groups in LISTAGG - see
inline comments for App/Positions with access
 You could probably fix this by using inline
tables instead of multiple window functions
MOD        DATE                DEVELOPER        COMMENT
---        --/--/--        ---------        ----------------------------
001        11/13/23        David
Alt        Fixed duplicate results in
Tasks reports
002        03/28/24        David
Alt        Updated ordering (CNVTUPPER
to application name)
******************************************************************************/
drop program
1fed_rpt_app_access_audit go
create
program 1fed_rpt_app_access_audit
prompt
"Output to File/Printer/MINE" = "MINE" ;* Enter or select the printer or file name
to send this report to.
, "Report Type" = "pos"
, "" = ""
, "" = ""
, "" = ""
, "" = ""
, "" = 0
, "" = 0
, "" = 0
, "" = 0
with OUTDEV,
rpt_type, rpt_pos, rpt_app, rpt_app_group, rpt_task, position, app,
app_group, task
/**************************************************************
; Global
Declarations
**************************************************************/
/**************************************************************
; Record
Structures
**************************************************************/
/**************************************************************
; Subroutines
**************************************************************/
/**************************************************************
; Main (where
we call the subroutines)
**************************************************************/
/**************************************************************
; Output
(place queries here)
**************************************************************/
SELECT
IF($rpt_type
= "pos" AND $rpt_pos = "Associated applications")
DISTINCT
position = UAR_GET_CODE_DISPLAY(ag.position_cd)
,position_status = UAR_GET_CODE_DISPLAY(pos.active_type_cd)
,application = a.description
,nbr_groups_with_app = COUNT(DISTINCT ag.app_group_cd) OVER (PARTITION
BY a.description)
,app_groups = LISTAGG(grp.display, ", ",
"OVERFLOW")
OVER(PARTITION BY a.description ORDER BY grp.display)
FROM APPLICATION_GROUP ag
,APPLICATION_ACCESS aa
,APPLICATION a
,CODE_VALUE grp
,CODE_VALUE pos
PLAN ag WHERE ag.position_cd = $position
AND ag.end_effective_dt_tm > SYSDATE
JOIN aa WHERE ag.app_group_cd = aa.app_group_cd
AND aa.active_ind = 1
JOIN a WHERE aa.application_number = a.application_number
AND a.active_ind = 1
JOIN grp WHERE ag.app_group_cd = grp.code_value
JOIN pos WHERE ag.position_cd = pos.code_value
ORDER BY position, CNVTUPPER(a.description)
ELSEIF($rpt_type
= "pos" AND $rpt_pos = "Associated application groups")
DISTINCT
position = UAR_GET_CODE_DISPLAY(ag.position_cd)
,position_status = UAR_GET_CODE_DISPLAY(pos.active_type_cd)
,application_group = UAR_GET_CODE_DISPLAY(ag.app_group_cd)
,nbr_apps_in_group = COUNT(DISTINCT aa.application_number)
OVER(PARTITION BY ag.app_group_cd)
FROM APPLICATION_GROUP ag
,APPLICATION_ACCESS aa
,CODE_VALUE pos
PLAN ag WHERE ag.position_cd = $position
AND ag.end_effective_dt_tm > SYSDATE
JOIN aa WHERE ag.app_group_cd = aa.app_group_cd
AND aa.active_ind = 1
JOIN pos WHERE ag.position_cd = pos.code_value
ORDER BY position, application_group
ELSEIF($rpt_type
= "pos" AND $rpt_pos = "Task extract")
position = UAR_GET_CODE_DISPLAY(ag.position_cd)
,position_status = UAR_GET_CODE_DISPLAY(pos.active_type_cd)
,app_group = UAR_GET_CODE_DISPLAY(ag.app_group_cd)
,application = a.description
,task = at.description
,task_description = at.text
,at.task_number
,ag.app_group_cd
,a.application_number
FROM APPLICATION_GROUP ag
,APPLICATION_ACCESS aa
,APPLICATION a
,APPLICATION_TASK_R atr
,APPLICATION_TASK at
,CODE_VALUE pos
PLAN ag WHERE ag.position_cd = $position
AND ag.end_effective_dt_tm > SYSDATE
JOIN aa WHERE ag.app_group_cd = aa.app_group_cd
AND aa.active_ind = 1
JOIN a WHERE aa.application_number = a.application_number
AND a.active_ind = 1
JOIN atr WHERE a.application_number = atr.application_number
JOIN at WHERE atr.task_number = at.task_number
AND at.active_ind = 1
JOIN pos WHERE ag.position_cd = pos.code_value
ORDER BY position, app_group, application, task
ELSEIF($rpt_type
= "app" AND $rpt_app = "Associated application groups")
DISTINCT
application = a.description
,application_group = UAR_GET_CODE_DISPLAY(ag.app_group_cd)
,ag.app_group_cd
,a.application_number
FROM APPLICATION a
,APPLICATION_ACCESS aa
,APPLICATION_GROUP ag
PLAN a WHERE a.application_number = $app
AND a.active_ind = 1
JOIN aa WHERE a.application_number = aa.application_number
AND aa.active_ind = 1
JOIN ag WHERE aa.app_group_cd = ag.app_group_cd
AND ag.end_effective_dt_tm > SYSDATE
ORDER BY CNVTUPPER(a.description), application_group
ELSEIF($rpt_type
= "app" AND $rpt_app = "Positions with access")
; known bug
here where app_groups listagg has some duplicates.
; The counts
are correct, and there are no incorrect values in app_groups
; Embedding
the listagg in a CTE works independently, but causes
; ORA-43918
error when you attempt to join to another table
DISTINCT
application = a.description
,position = UAR_GET_CODE_DISPLAY(ag.position_cd)
,position_status = UAR_GET_CODE_DISPLAY(pos.active_type_cd)
,nbr_groups = COUNT(DISTINCT ag.app_group_cd) OVER (PARTITION BY
ag.position_cd)
,app_groups = LISTAGG(grp.display, ", ",
"OVERFLOW")
OVER(PARTITION BY ag.position_cd ORDER BY grp.display)
FROM APPLICATION_GROUP ag
,APPLICATION_ACCESS aa
,APPLICATION a
,CODE_VALUE grp
,CODE_VALUE pos
PLAN ag WHERE 1=1
AND ag.app_group_cd IN (SELECT app_group_cd
FROM APPLICATION_ACCESS
WHERE application_number = $app
AND active_ind = 1)
JOIN aa WHERE ag.app_group_cd = aa.app_group_cd
AND aa.application_number = $app
JOIN a WHERE aa.application_number = a.application_number
JOIN grp WHERE ag.app_group_cd = grp.code_value
JOIN pos WHERE ag.position_cd = pos.code_value
ORDER BY CNVTUPPER(a.description), position
ELSEIF($rpt_type
= "app" AND $rpt_app = "Tasks")
application = a.description
,task = at.description
,description = at.text
,at.task_number
,a.application_number
FROM APPLICATION a
,APPLICATION_TASK_R atr
,APPLICATION_TASK at
PLAN a WHERE a.application_number = $app
AND a.active_ind = 1
JOIN atr WHERE a.application_number = atr.application_number
JOIN at WHERE atr.task_number = at.task_number
AND at.active_ind = 1
ORDER BY CNVTUPPER(a.description), task
ELSEIF($rpt_type
= "app_group" AND $rpt_app_group = "Associated
applications")
DISTINCT
application_group = UAR_GET_CODE_DISPLAY(ag.app_group_cd)
,application = a.description
,a.application_number
,ag.app_group_cd
FROM APPLICATION_GROUP ag
,APPLICATION_ACCESS aa
,APPLICATION a
PLAN ag WHERE ag.app_group_cd = $app_group
AND ag.end_effective_dt_tm > SYSDATE
JOIN aa WHERE ag.app_group_cd = aa.app_group_cd
AND aa.active_ind = 1
JOIN a WHERE aa.application_number = a.application_number
AND a.active_ind = 1
ORDER BY application_group, CNVTUPPER(a.description)
ELSEIF($rpt_type
= "app_group" AND $rpt_app_group = "Positions with access")
DISTINCT
application_group = UAR_GET_CODE_DISPLAY(ag.app_group_cd)
,position = UAR_GET_CODE_DISPLAY(ag.position_cd)
,position_status = UAR_GET_CODE_DISPLAY(pos.active_type_cd)
,nbr_apps_in_group = COUNT(DISTINCT aa.application_number)
OVER(PARTITION BY ag.position_cd)
FROM APPLICATION_GROUP ag
,APPLICATION_ACCESS aa
,CODE_VALUE pos
PLAN ag WHERE ag.app_group_cd = $app_group
AND ag.end_effective_dt_tm > SYSDATE
JOIN aa WHERE ag.app_group_cd = aa.app_group_cd
AND aa.active_ind = 1
JOIN pos WHERE ag.position_cd = pos.code_value
ORDER BY application_group, position
ELSEIF($rpt_type
= "task" AND $rpt_task = "Associated
applications")
DISTINCT
task = at.description
,description = at.text
,at.task_number
,application = a.description
,a.application_number
FROM APPLICATION_TASK at
,APPLICATION_TASK_R atr
,APPLICATION a
PLAN at WHERE at.task_number = $task
AND at.active_ind = 1
JOIN atr WHERE at.task_number = atr.task_number
JOIN a WHERE atr.application_number = a.application_number
AND a.active_ind = 1
ORDER BY task, CNVTUPPER(a.description)
ELSEIF($rpt_type
= "task" AND $rpt_task = "Associated application groups")
DISTINCT
task = at.description
,description = at.text
,at.task_number
,application_group = UAR_GET_CODE_DISPLAY(ag.app_group_cd)
,application = a.description
,a.application_number
FROM APPLICATION_TASK at
,APPLICATION_TASK_R atr
,APPLICATION a
,APPLICATION_ACCESS aa
,APPLICATION_GROUP
ag
PLAN at WHERE at.task_number = $task
AND at.active_ind = 1
JOIN atr WHERE at.task_number = atr.task_number
JOIN a WHERE atr.application_number = a.application_number
AND a.active_ind = 1
JOIN aa WHERE a.application_number = aa.application_number
JOIN ag WHERE aa.app_group_cd = ag.app_group_cd
AND ag.end_effective_dt_tm > SYSDATE
ORDER BY task, application_group, CNVTUPPER(a.description)
ELSEIF($rpt_type
= "task" AND $rpt_task = "Positions with access")
DISTINCT
task = at.description
,description = at.text
,at.task_number
,position = UAR_GET_CODE_DISPLAY(ag.position_cd)
,position_status = UAR_GET_CODE_DISPLAY(pos.active_type_cd)
FROM APPLICATION_TASK at
,APPLICATION_TASK_R atr
,APPLICATION a
,APPLICATION_ACCESS aa
,APPLICATION_GROUP ag
,CODE_VALUE pos
PLAN at WHERE at.task_number = $task
AND at.active_ind = 1
JOIN atr WHERE at.task_number = atr.task_number
JOIN a WHERE atr.application_number = a.application_number
AND a.active_ind = 1
JOIN aa WHERE a.application_number = aa.application_number
JOIN ag WHERE aa.app_group_cd = ag.app_group_cd
AND ag.end_effective_dt_tm > SYSDATE
JOIN pos WHERE ag.position_cd = pos.code_value
ORDER BY task, position
ENDIF
INTO $OUTDEV
error = "Invalid prompt selections"
WITH
NOCOUNTER, SEPARATOR=" ", FORMAT, CHECK, TIME=90
end
go
