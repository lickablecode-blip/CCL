/*
 * Source page  : HTML output
 * Source file  : output/html-output.md
 * Anchor       : Examples: subroutines for building HTML output
 * Block index  : 3 of 4
 * Detected lang: unknown
 * Lines        : 103
 *
 * Context (preceding paragraph):
 *   Both basic HTML and CSS are supported, although they need to be added inline or wrapped
 *   in the page's <style> tags instead of loading a separate file. Capabilities will vary
 *   based on the browser used in the Discern Output Viewer, which can be configured to use
 *   either IE or Edge. This is a global setting across all Discern reports. Images are
 *   theoretically supported but must be on the server (unsure if it needs to be on the
 *   server launching IE, or on the server/node running the CCL program).
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

;outputs the
input wrapped in <p></p> tags
subroutine
(html_p(input = vc) = vc)
declare output = vc
set output = BUILD("<p>", input,
"</p>")
return (output)
end
;outputs the
input followed by </br>
subroutine
(html_br(input = vc) = vc)
declare output = vc
set output = BUILD(input, "</br>")
return (output)
end
;outputs an
HTML link <a></a>
subroutine
(html_a(url=vc, label=vc) = vc)
declare output = vc
set output = BUILD(^<a href="^,
url,
^" _target="blank">^,
label,
^</a>^)
return (output)
end
;outputs a
link to a path in C:\Program Files\Cerner\
subroutine
(applink(path=vc, label=vc) = vc)
declare output = vc
set output =
CONCAT(^<a href='javascript:APPLINK(0, "^,
path,
^", "")'>^,
label,
^</a>^)
return (output)
end
;outputs an
html table row with 2 cells: link, path
subroutine
(app2(path=vc, label=vc) = vc)
declare output = vc
set output =
CONCAT(^<tr><td>^,
applink(path, label),
^</td><td>^,
path,
^</td></tr>^)
return (output)
end
;PowerChart
link
subroutine(chartlink(pid
= f8, eid = f8, label = vc) = vc)
declare output = vc with protect, noconstant("")
set output = BUILD(|<a href='javascript:APPLINK(0,
"Powerchart.exe", "/PERSONID=|
,pid
,| /ENCNTRID=|
,eid
,|")'>|
,label
,|</a>|
)
return (output)
end
;chartlink
subroutine(reportlink(rpt
= vc, prompts = vc, mode = i2, label = vc) = vc)
declare output = vc with protect, noconstant("")
set output = BUILD(|<a href='javascript:CCLLINK("|
,rpt
,|","|
,prompts
,|",|
,mode
,|)'>|
,label
,|</a>|
)
return (output)
end
;reportlink
subroutine(applink(url
= vc, label = vc) = vc)
declare output = vc with protect, noconstant("")
set output = BUILD(^<tr><td><a
href='javascript:APPLINK(0,^
,^"^
,url
,^", "")^
,label
,^</a></td><td>^
,url
,^</td></tr>^
)
return (output)
end ;applink
