# Installation

## Standalone

Download and extract:

packages/windows/standalone/ChickenMiner-Windows-v1.4.3-Standalone-Installer.zip

Run:

.\ChKn_miner_installer_x64.exe

## Full package

Download and extract:

packages/windows/full/ChickenMiner-Windows-v1.4.3-Bots-Thermal-Power.zip

Run installer:

.\ChKn_miner_installer_x64.exe

Run watcher:

powershell -ExecutionPolicy Bypass -File .\scripts\bots\watch-chicken-miner.ps1

Run thermal status:

powershell -ExecutionPolicy Bypass -File .\scripts\thermal\chicken-windows-thermal-status.ps1

Preview power settings:

powershell -ExecutionPolicy Bypass -File .\scripts\system-settings\Set-ChickenMiner-Recommended-Windows-Power.ps1

Apply power settings only if approved:

powershell -ExecutionPolicy Bypass -File .\scripts\system-settings\Set-ChickenMiner-Recommended-Windows-Power.ps1 -Apply
