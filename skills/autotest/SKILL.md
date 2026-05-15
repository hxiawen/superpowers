---
name: autotest
description: Run ChatBobi E2E autotest before version completion; record status only in Vx.y.z-test.md under ## Acceptance status (hooks). Command /Users/harry/Documents/chatbobi/.claude/commands/autotest.md
---

# Autotest (Final Acceptance)

Use ChatBobi's project command-based E2E runner as the **first** step of the three environment acceptance sequence (`autotest` → `mocktest` → `devicetest`). Hooks read results **only** from `Vx.y.z-test.md` under **`## Acceptance status (hooks)`** — not from the PR `tdd-log`.

## Source of Truth

Project command file:

- `/Users/harry/Documents/chatbobi/.claude/commands/autotest.md`

Behavior is defined there (Playwright suite, keyword/file mapping, only-test vs test-and-fix mode, and command-specific rules).

## Mandatory Usage

Use when executing **version-level** final acceptance (after TDD/review as your plan dictates). **Do not** treat the PR `tdd-log` as the place to satisfy `autotest` for hooks; preflight still requires that file for case IDs. After the run, write or update the **autotest** line in **`## Acceptance status (hooks)`** in `Vx.y.z-test.md`.

## Startup Gate (Mandatory Preflight)

Resolve the **version root** the same way hooks do: either **two-level** `docs/<product>/<stem>-<topic>/` (e.g. ChatBobi `docs/plugin/pv0.1.13-dom-adapt/`) or **one-level** `docs/<stem>-<topic>/` under `docs/` only. In the paths below, `Vx.y.z` is the **directory basename stem** (e.g. `pv0.1.13`), not literal `V`/`x`/`y`/`z`.

Before running autotest, validate both files exist:

- `<version-root>/Vx.y.z-PRn/Vx.y.z-PRn-tdd-log.md`
- `<version-root>/Vx.y.z-test.md`

Then validate both files contain detailed test cases:

- PR log includes case IDs (for example `T-001`/`TC-001`)
- Version test file includes `## Detailed Test Cases` and at least one case ID

Preflight policy for quality fields:

- Startup preflight does not block on the 6 quality fields
- Strict quality-field enforcement is applied by `Stop` gate (`hooks/test-acceptance-gate`)
- Missing quality fields at stop will block completion with structured `missing_fields`

If any check fails: do not start. Return `BLOCKED` and ask for detailed test cases first.

Before starting autotest, ask and record:

- test scope (which PR/version scope is under validation)
- run mode (`only-test` or `test-and-fix`)
- whether a pre-existing baseline run is needed before any code/spec change

If scope/mode/baseline intent is unclear, autotest must be blocked until clarified.

## Contract Alignment Note

`autotest` preflight originally guaranteed format presence (docs + case IDs).
Current templates also define test effectiveness fields. To avoid contract drift, preflight expectations must include:

- `T-xxx` quality fields in PR-level evidence log
- `TC-xxx` coverage/expectation/blind-spot sections at version level

## Required Outputs

Record the **autotest** status line **only** in `docs/.../Vx.y.z-test.md` under the exact H2 **`## Acceptance status (hooks)`** (see `version-test-template.md`).  
Do not add `autotest: …` to the PR `tdd-log` for hook purposes; that file is for TDD case evidence only.

## Minimum Result Fields

- command source path
- mode used (only-test / test-and-fix)
- scope
- command(s) executed
- **build version (MUST read from `app/plugin/.output/chrome-mv3/manifest.json` after `npm run build` completes — `buildNumber` auto-increments each build; reading before build reports a stale version)**
- **bundle size (from build output `Σ Total size` line — required for Quality Gate monitoring; flag any single-PR increase > 5KB vs a prior baseline)**
- pass/fail summary
- failed cases with evidence
- rerun status

When reporting version + bundle together, use one line, for example: `Build: X.Y.Z.N | Bundle: XXX kB`. Match project wording in `Vx.y.z-test.md` if templates use `构建版本` / `包体`.

## Completion Rule

- No version completion claim is valid without an `autotest` status line under **`## Acceptance status (hooks)`** in `Vx.y.z-test.md` (in order: autotest → mocktest → devicetest).
- If detailed test cases are missing in either file, autotest must be rejected before execution.
- If quality fields/sections are missing (`Test Point`, `Expected Result`, `Assertion Target`, `Coverage Matrix`, `Expectation Index`, `Known Blind Spots`), autotest output is not a valid acceptance conclusion.
- Never modify spec/test-spec assertion logic during autotest without explicit human confirmation first.

## Template References

- `docs/superpowers/templates/tdd-report-template.md`
- `docs/superpowers/templates/versioning/version-test-template.md`
- `docs/superpowers/templates/e2e-case-template.md`
