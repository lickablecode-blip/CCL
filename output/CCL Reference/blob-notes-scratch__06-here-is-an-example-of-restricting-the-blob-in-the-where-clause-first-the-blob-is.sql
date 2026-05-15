/*
 * Source page  : BLOB notes - scratch
 * Source file  : output/blob-notes-scratch.md
 * Anchor       : Here is an example of restricting the blob in the where clause, first the blob is uncompressed before the search is applied. Also, the blobout variable is declared before the select. Qualifying on blobs is inefficient so other qualifications must be used to limit the number of blob that are read. This example assumes the blob will be stored in a single row on the ce_blob. Blobs can be stored in multiple rows on the ce_blob table. See the Working with blobs on the ce_blob table section for an example that shows working with blobs that are stored in multiple rows.
 * Block index  : 6 of 11
 * Detected lang: ccl
 * Lines        : 44
 *
 * Context (preceding paragraph):
 *   end
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

DROP PROGRAM
blobtest GO
CREATE
PROGRAM blobtest
SET OcfCD =
0.0
Set stat =
uar_get_meaning_by_codeset(120,"OCFCOMP",1,OcfCD)
set BlobOut=
fillstring( 32768, ' ' )
SELECT
tlen = textlen(c.blob_contents),
BlobIn = trim(C.BLOB_CONTENTS)
FROM CE_BLOB
C, dummyt d
PLAN C WHERE
C.COMPRESSION_CD = OcfCD
join d where
ASSIGN(BlobOut, fillstring( 32768, ' ' ))
;CLEARS OUT BlobOut VARIABLE FOR THE NEXT RECORD
AND UAR_OCF_UNCOMPRESS(c.blob_contents,size(c.blob_contents), /*
changed from textlen(c.blob_contents) to size(c.blob_contents). */
BLOBOUT, SIZE( BLOBOUT ), 32768) >= 0
and blobout = "*chest*"
Head Report
;BlobOut= fillstring( 32768, ' ' )
cntr = 0
Detail
cnt = 1
cntr = cntr +1
col 0 "Record:", cntr
bsize = size(trim(blobout))
col +2 bsize
row +1
while(cnt < bsize )
line = substring(cnt, 100,blobout)
col 25 line
row +1
cnt = cnt +100
endwhile
WITH MAXREC =
20, MAXCOL = 32000, NOHEADING, FORMAT = VARIABLE
END
GO
