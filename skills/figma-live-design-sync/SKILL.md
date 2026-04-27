---
name: figma-live-design-sync
description: Orchestrate a live code-to-Figma sync loop after the human opens a Figma design and runs the plugin once; update plugin code, verify hot reload with figma-read, diff against product source, and iterate until the Figma design matches source.
---

# Figma Live Design Sync

Use this skill when the goal is to push product UI code into a Figma design, read the same Figma URL back, compare the rendered design with product source or screenshots, and iterate on the Figma plugin until the output matches.

This is a **higher-level orchestration skill**. It does not replace the lower-level capabilities:

- Use `codetofigma` to generate or patch the Figma plugin script.
- Use `figma-url-readiness` / `/figma-read` to read metadata, screenshot, and design context from Figma.
- Use visual diff tooling, preferably ZAI-MCP when available, for screenshot comparison.

## Core Contract

```text
Human bootstrap once, agent loops after.
```

The human opens the target Figma design and runs the plugin once. After that, the agent may update the plugin code, verify that Figma picked up the new build, read the same URL/node back, diff the result, and continue fixing the plugin script.

Do not promise fully headless Figma automation. Treat hot reload as a capability that must be verified every round. If hot reload fails, downgrade to assisted rerun and ask the human to run the plugin once.

## When To Use

Use this skill when the human asks for any of these:

- code-to-Figma closed-loop verification
- automatically push code design to Figma and inspect the result
- keep updating a Figma plugin until the Figma output matches product source
- run codetofigma, then figma-read the same URL, then fix the plugin
- hot reload a Figma plugin and verify the new design output

Do not use this skill for plain Figma reading. Use `figma-url-readiness` / `/figma-read` only.

Do not use this skill for one-off plugin generation without readback. Use `codetofigma` only.

## Required Inputs

Before starting the loop, lock these targets:

- Product source path(s)
- Token/style source path(s)
- Figma URL and nodeId
- Plugin script source path in the repo
- Figma plugin dev path or symlink target, if hot reload is expected
- Build label format, for example `v0.1.8-sync-r03`
- Execution mode: `bootstrap`, `live-loop`, or `assisted-rerun`
- Loop budget: default `max_rounds = 3`; hard cap `max_rounds = 5` unless the human explicitly approves more

If any target is missing, ask one concise question and stop until answered.

## Execution Modes

### Bootstrap Mode

Use this mode at the start of a new design page or when the plugin has not been run in the current Figma file.

1. Generate or update the plugin script with `codetofigma`.
2. Ensure the script writes a visible build/version label to the Figma canvas.
3. Ensure the script writes enough plugin data or node names to make readback verification possible.
4. Ask the human to open the target Figma design and run the plugin once.
5. Run `/figma-read` on the same Figma URL/node.
6. Verify the observed build label equals the expected build label.
7. If verified, enter Live Loop Mode.

### Live Loop Mode

Use this mode after bootstrap has succeeded.

Before each round, check the loop budget. Default to 3 rounds. Do not exceed 5 rounds without explicit human approval. If the budget is exhausted, stop and summarize the remaining diffs instead of continuing to edit.

For each round:

1. Increment the build label, for example `sync-r03` -> `sync-r04`.
2. Update the plugin script through `codetofigma` or direct plugin-script edits.
3. Write or sync the script to the Figma plugin dev path.
4. Trigger hot reload if the environment supports it, or wait for the plugin dev environment to pick up the new script.
5. Run `/figma-read` against the same Figma URL/node.
6. Verify the observed build label matches the expected build label.
7. Compare Figma readback against product source and screenshots.
8. Fix the plugin script if the Figma output is wrong.
9. Repeat until the stop condition is met.

### Assisted Rerun Mode

Use this mode when hot reload cannot be verified.

1. Update the plugin script and expected build label.
2. Tell the human exactly which plugin to run again.
3. After the human confirms rerun, call `/figma-read`.
4. Continue with the same readback and diff checks.

## Readback Verification

Every round must prove it is reading the latest Figma output. Do not rely on timestamps or assumptions.

Minimum verification:

- `expected_build_label`: the build label just written by the agent
- `observed_build_label`: the label read from Figma metadata/context or visible screenshot
- `figma_url`: unchanged from target lock unless the human explicitly changes it
- `nodeId`: unchanged from target lock unless the human explicitly changes it
- `metadata_read`: pass/fail/blocked
- `screenshot_read`: pass/fail/blocked
- `design_context_read`: pass/fail/blocked

If `observed_build_label` does not match `expected_build_label`, stop the loop and report:

```md
hot_reload: failed
expected_build: <expected>
observed_build: <observed or missing>
action: ask human to rerun plugin once, then read again
```

## Diff Scope

Run the smallest diff set that can prove correctness, but never use screenshot-only guesses when source can be inspected.

Required diff categories when applicable:

- Token diff: CSS variables/design tokens vs Figma variables or direct fills
- Structure diff: component hierarchy/layout vs Figma node hierarchy
- Visual diff: product screenshot vs Figma screenshot
- Text/icon diff: visible labels, icon shape, version/build label

Prefer ZAI-MCP for visual diff when available. If unavailable, continue only when built-in image analysis is adequate for the requested confidence. For strict pixel-level claims, mark visual confidence as low or blocked unless equivalent visual tooling is available.

## Fix Policy

Choose the fix target based on the source of truth:

| Finding | Fix target |
|---------|------------|
| Figma output differs from product source | Fix the plugin script |
| Plugin script matches source but product screenshot differs | Debug product runtime/style loading |
| Source and Figma both differ from approved design | Ask the human to confirm the intended source of truth |
| Hot reload did not apply latest script | Stop and request assisted rerun |

Do not change product source merely to match a wrong Figma output. Product source changes require normal brainstorming/spec/plan governance or explicit human confirmation.

## Status Record Template

Record loop status in the active version/PR docs when this is part of a versioned workflow:

```md
## Figma Live Design Sync

- mode: bootstrap / live-loop / assisted-rerun
- figma_url:
- nodeId:
- plugin_script:
- plugin_dev_path:
- expected_build_label:
- observed_build_label:
- hot_reload: pass / failed / not_available
- figma_readiness: pass / blocked
- visual_diff_mode: zai / built-in / blocked
- confidence: high / medium / low
- loop_rounds:
- max_rounds:
- remaining_diff_summary:
- final_decision: pass / blocked / needs_human_decision
```

## Stop Conditions

Stop with `pass` only when:

- the latest build label is observed in Figma
- metadata, screenshot, and design context have been read successfully
- required token/structure/visual diffs are closed or explicitly accepted
- remaining blind spots are recorded

Stop with `blocked` when:

- Figma tools are missing from the current session
- hot reload cannot be verified and the human has not rerun the plugin
- Figma readback fails
- visual diff tooling is insufficient for the requested confidence
- loop budget is exhausted and unresolved diffs remain
