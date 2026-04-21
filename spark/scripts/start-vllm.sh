#!/usr/bin/env bash
set -euo pipefail

MODEL="${VLLM_MODEL:-/opt/ai/models/26b-awq}"
PORT="${VLLM_PORT:-8000}"
GPU_UTIL="${VLLM_GPU_UTIL:-0.90}"
MAX_LEN="${VLLM_MAX_LEN:-8192}"
LOG="/opt/ai/logs/vllm.log"
PID="/opt/ai/run/vllm.pid"

mkdir -p /opt/ai/logs /opt/ai/run

if [[ -f "$PID" ]] && kill -0 "$(cat "$PID")" 2>/dev/null; then
  echo "vLLM already running (PID $(cat "$PID"))"
  exit 0
fi

nohup python3 -m vllm.entrypoints.openai.api_server \
  --model "$MODEL" \
  --host 0.0.0.0 \
  --port "$PORT" \
  --gpu-memory-utilization "$GPU_UTIL" \
  --max-model-len "$MAX_LEN" \
  > "$LOG" 2>&1 &

echo $! > "$PID"
echo "vLLM started — model=$MODEL port=$PORT pid=$(cat "$PID") log=$LOG"
