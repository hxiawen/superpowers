# Version Test Summary

**Version:** `Vx.y.z-<topic>`
**Date:** `YYYY-MM-DD`

## Maintenance Timing (Mandatory)

- Create this file when the version is initialized; update it as PRs close.
- **`Vx.y.z-spec.md`** must contain **`## Superpowers pipeline (hooks)`** with `Full extension acceptance pipeline: Yes` or `No` before `/writing-plans` (see `brainstorming` checklist). **No** skips extension test-order / manifest / drift hooks only; **Figma Live Design Sync** still follows the plan.
- The **only** machine source for `autotest` / `mocktest` / `devicetest` status and order, plus `figma-live-sync` when the plan includes `Figma Live Design Sync`, is the section **`## Acceptance status (hooks)`** below (title must be exact; no variants).
- Maintain `Coverage Matrix` / `Expectation Index` / `Known Blind Spots` and detailed cases throughout; do not wait until the last minute to add structure.

## Acceptance status (hooks)

Hooks (`enforce-acceptance-order`, `test-acceptance-gate`) read **only** the lines in this section (from this `##` through the line before the next top-level `##` at the same `##` depth).  
Put **three separate lines** with real statuses first; if the plan includes `Figma Live Design Sync`, add `figma-live-sync` as the fourth line. Avoid extra narrative in this block.

```text
autotest: pass
mocktest: pass
devicetest: pass
# Only when Vx.y.z-plan.md includes Figma Live Design Sync:
figma-live-sync: pass
```

Supported tokens include `autotest: pass`, `autotest：通过`, and the other status words accepted by `hooks/acceptance-order-common` (e.g. fail, blocked, skip, 失败).

Narrative sections later (e.g. **Expectation Index**) may mention `mocktest` or `autotest` by name; they **do not** affect hook order, because matching is **scoped to this section only**.

## Required acceptance coverage (reference)

- autotest
- mocktest
- devicetest
- figma-live-sync (only when the plan includes Figma Live Design Sync; legacy codetofigma is accepted for old plans)

Execution order in production remains: `autotest -> mocktest -> devicetest`, followed by `figma-live-sync` when planned (enforced only inside **Acceptance status (hooks)**).

## Command Sources

- autotest: `/Users/harry/Documents/chatbobi/.claude/commands/autotest.md`
- mocktest: `/Users/harry/Documents/chatbobi/.claude/commands/mocktest.md`
- devicetest: `/Users/harry/Documents/chatbobi/.claude/commands/devicetest.md`

## PR coverage (optional)

Use this for human planning across `PR1..PRn` if useful. Hooks do **not** require per-PR cells for the three test types; authoritative status is **only** in **Acceptance status (hooks)**.

| PR | note |
|---|---|
| `Vx.y.z-PR1` | scope / owner |
| `Vx.y.z-PR2` | scope / owner |

## Detailed Test Cases

- `TC-001` `<case description>` | spec: `<path/to/spec.ts or test file>` | assertion: `<target assertion summary>`
- `TC-002` `<case description>` | spec: `<path/to/spec.ts or test file>` | assertion: `<target assertion summary>`

Case IDs must follow strict format: `\b(T|TC)-[0-9]{3}\b`.

## Coverage Matrix

| feature_domain | must_cover_test_point | linked_case_id | layer (unit/integration/e2e) | status |
|---|---|---|---|---|
| `<domain-1>` | `<critical state/path>` | `TC-00X` | `unit/integration/e2e` | `pass/fail/pending` |
| `<domain-2>` | `<critical state/path>` | `TC-00Y` | `unit/integration/e2e` | `pass/fail/pending` |

## Expectation Index

| case_id | expected_result | assertion_target | command_or_suite |
|---|---|---|---|
| `TC-00X` | `<business expectation>` | `<machine-checkable assertion>` | `<playwright/vitest command or suite>` |
| `TC-00Y` | `<business expectation>` | `<machine-checkable assertion>` | `<playwright/vitest command or suite>` |

## Autotest aggregate (version level)

- executed suites
- pass/fail summary
- key failures and reruns

## Risks / follow-ups

- unresolved issues
- deferred tests

## Known blind spots

- `<intentionally not covered in this version>`
- `<coverage gap with mitigation or next-step plan>`
