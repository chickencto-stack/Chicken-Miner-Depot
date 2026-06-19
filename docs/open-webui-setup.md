# Open WebUI Setup

## Initial admin path

- Local Open WebUI URL: `http://127.0.0.1:13000`
- Local vLLM OpenAI-compatible URL: `http://127.0.0.1:18000/v1`

1. Start Open WebUI.
2. Create the first account.
3. Use that account as the admin account.
4. Confirm one plain chat works before adding Cadet-specific presets.

## Model connection

- The repo-managed Spark startup script wires Open WebUI to `gemma-vllm:8000` on `owui-net` by default.
- Open Admin Settings and confirm the model already appears.
- If it does not, go to Connections and add the local OpenAI-compatible endpoint used by your vLLM-backed model lane.
- Confirm the model appears and completes a basic chat.

## Cadet presets

### Cadet Alpha

- Use this as the daily preset.
- Apply the Cadet Alpha system prompt.
- Keep it free of attached knowledge by default.

### Cadet Alpha RAG

- Use this only for intentional document-grounded work.
- Attach knowledge only to this preset or flow.

## Validation

- Run 5 normal chats through Cadet Alpha.
- Run 2 document-grounded tests through Cadet Alpha RAG.
- Note where it feels weaker or better than cloud chat.
- During the first week, capture friction immediately in `docs/friction-log.html` and review the weekly export before making workflow changes.

## Supporting files in this repo

- `docs/cadet-activation-checklist.md` for the full operator checklist.
- `docs/cadet-alpha-prompt-template.md` for storing the real Cadet Alpha prompt text.
- `docs/friction-log.html` for one-week rolling friction capture and export.
