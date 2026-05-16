/*
* Name:     Like_to_Like_DupChecking_Audit
* Source:   Inbox/PathNet/Like_to_Like_DupChecking_Audit.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    27
* Notes:
*/

SELECT
                D.ACTIVE_IND
                , D_CATALOG_DISP = UAR_GET_CODE_DISPLAY(D.CATALOG_CD)
                , D.DUP_CHECK_SEQ
                , D_EXACT_HIT_ACTION_DISP = UAR_GET_CODE_DISPLAY(D.EXACT_HIT_ACTION_CD)
                , D.MIN_AHEAD
                , D_MIN_AHEAD_ACTION_DISP = UAR_GET_CODE_DISPLAY(D.MIN_AHEAD_ACTION_CD)
                , D.MIN_BEHIND
                , D_MIN_BEHIND_ACTION_DISP = UAR_GET_CODE_DISPLAY(D.MIN_BEHIND_ACTION_CD)
                , D_OUTPAT_EXACT_HIT_ACTION_DISP = UAR_GET_CODE_DISPLAY(D.OUTPAT_EXACT_HIT_ACTION_CD)
                , D.OUTPAT_FLEX_IND
                , D.OUTPAT_MIN_AHEAD
                , D_OUTPAT_MIN_AHEAD_ACTION_DISP = UAR_GET_CODE_DISPLAY(D.OUTPAT_MIN_AHEAD_ACTION_CD)
                , D.OUTPAT_MIN_BEHIND
                , D_OUTPAT_MIN_BEHIND_ACTION_DISP = UAR_GET_CODE_DISPLAY(D.OUTPAT_MIN_BEHIND_ACTION_CD)
                , D.ROWID
                , D.UPDT_APPLCTX
                , D.UPDT_CNT
                , D.UPDT_DT_TM
                , D.UPDT_ID
                , D.UPDT_TASK

FROM
                ORDERS   O
                , DUP_CHECKING   D

PLAN O
JOIN D WHERE D.CATALOG_CD = O.CATALOG_CD  AND O.ACTIVITY_TYPE_CD = 692  AND O.ACTIVE_IND = 1
GO
