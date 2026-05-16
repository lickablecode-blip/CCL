/*
* Name:     Tasks by Task Type by Task Name
* Source:   Inbox/PowerForms/Tasks by Task Type by Task Name.txt
* Purpose:
* Imported: 2026-05-15
* Category: PowerForms  (reason: subfolder)
* Lines:    14
* Notes:
*/

;Tasks by task type
SELECT 
 
O.ACTIVE_IND
 
, O_EVENT_DISP = UAR_GET_CODE_DISPLAY(O.EVENT_CD)
 
, O_TASK_ACTIVITY_DISP = UAR_GET_CODE_DISPLAY(O.TASK_ACTIVITY_CD)
 
, O.TASK_DESCRIPTION
 
, O.TASK_DESCRIPTION_KEY
 
, O_TASK_TYPE_DISP = UAR_GET_CODE_DISPLAY(O.TASK_TYPE_CD)
 
, o.task_type_cd
 
FROM 
 
ORDER_TASK O
 
where o.active_ind = 1 
 
and o.task_description = "pulse ox*" 
 
WITH time = 240, NOCOUNTER, SEPARATOR=" ", FORMAT
