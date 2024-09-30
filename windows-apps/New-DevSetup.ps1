# Verbose Message
Write-Output `r "-------------------------------------------"
Write-Output "  Configure Azure Development Environment  "
Write-Output "-------------------------------------------"
Write-Output "Pwsh Version: $($host.version.ToString())" `r

# Check if running as Administrator and PowerShell version is 7
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator") -or $PSVersionTable.PSVersion.Major -ne 7) {
    Write-Output "> Error: Please run this script as an Administrator and ensure it is using PowerShell 7."
    return
}

# Install Required Software
Write-Output "> Installing Required Software"
$requiredSoftware = @(
    'Microsoft.VisualStudioCode',
    'Microsoft.VisualStudioCode.CLI'
    'Microsoft.WindowsTerminal',
    'Microsoft.PowerShell',
    'Microsoft.AzureCLI',
    'Microsoft.Bicep',
    'FireDaemon.OpenSSL',
    'Git.Git',
    'GitHub.cli',
    'Hugo.Hugo.Extended',
    'Docker.DockerDesktop',
    'Docker.DockerCLI'
    'Kubernetes.Kubectl',
    'Microsoft.Azure.Kubelogin',
    'Helm.Helm'
)

foreach ($software in $requiredSoftware) {
    Write-Output `r "> Installing: $software"
    winget install --scope Machine --id $software --silent
}

# Install Required PowerShell Modules
$requiredModules = @(
    'Az',
    'Microsoft.Graph'
)

foreach ($module in $requiredModules) {
    Write-Output `r "> Installing: [Pwsh Module] $module"
    Install-Module -Scope 'CurrentUser' -Name $module -Force
}

# Creating System Path for OpenSSL
Write-Output `r "> Adding OpenSSL to System Path"
Write-Warning "> Requires system reboot to take effect!"
$oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
$newpath = "$oldpath;$Env:ProgramFiles\FireDaemon OpenSSL 3\bin"
Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newpath

# Reload PowerShell Profile
Write-Output "> Reloading PowerShell Profile"
Get-Process -Id $PID | Select-Object -ExpandProperty Path | ForEach-Object { Invoke-Command { & "$_" } -NoNewScope }