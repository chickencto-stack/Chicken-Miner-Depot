#!/usr/bin/env bash
set -euo pipefail

PID="/opt/ai/run/vllm.pid"
URL="http://127.0.0.1:${VLLM_PORT:-8000}/v1/models"

echo "== vLLM process =="
if [[ -f "$PID" ]] && kill -0 "$(cat "$PID")" 2>/dev/null; then
  echo "running pid=$(cat "$PID")"
else
  echo "not running"
fi

echo ""
echo "== vLLM API =="
if command -v curl >/dev/null 2>&1; then
  curl -fsS "$URL" || echo "vLLM API unreachable"
else
  echo "curl not available"
fi
