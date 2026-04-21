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
$commandPath = Join-Path $runtimeDir "surface-tunnels.cmd"
$hostName = $config.spark.host
$userName = $config.spark.sshUser
$port = [string]$config.spark.sshPort
$webUiPort = [string]$config.surface.localOpenWebUiPort
$vllmPort = [string]$config.surface.localVllmPort

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

$arguments = @(
  "-N",
  "-L", "$webUiPort:127.0.0.1:3000",
  "-L", "$vllmPort:127.0.0.1:8000",
  "-p", $port,
  "$userName@$hostName"
)

$sshCommand = "ssh {0}" -f (($arguments | ForEach-Object {
  if ($_ -match '\s') {
    '"{0}"' -f $_
  }
  else {
    $_
  }
}) -join ' ')

Set-Content -Path $commandPath -Value "@echo off`r`n$sshCommand`r`n" -NoNewline

$process = Start-Process -FilePath "powershell" -ArgumentList @(
  "-NoExit",
  "-ExecutionPolicy", "Bypass",
  "-Command", "& '$commandPath'"
) -PassThru
Set-Content -Path $pidPath -Value $process.Id
Write-Host "Started tunnel window PID $($process.Id)"
Write-Host "Open WebUI: http://127.0.0.1:$webUiPort"
Write-Host "vLLM: http://127.0.0.1:$vllmPort/v1/models"
Write-Host "If prompted, enter the Spark SSH password in the new window."
