/*
* Name:     Distinct list of DTA and code values
* Source:   Inbox/PathNet/Distinct list of DTA and code values.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    2
* Notes:
*/

Select mnemonic,task_assay_cd from discrete_task_assay 

where activity_type_cd = 692 and active_ind = 1 go
