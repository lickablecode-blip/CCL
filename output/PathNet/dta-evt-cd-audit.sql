/*
* Name:     DTA_evt_cd audit
* Source:   Inbox/PathNet/DTA_evt_cd audit.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    14
* Notes:
*/

select dta.task_assay_cd,
       dta.mnemonic,
       dta.description,
       event_code = uar_get_code_display(cvr.event_cd),
       cvr.event_cd

from discrete_task_assay dta,
code_value_event_r cvr

plan dta where
dta.activity_type_cd = 692 and
dta.active_ind = 1

join cvr where
cvr.parent_cd = dta.task_assay_cd

order dta.description asc
go
