/*
* Name:     Note Types to Patient Portal
* Source:   Inbox/Notes & Templates/Note Types to Patient Portal.txt
* Purpose:
* Imported: 2026-05-15
* Category: PowerForms  (reason: subfolder)
* Lines:    23
* Notes:
*/

SELECT
Document_or_Result_Name = uar_get_code_display(v.event_cd),
v.event_cd,
v.event_set_cd,
v.updt_dt_tm
FROM
v500_event_set_explode v
WHERE
v.event_set_cd =(
SELECT cv.code_value
FROM code_value cv
WHERE cv.display_key =
;"PATIENTVIEWABLERESULTS"
;"PATIENTVIEWABLERADIOLOGY"
;"PATIENTVIEWABLEPATHOLOGY"
;"PATIENTVIEWABLEMICROBIOLOGY"
"PATIENTVIEWABLECLINICALNOTES"
;"IQHEALTHEDUCATIONDOCUMENTS"
"PATIENTVIEWABLECOVID19RESULTS"
)
ORDER BY
uar_get_code_display(v.event_cd)
go
