/*
* Name:     Ref_Range_Updates_DTA_ServResource_with_PersonID
* Source:   Inbox/PathNet/Ref_Range_Updates_DTA_ServResource_with_PersonID.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    59
* Notes:
*/

Use this DVD for looking up changes to reference ranges per DTA and service resource. In the "PLAN" section, you will
need to enter in the code value of both the service resource you are looking at and the DTA you want to search for. This
query will pull up the names of whoever last changed the reference ranges, what they changed them from, and what they
changed them to. There are some extra miscellaneous columns in here, in case people are looking for other information regarding
ref range changes over time.


SELECT
	R_ACTIVE_STATUS_DISP = UAR_GET_CODE_DISPLAY(R.ACTIVE_STATUS_CD)
	, R.ACTIVE_STATUS_DT_TM
	, R.ACTIVE_STATUS_PRSNL_ID
	, R.UPDT_CNT
	, R.UPDT_DT_TM
	, R.UPDT_ID
	, P.PERSON_ID
	, P.NAME_FULL_FORMATTED
	, R.UPDT_TASK
	, R_TASK_ASSAY_DISP = UAR_GET_CODE_DISPLAY(R.TASK_ASSAY_CD)
	, R_SERVICE_RESOURCE_DISP = UAR_GET_CODE_DISPLAY(R.SERVICE_RESOURCE_CD)
	, R.AGE_FROM_MINUTES
	, R_AGE_FROM_UNITS_DISP = UAR_GET_CODE_DISPLAY(R.AGE_FROM_UNITS_CD)
	, R.AGE_TO_MINUTES
	, R_AGE_TO_UNITS_DISP = UAR_GET_CODE_DISPLAY(R.AGE_TO_UNITS_CD)
	, R.BEG_EFFECTIVE_DT_TM
	, R.CRITICAL_LOW
	, R.CRITICAL_HIGH
	, R.DEFAULT_RESULT
	, R_ENCNTR_TYPE_DISP = UAR_GET_CODE_DISPLAY(R.ENCNTR_TYPE_CD)
	, R.END_EFFECTIVE_DT_TM
	, R.NORMAL_IND
	, R.NORMAL_LOW
	, R.NORMAL_HIGH
	, R.FEASIBLE_IND
	, R.FEASIBLE_LOW
	, R.FEASIBLE_HIGH
	, R.REVIEW_IND
	, R.REVIEW_LOW
	, R.REVIEW_HIGH
	, R.LINEAR_IND
	, R.LINEAR_LOW
	, R.LINEAR_HIGH
	, R.MINS_BACK
	, R.REFERENCE_RANGE_FACTOR_ID
	, R.REF_RANGE_RULE_IND
	, R.ROWID
	, R.SENSITIVE_IND
	, R.SENSITIVE_HIGH
	, R.SENSITIVE_LOW
	, R_SEX_DISP = UAR_GET_CODE_DISPLAY(R.SEX_CD)
	, R_SPECIES_DISP = UAR_GET_CODE_DISPLAY(R.SPECIES_CD)
	, R_SPECIMEN_TYPE_DISP = UAR_GET_CODE_DISPLAY(R.SPECIMEN_TYPE_CD)
	, R_UNITS_DISP = UAR_GET_CODE_DISPLAY(R.UNITS_CD)
	, R.UNKNOWN_AGE_IND
	, R.UPDT_APPLCTX

FROM
	REFERENCE_RANGE_FACTOR   R
	, PERSON   P

PLAN R WHERE R.SERVICE_RESOURCE_CD = <ENTER SERVICE RESOURCE CODE VALUE>
	AND R.TASK_ASSAY_CD = <ENTER DTA CODE VALUE>
JOIN P WHERE P.PERSON_ID = R.UPDT_ID


WITH MAXREC = 100, NOCOUNTER, SEPARATOR=" ", FORMAT
