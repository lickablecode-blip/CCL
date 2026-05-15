/*
 * Source page  : BLOB notes - scratch
 * Source file  : output/blob-notes-scratch.md
 * Anchor       : The above example is just reading the CE_BLOB table. A real program would likely also read the CLINICAL_EVENT table and join the CE_BLOB table. If you add the CLINICAL_EVENT table to the above example it is critical that the result set does not contain duplicates of the rows from the CE_BLOB table. Most likely you will need the following qualifications on the CLINICAL_EVENT table to prevent getting duplicate rows from the CE_BLOB table:
 * Block index  : 10 of 11
 * Detected lang: ccl
 * Lines        : 4
 *
 * Context (preceding paragraph):
 *   end
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

and
ce.VALID_FROM_DT_TM < cnvtdatetime(curdate,curtime3)
and
ce.VALID_UNTIL_DT_TM > cnvtdatetime(curdate,curtime3)
