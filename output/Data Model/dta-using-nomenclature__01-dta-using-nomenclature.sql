/*
 * Source page  : DTA using NOMENCLATURE
 * Source file  : output/dta-using-nomenclature.md
 * Anchor       : (top of page)
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 78
 *
 * Context (preceding paragraph):
 *   (no preceding paragraph)
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
 MNEMONIC = dta.mnemonic
 , DESCRIPTION = dta.description
 , TYPE =
uar_get_code_display(dta.default_result_type_cd)
 , N.SOURCE_STRING
 , SEX =
if(r.sex_cd =
0.0)("All")
else(uar_get_code_display(r.sex_cd))endif
, START_AGE
=
if(uar_get_code_meaning(r.age_from_units_cd)
= "DAYS")((r.age_from_minutes / 60) / 24)
elseif(uar_get_code_meaning(r.age_from_units_cd)
= "HOURS")(r.age_from_minutes / 60)
elseif(uar_get_code_meaning(r.age_from_units_cd)
= "MINUTES")(r.age_from_minutes)
elseif(uar_get_code_meaning(r.age_from_units_cd)
= "MONTHS")(((r.age_from_minutes / 60) / 24) / 31)
elseif(uar_get_code_meaning(r.age_from_units_cd)
= "WEEKS")(((r.age_from_minutes / 60) / 24) / 7)
elseif(uar_get_code_meaning(r.age_from_units_cd)
= "YEARS")(((r.age_from_minutes / 60) / 24) / 365)
endif
, START_UNITS
= uar_get_code_display(r.age_from_units_cd)
,
END_AGE=
if(uar_get_code_meaning(r.age_to_units_cd)
= "DAYS")((r.age_to_minutes / 60) / 24)
elseif(uar_get_code_meaning(r.age_to_units_cd)
= "HOURS")(r.age_to_minutes / 60)
elseif(uar_get_code_meaning(r.age_to_units_cd)
= "MINUTES")(r.age_to_minutes)
elseif(uar_get_code_meaning(r.age_to_units_cd)
= "MONTHS")(((r.age_to_minutes / 60) / 24) / 31)
elseif(uar_get_code_meaning(r.age_to_units_cd)
= "WEEKS")(((r.age_to_minutes / 60) / 24) / 7)
elseif(uar_get_code_meaning(r.age_to_units_cd)
= "YEARS")(((r.age_to_minutes / 60) / 24) / 365)
endif
,END_UNITS =
uar_get_code_display(r.age_to_units_cd)
,
r.feasible_low
,
r.critical_low
,
r.normal_low
,
r.normal_high
,
r.critical_high
,
r.feasible_high
, UOM =
uar_get_code_display(r.units_cd)
FROM
 discrete_task_assay dta
 , REFERENCE_RANGE_FACTOR R
 , ALPHA_RESPONSES A
 , NOMENCLATURE N
Plan dta
WHERE
dta.ACTIVE_IND=1
 and dta.Mnemonic =
"Environmental Safety Implemented "
join R WHERE
dta.TASK_ASSAY_CD = R.TASK_ASSAY_CD
and
R.ACTIVE_IND=1
join A WHERE
outerjoin(R.REFERENCE_RANGE_FACTOR_ID) = A.REFERENCE_RANGE_FACTOR_ID
JOIN N WHERE
outerjoin(A.NOMENCLATURE_ID) = N.NOMENCLATURE_ID
WITH format,
time = 60, separator = " "
