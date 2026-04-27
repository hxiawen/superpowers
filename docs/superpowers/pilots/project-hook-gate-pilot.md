# Project Hook Gate Pilot Guide

## Goal

Pilot lightweight hook gates at the business-project layer to increase real defect discovery without replacing Superpowers workflow.

## Scope

Apply to a target project repository (not Superpowers core):

- `.claude/hooks/pre-commit-check.sh`
- `.claude/hooks/mark-review-needed.sh`
- `.claude/hooks/stop-gate.sh`

Templates are provided under:

- `docs/superpowers/templates/project-hooks/`

## Rollout Steps

1. Copy templates into target project `.claude/hooks/`.
2. Wire them in the project-level hook config (`PreToolUse`, `PostToolUse`, `Stop`).
3. Run pilot for 1-2 weeks with one team.
4. Record metrics weekly using `hook-gate-pilot-metrics-template.md`.

## Success Metrics

- Escaped defects found after merge (target: down)
- Defects caught before completion/commit (target: up)
- Stop-gate blocking count and unblock time
- False-positive gate rate
- Developer cycle-time impact

## Exit Criteria

- Keep pilot if defect catch rate improves and false-positive rate remains acceptable.
- Roll back or tune patterns if cycle-time impact is high or stop-gate is noisy.
