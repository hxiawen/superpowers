#!/usr/bin/env bash
# Test: spec-change-confirm updates the status file for real user confirmations.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
HOOK_PATH="$ROOT/hooks/spec-change-confirm"

echo "=== Test: spec change confirmation hook ==="
echo ""

if [ ! -f "$HOOK_PATH" ]; then
    echo "[FAIL] Hook missing: $HOOK_PATH"
    exit 1
fi

TMP_DIR="$(mktemp -d)"
cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

STATUS_FILE="$TMP_DIR/.claude/.spec-change-status"
mkdir -p "$TMP_DIR/.claude"

assert_status() {
    local expected="$1"
    local name="$2"
    local actual

    actual="$(tr -d '[:space:]' < "$STATUS_FILE" 2>/dev/null || true)"
    if [ "$actual" = "$expected" ]; then
        echo "  [PASS] $name"
    else
        echo "  [FAIL] $name"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
        exit 1
    fi
}

printf 'needs_confirm\n' > "$STATUS_FILE"
printf 'confirm spec change\n' | CLAUDE_PROJECT_DIR="$TMP_DIR" bash "$HOOK_PATH" >/dev/null
assert_status "confirmed" "plain text confirmation unlocks spec change gate"

printf 'needs_confirm\n' > "$STATUS_FILE"
printf '%s\n' '{"payload":{"text":"confirm spec change"}}' | CLAUDE_PROJECT_DIR="$TMP_DIR" bash "$HOOK_PATH" >/dev/null
assert_status "confirmed" "nested payload confirmation unlocks spec change gate"

printf 'needs_confirm\n' > "$STATUS_FILE"
printf '%s\n' '{"message":"please continue"}' | CLAUDE_PROJECT_DIR="$TMP_DIR" bash "$HOOK_PATH" >/dev/null
assert_status "needs_confirm" "non-confirmation input does not unlock spec change gate"

echo ""
echo "=== spec change confirmation hook checks passed ==="
