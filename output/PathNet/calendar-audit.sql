/*
* Name:     calendar_audit
* Source:   Inbox/PathNet/calendar_audit.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    32
* Notes:
*/

select
	service_resource = uar_get_code_display( lrc.service_resource_cd),
	location = uar_get_code_display(lrc.location_cd),
	LOC_RESOURCE_TYPE_CD = uar_get_code_display(lrc.loc_resource_type_cd),          
        lrc.UPDT_CNT,                
        lrc.UPDT_DT_TM,              
        lrc.UPDT_ID,                   
        lrc.UPDT_TASK,                   
        lrc.UPDT_APPLCTX,              
        lrc.CALENDAR_SEQ,                   
        lrc.DOW,                           
        PRIORITY_CD = uar_get_code_display(lrc.priority_cd),                  
        lrc.OPEN_TIME,                      
        lrc.CLOSE_TIME,                     
        lrc.AVAIL_IND,                      
        lrc.DESCRIPTION,                    
        lrc.BEG_EFFECTIVE_DT_TM,           
        lrc.END_EFFECTIVE_DT_TM,          
        lrc.ACTIVE_IND,                  
        lrc.ACTIVE_STATUS_CD,            
        lrc.ACTIVE_STATUS_DT_TM,      
        lrc.ACTIVE_STATUS_PRSNL_ID,       
        SPECIMEN_TYPE_CD = uar_get_code_display(lrc.specimen_type_cd),               
        lrc.SEQUENCE,                    
        lrc.DISPENSE_TYPE_CD,            
        lrc.AGE_FROM_MINUTES,        
        AGE_FROM_UNITS_CD = uar_get_code_display(lrc.age_from_units_cd),          
        lrc.AGE_TO_MINUTES,          
        AGE_TO_UNITS_CD = uar_get_code_display(lrc.age_to_units_cd)

from loc_resource_calendar lrc

where lrc.active_ind = 1

order by service_resource, calendar_seq
