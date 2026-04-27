#!/usr/bin/env bash
# Validate evolution closure visibility in project docs/LESSONS.md

set -euo pipefail

PROJECT_DIR="${1:-${CLAUDE_PROJECT_DIR:-}}"
if [ -z "$PROJECT_DIR" ]; then
  echo "SKIP: missing project dir"
  exit 0
fi

FEEDBACK_INDEX="$PROJECT_DIR/.claude/feedback/FEEDBACK-INDEX.md"
LESSONS_FILE="$PROJECT_DIR/docs/LESSONS.md"

if [ ! -f "$FEEDBACK_INDEX" ]; then
  echo "SKIP: no feedback index"
  exit 0
fi

if ! rg -qi "status:[[:space:]]*candidate|occurrences:[[:space:]]*([2-9]|[1-9][0-9]+)" "$FEEDBACK_INDEX"; then
  echo "OK: no candidate feedback signals"
  exit 0
fi

if [ ! -f "$LESSONS_FILE" ]; then
  echo "BLOCK: docs/LESSONS.md missing while candidate feedback exists"
  exit 2
fi

if ! rg -qi "建议是否被采纳[：:][[:space:]]*(pending|adopted|not_adopted)|adoption[：:][[:space:]]*(pending|adopted|not_adopted)" "$LESSONS_FILE"; then
  echo "BLOCK: docs/LESSONS.md missing adoption status (pending/adopted/not_adopted)"
  exit 2
fi

echo "OK: evolution closure visible in docs/LESSONS.md"
exit 0
