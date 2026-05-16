/*
* Name:     MIG_RUN_APR
* Source:   Inbox/PathNet/MIG_RUN_APR.PRG
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    7
* Notes:
*/

DROP PROGRAM mig_run_apr:dba GO
CREATE PROGRAM mig_run_apr:dba

SET FILENAME = "CER_INSTALL:MIG_IMP_apr.DAT"
SET SCRIPTNAME = "MIG_IMP_apr"

EXECUTE DM_DBIMPORT FILENAME, SCRIPTNAME, 10000

END
GO
