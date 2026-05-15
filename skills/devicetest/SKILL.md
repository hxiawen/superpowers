---
name: devicetest
description: Run ChatBobi real-device devicetest before version completion; record status only in Vx.y.z-test.md under ## Acceptance status (hooks). Command /Users/harry/Documents/chatbobi/.claude/commands/devicetest.md
---

# DeviceTest (Final Acceptance)

Use ChatBobi's project command-based real-device acceptance as the **third** step after `autotest` and `mocktest`. Hooks read the **devicetest** status **only** from **`## Acceptance status (hooks)`** in `Vx.y.z-test.md`.

## Source of Truth

Project command file:

- `/Users/harry/Documents/chatbobi/.claude/commands/devicetest.md`

Behavior is defined there (device acceptance steps, feedback capture, and structured TEST.md/test.md output guidance).

## Mandatory Usage

Use when **`autotest` and `mocktest`** are already recorded in the acceptance block and the gate expects `devicetest` (or when completing the full triple in one pass). Record the result only in **`## Acceptance status (hooks)`**; PR `tdd-log` is not the hook source for this line.

## Startup Gate (Mandatory Preflight)

Before running devicetest, validate both files exist:

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

version-source preflight for extension projects (mandatory when applicable):

- If project defines `scripts/bump-version.sh` + `.version-bump.json`, run drift check before devicetest.
- If extension artifact exists at `app/plugin/.output/chrome-mv3/manifest.json`, ensure artifact `version` matches source version (`app/plugin/package.json` when present).
- If version drift is detected, block devicetest until version is corrected and artifact rebuilt.

## Required Output

Record the **devicetest** status line **only** in `docs/.../Vx.y.z-test.md` under **`## Acceptance status (hooks)`** (see `version-test-template.md`).  
Do not use PR `tdd-log` for these hook-visible status lines.

## Minimum Result Fields

- command source path
- **build version (MUST read from `app/plugin/.output/chrome-mv3/manifest.json` after `npm run build` completes — `buildNumber` auto-increments each build; reading before build reports a stale version)**
- **bundle size (from build output `Σ Total size` line — required for Quality Gate monitoring; flag any single-PR increase > 5KB vs a prior baseline)**
- device matrix
- executed checks
- pass/fail summary
- device-specific issues

When reporting version + bundle together, use one line, for example: `Build: X.Y.Z.N | Bundle: XXX kB`. Match project wording in `Vx.y.z-test.md` if templates use `构建版本` / `包体`.

## Completion Rule

No version completion is valid without a `devicetest` status line under **`## Acceptance status (hooks)`** in `Vx.y.z-test.md` (after `autotest` and `mocktest`).
No execution is valid if detailed test cases are missing in either PR log or version test file.
If quality fields/sections are missing (`Test Point`, `Expected Result`, `Assertion Target`, `Coverage Matrix`, `Expectation Index`, `Known Blind Spots`), devicetest output is not a valid acceptance conclusion.

## Template References

- `docs/superpowers/templates/tdd-report-template.md`
- `docs/superpowers/templates/versioning/version-test-template.md`
- `docs/superpowers/templates/e2e-case-template.md`
