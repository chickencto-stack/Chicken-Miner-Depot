# Fleet Manager

Fleet Manager is a small control-plane repository for operating a remote NVIDIA Spark system from a Surface device. It is centered on practical operations: reach the box, inspect health, restart critical services, and keep a documented workflow for Open WebUI, vLLM, and Cadet presets.

## Goals

- Use the Surface as the control plane for Spark.
- Keep NVIDIA Sync as the transport and launch path.
- Use VS Code plus Codex for repo and script work.
- Keep Open WebUI usable for normal daily chat.
- Separate normal Cadet usage from RAG-scoped Cadet usage.

## Project layout

- `scripts/` operational PowerShell entry points
- `surface/` Surface-side PowerShell commands for deploy, checks, and control
- `spark/scripts/` Spark-side shell scripts deployed to `/opt/ai/scripts`
- `config/` service connection templates
- `docs/` setup and execution notes
- `.vscode/` workspace tasks for routine operations

## First steps

1. Review `config/services.local.json` and adjust host, user, ports, or paths if Spark changed.
2. Run `Fleet: Deploy Spark Scripts` to push `spark/scripts/*.sh` onto Spark.
3. Run `Fleet: Start Tunnels` to open local forwards for Open WebUI and vLLM.
4. Run `Fleet: Surface Check` to verify SSH reachability and local tunnel health.
5. Use the VS Code tasks to check service status, restart services, and tail logs against Spark.
6. Hook Open WebUI to the local OpenAI-compatible endpoint.
7. Create Cadet Alpha and Cadet Alpha RAG presets.

## Workflow split

- Window 1: chat and planning
- Window 2: NVIDIA Sync terminal for direct Spark control
- Window 3: VS Code and Codex for repo changes

## Notes

The default Cadet preset should stay free of attached knowledge. Use a separate RAG-specific preset when you intentionally want answers constrained to attached documents.

Remote operations are SSH-backed. NVIDIA Sync remains the preferred transport path, but the scripts in this repo can execute the same commands directly once your Surface can reach Spark over SSH.

The current defaults target Spark at `10.0.0.27` with user `childs`, matching the existing Surface helpers in this repo.

For local browser and client access on the Surface, `Fleet: Start Tunnels` forwards local ports `13000 -> 3000` and `18000 -> 8000`, and `Fleet: Stop Tunnels` tears those forwards down.
