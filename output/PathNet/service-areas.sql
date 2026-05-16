/*
* Name:     Service_Areas
* Source:   Inbox/PathNet/Service_Areas.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    18
* Notes:
*/

select distinct 
   Service_area= uar_get_code_display(l.location_cd),
   AMB_NURSE_LOGIN=uar_get_code_display(lg.child_loc_cd), 
   location_type=uar_get_code_display(l2.LOCATION_TYPE_CD)
   from 
      location l, 
      location_group lg,
      location l2,
      dummyt d1
   plan l where l.location_type_cd = 805 ;(Service Area from codeset 222
      and l.DISCIPLINE_TYPE_CD= 2513 ;Laboratory from codeset 6000
      and l.active_ind = 1
   join d1
   join lg where lg.parent_loc_cd = l.location_cd and lg.active_ind = 1 
   join l2 where l2.location_cd = lg.child_loc_cd
   
   order by Service_area, location_type,AMB_NURSE_LOGIN
   with outerjoin=d1
go
