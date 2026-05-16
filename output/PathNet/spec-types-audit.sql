/*
* Name:     Spec_Types_Audit
* Source:   Inbox/PathNet/Spec_Types_Audit.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    10
* Notes:
*/

select into "nl:"
	cv1.display,
	cv1.code_value

from
	code_value  cv1

where cv1.code_value > 0
  and cv1.code_set = 2052
  and cv1.cdf_meaning != "RADIOLOGY"

order by	cv1.display
go
