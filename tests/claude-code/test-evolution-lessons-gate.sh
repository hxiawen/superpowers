#!/usr/bin/env bash
# Test: stop gate blocks when candidate feedback lacks LESSONS adoption visibility
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$SCRIPT_DIR/../.."
HOOK_PATH="$ROOT/hooks/test-acceptance-gate"

echo "=== Test: evolution lessons visibility gate ==="
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
mkdir -p "$PR_DIR" "$TMP_DIR/.claude/feedback" "$TMP_DIR/.claude"

cat > "$TMP_DIR/.claude/.test-acceptance-status" <<'EOF'
needs_acceptance
EOF

cat > "$PR_DIR/V0.1.0-PR1-tdd-log.md" <<'EOF'
autotest: pass
mocktest: pass
devicetest: pass

### T-001 panel flow
Test Point: panel container state
Expected Result: panel opens with expected style
Assertion Target: expect(width).toBe('255px')
EOF

cat > "$PR_DIR/V0.1.0-PR1-subagent-summary.md" <<'EOF'
# Summary
EOF

cat > "$PR_DIR/V0.1.0-PR1-review-report.md" <<'EOF'
# Review
Approved.
EOF

cat > "$PR_DIR/V0.1.0-PR1-finalize-log.md" <<'EOF'
# Finalize
Ready.
EOF

cat > "$VERSION_DIR/V0.1.0-test.md" <<'EOF'
## Acceptance status (hooks)
autotest: pass
mocktest: pass
devicetest: pass

## Detailed Test Cases
TC-001 panel flow

## Coverage Matrix
ok

## Expectation Index
ok

## Known Blind Spots
none
EOF

cat > "$TMP_DIR/.claude/feedback/FEEDBACK-INDEX.md" <<'EOF'
- [x] topic: theme-mismatch
  - status: candidate
  - occurrences: 2
EOF

set +e
OUT="$(CLAUDE_PROJECT_DIR="$TMP_DIR" bash "$HOOK_PATH" 2>&1)"
CODE=$?
set -e
if [ "$CODE" -ne 2 ]; then
    echo "  [FAIL] expected block when candidate exists without LESSONS"
    echo "  exit_code=$CODE"
    echo "  output=$OUT"
    exit 1
fi
echo "  [PASS] missing LESSONS visibility is blocked"

mkdir -p "$TMP_DIR/docs"
cat > "$TMP_DIR/docs/LESSONS.md" <<'EOF'
# Lessons / 进化建议

## 2026-04-22 — theme-mismatch
- 流程状态：candidate
- 建议是否被采纳：pending
EOF

if ! CLAUDE_PROJECT_DIR="$TMP_DIR" bash "$HOOK_PATH" >/dev/null 2>&1; then
    echo "  [FAIL] expected pass when LESSONS adoption status exists"
    exit 1
fi

echo "  [PASS] LESSONS adoption status allows completion"
echo ""
echo "=== evolution lessons visibility checks passed ==="
