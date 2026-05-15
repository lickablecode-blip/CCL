/*
 * Source page  : Recursive queries
 * Source file  : output/recursive-queries.md
 * Anchor       : Examples
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 61
 *
 * Context (preceding paragraph):
 *   The following example uses the recursive connection operator and the recursive control
 *   option to create a recursive query to return the menus and program items from the
 *   Explorer_Menu table that are below the Explorer Menu Audits folder.
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

select into
$outdev
 p.rlevel
 , p.item_type
 , p.item_name
 , p.menu_parent_id
 , p.menu_id
 
from
 (
 (select parent.menu_id
 ,parent.item_name
 ,parent.item_type
 ,parent.menu_parent_id
 ,rlevel = 1 ;level is an illegal column name so using
rlevel to indicate the recursive level
 from explorer_menu parent
 where
parent.menu_parent_id=0.0 ;under main
menu
 and parent.item_name =
"EXPLORER MENU AUDITS" 
 and parent.active_ind =
1
 union all
 ( select child.menu_id
 ,child.item_name
 ,child.item_type
 ,child.menu_parent_id
 ,rlevel =
parent.rlevel+1
 from recursiveparent parent
 ,explorer_menu child
 where child.menu_parent_id =
parent.menu_id
 and child.active_ind = 1
 ;using the recursive connection
operator
 recursive (select menu_id
 ,item_name
 ,item_type
 ,menu_parent_id
 ,rlevel from
recursiveparent)
 )
 ;using recursive control option
 with
sqltype("f8","c30","c1","f8","i4")
 ,recursive =
recursiveparent(menu_id
 ,item_name
 ,item_type
 ,menu_parent_id
 ,rlevel)
 ) p )
order by
 p.rlevel
 , p.item_type
 , p.item_name
 
with nocounter, separator=" ", format
