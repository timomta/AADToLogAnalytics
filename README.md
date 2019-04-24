# AADToLogAnalytics
Scripts to transfer Audit and User logs from AAD to Log Analytics

## Get-LogAnalyticsLastTimestamp
```
Get-LogAnalyticsLastTimestamp.ps1
  -WorkspaceId {Log Analytics workspace GUID}
  -LogAnalyticsTable {Name of the Log Analytics table to query for last timestamp}
```  
The purpose of this script is to determine the latest timestamp in the Log Analyics table you intend to import new data to. You can use its output as a parameter to Get-AADReportJson to collect records newer than what is already written to Log Analytics. The intent is to give you a date you can use to avoid asking for records you don't need from AAD and importing duplicate records into Log Analyitics. This script requires you to authenticate to Azure by first running Connect-AzAccount.

## Get-AADReportJson
```
Get-AADReportJson.ps1
  -ClientId {Your AAD application Id GUID with rights to query the audit logs}
  -ClientSecret {The application secret for the given AAD application Id}
  -TenantDomain {The DNS domain name of the AAD tenant, for example contoso.onmicrosoft.com}
  -EarliestRecordDate {The date, yyyy-mm-ddThh:mm:ssZ, after which records should be exported, see Get-LogAnalyticslastTimestamp}
  -LogType {Audit | User}
```
The purpose of this script is to query AAD for audit or user logs, put the records into the correct JSON format for import to Log Analytics and save them to a JSON file on disk.

## Post-LogAnalyticsData
```
Post-LogAnalyticsData.ps1
  -WorkspaceId {Log Analytics workspace ID to push the data to}
  -WorkspaceKey {Log Analytics workspace key}
  -LogName {Name of the Log Analyics log to push the data to}
  -TimestampField {Name of the field in the json content to be used in the Log Analytics timestamp field}
  -JsonLogFile {JSON formatted records to put in the Log Analytics log}
```
The purpose of this script is to load records from a JSON file and import them into the given Log Analytics workspace table. The TimeStampField name to use for user logs "createdDateTime" and "activityDateTime" for audit logs.

## End to End Example
Below is an example run of Get-LogAnalyticsLastTimestamp. It returns the last timestamp (or max datetime) of all the records in the LogAnalytics table named AADSignIns_CL for the given workspace Id.
```
PS C:\Source\Repos\AADToLogAnalytics> Connect-AzAccount

Account             SubscriptionName                          TenantId                             Environment
-------             ----------------                          --------                             -----------
xxxxx@microsoft.com Azure Subscription                        72f988bf-86f1-41af-91ab-2d7cd1234567 AzureCloud


PS C:\Source\Repos\AADToLogAnalytics> .\Get-LogAnalyticsLastTimestamp.ps1 -WorkspaceId 12345678-8db9-4f87-a61a-f4657625c48c -LogAnalyticsTable AADSignIns_CL
2019-04-18T23:36:26.407Z
PS C:\Source\Repos\AADToLogAnalytics>
```

Next, run Get-AADReportJson to pull down the report you want from AAD. You will have to already created an application Id in AAD and its corresponding secret. Note that the date returned from the above script run is used.
Please see
 - https://docs.microsoft.com/en-us/azure/active-directory/reports-monitoring/howto-configure-prerequisites-for-reporting-api#grant-permissions
 - https://docs.microsoft.com/en-us/azure/active-directory/reports-monitoring/concept-reporting-api#execute-the-script

```
PS C:\Source\Repos\AADToLogAnalytics> .\Get-AADReportJson.ps1 -ClientId 12345678-a762-4249-93ee-79cfb527e2ac -ClientSecret ORZQWAsGREATbIGsECRETegGFDmwYRWslih1nM= -TenantDomain contoso.onmicrosoft.com -LogType User -EarliestRecordDate 2019-04-18T23:36:26.407Z
Searching the tenant for AAD Audit events after
Report location C:\Source\Repos\AADToLogAnalytics\AADUserLog.json
PS C:\Source\Repos\AADToLogAnalytics>
```

Finally, run Post-LogAnalyticsData to push the above JSON user records to Log Analytics. Note that we are using the file just written by the above run, AADUserLog.json. Also, the TimeStampField is the createdDateTime field in user logs. For audit logs it is activityDateTime.
```
PS C:\Source\Repos\AADToLogAnalytics> .\Post-LogAnalyticsData.ps1 -WorkspaceId 12345678-8db9-4f87-a61a-f4657625c48c -WorkspaceKey gREATbIGwORKSPACEkEYQEf66ZL4gFAyipFy8JQhtvrwsQ5JvUvZg3vFJ/KyBrdAO/vMG8X6wtP3A== -LogName AADSignIns_CL -TimeStampField createdDateTime -JsonLogFile .\AADUserLog.json
200
PS C:\Source\Repos\AADToLogAnalytics>
