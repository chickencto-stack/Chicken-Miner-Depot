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
$runtimeDir = Join-Path $PSScriptRoot "..\.runtime"
$pidPath = Join-Path $runtimeDir "surface-tunnels.pid"
$hostName = $config.spark.host
$userName = $config.spark.sshUser
$port = [string]$config.spark.sshPort
$keyPath = $config.spark.sshKeyPath
$webUiPort = [string]$config.surface.localOpenWebUiPort
$vllmPort = [string]$config.surface.localVllmPort

function Get-ExistingTunnelPid {
  param(
    [int[]]$Ports
  )

  $listenerPids = @(Get-NetTCPConnection -State Listen -LocalPort $Ports -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty OwningProcess -Unique)

  if ($listenerPids.Count -ne 1) {
    return $null
  }

  $candidate = Get-Process -Id $listenerPids[0] -ErrorAction SilentlyContinue
  if (-not $candidate) {
    return $null
  }

  if ($candidate.ProcessName -ne "ssh") {
    return $null
  }

  return $candidate.Id
}

New-Item -ItemType Directory -Force -Path $runtimeDir | Out-Null

if (Test-Path $pidPath) {
  $existingPid = Get-Content -Path $pidPath -Raw
  if ($existingPid) {
    $existingProcess = Get-Process -Id ([int]$existingPid) -ErrorAction SilentlyContinue
    if ($existingProcess) {
      Write-Host "Tunnel process already running with PID $existingPid"
      return
    }
  }
  Remove-Item -Path $pidPath -Force
}

$existingTunnelPid = Get-ExistingTunnelPid -Ports @([int]$webUiPort, [int]$vllmPort)
if ($existingTunnelPid) {
  Set-Content -Path $pidPath -Value $existingTunnelPid
  Write-Host "Tunnel process already running with PID $existingTunnelPid"
  return
}

$arguments = @(
  "-f",
  "-N",
  "-o", "BatchMode=yes",
  "-L", "${webUiPort}:127.0.0.1:3000",
  "-L", "${vllmPort}:127.0.0.1:8000",
  "-p", $port,
  "$userName@$hostName"
)

if (-not [string]::IsNullOrWhiteSpace($keyPath)) {
  $expandedKeyPath = [Environment]::ExpandEnvironmentVariables($keyPath)
  $arguments = @("-i", $expandedKeyPath) + $arguments
}

$existingListeners = Get-NetTCPConnection -State Listen -LocalPort @([int]$webUiPort, [int]$vllmPort) -ErrorAction SilentlyContinue |
  Select-Object -ExpandProperty OwningProcess -Unique

Start-Process -FilePath "ssh" -ArgumentList $arguments -WindowStyle Hidden | Out-Null

$deadline = (Get-Date).AddSeconds(5)
$listenerProcessIds = @()
while ((Get-Date) -lt $deadline) {
  $listenerProcessIds = @(Get-NetTCPConnection -State Listen -LocalPort @([int]$webUiPort, [int]$vllmPort) -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty OwningProcess -Unique |
    Where-Object { $_ -notin $existingListeners })

  if ($listenerProcessIds.Count -eq 1) {
    break
  }

  Start-Sleep -Milliseconds 200
}

if (-not $listenerProcessIds) {
  $resolvedTunnelPid = Get-ExistingTunnelPid -Ports @([int]$webUiPort, [int]$vllmPort)
  if ($resolvedTunnelPid) {
    $listenerProcessIds = @($resolvedTunnelPid)
  }
}

if (-not $listenerProcessIds -or $listenerProcessIds.Count -ne 1) {
  throw "Tunnel listener PID could not be determined cleanly."
}

Set-Content -Path $pidPath -Value $listenerProcessIds[0]

Write-Host "Started tunnel process PID $($listenerProcessIds[0])"
Write-Host "Open WebUI: http://127.0.0.1:$webUiPort"
Write-Host "vLLM: http://127.0.0.1:$vllmPort/v1/models"
