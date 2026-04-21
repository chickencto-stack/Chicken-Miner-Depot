[CmdletBinding()]
param()

Get-PSDrive -PSProvider FileSystem |
    Sort-Object Used -Descending |
    Select-Object Name, @{Name='UsedGB';Expression={[math]::Round($_.Used / 1GB, 2)}}, @{Name='FreeGB';Expression={[math]::Round($_.Free / 1GB, 2)}}, Root
