/*
* Name:     Service_Resources_Audit
* Source:   Inbox/PathNet/Service_Resources_Audit.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    69
* Notes:
*/

select 
	sr_service_resource_type_disp = uar_get_code_display( sr.service_resource_type_cd ),
	d_service_resource_disp = uar_get_code_display( d.service_resource_cd ),
	d.service_resource_cd,
	rg.sequence,
	sr1_service_resource_disp = uar_get_code_display( sr1.service_resource_cd ),
	sr1_service_resource_desc = uar_get_code_description( sr1.service_resource_cd ),
	sr1.service_resource_cd,
	sr1_service_resource_type_disp = uar_get_code_display( sr1.service_resource_type_cd ),
	sr1_discipline_type_disp = uar_get_code_display( sr1.discipline_type_cd ),
	sr1_activity_type_disp = uar_get_code_display( sr1.activity_type_cd ),
	rg1.sequence,
	sr2_service_resource_disp = uar_get_code_display( sr2.service_resource_cd ),
	sr2_service_resource_desc = uar_get_code_description( sr2.service_resource_cd ),
	sr2.service_resource_cd,
	sr2_service_resource_type_disp = uar_get_code_display( sr2.service_resource_type_cd ),
	s.multiplexor_ind,
	rg2.sequence,
	sr3_service_resource_disp = uar_get_code_display( sr3.service_resource_cd ),
	sr3_service_resource_desc = uar_get_code_description( sr3.service_resource_cd ),
	sr3.service_resource_cd,
	sr3.service_resource_type_cd 

from
	service_resource  sr,
	department  d,
	resource_group  rg,
	service_resource  sr1,
	resource_group  rg1,
	service_resource  sr2,
	sub_section  s,
	resource_group  rg2,
	service_resource  sr3

plan sr							;Department SR
where sr.service_resource_type_cd = 824
  and sr.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime3)
  and sr.end_effective_dt_tm >= cnvtdatetime(curdate, curtime3)
  and sr.active_ind = 1

join d
where d.service_resource_cd = sr.service_resource_cd

join rg
where rg.parent_service_resource_cd = sr.service_resource_cd

join sr1						;Section SR
where sr1.service_resource_cd = rg.child_service_resource_cd
  and sr1.activity_type_cd = 692
  and sr1.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime3)
  and sr1.end_effective_dt_tm >= cnvtdatetime(curdate, curtime3)
  and sr1.active_ind = 1

join rg1
where rg1.parent_service_resource_cd = sr1.service_resource_cd

join sr2						;Sub-section SR
where sr2.service_resource_cd = rg1.child_service_resource_cd
  and sr2.activity_type_cd = 692
  and sr2.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime3)
  and sr2.end_effective_dt_tm >= cnvtdatetime(curdate, curtime3)
  and sr2.active_ind = 1

join s
where s.service_resource_cd = sr2.service_resource_cd

join rg2
where rg2.parent_service_resource_cd = sr2.service_resource_cd

join sr3						;Bench/Instrument SR
where sr3.service_resource_cd = rg2.child_service_resource_cd
  and sr3.activity_type_cd = 692
  and sr3.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime3)
  and sr3.end_effective_dt_tm >= cnvtdatetime(curdate, curtime3)

order by	d_service_resource_disp,
			sr1_service_resource_disp,
			sr2_service_resource_disp,
			sr3_service_resource_disp
GO
