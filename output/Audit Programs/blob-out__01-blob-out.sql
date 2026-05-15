/*
 * Source page  : BLOB Out
 * Source file  : output/blob-out.md
 * Anchor       : (top of page)
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 540
 *
 * Context (preceding paragraph):
 *   WARNING: Still very much a work-in-progress!
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

drop program
dev_rpt_blob_out go
create
program dev_rpt_blob_out
/******************************************************************************
 REPORT NAME:
        Blob Output
 PROGRAM:
 DEV
PROGRAM:        dev_rpt_blob_output
 DEVELOPER:        David Alt
 PUBLISHED:
 SNAPSHOT:
 LOGICAL
PATH:        cust_script
 NODE:                        <default>
 PURPOSE/DESCRIPTION: background program to decompress and display
clinical notes
                                                 from
the CE_BLOB table only (e.g. will not work with LONG_BLOB)
 TARGET AUDIENCE: developers/report authors
 DEPENDENCIES: none
 CAVEATS:
MOD        DATE                DEVELOPER        COMMENT
---        --/--/--        ---------        ----------------------------
001        02/10/26        David
Alt        File creation
TODO:
em_anesthesia/ec_mdoc - not printing properly
need a proper/dynamic wrap function instead
em_surgery - formatting off
em_ESI/ec_radiology - formatting off
print document/author information next to each segment;
BUGS:
RTF-stripped blobs seem to have weird space padding that causes
 unnatural breaks in the lines.
CONSIDER:
Add a mode to display RTF documents without stripping formatting;
DIO=36
******************************************************************************/
prompt
"Output to File/Printer/MINE" = "MINE" ;* Enter or select the printer or file name
to send this report to.
, "Event ID" = 0
, "Mode" = 1
, "Meta Information" = 0
with OUTDEV,
event_id, mode, meta
/**************************************************************
; Global
Declarations
**************************************************************/
; MODES
; 1 = one
level; decompresses only the specified event, doesn't attempt to stitch related
events
; 2 = two
levels; stitches child events together. Documents, microbiology
; 3 = three
levels; stitches child events together. Pathology reports
; META INFO
; 0 = don't
include meta information
; 1 = parent
event only
; 2 = parent
and child events
; 3 = child
events only
; 4 = child
headers only. Needed for section headers in path reports, but full blocks
disrupt the document
declare
PARENT = i2 with protect, constant(1)
declare
PARENT_CHILD = i2 with protect, constant(2)
declare CHILD
= i2 with protect, constant(3)
declare
PATH_HEADER = i2 with protect, constant(4)
; BLOB
HANDLING
declare
ocf_compressed = f8 with constant(UAR_GET_CODE_BY("MEANING", 120,
"OCFCOMP")), protect
declare
not_compressed = f8 with constant(UAR_GET_CODE_BY("MEANING", 120,
"NOCOMP")), protect
declare xhtml
= f8 with constant(22130573) ;CE_BLOB_RESULT.format_cd for XHTML
; the
uar_rtf2 function requires a fixed size for u_blob_nortf; size will be
reallocated
declare
u_blob = vc        ; holds the
uncompressed blob
declare
u_blob_nortf = c100 with protect ; holds uncompressed blob w/o RTF
declare
f_blob = vc ; holds final (compressed) blob (for combined blobs)
declare
buffer = c32768 with protect
declare blob
= i4 with protect
declare
offset = i4 with protect
declare
tag_pos = i4 with protect
declare
new_size = i4 with protect
declare
cur_pos = i4 with protect
declare
end_pos = i4 with protect ; theoretical end of the line
declare
last_space_pos = i4 with protect
declare
u_blob_size = i4 with protect
declare
nortf_size = i4 with protect
declare chunk
= c120 with protect ; adjust this to change how many characters a chunk stores
declare
chunk_size = i4 with protect, constant(120) ; needs to match chunk
; TEXT
HANDLING
; OTHER
declare idx =
i4 with protect, noconstant(0)
declare pos =
i4 with protect, noconstant(0)
/**************************************************************
; Record
Structures
**************************************************************/
free record
ids
record ids (
1 success_ind = i2
1 mode = i2
1 meta = i2
1 html_ind = i2
1 parent_event_id = f8
1 parent_event = c40
1 parent_title = c100
1 parent_performed_dt_tm = dq8
1 parent_performed_tz = i4
1 parent_performed_prsnl = c100
1 parent_verified_dt_tm = dq8
1 parent_verified_tz = i4
1 parent_verified_prsnl = c100
1 list[*]
2 event_id = f8
2 event = c40
2 title = c100
2 performed_dt_tm = dq8
2 performed_tz = i4
2 performed_prsnl = c100
2 verified_dt_tm = dq8
2 verified_tz = i4
2 verified_prsnl = c100
) ; ids
/**************************************************************
; Subroutines
**************************************************************/
subroutine(build_ids(NULL)
= NULL)
set ids->success_ind = 1
set ids->mode = $mode
set ids->meta = $meta
set ids->parent_event_id = $event_id
IF(ids->mode = 1)
SELECT INTO "NL:"
FROM CLINICAL_EVENT ce
,(LEFT JOIN PRSNL p ON p.person_id = ce.performed_prsnl_id)
,(LEFT JOIN PRSNL v ON v.person_id = ce.verified_prsnl_id)
,(LEFT JOIN CE_BLOB_RESULT cbr ON cbr.event_id = ce.event_id
AND cbr.valid_until_dt_tm > SYSDATE)
PLAN ce WHERE ce.event_id = ids->parent_event_id
AND ce.result_status_cd NOT IN (28,29,30,31)
AND ce.valid_until_dt_tm > SYSDATE
JOIN p
JOIN v
JOIN cbr
ORDER BY ce.event_id
HEAD REPORT
i = 0
HEAD ce.event_id
ids->html_ind = EVALUATE2(
IF(cbr.format_cd = xhtml) 1
ELSE 0
ENDIF)
ids->parent_event = TRIM(UAR_GET_CODE_DISPLAY(ce.event_cd))
ids->parent_title = EVALUATE2(
IF(TEXTLEN(ce.event_title_text) > 96)
CONCAT(SUBSTRING(1, 96, TRIM(ce.event_title_text)), " ...")
ELSE TRIM(ce.event_title_text)
ENDIF)
ids->parent_performed_dt_tm = ce.performed_dt_tm
ids->parent_performed_tz = ce.performed_tz
ids->parent_performed_prsnl = p.name_full_formatted
ids->parent_verified_dt_tm = ce.verified_dt_tm
ids->parent_verified_tz = ce.verified_tz
ids->parent_verified_prsnl = v.name_full_formatted
DETAIL
i += 1
CALL ALTERLIST(ids->list, i)
ids->list[i].event_id = ce.event_id
ELSEIF(ids->mode = 2)
SELECT INTO "NL:"
FROM CLINICAL_EVENT ce
,(LEFT JOIN PRSNL p ON p.person_id = ce.performed_prsnl_id)
,(LEFT JOIN PRSNL v ON v.person_id = ce.verified_prsnl_id)
,CLINICAL_EVENT ce2
,(LEFT JOIN PRSNL p2 ON p2.person_id = ce2.performed_prsnl_id)
,(LEFT JOIN PRSNL v2 ON v2.person_id = ce2.verified_prsnl_id)
,(LEFT JOIN CE_BLOB_RESULT cbr ON cbr.event_id = ce2.event_id
AND cbr.valid_until_dt_tm > SYSDATE)
PLAN ce WHERE ce.event_id = ids->parent_event_id
AND ce.result_status_cd NOT IN (28,29,30,31)
AND ce.valid_until_dt_tm > SYSDATE
JOIN ce2 WHERE ce2.parent_event_id = ce.event_id
AND ce2.event_reltn_cd = 132 ;child
AND ce2.result_status_cd NOT IN (28,29,30,31)
AND ce2.valid_until_dt_tm > SYSDATE
JOIN p
JOIN v
JOIN p2
JOIN v2
JOIN cbr
ORDER BY ce.event_id, ce2.event_id
HEAD REPORT
i = 0
HEAD ce.event_id
ids->html_ind = EVALUATE2(
IF(cbr.format_cd = xhtml) 1
ELSE 0
ENDIF)
ids->parent_event = TRIM(UAR_GET_CODE_DISPLAY(ce.event_cd))
ids->parent_title = EVALUATE2(
IF(TEXTLEN(ce.event_title_text) > 96)
CONCAT(SUBSTRING(1, 96, TRIM(ce.event_title_text)), " ...")
ELSE TRIM(ce.event_title_text)
ENDIF)
ids->parent_performed_dt_tm = ce.performed_dt_tm
ids->parent_performed_tz = ce.performed_tz
ids->parent_performed_prsnl = p.name_full_formatted
ids->parent_verified_dt_tm = ce.verified_dt_tm
ids->parent_verified_tz = ce.verified_tz
ids->parent_verified_prsnl = v.name_full_formatted
DETAIL
i += 1
CALL ALTERLIST(ids->list, i)
ids->list[i].event_id = ce2.event_id
ids->list[i].event = TRIM(UAR_GET_CODE_DISPLAY(ce2.event_cd))
ids->list[i].title = EVALUATE2(
IF(TEXTLEN(ce2.event_title_text) > 96)
CONCAT(SUBSTRING(1, 96, TRIM(ce2.event_title_text)), " ...")
ELSE TRIM(ce2.event_title_text)
ENDIF)
ids->list[i].performed_dt_tm = ce2.performed_dt_tm
ids->list[i].performed_tz = ce2.performed_tz
ids->list[i].performed_prsnl = p2.name_full_formatted
ids->list[i].verified_dt_tm = ce2.verified_dt_tm
ids->list[i].verified_tz = ce2.verified_tz
ids->list[i].verified_prsnl = v2.name_full_formatted
ELSEIF(ids->mode = 3)
SELECT INTO "NL:"
FROM CLINICAL_EVENT ce
,(LEFT JOIN PRSNL p ON p.person_id = ce.performed_prsnl_id)
,(LEFT JOIN PRSNL v ON v.person_id = ce.verified_prsnl_id)
,CLINICAL_EVENT ce2
,CLINICAL_EVENT ce3
,(LEFT JOIN PRSNL p3 ON p3.person_id = ce3.performed_prsnl_id)
,(LEFT JOIN PRSNL v3 ON v3.person_id = ce3.verified_prsnl_id)
,(LEFT JOIN CE_BLOB_RESULT cbr ON cbr.event_id = ce3.event_id
AND cbr.valid_until_dt_tm > SYSDATE)
PLAN ce WHERE ce.event_id = ids->parent_event_id
AND ce.result_status_cd NOT IN (28,29,30,31)
AND ce.valid_until_dt_tm > SYSDATE
JOIN ce2 WHERE ce2.parent_event_id = ce.event_id
AND ce2.event_reltn_cd = 132 ;child
AND ce2.result_status_cd NOT IN (28,29,30,31)
AND ce2.valid_until_dt_tm > SYSDATE
JOIN ce3 WHERE ce3.parent_event_id = ce2.event_id
AND ce3.event_reltn_cd = 132 ;child
AND ce3.result_status_cd NOT IN (28,29,30,31)
AND ce3.valid_until_dt_tm > SYSDATE
JOIN p
JOIN v
JOIN p3
JOIN v3
JOIN cbr
ORDER BY ce.event_id, ce2.event_id, ce3.event_id
HEAD REPORT
i = 0
HEAD ce.event_id
ids->html_ind = EVALUATE2(
IF(cbr.format_cd = xhtml) 1
ELSE 0
ENDIF)
ids->parent_event = TRIM(UAR_GET_CODE_DISPLAY(ce.event_cd))
ids->parent_title = EVALUATE2(
IF(TEXTLEN(ce.event_title_text) > 96)
CONCAT(SUBSTRING(1, 96, TRIM(ce.event_title_text)), " ...")
ELSE TRIM(ce.event_title_text)
ENDIF)
ids->parent_performed_dt_tm = ce.performed_dt_tm
ids->parent_performed_tz = ce.performed_tz
ids->parent_performed_prsnl = p.name_full_formatted
ids->parent_verified_dt_tm = ce.verified_dt_tm
ids->parent_verified_tz = ce.verified_tz
ids->parent_verified_prsnl = v.name_full_formatted
DETAIL
i += 1
CALL ALTERLIST(ids->list, i)
ids->list[i].event_id = ce3.event_id
ids->list[i].event = TRIM(UAR_GET_CODE_DISPLAY(ce3.event_cd))
ids->list[i].title = EVALUATE2(
IF(TEXTLEN(ce3.event_title_text) > 96)
CONCAT(SUBSTRING(1, 96, TRIM(ce3.event_title_text)), " ...")
ELSE TRIM(ce3.event_title_text)
ENDIF)
ids->list[i].performed_dt_tm = ce3.performed_dt_tm
ids->list[i].performed_tz = ce3.performed_tz
ids->list[i].performed_prsnl = p3.name_full_formatted
ids->list[i].verified_dt_tm = ce3.verified_dt_tm
ids->list[i].verified_tz = ce3.verified_tz
ids->list[i].verified_prsnl = v3.name_full_formatted
ELSE
set ids->success_ind = 0
ENDIF
end ;
build_ids
/**************************************************************
; Main
**************************************************************/
CALL
build_ids(null)
declare
performed_dt_tm = c40 with protect
declare
verified_dt_tm = c40 with protect
declare
performed_by = c100 with protect
declare
verified_by = c100 with protect
declare
performed = c110 with protect
declare
verified = c110 with protect
declare
html_ind = i2 with protect, noconstant(0)
/**************************************************************
; Output
**************************************************************/
SELECT INTO
$OUTDEV
cb.event_id
,cb.blob_seq_num
FROM CE_BLOB cb
,(LEFT JOIN CE_BLOB_RESULT cbr ON cbr.event_id = cb.event_id
AND cbr.valid_until_dt_tm >
SYSDATE)
PLAN cb WHERE EXPAND(idx,1,size(ids->list, 5),cb.event_id,
ids->list[idx].event_id)
AND cb.valid_until_dt_tm > SYSDATE
JOIN cbr
ORDER BY cb.event_id, cb.blob_seq_num
HEAD REPORT
; print parent event information
event_type = CONCAT("Parent event: ",
ids->parent_event)
performed = TRIM(CONCAT(
"Performed on ",
TRIM(DATETIMEZONEFORMAT(ids->parent_performed_dt_tm,
ids->parent_performed_tz, "MM/DD/YYYY HH:MM (ZZZ);;q")),
" by ",
TRIM(ids->parent_performed_prsnl)
))
verified = TRIM(CONCAT(
"Verified on ",
TRIM(DATETIMEZONEFORMAT(ids->parent_verified_dt_tm,
ids->parent_verified_tz, "MM/DD/YYYY HH:MM (ZZZ);;q")),
" by ",
TRIM(ids->parent_verified_prsnl)
))
IF($meta IN (PARENT, PARENT_CHILD))
IF(ids->html_ind = 1)
col 0
"************************************************************************************</br>",
row+1
col 0
event_type,        "</br>",        row+1
col 0
performed,        "</br>",        row+1
col 0
verified,                "</br>",        row+1
col 0
"************************************************************************************</br>",
row+1
col 0
"<p></p>",        row+1
ELSE
col 0
"************************************************************************************",
row+1
col 0
event_type,                row+1
col 0 performed,
                row+1
col 0
verified,                        row+1
col 0
"************************************************************************************",
row+2
ENDIF
ENDIF
HEAD cb.event_id ;once per event, which may have multiple blob segments
; reset blob processing variables
u_blob = " "
f_blob = " "
buffer = " "
; initialize u_blob to a size that can hold the entire blob. For each
; 32k segment, pad u_blob with 32k. It's still compressed at this point
for (x = 1 to (cb.blob_length/32768))
u_blob = notrim(concat(notrim(u_blob),notrim(fillstring(32768, "
"))))
endfor
; now initialize space for the remainder, which will be less than 32k
remainder = mod(cb.blob_length, 32768)
u_blob = notrim(concat(notrim(u_blob),
 notrim(substring(1,remainder,fillstring(32768,
" ")))))
DETAIL
bytes_read = 1 ; initialize at 1, so while loop always runs at least
once
offset = 0
; get the blob segments and concat them into f_blob
; while loop safeguards against blobs > 32k, but usually only
executes once
while (bytes_read > 0)
; fetch a segment of the blob (up to 32k) and store in the buffer
bytes_read = blobget(buffer, offset, cb.blob_contents)
; update the offset
offset = offset + bytes_read
if(bytes_read != 0) ; we found data
; remove the "ocf_blob" tag at the end of each blob
tag_pos = findstring("ocf_blob", buffer, 1) - 1
if(tag_pos < 1) ; the tag wasn't found
tag_pos = bytes_read ; set bytes_read to exit the while loop
endif
; add the segment to the final blob
f_blob = notrim(concat(notrim(f_blob), notrim(substring(1, tag_pos,
buffer))))
endif
endwhile
FOOT cb.event_id
; initialize variables
uncompressed_size = 0
cur_pos = 0
end_pos = 0
; decompress f_blob and assign contents to u_blob
if(cb.compression_cd = ocf_compressed)
; add the "ocf_blob" tag back to the reassembled blob
f_blob = concat(notrim(f_blob), "ocf_blob")
call uar_ocf_uncompress(f_blob, size(f_blob), u_blob, size(u_blob),
uncompressed_size)
else
u_blob = f_blob
endif
; reallocate u_blob_nortf to a fixed length character variable that is
the size of u_blob
stat = memrealloc(u_blob_nortf, 1 ,build("c",size(u_blob)))
; strip the rtf from the blob and assign to u_blob_nortf
; https://wiki.cerner.com/display/public/1101discernHP/UAR_RTF2+Using+Discern+Explorer
; UAR_RTF2(InBuffer, InBufLen, OutBuffer ,OutBufLen, RetBufLen, bFlag)
stat = uar_rtf2(u_blob, size(u_blob), u_blob_nortf, size(u_blob_nortf),
nortf_size, 1)
; print event header
IF($meta = PATH_HEADER)
path_info = CONCAT("### REPORT SECTION: ", TRIM(ids->list[pos].title), "
###")
col 0 row+1, path_info, row+1
ENDIF
; print blob contents
WHILE(cur_pos < nortf_size)
; determine the maximum reach for this line
end_pos = cur_pos + chunk_size
; if we're near the end of the blob, just print the rest
IF(end_pos >= nortf_size)
chunk = substring(cur_pos, nortf_size - cur_pos, u_blob_nortf)
col 0 chunk
;break out of while loop
ELSE
; find the last space
FOR (x = cur_pos TO end_pos)
IF(substring(x, 1, u_blob_nortf) = " ")
last_space_pos = x
ENDIF
ENDFOR
IF(last_space_pos != -1)
end_pos = last_space_pos
ENDIF
; print the chunk
chunk = substring(cur_pos, end_pos - cur_pos, u_blob_nortf)
col 0 chunk
ENDIF
; advance the cursor
IF(last_space_pos = -1)
cur_pos = end_pos
ELSE
cur_pos = end_pos + 1 ;skip the space
ENDIF
; advance to the next line
row+1
ENDWHILE
; print event footer
IF($meta IN (PARENT_CHILD, CHILD))
IF(ids->html_ind = 1)
col 0 "<p></p>",
        row+1
col 0
"************************************************************************************</br>",
row+1
col 0 "<p></p>",
        row+1
ELSE
col 0 row+1
col 0
"************************************************************************************",
row+1
col 0 row+1
ENDIF
ENDIF
WITH
RDBARRAYFETCH=1, EXPAND=2, TIME=30, SEPARATOR=" ", FORMAT,
UAR_CODE(D)
end
go
