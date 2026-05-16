/*
* Name:     QC_manufactor_audit
* Source:   Inbox/PathNet/QC_manufactor_audit.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    8
* Notes:
*/

select
	cv.display

from
	code_value cv

where cv.code_set = 1908
  and cv.code_value > 0
  and cv.active_ind = 1

order by cv.display
