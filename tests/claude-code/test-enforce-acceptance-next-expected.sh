#!/usr/bin/env bash
# Test: next_expected_test_from_version respects completion state, not just line presence.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
COMMON="$ROOT/hooks/acceptance-order-common"

echo "=== Test: enforce acceptance next_expected ==="
echo ""

# shellcheck source=/dev/null
. "$COMMON"

TMP="$(mktemp)"
cleanup() {
  rm -f "$TMP"
}
trap cleanup EXIT

assert_eq() {
  local got="$1"
  local want="$2"
  local label="$3"
  if [ "$got" != "$want" ]; then
    echo "  [FAIL] $label: want '$want', got '$got'"
    exit 1
  fi
  echo "  [PASS] $label"
}

cat >"$TMP" <<'EOF'
## Acceptance status (hooks)
- autotest: pending
- mocktest: pending
- devicetest: pending
- figma-live-sync: pending
EOF
assert_eq "$(next_expected_test_from_version "$TMP" "true")" "autotest" "all pending still expects autotest"

cat >"$TMP" <<'EOF'
## Acceptance status (hooks)
- autotest: pass
- mocktest: pending
- devicetest: pending
- figma-live-sync: pending
EOF
assert_eq "$(next_expected_test_from_version "$TMP" "true")" "mocktest" "pending mocktest is not treated as completed"

cat >"$TMP" <<'EOF'
## Acceptance status (hooks)
- autotest: pass
- mocktest: pass
- devicetest: pending
- figma-live-sync: pending
EOF
assert_eq "$(next_expected_test_from_version "$TMP" "true")" "devicetest" "pending devicetest is not treated as completed"

cat >"$TMP" <<'EOF'
## Acceptance status (hooks)
- autotest: pass
- mocktest: pass
- devicetest: pass
- figma-live-sync: pending
EOF
assert_eq "$(next_expected_test_from_version "$TMP" "true")" "figma-live-sync" "pending figma-live-sync is not treated as completed"

cat >"$TMP" <<'EOF'
## Acceptance status (hooks)
- autotest: pass
- mocktest: pass
- devicetest: pass
- figma-live-sync: pass
EOF
assert_eq "$(next_expected_test_from_version "$TMP" "true")" "done" "completed figma-live-sync finishes the sequence"

cat >"$TMP" <<'EOF'
## Acceptance status (hooks)
- autotest: pass
- mocktest: pass
- devicetest: pass
- codetofigma: pass
EOF
assert_eq "$(next_expected_test_from_version "$TMP" "true")" "done" "legacy codetofigma remains accepted"

echo ""
echo "=== enforce acceptance next_expected checks passed ==="
