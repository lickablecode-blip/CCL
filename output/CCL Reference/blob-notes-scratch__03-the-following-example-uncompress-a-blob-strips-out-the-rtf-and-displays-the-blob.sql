/*
 * Source page  : BLOB notes - scratch
 * Source file  : output/blob-notes-scratch.md
 * Anchor       : The following example uncompress a blob, strips out the rtf and displays the blob contents in ascii format. This example assumes the blob will be stored in a single row on the ce_blob. Blobs can be stored in multiple rows on the ce_blob table. See the Working with blobs on the ce_blob table section for an example that shows working with blobs that are stored in multiple rows.
 * Block index  : 3 of 11
 * Detected lang: sql
 * Lines        : 26
 *
 * Context (preceding paragraph):
 *   end
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

drop program
ccl_blob go
create
program ccl_blob
;execute
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
select
BlobIn =
trim(Cb.BLOB_CONTENTS),
textlen =
textlen(cb.blob_contents)
from
ce_blob cb
where
Cb.COMPRESSION_CD
= OcfCD
Head Report
