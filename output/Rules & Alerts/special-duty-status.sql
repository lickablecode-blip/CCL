/*
* Name:     Special Duty Status
* Source:   Inbox/Rules & Alerts/Special Duty Status.txt
* Purpose:
* Imported: 2026-05-15
* Category: Rules & Alerts  (reason: subfolder)
* Lines:    90
* Notes:
*/

/* BRANCH 1: HAS CLINICAL EVENT WITHOUT PASSIVE ALERT	*/
SELECT
discrepancy_type = "Missing Alert"
, p.name_full_formatted
, ce.person_id
, ce.event_id		/*BEST PK*/
, ce.event_cd
, ce.event_title_text
, ce.result_val
, ce.event_end_dt_tm		/*WHEN EVENT "OCCURED" VS DOCUMENTED*/
, passive_alert_id = 0
, beg_effective_dt_tm = cnvtdatetime("01-JAN-1900 00:00:00")
, alert_txt = ""
FROM 
clinical_event ce
,person p
PLAN ce
	WHERE ce.event_cd IN		/*EVENT_CD F/ SPECIAL DUTY STATUS != TRAINEE*/
		(SELECT ese.event_cd
		FROM v500_event_set_explode ese
		WHERE ese.event_set_cd = 971791117
		AND ese.event_cd != 30288747499)
	AND ce.result_val = "Yes" 
	AND ce.event_end_dt_tm > cnvtdatetime(curdate-365,1) /*HOW MANY DAYS RETROACTIVE*/
	AND ce.valid_until_dt_tm > sysdate 
	AND ce.result_status_cd NOT IN (28, 29, 30, 31)
	AND NOT EXISTS		/* LATEST VALID YES PER EVENT_CD*/
		(SELECT 1
		FROM clinical_event ce2
		WHERE ce2.person_id = ce.person_id
		AND ce2.event_cd = ce.event_cd  
		AND ce2.valid_until_dt_tm > sysdate
		AND ce2.result_status_cd NOT IN (28, 29, 30, 31)
		AND (ce2.event_end_dt_tm > ce.event_end_dt_tm
			OR (ce2.event_end_dt_tm = ce.event_end_dt_tm
				AND ce2.event_id > ce.event_id)))
	AND NOT EXISTS		/*NO ACTIVE ALERT*/
		(SELECT 1
		FROM passive_alert pa
		WHERE pa.person_id = ce.person_id
		AND pa.alert_source = "SZ_V2_SPECIAL_DUTY_STATUS"
		AND pa.active_ind = 1
		AND pa.end_effective_dt_tm > sysdate)
JOIN p where p.person_id = ce.person_id
		
/* BRANCH 2: HAS PASSIVE ALERT WITHOUT CLINICAL EVENT	*/
/* NOT WORKING WELL, PROBABLY DOES NOT MATTER AS USERS	*/
/* WILL SEE PASSIVE ALERT AND CAN MANUALLY REMOVE		*/
;SELECT
;discrepancy_type = "Stale Alert"
;, p_placeholder = ""
;, pa.person_id
;, event_id = 0
;, event_cd = 0
;, event_title_text = ""
;, result_val = ""
;, event_end_dt_tm = cnvtdatetime("01-JAN-1900 00:00:00")
;, pa.passive_alert_id
;, pa.beg_effective_dt_tm
;, pa.alert_txt
;FROM
;passive_alert pa
;PLAN pa
;	WHERE pa.beg_effective_dt_tm > cnvtdatetime (curdate-365,0)	/*Filter on pa not useful	*/
;	AND pa.alert_source = "SZ_V2_SPECIAL_DUTY_STATUS"
;	AND pa.end_effective_dt_tm > sysdate
;	AND pa.active_ind = 1
;
;	AND NOT EXISTS
;		(SELECT 1
;		FROM clinical_event ce
;		WHERE ce.person_id = pa.person_id
;			AND ce.event_end_dt_tm > cnvtdatetime(curdate-365,0)
;			AND ce.event_cd IN
;				(971723825,		971727747,	971727761,	971729945
;				, 971729959,	971729973,	971729993,	971731911
;				, 971731943,	971731993,	971732045)
;				AND ce.result_val = "Yes"
;				AND ce.valid_until_dt_tm > sysdate
;				AND ce.result_status_cd NOT IN (28, 29, 30, 31))
;;					AND NOT EXISTS
;;						(SELECT 1
;;						FROM clinical_event ce2
;;						WHERE ce2.person_id = ce.person_id
;;							AND ce2.event_cd = ce.event_cd
;;							AND ce2.result_status_cd NOT IN (28, 29, 30, 31)
;;							AND ce2.valid_until_dt_tm > sysdate
;;							AND (ce2.event_end_dt_tm > ce.event_end_dt_tm
;;								OR (ce2.event_end_dt_tm = ce.event_end_dt_tm
;;									AND ce2.event_id > ce.event_id))))
WITH maxrec = 10000, time = 100
