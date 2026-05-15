/*
 * Source page  : Case Finder - Diagnosis
 * Source file  : output/case-finder-diagnosis.md
 * Anchor       : (top of page)
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 613
 *
 * Context (preceding paragraph):
 *   Exported: 5/22/25
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

drop program
1fed_rpt_cf_diagnosis go
create
program 1fed_rpt_cf_diagnosis
/******************************************************************************
 REPORT NAME:
        Case Finder - Diagnosis
 PROGRAM:                1fed_rpt_cf_diagnosis.prg
 DEVELOPER:        David Alt
 PUBLISHED:        12/03/2024
 SNAPSHOT:
        12/03/2024
 LOGICAL
PATH:        cust_script
 NODE:                        <default>
 PURPOSE/DESCRIPTION:
 TARGET AUDIENCE:
 CAVEATS:
         Excluding PHI/PII from
the output does not count as true de-identification of
         data for research
purposes. The pseudo-identifier that is created will always
         be consistent for that
individual (although not traceable by any other query/report).
         Other data included in
the output, such as age>89, reg_dt_tm, disch_dt_tm,
         while not PHI/PII, can
be used to identify a patient with sufficient work and
         thus also count against
de-identification.
         To truly de-identify
this data:
         diag_dt_tm --> year
only
         reg_dt_tm --> year
only
         disch_dt_tm --> year
only
         age --> any number
> 89 should output ">89"
         For more information,
read:
         https://www.hhs.gov/hipaa/for-professionals/privacy/special-topics/de-identification/index.html
MOD        DATE                DEVELOPER        COMMENT
---        --/--/--        ---------        ----------------------------
001        05/15/24        David
Alt        Version 1 for testing
002        11/08/24        David
Alt        Added replace_CRLF function
due to linebreaks in diag_prsnl
003        12/03/24        David
Alt        Initial publication to
production
TODO:
 - error checking to ensure at least one source
is selected (if neither, default to both?)
BUGS:
CONSIDER:
 - add provider NPI/taxonomy (first
only)
 - expand diagnosis types (e.g. working,
referral are both populated)
 - add confirmation status
 - add diagnosis type
******************************************************************************/
prompt
"Output to File/Printer/MINE" = "MINE" ;* Enter or select the printer or file name
to send this report to.
, "Search by" = "code"
, "ICD-10-CM Search" = ""
, "Diagnoses" = VALUE(0.0 )
, "Agency" = "ALL"
, "Facility" = VALUE(0.0)
, "Start (discharge date)" = "SYSDATE"
, "End (discharge date)" = "SYSDATE"
, "Diagnosis Source" = 0
, "Include PHI/PII" = 1
, "Exclude test patients" = 0
with OUTDEV,
search_by, icd10_search, icd10_list, agency, facility, start_date,
end_date, source, include_phi, exclude_tp
/**************************************************************
; Global
Declarations
**************************************************************/
; Removes all
line feeds/carriage returns/tabs from a string
subroutine
(replace_CRLF(input = vc) = vc)
; HT = char(9) horizontal tab
; LF = char(10) line feed
; CR = char(13) carriage return
declare output = vc with protect, noconstant("")
declare CRLF = vc with protect, constant(concat(char(13), char(10)))
declare CR = vc with protect, constant(char(13))
declare LF = vc with protect, constant(char(10))
declare HT = vc with protect, constant(char(9))
declare REPLACEMENT = vc with constant(" ")
; remove carriage return+line feed at the beginning and end of the
string
; option 3 -> Trim leading and trailing spaces
set output = trim(input, 3)
; replace carriage return+line feed inside string
set output = replace(output, CRLF, REPLACEMENT)
set output = replace(output, CR, REPLACEMENT)
set output = replace(output, LF, REPLACEMENT)
set output = replace(output, HT, REPLACEMENT)
return (output)
end
/**************************************************************
; Record
Structures
**************************************************************/
free record
fac ;stores the facilities from the prompt
record fac (
1 list[*]
2 location_cd = f8
) with
protect
free record
dx ;stores the diagnoses from the prompt
record dx (
1 list[*]
2 nomenclature_id = f8
) with
protect
free record
res ;stores the final results
record res (
1 list[*]
; diagnosis info
2 diagnosis_id = f8
2 diag_type = c40
2 diag_source = c10
2 diag_dt_tm = dq8
2 diag_prsnl = c100
2 diagnosis = c100
; nomenclature info
2 nomenclature_id = f8
2 coded_diagnosis = c100
2 code = c10
; encounter info
2 encntr_id = f8
2 encntr_tz = i4
2 fin = c40
2 reg_dt_tm = dq8
2 disch_dt_tm = dq8
2 disch_dispo = c40
2 facility = c40
2 nurse_unit = c40
2 encntr_type = c40
2 med_service = c40
; provider info
2 attending_id = f8
2 attending = c100
; patient info
2 person_id = f8
2 pseudo_person_id = i4
2 patient = c100
2 edipi = c20
2 sex = c20
2 age = c20
2 dob = dq8
2 dob_tz = i4
2 race = c40
2 ethnicity = c40
2 military_status = c40
2 test_patient_ind = i2
) with
protect
free record
ed ;encounter detail
record ed (
1 list[*]
2 encntr_id = f8
2 fin = c40
2 attending_id = f8
2 attending = c100
) with
protect
free record
pd ;person detail
record pd (
1 list[*]
; patient info
2 person_id = f8
2 pseudo_person_id = i4
2 patient = c100
2 edipi = c20
2 sex = c20
2 age = c20
2 dob = dq8
2 dob_tz = i4
2 race = c40
2 ethnicity = c40
2 military_status = c40
2 test_patient_ind = i2
) with
protect
/**************************************************************
; Subroutines
**************************************************************/
; Populate
the list of diagnoses from the prompt
subroutine
(build_dx_record(input = NULL) = NULL)
declare i = i4 with protect, noconstant(0)
IF($icd10_list = 0.0) ;"Any"
IF($search_by = "code")
SELECT INTO "NL:"
FROM NOMENCLATURE n
PLAN n WHERE n.source_identifier_keycap =
PATSTRING(CONCAT($icd10_search, "*"))
                 AND
n.source_vocabulary_cd = 19350056 ;ICD-10-CM
                 AND
n.active_ind = 1
                 AND
n.end_effective_dt_tm > SYSDATE
ORDER BY n.source_identifier_keycap
DETAIL
i += 1
CALL ALTERLIST(dx->list, i)
dx->list[i].nomenclature_id = n.nomenclature_id
WITH NOCOUNTER
ELSE ;searching by diagnosis description
SELECT INTO "NL:"
FROM NOMENCLATURE n
PLAN n WHERE CNVTUPPER(n.source_string) =
PATSTRING(CONCAT("*",$icd10_search, "*"))
 AND n.source_vocabulary_cd =
19350056 ;ICD-10-CM
 AND n.active_ind = 1
 AND n.end_effective_dt_tm
> SYSDATE
ORDER BY CNVTUPPER(n.source_string)
DETAIL
i += 1
CALL ALTERLIST(dx->list, i)
dx->list[i].nomenclature_id = n.nomenclature_id
WITH
NOCOUNTER
ENDIF
ELSE ;specific diagnoses were selected
SELECT INTO "NL:"
FROM NOMENCLATURE n
PLAN n WHERE n.nomenclature_id = $icd10_list
DETAIL
i += 1
CALL ALTERLIST(dx->list, i)
dx->list[i].nomenclature_id = n.nomenclature_id
WITH NOCOUNTER
ENDIF
end
;build_dx_record
; Populate
the list of facilities from the prompt
subroutine
(build_fac_record(input = NULL) = NULL)
declare i = i4 with protect, noconstant(0)
IF($facility = 0.0) ;"Any"
IF($agency = "ALL")
SELECT INTO "NL:"
FROM CUST_LOC_AGENCY_RELTN ag
,CODE_VALUE
cv
PLAN ag
JOIN cv WHERE cv.code_value = ag.location_cd
AND cv.display_key != "ZZ*"
AND cv.cdf_meaning = "FACILITY"
AND cv.active_ind = 1
AND cv.end_effective_dt_tm > SYSDATE
DETAIL
i += 1
CALL ALTERLIST(fac->list, i)
fac->list[i].location_cd = ag.location_cd
WITH NOCOUNTER
ELSE ;specific agency selected
SELECT INTO "NL:"
FROM CUST_LOC_AGENCY_RELTN ag
,CODE_VALUE
cv
PLAN ag WHERE ag.agency = $agency
JOIN cv WHERE cv.code_value = ag.location_cd
AND cv.display_key != "ZZ*"
AND cv.cdf_meaning = "FACILITY"
AND cv.active_ind = 1
AND cv.end_effective_dt_tm >
SYSDATE
DETAIL
i += 1
CALL ALTERLIST(fac->list, i)
fac->list[i].location_cd = ag.location_cd
WITH NOCOUNTER
ENDIF
ELSE ;specific facilities were selected
SELECT INTO "NL:"
FROM CUST_LOC_AGENCY_RELTN ag
PLAN ag WHERE ag.location_cd = $facility
DETAIL
i += 1
CALL ALTERLIST(fac->list, i)
fac->list[i].location_cd = ag.location_cd
WITH NOCOUNTER
ENDIF
end
;build_fac_record
subroutine
(build_res_record(input = NULL) = NULL)
declare i = i4 with protect, noconstant(0) ;record iterator
declare dx_idx = i4 with protect, noconstant(0) ;index for expanding dx
record
declare fac_idx = i4 with protect, noconstant(0) ;index for expanding
fac record
;1) Get initial case list
SELECT INTO "NL:"
FROM DIAGNOSIS d
,ENCOUNTER e
,NOMENCLATURE n
PLAN d WHERE EXPAND(dx_idx, 1, size(dx->list, 5), d.nomenclature_id,
dx->list[dx_idx].nomenclature_id)
 AND d.diag_type_cd = $source
 AND d.active_ind = 1
 AND d.beg_effective_dt_tm < SYSDATE
 AND d.end_effective_dt_tm >
SYSDATE
JOIN e WHERE e.encntr_id = d.encntr_id
AND e.disch_dt_tm BETWEEN CNVTDATETIME($start_date) AND
CNVTDATETIME($end_date)
AND EXPAND(fac_idx, 1, size(fac->list, 5), e.loc_facility_cd,
fac->list[fac_idx].location_cd)
AND e.active_ind = 1
AND e.end_effective_dt_tm > SYSDATE
JOIN n WHERE n.nomenclature_id = d.nomenclature_id
AND n.active_ind = 1
ORDER BY d.encntr_id, d.diagnosis_id
DETAIL
i += 1
CALL ALTERLIST(res->list, i)
; Diagnosis
res->list[i].diagnosis_id = d.diagnosis_id
res->list[i].diag_type = UAR_GET_CODE_DISPLAY(d.diag_type_cd)
res->list[i].diag_source = EVALUATE2(
IF(d.diag_type_cd = 89) "Coder" ;final
ELSE "Provider"
ENDIF
)
res->list[i].diag_dt_tm = EVALUATE2(
IF(d.diag_dt_tm IS NULL) d.updt_dt_tm
ELSE d.diag_dt_tm
ENDIF)
res->list[i].diagnosis = d.diagnosis_display
res->list[i].diag_prsnl =
TRIM(SUBSTRING(1,255,replace_CRLF(d.diag_prsnl_name)))
; Nomenclature
res->list[i].nomenclature_id = d.nomenclature_id
res->list[i].code = n.source_identifier
res->list[i].coded_diagnosis = n.source_string
; Encounter
res->list[i].encntr_id = d.encntr_id
res->list[i].reg_dt_tm = e.reg_dt_tm
res->list[i].disch_dt_tm = e.disch_dt_tm
res->list[i].disch_dispo =
UAR_GET_CODE_DISPLAY(e.disch_disposition_cd)
res->list[i].encntr_type = UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
res->list[i].med_service = UAR_GET_CODE_DISPLAY(e.med_service_cd)
res->list[i].facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
res->list[i].nurse_unit = UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
; Patient
res->list[i].person_id = e.person_id
WITH NOCOUNTER, TIME=900, EXPAND=2
end
;build_res_record
subroutine
(build_ed_record(input = NULL) = NULL)
declare i = i4 with protect, noconstant(0) ;record iterator
declare epr_idx = i4 with protect, noconstant(0) ;index for expanding
res record for encounters
declare fin_idx = i4 with protect, noconstant(0) ;index for expanding
res record for encounters
SELECT INTO "NL:"
FROM ENCNTR_ALIAS fin
,(LEFT JOIN (SELECT
epr.encntr_id
,attending = p.name_full_formatted
,p.person_id
,rn = ROW_NUMBER() OVER(PARTITION BY epr.encntr_id ORDER BY
epr.beg_effective_dt_tm DESC)
FROM ENCNTR_PRSNL_RELTN epr
,PRSNL p
WHERE EXPAND(epr_idx, 1, size(res->list, 5), epr.encntr_id,
res->list[epr_idx].encntr_id)
AND epr.encntr_prsnl_r_cd = 1119 ;attending
AND epr.end_effective_dt_tm > SYSDATE
AND epr.active_ind = 1
AND p.person_id = epr.prsnl_person_id
WITH
SQLTYPE("F8","VC","F8","I4")) attend
ON attend.encntr_id = fin.encntr_id
AND attend.rn = 1) ;last/current
attending
PLAN fin WHERE EXPAND(fin_idx, 1, size(res->list, 5), fin.encntr_id,
res->list[fin_idx].encntr_id)
AND fin.encntr_alias_type_cd = 1077
AND fin.active_ind = 1
AND fin.end_effective_dt_tm > SYSDATE
JOIN attend
ORDER BY fin.encntr_id
DETAIL
i += 1
CALL ALTERLIST(ed->list, i)
ed->list[i].encntr_id = fin.encntr_id
ed->list[i].fin = fin.alias
ed->list[i].attending_id = attend.person_id
ed->list[i].attending = attend.attending
WITH NOCOUNTER, EXPAND=1
end
;build_ed_record
subroutine
(add_ed_to_res_record(input = NULL) = NULL)
declare i = i4 with protect, noconstant(0)
declare pos = i4 with protect, noconstant(0)
declare idx = i4 with protect, noconstant(0)
for(i = 1 to size(res->list, 5)) ;for each record in
res
;... lookup same encounter in ed
set idx = 0 ;reset the index
set pos = LOCATEVALSORT(idx, 1, size(ed->list, 5),
res->list[i].encntr_id, ed->list[idx].encntr_id)
;... copy data from ed to res
set res->list[i].fin = ed->list[pos].fin
set res->list[i].attending_id = ed->list[pos].attending_id
set res->list[i].attending = ed->list[pos].attending
endfor
end
;add_ed_to_res_record
subroutine
(build_pd_record(input = NULL) = NULL)
declare i = i4 with protect, noconstant(0) ;record iterator
declare p_idx = i4 with protect, noconstant(0) ;index for expanding res
record for patients
SELECT INTO "NL:"
FROM PERSON p
,(LEFT JOIN PERSON_INFO pi ON pi.person_id = p.person_id
AND pi.info_sub_type_cd = 2678703703 ;Test Patient Identifier
AND pi.value_cd != 2678703509 ;Not a Test Patient
AND p.active_ind = 1
AND p.end_effective_dt_tm > SYSDATE)
,(LEFT JOIN PERSON_ALIAS edipi ON edipi.person_id = p.person_id
AND edipi.person_alias_type_cd = 22
AND edipi.active_ind = 1
AND edipi.end_effective_dt_tm > SYSDATE)
PLAN p WHERE EXPAND(p_idx, 1, size(res->list, 5), p.person_id,
res->list[p_idx].person_id)
AND p.active_ind = 1
JOIN pi
JOIN edipi
ORDER BY p.person_id
DETAIL
i += 1
CALL ALTERLIST(pd->list, i)
pd->list[i].person_id = p.person_id
;pd->list[i].pseudo_person_id = i ;assign a fake identifier to each
patient
pd->list[i].pseudo_person_id = RAND(p.person_id)
pd->list[i].patient = p.name_full_formatted
pd->list[i].edipi = edipi.alias
pd->list[i].sex = UAR_GET_CODE_DISPLAY(p.sex_cd)
pd->list[i].dob = p.birth_dt_tm
pd->list[i].dob_tz = p.birth_tz
pd->list[i].race = UAR_GET_CODE_DISPLAY(p.race_cd)
pd->list[i].ethnicity = UAR_GET_CODE_DISPLAY(p.ethnic_grp_cd)
pd->list[i].military_status =
UAR_GET_CODE_DISPLAY(p.vet_military_status_cd)
pd->list[i].test_patient_ind = EVALUATE2(
IF(pi.person_info_id > 0) 1
ELSE 0
ENDIF)
WITH NOCOUNTER, EXPAND=1
end
;build_pd_record
subroutine
(add_pd_to_res_record(input = NULL) = NULL)
declare i = i4 with protect, noconstant(0)
declare pos = i4 with protect, noconstant(0)
declare idx = i4 with protect, noconstant(0)
for(i = 1 to size(res->list, 5)) ;for each record in
res
;... lookup same encounter in pd
set idx = 0 ;reset the index
set pos = LOCATEVALSORT(idx, 1, size(pd->list, 5),
res->list[i].person_id, pd->list[idx].person_id)
;... copy data from pd to res
set res->list[i].pseudo_person_id =
pd->list[pos].pseudo_person_id
set res->list[i].patient = pd->list[pos].patient
set res->list[i].edipi = pd->list[pos].edipi
set res->list[i].sex = pd->list[pos].sex
set res->list[i].dob = pd->list[pos].dob
set res->list[i].dob_tz = pd->list[pos].dob_tz
set res->list[i].age = CNVTAGE(res->list[i].dob,
res->list[i].reg_dt_tm, 0)
set res->list[i].race = pd->list[pos].race
set res->list[i].ethnicity = pd->list[pos].ethnicity
set res->list[i].military_status = pd->list[pos].military_status
set res->list[i].test_patient_ind =
pd->list[pos].test_patient_ind
endfor
end
;add_pd_to_res_record
/**************************************************************
; Main
**************************************************************/
CALL
build_dx_record(NULL) ;store diagnosis
choices from the prompt
CALL
build_fac_record(NULL) ;store facility choices from the prompt
CALL
build_res_record(NULL) ;assemble the core records
CALL
build_ed_record(NULL) ;store FIN and
attending from encounter list
CALL
add_ed_to_res_record(NULL) ;add FIN and attending to core records
CALL
build_pd_record(NULL)        ;store
patient details
CALL
add_pd_to_res_record(NULL) ;add patient details to core records
/**************************************************************
; Output
**************************************************************/
SELECT
IF($include_phi
= 1)
;Diagnosis
code = res->list[d.seq].code
,coded_diagnosis =
res->list[d.seq].coded_diagnosis
,diagnosis = res->list[d.seq].diagnosis
,diag_dt_tm = res->list[d.seq].diag_dt_tm "MM/DD/YYYY;;q"
;,diag_type = res->list[d.seq].diag_type
,diag_source = res->list[d.seq].diag_source
,diag_prsnl = res->list[d.seq].diag_prsnl
;Encounter
,fin = res->list[d.seq].fin
,attending = res->list[d.seq].attending
,attending_id = res->list[d.seq].attending_id
,encntr_type = res->list[d.seq].encntr_type
,med_service = res->list[d.seq].med_service
,facility = res->list[d.seq].facility
,nurse_unit = res->list[d.seq].nurse_unit
,reg_dt_tm = res->list[d.seq].reg_dt_tm "MM/DD/YYYY;;d"
,disch_dt_tm = res->list[d.seq].disch_dt_tm
"MM/DD/YYYY;;d"
,disposition = res->list[d.seq].disch_dispo
;Patient
,patient = res->list[d.seq].patient
,edipi = res->list[d.seq].edipi
,dob = format(datetimezone(res->list[d.seq].dob,
res->list[d.seq].dob_tz), "MM/DD/YYYY;4;D")
,age = res->list[d.seq].age
,sex = res->list[d.seq].sex
,race = res->list[d.seq].race
,ethnicity = res->list[d.seq].ethnicity
,military_status = res->list[d.seq].military_status
,test_patient_ind = res->list[d.seq].test_patient_ind
;Identifiers
,person_id =
res->list[d.seq].person_id
,encntr_id = res->list[d.seq].encntr_id
,diagnosis_id = res->list[d.seq].diagnosis_id
FROM (DUMMYT d WITH SEQ = value(size(res->list, 5)))
PLAN d WHERE res->list[d.seq].test_patient_ind <= $exclude_tp
ORDER BY code, patient, diag_dt_tm
ELSE ;don't include PHI/PII
;Diagnosis
code = res->list[d.seq].code
,coded_diagnosis =
res->list[d.seq].coded_diagnosis
,diagnosis = res->list[d.seq].diagnosis
,diag_dt_tm = res->list[d.seq].diag_dt_tm "MM/DD/YYYY;;q"
,diag_source = res->list[d.seq].diag_source
;Encounter
,encntr_type = res->list[d.seq].encntr_type
,med_service = res->list[d.seq].med_service
,facility = res->list[d.seq].facility
,nurse_unit = res->list[d.seq].nurse_unit
,reg_dt_tm = res->list[d.seq].reg_dt_tm "MM/DD/YYYY;;d"
,disch_dt_tm = res->list[d.seq].disch_dt_tm
"MM/DD/YYYY;;d"
,disposition = res->list[d.seq].disch_dispo
;Patient Demographics
,pseudo_patient_identifier = res->list[d.seq].pseudo_person_id
,age = res->list[d.seq].age
,sex = res->list[d.seq].sex
,race = res->list[d.seq].race
,ethnicity = res->list[d.seq].ethnicity
,military_status = res->list[d.seq].military_status
,test_patient_ind = res->list[d.seq].test_patient_ind
FROM (DUMMYT d WITH SEQ = value(size(res->list, 5)))
PLAN d WHERE res->list[d.seq].test_patient_ind <= $exclude_tp
ORDER BY code, diag_dt_tm
ENDIF
INTO $OUTDEV
error = "Invalid prompt selections"
WITH
NOCOUNTER, SEPARATOR=" ", FORMAT, CHECK, TIME=900, EXPAND=2,
UAR_CODE(D)
end
go
