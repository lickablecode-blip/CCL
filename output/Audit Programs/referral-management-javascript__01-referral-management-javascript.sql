/*
 * Source page  : Referral Management (javascript)
 * Source file  : output/referral-management-javascript.md
 * Anchor       : (top of page)
 * Block index  : 1 of 1
 * Detected lang: sql
 * Lines        : 441
 *
 * Context (preceding paragraph):
 *   Exported from dev_rpt_referral_master.prg on 1/8/26. This is an older version that is
 *   no longer updated, but contains all the critical prompt manipulation logic for working
 *   with listbox events.
 *
 * Exported by export_scripts.py from Development-Shared.mht
 */

var theForm =
null;
// Define an
object to hold the constants for PmSearch
var PMSearch
= {
 SearchDlg:"PMSearch.SearchTask",
 //PMSearch Mode
 pmPersonMode : 1,
 pmPatientMode : 2,
 pmEncounterMode : 3,
 //Return Person Info
 pmReturnIDOnlyPerson : 0,
 pmReturnAllPerson : 1,
 pmReturnNeverPerson : 2,
 //Return EncounterInfo
 pmReturnIDOnlyEncounter : 0,
 pmReturnAllEncounter : 1,
 pmReturnNeverEcounter : 2
};
function
onLoad() {
 theForm = new DiscernForm();
 theForm.OUTDEV.visible = false;
 // disable read-only controls
 theForm.info.enabled = false;
 theForm.info.value = "Select a report
from the list on the left.";
 // hide all filters
 hideFilters();
 hidePersonFilters();
 // insert event handlers
 theForm.rpt.onChange = changeRpt; //fires
when report selection changes
 theForm.btnSearch.onClick = onSearch;
 theForm.btnClear.onClick = onClear;
 theForm.person_id.onChange =
changePersonID; //needed to workaround PMSearch bug on second search
}
function
changeRpt(sender) {
 showReportFilters(theForm.rpt.value);; //set appropriate filters
}
function
changePersonID(sender) {
 showPatientFilters();
 showReferralFilters();
}
function
showReportFilters(rpt){
 hideFilters();
 switch(rpt) {
 //LOCATION/SPECIALTY REPORTS
 case " All Referrals":
 theForm.info.value = "Detail
list of referrals by location, specialty, and status";
 hidePersonFilters();
 showLocationFilters();
 showStatusFilters();
 showDateFilters();
 break;
 case " Open Referrals":
 theForm.info.value =
"Referrals in any status other than Completed, Closed, or Canceled";
 hidePersonFilters();
 showLocationFilters();
 showDateFilters();
 break;
 case " Pending Close Referrals":
 theForm.info.value = "Patients
that have been seen for the referral";
 hidePersonFilters();
 showLocationFilters();
 showDateFilters();
 break;
 /*Removed
 case " Pending Close Referrals to Community Care
(VA)":
 theForm.info.value = "Patients
scheduled or seen at a Community Care location";
 hidePersonFilters();
 //theForm.refer_from_agency.visible
= true;
 theForm.from_method.visible = true;
 theForm.from_search.visible = true;
 theForm.refer_from_org.visible =
true;
 theForm.service_type.visible =
true;
 showDateFilters();
 break;*/
 case " Closed Referrals":
 theForm.info.value =
"Referrals in Completed, Closed, or Canceled status";
 hidePersonFilters();
 showLocationFilters();
 showDateFilters();
 theForm.ref_stat.visible = true;
 break;
 case " Closing-the-Loop - Direct Care
(DOD)":
 theForm.info.value = "Internal
Referrals in Patient Seen or Completed status. Designed for DOD
workflows.";
 hidePersonFilters();
 showLocationFilters();
 showDateFilters();
 break;
 case " Closing-the-Loop - Purchased Care
(DOD)":
 theForm.info.value = "External
Referrals in Patient Seen, Completed, Sent, or Closed status. Designed for DOD
workflows.";
 hidePersonFilters();
 showLocationFilters();
 showDateFilters();
 break;
 case " Late Booking Referrals":
 theForm.info.value =
"Referrals in Accepted or On Hold status.";
 hidePersonFilters();
 showLocationFilters();
 showDateFilters();
 break;
 case " Late Rejected Referrals":
 theForm.info.value =
"Referrals in Rejected and Send Failure status with an Updated Date/Time
older than 1 day";
 hidePersonFilters();
 showLocationFilters();
 showDateFilters();
 break;
 case " Late Reviewed Referrals":
 theForm.info.value =
"Referrals in Pending Acceptance status with a Sent Date/Time older than 1
day";
 hidePersonFilters();
 showLocationFilters();
 showDateFilters();
 break;
 case " Late Unreviewed Referrals":
 theForm.info.value =
"Referrals in Not Started or Prepare Send status with a Written Date/Time
older than 1 day";
 hidePersonFilters();
 showLocationFilters();
 showDateFilters();
 break;
 case " Lost Deferred Referrals (DOD)":
 theForm.info.value =
"Referrals with a Defer To location but not in Sent, Received, Send
Failure, Certified, Rejected, or Closed status. Designed for DOD workflows.";
 hidePersonFilters();
 //theForm.refer_from_agency.visible
= true;
 theForm.from_method.visible = true;
 theForm.from_search.visible = true;
 theForm.refer_from_org.visible =
true;
 theForm.service_type.visible =
true;
 theForm.refer_to_service.visible =
true;
 showDateFilters();
 break;
 case " Potential Misrouted Referrals (VA)":
 theForm.info.value =
"Referrals from a VA facility without a valid refer to location, in
Accepted, Pending Acceptance, Not Started, Prepare Send, or Pending Reschedule
status. Designed for VA workflows.";
 hidePersonFilters();
 //theForm.refer_from_agency.visible
= true;
 theForm.from_method.visible = true;
 theForm.from_search.visible = true;
 theForm.refer_from_org.visible =
true;
 theForm.service_type.visible =
true;
 showDateFilters();
 break;
 /*Removed
 case " Summary Metrics by Medical Service":
 theForm.info.value = "Provides
counts of referrals by referred medical service";
 hidePersonFilters();
 //theForm.refer_from_agency.visible
= true;
 theForm.from_method.visible = true;
 theForm.from_search.visible = true;
 theForm.refer_from_org.visible =
true;
 theForm.refer_to_service.visible =
true;
 theForm.status.visible = true;
 showDateFilters();
 break;
 case " Summary Metrics by Practice Site":
 theForm.info.value = "Provides
counts of referrals by referred practice site";
 hidePersonFilters();
 //theForm.refer_from_agency.visible
= true;
 theForm.from_method.visible = true;
 theForm.from_search.visible = true;
 theForm.refer_from_org.visible =
true;
 theForm.refer_to_site.visible =
true;
 theForm.status.visible = true;
 showDateFilters();
 break;
 case " Summary Metrics by Referral Type":
 theForm.info.value = "Provides
counts of referrals by referral type";
 hidePersonFilters();
 //theForm.refer_from_agency.visible
= true;
 theForm.from_method.visible = true;
 theForm.from_search.visible = true;
 theForm.refer_from_org.visible =
true;
 theForm.service_type.visible =
true;
 theForm.status.visible = true;
 showDateFilters();
 break;
 case " Wrong Encounter Types":
 theForm.info.value =
"Referrals that were placed on History or Lifetime Pharmacy
encounters";
 hidePersonFilters();
 showLocationFilters();
 showStatusFilters();
 showDateFilters();
 break;*/
 //PROVIDER REPORTS
 case " Referrals by Provider (summary)":
 theForm.info.value = "Provides
counts of referrals placed by the provider in the specified date range, grouped
by medical specialty and refer to location";
 hidePersonFilters();
 showProviderFilters();
 showStatusFilters();
 showDateFilters();
 break;
 case " Referrals by Provider (detail)":
 theForm.info.value = "Provides
a detail list of all referrals placed by the provider in the specified date
range";
 hidePersonFilters();
 showProviderFilters();
 showStatusFilters();
 showDateFilters();
 break;
 //PATIENT REPORTS
 /*Removed
 case " Patient Summary":
 theForm.info.value = "Provides
demographics and contact information for the patient, similar to the Referral
Management application";
 if(theForm.person_id.value == 0)
hidePersonFilters();
 else {
 showPatientFilters();
 showReferralFilters();
 }
 showPatientSearch();
 break;
 case " All Patient Referrals":
 theForm.info.value = "Provides
a list of all referrals for the patient in the specified status and date
range";
 if(theForm.person_id.value == 0)
hidePersonFilters();
 else {
 showPatientFilters();
 }
 showPatientSearch();
 showStatusFilters();
 showDateFilters();
 break;
 //INDIVIDUAL REFERRAL REPORTS
 case " Referral Summary":
 theForm.info.value = "Provides
a detailed summary for the selected referral";
 if(theForm.person_id.value == 0)
hidePersonFilters();
 else {
 showPatientFilters();
 showReferralFilters();
 }
 showPatientSearch();
 break;
 case " Referral Actions":
 theForm.info.value = "Lists
actions and action comments for the selected referral";
 if(theForm.person_id.value == 0)
hidePersonFilters();
 else {
 showPatientFilters();
 showReferralFilters();
 }
 showPatientSearch();
 break;*/
 case " Referral Comments":
 theForm.info.value = "Lists
referral-level comments for the selected referral";
 if(theForm.person_id.value == 0)
hidePersonFilters();
 else {
 showPatientFilters();
 showReferralFilters();
 }
 showPatientSearch();
 break;
 /*Removed
 case " Referral History":
 theForm.info.value = "Lists
the history of changes to the referral (very similar to referral
actions)";
 if(theForm.person_id.value == 0)
hidePersonFilters();
 else {
 showPatientFilters();
 showReferralFilters();
 }
 showPatientSearch();
 break;
 case " Associated Appointments and
Encounters":
 theForm.info.value =
"Information about appointments and encounters associated with the
selected referral";
 if(theForm.person_id.value == 0)
hidePersonFilters();
 else {
 showPatientFilters();
 showReferralFilters();
 }
 showPatientSearch();
 break;*/
 //In case all else fails, this will run
 default: //set to blank
 theForm.info.value = "No
report selected";
 }
}
function
hideFilters() {
 //theForm.refer_from_agency.visible =
false;
 theForm.from_method.visible = false;
 theForm.from_search.visible = false;
 theForm.refer_from_org.visible = false;
 theForm.service_type.visible = false;
 theForm.refer_to_agency.visible = false;
 theForm.refer_to_site.visible = false;
 theForm.refer_to_service.visible = false;
 theForm.status.visible = false;
 theForm.substatus.visible = false;
 theForm.start_date.visible = false;
 theForm.end_date.visible = false;
 theForm.search.visible = false;
 theForm.prsnl.visible = false;
 theForm.btnSearch.visible = false;
 theForm.btnClear.visible = false;
 theForm.person_id.visible = false;
 theForm.ref_stat.visible = false;
}
function
hidePersonFilters() {
 theForm.person_info.visible = false;
 theForm.ref_list.visible = false;
}
function
showLocationFilters() {
 //theForm.refer_from_agency.visible = true;
 theForm.from_method.visible = true;
 theForm.from_search.visible = true;
 theForm.refer_from_org.visible = true;
 theForm.service_type.visible = true;
 theForm.refer_to_agency.visible = true;
 theForm.refer_to_site.visible = true;
 theForm.refer_to_service.visible = true;
}
function
showStatusFilters() {
 theForm.status.visible = true;
 theForm.substatus.visible = true;
}
function
showDateFilters() {
 theForm.start_date.visible = true;
 theForm.end_date.visible = true;
}
function
showProviderFilters() {
 theForm.search.visible = true;
 theForm.prsnl.visible = true;
}
function
showPatientSearch() {
 theForm.btnSearch.visible = true;
 theForm.btnClear.visible = true;
}
function
showPatientFilters() {
 theForm.person_info.visible = true;
}
function
showReferralFilters() {
 theForm.ref_list.visible = true;
}
function
onSearch(sender) {
 // Open & connect to the PMSearch
automation server
 var pm = new
ActiveXObject(PMSearch.SearchDlg);
 // Search for person only
 pm.Mode = PMSearch.pmPersonMode;
 pm.AddPersonButton = false;
 pm.ReturnPersonInfo =
PMSearch.pmReturnAllPerson;
 pm.Initialize(theForm.appHandle);
 pm.Search(); // Run the PMSearch
 // Get the selected person
 theForm.person_id.value =
pm.GetPersonInfo(0, "person_id");
 // Force update to trigger listbox queries
 theForm.person_id.fireChangeEvent();
}
function
onClear(sender) {
 theForm.person_id.value = 0; //vs clear();
 theForm.ref_list.clear();
 hideFilters();
 hidePersonFilters();
 showPatientSearch();
}
