/*
* Name:     Lab_Layout
* Source:   Inbox/PathNet/Lab_Layout.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    10
* Notes:
*/

Select cdf_meaning,display,description 
from code_value where code_set = 221
And active_ind = 1 and 
CDF_meaning in 
("BENCH",
"INSTRUMENT",
"SUBSECTION",
"SECTION",
"DEPARTMENT",
"INSTITUTION") go
