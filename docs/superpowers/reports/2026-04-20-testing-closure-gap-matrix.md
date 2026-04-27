# Superpowers Testing Closure Gap Matrix

## Scope

This matrix compares declared testing/verification expectations against enforceable artifacts and gates.

## Gap Matrix

| Area | Declared Rule | Current Enforcement | Gap | Recommended Fix |
|---|---|---|---|---|
| Planning artifacts | `writing-plans` requires concrete test steps | Plan quality mostly relies on self-review text | No mandatory test report artifact | Require per-feature TDD report (`reports/*-tdd-report.md`) |
| TDD discipline | `test-driven-development` requires RED->GREEN | Trigger tests validate skill invocation, not red/green evidence | "Says TDD" can pass without proof | Require RED/GREEN commands + outcomes in task execution evidence |
| Completion claims | `verification-before-completion` requires fresh evidence | No consistent output schema in completion replies | Success claims can be vague | Add mandatory completion evidence block with command/exit/output summary |
| Execution workflow | `executing-plans` says run verifications | No explicit integration with verification-before-completion in every task | Verification quality varies by operator | Add per-task evidence gate and rerun rule after changes |
| Subagent execution | `subagent-driven-development` emphasizes quality gates | Implementer prompt says "follow TDD if task says to" | TDD can be treated as optional | Make TDD required by default, require evidence in subagent report |
| Code review quality | Review is required in multiple flows | Review content not standardized for spec drift/security checks | Real defects can escape non-systematic review | Add Stage1/Stage2 order + spec drift + security minimal scan checklist |
| Test harness | Existing scripts check skill triggering | Mostly validates skill loading or text responses | No automated assertion on evidence artifacts | Extend tests with verification-before-completion and artifact assertions |

## Priority Order

1. Add evidence schema and enforce in execution/verification skills.
2. Add report template and plan-to-report mapping.
3. Add review quality checkpoints (Stage1/Stage2 + spec drift + security scan).
4. Upgrade test harness to assert evidence-bearing outputs.

## Success Criteria

- Every implementation task maps to at least one RED/GREEN evidence record.
- Completion statements include fresh command evidence.
- Reviews explicitly check plan/spec compliance before code quality.
- Generated artifacts allow external audit without replaying the full chat.
