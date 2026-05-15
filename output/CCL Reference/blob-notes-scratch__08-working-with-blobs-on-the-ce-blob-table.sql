/*
 * Source page  : BLOB notes - scratch
 * Source file  : output/blob-notes-scratch.md
 * Anchor       : Working with blobs on the ce_blob table:
 * Block index  : 8 of 11
 * Detected lang: ccl
 * Lines        : 146
 *
 * Context (preceding paragraph):
 *   end
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

/*
When blobs
are stored on the ce_blob table, one actual blob may be broken up into multiple
rows on
the table.
Each row will contain up to a 32k segment of the blob. The text string
"ocf_blob" will
be appended
to each of the rows. All of the rows that have the same event_id where the
current
date and time
is between the valid_from_dt_tm and the valid_until_dt_tm will make up one
actual blob.
The
blob_seq_num field is used to determine the order of the individual blob
segements.
The following
example program selects the rows for a specific event_id, concats them into a
single
variable,
uncompresses the blob and writes it to a file.
*/
drop program
1_multi_record_blob go
create
program 1_multi_record_blob
;*****
declare blob working variables
declare
good_blob = vc
declare
print_blob = vc
declare
outbuf = c32768
declare
blobout = vc
declare
retlen = i4
declare
offset = i4
declare
newsize = i4
declare
finlen = i4
declare
xlen=i4
;for testing
set event_id to a specific event_id
;a real
program would probably join to the ce_blob table using the event_id
declare
event_id = f8 with constant(398851264.0)
declare
event_id_str = c20 with constant(cnvtstring(event_id))
declare
file_name = vc with constant(build("1_", event_id_str,
".RTF"))
select into
value(file_name)
cb.event_id,
cb.blob_seq_num,
cb.BLOB_LENGTH,
cb.VALID_FROM_DT_TM,
cb.VALID_UNTIL_DT_TM
from ce_blob
cb where cb.event_id = event_id
;some processes appear to write new rows when the blob is updated
;the old rows will have a valid_until_dt_tm before the current
date/time
;the following qualification gets only the valid rows
and cb.VALID_FROM_DT_TM < cnvtdatetime(curdate,curtime3)
and cb.VALID_UNTIL_DT_TM > cnvtdatetime(curdate,curtime3)
order by
;since blobget() is used sorting must be done at the RDBMS level
cb.event_id,
cb.blob_seq_num
head
cb.event_id
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
xlen = retlen
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
;;;***** uncompress the re-assembled blob.
/***** The uncompressed blob is assigned to the blobout variable. Any
additional processing of the blob can be done using the blobout variable.
*****/
blob_un = uar_ocf_uncompress(good_blob, size(good_blob), blobout,
size(blobout), newsize )
;Output the blob to a file 32000 characters at a time
offset = 1
while (offset < size(blobout))
;Output to file...
print_blob = trim(substring(offset, 32000, blobout))
if (size(print_blob) > 0)
col 0 print_blob
row +1
endif
offset = offset + 32000
endwhile
WITH MAXCOL =
32100 , RDBARRAYFETCH = 1, format=undefined
end
go
