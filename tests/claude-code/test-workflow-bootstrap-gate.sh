#!/usr/bin/env bash
# Test: workflow-bootstrap-gate — main exemptions (No.8), feat/pv branch shape, block JSON on violations.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
HOOK="$ROOT/hooks/workflow-bootstrap-gate"

echo "=== Test: workflow-bootstrap-gate ==="

assert_exit() {
  local project_dir="$1"
  local payload="$2"
  local want="$3"
  local label="$4"
  local code
  set +e
  printf '%s' "$payload" | CLAUDE_PROJECT_DIR="$project_dir" bash "$HOOK" >/dev/null 2>&1
  code=$?
  set -e
  if [ "$code" -eq "$want" ]; then
    echo "  [PASS] $label (exit $code)"
  else
    echo "  [FAIL] $label (expected exit $want, got $code)"
    printf '%s' "$payload" | CLAUDE_PROJECT_DIR="$project_dir" bash "$HOOK" 2>&1 || true
    exit 1
  fi
}

assert_json_block() {
  local project_dir="$1"
  local payload="$2"
  local label="$3"
  local out code
  set +e
  out="$(printf '%s' "$payload" | CLAUDE_PROJECT_DIR="$project_dir" bash "$HOOK" 2>&1)"
  code=$?
  set -e
  if [ "$code" -ne 2 ]; then
    echo "  [FAIL] $label (expected exit 2, got $code)"
    echo "$out"
    exit 1
  fi
  if printf '%s' "$out" | rg -q '"decision":"block"'; then
    echo "  [PASS] $label (blocked JSON)"
  else
    echo "  [FAIL] $label (missing block JSON)"
    echo "$out"
    exit 1
  fi
}

TMP_BASE="$(cd "$SCRIPT_DIR/../.." && pwd)/.tmp-wf-bootstrap-tests"
mkdir -p "$TMP_BASE"
TMP="$(mktemp -d "$TMP_BASE/wf-test.XXXXXX")"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

git_init_main() {
  mkdir -p "$1"
  git -C "$1" init -b main >/dev/null 2>&1
  git -C "$1" config user.email "test@test" && git -C "$1" config user.name "test"
  printf 'x\n' >"$1/README.md"
  git -C "$1" add README.md && git -C "$1" commit -m init >/dev/null 2>&1
}

git_init_main "$TMP/m1"
assert_exit "$TMP/m1" '{"prompt":"帮我修改 .superpowers/project2feedback.md 追加一条反馈"}' 0 "main + feedback / superpowers path intent"

git_init_main "$TMP/m2"
assert_json_block "$TMP/m2" '{"prompt":"帮我实现 plugin 登录功能并改 app/plugin 代码"}' "main + plugin implementation intent"

git_init_main "$TMP/m3"
mkdir -p "$TMP/m3/.superpowers"
printf 'y\n' >"$TMP/m3/.superpowers/note.txt"
git -C "$TMP/m3" add .superpowers/note.txt
assert_exit "$TMP/m3" '{"prompt":"帮我修改一下东西"}' 0 "main + whitelist-only workspace (no narrow intent needed)"

git_init_main "$TMP/m4"
assert_exit "$TMP/m4" '{"prompt":"调整一下，改为 顶部对齐。但如果有引用，则与引用首行对齐。"}' 0 "main + layout/brainstorm wording (adjust一下 + 对齐/引用)"

git_init_main "$TMP/m5"
mkdir -p "$TMP/m5/.superpowers"
printf '%s\n' 'brainstorming' >"$TMP/m5/.superpowers/workflow-phase"
assert_exit "$TMP/m5" '{"prompt":"优化一下默认选项的交互流程，先定产品规则"}' 0 "main + workflow-phase brainstorming (no code keywords)"

git_init_main "$TMP/m6"
mkdir -p "$TMP/m6/.superpowers"
printf '%s\n' 'brainstorming' >"$TMP/m6/.superpowers/workflow-phase"
assert_json_block "$TMP/m6" '{"prompt":"帮我改 src/index.ts 实现登录"}' "main + phase file but hard implementation (src/) still blocks"

mkdir -p "$TMP/f1/docs"
git_init_main "$TMP/f1"
git -C "$TMP/f1" checkout -b feat/pv0.1.0-bootstrap-hook-test >/dev/null 2>&1
assert_json_block "$TMP/f1" '{"prompt":"帮我实现一个需求"}' "feat/pv branch without version dir (expect scaffold block)"

echo ""
echo "=== workflow-bootstrap-gate checks passed ==="
