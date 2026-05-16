/*
* Name:     ESH - Contents of Grouper
* Source:   Inbox/mPages/ESH - Contents of Grouper.txt
* Purpose:
* Imported: 2026-05-15
* Category: MPages  (reason: subfolder)
* Lines:    21
* Notes:
*/

select
c.event_cd,
c.event_cd_disp,
c.event_set_name,
x.event_set_level
from
v500_event_code c,
v500_event_set_explode x
plan x
where x.event_set_cd in
(
select event_set_cd from v500_event_set_code
where event_set_cd_disp in
(
"Allergy Testing" ;Display name of ESH grouper
)
)
join c
where c.event_cd = x.event_cd
with format(date,";;q")
Go
