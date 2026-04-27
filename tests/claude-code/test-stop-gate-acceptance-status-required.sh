#!/usr/bin/env bash
# Test: stop gate blocks when ## Acceptance status (hooks) has keywords only (no pass/fail/etc.)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$SCRIPT_DIR/../.."
HOOK_PATH="$ROOT/hooks/test-acceptance-gate"

echo "=== Test: stop gate requires status tokens in Acceptance status section ==="
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

VERSION_DIR="$TMP_DIR/docs/V0.1.0-panel-ui"
PR_DIR="$VERSION_DIR/V0.1.0-PR1"
mkdir -p "$PR_DIR" "$TMP_DIR/.claude"

printf 'needs_acceptance\n' >"$TMP_DIR/.claude/.test-acceptance-status"

cat >"$PR_DIR/V0.1.0-PR1-tdd-log.md" <<'EOF'
### T-001 panel flow
Test Point: panel container state
Expected Result: panel opens
Assertion Target: expect(true)
EOF

cat >"$PR_DIR/V0.1.0-PR1-subagent-summary.md" <<'EOF'
# Summary
EOF

cat >"$PR_DIR/V0.1.0-PR1-review-report.md" <<'EOF'
# Review
EOF

cat >"$PR_DIR/V0.1.0-PR1-finalize-log.md" <<'EOF'
# Finalize
EOF

# Keywords only, no pass/fail (must block)
cat >"$VERSION_DIR/V0.1.0-test.md" <<'EOF'
## Acceptance status (hooks)
autotest
mocktest
devicetest

## Detailed Test Cases
TC-001 panel

## Coverage Matrix
ok

## Expectation Index
ok

## Known Blind Spots
none
EOF

set +e
OUT="$(CLAUDE_PROJECT_DIR="$TMP_DIR" bash "$HOOK_PATH" 2>&1)"
CODE=$?
set -e

if [ "$CODE" -ne 2 ]; then
  echo "  [FAIL] expected exit 2 when acceptance lines lack status (keyword-only)"
  echo "  exit_code=$CODE"
  echo "  output:"
  printf '%s\n' "$OUT" | head -n 20
  exit 1
fi

if ! printf '%s' "$OUT" | rg -q "带状态结果行|decision|block"; then
  echo "  [FAIL] expected block JSON or missing-status reason in output"
  echo "  output:"
  printf '%s\n' "$OUT" | head -n 20
  exit 1
fi

echo "  [PASS] keyword-only acceptance lines blocked (exit 2)"
echo ""
echo "=== stop gate acceptance status required: ok ==="
exit 0
