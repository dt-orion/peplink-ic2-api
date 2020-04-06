# Peplink InControl 2 API Examples
A small collection of PowerShell scripts that leverage the Peplink InControl 2 API
    
# Recommendations
* .NET Framework Runtime >=4.5.2 https://dotnet.microsoft.com/download
* Windows Management Framework/PowerShell 5.1 https://www.microsoft.com/en-us/download/details.aspx?id=54616
* NOTE: WMF/PS 5.1 is included with Windows 10+ & Server 2016+
  
If PowerShell hasn't been used before, the user's PowerShell execution policy might need to be relaxed
```powershell
# Run from an admin PowerShell session
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser
```
  
# Create a Peplink InControl 2 client application
```
1. Login to the Peplink InControl 2 portal: https://incontrol2.peplink.com/login
2. Click on the link for your account name (usually your email address) in the top right corner, just next to ' | Sing Out'
3. Scroll down to the bottom of the page and click the 'New Client' button
4. Enter the following values for the new client:
4.1 Application Name: RestClient
4.2 Enable: [CHECKED]
4.3 Website: [LEAVE BLANK]
4.4 Redirect URI: [LEAVE BLANK]
4.5 Token Type: Bearer
5. Click the 'Save' button
6. Click on the 'RestClient' link, in the 'Client Applications' list at the bottom of the page
7. Notate the 'Client ID' (referenced as CLIENT_ID)
8. Click the 'Show Secret' link
9. Notate the now visible 'Client Secret' (referenced as CLIENT_SECRET)

NOTE: Treat the 'Client ID' and 'Client Secret' as a secure username and password!
```
  
# ic2-get-org-list.ps1
* [View on GitHub](https://github.com/dt-orion/peplink-ic2-api/blob/master/ic2-get-org-list.ps1)
* [Raw download link](https://github.com/dt-orion/peplink-ic2-api/raw/master/ic2-get-org-list.ps1)
```powershell
# Get the list of organizations visible to a client application:

.\ic2-get-org-list.ps1 -ClientId 'CLIENT_ID' -ClientSecret 'CLIENT_SECRET'
```
  
# ic2-get-org-group-list.ps1
* [View on GitHub](https://github.com/dt-orion/peplink-ic2-api/blob/master/ic2-get-org-group-list.ps1)
* [Raw download link](https://github.com/dt-orion/peplink-ic2-api/raw/master/ic2-get-org-group-list.ps1)
```powershell
# Get the list of groups visible to an organization:

.\ic2-get-org-group-list.ps1 -ClientId 'CLIENT_ID' -ClientSecret 'CLIENT_SECRET' -OrgId 'ORG_ID'
```
  
# ic2-get-org-group-event-log.ps1
* [View on GitHub](https://github.com/dt-orion/peplink-ic2-api/blob/master/ic2-get-org-group-event-log.ps1)
* [Raw download link](https://github.com/dt-orion/peplink-ic2-api/raw/master/ic2-get-org-group-event-log.ps1)
```powershell
# Get the event log entries for a specific organization group:

.\ic2-get-org-group-event-log.ps1 -ClientId 'CLIENT_ID' -ClientSecret 'CLIENT_SECRET' -OrgId 'ORG_ID' -GroupId 'GROUP_ID'
```
  
# License Information
This repository is licensed under the [MIT license](https://github.com/dt-orion/peplink-ic2-api/blob/master/LICENSE)