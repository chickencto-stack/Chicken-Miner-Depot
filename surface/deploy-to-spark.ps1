param(
  [string]$ConfigPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
  $ConfigPath = Join-Path $PSScriptRoot "..\config\services.local.json"
}

if (-not (Test-Path $ConfigPath)) {
  throw "Config file not found: $ConfigPath"
}

$config = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
$SparkHost = $config.spark.host
$SparkUser = $config.spark.sshUser
$SparkPort = $config.spark.sshPort
$SparkKeyPath = $config.spark.sshKeyPath
$RemoteScriptsRoot = $config.spark.remoteScriptsRoot
$LogsRoot = $config.spark.logsRoot
$scripts = "$PSScriptRoot\..\spark\scripts"
$scriptFiles = Get-ChildItem -Path $scripts -Filter "*.sh" | Select-Object -ExpandProperty FullName

if (-not $scriptFiles) {
  throw "No Spark shell scripts found in $scripts"
}

$expandedKeyPath = $null
if (-not [string]::IsNullOrWhiteSpace($SparkKeyPath)) {
  $expandedKeyPath = [Environment]::ExpandEnvironmentVariables($SparkKeyPath)
}

function Invoke-ExternalCommand {
  param(
    [Parameter(Mandatory = $true)]
    [string]$FilePath,
    [Parameter(Mandatory = $true)]
    [string[]]$ArgumentList,
    [Parameter(Mandatory = $true)]
    [string]$FailureMessage
  )

  & $FilePath @ArgumentList
  if ($LASTEXITCODE -ne 0) {
    throw "$FailureMessage Exit code: $LASTEXITCODE"
  }
}

$target = "$SparkUser@$SparkHost"
$bootstrapCommand = "if [ -d /opt/ai ] && [ -w /opt/ai ]; then mkdir -p '$RemoteScriptsRoot' '$LogsRoot' /opt/ai/run; else sudo mkdir -p '$RemoteScriptsRoot' '$LogsRoot' /opt/ai/run; sudo chown -R '${SparkUser}:${SparkUser}' /opt/ai; fi"

Write-Host "Creating Spark runtime directories..."
$sshBootstrapArgs = @("-p", [string]$SparkPort)
if ($expandedKeyPath) {
  $sshBootstrapArgs += @("-i", $expandedKeyPath)
}
$sshBootstrapArgs += @($target, $bootstrapCommand)
Invoke-ExternalCommand -FilePath "ssh" -ArgumentList $sshBootstrapArgs -FailureMessage "Failed to create remote Spark directories."

Write-Host "Copying scripts..."
$scpArgs = @("-P", [string]$SparkPort)
if ($expandedKeyPath) {
  $scpArgs += @("-i", $expandedKeyPath)
}
$scpArgs += $scriptFiles + @("${SparkUser}@${SparkHost}:${RemoteScriptsRoot}/")
Invoke-ExternalCommand -FilePath "scp" -ArgumentList $scpArgs -FailureMessage "Failed to copy Spark scripts."

Write-Host "Setting executable..."
$sshChmodArgs = @("-p", [string]$SparkPort)
if ($expandedKeyPath) {
  $sshChmodArgs += @("-i", $expandedKeyPath)
}
$sshChmodArgs += @($target, "chmod +x ${RemoteScriptsRoot}/*.sh")
Invoke-ExternalCommand -FilePath "ssh" -ArgumentList $sshChmodArgs -FailureMessage "Failed to set executable permissions on Spark scripts."

Write-Host "`nDone. Verify with:"
Write-Host "  ssh -p $SparkPort $SparkUser@$SparkHost bash ${RemoteScriptsRoot}/health-check.sh"
