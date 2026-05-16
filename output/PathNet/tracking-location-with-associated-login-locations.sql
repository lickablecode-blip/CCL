/*
* Name:     Tracking Location with Associated Login Locations
* Source:   Inbox/PathNet/Tracking Location with Associated Login Locations.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    7
* Notes:
*/

SELECT
	
	Tracking_location  = UAR_GET_CODE_DISPLAY(LG.PARENT_LOC_CD)
	, Login_location = UAR_GET_CODE_DISPLAY(LG.CHILD_LOC_CD)
	

FROM
	LOCATION_GROUP   LG

WHERE LG.LOCATION_GROUP_TYPE_CD = 809

WITH NOCOUNTER, SEPARATOR=" ", FORMAT
