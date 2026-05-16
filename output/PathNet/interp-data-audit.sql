/*
* Name:     interp data audit
* Source:   Inbox/PathNet/interp data audit.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    10
* Notes:
*/

select
  task_assay = uar_get_code_display(id.task_assay_cd),
service_resource=uar_get_code_display(id.service_resource_cd),
interp_data = lt.long_text
 
from
  interp_data id,
  long_text lt

plan id where id.active_ind = 1

join lt where lt.long_text_id = id.long_text_id

order by task_assay, service_resource
