---
name: gitsp
description: One-click checkpoint for Superpowers updates: commit and push scoped changes, then optionally create and push a milestone tag. Use when user asks for "/gitsp", one-click GitHub push, or milestone tagging for superpowers/5.0.7.
---

# GitSP

## Purpose

Provide a safe, repeatable one-command flow to push Superpowers changes and optionally create a milestone tag.

Scope is fixed to:

- `superpowers/5.0.7`

## Required Inputs

Before running, collect:

1. Commit topic message (required)
2. Whether to create a milestone tag (optional)
3. Tag name if tagging is enabled (recommended format: `sp-v5.0.7-xia-YYYY-MM-DD-XX`)

## Command

Use the checkpoint script from repo root:

```bash
superpowers/5.0.7/scripts/sp-checkpoint.sh -m "<topic message>"
```

With milestone tag:

```bash
superpowers/5.0.7/scripts/sp-checkpoint.sh -m "<topic message>" --tag sp-v5.0.7-xia-YYYY-MM-DD-XX
```

## Execution Rules

1. Do not stage paths outside `superpowers/5.0.7`.
2. If no staged diff exists in scope, report "nothing to commit" and stop.
3. Preserve commit prefix format `superpowers: ...`.
4. After success, report:
   - branch
   - commit SHA
   - whether tag was created
   - pushed remote
5. If push fails, stop and return exact error reason.

## Post-Run Report Template

```md
## GitSP Result

- branch: <branch>
- commit: <sha>
- remote: origin
- tag: <tag-name or none>
- scope: superpowers/5.0.7
- status: success|failed
- note: <short detail>
```
