# TDD Evidence Report

**Version:** `Vx.y.z-<topic>`
**PR:** `Vx.y.z-PRn`
**Feature:** `<feature-name>`
**Date:** `YYYY-MM-DD`
**Spec:** `docs/Vx.y.z-<topic>/Vx.y.z-spec.md`
**Plan:** `docs/Vx.y.z-<topic>/Vx.y.z-plan.md`
**Log Target:** `docs/Vx.y.z-<topic>/Vx.y.z-PRn/Vx.y.z-PRn-tdd-log.md`

## PR loop timing (mandatory)

- This file is initialized when `PRn` starts (not at final cleanup).
- Keep updating this file throughout the PR loop: `TDD -> Development -> Review`, then debug as needed.
- This log holds **TDD case evidence** (case IDs, Test Point, Expected Result, Assertion Target). The **autotest / mocktest / devicetest** run results and order live only in `docs/.../Vx.y.z-test.md` under **`## Acceptance status (hooks)`** — see `version-test-template.md`.

## Mapping matrix

| Spec requirement | plan task | test ID | test scope | test point | status |
|---|---|---|---|---|---|
| `<spec-item-1>` | `Task N` | `T-001` | `unit/integration/e2e` | `<component/storage/api/message-path>` | `pending/pass/fail` |
| `<spec-item-2>` | `Task N` | `T-002` | `unit/integration/e2e` | `<component/storage/api/message-path>` | `pending/pass/fail` |

---

## Test evidence records

### T-001 `<short-behavior-name>`

- **Test scope:** `unit/integration/e2e`
- **Goal:** `<behavior being validated>`
- **Test point:** `<exact object/state/path being verified>`
- **Spec link:** `<section or bullet>`
- **Plan link:** `<task and step>`
- **Preconditions:** `<required data/environment/setup>`
- **Actions:** `<reproducible action steps>`
- **Expected result:** `<business expectation in plain language>`
- **Assertion target:** `<machine-checkable assertion target, e.g. expect(x).toBe(y)>`
- **RED command:** `<exact command>`
- **RED evidence:** `<key failing output lines>`
- **GREEN command:** `<exact command>`
- **GREEN evidence:** `<key passing output lines>`
- **Negative/edge case:** `<error path or boundary condition validated>`
- **Out of scope:** `<explicitly not covered by this case>`
- **Rerun after change:** `<yes/no and why>`
- **Latest exit code:** `<0/non-zero>`

### T-002 `<short-behavior-name>`

- **Test scope:** `unit/integration/e2e`
- **Goal:** `<behavior being validated>`
- **Test point:** `<exact object/state/path being verified>`
- **Spec link:** `<section or bullet>`
- **Plan link:** `<task and step>`
- **Preconditions:** `<required data/environment/setup>`
- **Actions:** `<reproducible action steps>`
- **Expected result:** `<business expectation in plain language>`
- **Assertion target:** `<machine-checkable assertion target, e.g. expect(x).toBe(y)>`
- **RED command:** `<exact command>`
- **RED evidence:** `<key failing output lines>`
- **GREEN command:** `<exact command>`
- **GREEN evidence:** `<key passing output lines>`
- **Negative/edge case:** `<error path or boundary condition validated>`
- **Out of scope:** `<explicitly not covered by this case>`
- **Rerun after change:** `<yes/no and why>`
- **Latest exit code:** `<0/non-zero>`

---

## Regression coverage

| risk_id | risk_description | linked_case_id | last_result |
|---|---|---|---|
| `R-001` | `<high-risk scenario>` | `T-00X` | `pass/fail` |
| `R-002` | `<high-risk scenario>` | `T-00Y` | `pass/fail` |

## Known gaps and risks

- `<not covered behavior>`
- `<follow-up action>`

## Completion evidence summary

- **Claim:** `<what is complete>`
- **Verification command:** `<command run in current turn>`
- **Exit code:** `<0/non-zero>`
- **Result summary:** `<pass/fail counts>`
- **Artifacts updated:** `<paths>`
