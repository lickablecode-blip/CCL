/*
* Name:     Cancel_Reason
* Source:   Inbox/PathNet/Cancel_Reason.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    9
* Notes:
*/

select 
	cv.display,
	cv.description

from
	code_value cv

where cv.code_set = 1309
  and cv.active_ind = 1

order by	cv.display
go
