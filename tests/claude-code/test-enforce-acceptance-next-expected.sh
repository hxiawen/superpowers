#!/usr/bin/env bash
# Test: next_expected_test_from_version is scoped to ## Acceptance status (hooks) only
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$SCRIPT_DIR/../.."
COMMON="$ROOT/hooks/acceptance-order-common"

echo "=== Test: enforce acceptance next_expected (version section) ==="
echo ""

# shellcheck source=hooks/acceptance-order-common
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

# 1) Empty section -> autotest
cat >"$TMP" <<'EOF'
## Acceptance status (hooks)

EOF
assert_eq "$(next_expected_test_from_version "$TMP")" "autotest" "empty section expects autotest"

# 2) Only autotest in section -> mocktest
cat >"$TMP" <<'EOF'
## Acceptance status (hooks)
autotest: pass

EOF
assert_eq "$(next_expected_test_from_version "$TMP")" "mocktest" "after autotest expects mocktest"

# 3) autotest + mocktest -> devicetest
cat >"$TMP" <<'EOF'
## Acceptance status (hooks)
autotest: pass
mocktest: pass

EOF
assert_eq "$(next_expected_test_from_version "$TMP")" "devicetest" "after mocktest expects devicetest"

# 4) All three -> done
cat >"$TMP" <<'EOF'
## Acceptance status (hooks)
autotest: pass
mocktest: pass
devicetest: pass

EOF
assert_eq "$(next_expected_test_from_version "$TMP")" "done" "all three -> done"

# 5) Design sync required after all three -> figma-live-sync
cat >"$TMP" <<'EOF'
## Acceptance status (hooks)
autotest: pass
mocktest: pass
devicetest: pass

EOF
assert_eq "$(next_expected_test_from_version "$TMP" "true")" "figma-live-sync" "design sync required expects figma-live-sync"

# 6) New design sync status completes the sequence
cat >"$TMP" <<'EOF'
## Acceptance status (hooks)
autotest: pass
mocktest: pass
devicetest: pass
figma-live-sync: pass

EOF
assert_eq "$(next_expected_test_from_version "$TMP" "true")" "done" "figma-live-sync status completes sequence"

# 7) Legacy codetofigma status remains accepted for old plans
cat >"$TMP" <<'EOF'
## Acceptance status (hooks)
autotest: pass
mocktest: pass
devicetest: pass
codetofigma: pass

EOF
assert_eq "$(next_expected_test_from_version "$TMP" "true")" "done" "legacy codetofigma status completes sequence"

# 8) Noise OUTSIDE section must not advance state (autotest only in body after next ##)
cat >"$TMP" <<'EOF'
## Acceptance status (hooks)

## Expectation Index
autotest: pass
mocktest: pass
devicetest: pass
EOF
assert_eq "$(next_expected_test_from_version "$TMP")" "autotest" "status outside section ignored"

# 9) Missing heading
cat >"$TMP" <<'EOF'
autotest: pass
mocktest: pass
devicetest: pass
EOF
assert_eq "$(next_expected_test_from_version "$TMP")" "missing_heading" "no H2 -> missing_heading"

echo ""
echo "=== enforce acceptance next_expected checks passed ==="
