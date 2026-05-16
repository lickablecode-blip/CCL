/*
* Name:     Advanced_Delta_Audit
* Source:   Inbox/PathNet/Advanced_Delta_Audit.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    55
* Notes:
*/

select 
	dta.mnemonic,
	rrf.reference_range_factor_id,
	dm.max_digits,
	dm.min_digits,
	dm.min_decimal_places,
	Sequence = rrf.precedence_sequence,
	Service_Resource = uar_get_code_display( rrf.service_resource_cd ),
	Sex = uar_get_code_display( rrf.sex_cd ),
	Species = uar_get_code_display( rrf.species_cd ),
	Specimen_Type = uar_get_code_display( rrf.specimen_type_cd ),
	rrf.unknown_age_ind,
	rrf.age_from_minutes,
	Age_from_Units = uar_get_code_display( rrf.age_from_units_cd ),
	rrf.age_to_minutes,
	Age_to_Units = uar_get_code_display( rrf.age_to_units_cd ),
	rrf.normal_low,
	rrf.normal_high,
	rrf.critical_low,
	rrf.critical_high,
	rrf.review_low,
	rrf.review_high,
	rrf.feasible_low,
	rrf.feasible_high,
	rrf.linear_low,
	rrf.linear_high,
	Units_of_Measure = uar_get_code_display( rrf.units_cd ),
	Delta_check_type = uar_get_code_display( rrf.delta_check_type_cd),
	rrf.delta_chk_flag,
	rrf.delta_minutes,
	rrf.delta_value,
	Advanced_Delta_Low=ad.delta_low,
	Advanced_Delta_High=ad.delta_high,
	Advanced_Delta_Check_Type=uar_get_code_display(ad.delta_check_type_cd),
	Advanced_Delta_Minutes=ad.delta_minutes,
	Advanced_Delta_Value=ad.delta_value


 
from	discrete_task_assay  dta,
          data_map  dm,
            reference_range_factor  rrf,
		      (left join advanced_delta ad on rrf.reference_range_factor_id=ad.reference_range_factor_id and ad.active_ind=1)
 
plan dta
  where dta.activity_type_cd = 692.00
    and dta.active_ind = 1
 
join dm
  where dm.task_assay_cd = dta.task_assay_cd
    and dm.active_ind = 1
      and dm.data_map_type_flag = 0
 
join rrf
  where rrf.task_assay_cd = dm.task_assay_cd
    and rrf.service_resource_cd = dm.service_resource_cd
      and rrf.active_ind = 1

join ad
  
     
 
order by	dta.mnemonic,
                  rrf.precedence_sequence

go
