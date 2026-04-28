#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
HOOK="$ROOT/hooks/enforce-acceptance-order"

TMP_PROJECT="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP_PROJECT"
}
trap cleanup EXIT

mkdir -p \
  "$TMP_PROJECT/docs/V0.1.10-dark-token/V0.1.10-PR1"

cat >"$TMP_PROJECT/docs/V0.1.10-dark-token/V0.1.10-plan.md" <<'EOF'
# Plan

- Figma Live Design Sync
EOF

cat >"$TMP_PROJECT/docs/V0.1.10-dark-token/V0.1.10-test.md" <<'EOF'
## Detailed Test Cases

### T-001
- check

## Acceptance status (hooks)
autotest: pass
mocktest: pass
devicetest: pass
EOF

cat >"$TMP_PROJECT/docs/V0.1.10-dark-token/V0.1.10-PR1/V0.1.10-PR1-tdd-log.md" <<'EOF'
### T-001
- check
EOF

run_hook() {
  local prompt="$1"
  local output_file
  output_file="$(mktemp)"
  set +e
  printf '{"prompt":"%s"}' "$prompt" | env CLAUDE_PROJECT_DIR="$TMP_PROJECT" bash "$HOOK" >"$output_file" 2>&1
  local code=$?
  set -e
  cat "$output_file"
  rm -f "$output_file"
  set +e
  return "$code"
}

assert_ok() {
  local prompt="$1"
  local label="$2"
  if run_hook "$prompt" >/dev/null; then
    echo "  [PASS] $label"
  else
    echo "  [FAIL] $label"
    exit 1
  fi
}

assert_block() {
  local prompt="$1"
  local expected="$2"
  local label="$3"
  local output_file
  output_file="$(mktemp)"
  set +e
  run_hook "$prompt" >"$output_file" 2>&1
  local code=$?
  set -e
  if [ "$code" -ne 2 ]; then
    echo "  [FAIL] $label: expected exit 2, got $code"
    cat "$output_file"
    rm -f "$output_file"
    exit 1
  fi
  if ! rg -q "$expected" "$output_file"; then
    echo "  [FAIL] $label: missing pattern $expected"
    cat "$output_file"
    rm -f "$output_file"
    exit 1
  fi
  rm -f "$output_file"
  echo "  [PASS] $label"
}

echo "=== Test: enforce-acceptance-order trigger narrowing ==="

assert_ok "回归测试的部分写得太简单，这怎么能叫测试用例呢？也就是说，你这一次写完文档以后，我们以后可以把它加到 AutoTest 这个技能里面去。" "discussion mentioning AutoTest should pass"
assert_ok "我每次说话都被 hook 拦截了。上文里提到 mocktest 和 devicetest，但我现在只是反馈问题。" "quoted test names in discussion should pass"
assert_block "/autotest" "figma-live-sync" "slash command still blocks when next expected is figma-live-sync"
assert_block "请执行 autotest" "figma-live-sync" "imperative request still blocks when out of order"

echo "=== trigger narrowing checks passed ==="
