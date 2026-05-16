/*
* Name:     QC_alpha_audit
* Source:   Inbox/PathNet/QC_alpha_audit.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    33
* Notes:
*/

select 
	cm.short_description,
	rar_service_resource_disp = uar_get_code_display( rar.service_resource_cd ),
	arl_task_assay_disp = uar_get_code_display( arl.task_assay_cd ),
	n.mnemonic,
	Normalcy = cv1.description

from	control_material  cm,
		control_lot  cl,
		resource_accession_r  rar,
		assay_resource_lot  arl,
		qc_alpha_responses  qar,
		nomenclature  n,
		code_value cv1
	
plan cm
  where cm.control_id > 0

join cl
  where cl.control_id = cm.control_id
    and cl.expiration_dt_tm >= cnvtdatetime(curdate, curtime3)  ;pull only active information


join rar
  where rar.control_id = cl.control_id
  and rar.preactive_ind = 0

join arl
  where arl.lot_id = cl.lot_id

join qar
  where qar.control_id = rar.control_id

join n
  where n.nomenclature_id = qar.nomenclature_id

join cv1
  where cv1.code_value = qar.result_process_cd
  	and cv1.code_set = 1902

order by	cm.short_description,
			rar_service_resource_disp,
			arl_task_assay_disp
