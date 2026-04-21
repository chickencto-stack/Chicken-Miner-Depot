#!/usr/bin/env bash
set -euo pipefail

VLLM_PORT="${VLLM_PORT:-8000}"
WEBUI_PORT="${WEBUI_PORT:-3000}"
CONTAINER="open-webui"

docker rm -f "$CONTAINER" >/dev/null 2>&1 || true

docker run -d \
  --name "$CONTAINER" \
  -p "$WEBUI_PORT":8080 \
  -e OPENAI_API_BASE_URL="http://127.0.0.1:$VLLM_PORT/v1" \
  -v open-webui:/app/backend/data \
  --restart unless-stopped \
  ghcr.io/open-webui/open-webui:main

echo "Open WebUI started — spark port $WEBUI_PORT"
