/*
 * Source page  : BLOB notes - scratch
 * Source file  : output/blob-notes-scratch.md
 * Anchor       : The following example checks to see if a blob is compressed. If the blob is compressed it is uncompressed and the rtf is stripped out. If the blob is not compressed it is used as is.
 * Block index  : 2 of 11
 * Detected lang: ccl
 * Lines        : 89
 *
 * Context (preceding paragraph):
 *   end
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

DROP PROGRAM
1_test_long_blob GO
CREATE
PROGRAM 1_test_long_blob
PROMPT
"Output to File/Printer/MINE" = MINE
WITH OUTDEV
declare
OCFCOMP_VAR = f8 with
Constant(uar_get_code_by("MEANING",120,"OCFCOMP")),protect
declare
NOCOMP_VAR = f8 with
Constant(uar_get_code_by("MEANING",120,"NOCOMP")),protect
declare
BlobOut = vc
declare
BlobNoRTF = vc
declare bsize
= i4
SELECT INTO
$OUTDEV
C.CE_EVENT_NOTE_ID,
C.COMPRESSION_CD,
C_COMPRESSION_DISP
= UAR_GET_CODE_DISPLAY( C.COMPRESSION_CD ),
L.LONG_BLOB,
L.PARENT_ENTITY_NAME,
lenblob =
size( L.LONG_BLOB )
FROM
CE_EVENT_NOTE
C,
LONG_BLOB L
Plan c where
C.COMPRESSION_CD IN (NOCOMP_VAR, OCFCOMP_VAR)
JOIN l where
C.CE_EVENT_NOTE_ID = L.PARENT_ENTITY_ID AND
L.PARENT_ENTITY_NAME
= "CE_EVENT_NOTE"
Head Report
m_NumLines =
0
%I
cclsource:vcclrtf.inc
Detail
if ((ROW + 3)
>= maxrow) break endif
blobout =
notrim(fillstring(32768," "))
blobnortf =
notrim(fillstring(32768," "))
if(c.compression_cd
= ocfcomp_var)
;use a variable to get the actual uncompressed size
uncompsize = 0
;use uar_ocf_uncompress to uncompress the blob
;the uncompressed blob is assigned to the variable blobout
blob_un = UAR_OCF_UNCOMPRESS
(l.long_blob, size( L.LONG_BLOB ), ;;; lenblob, change for 64bit
(2018) domains
BLOBOUT, SIZE( BLOBOUT ), uncompsize)
;In 64bit environments using the select expression lenblob in the above
uar_ocf_uncompress call
;can cause programs to crash. Changing it to use the Size() function
seems to prevent the crash.
;use uar_rtf2 to strip the rtf from the blob
stat = uar_rtf2(blobout,uncompsize,
blobnortf,size(blobnortf),bsize,0)
;set blobnortf to actual size
blobnortf = substring(1,bsize,blobnortf)
else
blobnortf = l.long_blob
endif
COL 5
C.CE_EVENT_NOTE_ID
COL 29
C_COMPRESSION_DISP
COL 83
L.PARENT_ENTITY_NAME
ROW + 1
;use the
print on multiple lines option in VE to wrap the blob.
CALL
cclrtf_print( 0, 13, 80, blobnortf, size(blobnortf), 1 )
ROW + 1
WITH MAXREC =
100, NOHEADING, FORMAT= VARIABLE
END
GO
