#!/usr/bin/env bash
# Test: build-version-report-guard skips when all three env tests are waived (web-only).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
COMMON="$ROOT/hooks/acceptance-order-common"
GUARD="$ROOT/hooks/build-version-report-guard"

echo "=== Test: build-version manifest waiver ==="
echo ""

# shellcheck source=/dev/null
. "$COMMON"

TMPDIR_TEST="$(mktemp -d)"
cleanup() {
  rm -rf "$TMPDIR_TEST"
}
trap cleanup EXIT

SUB="$TMPDIR_TEST/docs/V0.9.9-webonly"
mkdir -p "$SUB"
VERSION_TEST="$SUB/V0.9.9-test.md"

cat >"$VERSION_TEST" <<'EOF'
## Acceptance status (hooks)
- autotest: N/A (webapp)
- mocktest: N/A
- devicetest: N/A
EOF

assert_waived() {
  if ! acceptance_env_triple_waived_no_manifest_version_report "$1"; then
    echo "  [FAIL] expected triple waived for $1"
    exit 1
  fi
  echo "  [PASS] triple waived: $2"
}

assert_not_waived() {
  if acceptance_env_triple_waived_no_manifest_version_report "$1"; then
    echo "  [FAIL] expected NOT triple waived for $1"
    exit 1
  fi
  echo "  [PASS] not triple waived: $2"
}

assert_waived "$VERSION_TEST" "N/A lines"

if ! validate_order_in_acceptance_section "$VERSION_TEST" "fixture" "false" "false"; then
  echo "  [FAIL] validate_order should accept N/A triple"
  exit 1
fi
echo "  [PASS] validate_order accepts N/A triple"

mkdir -p "$TMPDIR_TEST/.claude"
printf 'needs_acceptance\n' >"$TMPDIR_TEST/.claude/.test-acceptance-status"
(
  cd "$TMPDIR_TEST" || exit 1
  export CLAUDE_PROJECT_DIR="$TMPDIR_TEST"
  if ! bash "$GUARD" >/dev/null 2>&1; then
    echo "  [FAIL] guard should exit 0 for waived triple"
    exit 1
  fi
)
echo "  [PASS] build-version-report-guard exits 0 when triple waived"

cat >"$VERSION_TEST" <<'EOF'
## Acceptance status (hooks)
- autotest: pass
- mocktest: N/A
- devicetest: N/A
EOF
assert_not_waived "$VERSION_TEST" "autotest pass still needs manifest discipline"

echo ""
echo "=== build-version waiver checks passed ==="
