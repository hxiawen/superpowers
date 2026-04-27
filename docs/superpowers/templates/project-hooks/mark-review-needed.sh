#!/usr/bin/env bash
# Project-level review marker (pilot template)

set -euo pipefail

if [ "${TOOL_NAME:-}" != "Edit" ] && [ "${TOOL_NAME:-}" != "Write" ]; then
  exit 0
fi

mkdir -p .claude
printf 'needs_review\n' > .claude/.needs-review
exit 0
