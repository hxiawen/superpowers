---
name: executing-plans
description: Use when you have a written implementation plan to execute in a separate session with review checkpoints
---

# Executing Plans

## Overview

Load plan, review critically, execute all tasks, report when complete.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

**Note:** Tell your human partner that Superpowers works much better with access to subagents. The quality of its work will be significantly higher if run on a platform with subagent support (such as Claude Code or Codex). If subagents are available, use superpowers:subagent-driven-development instead of this skill.

## The Process

### Step 1: Load and Review Plan
1. Read plan file
2. Review critically - identify any questions or concerns about the plan
3. Resolve version root and active PR folder from plan (`docs/Vx.y.z-<topic>/Vx.y.z-PRn/`)
4. Resolve PR execution order (`PR1..PRn`) from plan grouping
5. Ensure startup artifacts exist for active PR before execution (`PRn` folder, `PRn-tdd-log`, version-level `Vx.y.z-test.md`)
6. If concerns: Raise them with your human partner before starting
7. If no concerns: Create TodoWrite and proceed

### Step 2: Execute Tasks (Per Active PR)

For each task in the active PR:
1. Mark as in_progress
2. Follow each step exactly (plan has bite-sized steps)
3. Run verifications as specified
4. Record RED/GREEN evidence in `docs/Vx.y.z-<topic>/Vx.y.z-PRn/Vx.y.z-PRn-tdd-log.md`
5. Update PR doc pack:
   - `Vx.y.z-PRn-subagent-summary.md`
   - `Vx.y.z-PRn-review-report.md`
   - Migration rule: if `Vx.y.z-PRn-code-review.md` exists and `Vx.y.z-PRn-review-report.md` is missing, rename it to `Vx.y.z-PRn-review-report.md`
   - Ownership rule: `Vx.y.z-PRn-review-report.md` is reviewer-owned output. It must summarize findings from spec/code-quality/code-reviewer reviews, not implementer self-review notes.
6. If task implementation or test reruns introduce important corrections, append them immediately to `docs/Vx.y.z-<topic>/Vx.y.z-changelog.md`
7. Before marking completed, run `verification-before-completion` gate and include fresh command evidence
8. Mark as completed

After all active-PR tasks are completed:

9. Run acceptance sequence in order: `autotest -> mocktest -> devicetest` and record results only in `Vx.y.z-test.md` under **`## Acceptance status (hooks)`**
10. If acceptance fails, debug/fix and rerun acceptance until pass
11. Update active PR finalize evidence (`Vx.y.z-PRn-finalize-log.md`)
12. Explicitly switch active PR context to the next PR in grouping, then repeat Step 2

### Step 3: Complete Development

After all PRs (`PR1..PRn`) complete and verify:
- Ensure version-level regression/aggregation is reflected in `docs/Vx.y.z-<topic>/Vx.y.z-test.md` while active PR context remains bound to `PRn`
- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use superpowers:finishing-a-development-branch
- Update version governance docs:
  - `docs/Vx.y.z-<topic>/Vx.y.z-changelog.md`
  - `docs/Vx.y.z-<topic>/Vx.y.z-decisions.md`
- Ensure this version changelog includes important corrections from design/development/testing/release phases before final handoff
- Follow finishing skill to verify tests, present options, execute choice

## When to Stop and Ask for Help

**STOP executing immediately when:**
- Hit a blocker (missing dependency, test fails, instruction unclear)
- Plan has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly

**Ask for clarification rather than guessing.**

## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- Partner updates the plan based on your feedback
- Fundamental approach needs rethinking

**Don't force through blockers** - stop and ask.

## Remember
- Review plan critically first
- Follow plan steps exactly
- Don't skip verifications
- No completion claims without same-message fresh evidence
- Any code change requires verification rerun
- Reference skills when plan says to
- Stop when blocked, don't guess
- Never start implementation on main/master branch without explicit user consent

## Integration

**Required workflow skills:**
- **superpowers:using-git-worktrees** - Infrastructure utility; primarily required by `subagent-driven-development` Stage 5 startup
- **superpowers:writing-plans** - Creates the plan this skill executes
- **superpowers:requesting-code-review** - Review-stage template for reviewer conclusions when external review dispatch is needed
- **superpowers:verification-before-completion** - REQUIRED before any completion claim
- **superpowers:finishing-a-development-branch** - Complete development after all tasks

**Required PR artifacts before completion:**
- `Vx.y.z-PRn-tdd-log.md`
- `Vx.y.z-PRn-subagent-summary.md`
- `Vx.y.z-PRn-review-report.md`
- `Vx.y.z-PRn-finalize-log.md`
- `Vx.y.z-test.md` (version-level test summary; three acceptance status lines under **`## Acceptance status (hooks)`**)
