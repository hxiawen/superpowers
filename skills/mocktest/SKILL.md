---
name: mocktest
description: Run ChatBobi mock-environment mocktest before version completion; record status only in Vx.y.z-test.md under ## Acceptance status (hooks). Command /Users/harry/Documents/chatbobi/.claude/commands/mocktest.md
---

# MockTest (Final Acceptance)

Use ChatBobi's project command-based mock-environment acceptance as the **second** step after `autotest` in the ordered sequence. Hooks read the **mocktest** status **only** from **`## Acceptance status (hooks)`** in `Vx.y.z-test.md`.

## Source of Truth

Project command file:

- `/Users/harry/Documents/chatbobi/.claude/commands/mocktest.md`

Behavior is defined there (launch Chromium with extension, open mock page, prepare mock server/env for interactive acceptance).

## Mandatory Usage

Use when **`enforce-acceptance-order` / your plan** indicates `mocktest` is next (after `autotest` is recorded in the acceptance block). Record the result only in **`## Acceptance status (hooks)`**; PR `tdd-log` is not the hook source for this line.

## Startup Gate (Mandatory Preflight)

Before running mocktest, validate both files exist:

- `docs/Vx.y.z-<topic>/Vx.y.z-PRn/Vx.y.z-PRn-tdd-log.md`
- `docs/Vx.y.z-<topic>/Vx.y.z-test.md`

Then validate both files contain detailed test cases:

- PR log includes case IDs (for example `T-001`/`TC-001`)
- Version test file includes `## Detailed Test Cases` and at least one case ID

Preflight policy for quality fields:

- Startup preflight does not block on the 6 quality fields
- Strict quality-field enforcement is applied by `Stop` gate (`hooks/test-acceptance-gate`)
- Missing quality fields at stop will block completion with structured `missing_fields`

If any check fails: do not start. Return `BLOCKED` and ask for detailed test cases first.

## Required Output

Record the **mocktest** status line **only** in `docs/.../Vx.y.z-test.md` under **`## Acceptance status (hooks)`** (see `version-test-template.md`).  
Optional human notes in `Vx.y.z-test.md` outside that section (e.g. PR coverage table) are fine; hooks read order/status **only** from the acceptance block.

## Minimum Result Fields

- command source path
- mocked scenario set
- checks executed
- pass/fail summary
- defect evidence links/snippets

## Completion Rule

No version completion is valid without a `mocktest` status line under **`## Acceptance status (hooks)`** in `Vx.y.z-test.md` (after `autotest`, before `devicetest`).
No execution is valid if detailed test cases are missing in either PR log or version test file.
If quality fields/sections are missing (`Test Point`, `Expected Result`, `Assertion Target`, `Coverage Matrix`, `Expectation Index`, `Known Blind Spots`), mocktest output is not a valid acceptance conclusion.

## Template References

- `docs/superpowers/templates/tdd-report-template.md`
- `docs/superpowers/templates/versioning/version-test-template.md`
- `docs/superpowers/templates/e2e-case-template.md`
