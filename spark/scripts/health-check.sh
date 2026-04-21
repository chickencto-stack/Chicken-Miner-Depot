#!/usr/bin/env bash
set -euo pipefail

echo "== host =="
hostname
whoami
date -Iseconds

echo ""
echo "== gpu =="
nvidia-smi --query-gpu=name,driver_version,memory.total,memory.used --format=csv,noheader

echo ""
echo "== disk =="
df -h /opt /tmp 2>/dev/null || df -h /

echo ""
echo "== python =="
python3 --version 2>/dev/null || echo "python3 not found"

echo ""
echo "== docker =="
docker --version 2>/dev/null || echo "docker not found"

echo ""
echo "== listening ports =="
ss -tulpn 2>/dev/null | grep -E '(:22|:3000|:8000|:11434)' || echo "none on watched ports"
