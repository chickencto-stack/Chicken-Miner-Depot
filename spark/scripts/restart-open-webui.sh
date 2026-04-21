#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "$DIR/stop-open-webui.sh"
bash "$DIR/start-open-webui.sh"
