#!/usr/bin/env bash
set -euo pipefail

docker logs --tail 100 -f open-webui
