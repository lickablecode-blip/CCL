/*
* Name:     Who Updated Code
* Source:   Inbox/Notes & Templates/Who Updated Code.txt
* Purpose:
* Imported: 2026-05-15
* Category: PowerForms  (reason: subfolder)
* Lines:    15
* Notes:
*/

SELECT
    cv.code_set
    ,cv.code_value
    ,cv.display
    ,last_updated_on = cv.updt_dt_tm "MM/DD/YYYY HH:MM;;q"
    ,last_updated_by = 
        IF(p.position_cd != 0)
            BUILD(p.name_full_formatted, " (", UAR_GET_CODE_DISPLAY(p.position_cd), ")")
        ELSE p.name_full_formatted
        ENDIF

FROM CODE_VALUE cv
    ,PRSNL p
PLAN cv WHERE cv.code_value IN (703502, 2808511)
JOIN p WHERE p.person_id = cv.updt_id
WITH TIME=30
