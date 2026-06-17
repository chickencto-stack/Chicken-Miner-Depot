param([string]$OutputPath = "")
$cpu = Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1
$os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
$power = powercfg /GETACTIVESCHEME 2>$null
$zones = @(Get-CimInstance -Namespace root/wmi -ClassName MSAcpi_ThermalZoneTemperature -ErrorAction SilentlyContinue)
$result = [ordered]@{
  updated_utc = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
  host = $env:COMPUTERNAME
  platform = "windows"
  cpu_name = if($cpu){$cpu.Name}else{$null}
  cpu_load_percent = if($cpu){$cpu.LoadPercentage}else{$null}
  logical_processors = if($cpu){$cpu.NumberOfLogicalProcessors}else{$null}
  memory_free_mb = if($os){[math]::Round($os.FreePhysicalMemory / 1024,0)}else{$null}
  active_power_scheme = ($power -join "`n")
  thermal_zone_count = $zones.Count
  note = "Windows may not expose CPU package temperature through built-in WMI on all hardware."
}
$json = $result | ConvertTo-Json -Depth 8
if($OutputPath){ Set-Content -LiteralPath $OutputPath -Value $json -Encoding UTF8 -Force }
$json
