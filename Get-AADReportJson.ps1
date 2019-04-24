param(
    [Parameter(Mandatory=$true)]
    [GUID]$ClientId, # Should be a ~35 character string insert your info here

    [Parameter(Mandatory=$true)]
    [string]$ClientSecret, # Should be a ~44 character string insert your info here

    [Parameter(Mandatory=$true)]
    [string]$tenantdomain, # For example, contoso.onmicrosoft.com

    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [string]$earliestRecordDate, # Only log records later than this date will be requested (format yyyy-mm-ddThh:mm:ssZ)
    
    [Parameter(Mandatory=$true)]
    [ValidateSet("Audit","User")]
    [string]$LogType # Must be either User or Audit
)

$loginURL = "https://login.windows.net"
$resource = "https://graph.microsoft.com"

switch($LogType)
{
    Audit {
        $URIfilter = "directoryAudits?`$filter=activityDateTime gt $earliestRecordDate"
        Break 
    }
    User {
        $URIfilter = "signIns?`$filter=createdDateTime gt $earliestRecordDate" 
        Break
    }
}

Write-Output "Searching the tenant $tenantdomain for AAD $LogType events after $PastPeriod"

$url = "https://graph.microsoft.com/beta/auditLogs/" + $URIfilter
$body       = @{grant_type="client_credentials";resource=$resource;client_id=$ClientID;client_secret=$ClientSecret}
$oauth      = Invoke-RestMethod -Method POST -Uri $loginURL/$tenantdomain/oauth2/token?api-version=1.0 -Body $body
if ($oauth.access_token -ne $null)
{
    $headerParams = @{'Authorization'="$($oauth.token_type) $($oauth.access_token)"}
    $myReport = (Invoke-WebRequest -UseBasicParsing -Headers $headerParams -Uri $url -Method GET)
    
	$ConvertedReport = ConvertFrom-Json -InputObject $myReport.Content 
	$ReportValues = $ConvertedReport.value 
	$nextURL = $ConvertedReport."@odata.nextLink"
	if ($nextURL -ne $null)
	{
		Do 
        {
            $NextResults = Invoke-WebRequest -UseBasicParsing -Headers $headerParams -Uri $nextURL -Method Get -ErrorAction SilentlyContinue 
		    $NextConvertedReport = ConvertFrom-Json -InputObject $NextResults.Content 
		    $ReportValues += $NextConvertedReport.value
		    $nextURL = $NextConvertedReport."@odata.nextLink"
		}
		While ($nextURL -ne $null)
    }

    $json=$ReportValues | ConvertTo-Json
    $fileName= 'AAD' + $LogType + 'Log.json'
    $path=Join-Path (Get-Location) $fileName
    Set-Content -Path $path -Value $json
    Write "Report location $path"

}