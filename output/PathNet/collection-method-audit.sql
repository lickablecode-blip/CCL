/*
* Name:     Collection_Method_Audit
* Source:   Inbox/PathNet/Collection_Method_Audit.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    7
* Notes:
*/

select into "nl:"
	cv.display

from code_value  cv

where cv.code_set = 2058 
  and cv.display_key != "APSPECIMEN"
  and cv.active_ind = 1

order by cv.display
