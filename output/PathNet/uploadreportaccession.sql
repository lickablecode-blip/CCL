/*
* Name:     uploadReportAccession
* Source:   Inbox/PathNet/uploadReportAccession.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    9
* Notes:
*/

select hd.accession,
       hu.report_nbr,
       hu.upload_dt_tm
     
from handheld_detail hd,
     handheld_upload hu

plan hd
where hd.accession = "00000YYYYDDD######"; your accession here

join hu
where hd.handheld_upload_id = hu.handheld_upload_id
