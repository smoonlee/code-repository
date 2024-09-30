<#
.SYNOPSIS
    Updates PowerShell Package Management modules including NuGet, PowerShellGet, and PackageManagement.

.DESCRIPTION
    This script performs the following tasks:
    - Checks if the script is running with Administrator privileges.
    - Installs the latest NuGet Package Provider if running on PowerShell 5.
    - Ensures the PowerShell Gallery repository is set to 'Trusted'.
    - Installs the latest versions of PowerShellGet and PackageManagement modules.
    - Removes and re-imports the updated modules to ensure they are loaded correctly.

.PARAMETERS
    None.

.EXAMPLE
    PS C:\> .\Update-PwshPackageManagement.ps1
    Runs the script to update PowerShell Package Management modules.

.NOTES
    - Ensure the script is run with Administrator privileges.
    - The script is designed to work with both PowerShell 5 and later versions.

#>

function Update-PwshPackageManagement {

    # Verbose Message
    Write-Output `r "--------------------------------------"
    Write-Output " Update PowerShell Package Management "
    Write-Output "--------------------------------------"
    Write-Output "Pwsh Version: $($host.version.ToString())" `r

    # Check if running as Administrator
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Output "> Error: Please run this script as an Administrator"
        return
    }

    # Install Latest NuGet Package Provider
    if ($host.Version.Major -like '5') {
    try {
        Write-Output "> Installing Latest NuGet Package Provider"
        Install-PackageProvider -Scope 'CurrentUser' -Name 'NuGet' -Force
        Write-Output ""
    }
    catch {
        Write-Output "> Error: Installing Latest NuGet Package Provider"
        Write-Output "> Error: $_"
    }
    }

    # Check PowerShell Gallery - Trusted Repositories
    Write-Output "> Checking PowerShell Gallery - Trusted Repositories"
    $installationPolicyCheck = $(Get-PSRepository -Name 'PSGallery').InstallationPolicy
    if ($installationPolicyCheck -ne 'Trusted') {
        Write-Output "> Updating Installation Policy for [PSGallery] to 'Trusted'"
        Set-PSRepository -Name 'PSGallery' -InstallationPolicy 'Trusted'
    }

    if ($installationPolicyCheck -eq 'Trusted') {
        Write-Output "> Installation Policy for [PSGallery] is already 'Trusted'"
    }

    # Install Latest PowerShellGet Module
    try {
        Write-Output `r "> Installing Latest PowerShellGet Module"
        Install-Module -WarningAction 'SilentlyContinue' -Scope 'AllUsers' -Name 'PowerShellGet' -Force

    } catch {
        Write-Output "> Error: Installing Latest PowerShellGet Module"
        Write-Output "> Error: $_"
    }

    # Install Latest PackageManagement Module
    try {
        Write-Output "> Installing Latest PackageManagement Module"
        Install-Module -WarningAction 'SilentlyContinue' -Scope 'AllUsers' -Name 'PackageManagement' -Force

    } catch {
        Write-Output "> Error: Installing Latest PackageManagement Module"
        Write-Output "> Error: $_"
    }

    # Remove and Import Updated Modules
    try {
        Write-Output "> Removing and Importing Updated Modules"
        Remove-Module -Name 'PowerShellGet' -Force -ErrorAction SilentlyContinue
        Remove-Module -Name 'PackageManagement' -Force -ErrorAction SilentlyContinue

        Import-Module -Name 'PowerShellGet' -Force
        Import-Module -Name 'PackageManagement' -Force

        # Show Imported Modules
        Get-Module | Format-Table

    } catch {
        Write-Output "> Error: Removing and Importing Updated Modules"
        Write-Output "> Error: $_"
    }
}

# Execute Function
Update-PwshPackageManagement