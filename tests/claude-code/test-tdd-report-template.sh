#!/usr/bin/env bash
# Test: tdd report template required fields
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_PATH="$SCRIPT_DIR/../../docs/superpowers/templates/tdd-report-template.md"

echo "=== Test: tdd-report template ==="
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

assert_field "Spec:" "Spec mapping field"
assert_field "Plan:" "Plan mapping field"
assert_field "RED command:" "RED command field"
assert_field "GREEN command:" "GREEN command field"
assert_field "Test Point" "Test Point field"
assert_field "Expected Result" "Expected Result field"
assert_field "Assertion Target" "Assertion Target field"
assert_field "Regression coverage" "Regression coverage section"
assert_field "Completion evidence summary" "Completion evidence section"
assert_field "Acceptance status \\(hooks\\)" "points to version Vx.y.z-test.md acceptance section"
assert_field "^\\| Spec requirement \\| plan task \\| test ID \\| test scope \\| test point \\| status \\|$" "Mapping matrix header has 6 columns"
assert_field "^\\|---\\|---\\|---\\|---\\|---\\|---\\|$" "Mapping matrix separator matches 6 columns"

echo ""
echo "=== tdd-report template checks passed ==="
