/*
 * Source page  : WITH clause (control options)
 * Source file  : output/with-clause-control-options.md
 * Anchor       : RECURSIVE
 * Block index  : 1 of 8
 * Detected lang: ccl
 * Lines        : 48
 *
 * Context (preceding paragraph):
 *   RECURSIVE is used in the WITH clause of a nested SELECT that uses the RECURSIVE
 *   connection operator to create hierarchical queries. Requires Oracle version 11.2 or
 *   later and Discern Explorer version 8.7.2 or later.
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

SELECT
p.rlevel
, p.da_folder_name
, p.parent_folder_id
, p.da_folder_id
FROM
 (
 (SELECT parent.da_folder_id
 ,parent.da_folder_name
 ,parent.parent_folder_id
 ,rlevel = 1 ;level is an illegal column name so using
rlevel to indicate the recursive level
 FROM da_folder parent
 WHERE parent.parent_folder_id=0.0 ;start with root folders
 AND parent.public_ind = 1
 ;and parent.item_name =
"EXPLORER MENU AUDITS"
 UNION ALL
 ( SELECT child.da_folder_id
 ,child.da_folder_name
 ,child.parent_folder_id
 ,rlevel = parent.rlevel+1
 FROM recursiveparent parent
 ,da_folder child
 WHERE child.parent_folder_id =
parent.da_folder_id
 AND child.public_ind = 1
 ;using the recursive connection
operator
 recursive (SELECT da_folder_id
 ,da_folder_name
 ,parent_folder_id
 ,rlevel FROM
recursiveparent)
 )
 ;using recursive control option
 WITH
sqltype("f8","c40","f8","i4")
 ,recursive =
recursiveparent(da_folder_id
 ,da_folder_name
 ,parent_folder_id
 ,rlevel)
 ) p )
ORDER BY
p.rlevel, p.da_folder_name
WITH
nocounter, separator=" ", format, time=30
