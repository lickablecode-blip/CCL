/*
* Name:     PowerForm Sections
* Source:   Inbox/PowerForms/PowerForm Sections.txt
* Purpose:
* Imported: 2026-05-15
* Category: PowerForms  (reason: subfolder)
* Lines:    20
* Notes:
*/

SELECT DISTINCT
	DF.DCP_FORMS_REF_ID
	, form_def = DF.DEFINITION
	, form_desc = DF.DESCRIPTION
	, D.DCP_SECTION_REF_ID
	, section_def = DS.DEFINITION
	, section_desc = DS.DESCRIPTION

FROM
	DCP_FORMS_DEF   D
	, DCP_FORMS_REF   DF
	, DCP_SECTION_REF   DS

PLAN D
WHERE D.ACTIVE_IND = 1
JOIN DF WHERE D.DCP_FORMS_REF_ID = DF.DCP_FORMS_REF_ID  AND
DF.ACTIVE_IND = 1
JOIN DS WHERE D.DCP_SECTION_REF_ID = DS.DCP_SECTION_REF_ID  AND
DS.ACTIVE_IND = 1
ORDER BY
DF.DEFINITION

WITH NOCOUNTER, SEPARATOR=" ", FORMAT
