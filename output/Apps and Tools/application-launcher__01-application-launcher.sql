/*
 * Source page  : Application Launcher
 * Source file  : output/application-launcher.md
 * Anchor       : (top of page)
 * Block index  : 1 of 1
 * Detected lang: ccl
 * Lines        : 594
 *
 * Context (preceding paragraph):
 *   Exported: 11/25/25
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

/******************************************************************************
 REPORT NAME:
        Application Launcher
 PROGRAM:
 DEV
PROGRAM:        dev_rpt_app_launcher.prg
 DEVELOPER:        David Alt
(david.a.alt2.mil@health.mil)
 PUBLISHED:
 SNAPSHOT:
 LOGICAL
PATH:        cust_script:
 NODE:                        <default>
 PURPOSE/DESCRIPTION:
         Provides a workaround to
the AppBar limitation of not being able to launch
         java applications.
 TARGET AUDIENCE: Solution Owners/Support
MOD        DATE                DEVELOPER        COMMENT
         ---        --/--/--        ---------        ---------------------------
001        11/18/25        David
Alt        initial build
         ---- unpublished ----
         TODO:
                 make
it pretty
                 add
other roles?
******************************************************************************/
drop program
dev_rpt_app_launcher go
create
program dev_rpt_app_launcher
prompt
"Output to File/Printer/MINE" = "MINE" ;* Enter or select the printer or file name
to send this report to.
, "Role" = ""
, "Info" = ""
with OUTDEV,
role, info
/**************************************************************
; Global
Declarations
**************************************************************/
/**************************************************************
; Record
Structures
**************************************************************/
/**************************************************************
; Subroutines
**************************************************************/
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
/**************************************************************
; Main
**************************************************************/
/**************************************************************
; Output
**************************************************************/
SELECT
IF($role =
"Charge Services")
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
row+1 ^<h4>Charge Services</h4>^
row+1 ^<table border='1'>^
row+1 call print(app2("CSBatchChargeEntry.exe", "Batch
Charge Entry"))
row+1 call print(app2("CSCTManager.exe", "Charge
Transformation"))
row+1 call print(app2("CSChargeViewer.exe", "Charge
Viewer"))
row+1 call print(app2("CSMiscSetup.exe", "DB Misc
Setup"))
row+1 call print(app2("CSTierMaint.exe", "DB Tier
Options Maintenance"))
row+1 call print(app2("CSPriceInquiry.exe", "Price
Inquiry"))
row+1 call print(app2("CSPricingTool.exe", "Pricing
Tool"))
row+1 ^</table>^
row+1 ^</body></html>^
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
ELSEIF($role
= "Documentation")
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
;table - documentation
row+1 ^<h4>Documentation</h4>^
row+1
^<table>^
row+1 call print(app2("ContentManager.exe", "Content
Manager"))
row+1 call print(app2("CoreEventManager.exe", "Core
Event Manager (ESH)"))
row+1 call print(app2("DCPTools.exe", "DCP Tools"))
row+1 call print(app2("DiscernVisualDeveloper.exe",
"Discern Visual Developer"))
row+1 call print(app2("scdke.exe", "Knowledge
Editor"))
row+1 ^</table>^
row+1 ^</body>^
row+1 ^</html>^
ELSEIF($role
= "Patient Care Location")
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
;table - patient care location
row+1 ^<h4>Patient Care Location</h4>^
row+1
^<table>^
row+1 call print(app2("CoreCodeBuilder.exe", "Core Code
Builder"))
row+1 call print(app2("LocAlias.exe", "Location Alias
Maintenance"))
row+1 call print(app2("LocCombine.exe", "Location
Combine Tool"))
row+1 call print(app2("Location.exe", "Location Resource
Maintenance"))
row+1 ^</table>^
row+1 ^</body>^
row+1 ^</html>^
ELSEIF($role
= "Registration/Scheduling")
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
;table - registration and scheduling
row+1 ^<h4>Registration and Scheduling</h4>^
row+1 ^<table>^
row+1 call print(app2("CoreCodeBuilder.exe", "Core Code
Builder"))
row+1 call print(app2("PMDBConv.exe", "PM Conversation
Builder"))
row+1 call
print(app2("RevenueCycleMaintenance/RevenueCycleMaintenance.exe",
"Revenue Cycle Maintenance"))
row+1 call print(app2("SchReportExe.exe", "Schedule
Reports"))
row+1 call print(app2("SchApptBook.exe", "Scheduling
Appointment Book"))
row+1 call print(app2("SchTools.exe", "Scheduling
Database Tools"))
row+1 ^</table>^
row+1 ^</body>^
row+1 ^</html>^
ELSEIF($role
= "Support Folder")
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
;table - support folder
row+1 ^<h4><a href='javascript:APPLINK(0,
"explorer.exe", "c:\program files\cerner")'>Support
Folder</a></h4>^
row+1 ^<table>^
row+1 call print(app2("AppBar.exe", "AppBar"))
row+1 call print(app2("PMOffice.exe", "Access Management
Office"))
row+1 call print(app2("CSBatchChargeEntry.exe", "Batch
Charge Entry"))
row+1 call print(app2("Bedrock64/Bedrock64.exe",
"Bedrock"))
row+1 call print(app2("CSCTManager.exe", "Charge
Transformation"))
row+1 call print(app2("CSChargeViewer.exe", "Charge
Viewer"))
row+1 call print(app2("ContentManager.exe", "Content
Manager"))
row+1 call print(app2("CoreCodeBuilder.exe", "Core Code
Builder"))
row+1 call print(app2("CoreEventManager.exe", "Core
Event Manager (ESH)"))
row+1 call print(app2("CSMiscSetup.exe", "DB Misc
Setup"))
row+1 call print(app2("CSTierMaint.exe", "DB Tier
Options Maintenance"))
row+1 call print(app2("DCPTools.exe", "DCP Tools"))
row+1 call
print(app2("DiscernAdministrator/DiscernAdministrator.exe",
"Discern Administrator"))
row+1 call print(app2("Discern Analytics 2.0/DA2.exe",
"Discern Analytics 2.0"))
row+1 call print(app2("DiscernLaunch.exe", "Discern
Launch"))
row+1 call print(app2("Metadata Builder/Metadata
Builder.exe", "Discern Metadata Builder"))
row+1 call print(app2("DiscernReportingPortal.exe",
"Discern Reporting Portal"))
row+1 call print(app2("DiscernVisualDeveloper.exe",
"Discern Visual Developer"))
row+1 call print(app2("EEMTools.exe", "EEM Database
Tools"))
row+1 call print(app2("EEMProfile.exe", "EEM Profile
Builder"))
row+1 call print(app2("EksEscalation.exe", "EKS
Escalation"))
row+1 call print(app2("DiscernDev/DiscernDev.exe", "EKM
Developer"))
row+1 call print(app2("EventValidationTool.exe", "Event
Validation Tool"))
row+1 call print(app2("ExpertSysTool.exe", "Expert
System Tool"))
row+1 call print(app2("FirstNet.exe", "FirstNet"))
row+1 call print(app2("HNAUser.exe", "HNA User"))
row+1 call print(app2("scdke.exe", "Knowledge
Editor"))
row+1 call print(app2("LocAlias.exe", "Location Alias
Maintenance"))
row+1 call print(app2("LocCombine.exe", "Location
Combine Tool"))
row+1 call print(app2("Location.exe", "Location Resource
Maintenance"))
row+1 call print(app2("EquationBuild.exe", "PathNet DB
Equation Build"))
row+1 call print(app2("PMDBConv.exe", "PM Conversation
Builder"))
row+1 call print(app2("PMLaunch.exe", "PM Conversation
Launcher"))
row+1 call print(app2("PMLocAttrib.exe", "PM DB Location
Attribute Builder"))
row+1 call print(app2("PMLocHist.exe", "PM Visit History
Viewer"))
row+1 call print(app2("PowerChart.exe",
"PowerChart"))
row+1 call print(app2("PPRAuditEventManager.exe", "PPR
Audit Event Manager"))
row+1 call print(app2("PPRConsentStatusManager.exe",
"PPR Consent Status Manager"))
row+1 call print(app2("PPRFilterServiceMaintTool.exe",
"PPR Filter Service Maintenance"))
row+1 call print(app2("PPRPrivacyStatusMgr.exe", "PPR
Privacy Status Manager"))
row+1 call print(app2("PPRProviderLookup.exe", "PPR
Provider Lookup"))
row+1 call print(app2("PPRServResAccess.exe", "PPR
Service Resource Access"))
row+1 call print(app2("PrefMaint.exe", "Preference
Maintenance"))
row+1 call print(app2("PreferenceManager.exe",
"Preference Manager"))
row+1 call print(app2("CSPriceInquiry.exe", "Price
Inquiry"))
row+1 call print(app2("CSPricingTool.exe", "Pricing
Tool"))
row+1 call print(app2("PrivMaint.exe", "Privilege
Maintenance"))
row+1 call print(app2("RevenueCycle/RevenueCycle.exe",
"Revenue Cycle"))
row+1 call
print(app2("RevenueCycleMaintenance/RevenueCycleMaintenance.exe",
"Revenue Cycle Maintenance"))
row+1 call print(app2("SchReportExe.exe", "Schedule
Reports"))
row+1 call print(app2("SchApptBook.exe", "Scheduling
Appointment Book"))
row+1 call print(app2("SchTools.exe", "Scheduling
Database Tools"))
row+1 ^</table>^
row+1 ^</body>^
row+1 ^</html>^
ENDIF
INTO $OUTDEV
;failsafe
WITH
NOCOUNTER, SEPARATOR=" ", FORMAT, CHECK, TIME=60, MAXREC=30,
MAXCOL=1000
end
go
