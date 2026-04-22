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
$SPARK_HOST = $config.spark.host
$SPARK_USER = $config.spark.sshUser
$VLLM_LOCAL = $config.surface.localVllmPort
$WEBUI_LOCAL = $config.surface.localOpenWebUiPort
$hasFailures = $false

Write-Host "`n== Spark SSH ping =="
$nc = Test-NetConnection -ComputerName $SPARK_HOST -Port 22 -InformationLevel Quiet -WarningAction SilentlyContinue
Write-Host "SSH reachable: $nc"
if (-not $nc) {
  $hasFailures = $true
}

Write-Host "Spark user: $SPARK_USER"

Write-Host "`n== vLLM endpoint (requires Sync tunnel on $VLLM_LOCAL) =="
try {
  $r = Invoke-RestMethod -Uri $config.services.vllm.tunneledHealthUrl -TimeoutSec 6
  Write-Host "vLLM OK"
  $r | ConvertTo-Json -Depth 4
} catch {
  $hasFailures = $true
  Write-Host "vLLM unreachable: $($_.Exception.Message)"
}

Write-Host "`n== Open WebUI (requires Sync tunnel on $WEBUI_LOCAL) =="
try {
  $r = Invoke-WebRequest -Uri $config.services.openWebUi.tunneledHealthUrl -UseBasicParsing -TimeoutSec 6
  Write-Host "Open WebUI OK - HTTP $($r.StatusCode)"
} catch {
  $hasFailures = $true
  Write-Host "Open WebUI unreachable: $($_.Exception.Message)"
}

if ($hasFailures) {
  exit 1
}
