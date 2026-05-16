/*
* Name:     Label Printer Audit
* Source:   Inbox/PathNet/Label Printer Audit.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    33
* Notes:
*/

select  DEVICE_CD=p.device_cd,
		OUTPUT_DEST_CD=od.output_dest_cd,
		PRINTER_NAME=od.name,
  		PRINTER_DESCRIPTION=od.description,
  		PRINTER_TYPE = UAR_GET_CODE_DISPLAY(p.printer_type_cd),
 		LABEL_PREFIX=od.label_prefix,
  		LABEL_PROGRAM=od.label_program_name,
  		CUSTOM_FORM=p.default_custom_form_name,
  		X_POSITION=od.label_xpos,
  		Y_POSITION=od.label_ypos
  
from    output_dest od,
  		printer p,
  		dummyt d1
plan p
where  p.printer_type_cd in (
(OUTERJOIN(VALUE(UAR_GET_CODE_BY("MEANING", 3003, "16")))), 
(OUTERJOIN(VALUE(UAR_GET_CODE_BY("MEANING", 3003, "18")))), 
(OUTERJOIN(VALUE(UAR_GET_CODE_BY("MEANING", 3003, "19")))), 
(OUTERJOIN(VALUE(UAR_GET_CODE_BY("MEANING", 3003, "20")))), 
(OUTERJOIN(VALUE(UAR_GET_CODE_BY("MEANING", 3003, "24")))), 
(OUTERJOIN(VALUE(UAR_GET_CODE_BY("MEANING", 3003, "27")))), 
(OUTERJOIN(VALUE(UAR_GET_CODE_BY("MEANING", 3003, "31")))), 
(OUTERJOIN(VALUE(UAR_GET_CODE_BY("MEANING", 3003, "32")))),
(OUTERJOIN(VALUE(UAR_GET_CODE_BY("MEANING", 3003, "39")))), 
(OUTERJOIN(VALUE(UAR_GET_CODE_BY("MEANING", 3003, "40")))), 
(OUTERJOIN(VALUE(UAR_GET_CODE_BY("MEANING", 3003, "42")))),
(OUTERJOIN(VALUE(UAR_GET_CODE_BY("MEANING", 3003, "43"))))
)  

join d1

join od
where p.device_cd=od.device_cd




order by PRINTER_NAME,LABEL_PREFIX,LABEL_PROGRAM

WITH OUTERJOIN=D1,MAXREC = 9999, NOCOUNTER, SEPARATOR=" ", FORMAT
