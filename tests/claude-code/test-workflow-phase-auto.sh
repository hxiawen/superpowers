#!/usr/bin/env bash
# Test: workflow-phase-auto maintains .superpowers/workflow-phase from prompts.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
HOOK="$ROOT/hooks/workflow-phase-auto"

TMP_BASE="$(cd "$SCRIPT_DIR/../.." && pwd)/.tmp-wf-bootstrap-tests"
mkdir -p "$TMP_BASE"
TMP="$(mktemp -d "$TMP_BASE/phase-auto.XXXXXX")"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

run_hook() {
  local dir="$1" payload="$2"
  printf '%s' "$payload" | CLAUDE_PROJECT_DIR="$dir" bash "$HOOK" >/dev/null 2>&1 || true
}

assert_file_contains() {
  local f="$1" needle="$2" label="$3"
  if head -n 1 "$f" | rg -q "$needle" 2>/dev/null; then
    echo "  [PASS] $label"
  else
    echo "  [FAIL] $label (expected first line match in $f)"
    cat "$f" 2>/dev/null || true
    exit 1
  fi
}

echo "=== Test: workflow-phase-auto ==="

git -C "$TMP" init -b main -q
git -C "$TMP" config user.email t@t && git -C "$TMP" config user.name t
echo x >"$TMP/README.md" && git -C "$TMP" add . && git -C "$TMP" commit -qm init

run_hook "$TMP" '{"prompt":"我们在做插件 pv0.1.13 的 brainstorming，先对齐体验"}'
assert_file_contains "$TMP/.superpowers/workflow-phase" '^brainstorming' "recap-style pv + brainstorming"

run_hook "$TMP" '{"prompt":"开始 writing-plans，补全 PR 脚手架"}'
assert_file_contains "$TMP/.superpowers/workflow-phase" '^writing-plans' "upgrade to writing-plans"

printf '%s\n' 'writing-plans' >"$TMP/.superpowers/workflow-phase"
run_hook "$TMP" '{"prompt":"invoke brainstorming skill"}'
if head -n 1 "$TMP/.superpowers/workflow-phase" | rg -q '^writing-plans'; then
  echo "  [PASS] downgrade to brainstorming blocked without explicit return"
else
  echo "  [FAIL] expected writing-plans preserved"
  cat "$TMP/.superpowers/workflow-phase"
  exit 1
fi

run_hook "$TMP" '{"prompt":"回到 brainstorming，推翻上一版假设"}'
assert_file_contains "$TMP/.superpowers/workflow-phase" '^brainstorming' "explicit return allows downgrade"

echo ""
echo "=== workflow-phase-auto checks passed ==="
