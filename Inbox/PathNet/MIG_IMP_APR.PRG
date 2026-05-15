/*~BB~************************************************************************
      *                                                                      *
      *  Copyright Notice:  (c) 1983 Laboratory Information Systems &        *
      *                              Technology, Inc.                        *
      *       Revision      (c) 1984-2003 Cerner Corporation                 *
      *                                                                      *
      *  Cerner (R) Proprietary Rights Notice:  All rights reserved.         *
      *  This material contains the valuable properties and trade secrets of *
      *  Cerner Corporation of Kansas City, Missouri, United States of       *
      *  America (Cerner), embodying substantial creative efforts and        *
      *  confidential information, ideas and expressions, no part of which   *
      *  may be reproduced or transmitted in any form or by any means, or    *
      *  retained in any storage or retrieval system without the express     *
      *  written permission of Cerner.                                       *
      *                                                                      *
      *  Cerner is a registered mark of Cerner Corporation.                  *
      *                                                                      *
  ~BE~***********************************************************************/

/*****************************************************************************
        Author:                 LH2074
        Date Written:           05/09/2005
        Source file name:       mig_imp_apr.prg
        Object name:            mig_imp_apr
        Request #:

        Product:                MIGRATIONS
        Product Team:           MIGRATIONS
        HNA Version:            306
        CCL Version:            3.1 B00

        Program purpose:        Import Display Sequence for Assays
        Tables read:            Assay_processing_r
        Tables updated:         Assay_processing_r
        Executing from:

        Special Notes:          ?

******************************************************************************/


;~DB~************************************************************************
;    *                      GENERATED MODIFICATION CONTROL LOG              *
;    ************************************************************************
;    *                                                                      *
;    *Mod Date     Engineer             Comment                             *
;    *--- -------- -------------------- ----------------------------------- *
;     000 05/09/05 LH2074               Initial Release                     *
;~DE~************************************************************************


;~END~ ******************  END OF ALL MODCONTROL BLOCKS  ********************

drop program mig_imp_apr:dba go    
create program mig_imp_apr:dba
     
/********************************************************************/
/*  Requestin (INPUT) Record                                        */
/********************************************************************/
/*
      record requestin
      (                                       
         1 list_0 [*]
                2  service_resource_cd  = f8
                2  service_resource     = vc
                2  assay_cd             = f8
                2  Assay_mnemonic       = vc
                2  sequence             = i4  ; _ind
      )
*/
/********************************************************************/
/*  Request (OUTPUT) Record                                         */
/********************************************************************/

free record imprequest         
record imprequest            
( 1 qual[1]
    2 service_resource_cd        = f8
    2 task_assay_cd              = f8
    2 active_ind                 = i2
    2 default_result_type_cd     = f8
    2 default_result_template_id = f8
    2 qc_result_type_cd          = f8
    2 qc_sequence                = i4
    2 display_sequence           = i4
    2 downld_ind                 = i2
    2 code_set                   = i4
)

record reqinfo
( 1 commit_ind  = i2
  1 updt_id     = f8
;  1 position_cd = f8
;  1 updt_app    = i4
  1 updt_task   = i4
;  1 updt_req    = i4
  1 updt_applctx= i4
)

/********************************************************************/
/*  Reply (returned) Record                                         */
/********************************************************************/

record impreply          ;reply structure from orc_add_assay_processing_r
(
%i cclsource:status_block.inc
)

set reqinfo->updt_id = 0                                            
set reqinfo->updt_task = 1                                          
set reqinfo->commit_ind = 1                                         
set reqinfo->updt_applctx = 1                                       
set total_rec = 0
set valid_rec = 0
set saved_echo = curecho
set curecho = 0 ; 0=show all, 2=data, 5=trace ,9=normal msgs, 99=nothing
/*******************************************************************/
/*  start the log file                                             */
/*******************************************************************/

set logvar = 0
set dir_name    = logical("miglog")
if (dir_name    = " ")
   set log_name = "ccluserdir:mig_imp_apr.log"
else
   set log_name = "miglog:mig_imp_apr.log"
endif

call echo(build('Opening logfile - "',log_name,'".'),1,5)
select into value(log_name)
    logvar
head report
    curdate "dd-mmm-yyyy;;d","-",curtime "hh:mm;;m",
    col + 1, "Assay Display Sequence Import Log"
detail
    row + 1, "     Service Resource         DTA               SEQUENCE    STATUS"
with nocounter, format=variable, noformfeed, maxcol = 240, maxrow = 1,
     append    
call echo("started log file",1,9)

/*****************************************************************************/
/*   Read requestin and fill in Request Structure                         */
/*****************************************************************************/
set invalid_sw = 0
set loopvarin = 1
set numrows = size(requestin->list_0, 5)

while (loopvarin <= numrows)
if (requestin->list_0[loopvarin].assay_mnemonic > ""
and requestin->list_0[loopvarin].service_resource > "")
set def_res_typ = 0.0
select into "nl:"
from assay_processing_r apr
where apr.task_assay_cd = cnvtreal(requestin->list_0[loopvarin].assay_cd)
  and apr.service_resource_cd = cnvtreal(requestin->list_0[loopvarin].service_resource_cd)
  and apr.active_ind = 1
detail
  def_res_typ = apr.DEFAULT_RESULT_TYPE_CD
with nocounter
endif
if ( curqual > 0
and requestin->list_0[loopvarin].assay_mnemonic > ""
and requestin->list_0[loopvarin].service_resource > "")
     set imprequest->qual[1]->task_assay_cd =
                     cnvtreal(requestin->list_0[loopvarin].assay_cd)
     set imprequest->qual[1]->service_resource_cd =
                     cnvtreal(requestin->list_0[loopvarin].service_resource_cd)
     set imprequest->qual[1]->display_sequence = 
                     cnvtint(requestin->list_0[loopvarin].sequence)
          set imprequest->qual[1]->active_ind = 1
           set imprequest->qual[1]->default_result_type_cd   = def_res_typ
     execute orc_add_assay_processing_r with replace ("REQUEST", imprequest),
                                             replace ("REPLY", impreply)
 
    if(impreply->status_data->status = "S")
         call logsuccess(loopvarin)
    else
         call logfailure(loopvarin)
    endif
    set loopvarin = loopvarin + 1
else
    set loopvarin = loopvarin + 1
endif

endwhile

call logtotal(valid_rec)

go to enditnow
 
/*****************************************************************************/
/* Log Success                                                               */
/*****************************************************************************/
subroutine logsuccess(logvar)  
select into concat(trim(dir_name),"mig_imp_apr.log")
   logvar
head report
   row + 1
detail
   col  6, requestin->list_0[logvar].service_resource,
   col 30, requestin->list_0[logvar].assay_mnemonic,
   col 50, requestin->list_0[logvar].sequence,
   col 60, "ADDED",
   total_rec = total_rec + 1,
   valid_rec = valid_rec + 1
with nocounter, append, format=variable, noformfeed, maxcol=132, maxrow=1
end

/*****************************************************************************/
/* Log Failure                                                               */
/*****************************************************************************/
subroutine logfailure(logvar)  
select into concat(trim(dir_name),"mig_imp_apr.log")
logvar
head report
   row + 1
detail
   col  6, requestin->list_0[logvar].service_resource,
   col 30, requestin->list_0[logvar].assay_mnemonic,
   col 50, requestin->list_0[logvar].sequence,
   col 60, "NOT ADDED",
   total_rec = total_rec + 1

with nocounter, append, format=variable, noformfeed, maxcol=132, maxrow=1
end

/*****************************************************************************/
/* Log Total                                                                 */
/*****************************************************************************/
subroutine logtotal(logvar)  
select into concat(trim(dir_name),"mig_imp_apr.log")
   logvar
head report
   row + 1
detail
   col 0, "Total Processed: ", total_rec "####;p0",
   row+1,
   col 0, "Total Added: ", logvar "####;p0"
 

with nocounter, append, format=variable, noformfeed, maxcol=132, maxrow=1
end


#enditnow         
commit

end
go      

