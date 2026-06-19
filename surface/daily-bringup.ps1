param(
  [string]$ConfigPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
  $ConfigPath = Join-Path $PSScriptRoot "..\config\services.local.json"
}

& (Join-Path $PSScriptRoot "start-tunnels.ps1") -ConfigPath $ConfigPath
& (Join-Path $PSScriptRoot "..\scripts\preflight.ps1") -ConfigPath $ConfigPath
