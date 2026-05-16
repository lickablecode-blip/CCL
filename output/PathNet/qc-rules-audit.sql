/*
* Name:     QC_rules_audit
* Source:   Inbox/PathNet/QC_rules_audit.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    18
* Notes:
*/

select 
	qrt.short_description,
	qr.trig_ind,
	qr.rule_form_flag,
	qr.rule_definition,
	qr.error_flag,
	qr.sequence

from
	qc_rule_type  qrt,
	qc_rule  qr

plan qrt
where qrt.rule_id > 0
  and qrt.active_ind = 1

join qr
where qr.rule_id = qrt.rule_id
  and qr.active_ind = 1

order by	qrt.short_description,
			qr.sequence
