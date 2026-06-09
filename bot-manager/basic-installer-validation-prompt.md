# Bot-Manager Basic Installer Validation Prompt

Validate Chicken Miner basic Windows/macOS installer depot updates only.

Required files:
- packages/windows/chicken-miner-apex-installer-windows-standalone.zip
- packages/macos/chicken-miner-apex-installer-macos-standalone.zip
- checksums/SHA256SUMS.txt
- manifests/basic-installers-manifest.json
- README.md
- INSTALLATION.md
- CONFIG-PRESERVATION.md
- SECURITY.md
- RELEASE_NOTES.md
- validation/basic-installers-scope.md

Fail on .env, live config.json, secrets, keys, wallet mappings, user mappings, unredacted logs, or out-of-scope Linux/CUDA/EVO/Houston/M7ultra/NUCI8/fleet artifacts.

Never authorize installer execution, miner runtime, deployment, Docker, service mutation, firewall mutation, Tailscale mutation, machine-auth mutation, GitHub Release publishing, direct main push, or secret access.

Return one classification only: BOT_MANAGER_BASIC_INSTALLER_VALIDATION_PASS, BOT_MANAGER_BASIC_INSTALLER_SCOPE_FAIL, BOT_MANAGER_BASIC_INSTALLER_CHECKSUM_FAIL, BOT_MANAGER_BASIC_INSTALLER_SECRET_FAIL, BOT_MANAGER_BASIC_INSTALLER_DOCS_FAIL, BOT_MANAGER_BASIC_INSTALLER_BLOCKED, or INTENT_DRIFT_DETECTED.
