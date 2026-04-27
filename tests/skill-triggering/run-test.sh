#!/usr/bin/env bash
# Test skill triggering with naive prompts
# Usage: ./run-test.sh <skill-name> <prompt-file>
#
# Tests whether Claude triggers a skill based on a natural prompt
# (without explicitly mentioning the skill)

set -e

SKILL_NAME="$1"
PROMPT_FILE="$2"
MAX_TURNS="${3:-3}"

if [ -z "$SKILL_NAME" ] || [ -z "$PROMPT_FILE" ]; then
    echo "Usage: $0 <skill-name> <prompt-file> [max-turns]"
    echo "Example: $0 systematic-debugging ./test-prompts/debugging.txt"
    exit 1
fi

# Get the directory where this script lives (should be tests/skill-triggering)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Get the superpowers plugin root (two levels up from tests/skill-triggering)
PLUGIN_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

TIMESTAMP=$(date +%s)
OUTPUT_DIR="/tmp/superpowers-tests/${TIMESTAMP}/skill-triggering/${SKILL_NAME}"
mkdir -p "$OUTPUT_DIR"

# Read prompt from file
PROMPT=$(cat "$PROMPT_FILE")

echo "=== Skill Triggering Test ==="
echo "Skill: $SKILL_NAME"
echo "Prompt file: $PROMPT_FILE"
echo "Max turns: $MAX_TURNS"
echo "Output dir: $OUTPUT_DIR"
echo ""

# Copy prompt for reference
cp "$PROMPT_FILE" "$OUTPUT_DIR/prompt.txt"

# Run Claude
LOG_FILE="$OUTPUT_DIR/claude-output.json"
cd "$OUTPUT_DIR"

echo "Plugin dir: $PLUGIN_DIR"
echo "Running claude -p with naive prompt..."
timeout 300 claude -p "$PROMPT" \
    --plugin-dir "$PLUGIN_DIR" \
    --dangerously-skip-permissions \
    --max-turns "$MAX_TURNS" \
    --output-format stream-json \
    > "$LOG_FILE" 2>&1 || true

echo ""
echo "=== Results ==="

# Check if skill was triggered (look for Skill tool invocation)
# In stream-json, tool invocations have "name":"Skill" (not "tool":"Skill")
# Match either "skill":"skillname" or "skill":"namespace:skillname"
SKILL_PATTERN='"skill":"([^"]*:)?'"${SKILL_NAME}"'"'
if grep -q '"name":"Skill"' "$LOG_FILE" && grep -qE "$SKILL_PATTERN" "$LOG_FILE"; then
    echo "✅ PASS: Skill '$SKILL_NAME' was triggered"
    TRIGGERED=true
else
    echo "❌ FAIL: Skill '$SKILL_NAME' was NOT triggered"
    TRIGGERED=false
fi

# Extra assertions for verification-before-completion
if [ "$SKILL_NAME" = "verification-before-completion" ] && [ "$TRIGGERED" = "true" ]; then
    if grep -qiE "fresh verification|run.*command|evidence|no completion claims|same message" "$LOG_FILE"; then
        echo "✅ PASS: verification-before-completion guidance detected"
    else
        echo "❌ FAIL: verification-before-completion guidance not detected"
        TRIGGERED=false
    fi
fi

# Extra assertions for systematic-debugging
if [ "$SKILL_NAME" = "systematic-debugging" ] && [ "$TRIGGERED" = "true" ]; then
    if grep -qiE "root cause|phase 1|no fixes without root cause|four phases" "$LOG_FILE"; then
        echo "✅ PASS: systematic-debugging core guidance detected"
    else
        echo "❌ FAIL: systematic-debugging core guidance not detected"
        TRIGGERED=false
    fi
fi

# Extra assertions for test-driven-development
if [ "$SKILL_NAME" = "test-driven-development" ] && [ "$TRIGGERED" = "true" ]; then
    if grep -qiE "red|green|failing test|no production code without a failing test first" "$LOG_FILE"; then
        echo "✅ PASS: test-driven-development core guidance detected"
    else
        echo "❌ FAIL: test-driven-development core guidance not detected"
        TRIGGERED=false
    fi
fi

# Extra assertions for executing-plans
if [ "$SKILL_NAME" = "executing-plans" ] && [ "$TRIGGERED" = "true" ]; then
    if grep -qiE "read plan|todowrite|verification|finishing-a-development-branch" "$LOG_FILE"; then
        echo "✅ PASS: executing-plans core guidance detected"
    else
        echo "❌ FAIL: executing-plans core guidance not detected"
        TRIGGERED=false
    fi
fi

# Show what skills WERE triggered
echo ""
echo "Skills triggered in this run:"
grep -o '"skill":"[^"]*"' "$LOG_FILE" 2>/dev/null | sort -u || echo "  (none)"

# Show first assistant message
echo ""
echo "First assistant response (truncated):"
grep '"type":"assistant"' "$LOG_FILE" | head -1 | jq -r '.message.content[0].text // .message.content' 2>/dev/null | head -c 500 || echo "  (could not extract)"

echo ""
echo "Full log: $LOG_FILE"
echo "Timestamp: $TIMESTAMP"

if [ "$TRIGGERED" = "true" ]; then
    exit 0
else
    exit 1
fi
