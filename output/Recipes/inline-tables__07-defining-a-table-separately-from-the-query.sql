/*
 * Source page  : Inline tables
 * Source file  : output/inline-tables.md
 * Anchor       : Defining a table separately from the query
 * Block index  : 7 of 7
 * Detected lang: ccl
 * Lines        : 27
 *
 * Context (preceding paragraph):
 *   Tables can also be defined in the WITH clause
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT INTO
$OUTDEV
p.name_full_formatted
,ma1.person_id
,mrn = ma1.alias
,ssn = ma2.alias
FROM
MY_ALIASES ma1
,MY_ALIASES ma2
,PERSON p
PLAN ma1
WHERE ma1.person_alias_type_cd = 10 ;MRN
JOIN ma2
WHERE ma2.person_id = ma1.person_id
AND ma2.person_alias_type_cd = 18 ;SSN
JOIN p WHERE
p.person_id = ma1.person_id
WITH
NOCOUNTER, SEPARATOR=" ", FORMAT, TIME=30, MAXREC=50,
MY_ALIASES = (
 SELECT pa.person_id
,pa.alias
,pa.person_alias_type_cd
FROM PERSON_ALIAS pa
WHERE pa.person_alias_type_cd IN (10, 18) ;MRN, SSN
WITH SQLTYPE("f8", "c40", "f8")
)
