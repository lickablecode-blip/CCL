/*
* Name:     QC_numeric_audit
* Source:   Inbox/PathNet/QC_numeric_audit.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    33
* Notes:
*/

select Distinct
	cm.short_description,
	rar_service_resource_disp = uar_get_code_display( rar.service_resource_cd ),
	arl_task_assay_disp = uar_get_code_display( arl.task_assay_cd ),
	qrt.short_description,
	arl.mean,
	arl.statistical_std_dev,
	dm.min_decimal_places

from	control_material  cm,
		control_lot  cl,
		resource_accession_r  rar,
		resource_lot_r  rlr,
		assay_resource_lot  arl,
		data_map  dm,
		qc_rule_type  qrt
	
plan cm
  where cm.control_id > 0 

join cl
  where cl.control_id = cm.control_id
    and cl.expiration_dt_tm >= cnvtdatetime(curdate, curtime3)  ;pull only active information

join rar
  where rar.control_id = cl.control_id

join rlr
  where rlr.lot_id = cl.lot_id

join arl
  where arl.lot_id = rlr.lot_id

join dm
  where arl.task_assay_cd = dm.task_assay_cd

 
join qrt
  where arl.rule_id = qrt.rule_id

order by	cm.short_description,
			rar_service_resource_disp,
			arl_task_assay_disp
