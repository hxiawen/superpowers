#!/usr/bin/env bash
# Project-level stop gate (pilot template)

set -euo pipefail

FLAG_FILE=".claude/.needs-review"
if [ ! -f "$FLAG_FILE" ]; then
  exit 0
fi

state="$(cat "$FLAG_FILE" 2>/dev/null || true)"
if [ "$state" = "needs_review" ]; then
  echo "stop blocked: review still pending"
  exit 2
fi

exit 0
