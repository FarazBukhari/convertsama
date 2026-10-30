#!/usr/bin/env bash
# Bundle ConvertSama, quit any running instance, launch the fresh build.
# Usage: scripts/run.sh [debug|release]
set -euo pipefail
cd "$(dirname "$0")/.."

scripts/bundle.sh "${1:-debug}"
if pgrep -x ConvertSama >/dev/null; then
  osascript -e 'tell application id "com.farazbukhari.convertsama" to quit' >/dev/null 2>&1 || pkill -x ConvertSama || true
  for _ in {1..20}; do pgrep -x ConvertSama >/dev/null || break; sleep 0.25; done
fi
open build/ConvertSama.app
