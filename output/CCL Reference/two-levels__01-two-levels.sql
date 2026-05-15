/*
 * Source page  : Two levels
 * Source file  : output/two-levels.md
 * Anchor       : (top of page)
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 57
 *
 * Context (preceding paragraph):
 *   This demonstrates a two-level record structure, loaded from a single query. This is the
 *   most common type of record structure - some high-level information and a list of
 *   records.
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

/**************************************************************
; Declarations
**************************************************************/
;PO = Person
Orders
FREE RECORD
po
RECORD po (
1 person_id = f8
1 list[*]
2 order_id = f8
) ;end po
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
FROM PERSON p
,ORDERS o
PLAN p WHERE
p.person_id = <insert person_id>
JOIN o WHERE
o.person_id = p.person_id
ORDER BY
p.person_id, o.order_id
HEAD REPORT
i = 0 ;reset the orders count
po->person_id = p.person_id ;only
set once; not dependent on query
DETAIL ;o.order_id
i += 1
call alterlist(po->list, i) ;allocate
memory for the next value
po->list[i].order_id = o.order_id
/**************************************************************
; Report
**************************************************************/
SELECT INTO
$OUTDEV
person_id = po->person_id ;only one record member, so don't have to
specify
,order_id = po->list[d1.seq].order_id
FROM (DUMMYT
d1 WITH seq = value(size(po->list, 5)))
;seq = number of items in the record
structure
PLAN d1
ORDER BY
person_id, order_id
WITH
NOCOUNTER, SEPARATOR=" ", FORMAT, TIME=30
