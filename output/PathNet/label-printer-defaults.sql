/*
* Name:     Label_Printer_Defaults
* Source:   Inbox/PathNet/Label_Printer_Defaults.TXT
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    24
* Notes:
*/

;Any rows showing Blank for Service Resource or Collection Priority should be replaced with ALL.
;Blank Printers should be replaced with NONE.
;This will pull the Specimen Label Routing. For Aliquot Label Defaults, change lpd.default_type_flag = 1


Select
Facility=org.Org_name,
lpd.Location_CD,
Location_Name = uar_get_code_display(lpd.Location_cd),
lpd.Service_Resource_CD,
Service_Resource = uar_get_code_display(lpd.service_resource_cd),
Collection_Priority = uar_get_code_display(lpd.coll_priority_cd),
Printer = lpd.Lbl_queue_name,
Nurse_Collect_Printer = lpd.Nurse_queue_name

from Label_printer_def lpd,
Location loc,
Organization org

Plan lpd
where lpd.active_ind =1
and lpd.default_type_flag = 0

Join loc
where lpd.location_cd = loc.location_cd

Join org
where org.organization_id = loc.organization_id

order by Facility,Location_name
go
