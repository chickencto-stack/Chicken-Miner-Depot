[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('openWebUi', 'vllm')]
    [string]$Service,
    [switch]$Execute,
    [string]$ConfigPath
)

if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
    $ConfigPath = Join-Path $PSScriptRoot "..\config\services.local.json"
}

$config = & (Join-Path $PSScriptRoot "Get-FleetConfig.ps1") -Path $ConfigPath
$serviceConfig = $config.services.$Service

if (-not $serviceConfig) {
    throw "Unknown service key: $Service"
}

$command = $serviceConfig.restartCommand
if ([string]::IsNullOrWhiteSpace($command)) {
    throw "No restart command configured for $Service"
}

if (-not $Execute) {
    Write-Host "Restart command for $($serviceConfig.label):" -ForegroundColor Cyan
    Write-Host $command
    Write-Host "Use -Execute to run this over SSH against Spark."
    return
}

& (Join-Path $PSScriptRoot "Invoke-SparkCommand.ps1") -ConfigPath $ConfigPath -Command $command
