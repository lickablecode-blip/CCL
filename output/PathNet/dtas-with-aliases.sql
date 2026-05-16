/*
* Name:     dtas with aliases
* Source:   Inbox/PathNet/dtas with aliases.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    16
* Notes:
*/

select
	dta.task_assay_cd,
	dta.description,
	dta.mnemonic,
	cva.alias
	cva.contributor_source_cd = uar_get_code_display(cva.contributor_source_cd )

from	discrete_task_assay  dta,
		code_value_alias cva
		
plan dta
  where dta.activity_type_cd = 692
    and dta.active_ind = 1
   
    
join cva
	where cva.code_value = dta.task_assay_cd
	and cva.contributor_source_cd = XXXXXX 
	and cva.code_set = 14003
	
order dta.description
