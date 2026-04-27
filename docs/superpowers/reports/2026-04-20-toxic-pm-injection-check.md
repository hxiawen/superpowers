# Toxic PM Injection Runthrough Check

## Scope

Verify whether "toxic PM clarification template injection" runs through at:

- `skills/brainstorming/SKILL.md`
- `skills/writing-plans/SKILL.md`

Out of scope:

- hooks/feedback evolution loop behavior

## Pass Criteria

1. Brainstorming can drive at least 3 of 4 clarification dimensions in live conversation, one question per turn.
2. Writing-plans can show task boundary review traces for each task: value/execution/scope/ambiguity.
3. Output artifacts (spec/plan docs) contain the clarification/boundary-review outcomes, not only chat messages.

## Static Verification (Configuration-Level)

### Brainstorming node

File: `skills/brainstorming/SKILL.md`

- Clarification checkpoints are present:
  - value reality
  - path closure
  - MVP cut
  - AI leverage
- One-question rule is present ("Only one question per message").

Result: PASS (static)

### Writing-plans node

File: `skills/writing-plans/SKILL.md`

- Task boundary review section is present:
  - value boundary
  - execution boundary
  - scope boundary
  - ambiguity scan

Result: PASS (static)

### Governance alignment

File: `SUPERPOWERS_PMSKILLS_FUSION_GUIDE.md`

- Injection points explicitly map to the two nodes:
  - brainstorming = anti-ambiguity questioning
  - writing-plans = boundary review

Result: PASS (static)

## Runtime Verification (Execution-Level)

### Attempted commands

1) Claude CLI run for brainstorming conversation smoke test

```bash
claude -p "<ambiguous feature request>" \
  --plugin-dir "/Users/harry/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7" \
  --dangerously-skip-permissions \
  --max-turns 6
```

2) OpenCode CLI run for explicit skill loading smoke test

```bash
opencode run --print-logs "Use the use_skill tool to load superpowers:brainstorming ..."
```

### Observed status

- Claude CLI process did not return output in this environment (stalled).
- OpenCode CLI failed under sandbox (lock path permission), and still stalled after full-permission rerun.

Result: BLOCKED (environment/runtime), no behavioral transcript could be collected from local CLI runs.

## Artifact Verification (Output-Level)

Because runtime conversation could not complete locally, no fresh spec/plan artifacts were produced in this check run.

Result: BLOCKED (dependent on runtime completion)

## Final Verdict

- Configuration-level runthrough readiness: PASS
- Runtime execution proof in current environment: BLOCKED
- End-to-end "trigger -> presentation -> artifact" closure for this run: PARTIAL (static only)

## Re-run Instructions (when local CLI is available)

1. Run one brainstorming session with an intentionally ambiguous product request.
2. Confirm >=3 clarification dimensions are explicitly asked, one per turn.
3. Approve design and continue to writing-plans.
4. Confirm each task includes value/execution/scope/ambiguity checks.
5. Verify generated spec/plan document contains these conclusions explicitly.
