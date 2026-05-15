/*
 * Source page  : BLOB notes - scratch
 * Source file  : output/blob-notes-scratch.md
 * Anchor       : Example 1 - DynDoc, retains formatting
 * Block index  : 1 of 11
 * Detected lang: ccl
 * Lines        : 142
 *
 * Context (preceding paragraph):
 *   It does not attempt to strip or modify formatting. Discern Output Viewer displays the
 *   text more or less as it would be seen in PowerChart, except it doesn't properly handle
 *   the HTML formatting, some of which may be displayed as raw text in the clinical note.
 *   It will return text for other entry modes, including PowerForm textual renditions, but
 *   will not display properly - perhaps a conflict between the note's original (RTF)
 *   formatting and Discern Output Viewer's attempts to parse it. However … it successfully
 *   demonstrates loading and stitching multiple blobs together for processing before
 *   outputting the content.
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

drop program
dev_rpt_blob_output go
create
program dev_rpt_blob_output
prompt
"Output to File/Printer/MINE" = "MINE" ;* Enter or select the printer or file name
to send this report to.
, "Event ID" = 0
with OUTDEV,
event_id
/**************************************************************
; Global
Declarations
**************************************************************/
; BLOB
HANDLING
;declare
ocf_compressed = f8 with constant(UAR_GET_CODE_BY("MEANING", 120,
"OCFCOMP")), protect
;declare
not_compressed = f8 with constant(UAR_GET_CODE_BY("MEANING", 120,
"NOCOMP")), protect
declare
u_blob = vc        ; holds the
uncompressed blob
declare
f_blob = vc ; holds final (compressed) blob (for combined blobs)
declare
buffer = c32768 with protect
declare
blob_found = i4 with protect
declare
offset = i4 with protect
declare
tag_pos = i4 with protect
declare
new_size = i4 with protect
declare
cur_pos = i4 with protect
declare
end_pos = i4 with protect
declare
u_blob_size = i4 with protect
declare
row_width = i4 with protect, constant(100)
declare chunk
= c100 with protect
/**************************************************************
; Output
**************************************************************/
SELECT INTO
$OUTDEV
FROM
CLINICAL_EVENT ce
,CE_BLOB cb
PLAN ce WHERE
ce.parent_event_id = $event_id
AND ce.valid_from_dt_tm < SYSDATE
AND ce.valid_until_dt_tm > SYSDATE
JOIN cb WHERE
cb.event_id = ce.event_id
AND cb.valid_from_dt_tm < SYSDATE
AND cb.valid_until_dt_tm > SYSDATE
;AND cb.compression_cd = ocf_compressed ;only join compressed blobs
ORDER BY
ce.event_end_dt_tm, cb.event_id, cb.blob_seq_num
HEAD
cb.event_id ;once per event, which may have multiple blob segments
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
blob_found = 1 ; initialize at 1, so while loop always runs at least
once
offset = 0
; get the blob segments and concat them into f_blob
; while loop safeguards against blobs > 32k, but usually only
executes once
while (blob_found > 0)
; get a segment of the blob, up to 32k
blob_found = blobget(buffer, offset, cb.blob_contents)
; update the offset
offset = offset + blob_found
if(blob_found != 0)
; remove the "ocf_blob" tag at the end of each blob
tag_pos = findstring("ocf_blob", buffer, 1) - 1
if(tag_pos < 1)
tag_pos = blob_found ; not found, exit the while loop
endif
; add the segment to the final blob
f_blob = notrim(concat(notrim(f_blob), notrim(substring(1, tag_pos,
buffer))))
endif
endwhile
FOOT
cb.event_id
new_size = 0
; reset printing variables
cur_pos = 0
end_pos = 0
u_blob_size = textlen(u_blob) ;vs blobgetlen/size
; add the "ocf_blob" tag back to the reassembled blob
f_blob = concat(notrim(f_blob), "ocf_blob")
; decompress f_blob and assign contents to u_blob
call uar_ocf_uncompress(f_blob, size(f_blob), u_blob, size(u_blob),
new_size)
while(cur_pos < u_blob_size)
; determine the maximum reach for this line
end_pos = cur_pos + row_width
; if we're near the end of the blob, just print the rest
if(end_pos >= u_blob_size)
chunk = substring(cur_pos, u_blob_size, u_blob)
col 0 chunk
;break out of while loop
endif
; honor existing new lines
; ... automatically handled in HTML formatting
; handle word-wrapping
; ... automatically handled in HTML formatting
; print the chunk
chunk = substring(cur_pos, end_pos, u_blob)
col 0 chunk row+1
; advance the cursor
cur_pos = end_pos
endwhile
row+2
WITH
RDBARRAYFETCH = 1, TIME=60
end
go
