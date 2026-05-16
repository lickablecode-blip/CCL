/*
* Name:     QC_troubleshoot_audit
* Source:   Inbox/PathNet/QC_troubleshoot_audit.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    15
* Notes:
*/

select into "nl:"
	qts_service_resource_disp = uar_get_code_display( qts.service_resource_cd ),
	qts.error_flag,
	qts.step,
	qts.step_nbr,
	qts_task_assay_disp = uar_get_code_display( qts.task_assay_cd ),
	qts.trouble_id

from
	qc_trouble_step  qts

where qts.active_ind = 1

order by	qts_service_resource_disp,
			qts_task_assay_disp,
			qts.error_flag,
			qts.step_nbr
go
