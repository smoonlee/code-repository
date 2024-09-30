<#
.SYNOPSIS
Installs or updates the WinGet CLI Package Manager on a Windows client.

.DESCRIPTION
This script downloads and installs the latest stable release of the WinGet CLI Package Manager along with its dependencies.
It checks for the required permissions, downloads necessary files, installs pre-requisite packages, and finally installs the WinGet CLI.

.PARAMETER preview
A switch parameter to indicate if the preview version of WinGet CLI should be installed. (Currently not implemented in the script)

.NOTES
- The script must be run with Administrator privileges.
- The script downloads files to a temporary directory under the user's local app data folder.
- After installation, the script cleans up the downloaded files.

.EXAMPLE
PS> .\Install-WinGetCLI.ps1
This command runs the script and installs the latest stable version of WinGet CLI.

#>

function Install-WinGetCLI {

    # Verbose Message
    Write-Output `r "--------------------------------------"
    Write-Output "  Install WinGet CLI Package Manager  "
    Write-Output "--------------------------------------"
    Write-Output "Pwsh Version: $($host.version.ToString())" `r

    # Check if running as Administrator
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Output "> Error: Please run this script as an Administrator"
        return
    }

    # Github Urls
    $winGetUrl = 'https://api.github.com/repos/microsoft/winget-cli/releases'
    $winGetResponse = Invoke-WebRequest -Method 'Get' -Uri $winGetUrl
    $winGetContent = $winGetResponse.Content | ConvertFrom-Json

    # Get Winget CLI Releases
    $winGetPreviewRelease = $winGetContent | Where-Object { $_.prerelease } | Select-Object -First 1
    $winGetStableRelease = $winGetContent | Where-Object { -not $_.prerelease } | Select-Object -First 1

    # Get WinGet CLI Download Urls
    $winGetStableLicenseName = $($winGetStableRelease.assets | Where-Object { $_.name -like '*.xml' } | Select-Object -First 1).name
    $winGetStableLicenseUrl = $($winGetStableRelease.assets | Where-Object { $_.name -like '*.xml' } | Select-Object -First 1).browser_download_url

    $wingGetStablePackageName = $($winGetStableRelease.assets | Where-Object { $_.name -like '*.msixbundle' } | Select-Object -First 1).name
    $winGetStablePackageUrl = $($winGetStableRelease.assets | Where-Object { $_.name -like '*.msixbundle' } | Select-Object -First 1).browser_download_url

    # Download Files
    $wc = New-Object System.Net.WebClient
    $downloadPath = "$env:LOCALAPPDATA\temp\wingetInstallPackages"
    if (!(Test-Path -Path $downloadPath)) {
        New-Item -ItemType 'Directory'  -Path $downloadPath -Force | Out-Null
        Write-Output "> Created Download Path: [$downloadPath]" `r
    }

    # Download Microsoft.VCLibs
    Write-Output "> Downloading Microsoft.VCLibs.x64.14.00.Desktop.appx"
    $wc.DownloadFile('https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx', "$downloadPath\Microsoft.VCLibs.x64.14.00.Desktop.appx")

    Write-Output "> Downloading Microsoft.VCLibs.x86.14.00.Desktop.appx"
    $wc.DownloadFile('https://aka.ms/Microsoft.VCLibs.x86.14.00.Desktop.appx', "$downloadPath\Microsoft.VCLibs.x86.14.00.Desktop.appx")

    # Download Microsoft.UI.Xaml
    Write-Output `r "> Downloading Microsoft.UI.Xaml.2.8.x64.appx"
    $wc.DownloadFile('https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx', "$downloadPath\Microsoft.UI.Xaml.2.8.x64.appx")

    Write-Output "> Downloading Microsoft.UI.Xaml.2.8.x86.appx"
    $wc.DownloadFile('https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x86.appx', "$downloadPath\Microsoft.UI.Xaml.2.8.x86.appx")

    # Download WinGet CLI License
    Write-Output `r "> Downloading WinGet License File: [$winGetStableLicenseName]"
    $wc.DownloadFile($winGetStableLicenseUrl, "$downloadPath\$winGetStableLicenseName")

    # Download WinGet CLI Package
    Write-Output "> Downloading WinGet Appx Package: [$wingGetStablePackageName]"
    #Invoke-WebRequest -Uri $winGetStablePackageUrl -OutFile "$downloadPath\$wingGetStablePackageName"
    $wc.DownloadFile($winGetStablePackageUrl, "$downloadPath\$wingGetStablePackageName")

    # Install Pre-Requisites - Microsoft.VCLibs
    Write-Output `r "> Checking Microsoft.VCLibs Package Version"

    if (!(Get-AppxPackage -Name 'Microsoft.VCLibs.140.00.UWPDesktop' | Where-Object { $_.Architecture -eq 'X64' } )) {
            Write-Output "> Installing Microsoft.VCLibs.x64.14.00.Desktop.appx"
            Add-AppxPackage -Path "$downloadPath\Microsoft.VCLibs.x64.14.00.Desktop.appx"
    } else {
        Write-Output "> Microsoft.VCLibs.x64.14.00.Desktop.appx is already installed"
    }

    if (!(Get-AppxPackage -Name 'Microsoft.VCLibs.140.00.UWPDesktop' | Where-Object { $_.Architecture -eq 'X86' } )) {
    Write-Output "> Installing Microsoft.VCLibs.x86.14.00.Desktop.appx"
    Add-AppxPackage -Path "$downloadPath\Microsoft.VCLibs.x86.14.00.Desktop.appx"
    } else {
        Write-Output "> Microsoft.VCLibs.x86.14.00.Desktop.appx is already installed"
    }

    # Install Pre-Requisites - Microsoft.UI.Xaml
    Write-Output `r "> Checking Microsoft.UI.Xaml Package Version"
    if (!(Get-AppxPackage -Name 'Microsoft.UI.Xaml.2.8' | Where-Object { $_.Architecture -eq 'X64' } )) {
        Write-Output "> Installing Microsoft.UI.Xaml.2.8.x64.appx"
        Add-AppxPackage -Path "$downloadPath\Microsoft.UI.Xaml.2.8.x64.appx"
    } else {
        Write-Output "> Microsoft.UI.Xaml.2.8.x64.appx is already installed"
    }

    if (!(Get-AppxPackage -Name 'Microsoft.UI.Xaml.2.8' | Where-Object { $_.Architecture -eq 'X86' } )) {
        Write-Output "> Installing Microsoft.UI.Xaml.2.8.x86.appx"
        Add-AppxPackage -Path "$downloadPath\Microsoft.UI.Xaml.2.8.x86.appx"
    }
    else {
        Write-Output "> Microsoft.UI.Xaml.2.8.x86.appx is already installed"
    }

    # Install WinGet CLI
    Write-Output `r "> Installing WinGet CLI"
    Add-ProvisionedAppPackage -Online `
        -LicensePath "$downloadPath\$winGetStableLicenseName" `
        -PackagePath "$downloadPath\$wingGetStablePackageName"

    Write-Output "> WinGet CLI Installed Successfully"

    # Update WinGet Cache
    Write-Output `r "> Updating WinGet Cache" `r
    winget source reset --force ; winget source update

    # Remove Downloaded Files
    Write-Output `r "> Removing Downloaded Files"
    Remove-Item -Path $downloadPath -Recurse -Force

}

# Execute Function
Install-WinGetCLI