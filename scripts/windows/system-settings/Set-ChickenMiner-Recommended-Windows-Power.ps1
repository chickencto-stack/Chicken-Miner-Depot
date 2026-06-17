param([switch]$Apply,[switch]$KeepDisplayOn)
"=== CHICKEN MINER RECOMMENDED WINDOWS POWER SETTINGS ==="
"APPLY=$([bool]$Apply)"
powercfg /GETACTIVESCHEME
if(-not $Apply){
  "DRY_RUN=True"
  "Would enable Ultimate Performance if available, otherwise High Performance."
  "Would set plugged-in sleep timeout to never."
  "Would set plugged-in hibernate timeout to never."
  if($KeepDisplayOn){ "Would set plugged-in display timeout to never." }
  return
}
$ultimateGuid = "e9a42b02-d5df-448d-aa00-03f14749eb61"
$highPerfGuid = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
$dup = powercfg -duplicatescheme $ultimateGuid 2>&1
$schemeGuid = $null
if(($dup -join "`n") -match "([a-fA-F0-9-]{36})"){ $schemeGuid = $Matches[1] }
if($schemeGuid){ powercfg /S $schemeGuid } else { powercfg /S $highPerfGuid }
powercfg -change -standby-timeout-ac 0
powercfg -change -hibernate-timeout-ac 0
if($KeepDisplayOn){ powercfg -change -monitor-timeout-ac 0 }
"CHICKEN_POWER_SETTINGS_COMPLETE=True"
"DEFENDER_MODIFIED=False"
"UAC_MODIFIED=False"
"FIREWALL_MODIFIED=False"
"NETWORK_SHARING_MODIFIED=False"
