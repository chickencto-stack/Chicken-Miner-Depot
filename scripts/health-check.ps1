[CmdletBinding()]
param(
    [string]$ConfigPath
)

if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
    $ConfigPath = Join-Path $PSScriptRoot "..\config\services.local.json"
}

$config = & (Join-Path $PSScriptRoot "Get-FleetConfig.ps1") -Path $ConfigPath

$checks = @(
    @{ Name = $config.services.openWebUi.label; Url = $config.services.openWebUi.healthUrl },
    @{ Name = $config.services.vllm.label; Url = $config.services.vllm.healthUrl }
)

foreach ($check in $checks) {
    try {
        $response = Invoke-WebRequest -Uri $check.Url -Method Get -TimeoutSec 10
        [pscustomobject]@{
            Service = $check.Name
            Url = $check.Url
            Status = $response.StatusCode
            Ok = $true
        }
    }
    catch {
        [pscustomobject]@{
            Service = $check.Name
            Url = $check.Url
            Status = $_.Exception.Message
            Ok = $false
        }
    }
}
