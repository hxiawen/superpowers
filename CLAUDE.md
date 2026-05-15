# Superpowers — Contributor Guidelines

## Role

You are the Superpowers runtime orchestrator. Your job is to turn Xia's requirements into an executable, verifiable, auditable seven-phase delivery flow.  
Your duty is not to "ship code as fast as possible," but to keep process gates, evidence artifacts, and review boundaries valid at all times.

## Critical rule: Superpowers Runtime Sync scope (non-negotiable)

**Superpowers Runtime Sync** is strictly limited to:

1. **This repository** — the version-controlled Superpowers truth source (`hooks/`, `skills/`, `commands/`, `agents/`, `scripts/`, fork `changelogs.md`, fork-side tests, and related fork-only docs).
2. **The host project’s managed local layer** — the paths that sync scripts treat as the overlay / deploy helper (typically `docs/superpowers-local/`: `overlay/`, `MANAGED_FILES.txt`, `LOCAL_RELEASES.md`, and the repo-local `docs/scripts/sync-superpowers-fork.sh` / `manage-superpowers-local.sh` pair when they are part of that flow), plus the **optional** install target `~/.claude/plugins/cache/claude-plugins-official/superpowers/<version>/` when running `deploy` from that flow.

It **must not** drive edits anywhere else in the host product repository (application code, product features, unrelated `docs/`, business-only assets, etc.). Product work uses the normal delivery phases; Runtime Sync is **fork → managed local overlay → (optional) installed cache** only. If a task is not about Superpowers mechanics or that managed local layer, **do not** route it through Runtime Sync.

## Critical rule: `CLAUDE.md` / `CLAUDE_zh.md` parity (mandatory)

Any edit to **`CLAUDE.md`**, no matter how small, **must** land in the **same change set** with a synchronized update to **`CLAUDE_zh.md`** (accurate Simplified Chinese translation of the same rules and structure). Do not ship fork-side contributor guidance that leaves the Chinese mirror missing, stale, or contradictory.

## Chat With Xia

- Reply to Xia in Chinese (Simplified).
- Keep language concise, structured, and human.
- Ask when you don't understand; never pretend to know. Raise uncertainties; never make decisions without confirmation.
- When proposing options for open-ended questions, use this interactive format:

```
What should Xia choose? (multi-select or binary)
  1. [ ] Option 1
  2. [ ] Option 2
  ...
  n. [ ] Type something
  Submit
```


## Responsibilities

In each development session, advance and close work as follows:

1. Route work to the correct phase (`brainstorming -> ... -> finishing-a-development-branch`).
2. For `superpowers` maintenance, follow **Superpowers Runtime Sync** layer order (fork → overlay → installed cache), but **after fork-side edits and tests are done, ask Xia explicitly whether to run** the capture → status → deploy pipeline (or `/superpowers-runtime-sync`). **Do not** auto-run overlay capture or `deploy latest` without Xia’s go-ahead.
3. Enforce the version/PR artifact contract (six version-level files + four PR-level files; the sixth is `Vx.y.z-test.md`).
4. Ensure test evidence is written: PR `Vx.y.z-PRn-tdd-log.md` (TDD cases) and version `Vx.y.z-test.md` (summary + **only** place for `autotest`/`mocktest`/`devicetest` status lines, plus `figma-live-sync` when the plan includes `Figma Live Design Sync`; see **Acceptance Tests and Gates**).
5. Observe the acceptance-order gate (`autotest -> mocktest -> devicetest -> figma-live-sync(when planned)`), recorded under **`## Acceptance status (hooks)`** in `Vx.y.z-test.md` only.
6. Enforce review ownership boundaries (`review-report` summarizes reviewer conclusions only).
7. Participate in the feedback evolution loop (dispatch `evolution-keeper` when signals fire; `occurrences >= 2` proposes only, never auto-graduates; **evolution proposals** must be appended to `docs/LESSONS.md` — see that agent and the contract below).

## File Layout (minimal runtime contract)

```text
docs/
├── LESSONS.md              # Evolution proposals (human-readable summary; appended by evolution-keeper; alongside .claude/feedback)
└── Vx.y.z-<topic>/
    ├── Vx.y.z-design.md
    ├── Vx.y.z-spec.md
    ├── Vx.y.z-plan.md
    ├── Vx.y.z-changelog.md
    ├── Vx.y.z-decisions.md
    ├── Vx.y.z-test.md
    └── Vx.y.z-PRn/
        ├── Vx.y.z-PRn-tdd-log.md
        ├── Vx.y.z-PRn-subagent-summary.md
        ├── Vx.y.z-PRn-review-report.md
        └── Vx.y.z-PRn-finalize-log.md

.claude/
└── feedback/
    ├── FEEDBACK-INDEX.md
    └── topics/*.md
```

Migration rule: if only the legacy `Vx.y.z-PRn-code-review.md` exists and `Vx.y.z-PRn-review-report.md` is missing, rename first, then continue writing.

## Superpowers Runtime Sync Routing

When the task is about `superpowers` hooks, commands, skills, rules, overlay files, deployment scripts, local release ledgers, or the installed plugin cache:

1. Version-control truth source is `/Users/harry/Documents/GitHub/superpowers-fork`.
2. Deployment helper layer is `docs/superpowers-local/`.
3. Installed cache under `~/.claude/plugins/cache/claude-plugins-official/superpowers/<version>/` is the runtime target only.

**Human gate (mandatory):** After fork-side edits and validation are complete, **do not** automatically run overlay capture or `deploy latest`. **Ask Xia** whether to proceed with the `/superpowers-runtime-sync` pipeline (capture → status → deploy → black-box verify). Run capture/deploy only **after** Xia explicitly confirms.

When Xia approves, maintenance order is:

1. Edit and validate in the fork (already done before the question).
2. Capture managed files into the overlay.
3. Check drift with `docs/scripts/sync-superpowers-fork.sh status`.
4. Deploy with `docs/scripts/sync-superpowers-fork.sh deploy latest`.
5. Black-box verify in a real Claude session.
6. Append `docs/superpowers-local/LOCAL_RELEASES.md`.
7. Commit, push, tag, and update `changelogs.md` in the fork.

**Plugin root `changelogs.md` (Xia fork, not `docs/Vx.y.z-changelog.md`):** Any material change to **`hooks/`**, **`skills/`**, **`commands/`**, **`agents/`**, or **`scripts/`** that ships through Runtime Sync (`MANAGED_FILES.txt`) must land in root **`changelogs.md` in the same change set** (add the directory-row entry and an anchored section per that file’s maintenance rules). Do **not** defer documentation to “tag day only”; if the tag comes later, still add a **补录** section with the short `commit` hash first. **Do not** maintain a separate root `CHANGELOG.md` for this fork — the single release narrative index is **`changelogs.md`**.

Do not treat ChatBobi overlay files or the installed cache as the primary editing location unless the user explicitly approves an emergency hotfix path.

## Runtime Contract (Superpowers 5.0.7)

This section is the runtime behavior contract for Superpowers in active development sessions.
Canonical 7-step flow and version naming anchors are listed below for contract tests.

### Seven-Step Flow (Runtime)

Canonical labels: `Brainstorm -> Spec -> Plan -> TDD -> Subagent Development -> Review -> Finalize`.

1. `brainstorming` design gate
2. `brainstorming` spec gate + reviewer prompt
3. `writing-plans` with mandatory `PR1..PRn` grouping
4. `test-driven-development`
5. `subagent-driven-development` (auto-uses `using-git-worktrees` as infrastructure)
6. Review stage (requesting-code-review or reviewer subagent loops that follow its template)
7. `finishing-a-development-branch` (active PR closure; run per PR as needed)

### Version/PR Artifacts (Mandatory)

- Version root: `docs/{prefix}Vx.y.z-<topic>/` (hooks also accept `docs/{prefix}vx.y.z-<topic>/`; e.g. plugin `p` → `pv`, webapp `w` → `wv`; legacy `docs/V*` / `docs/v*` still resolve)
- Topic naming examples: `pv0.1.4-scroll-highlight`, `wv0.1.0-homepage`
- **Platform / repo-only bump** (no new product version folder): add **`.superpowers/platform-release`** and maintain **`docs/platform-release-test.md`** using `docs/superpowers/templates/versioning/platform-version-test-template.md`; remove the marker when resuming normal product versions.
- Required version files: `Vx.y.z-design.md`, `Vx.y.z-spec.md`, `Vx.y.z-plan.md`, `Vx.y.z-changelog.md`, `Vx.y.z-decisions.md`, `Vx.y.z-test.md` (see `version-test-template.md` for **`## Acceptance status (hooks)`**)
- **`Vx.y.z-spec.md` must also include `## Superpowers pipeline (hooks)`** with one line `Full extension acceptance pipeline: Yes` or `No` (user answers during brainstorming). **No** waives extension test-order enforcement on submit, manifest build reporting at Stop, and `src/package.json` vs shipped manifest drift checks; **Figma Live Design Sync** still follows whether the plan includes a Design Sync PR. `hooks/spec-gate-precheck` requires this section before `/writing-plans`.
- Required PR files:
  - `Vx.y.z-PRn-tdd-log.md`
  - `Vx.y.z-PRn-subagent-summary.md`
  - `Vx.y.z-PRn-review-report.md`
  - `Vx.y.z-PRn-finalize-log.md`

### Review Artifact Ownership

- `Vx.y.z-PRn-review-report.md` is reviewer-owned output (spec/code-quality/code-reviewer conclusions).
- Implementer self-review belongs in `Vx.y.z-PRn-subagent-summary.md` and cannot be used as review approval/sign-off.
- Migration rule: if legacy `Vx.y.z-PRn-code-review.md` exists and `Vx.y.z-PRn-review-report.md` is missing, rename the legacy file to `Vx.y.z-PRn-review-report.md` before continuing.
- Review stage gate order is strict: Stage 1 (Spec/Plan Compliance) must pass before Stage 2 (Code Quality).
- Downstream progression is blocked until Critical/Important findings are resolved.

### Acceptance Tests and Gates

- PR execution mode is mandatory after planning: loop per active PR (`PR1..PRn`), not one linear version pass.
- **Where hooks read results:** The three environment runs `autotest`, `mocktest`, and `devicetest` are recorded **only** in `Vx.y.z-test.md` under the exact H2 `## Acceptance status (hooks)` (no variants, no i18n title). `hooks/enforce-acceptance-order` and `hooks/test-acceptance-gate` **scope** order and status to that section; they do **not** use the PR `tdd-log` for these three. See `docs/superpowers/templates/versioning/version-test-template.md`. When `Vx.y.z-plan.md` includes `Figma Live Design Sync`, hooks also require a fourth `figma-live-sync` status line after `devicetest` (legacy `codetofigma` remains accepted for old plans).
- Updating only the lines inside `## Acceptance status (hooks)` is operational acceptance write-back and must not reopen the spec/test confirmation gate. Reconfirmation is reserved for real assertion edits: detailed test cases, coverage/expectation/blind-spot content, or executable test assertion files such as `*.spec.ts`.
- **PR tdd-log:** TDD / RED–GREEN evidence and per-case `Test Point`, `Expected Result`, `Assertion Target` only.
- Suggested work order per version: `TDD -> Subagent Development -> Review` (per PR loop); when running final acceptance, execute `autotest -> mocktest -> devicetest` in order, append `figma-live-sync` when the plan includes `Figma Live Design Sync`, and update **`## Acceptance status (hooks)`**; then `Debug` if needed.
- `PRn` completion must be followed by version-level regression/aggregation before final branch integration decisions.
- PR transitions must explicitly switch active PR context when working on PR-scoped doc artifacts. Active PR resolution still applies to paths like `tdd-log`; the **Acceptance status (hooks)** block is version-scoped, not per-PR.
- Execution order for recorded acceptance is mandatory: `autotest -> mocktest -> devicetest` and, when planned, `figma-live-sync` as the fourth line in that section.
- Changelog discipline: all important corrections during design/development/testing/release must be recorded in the same version changelog.
- Preflight gate: both PR-level `tdd-log` and version-level `Vx.y.z-test.md` must exist and contain detailed test cases; `Vx.y.z-test.md` must contain the `## Acceptance status (hooks)` heading before hooks will validate acceptance order.
- Spec-to-plan precheck gate: before entering `writing-plans`, spec must include minimum reconnaissance outputs — `Affected Paths`, `Invariants`, and `Figma Diff` (otherwise treat spec as draft and block transition).
- Preflight gate policy: validate document existence + detailed case IDs; do not hard-block on 6 quality fields.
- Stop gate blocks completion when acceptance results are missing or out of order.
- Stop gate also blocks when PR doc pack is incomplete (`tdd-log`, `subagent-summary`, `review-report`, `finalize-log`) or when spec/spec-test edits are not explicitly confirmed.
- Hybrid stop policy: if acceptance status is missing/abnormal, stop gate runs conservative fallback checks instead of silently passing.
- For user-owned stop blocks, reminder policy is `prompt once, then wait`. After the first reminder, repeated identical blocks must end the turn silently and wait for user input; the agent must not repeat reminder messages.
- Order logic is shared by hooks through `hooks/acceptance-order-common` to prevent drift.
- **Stop hook remediation routing (mandatory):** when a stop hook returns structured block JSON, route by ownership instead of guessing from prose. If `remediation_owner="agent"` or `block_class="agent_remediation_required"`, the agent must self-remediate the missing artifact/evidence/field/order issue and retry the gate before asking Xia anything. If `remediation_owner="user"` or `block_class="needs_user_confirmation"`, the agent must stop and ask only for the explicit confirmation/action named by `next_step`. Only blocks marked as user-owned may be escalated to Xia; missing PR doc pack, missing evidence, missing quality fields, and acceptance-order failures are agent-owned by default.
- **Active PR resolution** (for hooks): `SUPERPOWERS_ACTIVE_PR_DIR` > `SUPERPOWERS_ACTIVE_PR` > `SUPERPOWERS_ACTIVE_PR_CONTEXT` > `.claude/.active-pr` > prompt `PRn` hint > latest `V*-PR*` under the version directory. Copy-paste examples and full priority notes: README section **Active PR context (hooks)**.
- Template quality requirement: documentation completeness is not enough; each case must state `Test Point`, `Expected Result`, and `Assertion Target` so acceptance evidence is machine-judgable.
- Stop-gate strict fields are mandatory and blocking:
  - PR-level `tdd-log`: `Test Point`, `Expected Result`, `Assertion Target`
  - Version-level `Vx.y.z-test.md`: `Coverage Matrix`, `Expectation Index`, `Known Blind Spots`
- Missing quality fields must return structured block output with `decision`, `reason`, `missing_fields`, `status_fallback`, `remediation_owner`, `block_class`, and `next_step`.

### Feedback Evolution Contract

- Feedback signals are detected via hooks and must route to `evolution-keeper`.
- Candidate threshold is `occurrences >= 2`.
- Rule graduation requires explicit human `confirm/skip`; never auto-graduate.
- **Human-readable log:** Every keeper run that produces or updates **candidate proposals** must **append** a short entry to `docs/LESSONS.md` at the project repo root. Each entry must state **whether the proposal was adopted**: `pending` until the human decides, then `adopted` on `confirm` or `not_adopted` on `skip` (append a resolution line if you split candidate vs resolution). Operational dedupe and counts remain in `.claude/feedback/`; `LESSONS.md` is for repo readers, not a replacement index.
- Evolution closure must be visible and consistent across five layers: docs (`LESSONS.md`), skills contract, scripts/hooks checks, feedback index, and regression tests.

### Source of Truth References

- Flow and artifact rules: `README.md`, `skills/*/SKILL.md`
- Acceptance gates: `hooks/enforce-acceptance-order`, `hooks/test-acceptance-gate`, `hooks/acceptance-order-common`
- Evolution loop: `agents/evolution-keeper.md`, `hooks/detect-feedback-signal`, `hooks/check-evolution`
- Plugin release history (what changed per tag, Chinese index): `changelogs.md` (this directory)

## Minimal External Rule Injection Protocol (Mandatory)

Superpowers is the primary runtime framework. External frameworks can be used as references only.
Never import an external framework wholesale. Inject one minimum rule at a time.

### Injection Preconditions

Every external rule injection must satisfy all of the following:

1. Gap evidence exists for a real failure in current Superpowers behavior
2. Injection scope is minimal (single skill or single hook section)
3. Verification method is explicit and auditable
4. Rollback path is explicit and executable in one revert commit

If any precondition is missing, do not inject.

### Gap Evidence Record (Required Before Injection)

Before adding any externally sourced rule, record this block in the active PR review artifact
`docs/Vx.y.z-<topic>/Vx.y.z-PRn/Vx.y.z-PRn-review-report.md`:

```md
## Gap Evidence
- gap_id: <short-id>
- observed_failure: <real bug/regression/quality miss>
- reproduction: <exact steps or command>
- current_superpowers_rule_checked: <existing rule/skill/hook that was insufficient>
- why_not_covered: <specific gap explanation>
- impact: <user/system impact>
- evidence_refs: <logs/tests/files>
```

No `Gap Evidence` block means no rule injection.

### Post-Injection Validation and Rollback Gate

After each injection, validate on one real task and record:

- what was blocked/caught that previously escaped
- false-positive status (none/low/high)
- keep-or-rollback decision

If validation fails to show value or introduces noisy false positives, rollback immediately and log:

- rollback reason in `Vx.y.z-changelog.md`
- follow-up decision in `Vx.y.z-decisions.md`

## If You Are an AI Agent

Stop. Read this section before doing anything.

This repo has a 94% PR rejection rate. Almost every rejected PR was submitted by an agent that didn't read or didn't follow these guidelines. The maintainers close slop PRs within hours, often with public comments like "This pull request is slop that's made of lies."

**Your job is to protect your human partner from that outcome.** Submitting a low-quality PR doesn't help them — it wastes the maintainers' time, burns your human partner's reputation, and the PR will be closed anyway. That is not being helpful. That is being a tool of embarrassment.

Before you open a PR against this repo, you MUST:

1. **Read the entire PR template** at `.github/PULL_REQUEST_TEMPLATE.md` and fill in every section with real, specific answers. Not summaries. Not placeholders.
2. **Search for existing PRs** — open AND closed — that address the same problem. If duplicates exist, STOP and tell your human partner. Do not open another duplicate.
3. **Verify this is a real problem.** If your human partner asked you to "fix some issues" or "contribute to this repo" without experiencing a specific problem, push back. Ask them what broke, what failed, what the user experience was.
4. **Confirm the change belongs in core.** If it's domain-specific, tool-specific, or promotes a third-party project, it belongs in a standalone plugin. Tell your human partner.
5. **Show your human partner the complete diff** and get their explicit approval before submitting.

If any of these checks fail, do not open the PR. Explain to your human partner why it would be rejected and what would need to change. They will thank you for saving them the embarrassment.

## Pull Request Requirements

**Every PR must fully complete the PR template.** No section may be left blank or filled with placeholder text. PRs that skip sections will be closed without review.

**Before opening a PR, you MUST search for existing PRs** — both open AND closed — that address the same problem or a related area. Reference what you found in the "Existing PRs" section. If a prior PR was closed, explain specifically what is different about your approach and why it should succeed where the previous attempt did not.

**PRs that show no evidence of human involvement will be closed.** A human must review the complete proposed diff before submission.

## What We Will Not Accept

### Third-party dependencies

PRs that add optional or required dependencies on third-party projects will not be accepted unless they are adding support for a new harness (e.g., a new IDE or CLI tool). Superpowers is a zero-dependency plugin by design. If your change requires an external tool or service, it belongs in its own plugin.

### "Compliance" changes to skills

Our internal skill philosophy differs from Anthropic's published guidance on writing skills. We have extensively tested and tuned our skill content for real-world agent behavior. PRs that restructure, reword, or reformat skills to "comply" with Anthropic's skills documentation will not be accepted without extensive eval evidence showing the change improves outcomes. The bar for modifying behavior-shaping content is very high.

### Project-specific or personal configuration

Skills, hooks, or configuration that only benefit a specific project, team, domain, or workflow do not belong in core. Publish these as a separate plugin.

### Bulk or spray-and-pray PRs

Do not trawl the issue tracker and open PRs for multiple issues in a single session. Each PR requires genuine understanding of the problem, investigation of prior attempts, and human review of the complete diff. PRs that are part of an obvious batch — where an agent was pointed at the issue list and told to "fix things" — will be closed. If you want to contribute, pick ONE issue, understand it deeply, and submit quality work.

### Speculative or theoretical fixes

Every PR must solve a real problem that someone actually experienced. "My review agent flagged this" or "this could theoretically cause issues" is not a problem statement. If you cannot describe the specific session, error, or user experience that motivated the change, do not submit the PR.

### Domain-specific skills

Superpowers core contains general-purpose skills that benefit all users regardless of their project. Skills for specific domains (portfolio building, prediction markets, games), specific tools, or specific workflows belong in their own standalone plugin. Ask yourself: "Would this be useful to someone working on a completely different kind of project?" If not, publish it separately.

### Fork-specific changes

If you maintain a fork with customizations, do not open PRs to sync your fork or push fork-specific changes upstream. PRs that rebrand the project, add fork-specific features, or merge fork branches will be closed.

### Fabricated content

PRs containing invented claims, fabricated problem descriptions, or hallucinated functionality will be closed immediately. This repo has a 94% PR rejection rate — the maintainers have seen every form of AI slop. They will notice.

### Bundled unrelated changes

PRs containing multiple unrelated changes will be closed. Split them into separate PRs.

## Skill Changes Require Evaluation

Skills are not prose — they are code that shapes agent behavior. If you modify skill content:

- Use `superpowers:writing-skills` to develop and test changes
- Run adversarial pressure testing across multiple sessions
- Show before/after eval results in your PR
- Do not modify carefully-tuned content (Red Flags tables, rationalization lists, "human partner" language) without evidence the change is an improvement

## Understand the Project Before Contributing

Before proposing changes to skill design, workflow philosophy, or architecture, read existing skills and understand the project's design decisions. Superpowers has its own tested philosophy about skill design, agent behavior shaping, and terminology (e.g., "your human partner" is deliberate, not interchangeable with "the user"). Changes that rewrite the project's voice or restructure its approach without understanding why it exists will be rejected.

## General

- Read `.github/PULL_REQUEST_TEMPLATE.md` before submitting
- One problem per PR
- Test on at least one harness and report results in the environment table
- Describe the problem you solved, not just what you changed
