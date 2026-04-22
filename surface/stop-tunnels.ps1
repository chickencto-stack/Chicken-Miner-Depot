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

if (Test-Path $ConfigPath) {
  $config = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
  $listenerPorts = @([int]$config.surface.localOpenWebUiPort, [int]$config.surface.localVllmPort)
}

if (-not (Test-Path $pidPath)) {
  if ($listenerPorts.Count -gt 0) {
    $fallbackPid = Get-ExistingTunnelPid -Ports $listenerPorts
    if ($fallbackPid) {
      Stop-Process -Id $fallbackPid -Force
      Write-Host "Stopped tunnel process PID $fallbackPid"
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
  if ($listenerPorts.Count -gt 0) {
    $fallbackPid = Get-ExistingTunnelPid -Ports $listenerPorts
    if ($fallbackPid) {
      Set-Content -Path $pidPath -Value $fallbackPid
      Stop-Process -Id $fallbackPid -Force
      Remove-Item -Path $pidPath -Force
      Write-Host "Stopped tunnel process PID $fallbackPid"
      return
    }
  }

  Remove-Item -Path $pidPath -Force
  Write-Host "Tunnel process $pidValue not running. Removed PID file."
  return
}

if ($process.ProcessName -ne "ssh") {
  Remove-Item -Path $pidPath -Force
  throw "Tunnel PID file points to non-ssh process $($process.ProcessName) ($pidValue)."
}

Stop-Process -Id $process.Id -Force
Remove-Item -Path $pidPath -Force
Write-Host "Stopped tunnel process PID $($process.Id)"
