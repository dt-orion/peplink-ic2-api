# Script: ic2-get-org-group-list.ps1
# Version: 0.1
# Purpose: Get the list of groups visible to a specific organization
# https://github.com/dt-orion/peplink-ic2-api
# Recommended .NET Framework Runtime >=4.5.2 (https://dotnet.microsoft.com/download)
# Recommended Windows Management Framework/PowerShell 5.1 (https://www.microsoft.com/en-us/download/details.aspx?id=54616)

# Required user input
Param
(
    [Parameter(Mandatory = $true, Position = 0)]
    [String]$ClientId,
    [Parameter(Mandatory = $true, Position = 1)]
    [String]$ClientSecret,
    [Parameter(Mandatory = $false, Position = 2)]
    [String]$RedirectUri = 'http://www.peplink.com',
    [Parameter(Mandatory = $false, Position = 3)]
    [String]$ApiServer = 'https://api.ic.peplink.com/',
    [Parameter(Mandatory = $true, Position = 4)]
    [String]$OrgId
)

# Enforce latest string mode specification
Set-StrictMode -Version Latest

# Set PowerShell Preferences
$VerbosePreference = 'SilentlyContinue'
$WarningPreference = 'SilentlyContinue'
# Fix for PowerShell bug with Invoke-WebRequest performance
$ProgressPreference = 'SilentlyContinue'

# Allow PowerShell to use self-signed SSL certificates and all security protocols
Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
    }
}
"@
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]"Tls12,Tls11,Tls,Ssl3"
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

# NOTE: The default value for MaxServicePointIdleTime is 100000 milliseconds (100 seconds).
#       The -TimeoutSec parameter for Invoke-WebRequest does not override the value
#       set for MaxServicePointIdleTime. If connections are being closed before the REST
#       operation is able to complete and return a response, the value for 
#       MaxServicePointIdleTime will need to be increased.
#
# Set the timeout value for Invoke-WebRequest to 180 seconds (3 minutes)
[System.Net.ServicePointManager]::MaxServicePointIdleTime = 180000

# Start of script body

# Capture script execution start time
$ScriptTime = Get-Date

# OAuth2 URI
$OAuth2Uri = $ApiServer + "api/oauth2/token"

# Generate OAuth2 authentication post body
$OAuth2PostBody = "client_id=$ClientId&client_secret=$ClientSecret&grant_type=client_credentials"

# Capture task start time
$TaskTime = Get-Date

# Get OAuth2 token
Write-Host("Attempting to authenticate client ID '$ClientId' with secret '$ClientSecret' at $OAuth2Uri...") -ForegroundColor Yellow
try {
    $OAuth2PostResponse = Invoke-WebRequest -Uri $OAuth2Uri -Body $OAuth2PostBody -ContentType "application/x-www-form-urlencoded" -Method Post -SessionVariable OAuth2Session -UseBasicParsing:$true -DisableKeepAlive:$true
}
catch {
    throw "An error occurred while attempting to get the OAuth2 token! Please double-check the API server address / client ID & secret and try again!"
}

# Calculate and display task end time
$TaskTime = $(Get-Date) - $TaskTime
Write-Host("Successfully aquired OAuth2 token from $OAuth2Uri in " + $TaskTime.ToString("hh\:mm\:ss\.ffff")) -ForegroundColor Green

# Convert the OAuth2 authentication post response content string to a powershell JSON object
$OAuth2 = ConvertFrom-Json $([String]::new($OAuth2PostResponse.Content))

# Extract the values from the JSON object
$OAuth2AccessToken = $OAuth2.access_token
$OAuth2RefreshToken = $OAuth2.refresh_token
$OAuth2TokenType = $OAuth2.token_type
$OAuth2ExpiresIn = $OAuth2.expires_in

# Calcuate OAuth2 token expiration date and time
$OAuth2ExpirationDate = $(Get-Date).AddSeconds([int]$OAuth2ExpiresIn)

# Display OAuth2 token expiration date and time
Write-Host("OAuth2 access token: $OAuth2AccessToken") -ForegroundColor Magenta
Write-Host("OAuth2 refresh token: $OAuth2RefreshToken") -ForegroundColor Cyan
Write-Host("OAuth2 token type: $OAuth2TokenType") -ForegroundColor Green
Write-Host("OAuth2 token expires on $($OAuth2ExpirationDate.ToShortDateString()) at $($OAuth2ExpirationDate.ToShortTimeString())") -ForegroundColor Yellow

# Generate ic2 organization group list URI with the OAuth2 access token
$OrgGroupListUri = $ApiServer + "rest/o/$OrgId/g?access_token=$OAuth2AccessToken"

# Capture task start time
$TaskTime = Get-Date

# Get visible ic2 organization list
Write-Host("Attempting to get group list for organization ID '$OrgId' from: $OrgGroupListUri") -ForegroundColor Yellow
try {
    $OrgGroupListGetResponse = Invoke-WebRequest -Uri $OrgGroupListUri -Method Get -SessionVariable OrgGroupListSession -UseBasicParsing:$true -DisableKeepAlive:$true
}
catch {
    throw "An error occurred while attempting to get the group list for organization ID '$OrgId'! Please double-check the organization ID / OAuth2 token and try again!"
}

# Calculate and display task end time
$TaskTime = $(Get-Date) - $TaskTime
Write-Host("Acquired the organization group list in " + $TaskTime.ToString("hh\:mm\:ss\.ffff")) -ForegroundColor Green

# Convert the ic2 organization group list get response content string to a powershell JSON object
$OrgGroupList = ConvertFrom-Json $([String]::new($OrgGroupListGetResponse.Content))

# Display API call results
Write-Host("API call caller_ref: $($OrgGroupList.caller_ref)") -ForegroundColor DarkCyan
Write-Host("API call resp_code: $($OrgGroupList.resp_code)") -ForegroundColor DarkGreen
Write-Host("API call server_ref: $($OrgGroupList.server_ref)") -ForegroundColor DarkMagenta

# Decalre empty array to store the individual organization group records
$OrgGroupArray = @()

# Loop through all the organization groups and add them to the array
foreach ($OrgGroup in $OrgGroupList.data) {
    $OrgGroupArray += , $OrgGroup
}

# Display all organization group records
$OrgGroupArray

# Calculate script end time and display results
$ScriptTime = $(Get-Date) - $ScriptTime
Write-Host("Finished script execution in " + $ScriptTime.ToString("hh\:mm\:ss\.ffff"))
