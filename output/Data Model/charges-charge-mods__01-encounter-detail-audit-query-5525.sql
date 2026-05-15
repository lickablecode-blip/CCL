/*
 * Source page  : Charges, Charge Mods
 * Source file  : output/charges-charge-mods.md
 * Anchor       : Encounter Detail Audit query, 5/5/25
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 238
 *
 * Context (preceding paragraph):
 *   Source: Chris Bevington training course
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

ELSEIF($cat =
"encounter" AND $enc_rpt = "Charges")
 charge = c.charge_description
 ,category = EVALUATE2(
 IF(c.activity_sub_type_cd > 0)
CONCAT(
 TRIM(UAR_GET_CODE_DISPLAY(c.activity_type_cd)),
 " (",
 TRIM(UAR_GET_CODE_DISPLAY(c.activity_sub_type_cd)),
 ")")
 ELSE
UAR_GET_CODE_DISPLAY(c.activity_type_cd)
 ENDIF)
 ,service_dt_tm =
DATETIMEZONEFORMAT(c.service_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,icd_diag = icd.field6
 ,icd_diag2 = icd2.field6
 ,icd_diag3 = icd3.field6
 ,icd_proc = icd_proc.field6
 ,cpt = cpt.field6
 ,cpt_mod = cpt_mod.field6
 ,cpt_mod2 = cpt_mod2.field6
 ,cpt_mod3 = cpt_mod3.field6
 ,hcpcs = hcpcs.field6
 ,revenue = rev_code.field6
 ,cdm = cdm.field6
 ,ndc = ndc.field6
 ; CHARGE DETAILS
 ,charge_type =
UAR_GET_CODE_DISPLAY(c.charge_type_cd)
 ,tier_group =
UAR_GET_CODE_DISPLAY(c.tier_group_cd)
 ,financial_class =
UAR_GET_CODE_DISPLAY(c.fin_class_cd)
 ,offset = IF(c.offset_charge_item_id >
0) "yes" ELSE "no" ENDIF
 ,c.manual_ind
 ,status = EVALUATE(c.process_flg,
 0,        "Pending",
 1,        "Suspended",
 2,        "Review",
 3,        "On Hold",
 4,        "Manual",
 5,        "Skipped",
 6,        "Combined",
 7,        "Absorbed",
 8,        "ABN (Advanced
Beneficiary Notice) Status",
 10,        "Offset",
 11,        "Adjusted",
 12,        "Grouped",
 13,        "Unreconciled
Credit",
 100,        "Posted",
 222,        "Temporary Near
Time In-Process",
 777,        "Bundled",
 977,        "Bundled -
Interfaced",
 996,        "OMF Stats
Only",
 998,        "Pharmacy NO
CHARGE charges",
 997,        "Statistics
Only",
 999,        "Interfaced",
 "<unmapped
value>")
 ,quantity = c.item_quantity
 ,price = c.item_price
 ; OTHER DATE TIMES
 ,credited_dt_tm =
DATETIMEZONEFORMAT(c.credited_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,adjusted_dt_tm =
DATETIMEZONEFORMAT(c.adjusted_dt_tm, ids->tz, "MM/DD/YYYY
HH:MM;;q")
 ,updt_dt_tm =
DATETIMEZONEFORMAT(c.updt_dt_tm, ids->tz, "MM/DD/YYYY HH:MM;;q")
 ; PROVIDERS
 ,ordering_provider =
CNVTUPPER(ord_prov.name_full_formatted)
 ;,performing_provider =
CNVTUPPER(perf_prsnl.name_full_formatted)
 ,verifying_provider =
CNVTUPPER(veri_prsnl.name_full_formatted)
 ,posted_by =
CNVTUPPER(post_prsnl.name_full_formatted)
 ,updated_by =
CNVTUPPER(updt_prsnl.name_full_formatted)
 ; ANCILLARY INFO
; ,performing_loc =
UAR_GET_CODE_DISPLAY(c.perf_loc_cd)
; ,department =
UAR_GET_CODE_DISPLAY(c.department_cd)
; ,section =
UAR_GET_CODE_DISPLAY(c.section_cd)
; ,accession =
UAR_FMT_ACCESSION(c_evnt.accession, size(c_evnt.accession, 1))
 ; IDENTIFIERS
 ,c.order_id
 ,c.bill_item_id
 ,c.charge_item_id
; ,c.parent_charge_item_id
; ,c.offset_charge_item_id
; ,c.charge_event_id
; ,c.price_sched_id
; ,c.bundle_id
FROM CHARGE c
 ;ICD DIAGNOSIS CODES
 ,(LEFT JOIN CHARGE_MOD icd ON
c.charge_item_id = icd.charge_item_id
 AND icd.field1_id =
value(UAR_GET_CODE_BY("MEANING",14002,"ICD9"))
 AND icd.field2_id = 1)
 ,(LEFT JOIN CHARGE_MOD icd2
ON c.charge_item_id = icd2.charge_item_id
 AND icd2.field1_id =
value(UAR_GET_CODE_BY("MEANING",14002,"ICD9"))
 AND icd2.field2_id = 2)
 ,(LEFT JOIN CHARGE_MOD icd3
ON c.charge_item_id = icd3.charge_item_id
 AND icd3.field1_id =
value(UAR_GET_CODE_BY("MEANING",14002,"ICD9"))
 AND icd3.field2_id = 3)
 ;ICD PROCEDURE CODES
 ,(LEFT JOIN CHARGE_MOD
icd_proc ON c.charge_item_id = icd_proc.charge_item_id
 AND icd_proc.field1_id IN
(SELECT cv.code_value FROM CODE_VALUE cv
 WHERE cv.code_set = 14002 AND cv.cdf_meaning = "PROCCODE"
 AND cv.active_ind = 1 AND cv.end_effective_dt_tm > SYSDATE)
 AND icd_proc.field2_id =
1)
 ;CPT PROCEDURE CODES
 ,(LEFT JOIN CHARGE_MOD cpt ON
c.charge_item_id = cpt.charge_item_id
 AND cpt.field1_id IN
(SELECT cv.code_value FROM CODE_VALUE cv
 WHERE cv.code_set = 14002 AND cv.cdf_meaning = "CPT4"
 AND cv.active_ind = 1 AND cv.end_effective_dt_tm > SYSDATE)
 AND cpt.field2_id = 1)
 ;CPT MODIFIER CODES
 ,(LEFT JOIN CHARGE_MOD
cpt_mod ON c.charge_item_id = cpt_mod.charge_item_id
 AND cpt_mod.field1_id IN
(SELECT cv.code_value FROM CODE_VALUE cv
 WHERE cv.code_set = 14002 AND cv.cdf_meaning = "MODIFIER"
 AND cv.active_ind = 1 AND cv.end_effective_dt_tm > SYSDATE)
 AND cpt_mod.field2_id =
1)
 ,(LEFT JOIN CHARGE_MOD
cpt_mod2 ON c.charge_item_id = cpt_mod2.charge_item_id
 AND cpt_mod2.field1_id IN
(SELECT cv.code_value FROM CODE_VALUE cv
 WHERE cv.code_set = 14002 AND cv.cdf_meaning = "MODIFIER"
 AND cv.active_ind = 1 AND cv.end_effective_dt_tm > SYSDATE)
 AND cpt_mod2.field2_id =
2)
 ,(LEFT JOIN CHARGE_MOD
cpt_mod3 ON c.charge_item_id = cpt_mod3.charge_item_id
 AND cpt_mod3.field1_id IN
(SELECT cv.code_value FROM CODE_VALUE cv
 WHERE cv.code_set = 14002 AND cv.cdf_meaning = "MODIFIER"
 AND cv.active_ind = 1 AND cv.end_effective_dt_tm > SYSDATE)
 AND cpt_mod3.field2_id =
3)
 ;HCPCS CODES
 ,(LEFT JOIN CHARGE_MOD hcpcs
ON c.charge_item_id = hcpcs.charge_item_id
 AND hcpcs.field1_id IN
(SELECT cv.code_value FROM CODE_VALUE cv
 WHERE cv.code_set = 14002 AND cv.cdf_meaning = "HCPCS"
 AND cv.active_ind = 1 AND cv.end_effective_dt_tm > SYSDATE)
 AND hcpcs.field2_id = 1)
 ;REVENUE CODES
 ,(LEFT JOIN CHARGE_MOD
rev_code ON c.charge_item_id = rev_code.charge_item_id
 AND rev_code.field1_id IN
(SELECT cv.code_value FROM CODE_VALUE cv
 WHERE cv.code_set = 14002 AND cv.cdf_meaning = "REVENUE"
 AND cv.active_ind = 1 AND cv.end_effective_dt_tm > SYSDATE)
 AND rev_code.field2_id =
1)
 ;CDM CODES
 ,(LEFT JOIN CHARGE_MOD cdm ON
c.charge_item_id = cdm.charge_item_id
 AND cdm.field1_id IN
(SELECT cv.code_value FROM CODE_VALUE cv
 WHERE cv.code_set = 14002 AND cv.cdf_meaning = "CDM_SCHED"
 AND cv.active_ind = 1 AND cv.end_effective_dt_tm > SYSDATE)
 )
 ;NDC
number
 ,(LEFT JOIN CHARGE_MOD ndc ON
c.charge_item_id = ndc.charge_item_id
 AND ndc.field1_id =
24356556)
 ,CHARGE_EVENT c_evnt ;needed
for accession
 ,PRSNL ord_prov
 ,PRSNL updt_prsnl
 ,PRSNL perf_prsnl
 ,PRSNL veri_prsnl
 ,PRSNL post_prsnl
 PLAN c WHERE c.encntr_id =
ids->encntr_id
         ;AND
c.offset_charge_item_id = 0 ;what exactly does this do?
 AND c.active_ind = 1
 AND c.end_effective_dt_tm > SYSDATE
 JOIN c_evnt WHERE c.charge_event_id =
c_evnt.charge_event_id
 AND c_evnt.active_ind = 1
 JOIN ord_prov WHERE c.ord_phys_id =
ord_prov.person_id
 JOIN updt_prsnl WHERE c.updt_id =
updt_prsnl.person_id
 JOIN perf_prsnl WHERE c.perf_phys_id =
perf_prsnl.person_id
 JOIN veri_prsnl WHERE c.verify_phys_id =
veri_prsnl.person_id
 JOIN post_prsnl WHERE c.posted_id =
post_prsnl.person_id
 JOIN icd
 JOIN icd2
 JOIN icd3
 JOIN icd_proc
 JOIN cpt
 JOIN cpt_mod
 JOIN cpt_mod2
 JOIN cpt_mod3
 JOIN hcpcs
 JOIN rev_code
 JOIN cdm
 JOIN ndc
 ORDER BY category, c.service_dt_tm, charge
