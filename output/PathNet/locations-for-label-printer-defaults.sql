/*
* Name:     locations for label printer defaults
* Source:   Inbox/PathNet/locations for label printer defaults.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    19
* Notes:
*/

select lo.organization_id,
	org.org_name,
       lo.location_cd,
       cv.display,
       cv.description
       
from location lo,
      code_value cv,
	organization org
      

plan lo
	where lo.active_ind = 1
	and lo.location_type_cd in (772, 794)
	and lo.organization_id = XXXXXX	

	
join cv
	where cv.code_value = lo.location_cd
	and lo.active_ind = 1

join org
	where org.organization_id=lo.organization_id
	
order by org.org_name, cv.display
	

go
