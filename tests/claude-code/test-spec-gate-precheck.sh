#!/usr/bin/env bash
# Test: spec gate precheck blocks writing-plans when reconnaissance sections are missing
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$SCRIPT_DIR/../.."
HOOK_PATH="$ROOT/hooks/spec-gate-precheck"

echo "=== Test: spec gate precheck ==="
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
mkdir -p "$VERSION_DIR"

cat > "$VERSION_DIR/V0.1.0-design.md" <<'EOF'
# Design
Approved.
EOF

cat > "$VERSION_DIR/V0.1.0-spec.md" <<'EOF'
# Spec
## Scope
Initial draft without required reconnaissance sections.
EOF

PROMPT_JSON='{"prompt":"please enter writing-plans now"}'

set +e
OUT="$(printf '%s' "$PROMPT_JSON" | CLAUDE_PROJECT_DIR="$TMP_DIR" bash "$HOOK_PATH" 2>&1)"
CODE=$?
set -e

if [ "$CODE" -ne 2 ]; then
    echo "  [FAIL] expected block when reconnaissance sections missing"
    echo "  exit_code=$CODE"
    echo "  output=$OUT"
    exit 1
fi

if ! printf '%s' "$OUT" | rg -q '"decision":"block"'; then
    echo "  [FAIL] expected structured block output"
    echo "  output=$OUT"
    exit 1
fi

echo "  [PASS] missing reconnaissance sections are blocked"

cat > "$VERSION_DIR/V0.1.0-spec.md" <<'EOF'
# Spec
## Affected Paths
- src/panel.ts

## Invariants
- Must not break existing keyboard shortcuts.

## Figma Diff
- Footer capsule uses fixed 105px width.

## Superpowers pipeline (hooks)

Full extension acceptance pipeline: Yes
EOF

if ! printf '%s' "$PROMPT_JSON" | CLAUDE_PROJECT_DIR="$TMP_DIR" bash "$HOOK_PATH" >/dev/null 2>&1; then
    echo "  [FAIL] expected pass after adding required sections"
    exit 1
fi

echo "  [PASS] writing-plans allowed after required sections"
echo ""
echo "=== spec gate precheck checks passed ==="
