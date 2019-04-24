# AADToLogAnalytics
Scripts to transfer Audit and User logs from AAD to Log Analytics

## Get-LogAnalyticsLastTimestamp
```
Get-LogAnalyticsLastTimestamp.ps1
  -logAnalyticsWorkspace {Log Analytics workspace GUID}
  -logAnalyticsTable {Name of the Log Analytics table to query for last timestamp}
```  
The purpose of this script is to determine the latest timestamp in the Log Analyics table you intend to import new data to. You can use this value as a parameter to Get-AADReportJson so that it will only collect records newer than what is already written to Log Analytics. The intent is to give you a date you can use to avoid asking for records you don't need from AAD and importing duplicate records into Log Analyitics.

## Get-AADReportJson
```
Get-AADReportJson.ps1
  -ClientId {Your AAD application Id GUID with rights to query the audit logs}
  -ClientSecret {The application secret for the given AAD application Id}
  -tenantdomain {The DNS domain name of the AAD tenant, for example contoso.onmicrosoft.com}
  -earliestRecordDate {The date, yyyy-mm-ddThh:mm:ssZ, after which records should be exported, see Get-LogAnalyticslastTimestamp}
  -LogType {Audit | User}
```
The purpose of this script is to query AAD for audit or user logs, put the records into the correct JSON format for import to Log Analytics and save them to a JSON file on disk.

## Post-LogAnalyticsData
```
Post-LogAnalyticsData.ps1
  -WorkspaceId {Log Analytics workspace ID to push the data to}
  -WorkspaceKey {Log Analytics workspace key}
  -LogType {Name of the Log Analyics log to push the data to}
  -TimestampField {Name of the field in the json content to be used in the Log Analytics timestamp field}
  -jsonLogFile {JSON formatted records to put in the Log Analytics log}
```
The purpose of this script is to load records from a JSON file and import them into the given Log Analytics workspace table.
