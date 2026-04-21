param(
  [string]$ConfigPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$runtimeDir = Join-Path $PSScriptRoot "..\.runtime"
$pidPath = Join-Path $runtimeDir "surface-tunnels.pid"
$commandPath = Join-Path $runtimeDir "surface-tunnels.cmd"

if (-not (Test-Path $pidPath)) {
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
if (Test-Path $commandPath) {
  Remove-Item -Path $commandPath -Force
}
Write-Host "Stopped tunnel process PID $($process.Id)"
