#!/usr/bin/env bash
# Test: version test template required quality fields
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_PATH="$SCRIPT_DIR/../../docs/superpowers/templates/versioning/version-test-template.md"

echo "=== Test: version-test template ==="
echo ""

if [ ! -f "$TEMPLATE_PATH" ]; then
    echo "[FAIL] Template missing: $TEMPLATE_PATH"
    exit 1
fi

assert_field() {
    local pattern="$1"
    local name="$2"
    if rg -n "$pattern" "$TEMPLATE_PATH" >/dev/null 2>&1; then
        echo "  [PASS] $name"
    else
        echo "  [FAIL] Missing field: $name"
        exit 1
    fi
}

assert_field '^## Acceptance status \(hooks\)$' "exact H2 ## Acceptance status (hooks)"
assert_field "Detailed Test Cases" "Detailed Test Cases section"
assert_field "Coverage Matrix" "Coverage Matrix section"
assert_field "Expectation Index" "Expectation Index section"
assert_field "Known Blind Spots" "Known Blind Spots section"

echo ""
echo "=== version-test template checks passed ==="
