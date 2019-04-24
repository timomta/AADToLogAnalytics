Param(
    [Parameter(Mandatory=$true)]
    [GUID]$WorkspaceId, # Log Analytics Workspace ID

    [Parameter(Mandatory=$true)]
    [string]$LogAnalyticsTable # Log Analytics table to query to find 
)

$latestTimestamp=Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceId `
    -Query ($LogAnalyticsTable + " | summarize max(TimeGenerated)")

$latestTimestamp.Results.max_TimeGenerated
