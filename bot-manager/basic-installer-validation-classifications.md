# Bot-Manager Basic Installer Validation Classifications

BOT_MANAGER_BASIC_INSTALLER_VALIDATION_PASS - required files, checksums, manifest, docs, and scope are valid.
BOT_MANAGER_BASIC_INSTALLER_SCOPE_FAIL - out-of-scope artifacts are present.
BOT_MANAGER_BASIC_INSTALLER_CHECKSUM_FAIL - checksum file is missing, malformed, or incomplete.
BOT_MANAGER_BASIC_INSTALLER_SECRET_FAIL - secret, key, .env, live config, wallet mapping, user mapping, or unredacted log is present.
BOT_MANAGER_BASIC_INSTALLER_DOCS_FAIL - required docs are missing.
BOT_MANAGER_BASIC_INSTALLER_BLOCKED - validation cannot complete.
INTENT_DRIFT_DETECTED - task expanded into blocked actions.

Gate rule: validation PASS does not authorize merge, release, deployment, installer execution, or miner runtime.
