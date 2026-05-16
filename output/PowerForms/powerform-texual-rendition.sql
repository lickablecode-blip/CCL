/*
* Name:     Powerform Texual Rendition
* Source:   Inbox/PowerForms/Powerform Texual Rendition.txt
* Purpose:
* Imported: 2026-05-15
* Category: PowerForms  (reason: subfolder)
* Lines:    76
* Notes:
*/

SELECT DISTINCT
    dfr.dcp_forms_ref_id
    ,display_name = dfr.description
    ,unique_name = dfr.definition
    ,form_parent = UAR_GET_CODE_DISPLAY(vese2.event_set_cd)
    ,text_rendition = UAR_GET_CODE_DISPLAY(dfr.text_rendition_event_cd)
    ,dfr.text_rendition_event_cd
    ,text_rendition_parent = UAR_GET_CODE_DISPLAY(vese4.event_set_cd)
    ,order_task_type = UAR_GET_CODE_DISPLAY(ot.task_type_cd)
    ,order_task_activity = UAR_GET_CODE_DISPLAY(ot.task_activity_cd)

    ;LOINC MAPPING
    ,has_loinc =    
        IF(loinc_classcode.code_value > 0 AND loinc_contenttype.code_value > 0 AND loinc_typecode.code_value > 0) "yes"
        ELSEIF(loinc_classcode.code_value > 0 OR loinc_contenttype.code_value > 0 OR loinc_typecode.code_value > 0) "partial"
        ELSE "no"
        ENDIF
    ,loinc_class_code = IF(loinc_classcode.code_value > 0) loinc_classcode.alias ENDIF
    ,loinc_content_type = IF(loinc_contenttype.code_value > 0) loinc_contenttype.alias ENDIF
    ,loinc_type_code = IF(loinc_typecode.code_value > 0) loinc_typecode.alias ENDIF
    ,class_code_short = IF(loinc_classcode.code_value > 0) n_classcode.short_string ENDIF
    ,content_type_short = IF(loinc_contenttype.code_value > 0) n_contenttype.short_string ENDIF
    ,type_code_short = IF(loinc_typecode.code_value > 0) n_typecode.short_string ENDIF
    ,class_code_fully_specified = IF(loinc_classcode.code_value > 0) n_classcode.source_string ENDIF
    ,content_type_fully_specified = IF(loinc_contenttype.code_value > 0) n_contenttype.source_string ENDIF
    ,type_code_fully_specified = IF(loinc_typecode.code_value > 0) n_typecode.source_string ENDIF
        

FROM DCP_FORMS_REF dfr
    ,(LEFT JOIN V500_EVENT_SET_EXPLODE vese1 ON vese1.event_cd = dfr.event_cd
        AND vese1.event_set_level = 0)
    ,(LEFT JOIN V500_EVENT_SET_EXPLODE vese2 ON vese2.event_cd = dfr.event_cd
        AND vese2.event_set_level = 1)
    ,(LEFT JOIN V500_EVENT_SET_EXPLODE vese3 ON vese3.event_cd = dfr.text_rendition_event_cd
        AND vese3.event_set_level = 0)
    ,(LEFT JOIN V500_EVENT_SET_EXPLODE vese4 ON vese4.event_cd = dfr.text_rendition_event_cd
        AND vese4.event_set_level = 1)
    ,(LEFT JOIN CODE_VALUE_OUTBOUND loinc_classcode 
        ON dfr.text_rendition_event_cd = loinc_classcode.code_value
        AND loinc_classcode.contributor_source_cd = 18024137 ;LOINC
        AND loinc_classcode.alias_type_meaning = "CLASSCODE")
    ,(LEFT JOIN CODE_VALUE_OUTBOUND loinc_contenttype   
        ON dfr.text_rendition_event_cd = loinc_contenttype.code_value
        AND loinc_contenttype.contributor_source_cd = 18024137 ;LOINC
        AND loinc_contenttype.alias_type_meaning = "CONTENTTYPE")
    ,(LEFT JOIN CODE_VALUE_OUTBOUND loinc_typecode  
        ON dfr.text_rendition_event_cd = loinc_typecode.code_value
        AND loinc_typecode.contributor_source_cd = 18024137 ;LOINC
        AND loinc_typecode.alias_type_meaning = "TYPECODE")
    ,(LEFT JOIN NOMENCLATURE n_classcode    
        ON loinc_classcode.alias = n_classcode.source_identifier
        AND n_classcode.active_ind = 1
        AND n_classcode.end_effective_dt_tm > SYSDATE)
    ,(LEFT JOIN NOMENCLATURE n_contenttype  
        ON loinc_contenttype.alias = n_contenttype.source_identifier
        AND n_contenttype.active_ind = 1
        AND n_contenttype.end_effective_dt_tm > SYSDATE)
    ,(LEFT JOIN NOMENCLATURE n_typecode 
        ON loinc_typecode.alias = n_typecode.source_identifier
        AND n_typecode.active_ind = 1
        AND n_typecode.end_effective_dt_tm > SYSDATE)
    ,(LEFT JOIN ORDER_TASK ot ON ot.dcp_forms_ref_id = dfr.dcp_forms_ref_id
        AND ot.active_ind = 1)
    
PLAN dfr WHERE dfr.active_ind = 1
    ;AND dfr.text_rendition_event_cd = 0 ;uncomment this for notes WITHOUT textual rendition
    ;AND dfr.text_rendition_event_cd > 0 ;uncomment this for notes WITH textual rendition

JOIN vese1 
JOIN vese2
JOIN vese3
JOIN vese4
JOIN loinc_classcode
JOIN loinc_contenttype
JOIN loinc_typecode
JOIN n_classcode
JOIN n_contenttype
JOIN n_typecode
JOIN ot

ORDER BY display_name
WITH TIME=60
