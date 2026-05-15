/*
 * Source page  : Format
 * Source file  : output/format.md
 * Anchor       : Display Qualifiers (to remove trailing zeros)
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 12
 *
 * Context (preceding paragraph):
 *   [https://wiki.cerner.com/display/public/1101discernHP/Display+Qualifier+Using+Discern+E
 *   xplorer](https://wiki.cerner.com/display/public/1101discernHP/Display+Qualifier+Using+D
 *   iscern+Explorer)
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

call
echo(format(1.0,"###.##;t(1)")) go
 1
call
echo(format(1.0,"###.##;t(2)")) go
 1.0

call echo(format(1.10,"###.##;t(1)")) go
 1.1
call
echo(format(1.10,"###.##;t(2)")) go
1.1
