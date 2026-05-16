/*
* Name:     Allergy Reactions
* Source:   Inbox/mPages/Allergy Reactions.txt
* Purpose:
* Imported: 2026-05-15
* Category: MPages  (reason: subfolder)
* Lines:    10
* Notes:
*/

SELECT 	
	n.source_string
	,n.source_identifier
	,vocabulary = UAR_GET_CODE_DISPLAY(n.source_vocabulary_cd)
	,n.nomenclature_id
	
FROM NOMENCLATURE n	
	
PLAN n WHERE n.source_vocabulary_cd = 55518149 ;ALLERGY REACTION	
	AND n.active_ind = 1
ORDER BY n.source_string	
WITH TIME=30
