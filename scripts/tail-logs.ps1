[CmdletBinding()]
param(
    [string]$Path,
    [int]$Tail = 50
)

if ([string]::IsNullOrWhiteSpace($Path)) {
    $Path = Join-Path $PSScriptRoot "..\logs\fleet-manager.log"
}

if (-not (Test-Path $Path)) {
    throw "Log file not found: $Path"
}

Get-Content -Path $Path -Tail $Tail -Wait
