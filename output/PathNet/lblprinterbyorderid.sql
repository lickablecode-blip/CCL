/*
* Name:     lblPrinterByOrderID
* Source:   Inbox/PathNet/lblPrinterByOrderID.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    15
* Notes:
*/

select  
	orderable = uar_get_code_display (n.catalog_cd),
	n.collection_dt_tm,
	n.accession,
	collection_priority = uar_get_code_display (n.collection_priority_cd),
	report_priority = uar_get_code_display (n.report_priority_cd),
	printer_name = o.name,
	printer_description = o.description
from 
	netting n,
	output_dest o

plan n
	where n.order_id = XXXXX ;enter your order_id 

join o
	where o.output_dest_cd = n.label_printer_id
