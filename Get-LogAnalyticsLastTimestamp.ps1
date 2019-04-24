Param(
    [Parameter(Mandatory=$true)]
    [GUID]$logAnalyticsWorkspace, # Log Analytics Workspace ID

    [Parameter(Mandatory=$true)]
    [string]$logAnalyticsTable # Log Analytics table to query to find 
)

$latestTimestamp=Invoke-AzOperationalInsightsQuery -WorkspaceId $logAnalyticsWorkspace `
    -Query ($logAnalyticsTable + " | summarize max(TimeGenerated)")

$latestTimestamp.Results.max_TimeGenerated
