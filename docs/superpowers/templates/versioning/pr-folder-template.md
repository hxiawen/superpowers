# PR folder template

Each PR folder (`Vx.y.z-PRn/`) must contain:

- `Vx.y.z-PRn-tdd-log.md`
- `Vx.y.z-PRn-subagent-summary.md`
- `Vx.y.z-PRn-review-report.md`
- `Vx.y.z-PRn-finalize-log.md`

## File purpose

- `tdd-log`: RED/GREEN test evidence, case IDs, and per-case `Test Point` / `Expected Result` / `Assertion Target`
- `subagent-summary`: task-by-task subagent outputs and escalations
- `review-report`: consolidated reviewer conclusions for the PR (source: spec/code-quality/code-reviewer outputs, not implementer self-review)
- `finalize-log`: final readiness summary and merge/PR decision context

## Completion gate

A PR is not finishable unless all required files exist and have current content.

## Legacy Migration Rule

If a legacy `Vx.y.z-PRn-code-review.md` exists and `Vx.y.z-PRn-review-report.md` is missing, rename the legacy file to `Vx.y.z-PRn-review-report.md` before continuing. The unified review artifact name is `review-report.md`.

## Version-level acceptance (autotest / mocktest / devicetest)

**Hooks do not read** `autotest` / `mocktest` / `devicetest` **results from the PR tdd-log**. Record ordered results **only** in the version file `docs/.../Vx.y.z-test.md` under the exact heading **`## Acceptance status (hooks)`** (see `version-test-template.md`).  
Execution order remains `autotest -> mocktest -> devicetest` in that section.

## TDD log format minimum

`Vx.y.z-PRn-tdd-log.md` must include:

- case IDs using strict format: `T-001` / `TC-001` (`\b(T|TC)-[0-9]{3}\b`)
- per-case quality fields: `Test Point`, `Expected Result`, `Assertion Target`
