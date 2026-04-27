#!/usr/bin/env bash
# Test: verification-before-completion skill
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/test-helpers.sh"

echo "=== Test: verification-before-completion skill ==="
echo ""

echo "Test 1: Skill recognition..."
output=$(run_claude "What is the verification-before-completion skill and when should it be used?" 30)
if ! assert_contains "$output" "verification-before-completion\|Verification Before Completion" "Skill is recognized"; then
    exit 1
fi
echo ""

echo "Test 2: Fresh evidence requirement..."
output=$(run_claude "Can I claim work is complete based on a test run from earlier in the session?" 30)
if ! assert_contains "$output" "fresh\|current\|same message\|run.*again\|cannot claim" "Requires fresh evidence"; then
    exit 1
fi
echo ""

echo "Test 3: Evidence block fields..."
output=$(run_claude "Before I claim completion, what evidence fields should I include?" 30)
if ! assert_contains "$output" "command" "Mentions command field"; then
    exit 1
fi
if ! assert_contains "$output" "exit.*code\|exit_code" "Mentions exit code field"; then
    exit 1
fi
if ! assert_contains "$output" "result.*summary\|evidence" "Mentions result/evidence summary"; then
    exit 1
fi

echo ""
echo "=== All verification-before-completion skill tests passed ==="
