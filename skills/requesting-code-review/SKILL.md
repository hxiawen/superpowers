---
name: requesting-code-review
description: Use when completing tasks, implementing major features, or before merging to verify work meets requirements
---

# Requesting Code Review

Dispatch superpowers:code-reviewer subagent to catch issues before they cascade. The reviewer gets precisely crafted context for evaluation — never your session's history. This keeps the reviewer focused on the work product, not your thought process, and preserves your own context for continued work.

**Core principle:** Review early, review often.

## Review Positioning (Upstream/Downstream)

Treat review as a hard stage boundary, not an optional quality pass.

**Upstream prerequisites (must exist before review starts):**
- Implementation for active scope (task/PR) is complete
- RED/GREEN evidence is recorded in active `Vx.y.z-PRn-tdd-log.md`
- Scope baseline is explicit (`plan/spec` + commit range)
- Active PR context is explicitly set to the PR under review (`PRn`)

**In-stage obligations:**
- Run Stage 1 then Stage 2 in strict order
- Keep reviewer conclusions in reviewer-owned artifact only: `Vx.y.z-PRn-review-report.md`
- Keep implementer self-review separate: `Vx.y.z-PRn-subagent-summary.md`

**Downstream gate (to proceed):**
- No unresolved Critical/Important review findings
- No unresolved stage-order violations
- Review artifacts updated and attributable to reviewer output

## When to Request Review

**Mandatory:**
- After each task in subagent-driven development
- After completing major feature
- Before merge to main

**Optional but valuable:**
- When stuck (fresh perspective)
- Before refactoring (baseline check)
- After fixing complex bug

## How to Request

**1. Get git SHAs:**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

**2. Dispatch code-reviewer subagent:**

Use Task tool with superpowers:code-reviewer type, fill template at `code-reviewer.md`

**Placeholders:**
- `{WHAT_WAS_IMPLEMENTED}` - What you just built
- `{PLAN_OR_REQUIREMENTS}` - What it should do
- `{BASE_SHA}` - Starting commit
- `{HEAD_SHA}` - Ending commit
- `{DESCRIPTION}` - Brief summary

**3. Act on feedback:**
- Fix Critical issues immediately
- Fix Important issues before proceeding
- Note Minor issues for later
- Push back if reviewer is wrong (with reasoning)
- Write/refresh consolidated review output in `docs/Vx.y.z-<topic>/Vx.y.z-PRn/Vx.y.z-PRn-review-report.md`
- If only legacy `Vx.y.z-PRn-code-review.md` exists, rename it to `Vx.y.z-PRn-review-report.md` before appending new review content
- `Vx.y.z-PRn-review-report.md` must be based on reviewer output. Implementer self-review notes cannot be used as approval or sign-off.

## Review Order (Mandatory)

Run reviews in this order:

1. **Stage 1: Spec/Plan Compliance**
   - Verify requested behavior is fully implemented
   - Detect missing requirements
   - Detect extra features not requested (Spec Drift)
2. **Stage 2: Code Quality**
   - Run only if Stage 1 has no blocking issues
   - Evaluate maintainability, testing quality, and design quality
   - Enforce baseline coding standards for touched files:
     - TypeScript repos: strict typing enabled for the project; no unreviewed `any`
     - Naming baseline: PascalCase (components/types), camelCase (functions/variables), kebab-case (filenames where project style expects it)
     - Flag deviations as quality findings, not optional style notes

If Stage 1 has unresolved important/critical issues, do not proceed to Stage 2.

## Minimum Security and Drift Checklist

During review, include these checks:

- **Spec Drift:** Any route/API/schema/capability not present in plan/spec?
- **Secrets leakage:** Hardcoded keys/tokens/passwords in changed files? Include scans for patterns like `sk-ant-`, `sk-proj-`, `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, `password=...`.
- **Risky execution patterns:** Dangerous code execution or HTML injection patterns such as `eval(`, `dangerouslySetInnerHTML`, or unsafe `innerHTML` assignment.
- **Injection-prone concatenation:** Obvious SQL/command/query string concatenation with untrusted input.
- **Path exposure:** Absolute developer path leakage (for example `/Users/`) or unsafe path handling patterns.

If any item is found, report with file references and severity.

## Example

```
[Just completed Task 2: Add verification function]

You: Let me request code review before proceeding.

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
HEAD_SHA=$(git rev-parse HEAD)

[Dispatch superpowers:code-reviewer subagent]
  WHAT_WAS_IMPLEMENTED: Verification and repair functions for conversation index
  PLAN_OR_REQUIREMENTS: Task 2 from docs/Vx.y.z-<topic>/Vx.y.z-plan.md
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661
  DESCRIPTION: Added verifyIndex() and repairIndex() with 4 issue types

[Subagent returns]:
  Strengths: Clean architecture, real tests
  Issues:
    Important: Missing progress indicators
    Minor: Magic number (100) for reporting interval
  Assessment: Ready to proceed

You: [Fix progress indicators]
[Continue to Task 3]
```

## Integration with Workflows

**Subagent-Driven Development:**
- Review after EACH task
- Catch issues before they compound
- Fix before moving to next task

**Executing Plans:**
- Review after each batch (3 tasks)
- Get feedback, apply, continue

**Ad-Hoc Development:**
- Review before merge
- Review when stuck

## Red Flags

**Never:**
- Skip review because "it's simple"
- Ignore Critical issues
- Proceed with unfixed Important issues
- Argue with valid technical feedback

**If reviewer wrong:**
- Push back with technical reasoning
- Show code/tests that prove it works
- Request clarification

See template at: requesting-code-review/code-reviewer.md
