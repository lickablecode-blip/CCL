/*
 * Source page  : HTML output
 * Source file  : output/html-output.md
 * Anchor       : Example: outputting a query to HTML table (simple query)
 * Block index  : 4 of 4
 * Detected lang: ccl
 * Lines        : 79
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

SELECT INTO
$OUTDEV
fin = fin.alias
,reg_dt_tm = FORMAT(e.reg_dt_tm, "MM/DD/YYYY HH:MM;;q")
,e.encntr_id
FROM
ENCOUNTER e
,ENCNTR_ALIAS fin
PLAN e WHERE
e.reg_dt_tm > SYSDATE-3
AND e.active_ind = 1
JOIN fin
WHERE fin.encntr_id = e.encntr_id
AND fin.encntr_alias_type_cd = 1077 ;FIN
AND fin.end_effective_dt_tm > SYSDATE
AND fin.active_ind = 1
ORDER BY
e.reg_dt_tm
HEAD
REPORT ;everything
in HEAD REPORT runs once
i=0
row+1 "<html>"
row+1 "<head>"
row+1 "<meta content='CCLLINK' name='discern'>"
row+1        "<title>Testing
HTML and chart interactivity</title>"
row+1        "<style>"
row+1                "html,
body, table { font: normal 0.9em/1.5em Arial, Helvetica, sans-serif; }"
row+1                "table
{ border-collapse: collapse; }"
row+1                "th,
td { padding-left: 5px; padding-right: 5px; }"
row+1        "</style>"
row+1 "</head>"
row+1 "<body>"
row+1 "<p>Testing HTML and chart
interactivity</p>"
;table & header
row+1 "<table border='1'>"
row+1 "<tr>"
row+1        "<th>&nbsp;</th>"
row+1
        "<th>FIN</th>"
row+1
        "<th>Registration</th>"
row+1        "<th>encntr_id</th>"
row+1 "</tr>"
DETAIL ;DETAIL runs once per query result
i+=1
row+1 "<tr>"
row+1        call
print(build("<td>", i, "</td>"))
row+1        call
print(build(|<td><a href='javascript:APPLINK(0,
"Powerchart.exe", "/PERSONID=|
,e.person_id
,| /ENCNTRID=|
,e.encntr_id
,|")'>|
,fin.alias
,|</a></td>|
)
)
row+1        call
print(build("<td>", reg_dt_tm, "</td>"))
row+1        call
print(build("<td>", e.encntr_id, "</td>"))
row+1 "</tr>"
FOOT REPORT ;FOOT REPORT runs once after processing all query
rows
row+1 "</table>"
row+1 "</body>"
row+1
"</html>"
WITH
NOCOUNTER, SEPARATOR=" ", FORMAT, CHECK, TIME=60, MAXREC=30,
MAXCOL=1000
