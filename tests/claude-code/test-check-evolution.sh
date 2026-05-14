#!/usr/bin/env bash
# Test: check-evolution tolerates table-format feedback indexes and emits
# SessionStart context instead of exiting on rg zero-match.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
HOOK="$ROOT/hooks/check-evolution"

echo "=== Test: check-evolution table feedback index support ==="

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local name="$3"
  if printf '%s' "$haystack" | rg -q "$needle"; then
    echo "  [PASS] $name"
  else
    echo "  [FAIL] $name"
    echo "  Missing pattern: $needle"
    echo "$haystack"
    exit 1
  fi
}

PROJECT_DIR="$(mktemp -d)"
PROJECT_DIR2=""
cleanup() {
  rm -rf "$PROJECT_DIR"
  if [ -n "${PROJECT_DIR2:-}" ]; then
    rm -rf "$PROJECT_DIR2"
  fi
}
trap cleanup EXIT
mkdir -p "$PROJECT_DIR/.claude/feedback"

cat > "$PROJECT_DIR/.claude/feedback/FEEDBACK-INDEX.md" <<'EOF'
# Feedback Index

## Topics

| Topic | File | Occurrences | Status | First Seen | Last Seen |
|-------|------|-------------|--------|------------|-----------|
| mocktest-brand-refresh-ui | mocktest-brand-refresh-ui.md | 1 | recorded | 2026-04-28 | 2026-04-28 |
| test-acceptance-gate-false-positive | test-acceptance-gate-false-positive.md | 2 | candidate | 2026-04-28 | 2026-04-28 |
EOF

set +e
output="$(CLAUDE_PROJECT_DIR="$PROJECT_DIR" CLAUDE_PLUGIN_ROOT="$ROOT" bash "$HOOK" 2>&1)"
code=$?
set -e

if [ "$code" -ne 0 ]; then
  echo "  [FAIL] hook should not fail on table-format feedback index"
  echo "$output"
  exit 1
fi
echo "  [PASS] hook exits successfully"

assert_contains "$output" '"hookEventName": "SessionStart"' "hook emits SessionStart payload"
assert_contains "$output" 'found 2 feedback entries' "hook counts table rows"
assert_contains "$output" 'Candidate signals detected: 1' "hook counts candidate table rows"

if [ ! -f "$PROJECT_DIR/.claude/.evolution-required" ]; then
  echo "  [FAIL] hook should write evolution-required marker"
  exit 1
fi

marker="$(tr -d '[:space:]' < "$PROJECT_DIR/.claude/.evolution-required")"
if [ "$marker" != "candidate" ]; then
  echo "  [FAIL] expected candidate marker"
  echo "  actual=$marker"
  exit 1
fi
echo "  [PASS] hook writes candidate marker"

echo ""
echo "=== Test: adopted / closed rows do not inflate candidate count ==="

PROJECT_DIR2="$(mktemp -d)"
mkdir -p "$PROJECT_DIR2/.claude/feedback"

cat > "$PROJECT_DIR2/.claude/feedback/FEEDBACK-INDEX.md" <<'EOF'
# Feedback Index

## Topics

| Topic | File | Occurrences | Status | First Seen | Last Seen |
|-------|------|-------------|--------|------------|-----------|
| topic-a | topic-a.md | 5 | adopted | 2026-04-28 | 2026-05-03 |
| topic-b | topic-b.md | 3 | not_adopted | 2026-04-28 | 2026-05-03 |
| topic-c | topic-c.md | 1 | recorded | 2026-04-28 | 2026-04-28 |
EOF

set +e
output2="$(CLAUDE_PROJECT_DIR="$PROJECT_DIR2" CLAUDE_PLUGIN_ROOT="$ROOT" bash "$HOOK" 2>&1)"
code2=$?
set -e

if [ "$code2" -ne 0 ]; then
  echo "  [FAIL] hook should not fail on adopted-only table index"
  echo "$output2"
  exit 1
fi
echo "  [PASS] hook exits successfully (adopted fixture)"

if [ -n "${output2//[[:space:]]/}" ]; then
  echo "  [FAIL] expected empty stdout when there are zero actionable candidates"
  printf '%s\n' "$output2"
  exit 1
fi
echo "  [PASS] hook emits no SessionStart JSON when EVO_CANDIDATES is zero"

if [ -f "$PROJECT_DIR2/.claude/.evolution-required" ]; then
  echo "  [FAIL] expected no evolution-required marker when EVO_CANDIDATES is zero"
  exit 1
fi
echo "  [PASS] hook clears evolution-required marker when no actionable candidates"

echo ""
echo "=== check-evolution checks passed ==="
