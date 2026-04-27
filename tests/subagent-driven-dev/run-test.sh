#!/usr/bin/env bash
# Run a subagent-driven-development test
# Usage: ./run-test.sh <test-name> [--plugin-dir <path>]
#
# Example:
#   ./run-test.sh go-fractals
#   ./run-test.sh svelte-todo --plugin-dir /path/to/superpowers

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEST_NAME="${1:?Usage: $0 <test-name> [--plugin-dir <path>]}"
shift

# Parse optional arguments
PLUGIN_DIR=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --plugin-dir)
      PLUGIN_DIR="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Default plugin dir to parent of tests directory
if [[ -z "$PLUGIN_DIR" ]]; then
  PLUGIN_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
fi

# Verify test exists
TEST_DIR="$SCRIPT_DIR/$TEST_NAME"
if [[ ! -d "$TEST_DIR" ]]; then
  echo "Error: Test '$TEST_NAME' not found at $TEST_DIR"
  echo "Available tests:"
  ls -1 "$SCRIPT_DIR" | grep -v '\.sh$' | grep -v '\.md$'
  exit 1
fi

# Create timestamped output directory
TIMESTAMP=$(date +%s)
OUTPUT_BASE="/tmp/superpowers-tests/$TIMESTAMP/subagent-driven-development"
OUTPUT_DIR="$OUTPUT_BASE/$TEST_NAME"
mkdir -p "$OUTPUT_DIR"

echo "=== Subagent-Driven Development Test ==="
echo "Test: $TEST_NAME"
echo "Output: $OUTPUT_DIR"
echo "Plugin: $PLUGIN_DIR"
echo ""

# Scaffold the project
echo ">>> Scaffolding project..."
"$TEST_DIR/scaffold.sh" "$OUTPUT_DIR/project"
echo ""

# Prepare the prompt
PLAN_PATH="$OUTPUT_DIR/project/plan.md"
PROMPT="Execute this plan using superpowers:subagent-driven-development. The plan is at: $PLAN_PATH"

# Run Claude with JSON output for token tracking
LOG_FILE="$OUTPUT_DIR/claude-output.json"
echo ">>> Running Claude..."
echo "Prompt: $PROMPT"
echo "Log file: $LOG_FILE"
echo ""

# Run claude and capture output
# Using stream-json to get token usage stats
# --dangerously-skip-permissions for automated testing (subagents don't inherit parent settings)
cd "$OUTPUT_DIR/project"
set +e
claude -p "$PROMPT" \
  --plugin-dir "$PLUGIN_DIR" \
  --dangerously-skip-permissions \
  --output-format stream-json \
  --verbose \
  > "$LOG_FILE" 2>&1
CLAUDE_EXIT_CODE=$?
set -e

# Extract final stats
echo ""
echo ">>> Test complete"
echo "Project directory: $OUTPUT_DIR/project"
echo "Claude log: $LOG_FILE"
echo "Claude exit code: $CLAUDE_EXIT_CODE"
echo ""

# Automated pass/fail checks (instead of log-only collection)
FAILED=0
if rg -q '"name":"Skill".*"skill":"superpowers:subagent-driven-development"' "$LOG_FILE"; then
  echo "✅ PASS: subagent-driven-development skill was triggered"
else
  echo "❌ FAIL: subagent-driven-development skill was not triggered"
  FAILED=1
fi

if rg -q '"name":"TodoWrite"' "$LOG_FILE"; then
  echo "✅ PASS: task tracking (TodoWrite) detected"
else
  echo "❌ FAIL: TodoWrite not detected"
  FAILED=1
fi

if rg -q '"type":"result"' "$LOG_FILE"; then
  echo "✅ PASS: result event detected"
else
  echo "❌ FAIL: result event not detected"
  FAILED=1
fi

if [ "$CLAUDE_EXIT_CODE" -ne 0 ]; then
  echo "❌ FAIL: claude command exited non-zero ($CLAUDE_EXIT_CODE)"
  FAILED=1
else
  echo "✅ PASS: claude command exited successfully"
fi

# Show token usage if available
if command -v jq &> /dev/null; then
  echo ">>> Token usage:"
  # Extract usage from the last message with usage info
  jq -s '[.[] | select(.type == "result")] | last | .usage' "$LOG_FILE" 2>/dev/null || echo "(could not parse usage)"
  echo ""
fi

echo ">>> Next steps:"
echo "1. Review the project: cd $OUTPUT_DIR/project"
echo "2. Review Claude's log: less $LOG_FILE"
echo "3. Check if tests pass:"
if [[ "$TEST_NAME" == "go-fractals" ]]; then
  echo "   cd $OUTPUT_DIR/project && go test ./..."
elif [[ "$TEST_NAME" == "svelte-todo" ]]; then
  echo "   cd $OUTPUT_DIR/project && npm test && npx playwright test"
fi

if [ "$FAILED" -ne 0 ]; then
  exit 1
fi

echo "✅ PASS: subagent-driven-dev test completed"
exit 0
