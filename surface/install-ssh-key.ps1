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
$hostName = $config.spark.host
$userName = $config.spark.sshUser
$port = [string]$config.spark.sshPort
$publicKeyPath = [Environment]::ExpandEnvironmentVariables($config.spark.sshPublicKeyPath)

if ([string]::IsNullOrWhiteSpace($publicKeyPath) -or -not (Test-Path $publicKeyPath)) {
  throw "SSH public key not found: $publicKeyPath"
}

$publicKey = (Get-Content -Path $publicKeyPath -Raw).Trim()
if ([string]::IsNullOrWhiteSpace($publicKey)) {
  throw "SSH public key file is empty: $publicKeyPath"
}

$escapedPublicKey = $publicKey.Replace("'", "'\''")
$remoteCommand = "umask 077; mkdir -p ~/.ssh; touch ~/.ssh/authorized_keys; grep -qxF '$escapedPublicKey' ~/.ssh/authorized_keys || echo '$escapedPublicKey' >> ~/.ssh/authorized_keys"

Write-Host "Installing SSH public key on $userName@$hostName"
& ssh -p $port "$userName@$hostName" $remoteCommand
if ($LASTEXITCODE -ne 0) {
  throw "Failed to install SSH key on Spark."
}

Write-Host "SSH key installed. Test with:"
Write-Host "  ssh -o BatchMode=yes -p $port $userName@$hostName echo key-auth-ok"
