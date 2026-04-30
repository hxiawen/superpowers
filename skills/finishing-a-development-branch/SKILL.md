---
name: finishing-a-development-branch
description: Use when implementation is complete, all tests pass, and you need to decide how to integrate the work - guides completion of development work by presenting structured options for merge, PR, or cleanup
---

# Finishing a Development Branch

## Overview

Guide completion of development work by presenting clear options and handling chosen workflow.

**Core principle:** Verify tests → Present options → Execute choice → Clean up.

**Announce at start:** "I'm using the finishing-a-development-branch skill to complete this work."

**Scope note:** Treat this as active-PR closure logic. In multi-PR versions, run this closure flow for each PR as it finishes, explicitly switching active PR context on PR transitions, then run version-level aggregation after `PRn` with active PR still bound to `PRn`.

## The Process

### Step 1: Verify Tests

**Before presenting options, verify tests pass:**

```bash
# Run project's test suite
npm test / cargo test / pytest / go test ./...
```

**If tests fail:**
```
Tests failing (<N> failures). Must fix before completing:

[Show failures]

Cannot proceed with merge/PR until tests pass.
```

Stop. Don't proceed to Step 2.

**If tests pass:** Continue to Step 2.

### Step 1.5: Mandatory Final Acceptance Tests

Before completion options, run all three acceptance skills for the active PR closure:

1. `autotest` (automated mock environment, Playwright-capable)
2. `mocktest` (mock data/service scenarios)
3. `devicetest` (required device profiles)

Command sources (ChatBobi project commands):

- `/Users/harry/Documents/chatbobi/.claude/commands/autotest.md`
- `/Users/harry/Documents/chatbobi/.claude/commands/mocktest.md`
- `/Users/harry/Documents/chatbobi/.claude/commands/devicetest.md`

Required logging (must already be in active maintenance, then refreshed here):

- `docs/Vx.y.z-<topic>/Vx.y.z-test.md` must include all three **status lines** in order under the exact H2 **`## Acceptance status (hooks)`** (hooks do not read these from the PR `tdd-log`). PR `tdd-log` remains for TDD case evidence only.

If any of the three tests is missing or failing, stop and do not proceed.
Do not defer missing evidence to "final cleanup later."

### Step 2: Determine Base Branch

```bash
# Try common base branches
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null
```

Or ask: "This branch split from main - is that correct?"

### Step 2.5: Finalize Log Gate (Mandatory)

Before presenting options, ensure PR finalize log exists and is updated:

- `docs/Vx.y.z-<topic>/Vx.y.z-PRn/Vx.y.z-PRn-finalize-log.md`

Required content in finalize log:

- Completed tasks summary
- Final verification evidence summary
- Open risks and follow-ups
- Decision recommendation for merge/PR/keep/discard

Version changelog requirement before Step 3:

- Confirm `docs/Vx.y.z-<topic>/Vx.y.z-changelog.md` contains important corrections from design, development, testing, and release preparation.
- If any important correction is missing, update changelog first. Do not continue to Step 3.

If finalize log is missing, create/update it first. Do not continue to Step 3.

### Step 2.75: Conditional Release Privacy Audit Gate (Publish Path Only)

Run this step only when the human partner explicitly wants to publish/deploy/package artifacts for end users now.
For normal development branch closure (merge/PR/keep/discard without release), skip this step.

If publish path is selected, identify the build artifact directory and run a minimum privacy audit before presenting completion options:

- No developer path leakage (for example `/Users/`)
- No hardcoded credential patterns (for example `sk-ant-`, `sk-proj-`, `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`)
- No shipped local database artifacts (`*.db`, `*.db-shm`, `*.db-wal`)
- No shipped env/credential files (`.env*`, `credentials*`, `*.pem`, `*.key`)

If any item fails:

- Stop immediately
- Record findings with file references
- Do not proceed to Step 3 until fixed and re-verified

### Step 3: Present Options

Present exactly these 4 options:

```
Implementation complete. What would you like to do?

1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Keep the branch as-is (I'll handle it later)
4. Discard this work

Which option?
```

**Don't add explanation** - keep options concise.

### Step 4: Execute Choice

#### Option 1: Merge Locally

```bash
# Switch to base branch
git checkout <base-branch>

# Pull latest
git pull

# Merge feature branch
git merge <feature-branch>

# Verify tests on merged result
<test command>

# If tests pass — clean up both local and remote
git branch -d <feature-branch>
git push origin --delete <feature-branch> 2>/dev/null || true
git remote prune origin
```

Then: Final verification (Step 5)

#### Option 2: Push and Create PR

```bash
# Push branch
git push -u origin <feature-branch>

# Create PR
gh pr create --title "<title>" --body "$(cat <<'EOF'
## Summary
<2-3 bullets of what changed>

## Test Plan
- [ ] <verification steps>
EOF
)"
```

Then: Final verification (Step 5)

#### Option 3: Keep As-Is

Report: "Keeping branch <name>. Worktree preserved at <path>."

**Don't cleanup worktree.**

#### Option 4: Discard

**Confirm first:**
```
This will permanently delete:
- Branch <name>
- All commits: <commit-list>
- Worktree at <path>

Type 'discard' to confirm.
```

Wait for exact confirmation.

If confirmed:
```bash
git checkout <base-branch>
git branch -D <feature-branch>
git push origin --delete <feature-branch> 2>/dev/null || true
git remote prune origin
```

Then: Final verification (Step 5)

### Step 5: Final Verification

After executing the chosen option, run this checklist to confirm clean state:

```bash
# 1. Verify on correct branch
git branch --show-current  # Should be <base-branch>

# 2. Verify no stale remote branches
git branch -r  # Should only show expected remote branches

# 3. Verify local is in sync with remote
git status

# 4. If worktree was used, verify cleanup
git worktree list  # Should not show stale worktrees
```

**For Options 1, 4:**

Check if in worktree:
```bash
git worktree list | grep $(git branch --show-current)
```

If yes:
```bash
git worktree remove <worktree-path>
```

**For Option 2, 3:** Don't cleanup worktree.

**Report final state:**
```
Branch closure complete:
- Current branch: <base-branch>
- Feature branch <name>: deleted (local + remote)
- Worktree: cleaned up / preserved
- Remote tracking: pruned
```

## Quick Reference

| Option | Merge | Push | Keep Worktree | Cleanup Local Branch | Cleanup Remote Branch |
|--------|-------|------|---------------|----------------------|----------------------|
| 1. Merge locally | ✓ | - | - | ✓ | ✓ |
| 2. Create PR | - | ✓ | ✓ | - | - |
| 3. Keep as-is | - | - | ✓ | - | - |
| 4. Discard | - | - | - | ✓ (force) | ✓ |

## Common Mistakes

**Skipping test verification**
- **Problem:** Merge broken code, create failing PR
- **Fix:** Always verify tests before offering options

**Open-ended questions**
- **Problem:** "What should I do next?" → ambiguous
- **Fix:** Present exactly 4 structured options

**Automatic worktree cleanup**
- **Problem:** Remove worktree when might need it (Option 2, 3)
- **Fix:** Only cleanup for Options 1 and 4

**No confirmation for discard**
- **Problem:** Accidentally delete work
- **Fix:** Require typed "discard" confirmation

**Forgetting remote branch cleanup**
- **Problem:** Merged/discarded branches remain on remote indefinitely, accumulating stale branches and confusing repo state
- **Fix:** Always delete remote branch + `git remote prune origin` for Options 1 and 4

## Red Flags

**Never:**
- Proceed with failing tests
- Merge without verifying tests on result
- Delete work without confirmation
- Force-push without explicit request

**Always:**
- Verify tests before offering options
- Run `autotest` + `mocktest` + `devicetest` before completion and record ordered status under **`## Acceptance status (hooks)`** in `Vx.y.z-test.md`
- Run release privacy audit when publish path is requested
- Present exactly 4 options
- Get typed confirmation for Option 4
- Clean up worktree for Options 1 & 4 only
- Delete remote branch + prune for Options 1 & 4
- Report final state after cleanup (Step 5)
- Require `*-finalize-log.md` before completion options

## Integration

**Called by:**
- **subagent-driven-development** (Step 7) - After all tasks complete
- **executing-plans** (Step 5) - After all batches complete

**Pairs with:**
- **using-git-worktrees** - Cleans up worktree created by that skill
