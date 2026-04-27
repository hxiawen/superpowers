#!/usr/bin/env bash
# Test: mark-test-acceptance-needed does not reopen spec confirmation for
# status-only updates inside Vx.y.z-test.md Acceptance status section.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
HOOK="$ROOT/hooks/mark-test-acceptance-needed"

echo "=== Test: mark-test-acceptance-needed status-only exemption ==="

make_project() {
  local dir
  dir="$(mktemp -d)"
  mkdir -p "$dir/.claude" "$dir/docs/V0.1.0-demo" "$dir/src/e2e/specs"
  printf '# Test\n\n## Acceptance status (hooks)\n\n- autotest: pending\n- mocktest: pending\n' > "$dir/docs/V0.1.0-demo/V0.1.0-test.md"
  printf 'test("x", () => {});\n' > "$dir/src/e2e/specs/sample.spec.ts"
  printf '%s' "$dir"
}

assert_missing() {
  local file="$1"
  local name="$2"
  if [ ! -f "$file" ]; then
    echo "  [PASS] $name"
  else
    echo "  [FAIL] $name"
    echo "  Unexpected file: $file"
    exit 1
  fi
}

assert_equals() {
  local expected="$1"
  local file="$2"
  local name="$3"
  local actual
  actual="$(tr -d '[:space:]' < "$file" 2>/dev/null || true)"
  if [ "$actual" = "$expected" ]; then
    echo "  [PASS] $name"
  else
    echo "  [FAIL] $name"
    echo "  Expected: $expected"
    echo "  Actual:   $actual"
    exit 1
  fi
}

PROJECT_DIR="$(make_project)"
trap 'rm -rf "$PROJECT_DIR"' EXIT

STATUS_FILE="$PROJECT_DIR/.claude/.test-acceptance-status"
SPEC_FILE="$PROJECT_DIR/.claude/.spec-change-status"

cat <<'EOF' | CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" >/dev/null
{"tool_input":{"file_path":"docs/V0.1.0-demo/V0.1.0-test.md","old_string":"- autotest: pending","new_string":"- autotest: pass"}}
EOF
assert_missing "$STATUS_FILE" "status-only version test update does not require acceptance rerun"
assert_missing "$SPEC_FILE" "status-only version test update does not reopen spec confirmation"

cat <<'EOF' | CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" >/dev/null
{"tool_input":{"file_path":"docs/V0.1.0-demo/V0.1.0-test.md","old_string":"pending","new_string":"pass"}}
EOF
assert_missing "$STATUS_FILE" "status token-only version test update does not require acceptance rerun"
assert_missing "$SPEC_FILE" "status token-only version test update does not reopen spec confirmation"

cat <<'EOF' | CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" >/dev/null
{"tool_input":{"file_path":"docs/V0.1.0-demo/V0.1.0-test.md","old_string":"| Expected Result | old |","new_string":"| Expected Result | new |"}}
EOF
assert_equals "needs_confirm" "$SPEC_FILE" "real version test assertion edit reopens spec confirmation"
rm -f "$SPEC_FILE" "$STATUS_FILE"

cat <<'EOF' | CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" >/dev/null
{"tool_input":{"file_path":"src/e2e/specs/sample.spec.ts","old_string":"test(\"x\", () => {});","new_string":"test(\"x\", async () => {});"}}
EOF
assert_equals "needs_acceptance" "$STATUS_FILE" "e2e assertion edit requires acceptance rerun"
assert_equals "needs_confirm" "$SPEC_FILE" "e2e assertion edit requires explicit confirmation"

echo ""
echo "=== mark-test-acceptance-needed checks passed ==="
