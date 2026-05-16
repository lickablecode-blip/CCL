/*
* Name:     Task by Location
* Source:   Inbox/PowerForms/Task by Location.txt
* Purpose:
* Imported: 2026-05-15
* Category: PowerForms  (reason: subfolder)
* Lines:    1
* Notes:
*/

select der.dcp_entity_reltn_id, der.entity1_id, der.entity1_name, der.entity2_id, der.entity2_name from dcp_entity_reltn der where der.active_ind = 1 and der.entity_reltn_mean = "TASK/LOC" go
