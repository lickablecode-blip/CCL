/*
 * Source page  : HTML output
 * Source file  : output/html-output.md
 * Anchor       : Example: showing application links in an HTML table
 * Block index  : 1 of 4
 * Detected lang: ccl
 * Lines        : 91
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

ELSEIF($role
= "Discern Developer")
FROM DUMMYT d
DETAIL
;metadata
row+1 ^<html><head><meta content='CCLLINK'
name='discern'>^
row+1 ^<title>Application Links</title>^
row+1 ^<style>^
row+1        ^html, body, table
{ font: normal 0.9em/1.5em Arial, Helvetica, sans-serif; }^
row+1        ^table { border:
1px #EEE; border-collapse: collapse; margin-left: 10px;}^
row+1        ^th, td {
background: #EEE; border: 1px solid #878787; padding-left: 5px; padding-right:
5px; }^
row+1        ^a { color:
#24469C; }^
row+1 ^</style>^
row+1 ^</head>^
row+1 ^<body>^
;table - common services
row+1 ^<h4>Common Services</h4>^
row+1 ^<table>^
row+1 ^<tr>^
^<td><a href='javascript:APPLINK(0, "AppBar.exe",
"")'>AppBar</a></td>^
^<td><a href='javascript:APPLINK(0,
"PowerChart.exe", "")'>PowerChart</a></td>^
^<td><a href="https://access.mhsgenesis.health.mil/"
target="_blank">PROD</a></td>^
 ^</tr>^
row+1 ^<tr>^
^<td><a href='javascript:APPLINK(0,
"Bedrock64/Bedrock64.exe",
"")'>Bedrock</a></td>^
^<td><a href='javascript:APPLINK(0, "FirstNet.exe",
"")'>FirstNet</a></td>^
^<td><a
href="https://accesscert.mhsgenesis.health.mil/"
target="_blank">PRE-PROD</a></td>^
 ^</tr>^
row+1 ^<tr>^
^<td><a href='javascript:APPLINK(0, "explorer.exe",
"c:\program files\cerner")'>Support Folder</a></td>^
^<td><a href='javascript:APPLINK(0,
"RevenueCycle/RevenueCycle.exe",
"")'>RevCycle</a></td>^
^<td><a
href="https://access2cert.mhsgenesis.health.mil/"
target="_blank">B1930</a></td>^
 ^</tr>^
row+1 ^</table>^
;table - reports
row+1 ^<h4>Report Developer</h4>^
row+1 ^<table>^
row+1 call
print(app2("DiscernAdministrator/DiscernAdministrator.exe",
"Discern Administrator"))
row+1 call print(app2("Discern Analytics 2.0/DA2.exe",
"Discern Analytics 2.0"))
row+1 call print(app2("Metadata Builder/Metadata
Builder.exe", "Discern Metadata Builder"))
row+1 call print(app2("DiscernReportingPortal.exe",
"Discern Reporting Portal"))
row+1 call print(app2("DiscernVisualDeveloper.exe",
"Discern Visual Developer"))
row+1
^<tr><td>&nbsp;</td><td></td></tr>^
;spacer row
row+1 call print(app2("CoreCodeBuilder.exe", "Core Code
Builder"))
row+1 call print(app2("CoreEventManager.exe", "Core
Event Manager (ESH)"))
row+1 call print(app2("EventValidationTool.exe", "Event
Validation Tool"))
row+1 ^</table>^
;table - rules and alerts
row+1 ^<h4>Rules and Alerts</h4>^
row+1 ^<table>^
row+1 call print(app2("DiscernLaunch.exe", "Discern
Launch"))
row+1 call print(app2("EksEscalation.exe", "EKS
Escalation"))
row+1 call print(app2("DiscernDev/DiscernDev.exe", "EKM
Developer"))
row+1 call print(app2("ExpertSysTool.exe", "Expert
System Tool"))
row+1 ^</table>^
row+1 ^</body>^
row+1 ^</html>^
