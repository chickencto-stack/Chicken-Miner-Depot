[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Command,
    [string]$ConfigPath
)

if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
    $ConfigPath = Join-Path $PSScriptRoot "..\config\services.local.json"
}

$config = & (Join-Path $PSScriptRoot "Get-FleetConfig.ps1") -Path $ConfigPath
$hostName = $config.spark.host
$userName = $config.spark.sshUser
$port = $config.spark.sshPort
$keyPath = $config.spark.sshKeyPath

if ([string]::IsNullOrWhiteSpace($hostName) -or [string]::IsNullOrWhiteSpace($userName)) {
    throw "Spark host and sshUser must be set in services.local.json"
}

$target = "$userName@$hostName"
$sshArgs = @()
if ($port) {
    $sshArgs += "-p"
    $sshArgs += [string]$port
}
if (-not [string]::IsNullOrWhiteSpace($keyPath)) {
    $expandedKeyPath = [Environment]::ExpandEnvironmentVariables($keyPath)
    $sshArgs += "-i"
    $sshArgs += $expandedKeyPath
}
$sshArgs += $target
$sshArgs += $Command

& ssh @sshArgs
if ($LASTEXITCODE -ne 0) {
    throw "SSH command failed with exit code $LASTEXITCODE"
}
