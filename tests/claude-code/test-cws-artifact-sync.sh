#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$SCRIPT_DIR/../.."
# shellcheck source=/dev/null
. "$ROOT/hooks/acceptance-order-common"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
git -C "$TMP" init -q -b main
mkdir -p "$TMP/app/plugin/features"
printf 'v1\n' > "$TMP/app/plugin/features/a.ts"
git -C "$TMP" add . && git -C "$TMP" -c user.email=t@test -c user.name=t commit -q -m init
printf 'v2\n' > "$TMP/app/plugin/features/a.ts"
git -C "$TMP" add app/plugin/features/a.ts
git -C "$TMP" -c user.email=t@test -c user.name=t commit -q -m src
if plugin_output_covers_source_tip "$TMP"; then echo "FAIL stale"; exit 1; else echo "PASS stale"; fi
mkdir -p "$TMP/app/plugin/.output/chrome-mv3"
printf '{"version":"0.1.14.1"}' > "$TMP/app/plugin/.output/chrome-mv3/manifest.json"
printf "BASE_VERSION = '0.1.14'\n" > "$TMP/app/plugin/wxt.config.ts"
git -C "$TMP" add app/plugin/.output app/plugin/wxt.config.ts
git -C "$TMP" -c user.email=t@test -c user.name=t commit -q -m out
plugin_output_covers_source_tip "$TMP" || { echo "FAIL fresh"; exit 1; }
echo "PASS fresh"
