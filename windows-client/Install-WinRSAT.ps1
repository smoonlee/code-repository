<#
.SYNOPSIS
    Installs Windows Remote Server Administration Tools (RSAT) on a client or server machine.

.DESCRIPTION
    The Install-WinRSAT function installs the necessary RSAT tools based on the specified installation type (Client or Server).
    It checks if the script is running with administrative privileges and installs the appropriate RSAT tools accordingly.

.PARAMETER installType
    Specifies the type of installation. Valid values are 'Client' and 'Server'.
    'Client' installs RSAT tools for client machines.
    'Server' installs RSAT tools for server machines.

.EXAMPLE
    Install-WinRSAT -installType Client
    This command installs RSAT tools for a client machine.

.EXAMPLE
    Install-WinRSAT -installType Server
    This command installs RSAT tools for a server machine.

.NOTES
    Ensure that the script is run with administrative privileges.
    The script updates PowerShell Package Management and installs the necessary RSAT tools based on the specified installation type.

#>


function Install-WinRSAT {

    param (
        [parameter(Mandatory = $True)] [ValidateSet('Client', 'Server')] [string]$installType
    )

    # Verbose Message
    Write-Output `r "--------------------------------------------"
    Write-Output "  Remote Server Administration Tools Setup  "
    Write-Output "--------------------------------------------"
    Write-Output "Pwsh Version: $($host.version.ToString())" `r

    # Check if running as Administrator
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Output "> Error: Please run this script as an Administrator"
        return
    }

    # Install Windows Remote Server Administration Tools
    if ($installType -eq 'Client') {
        Write-Output "> Installing Windows Remote Server Administration Tools for Client"
        $rsatArray = Get-WindowsCapability -Online | Where-Object { $_.Name -like 'Rsat.Client*' -and $_.State -eq 'NotPresent' }
        foreach ($rsat in $rsatArray) {
            Write-Output "> Installing RSAT: $($rsat.Name)"
            Add-WindowsCapability -Online -Name $rsat.Name
        }
    }

    if ($installType -eq 'Server') {
        Write-Output "> Installing Windows Remote Server Administration Tools for Server"

        # List of RSAT features to install
        $rsatFeatures = @(
            "RSAT-AD-Tools",
            "RSAT-AD-PowerShell",
            "RSAT-ADDS",
            "RSAT-AD-AdminCenter",
            "RSAT-ADDS-Tools",
            "RSAT-ADLDS",
            "RSAT-Hyper-V-Tools",
            "RSAT-RDS-Tools",
            "RSAT-RDS-Gateway",
            "RSAT-RDS-Licensing-Diagnosis-UI",
            "RSAT-ADCS",
            "RSAT-ADCS-Mgmt",
            "RSAT-Online-Responder",
            "RSAT-ADRMS",
            "RSAT-DHCP",
            "RSAT-DNS-Server",
            "RSAT-Fax",
            "RSAT-File-Services",
            "RSAT-DFS-Mgmt-Con",
            "RSAT-FSRM-Mgmt",
            "RSAT-NFS-Admin",
            "RSAT-NetworkController",
            "RSAT-NPAS",
            "RSAT-Print-Services",
            "RSAT-RemoteAccess",
            "RSAT-RemoteAccess-Mgmt",
            "RSAT-RemoteAccess-PowerShell",
            "RSAT-VA-Tools",
            "RSAT-Clustering"
            "WDS-AdminPack"
        )

        # Install each feature
        foreach ($feature in $rsatFeatures) {
            Install-WindowsFeature -Name $feature -IncludeManagementTools -ErrorAction Stop | Out-Null
            Write-Output `r "$feature installed successfully."
        }

    }

}

# Execute Function
Install-WinRSAT