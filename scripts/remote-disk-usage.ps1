[CmdletBinding()]
param(
    [string]$ConfigPath
)

if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
    $ConfigPath = Join-Path $PSScriptRoot "..\config\services.local.json"
}

& (Join-Path $PSScriptRoot "Invoke-SparkCommand.ps1") -ConfigPath $ConfigPath -Command "df -h"
