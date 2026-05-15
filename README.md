# Superpowers

Superpowers is a complete software development workflow for your coding agents, built on top of a set of composable "skills" and some initial instructions that make sure your agent uses them.

## How it works

It starts from the moment you fire up your coding agent. As soon as it sees that you're building something, it *doesn't* just jump into trying to write code. Instead, it steps back and asks you what you're really trying to do. 

Once it's teased a spec out of the conversation, it shows it to you in chunks short enough to actually read and digest. 

After you've signed off on the design, your agent puts together an implementation plan that's clear enough for an enthusiastic junior engineer with poor taste, no judgement, no project context, and an aversion to testing to follow. It emphasizes true red/green TDD, YAGNI (You Aren't Gonna Need It), and DRY. 

Next up, once you say "go", it launches a *subagent-driven-development* process, having agents work through each engineering task, inspecting and reviewing their work, and continuing forward. It's not uncommon for Claude to be able to work autonomously for a couple hours at a time without deviating from the plan you put together.

There's a bunch more to it, but that's the core of the system. And because the skills trigger automatically, you don't need to do anything special. Your coding agent just has Superpowers.


## Sponsorship

If Superpowers has helped you do stuff that makes money and you are so inclined, I'd greatly appreciate it if you'd consider [sponsoring my opensource work](https://github.com/sponsors/obra).

Thanks! 

- Jesse


## Installation

**Note:** Installation differs by platform. Claude Code or Cursor have built-in plugin marketplaces. Codex and OpenCode require manual setup.

### Claude Code Official Marketplace

Superpowers is available via the [official Claude plugin marketplace](https://claude.com/plugins/superpowers)

Install the plugin from Claude marketplace:

```bash
/plugin install superpowers@claude-plugins-official
```

### Claude Code (via Plugin Marketplace)

In Claude Code, register the marketplace first:

```bash
/plugin marketplace add obra/superpowers-marketplace
```

Then install the plugin from this marketplace:

```bash
/plugin install superpowers@superpowers-marketplace
```

### Cursor (via Plugin Marketplace)

In Cursor Agent chat, install from marketplace:

```text
/add-plugin superpowers
```

or search for "superpowers" in the plugin marketplace.

### Codex

Tell Codex:

```
Fetch and follow instructions from https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.codex/INSTALL.md
```

**Detailed docs:** [docs/README.codex.md](docs/README.codex.md)

### OpenCode

Tell OpenCode:

```
Fetch and follow instructions from https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.opencode/INSTALL.md
```

**Detailed docs:** [docs/README.opencode.md](docs/README.opencode.md)

### GitHub Copilot CLI

```bash
copilot plugin marketplace add obra/superpowers-marketplace
copilot plugin install superpowers@superpowers-marketplace
```

### Gemini CLI

```bash
gemini extensions install https://github.com/obra/superpowers
```

To update:

```bash
gemini extensions update superpowers
```

### Verify Installation

Start a new session in your chosen platform and ask for something that should trigger a skill (for example, "help me plan this feature" or "let's debug this issue"). The agent should automatically invoke the relevant superpowers skill.

## The Basic Workflow

1. **Brainstorm (`brainstorming` design gate)** - Activates before writing code. Refines rough ideas through questions, explores alternatives, and validates user/product/design intent. Produces `Vx.y.z-design.md`.

2. **Spec (`brainstorming` spec gate + reviewer prompt)** - Converts approved design into implementation-ready, testable specification (technical boundaries, acceptance mapping, and capacity split checks). Produces `Vx.y.z-spec.md`.
   - Before entering `writing-plans`, spec must include minimum reconnaissance outputs: `Affected Paths`, `Invariants`, and `Figma Diff` (otherwise remain draft).

3. **Plan (`writing-plans`)** - Saves `docs/Vx.y.z-<topic>/Vx.y.z-plan.md`, defines PR grouping from task dependencies, and maps tests to PR-level TDD logs. Plan must define `PR1..PRn` execution order (single-PR versions still use `PR1`).

4. **TDD (`test-driven-development`)** - Establishes RED-GREEN-REFACTOR evidence discipline. No task is complete without recorded RED/GREEN evidence.

5. **Subagent Development (`subagent-driven-development`)** - Executes plan tasks with subagents and reviewer loops. `using-git-worktrees` is auto-used here as infrastructure (not a standalone product phase), and produces isolated worktree directories only.

6. **Review (`requesting-code-review`)** - Runs mandatory two-stage review order (Spec/Plan Compliance -> Code Quality), blocks on unresolved critical/important issues, and enforces reviewer-owned review artifacts.

7. **Finalize (`finishing-a-development-branch`)** - Active-PR closure step: verifies acceptance evidence, requires finalize log, presents merge/PR options, and cleans up unused worktrees. This is run per PR closure, not "once per version only."

**The agent checks for relevant skills before any task.** Mandatory workflows, not suggestions.

## Version/PR/Task Documentation Contract

Superpowers uses version-centric documentation as a hard rule. **Path layout** (two-level `docs/<product>/<stem>-<topic>/` vs one-level `docs/<stem>-<topic>/`, legacy `docs/V*`, and the meaning of the `Vx.y.z` placeholder) is defined in root **`CLAUDE.md`** (*File Layout* + *Version/PR Artifacts*).

- Every implementation cycle is bound to one **version root** resolved under `docs/` (hooks: `hooks/acceptance-order-common`).
- `<topic>` naming: use theme keywords in kebab-case (examples: `pv0.1.13-dom-adapt`, `v0.1.5-panel-ui`); **file basename prefixes must match the version directory basename stem** (`Vx.y.z` in templates = that stem, e.g. `pv0.1.13`).
- Required version files: `Vx.y.z-design.md`, `Vx.y.z-spec.md`, `Vx.y.z-plan.md`, `Vx.y.z-changelog.md`, `Vx.y.z-decisions.md`, `Vx.y.z-test.md` (three environment statuses only under **`## Acceptance status (hooks)`** — see `version-test-template.md`)
- Changelog hard rule: all important corrections during design, development, testing, and release must be recorded in the same version's `Vx.y.z-changelog.md`
- Each PR folder (`Vx.y.z-PRn/`) requires:
  - `Vx.y.z-PRn-tdd-log.md`
  - `Vx.y.z-PRn-subagent-summary.md`
  - `Vx.y.z-PRn-review-report.md`
  - `Vx.y.z-PRn-finalize-log.md`

Review artifact naming is globally unified to `Vx.y.z-PRn-review-report.md`.
Migration rule: if a legacy `Vx.y.z-PRn-code-review.md` exists and `Vx.y.z-PRn-review-report.md` does not, rename the legacy file to the unified name before continuing.

Dependent tasks go into the same PR. Independent tasks should be split into separate PRs.

## PR Execution Loop (Mandatory)

After planning, execute by PR loop, not a single linear pass:

1. Create/activate `Vx.y.z-PR1/` (then `PR2..PRn` as defined by plan)
2. Run PR loop: `TDD -> Subagent Development -> Review` (per PR). When you run the three environment acceptances, record `autotest -> mocktest -> devicetest` **only** in the version file `Vx.y.z-test.md` under **`## Acceptance status (hooks)`** (version-scoped; not in `Vx.y.z-PRn/`). Then `Debug` if needed
3. Keep PR doc pack and version `Vx.y.z-test.md` continuously updated during the loop (never "fill everything at the end")
4. Move to next PR when current PR passes review; full three acceptance runs are version-scoped (see **Mandatory Final Acceptance Tests**)
5. After `PRn` closes, run version-level regression/aggregation before final branch integration decisions
6. When using PR-scoped doc hooks, switch the active PR context (marker/env). The **`## Acceptance status (hooks)`** block is always in the **version** file, not under `Vx.y.z-PRn/`

### Active PR context (hooks)

Acceptance hooks resolve which `Vx.y.z-PRn/` directory is **active**. **Priority** (highest first):

1. **`SUPERPOWERS_ACTIVE_PR_DIR`** — absolute path to the PR folder (must exist).
2. **`SUPERPOWERS_ACTIVE_PR`** — folder basename under the version root (e.g. `V0.1.6-PR2`).
3. **`SUPERPOWERS_ACTIVE_PR_CONTEXT`** — `PR2` shorthand (case-insensitive) or a full folder name that exists under the version root.
4. **`.claude/.active-pr`** — project-local marker file: one line, either an absolute path to the PR folder or a basename relative to the version root.
5. **Prompt hint** — e.g. "run devicetest for **PR2**" (first `prN` token wins).
6. **Latest PR directory** under the selected version (fallback).

Copy-paste examples (from the project repo root; replace placeholders):

```bash
# 1) Pin via env: full path to PR folder (highest priority)
export SUPERPOWERS_ACTIVE_PR_DIR="/path/to/repo/docs/V0.1.6-widget-dark-mode/V0.1.6-PR2"

# 2) Pin via env: basename under the version folder
export SUPERPOWERS_ACTIVE_PR="V0.1.6-PR2"

# 3) Pin via env: PRn shorthand (matches V*-PR2 under the version)
export SUPERPOWERS_ACTIVE_PR_CONTEXT="PR2"

# 4) Pin via marker file (relative basename)
mkdir -p .claude
echo 'V0.1.6-PR2' > .claude/.active-pr

# 5) Or absolute path in the marker file
echo '/abs/path/to/docs/V0.1.6-widget-dark-mode/V0.1.6-PR2' > .claude/.active-pr
```

Clear env overrides when switching work sessions if needed: `unset SUPERPOWERS_ACTIVE_PR_DIR SUPERPOWERS_ACTIVE_PR SUPERPOWERS_ACTIVE_PR_CONTEXT`.

Implementation: `hooks/acceptance-order-common` (`resolve_active_pr_dir`).

## Mandatory Final Acceptance Tests

All three environment runs are required to close a version. **Hooks read results only** from `docs/.../Vx.y.z-test.md` inside the exact heading **`## Acceptance status (hooks)`** (no title variants; see `docs/superpowers/templates/versioning/version-test-template.md`).

- `autotest` (automated mock environment, Playwright-capable)
- `mocktest` (mock scenario acceptance)
- `devicetest` (device-profile acceptance)

Execution order is mandatory: `autotest -> mocktest -> devicetest` in that section (one status line per test type, in order).

Logging requirements:

- **Do not** put `autotest` / `mocktest` / `devicetest` **status lines** in `Vx.y.z-PRn-tdd-log.md` for hook purposes — PR tdd-log is for TDD case evidence (`Test Point`, `Expected Result`, `Assertion Target`) only
- `Vx.y.z-test.md` must contain the **`## Acceptance status (hooks)`** section with all three status lines in order; keep `Coverage Matrix` / `Expectation Index` / `Known Blind Spots` as before
- Preflight: `hooks/enforce-acceptance-order` still requires both PR `tdd-log` and version `Vx.y.z-test.md` with case IDs; Stop gate enforces the 6 quality fields strictly

Hook gate blocks completion when required acceptance evidence is missing.
Stop gate is strict for template quality fields and blocks completion when any required field is absent.
Hybrid stop policy: when acceptance status is missing/abnormal, stop gate runs conservative fallback checks and marks output with `status_fallback: true`.
Stop gate also blocks when PR doc pack is incomplete (`tdd-log`, `subagent-summary`, `review-report`, `finalize-log`) or when spec/spec-test edits are unconfirmed.

## Test Template Quality Requirements

Documentation completeness does not equal test effectiveness.

For each `T-xxx` or `TC-xxx`, templates must include:

- `Test Point` (what exact object/state/path is verified)
- `Expected Result` (business expectation in plain language)
- `Assertion Target` (machine-checkable condition)

Suggested template references:

- `docs/superpowers/templates/tdd-report-template.md`
- `docs/superpowers/templates/versioning/version-test-template.md`
- `docs/superpowers/templates/e2e-case-template.md`

Stop-gate strict fields (all required):

- PR-level `tdd-log`: `Test Point`, `Expected Result`, `Assertion Target`
- Version-level `Vx.y.z-test.md`: `Coverage Matrix`, `Expectation Index`, `Known Blind Spots`

When blocked by missing quality fields, stop gate returns structured JSON with `decision`, `reason`, `missing_fields`, and `status_fallback`.

For ChatBobi, acceptance commands are sourced from project-level command files:

- `/Users/harry/Documents/chatbobi/.claude/commands/autotest.md`
- `/Users/harry/Documents/chatbobi/.claude/commands/mocktest.md`
- `/Users/harry/Documents/chatbobi/.claude/commands/devicetest.md`

## Runtime Enforcement Summary

Use this as the quick runtime map; detailed behavior stays in skills/hooks.

- **Seven-step runtime flow:** `Brainstorm -> Spec -> Plan -> TDD -> Subagent Development -> Review -> Finalize`
- **Skill mapping:** `brainstorming (design gate) -> brainstorming (spec gate + reviewer prompt) -> writing-plans (PR grouping) -> test-driven-development -> subagent-driven-development (+using-git-worktrees infra, includes reviewer loops using requesting-code-review templates) -> finishing-a-development-branch (per active PR closure)`
- **Required artifacts:** version root six files (`Vx.y.z-design.md`/`Vx.y.z-spec.md`/`Vx.y.z-plan.md`/`Vx.y.z-changelog.md`/`Vx.y.z-decisions.md`/`Vx.y.z-test.md`) + PR four files (`tdd-log/subagent-summary/review-report/finalize-log`)
- **Version changelog discipline:** important corrections from design/dev/test/release are always appended to the same `Vx.y.z-changelog.md`
- **Review boundary:** `review-report` is reviewer-owned output; implementer self-review belongs in `subagent-summary`
- **Legacy migration:** if only `Vx.y.z-PRn-code-review.md` exists, rename to `Vx.y.z-PRn-review-report.md` before appending
- **Acceptance order:** `autotest -> mocktest -> devicetest` **only** under **`## Acceptance status (hooks)`** in `Vx.y.z-test.md` (preflight + stop gates; hooks do not use PR `tdd-log` for these three)
- **Evolution loop:** hooks route signals to `evolution-keeper`; `occurrences >= 2` creates candidate; graduation always requires human `confirm/skip`; candidate summaries append to `docs/LESSONS.md` with **adoption** state (`pending` → `adopted`|`not_adopted`) (see `agents/evolution-keeper.md`)
- **Evolution visibility:** closure must be consistent across docs, skills, scripts/hooks, feedback index, and regression tests.

Primary enforcement references:

- `changelogs.md` (plugin release history; same folder as `CLAUDE.md`)
- `skills/executing-plans/SKILL.md`
- `skills/subagent-driven-development/SKILL.md`
- `skills/requesting-code-review/SKILL.md`
- `skills/test-driven-development/SKILL.md`
- `hooks/enforce-acceptance-order`
- `hooks/test-acceptance-gate`
- `hooks/acceptance-order-common`
- `agents/evolution-keeper.md`

## Minimal Rule Injection Discipline

Superpowers is the primary and only runtime framework. External frameworks can be referenced, but not imported as parallel workflow systems.

When adding an externally inspired quality rule:

1. Inject one minimum rule at a time (single skill/hook section scope)
2. Record `## Gap Evidence` in the active PR review artifact before any rule text is added
3. Validate on one real task after injection
4. If false positives are noisy or value is not demonstrated, rollback immediately

Required record location for injection evidence:

- `docs/Vx.y.z-<topic>/Vx.y.z-PRn/Vx.y.z-PRn-review-report.md`

Required rollback traceability:

- reason in `Vx.y.z-changelog.md`
- decision in `Vx.y.z-decisions.md`

## What's Inside

### Skills Library

**Testing**
- **test-driven-development** - RED-GREEN-REFACTOR cycle (includes testing anti-patterns reference)

**Debugging**
- **systematic-debugging** - 4-phase root cause process (includes root-cause-tracing, defense-in-depth, condition-based-waiting techniques)
- **verification-before-completion** - Ensure it's actually fixed

**Collaboration** 
- **brainstorming** - Socratic design refinement
- **writing-plans** - Detailed implementation plans
- **executing-plans** - Batch execution with checkpoints
- **dispatching-parallel-agents** - Concurrent subagent workflows
- **requesting-code-review** - Pre-review checklist
- **receiving-code-review** - Responding to feedback
- **using-git-worktrees** - Subagent Development infrastructure (isolated worktree provisioning/cleanup lifecycle support)
- **finishing-a-development-branch** - Merge/PR decision workflow
- **subagent-driven-development** - Fast iteration with two-stage review (spec compliance, then code quality)

**Meta**
- **writing-skills** - Create new skills following best practices (includes testing methodology)
- **using-superpowers** - Introduction to the skills system

## Philosophy

- **Test-Driven Development** - Write tests first, always
- **Systematic over ad-hoc** - Process over guessing
- **Complexity reduction** - Simplicity as primary goal
- **Evidence over claims** - Verify before declaring success

Read more: [Superpowers for Claude Code](https://blog.fsck.com/2025/10/09/superpowers/)

## Contributing

Skills live directly in this repository. To contribute:

1. Fork the repository
2. Create a branch for your skill
3. Follow the `writing-skills` skill for creating and testing new skills
4. Submit a PR

See `skills/writing-skills/SKILL.md` for the complete guide.

## Updating

Skills update automatically when you update the plugin:

```bash
/plugin update superpowers
```

## License

MIT License - see LICENSE file for details

## Community

Superpowers is built by [Jesse Vincent](https://blog.fsck.com) and the rest of the folks at [Prime Radiant](https://primeradiant.com).

- **Discord**: [Join us](https://discord.gg/35wsABTejz) for community support, questions, and sharing what you're building with Superpowers
- **Issues**: https://github.com/obra/superpowers/issues
- **Release announcements**: [Sign up](https://primeradiant.com/superpowers/) to get notified about new versions
