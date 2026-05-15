/*
 * Source page  : BLOB notes - scratch
 * Source file  : output/blob-notes-scratch.md
 * Anchor       : The above example is coded to output one blob. Trying to use it to output multiple blobs will result in a couple of issues. The first issue is the code appears to output the same blob for each event_id. To resolve that reset the variables (blobout, outbuf, good_blob, blobnortf) that are used by the uncompress process to a space in the head cb.event_id section. The second issue is that UAR_RTF2 requires a pre-allocated fixed length character variable for the output buffer. Since blobs on the ce_blob table can be split across multiple rows, you really shouldn't just pick a length to use when declaring a fixed length variable. Doing so runs the risk of hitting a blob that exceeds the fixed size you picked. To resolve that issue, declare the variable (BlobNoRTF) that is used for the output buffer for UAR_RTF2 as a fixed length character variable (c100). Then in the foot cb.event_id section use the MEMREALLOC() function to redefine the variable to the size of the uncompressed blob. There will be some other differences between the following example and the one from above. But those are the major changes. Here is the revised code which appears to display multiple blobs:
 * Block index  : 9 of 11
 * Detected lang: ccl
 * Lines        : 161
 *
 * Context (preceding paragraph):
 *   end
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

drop program
1_ccl_multi_multi_record_blob go
create
program 1_ccl_multi_multi_record_blob
prompt
"Output
to File/Printer/MINE" = "MINE"
with OUTDEV
;*****
declare blob working variables
declare
OCFCOMP_VAR = f8 with
Constant(uar_get_code_by("MEANING",120,"OCFCOMP")),protect
declare
good_blob = vc with protect
declare
print_blob = c100 with protect
declare
outbuf = c32768 with protect
declare
blobout = vc with protect
;uar_rtf2()
requires a pre-allocated fixed length character variable for the output buffer
so declaring BlobNoRTF ;as c100
;will use
MemReAlloc() in report writer to resize to length of uncompressed blob
declare
BlobNoRTF = c100 with protect
declare
retlen = i4 with protect
declare
offset = i4 with protect
declare
newsize = i4 with protect
declare
nortfsize = i4 with protect
declare
finlen = i4 with protect
declare
xlen=i4 with protect
select into
$outdev
cb.event_id,
cb.blob_seq_num,
cb.BLOB_LENGTH,
cb.VALID_FROM_DT_TM,
cb.VALID_UNTIL_DT_TM
from ce_blob
cb where cb.event_id in (25680280.00, 26790291.00, 52212337.00)
;for testing qualifying on specific event_ids
;a real program would probably join to the ce_blob table using the
event_id
;see the next example for information on joining to the clinical_event
table to the ce_blob table
and VALID_FROM_DT_TM < cnvtdatetime(curdate,curtime3)
and cb.VALID_UNTIL_DT_TM > cnvtdatetime(curdate,curtime3)
;some processes appear to write new rows when the blob is updated
;the old rows will have a valid_until_dt_tm before the current
date/time
;the following qualification gets only the valid rows
and cb.compression_cd = ocfcomp_var
order by
;since blobget() is used sorting must be done at the RDBMS level
cb.event_id
,cb.blob_seq_num
head
cb.event_id
blobout = " " ;reset the blob processing variables for each
event_id
outbuf = " "
good_blob = " "
blobnortf = " "
;****** initialize blobout to a size that will be large enough to hold
the full uncompressed blob
;****** initialize space for the 32k segments
for (x = 1 to (cb.blob_length/32768) )
blobout = notrim(concat(notrim(blobout),notrim(fillstring(32768, "
"))))
endfor
finlen = mod(cb.blob_length,32768)
;****** initialize space for the final segment. the final segment will
less than 32k.
blobout =
notrim(concat(notrim(blobout),notrim(substring(1,finlen,fillstring(32768,
" ")))))
DETAIL
retlen = 1
offset = 0
;*** get the blob segments and concat them into a single variable named
good_blob
;*** the following while loop is used in case the blob_contents is
actually more than 32k
;*** in most cases the while loop will only be executed one time
because the blob is stored
;*** in 32k segments
while (retlen > 0)
;;; *** this gets a segment of the blob upto 32000 specified by retlen,
offset is an accum of retlen
retlen = blobget(outbuf, offset, cb.blob_contents)
offset = offset + retlen
if(retlen!=0)
;*** when dealing with CE_BLOB each row is ended with the tag
"ocf_blob"
;*** these tags need to be excluded when the blob segments are
re-assembled
xlen = findstring("ocf_blob",outbuf,1)-1
if(xlen<1)
<br /> xlen = retlen
endif
good_blob = notrim(concat(notrim(good_blob),
notrim(substring(1,xlen,outbuf))))
endif
endwhile
foot
cb.event_id
newsize = 0
;;;***** put the ocf_blob terminator back on the end of the
re-assembled blob
good_blob = concat(notrim(good_blob),"ocf_blob")
/**** uncompress the re-assembled blob. The uncompressed blob is
assigned to the variable blobout. Any additional processing of the uncompressed
blob can be done using the blobout variable. *****/
blob_un = uar_ocf_uncompress(good_blob, size(good_blob), blobout,
size(blobout), newsize )
;reallocate BlobNoRTF to a fixed length character variable that is the
size of blobout
stat = memrealloc(BlobNoRTF,1,build("c",size(blobout)))
call echo(build("size of BlobNoRTF:",size(BlobNoRTF)))
;;;***** use uar_rtf2 to strip the rtf from the blob
stat = uar_rtf2(blobout,
size(blobout),
BlobNoRTF,
size(BlobNoRTF),
nortfsize,
1)
col 0 "*****************Event ID:" col +1 cb.event_id col +1
" *****************" row +1
;Output the blob 100 characters at a time. No attempt is made to break
lines on spaces.
;Likely need to test to ensure the entire blob is getting printed.
;It would be better to use one of the common wrapping routines or a
wrap and grow item in
;layout builder to display the blob information.
offset = 1
while (offset < size(trim(BlobNoRTF)))
print_blob = trim(substring(offset, 100, BlobNoRTF))
print_blob = replace(replace(print_blob,char(13),"
"),char(10)," ")
if (size(print_blob) > 0)
col 0 print_blob
row +1
endif
offset = offset + 100
endwhile
row +1
WITH
RDBARRAYFETCH = 1, maxrec = 1000, time = 30
;,skipreport
= 1, format, separator = " "
end
go
