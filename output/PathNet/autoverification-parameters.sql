/*
* Name:     Autoverification parameters
* Source:   Inbox/PathNet/Autoverification parameters.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    22
* Notes:
*/

select  
         service_resource = uar_get_code_display(av.service_resource_cd),
         task_assay= uar_get_code_display(av.task_assay_cd),
         av.PREV_VERF_IND,
         av.DUP_ASSAY_IND,                   
         av.UNVERF_PREV_RSLT_IND,           
         av.REF_RANGE_IND,
         av.REV_RANGE_IND,
         av.CRIT_RANGE_IND,
	 av.NOTIFY_RANGE_IND,
         av.FEAS_RANGE_IND,
         av.LIN_RANGE_IND,
         av.DELTA_CHK_FLAG,     
         av.INSTR_ERROR_CODE_IND,           
         av.AV_STATUS_FLAG,  
         av.VALIDATE_QC_SCHEDULE_IND,       
         av.QC_INSTR_ERROR_CODE_IND

from auto_verify av

plan av
	where av.active_ind = 1
	
order by service_resource, task_assay

Go
