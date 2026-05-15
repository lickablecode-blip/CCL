/*
 * Source page  : BLOB notes - scratch
 * Source file  : output/blob-notes-scratch.md
 * Anchor       : The uar_rtf and uar_rtf2 routines can be used to strip the rtf formatting commands out of a blob. Care should be taken when stripping the rtf out of blobs to avoid unexpected results. For example if a blob had text that was displayed in a font that used strikethrough, and the rtf was removed, the strikethrough would be removed. This could dramatically affect the meaning of the text. The following example shows how to uncompress the blob, qualify on the blob, and strip out the rtf commands. This example assumes the blob will be stored in a single row on the ce_blob. Blobs can be stored in multiple rows on the ce_blob table. See the Working with blobs on the ce_blob table section for an example that shows working with blobs that are stored in multiple rows.
 * Block index  : 5 of 11
 * Detected lang: ccl
 * Lines        : 145
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
execute
cclseclogin
SET OcfCD =
0.0
Set stat =
uar_get_meaning_by_codeset(120,"OCFCOMP",1,OcfCD)
set BlobOut=
fillstring( 32768, ' ' )
set BlobNoRTF
= fillstring( 32768, ' ' )
set bsize = 0
SELECT
tlen =
textlen(c.blob_contents),
BlobIn =
trim(C.BLOB_CONTENTS)
FROM CE_BLOB
C, dummyt d
PLAN C WHERE
C.COMPRESSION_CD = OcfCD
join d where
UAR_OCF_UNCOMPRESS(c.blob_contents,size(c.blob_contents), /***textlen(c.blob_contents),
change for 64 bit environments***/
BLOBOUT,
SIZE( BLOBOUT ), 32768) >= 0
and blobout =
"*chest*"
;uar_ocf_uncompress
will set blobout equal
;to the
uncompressed blob
;
;the dummyt
table must be used to qualify
;on the
string value in the blob
;i.e.
"and blobout = "*chest*"
Head Report
;this routine
wraps text for display
%i
cclsource:CCL_text_WRAP.inc
cntr = 0
Detail
cnt = 1
cntr = cntr
+1
col 0
"Record:", cntr
;use uar_rtf2
to strip the rtf from the blob
stat =
uar_rtf2(blobout,size(blobout),
blobnortf,size(blobnortf),bsize,0)
col +1 call
ccl_text_wrap(col, 100, blobnortf)
row +1
WITH MAXREC =
20,
MAXCOL =
32000,
NOHEADING,
FORMAT =
VARIABLE
END
GO
blobtest go
/*
;The above
program calls the ccl_text_wrap subroutine.
;This
subroutine WILL NOT WORK with postscript reports.
;The
subroutine is created by including the
;cclsource:ccl_test_wrap.inc
file in the head reportsection of the
;select
command. This subroutine can be used in CCL programs to wrap
;textual
fields in reportwriter. The source code contained in the
;cclsource:ccl_test_wrap.inc
file is shown below.
;A better
method for wrapping the text in VE would be to use the print
;across
multiple lines option. To see this option place a field on the
;report
writer layout grid and then double click it. The print across
;multiple
lines option includes the cclsource:vcclrtf.inc file that is
;shipped with
VE and then calls the cclrtf_print subroutine to print the
;text on
multiple lines.
SUBROUTINE
CCL_text_wrap(X, Y, Z) ;name of the subroutine is
;CCL_TEXT_wrap
;The
parameters X, Y, and Z will be passed from the program when this
;subroutine
is called.
;X = column
where item is placed on report
;Y = the
length of the text string before it wraps
;Z = the
textual field that is being placed on the report
;initialize
variables
eol =
SIZE(TRIM(Z),1) ;finds total length of trimmed textual field
bseg = 1
eseg = 1
line =
SUBSTRING(bseg, eol, Z)
while(eseg
<= eol )<br /> bseg = eseg
eseg = eseg +
y
;if there is
a space in the segment, break on the space
if(findstring("
",substring(bseg,eseg-bseg,line))>0)
while(substring(eseg
-1,1,line)!=" " and eseg!=bseg)
eseg = eseg
-1
endwhile
segment =
substring(bseg,(eseg - bseg) -1, z)
else
segment =
substring(bseg,(eseg - bseg), z)
endif
col x call
print(substring(1,y,segment))
row +1
endwhile
END
*/
