/*
* Name:     Spec_Containers_Audit
* Source:   Inbox/PathNet/Spec_Containers_Audit.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    15
* Notes:
*/

select 
	sc_spec_cntnr_disp = uar_get_code_display( sc.spec_cntnr_cd ),
	sc_spec_cntnr_desc = uar_get_code_description( sc.spec_cntnr_cd ),
	scv.volume,
	sc_volume_units_disp = uar_get_code_display( sc.volume_units_cd )

from
	specimen_container  sc,
	specimen_container_volume  scv

plan sc
where sc.spec_cntnr_cd > 0

join scv
where scv.spec_cntnr_cd = sc.spec_cntnr_cd

order by	sc_spec_cntnr_disp,
			scv.volume
go
