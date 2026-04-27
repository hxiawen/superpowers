#!/usr/bin/env bash
# Project-level pre-commit quality gate (pilot template)

set -euo pipefail

if [ "${TOOL_NAME:-}" != "Bash" ]; then
  exit 0
fi

if [ -z "${TOOL_INPUT:-}" ]; then
  exit 0
fi

if ! printf '%s' "$TOOL_INPUT" | rg -q "git commit"; then
  exit 0
fi

if [ -f "package.json" ]; then
  if npm run -s typecheck >/dev/null 2>&1; then
    exit 0
  fi
  echo "typecheck failed, commit blocked"
  exit 2
fi

exit 0
