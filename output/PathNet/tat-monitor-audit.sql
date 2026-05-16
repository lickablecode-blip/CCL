/*
* Name:     TAT_Monitor_audit
* Source:   Inbox/PathNet/TAT_Monitor_audit.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    11
* Notes:
*/

Select 
	
        Service_resource = uar_get_code_display(Service_resource_cd),
        Rpt_Priority = uar_get_code_display(rep_priority_cd),
        Orderable = uar_get_code_display(catalog_cd),
	display_min,
	warning_min,
	alert_min

From
	plm_tat_parameter
	
where active_ind = 1
go
