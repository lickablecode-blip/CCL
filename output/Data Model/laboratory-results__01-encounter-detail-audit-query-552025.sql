/*
 * Source page  : Laboratory results
 * Source file  : output/laboratory-results.md
 * Anchor       : Encounter Detail Audit query, 5/5/2025
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 177
 *
 * Context (preceding paragraph):
 *   (no preceding paragraph)
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

ELSEIF($cat =
"encounter" AND $enc_rpt = "Lab Results")
 orderable = oc.description
 ,event = UAR_GET_CODE_DISPLAY(ce.event_cd)
 ,result = ce.result_val
 ,result_units =
UAR_GET_CODE_DISPLAY(ce.result_units_cd)
 ,result_flag =
UAR_GET_CODE_DISPLAY(ce.normalcy_cd)
 ,result_status =
UAR_GET_CODE_DISPLAY(ce.result_status_cd)
;ORDER INFO
 ,order_status =
UAR_GET_CODE_DISPLAY(o.order_status_cd)
 ,dept_status =
UAR_GET_CODE_DISPLAY(o.dept_status_cd)
 ,performing_device =
UAR_GET_CODE_DISPLAY(ce.resource_cd)
 ,performing_lab =
UAR_GET_CODE_DISPLAY(perf_resource.location_cd)
 ,performing_facility = perf_org.org_name
 ;COLLECTION/SPECIMEN
 ,specimen_type =
UAR_GET_CODE_DISPLAY(c.specimen_type_cd) ;replaced CE-based field
 ,collection_method =
UAR_GET_CODE_DISPLAY(c.collection_method_cd) ;replaced CE-based field
 ,collection_priority =
UAR_GET_CODE_DESCRIPTION(spec.specimen_collect_priority_cd) ;DISPLAY is
abbreviated
 ,collection_status =
EVALUATE(ocr.collection_status_flag,
         0, "Pending",
         1,
"Collected",
         2, "On Hold",
         3,
"Recollect",
         4,
"Rescheduled",
         5, "Canceled",
         6, "Omitted",
         7, "Inactive",
         "<unmapped
value>")
,container_location = UAR_GET_CODE_DISPLAY(c.current_location_cd)
 ;TIMING
 ,order_dt_tm =
DATETIMEZONEFORMAT(o.orig_order_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,collect_dt_tm =
DATETIMEZONEFORMAT(c.drawn_dt_tm, ids->tz, "MM/DD/YYYY HH:MM;;q")
;replaced CE-based field
 ,received_dt_tm =
DATETIMEZONEFORMAT(c.received_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q") ;replaced CE-based field
 ,performed_dt_tm =
DATETIMEZONEFORMAT(ce.performed_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,verified_dt_tm =
DATETIMEZONEFORMAT(ce.verified_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ;,tat_ordered_to_verified =
 ;,tat_received_to_verified =
;OTHER LAB ORDER INFO
 ,activity_type =
UAR_GET_CODE_DISPLAY(oc.activity_type_cd)
 ,activity_subtype =
UAR_GET_CODE_DISPLAY(oc.activity_subtype_cd)
 ,loinc_analyte = PIECE(cid.concept_cki,
"!", 2, "")
 ;REFERENCE RANGES
 ,ce.critical_low
 ,ce.normal_low
 ,ce.normal_high
 ,ce.critical_high
;ENCOUNTER/PROVIDER INFO
 ,responsible_provider =
         IF(order_p.position_cd
!= 0)
                 BUILD(order_p.name_full_formatted,
" (", TRIM(UAR_GET_CODE_DISPLAY(order_p.position_cd)), ")")
         ELSE
order_p.name_full_formatted
         ENDIF
 ,ordering_prsnl =
         IF(entry_p.position_cd
!= 0)
                 BUILD(entry_p.name_full_formatted,
" (", TRIM(UAR_GET_CODE_DISPLAY(entry_p.position_cd)), ")")
         ELSE
entry_p.name_full_formatted
         ENDIF
 ;OTHER IDENTIFIERS
,order_type =
         IF(o.originating_encntr_id
!= 0 AND o.encntr_id = 0) "future (unactivated)"
         ELSEIF(o.originating_encntr_id
!= 0 AND o.encntr_id != 0) "future (activated)"
         ELSEIF(o.originating_encntr_id
= 0) "non-future"
         ELSE "other"
         ENDIF
 ,template_flag =
EVALUATE(o.template_order_flag,
         0, "None",
         1, "Template",
         2, "Order-based
Instance",
         3, "Task-based
Instance",
         4, "Rx-based
Instance",
         5, "Future
Recurring Template",
         6, "Future
Recurring Instance",
         7, "Protocol",
         "<unmapped
value>")
,accession_formatted = UAR_FMT_ACCESSION(ca.accession,
size(ca.accession, 1)) ;replaced CE version
,o.order_id
 ,ce.event_id
 ;,c.container_id
 ;,c.specimen_id
 FROM CLINICAL_EVENT ce
,(LEFT JOIN ORDER_CONTAINER_R ocr ON ocr.order_id = ce.order_id)
,(LEFT JOIN CONTAINER c ON c.container_id = ocr.container_id)
,(LEFT JOIN CONTAINER_ACCESSION ca ON ca.container_id =
c.container_id)
 ,(LEFT JOIN V500_SPECIMEN spec ON
spec.specimen_id = c.specimen_id)
 ,(LEFT JOIN SERVICE_RESOURCE
perf_resource ON ce.resource_cd = perf_resource.service_resource_cd)
 ,(LEFT JOIN ORGANIZATION perf_org ON
perf_resource.organization_id = perf_org.organization_id)
 ,(LEFT JOIN CONCEPT_IDENTIFIER_DTA cid
ON ce.task_assay_cd = cid.task_assay_cd
 AND cid.service_resource_cd =
ce.resource_cd
 AND cid.specimen_type_cd =
c.specimen_type_cd
 AND cid.concept_type_flag = 1
;LOINC Analyte Code
 AND cid.ignore_ind = 0 ;row is not
ignored by the LOINC service
 AND cid.active_ind = 1
 AND cid.end_effective_dt_tm >
SYSDATE)
         ,ORDERs o
 ,ORDER_CATALOG oc
 ,ORDER_ACTION oa
 ,PRSNL order_p
 ,PRSNL entry_p
PLAN ce WHERE ce.encntr_id = ids->encntr_id
 AND ce.view_level = 1
         AND ce.result_status_cd
NOT IN (28,29,30,31) ;IN ERROR
         AND ce.valid_until_dt_tm
>= SYSDATE
 JOIN o WHERE o.order_id = ce.order_id
AND o.catalog_type_cd = 2513 ;lab
JOIN oc WHERE o.catalog_cd = oc.catalog_cd
JOIN oa WHERE oa.order_id = o.order_id AND oa.action_type_cd = 2534
;ordered
JOIN order_p WHERE order_p.person_id = oa.order_provider_id
JOIN entry_p WHERE entry_p.person_id = oa.action_personnel_id
 JOIN ocr
 JOIN c
 JOIN ca
 JOIN spec
 JOIN perf_resource
 JOIN perf_org
 JOIN cid
 ;I don't love this sort order but it keeps
the panel results together
 ORDER BY ce.order_id, event
