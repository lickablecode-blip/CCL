/*
* Name:     Printers_Audit
* Source:   Inbox/PathNet/Printers_Audit.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    11
* Notes:
*/

select
Output_Dest_Cd,
Device_Cd,
Name,
Description,
Label_Prefix,
Label_Program_Name,
Label_XPOS,
Label_YPOS

from output_dest
go
