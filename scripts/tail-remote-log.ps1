[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('openWebUi', 'vllm')]
    [string]$Service,
    [int]$Tail = 100,
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

$logPath = $serviceConfig.logPath
if ([string]::IsNullOrWhiteSpace($logPath)) {
    throw "No logPath configured for $Service"
}

$command = "tail -n $Tail -f $logPath"
& (Join-Path $PSScriptRoot "Invoke-SparkCommand.ps1") -ConfigPath $ConfigPath -Command $command
