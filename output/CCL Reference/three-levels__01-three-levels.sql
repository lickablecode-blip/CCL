/*
 * Source page  : Three levels
 * Source file  : output/three-levels.md
 * Anchor       : (top of page)
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 96
 *
 * Context (preceding paragraph):
 *   This demonstrates a three-level record structure, loaded from a single query, with all
 *   three levels accessed in the report output.
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

/**************************************************************
; Declarations
**************************************************************/
;PEC = Person-Encounter-Clinical Event
FREE RECORD
pec
RECORD pec (
1 plist[*]
2 person_id = f8
2 elist[*]
3 encntr_id = f8
3 clist[*]
4 event_id = f8
4 event_cd = f8
) ;end PEC
/**************************************************************
; Init
**************************************************************/
;Load the record structure
/*
You don't actually need anything in the SELECT clause
- it is ignored
see https://community.cerner.com/t5/CCL-Discern-Explorer-Client-and-Cerner-Collaboration/Efficiency-question-query-without-select-items-vs-query-with-explicit-select-items/m-p/453420
*/
SELECT INTO
"NL:"
p.person_id
,e.encntr_id
,ce.event_id
,ce.event_cd
FROM PERSON p
,ENCOUNTER e
,CLINICAL_EVENT ce
PLAN p WHERE
p.person_id = <insert person_id>
AND p.person_type_cd = 903 ;PERSON
AND p.end_effective_dt_tm > SYSDATE
AND p.active_ind = 1
JOIN e WHERE
p.person_id = e.person_id
AND e.end_effective_dt_tm > SYSDATE
AND e.active_ind = 1
JOIN ce WHERE
e.encntr_id = ce.encntr_id
AND ce.publish_flag = 1
AND ce.view_level = 1
AND ce.result_status_cd NOT IN (28,29,30,31)
AND ce.valid_until_dt_tm > SYSDATE
ORDER BY
p.person_id, e.encntr_id, ce.event_id
HEAD REPORT
pcnt = 0 ;reset the person
count
HEAD
p.person_id
pcnt += 1 ;increment the person count
ecnt = 0 ;reset the encounter count
call alterlist(pec->plist, pcnt) ;allocate
memory for the next value
pec->plist[pcnt].person_id = p.person_id
HEAD
e.encntr_id
ecnt += 1 ;increment the encounter
count
ccnt = 0 ;reset the clinical event
count
call alterlist(pec->plist[pcnt].elist, ecnt) ;allocate memory for the next value
pec->plist[pcnt].elist[ecnt].encntr_id = e.encntr_id
DETAIL ;ce.event_id
ccnt += 1
call alterlist(pec->plist[pcnt].elist[ecnt].clist, ccnt) ;allocate memory for the next value
pec->plist[pcnt].elist[ecnt].clist[ccnt].event_id = ce.event_id
pec->plist[pcnt].elist[ecnt].clist[ccnt].event_cd = ce.event_cd
/**************************************************************
; Report
**************************************************************/
SELECT INTO
$OUTDEV
person_id = pec->plist[d1.seq].person_id
,encntr_id = pec->plist[d1.seq].elist[d2.seq].encntr_id
,event_id = pec->plist[d1.seq].elist[d2.seq].clist[d3.seq].event_id
,event =
UAR_GET_CODE_DISPLAY(pec->plist[d1.seq].elist[d2.seq].clist[d3.seq].event_cd)
FROM
(DUMMYT d1 WITH seq = value(size(pec->plist, 5))) ;seq = number of items in the record structure
,(DUMMYT d2 WITH seq = 1)
,(DUMMYT d3 WITH seq = 1)
PLAN d1 WHERE
MAXREC(d2, size(pec->plist[d1.seq].elist, 5))
JOIN d2 WHERE
MAXREC(d3, size(pec->plist[d1.seq].elist[d2.seq].clist, 5))
JOIN d3
ORDER BY
person_id, encntr_id, event_id
WITH
NOCOUNTER, SEPARATOR=" ", FORMAT, TIME=30
