# Chicken Miner Depot

Windows Chicken Miner v1.4.3 release package.

## Packages

Standalone installer:

packages/windows/standalone/ChickenMiner-Windows-v1.4.3-Standalone-Installer.zip

Full package with bots, thermal status, and recommended power settings:

packages/windows/full/ChickenMiner-Windows-v1.4.3-Bots-Thermal-Power.zip

## Included

- Windows Chicken Miner v1.4.3 standalone installer ZIP
- Full Windows package with installer, bots, thermal status, and power settings helper
- Windows watcher bot scripts
- Health JSON schema
- Install-agent prompt
- Commit-agent prompt

## Excluded

- Private fleet or deployment artifacts
- Host proof
- Machine-specific configs
- Credentials, tokens, private keys, wallet or pool configuration
- Defender exclusion automation
- UAC-disable logic

## Bot Knowledge Graph

The Windows v1.4.3 full bot package includes a bot-readable knowledge graph:

knowledge-graphs/chicken-miner-windows-v1.4.3-bot-package.kg.json

The full ZIP also embeds the knowledge graph and KG package agent prompt so an authorized bot can read the install sequence, package contents, monitoring skills, validation outputs, and public safety boundaries from inside the package.
