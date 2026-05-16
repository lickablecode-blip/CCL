/*
* Name:     Virtual views per order sentence
* Source:   Inbox/PathNet/Virtual views per order sentence.txt
* Purpose:
* Imported: 2026-05-15
* Category: PathNet  (reason: subfolder)
* Lines:    14
* Notes:
*/

Here's a quick query I put together a while back that pulls all sentences and their virtual view settings, is this what you're looking for?

 
You'll have to make sure that the filter_type_cd code value is correct for sentences for your site, you can check on code set 30620.  I also have a DVDev program that will split out the virtual view facilities into seperate columns instead of repeated lines like this query returns (it's better for filtering the results), but that would take a decent amount of customization to get it to work for a different site.  Let me know if you'd like to have it though.

 
 
 
select ocsr.order_sentence_id, ocsr.catalog_cd, ocsr.synonym_id,

ORDERABLE = substring(1,25,ocs.mnemonic),

SENTENCE = substring(1,40,ocsr.order_sentence_disp_line),

fer.filter_entity1_id, FACILITY = substring(1,30,cv.display)

from filter_entity_reltn fer, ord_cat_sent_r ocsr, order_catalog_synonym ocs,

code_value cv

plan fer where fer.filter_type_cd=4047152 ; replace with code value for order sentence from code set 30620

join ocsr where ocsr.order_sentence_id = fer.parent_entity_id

join ocs where ocs.synonym_id = ocsr.synonym_id

join cv where cv.code_value = fer.filter_entity1_id

order by ocs.synonym_id, ocsr.order_sentence_disp_line, cv.display

go
