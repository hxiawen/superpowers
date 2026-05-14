#!/usr/bin/env bash
# Test: Stop gate accepts platform-only release via docs/platform-release-test.md + marker
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$SCRIPT_DIR/../.."
HOOK="$ROOT/hooks/test-acceptance-gate"

echo "=== Test: platform-release stop gate ==="
echo ""

TMP="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP"
}
trap cleanup EXIT

mkdir -p "$TMP/.claude" "$TMP/.superpowers" "$TMP/docs"
printf 'x\n' > "$TMP/.superpowers/platform-release"

cat > "$TMP/docs/platform-release-test.md" <<'EOF'
## Acceptance status (hooks)
structure: pass
build: pass
git-history: pass

## Detailed Test Cases
TC-001 layout ok

## Coverage Matrix
ok

## Expectation Index
ok

## Known Blind Spots
none
EOF

cat > "$TMP/.claude/.test-acceptance-status" <<'EOF'
needs_acceptance
EOF

if ! CLAUDE_PROJECT_DIR="$TMP" bash "$HOOK" >/dev/null 2>&1; then
  echo "  [FAIL] expected hook pass for valid platform acceptance file"
  CLAUDE_PROJECT_DIR="$TMP" bash "$HOOK" 2>&1 || true
  exit 1
fi
echo "  [PASS] stop gate passes with platform marker + platform test doc"

TMP_BAD="$(mktemp -d)"
mkdir -p "$TMP_BAD/.claude" "$TMP_BAD/.superpowers" "$TMP_BAD/docs"
printf 'x\n' > "$TMP_BAD/.superpowers/platform-release"
cat > "$TMP_BAD/docs/platform-release-test.md" <<'EOF'
## Acceptance status (hooks)
structure: pass
build: pass

## Detailed Test Cases
TC-001 layout ok

## Coverage Matrix
ok

## Expectation Index
ok

## Known Blind Spots
none
EOF
cat > "$TMP_BAD/.claude/.test-acceptance-status" <<'EOF'
needs_acceptance
EOF

set +e
OUT="$(CLAUDE_PROJECT_DIR="$TMP_BAD" bash "$HOOK" 2>&1)"
CODE=$?
set -e
rm -rf "$TMP_BAD"
if [ "$CODE" -eq 0 ]; then
  echo "  [FAIL] expected block when platform acceptance omits git-history"
  exit 1
fi
echo "  [PASS] stop gate blocks incomplete platform acceptance"

echo ""
echo "=== platform-release acceptance checks passed ==="
