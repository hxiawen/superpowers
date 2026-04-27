#!/usr/bin/env bash
# Test: user-owned stop blocks prompt once, then silently end the turn.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
HOOK="$ROOT/hooks/test-acceptance-gate"

echo "=== Test: stop gate user confirmation reminder policy ==="

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local name="$3"
  if printf '%s' "$haystack" | rg -q "$needle"; then
    echo "  [PASS] $name"
  else
    echo "  [FAIL] $name"
    echo "  Missing pattern: $needle"
    echo "$haystack"
    exit 1
  fi
}

PROJECT_DIR="$(mktemp -d)"
trap 'rm -rf "$PROJECT_DIR"' EXIT
mkdir -p "$PROJECT_DIR/.claude"
printf 'needs_acceptance\n' > "$PROJECT_DIR/.claude/.test-acceptance-status"
printf 'needs_confirm\n' > "$PROJECT_DIR/.claude/.spec-change-status"

set +e
first_output="$(CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" 2>&1)"
first_code=$?
second_output="$(CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" 2>&1)"
second_code=$?
set -e

if [ "$first_code" -ne 2 ] || [ "$second_code" -ne 0 ]; then
  echo "  [FAIL] stop hook should block once, then allow waiting turn to end"
  echo "  first_code=$first_code second_code=$second_code"
  exit 1
fi

assert_contains "$first_output" '"next_step":"ask_user_for_explicit_confirmation_once"' "first block asks once"
assert_contains "$first_output" '仅提醒一次' "first block reason says remind once"
if [ -n "$second_output" ]; then
  echo "  [FAIL] repeated block should end silently"
  echo "$second_output"
  exit 1
fi
echo "  [PASS] repeated block ends silently"

echo ""
echo "=== stop gate user confirmation reminder checks passed ==="
