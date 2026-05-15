/*
 * Source page  : Unknown Queue and Scheduling List
 * Source file  : output/unknown-queue-and-scheduling-list.md
 * Anchor       : Discern Report
 * Block index  : 3 of 8
 * Detected lang: ccl
 * Lines        : 35
 *
 * Context (preceding paragraph):
 *   Here's a basic example of how to connect those in a query to review orders with a
 *   related "Order - Schedulable" Flex:
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

select
Catalog_Type=uar_get_code_display(oc.catalog_type_cd)
,
Order_Primary_Mnemonic=oc.primary_mnemonic
, Sch_Order =
if (oc.schedule_ind=1) "YES" elseif (oc.schedule_ind=0)
"NO" endif
,
Active_Order = if (oc.active_ind=1) "YES" elseif (oc.active_ind=0)
"NO" endif
,
Order_Schedulable_Flex= sf.mnemonic
from
order_catalog oc
,
sch_simple_assoc ssa
,
sch_flex_string sf
plan oc
where
oc.schedule_ind=1
and
oc.active_ind=1
join ssa
where
ssa.parent_id=outerjoin(oc.catalog_cd)
and
ssa.active_ind=outerjoin(1)
join sf
where
sf.sch_flex_id=(ssa.child_id)
and
sf.active_ind=(1)
order by
catalog_type, order_primary_mnemonic
