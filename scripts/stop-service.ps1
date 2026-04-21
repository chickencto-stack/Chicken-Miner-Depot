[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('openWebUi', 'vllm')]
    [string]$Service,
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

$command = $serviceConfig.stopCommand
if ([string]::IsNullOrWhiteSpace($command)) {
    throw "No stop command configured for $Service"
}

& (Join-Path $PSScriptRoot "Invoke-SparkCommand.ps1") -ConfigPath $ConfigPath -Command $command
