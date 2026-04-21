#!/usr/bin/env bash
set -euo pipefail

PID="/opt/ai/run/vllm.pid"

if [[ ! -f "$PID" ]]; then
  echo "No vLLM PID file found"
  exit 0
fi

P="$(cat "$PID")"
if kill -0 "$P" 2>/dev/null; then
  kill "$P"
  sleep 1
  kill -0 "$P" 2>/dev/null && kill -9 "$P"
  echo "Stopped vLLM PID $P"
else
  echo "PID $P not running"
fi

rm -f "$PID"
