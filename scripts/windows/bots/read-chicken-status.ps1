param([string]$StatusRoot = "C:\ProgramData\ChickenMiner")
"=== CHICKEN MINER LOCAL STATUS ==="
"STATUS_ROOT=$StatusRoot"
foreach($name in @("status.json","health.json","thread-control.json","miner-status.json")){
  $p = Join-Path $StatusRoot $name
  if(Test-Path -LiteralPath $p){
    "STATUS_FILE_FOUND=$p"
    Get-Content -LiteralPath $p -Raw
  }
}
"CHICKEN_STATUS_READ_COMPLETE=True"
