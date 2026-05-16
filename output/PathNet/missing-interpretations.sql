/*
* Name:     Missing_Interpretations
* Source:   Inbox/PathNet/Missing_Interpretations.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    9
* Notes:
*/

; This looks for GenLab assays that are active with a default result type of Interp 
; but have no active rows on the Interp Tables.

select
Task_assay_cd,
DTA = uar_get_code_display(task_assay_cd)

from discrete_task_assay
where activity_type_cd = 692 and active_ind = 1
and default_result_type_cd = 882
and task_assay_cd not in (select task_assay_cd from interp_task_assay where active_ind = 1)
