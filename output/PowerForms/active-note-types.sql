/*
* Name:     Active Note Types
* Source:   Inbox/Notes & Templates/Active Note Types.txt
* Purpose:
* Imported: 2026-05-15
* Category: PowerForms  (reason: subfolder)
* Lines:    16
* Notes:
*/

***************************************************************
This ad hoc query lists all of the active note types. Columns Include:
 ;      *Description Name
 ;      *Display Name
 ************************************************************** 

SELECT  DESCRIPTION = UAR_GET_CODE_DESCRIPTION(N.EVENT_CD)
        , DISPLAY = UAR_GET_CODE_DISPLAY(N.EVENT_CD)
FROM    NOTE_TYPE N
WHERE   N.EVENT_CD IN (SELECT V.EVENT_CD
                       FROM V500_EVENT_SET_EXPLODE   V
                       WHERE V.EVENT_SET_CD IN (SELECT CV.CODE_VALUE
                                                FROM CODE_VALUE   CV
                                                WHERE CV.DISPLAY_KEY = "CLINICALDOC"
                                                AND CV.CODE_SET = 93))
        AND N.DATA_STATUS_IND = 1
ORDER BY UAR_GET_CODE_DISPLAY(N.EVENT_CD)
