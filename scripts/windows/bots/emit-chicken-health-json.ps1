param([string]$OutputPath = "$env:TEMP\chicken-miner-health.json")
$procs = @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object { "$($_.Name) $($_.ExecutablePath) $($_.CommandLine)" -match "chkn|chicken|chickenminer" })
$result = [ordered]@{
  updated_utc = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
  host = $env:COMPUTERNAME
  platform = "windows"
  miner_process_found = ($procs.Count -gt 0)
  miner_process_count = $procs.Count
  status = if($procs.Count -gt 0){"PROCESS_FOUND"}else{"NO_PROCESS_FOUND"}
}
$json = $result | ConvertTo-Json -Depth 8
Set-Content -LiteralPath $OutputPath -Value $json -Encoding UTF8 -Force
$json
"HEALTH_JSON=$OutputPath"
