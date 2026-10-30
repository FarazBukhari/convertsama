#!/usr/bin/env bash
# Release-build ConvertSama, sign it (SIGN_ID, default "ConvertSama Dev" if present), install to /Applications, relaunch.
# Usage: scripts/install.sh
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ -z "${SIGN_ID:-}" ]]; then
  SIGN_ID="ConvertSama Dev"
  # Keychains set up before the rename hold the old "Rondo Dev" certificate.
  security find-identity -p codesigning | grep -q "\"$SIGN_ID\"" || SIGN_ID="Rondo Dev"
fi
export SIGN_ID
scripts/bundle.sh release

# Quit the pre-rename app too: two copies would both open wheels on every drag.
for app in "ConvertSama com.farazbukhari.convertsama" "Rondo com.farazbukhari.rondo"; do
  read -r proc bid <<<"$app"
  pgrep -x "$proc" >/dev/null || continue
  osascript -e "tell application id \"$bid\" to quit" >/dev/null 2>&1 || true
  for _ in {1..40}; do pgrep -x "$proc" >/dev/null || break; sleep 0.25; done
done
ditto build/ConvertSama.app /Applications/ConvertSama.app
codesign -v /Applications/ConvertSama.app
codesign -dv /Applications/ConvertSama.app 2>&1 | grep -E "^(Authority|Signature)=" || true
open /Applications/ConvertSama.app
echo "Installed /Applications/ConvertSama.app"
