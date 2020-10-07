<#
.SYNOPSIS

Copies a modern SharePoint site to a new URL.

.DESCRIPTION

Copy-PnPSite creates a new target site of the same type as the source
at a new URL, and copies all site pages from the source to the target.

The source site is exported as a PnP provisioning template and the
template is applied to the target site.

.PARAMETER SourceUrl 
Specifies the URL of the site to be copied. The site must exist, and you must
have permission to export a site template.

.PARAMETER TargetUrl
Specifies the URL of the target site to be created. The site must not exist.

.EXAMPLE

PS> .\Copy-PnPSite.ps1 -SourceUrl "https://example.sharepoint.com/sites/Alpha" -TargetUrl "https://example.sharepoint.com/sites/Beta"

#>

param (
    [string]$SourceUrl = $(throw "SourceUrl parameter is required."),
    [string]$TargetUrl = $(throw "TargetUrl parameter is required.")
)

# Get source site info
$SourceSite = Get-PnPTenantSite -Url $SourceUrl
$SourceSiteTitle = $SourceSite.Title
$SourceSiteGroupId = $SourceSite.GroupId
$SourceSiteType = "CommunicationSite"

# If the source is connected to a group, create a team site.
if ( $SourceSiteGroupId -ne "00000000-0000-0000-0000-000000000000" )
{
    $SourceSiteType = "TeamSite"
}

# Connect to source site.
$SourceConnection = Connect-PnPOnline -Url $SourceUrl

# Temporary file to save site template.
$TempFile = New-TemporaryFile

# Export page contents as a site template.
Get-PnPProvisioningTemplate -Out $TempFile -Handlers PageContents -IncludeAllClientSidePages

# Disconnect from source site.
Disconnect-PnPOnline -Connection $SourceConnection

# Create copy site
New-PnPSite -Type $SourceSiteType -Title $"Copy of ${SourceSiteTitle}" -Url $TargetUrl

# Connect to clone
$TargetConnection = Connect-PnPOnline -Url $TargetUrl

# Apply source tempalte to new site
Apply-PnPProvisioningTemplate -Path $TempFile -Connection $TargetConnection

# Disconnect from clone
Disconnect-PnPOnline -Connection $TargetConnection

# Clean up temporary file.
Remove-Item -Path $TempFile
