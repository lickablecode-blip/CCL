/*
 * Source page  : BLOB notes - scratch
 * Source file  : output/blob-notes-scratch.md
 * Anchor       : If the blob is uncompressed you can qualify on it by joining to the dummyt table.
 * Block index  : 7 of 11
 * Detected lang: ccl
 * Lines        : 33
 *
 * Context (preceding paragraph):
 *   end
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

DROP PROGRAM
ve_blobtest GO
CREATE
PROGRAM ve_blobtest
SELECT
BlobOut = trim( C.BLOB_CONTENTS )
FROM CE_BLOB
C, dummyt d
PLAN C
Join d where
check(c.blob_contents) = "*chest*"
Head Report
BlobOut= fillstring( 32768, ' ' )
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
ve_blobtest
GO
