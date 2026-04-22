# Cadet Activation Checklist

## Preconditions

- `Fleet: Start Tunnels` is running.
- `Fleet: Surface Check` returns success for Open WebUI and vLLM.
- Open WebUI is reachable at `http://127.0.0.1:13000`.

## Open WebUI admin setup

1. Open `http://127.0.0.1:13000`.
2. Create the first account.
3. Verify that first account is the admin account.
4. Complete one plain chat before changing any settings.

## Model provider setup

1. Open Admin Settings.
2. Verify the local model already appears in the model list.
3. Run one plain completion test.
4. Only if the model is missing, open Connections.
5. Add the OpenAI-compatible endpoint `http://127.0.0.1:18000/v1` as a fallback check path.

## Cadet Alpha preset

1. Open Prompts or model preset settings.
2. Create `Cadet Alpha`.
3. Paste your Cadet Alpha system prompt.
4. Do not attach knowledge sources.
5. Save and run 5 normal chats.

## Cadet Alpha RAG preset

1. Create `Cadet Alpha RAG`.
2. Paste the same base system prompt if desired.
3. Attach only the knowledge sources for intentional document-grounded work.
4. Run 2 document-grounded chats.

## Validation notes

- Record where local Cadet is already good enough for daily work.
- Record where you still fall back to cloud chat.
- Keep the default Cadet preset non-RAG.
- If the model disappears after a container restart, restart Open WebUI from the repo-managed script path before changing admin settings.
