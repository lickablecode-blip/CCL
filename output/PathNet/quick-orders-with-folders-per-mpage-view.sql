/*
* Name:     Quick Orders with folders per MPage view
* Source:   Inbox/PathNet/Quick Orders with folders per MPage view.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    76
* Notes:
*/

Audit to pull Quick Order Folders per MPage View.
Replace the highlighted portion (BDC.CATEGORY_NAME) with your view name. It won�t account for User Favorites added to the view after it is set up.


SELECT VIEW_NAME = BDC.CATEGORY_NAME
, FOLDER_DISPLAY = AC.SHORT_DESCRIPTION
, UNIQUE_DESCRIPTION  = AC.LONG_DESCRIPTION
, SUB_FOLDER_DISPLAY = AC2.SHORT_DESCRIPTION
, SUB_UNIQUE_DESCRIPTION  = AC2.LONG_DESCRIPTION
, ORDER_SYNONYM = (IF (AL2.ALT_SEL_CATEGORY_ID = 0 AND OCS.MNEMONIC != NULL) OCS.MNEMONIC
                                                            ELSEIF (AL2.ALT_SEL_CATEGORY_ID != 0 AND OCS2.MNEMONIC != NULL) OCS2.MNEMONIC
                                                            ELSEIF (OCS.MNEMONIC = NULL AND PCS.SYNONYM_NAME = NULL AND OCS2.MNEMONIC = NULL AND 
                                                            PCS2.SYNONYM_NAME = NULL) "FOLDER IS EMPTY"
                                                             ENDIF)
, ORDER_SENTENCE = (IF (AL2.ALT_SEL_CATEGORY_ID = 0) OS.ORDER_SENTENCE_DISPLAY_LINE
                                                             ELSEIF (AL2.ALT_SEL_CATEGORY_ID != 0) OS2.ORDER_SENTENCE_DISPLAY_LINE
                                                             ENDIF)
, POWERPLAN_SYNONYM_USED = (IF (AL2.ALT_SEL_CATEGORY_ID = 0 AND PCS.SYNONYM_NAME != NULL) PCS.SYNONYM_NAME
                                                            ELSEIF (AL2.ALT_SEL_CATEGORY_ID != 0 AND PCS2.SYNONYM_NAME != NULL) PCS2.SYNONYM_NAME
                                                            ELSEIF (OCS.MNEMONIC = NULL AND PCS.SYNONYM_NAME = NULL AND OCS2.MNEMONIC = NULL AND 
                                                            PCS2.SYNONYM_NAME = NULL) "FOLDER IS EMPTY"
                                                            ENDIF)
FROM           BR_DATAMART_CATEGORY BDC
                       , BR_DATAMART_REPORT BR
                       , BR_DATAMART_REPORT_FILTER_R BFR
                       , BR_DATAMART_FILTER BF
                       , BR_DATAMART_VALUE BV
                       , ALT_SEL_CAT AC
                              , ALT_SEL_LIST AL
               , ALT_SEL_CAT AC2
               , ORDER_CATALOG_SYNONYM OCS
               , ORDER_SENTENCE OS
               , PATHWAY_CATALOG PC
               , PW_CAT_SYNONYM PCS
               , ALT_SEL_LIST AL2
               , ORDER_CATALOG_SYNONYM OCS2
               , ORDER_SENTENCE OS2
               , PATHWAY_CATALOG PC2
               , PW_CAT_SYNONYM PCS2

PLAN BDC
WHERE BDC.CATEGORY_NAME = "PEDS Inpatient Quick Orders" ; VIEW NAME
JOIN BR 
                       WHERE BR.BR_DATAMART_CATEGORY_ID =   BDC.BR_DATAMART_CATEGORY_ID 
        JOIN BFR 
                       WHERE BFR.BR_DATAMART_REPORT_ID = BR.BR_DATAMART_REPORT_ID
        JOIN BF 
                       WHERE BF.BR_DATAMART_FILTER_ID = BFR.BR_DATAMART_FILTER_ID
        JOIN BV 
                       WHERE BV.BR_DATAMART_CATEGORY_ID = BF.BR_DATAMART_CATEGORY_ID
                         AND BV.BR_DATAMART_FILTER_ID = BF.BR_DATAMART_FILTER_ID
                         AND TRIM(BV.PARENT_ENTITY_NAME) = "ALT_SEL_CAT"
                         AND BV.END_EFFECTIVE_DT_TM > CNVTDATETIME(CURDATE,CURTIME3)
        JOIN AC
        WHERE AC.ALT_SEL_CATEGORY_ID = BV.PARENT_ENTITY_ID                         
        
        JOIN AL 
               WHERE AL.ALT_SEL_CATEGORY_ID = AC.ALT_SEL_CATEGORY_ID

JOIN AC2
               WHERE AC2.ALT_SEL_CATEGORY_ID = OUTERJOIN(AL.CHILD_ALT_SEL_CAT_ID)

JOIN OCS
               WHERE OCS.SYNONYM_ID = OUTERJOIN(AL.SYNONYM_ID)

JOIN OS 
               WHERE OS.ORDER_SENTENCE_ID = OUTERJOIN(AL.ORDER_SENTENCE_ID)

JOIN PC
               WHERE PC.PATHWAY_CATALOG_ID = OUTERJOIN(AL.PATHWAY_CATALOG_ID)

JOIN PCS 
               WHERE PCS.PW_CAT_SYNONYM_ID = OUTERJOIN(AL.PW_CAT_SYNONYM_ID)

JOIN AL2
               WHERE AL2.ALT_SEL_CATEGORY_ID = OUTERJOIN(AC2.ALT_SEL_CATEGORY_ID)
               AND AL2.ALT_SEL_CATEGORY_ID != OUTERJOIN(0)

JOIN OCS2
               WHERE OCS2.SYNONYM_ID = OUTERJOIN(AL2.SYNONYM_ID)

JOIN OS2 
               WHERE OS2.ORDER_SENTENCE_ID = OUTERJOIN(AL2.ORDER_SENTENCE_ID)

JOIN PC2
               WHERE PC2.PATHWAY_CATALOG_ID = OUTERJOIN(AL2.PATHWAY_CATALOG_ID)

JOIN PCS2
               WHERE PCS2.PW_CAT_SYNONYM_ID = OUTERJOIN(AL2.PW_CAT_SYNONYM_ID)
               
WITH TIME = 60
