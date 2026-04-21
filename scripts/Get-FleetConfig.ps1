param(
    [string]$Path
)

if ([string]::IsNullOrWhiteSpace($Path)) {
    $Path = Join-Path $PSScriptRoot "..\config\services.local.json"
}

if (-not (Test-Path $Path)) {
    $samplePath = Join-Path $PSScriptRoot "..\config\services.sample.json"
    throw "Config file not found: $Path. Copy $samplePath to services.local.json and update it."
}

Get-Content -Path $Path -Raw | ConvertFrom-Json
