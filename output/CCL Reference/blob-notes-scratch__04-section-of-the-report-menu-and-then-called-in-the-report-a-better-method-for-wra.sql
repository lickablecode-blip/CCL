/*
 * Source page  : BLOB notes - scratch
 * Source file  : output/blob-notes-scratch.md
 * Anchor       : section of the Report menu and then called in the report. A better method for wrapping the text in VE would be to use the print across multiple lines option. To see this option place a field on the report writer layout grid and then double click it. The print across multiple lines option includes the cclsource:vcclrtf.inc file that is shipped with VE and then calls the cclrtf_print subroutine to print the text on multiple lines.
 * Block index  : 4 of 11
 * Detected lang: ccl
 * Lines        : 51
 *
 * Context (preceding paragraph):
 *   end
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

subroutine
ccl_text_wrap(column, length, string)
;column = column where item is placed on report
;length = the length of the text string before it wraps
;string = the textual field that is being placed on the report
;initialize variables
eol = size(trim(string), 1) ;finds total length of trimmed string
bseg = 1
eseg = 1
chunk = substring(bseg, eol, string)
while(eseg <= eol )<br /> bseg = eseg
eseg = eseg + y
;if there is a space in the segment, break on the space
if(findstring(" ", substring(bseg, eseg-bseg, chunk)) > 0)
while(substring(eseg -1, 1, chunk) != " " and eseg != bseg)
eseg = eseg - 1
endwhile
segment = substring(bseg,(eseg - bseg) -1, string)
else
segment = substring(bseg,(eseg - bseg), string)
endif
col x call print(substring(1, length, segment))
row +1
endwhile
end
cntr = 0
Detail
cnt = 1
cntr = cntr +1
col 0 "Record:" , cntr
col +2 "Event ID:", cb.event_id
;use uar_ocf_uncompress to uncompress the blob
;the uncompressed blob is assigned to the variable blobout
blob_un = UAR_OCF_UNCOMPRESS(cb.blob_contents, size(cb.blob_contents),
blobout, size(blobout), 32768)
;use uar_rtf2 to strip the rtf from the blob
stat = uar_rtf2(blobout, size(blobout), blobnortf, size(blobnortf),
bsize, 0)
col +1 call ccl_text_wrap(col, 100, blobnortf)
row +1
WITH MAXREC =
20, MAXCOL = 32000, NOHEADING, FORMAT = VARIABLE
end
go
/***NOTE if
the blob appears to be overlaying, reinitialize BlobOut and BlobNoRTF
BlobOut=
fillstring( 32768, ' ' )
BlobNoRTF =
fillstring( 32768, ' ' )
*/
