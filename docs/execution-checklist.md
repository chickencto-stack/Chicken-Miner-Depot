# Fleet Manager Execution Checklist

## Order of operations

1. Surface control plane
2. Spark connectivity through NVIDIA Sync
3. Service control scripts
4. Open WebUI admin and provider hookup
5. Cadet Alpha preset
6. Cadet Alpha RAG preset
7. Daily-use validation run

## Surface control plane

- Install NVIDIA Sync on the Surface.
- Install VS Code on the Surface.
- Install the Codex extension in VS Code.
- Confirm Spark has completed first-boot setup and is reachable on the network.
- Add Spark to NVIDIA Sync.
- Verify SSH terminal launch from Sync.
- Verify VS Code launch from Sync into the Spark workspace.

## Service control scripts

- Model health check
- vLLM start or restart
- Open WebUI start or restart
- Disk usage check
- Logs tail
- Port and tunnel shortcuts for Open WebUI and vLLM

## Open WebUI and Cadet

- Create the first Open WebUI account and use it as admin.
- Connect Open WebUI to the local OpenAI-compatible endpoint.
- Verify one plain chat works.
- Create Cadet Alpha as the default preset with no attached knowledge.
- Create Cadet Alpha RAG for document-grounded use only.

## Done criteria

- Spark is reachable from Surface through NVIDIA Sync.
- Terminal and VS Code launch cleanly.
- Health and restart actions exist for core services.
- Open WebUI admin login works.
- Local model connection works.
- Cadet Alpha and Cadet Alpha RAG both work as intended.
- A normal work session can stay local without immediate fallback.
