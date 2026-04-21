param(
  [string]$ConfigPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
  $ConfigPath = Join-Path $PSScriptRoot "..\config\services.local.json"
}

$runtimeDir = Join-Path $PSScriptRoot "..\.runtime"
$pidPath = Join-Path $runtimeDir "surface-tunnels.pid"
$listenerPorts = @()

if (Test-Path $ConfigPath) {
  $config = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
  $listenerPorts = @([int]$config.surface.localOpenWebUiPort, [int]$config.surface.localVllmPort)
}

if (-not (Test-Path $pidPath)) {
  if ($listenerPorts.Count -gt 0) {
    $fallbackPids = @(Get-NetTCPConnection -State Listen -LocalPort $listenerPorts -ErrorAction SilentlyContinue |
      Select-Object -ExpandProperty OwningProcess -Unique)
    if ($fallbackPids.Count -eq 1) {
      Stop-Process -Id $fallbackPids[0] -Force
      Write-Host "Stopped tunnel process PID $($fallbackPids[0])"
      return
    }
  }

  Write-Host "No tunnel PID file found."
  return
}

$pidValue = Get-Content -Path $pidPath -Raw
if (-not $pidValue) {
  Remove-Item -Path $pidPath -Force
  Write-Host "Removed empty tunnel PID file."
  return
}

$process = Get-Process -Id ([int]$pidValue) -ErrorAction SilentlyContinue
if (-not $process) {
  Remove-Item -Path $pidPath -Force
  Write-Host "Tunnel process $pidValue not running. Removed PID file."
  return
}

Stop-Process -Id $process.Id -Force
Remove-Item -Path $pidPath -Force
Write-Host "Stopped tunnel process PID $($process.Id)"
