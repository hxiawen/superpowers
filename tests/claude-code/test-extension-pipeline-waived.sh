#!/usr/bin/env bash
# Test: superpowers_extension_pipeline_waived + hooks respect spec ## Superpowers pipeline (hooks).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
COMMON="$ROOT/hooks/acceptance-order-common"
ENFORCE="$ROOT/hooks/enforce-acceptance-order"
BUILD_GUARD="$ROOT/hooks/build-version-report-guard"

echo "=== Test: extension pipeline waived (spec-driven) ==="
echo ""

# shellcheck source=/dev/null
. "$COMMON"

TMP="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP"
}
trap cleanup EXIT

SUB="$TMP/docs/V0.8.8-pipeline"
mkdir -p "$SUB" "$TMP/.claude"

cat >"$SUB/V0.8.8-spec.md" <<'SPECEOF'
# Spec

## Superpowers pipeline (hooks)

Full extension acceptance pipeline: No

## Other
x
SPECEOF

export CLAUDE_PROJECT_DIR="$TMP"
if ! superpowers_extension_pipeline_waived "$TMP"; then
  echo "  [FAIL] expected waived when spec says No"
  exit 1
fi
echo "  [PASS] superpowers_extension_pipeline_waived is true for No"

cat >"$SUB/V0.8.8-spec.md" <<'SPECEOF'
## Superpowers pipeline (hooks)

Full extension acceptance pipeline: Yes
SPECEOF
if superpowers_extension_pipeline_waived "$TMP"; then
  echo "  [FAIL] expected not waived for Yes"
  exit 1
fi
echo "  [PASS] not waived for Yes"

cat >"$SUB/V0.8.8-spec.md" <<'SPECEOF'
## Superpowers pipeline (hooks)

Full extension acceptance pipeline: No
SPECEOF
mkdir -p "$SUB/V0.8.8-PR1"
printf 'T-001\nTest Point\nExpected\nAssertion\n' >"$SUB/V0.8.8-PR1/V0.8.8-PR1-tdd-log.md"
cat >"$SUB/V0.8.8-test.md" <<'TEOF'
## Detailed Test Cases
- TC-001 | x | x | x
## Acceptance status (hooks)
- autotest: pass
- mocktest: pending
- devicetest: pending
## Coverage Matrix
## Expectation Index
## Known Blind Spots
TEOF
if ! printf '%s' '{"prompt":"请执行 mocktest"}' | CLAUDE_PROJECT_DIR="$TMP" bash "$ENFORCE" >/dev/null 2>&1; then
  echo "  [FAIL] enforce should exit 0 when pipeline waived"
  exit 1
fi
echo "  [PASS] enforce-acceptance-order exits 0 when waived"

printf 'needs_acceptance\n' >"$TMP/.claude/.test-acceptance-status"
if ! bash "$BUILD_GUARD" >/dev/null 2>&1; then
  echo "  [FAIL] build-version-report-guard should exit 0 when waived"
  exit 1
fi
echo "  [PASS] build-version-report-guard exits 0 when waived"

echo ""
echo "=== extension pipeline waived checks passed ==="
