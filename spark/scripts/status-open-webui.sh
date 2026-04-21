#!/usr/bin/env bash
set -euo pipefail

URL="http://127.0.0.1:${WEBUI_PORT:-3000}"

echo "== Open WebUI container =="
docker ps --filter name=open-webui --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

echo ""
echo "== Open WebUI HTTP =="
if command -v curl >/dev/null 2>&1; then
  curl -IfsS "$URL" || echo "Open WebUI unreachable"
else
  echo "curl not available"
fi
