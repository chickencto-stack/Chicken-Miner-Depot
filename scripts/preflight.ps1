[CmdletBinding()]
param(
    [string]$ConfigPath,
    [string]$ExpectedModelId
)

if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
    $ConfigPath = Join-Path $PSScriptRoot "..\config\services.local.json"
}

$config = & (Join-Path $PSScriptRoot "Get-FleetConfig.ps1") -Path $ConfigPath

if ([string]::IsNullOrWhiteSpace($ExpectedModelId)) {
    $ExpectedModelId = $config.services.vllm.defaultModelId
}

if ([string]::IsNullOrWhiteSpace($ExpectedModelId)) {
    $ExpectedModelId = "/models/26b"
}

$results = @()
$hasFailures = $false

function Add-Result {
    param(
        [string]$Check,
        [bool]$Ok,
        [string]$Details
    )

    $script:results += [pscustomobject]@{
        Check = $Check
        Ok = $Ok
        Details = $Details
    }

    if (-not $Ok) {
        $script:hasFailures = $true
    }
}

try {
    $sshOk = Test-NetConnection -ComputerName $config.spark.host -Port $config.spark.sshPort -InformationLevel Quiet -WarningAction SilentlyContinue
    Add-Result -Check "Spark SSH reachable" -Ok ([bool]$sshOk) -Details "$($config.spark.sshUser)@$($config.spark.host):$($config.spark.sshPort)"
}
catch {
    Add-Result -Check "Spark SSH reachable" -Ok $false -Details $_.Exception.Message
}

foreach ($check in @(
    @{ Name = "Open WebUI direct"; Url = $config.services.openWebUi.healthUrl },
    @{ Name = "vLLM direct"; Url = $config.services.vllm.healthUrl },
    @{ Name = "Open WebUI tunnel"; Url = $config.services.openWebUi.tunneledHealthUrl },
    @{ Name = "vLLM tunnel"; Url = $config.services.vllm.tunneledHealthUrl }
)) {
    try {
        $response = Invoke-WebRequest -Uri $check.Url -Method Get -TimeoutSec 10
        Add-Result -Check $check.Name -Ok $true -Details "HTTP $($response.StatusCode)"
    }
    catch {
        Add-Result -Check $check.Name -Ok $false -Details $_.Exception.Message
    }
}

function Test-ModelList {
    param(
        [string]$Name,
        [string]$Url,
        [string]$Expected
    )

    try {
        $json = Invoke-RestMethod -Uri $Url -Method Get -TimeoutSec 10
        $ids = @($json.data | ForEach-Object { $_.id })
        $hasExpected = $ids -contains $Expected
        Add-Result -Check $Name -Ok $hasExpected -Details ("found=" + (($ids -join ", ") -replace "^$", "none") + "; expected=$Expected")
    }
    catch {
        Add-Result -Check $Name -Ok $false -Details $_.Exception.Message
    }
}

Test-ModelList -Name "vLLM direct default model" -Url $config.services.vllm.healthUrl -Expected $ExpectedModelId
Test-ModelList -Name "vLLM tunnel default model" -Url $config.services.vllm.tunneledHealthUrl -Expected $ExpectedModelId

$results | Format-Table -AutoSize

if ($hasFailures) {
    exit 1
}
