#!/usr/bin/env bash
set -euo pipefail
docker rm -f open-webui >/dev/null 2>&1 || true
echo "Open WebUI stopped"
