#!/usr/bin/env bash
# Test: stop gate blocks when any required quality field is missing
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$SCRIPT_DIR/../.."
HOOK_PATH="$ROOT/hooks/test-acceptance-gate"

echo "=== Test: stop gate quality fields blocking ==="
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
STATUS_FILE="$TMP_DIR/.claude/.test-acceptance-status"

mkdir -p "$PR_DIR" "$TMP_DIR/.claude"

write_docs() {
    local omit_field="$1"
    local pr_tdd="$PR_DIR/V0.1.0-PR1-tdd-log.md"
    local pr_summary="$PR_DIR/V0.1.0-PR1-subagent-summary.md"
    local pr_review="$PR_DIR/V0.1.0-PR1-review-report.md"
    local pr_finalize="$PR_DIR/V0.1.0-PR1-finalize-log.md"
    local version_test="$VERSION_DIR/V0.1.0-test.md"

    cat >"$pr_tdd" <<EOF
autotest: pass
mocktest: pass
devicetest: pass

T-001 basic flow
EOF
    if [ "$omit_field" != "Test Point" ]; then
        echo "Test Point: panel container state" >>"$pr_tdd"
    fi
    if [ "$omit_field" != "Expected Result" ]; then
        echo "Expected Result: panel opens with expected style" >>"$pr_tdd"
    fi
    if [ "$omit_field" != "Assertion Target" ]; then
        echo "Assertion Target: expect(width).toBe('255px')" >>"$pr_tdd"
    fi

    cat >"$pr_summary" <<EOF
# Subagent Summary
EOF

    cat >"$pr_review" <<EOF
# Review Report
EOF

    cat >"$pr_finalize" <<EOF
# Finalize Log
EOF

    cat >"$version_test" <<EOF
## Acceptance status (hooks)
autotest: pass
mocktest: pass
devicetest: pass

## Detailed Test Cases
TC-001 panel flow
EOF
    if [ "$omit_field" != "Coverage Matrix" ]; then
        echo "Coverage Matrix" >>"$version_test"
    fi
    if [ "$omit_field" != "Expectation Index" ]; then
        echo "Expectation Index" >>"$version_test"
    fi
    if [ "$omit_field" != "Known Blind Spots" ]; then
        echo "Known Blind Spots" >>"$version_test"
    fi
}

run_hook_and_assert() {
    local expected_field="$1"
    local status_mode="${2:-needs_acceptance}"
    local output
    local exit_code

    if [ "$status_mode" = "missing" ]; then
        rm -f "$STATUS_FILE"
    else
        printf '%s\n' "$status_mode" >"$STATUS_FILE"
    fi
    set +e
    output="$(CLAUDE_PROJECT_DIR="$TMP_DIR" bash "$HOOK_PATH" 2>&1)"
    exit_code=$?
    set -e

    if [ "$exit_code" -ne 2 ]; then
        echo "  [FAIL] expected exit 2 when missing: $expected_field"
        echo "  exit_code=$exit_code"
        echo "  output=$output"
        exit 1
    fi

    if ! printf '%s' "$output" | rg -q '"decision":"block"'; then
        echo "  [FAIL] expected structured block decision for: $expected_field"
        echo "  output=$output"
        exit 1
    fi

    if ! printf '%s' "$output" | rg -q '"remediation_owner":"agent"'; then
        echo "  [FAIL] expected remediation_owner=agent for: $expected_field"
        echo "  output=$output"
        exit 1
    fi

    if ! printf '%s' "$output" | rg -q '"block_class":"agent_remediation_required"'; then
        echo "  [FAIL] expected block_class=agent_remediation_required for: $expected_field"
        echo "  output=$output"
        exit 1
    fi

    if ! printf '%s' "$output" | rg -q '"missing_fields":\['; then
        echo "  [FAIL] expected missing_fields array for: $expected_field"
        echo "  output=$output"
        exit 1
    fi

    if [ "$status_mode" = "needs_acceptance" ]; then
        if ! printf '%s' "$output" | rg -q '"status_fallback":false'; then
            echo "  [FAIL] expected status_fallback=false for strict mode: $expected_field"
            echo "  output=$output"
            exit 1
        fi
    else
        if ! printf '%s' "$output" | rg -q '"status_fallback":true'; then
            echo "  [FAIL] expected status_fallback=true for fallback mode: $expected_field"
            echo "  output=$output"
            exit 1
        fi
    fi

    if ! printf '%s' "$output" | rg -q "$expected_field"; then
        echo "  [FAIL] expected missing field not found in output: $expected_field"
        echo "  output=$output"
        exit 1
    fi

    echo "  [PASS] missing $expected_field is blocked with missing_fields output"
}

write_multi_case_docs_missing_second_case_field() {
    local missing_field="$1"
    local pr_tdd="$PR_DIR/V0.1.0-PR1-tdd-log.md"
    local pr_summary="$PR_DIR/V0.1.0-PR1-subagent-summary.md"
    local pr_review="$PR_DIR/V0.1.0-PR1-review-report.md"
    local pr_finalize="$PR_DIR/V0.1.0-PR1-finalize-log.md"
    local version_test="$VERSION_DIR/V0.1.0-test.md"

    cat >"$pr_tdd" <<EOF
autotest: pass
mocktest: pass
devicetest: pass

### T-001 first case
Test Point: first test point
Expected Result: first expected result
Assertion Target: first assertion target

### T-002 second case
EOF
    if [ "$missing_field" != "Test Point" ]; then
        echo "Test Point: second test point" >>"$pr_tdd"
    fi
    if [ "$missing_field" != "Expected Result" ]; then
        echo "Expected Result: second expected result" >>"$pr_tdd"
    fi
    if [ "$missing_field" != "Assertion Target" ]; then
        echo "Assertion Target: second assertion target" >>"$pr_tdd"
    fi

    cat >"$version_test" <<EOF
## Acceptance status (hooks)
autotest: pass
mocktest: pass
devicetest: pass

## Detailed Test Cases
TC-001 panel flow
Coverage Matrix
Expectation Index
Known Blind Spots
EOF

    cat >"$pr_summary" <<EOF
# Subagent Summary
EOF

    cat >"$pr_review" <<EOF
# Review Report
EOF

    cat >"$pr_finalize" <<EOF
# Finalize Log
EOF
}

# Positive control: all fields present should pass
write_docs ""
printf 'needs_acceptance\n' >"$STATUS_FILE"
if ! CLAUDE_PROJECT_DIR="$TMP_DIR" bash "$HOOK_PATH" >/dev/null 2>&1; then
    echo "  [FAIL] baseline with all quality fields should pass"
    baseline_output="$(CLAUDE_PROJECT_DIR="$TMP_DIR" bash "$HOOK_PATH" 2>&1 || true)"
    echo "  output=$baseline_output"
    exit 1
fi
echo "  [PASS] baseline with all quality fields passes"

fields=(
    "Test Point"
    "Expected Result"
    "Assertion Target"
    "Coverage Matrix"
    "Expectation Index"
    "Known Blind Spots"
)

for field in "${fields[@]}"; do
    write_docs "$field"
    run_hook_and_assert "$field"
done

# Anti-bypass check: one case complete, another case missing fields must still block
write_multi_case_docs_missing_second_case_field "Expected Result"
run_hook_and_assert "T-002:Expected Result"

# Fallback mode checks: status file missing or abnormal state should still enforce gate
write_docs "Expected Result"
run_hook_and_assert "Expected Result" "missing"
write_docs "Assertion Target"
run_hook_and_assert "Assertion Target" "unexpected_state"

echo ""
echo "=== stop gate quality fields checks passed ==="
