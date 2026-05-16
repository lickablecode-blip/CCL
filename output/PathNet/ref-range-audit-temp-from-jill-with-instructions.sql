/*
* Name:     Ref Range Audit - Temp from Jill with Instructions
* Source:   Inbox/PathNet/Ref Range Audit - Temp from Jill with Instructions.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    69
* Notes:
*/

select  
dta = dta.mnemonic  
, service_resource = if(rrf.service_resource_cd = 0) "All"  
else uar_get_code_display(rrf.service_resource_cd)  
endif  
, dm.max_digits  
, dm.min_digits  
, dm.min_decimal_places  
, uom = uar_get_code_display(rrf.units_cd)  
, sex = if(rrf.sex_cd = 0) "All"  
else uar_get_code_display(rrf.sex_cd)  
endif  
, age_from = if(rrf.age_from_minutes between 0 and 1440) concat(trim(cnvtstring(rrf.age_from_minutes/60),3)," hrs")  
elseif(rrf.age_from_minutes between 1441 and 10080) concat(trim(cnvtstring(rrf.age_from_minutes/1440),3)," days")  
elseif(rrf.age_from_minutes between 10081 and 43800) concat(trim(cnvtstring(rrf.age_from_minutes/10080),3)," weeks")  
elseif(rrf.age_from_minutes between 43800 and 525600) concat(trim(cnvtstring(rrf.age_from_minutes/43800),3)," months")  
elseif(rrf.age_from_minutes > 525600) concat(trim(cnvtstring(rrf.age_from_minutes/525600),3)," years")  
endif  
, age_to = if(rrf.age_to_minutes between 0 and 1440) concat(trim(cnvtstring(rrf.age_to_minutes/60),3)," hrs")  
elseif(rrf.age_to_minutes between 1441 and 10080) concat(trim(cnvtstring(rrf.age_to_minutes/1440),3)," days")  
elseif(rrf.age_to_minutes between 10081 and 43800) concat(trim(cnvtstring(rrf.age_to_minutes/10080),3)," weeks")  
elseif(rrf.age_to_minutes between 43800 and 525600) concat(trim(cnvtstring(rrf.age_to_minutes/43800),3)," months")  
elseif(rrf.age_to_minutes > 525600) concat(trim(cnvtstring(rrf.age_to_minutes/525600),3)," years")  
endif  
, num_ref_low = rrf.normal_low 
, num_ref_high = rrf.normal_high 
, num_crit_low = rrf.critical_low 
, num_crit_high = rrf.critical_high 
, num_feas_low = rrf.feasible_low 
, num_feas_high = rrf.feasible_high 
, num_review_low = rrf.review_low 
, num_review_high = rrf.review_high 
, num_lin_low = rrf.linear_low 
, num_lin_high = rrf.linear_high 
, num_dilute_ind = rrf.dilute_ind  
, alpha_response = n.mnemonic 
, alpha_use_units = if(ar.use_units_ind = 0) "No" 
elseif (ar.use_units_ind = 1) "Yes" 
endif 
, alpha_default_ind = if(ar.default_ind = 0) "No" 
elseif (ar.default_ind = 1) "Yes" 
endif 
, alpha_ref_indicator = if(ar.reference_ind = 0) "No" 
elseif (ar.reference_ind = 1) "Yes" 
endif 
, alpha_flag = uar_get_code_description(ar.result_process_cd) 
  
from  
  
discrete_task_assay dta  
, reference_range_factor rrf  
, data_map dm  
, alpha_responses ar 
, nomenclature n 
plan dta  
where dta.active_ind = 1  
join rrf  
where rrf.task_assay_cd = dta.task_assay_cd  
And rrf.service_resource_cd = 271590389 ;enter service resource code value here  
and rrf.active_ind = 1 
join dm  
where dm.task_assay_cd = rrf.task_assay_cd  
and dm.service_resource_cd = rrf.service_resource_cd  
join ar 
where ar.reference_range_factor_id = rrf.reference_range_factor_id 
join n 
where n.nomenclature_id = ar.nomenclature_id 
order by  
dta.mnemonic, ar.sequence 
with time = 30, format(date,"mm/dd/yyyy hh:mm ;;d") 


You have to use the service_resource_code which is annoying (right click in location.exe to get the code, or search for it in 220), but my brain wasn’t working on how to pull by service resource display
