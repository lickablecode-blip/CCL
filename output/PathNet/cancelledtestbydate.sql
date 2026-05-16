/*
* Name:     CancelledTestByDate
* Source:   Inbox/PathNet/CancelledTestByDate.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    31
* Notes:
*/

SELECT 
	p.name_last,
	p.name_first,
	aor.ACCESSION,
	o.order_mnemonic,
	O_ORDER_STATUS_DISP = UAR_GET_CODE_DISPLAY(O.ORDER_STATUS_CD),
	nurse_unit = uar_get_code_display (e.LOC_NURSE_UNIT_CD),
	cancel_reason = uar_get_code_display (omf.cancel_reason_cd)
	
FROM
    orders o, 
    encounter e,
    accession_order_r aor,
    omf_order_st omf, 
    person p
	
plan o where 
	o.updt_dt_tm > cnvtdatetime("15-NOV-2009 20:00:00") ;enter your date here
	and o.activity_type_cd in (692, 674, 696, 671) ;genlab, blood bank, micro, AP
	and o.order_status_cd = 2542 ;cancelled
    
	
join omf where 
	omf.order_id = o.order_id
	and omf.orig_order_dt_tm > cnvtdatetime("15-NOV-2009 00:00:00") ;original order dt_tm
	and omf.cancel_dt_tm between cnvtdatetime("17-NOV-2009 20:00:00") and cnvtdatetime("17-NOV-2009 20:10:00") ;cancel time window
	and omf.cancel_reason_cd = 678503 ;Lab Operations Cancel, your code_value may be different
	
join e where
	e.encntr_id = o.encntr_id
	and e.loc_facility_cd = 4363216 ;enter facility here    
	
join p where
	p.person_id = e.person_id

join aor where
	aor.order_id = o.order_id
	
order by p.name_last, p.name_first, aor.accession
