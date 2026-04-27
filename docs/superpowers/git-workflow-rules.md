# Superpowers Git Workflow Rules (Xia)

## Scope

- `main` only tracks `superpowers/5.0.7`.
- Other folders may exist locally, but should not be added to `main`.

## Commit Rules

- One topic per commit.
- Preferred message format:
  - `superpowers: add <topic>`
  - `superpowers: update <topic>`
  - `superpowers: fix <topic>`
  - `superpowers: docs <topic>`
- Avoid mixed commits that touch unrelated topics.

## Branch Rules

- Keep `main` always usable.
- Use short-lived branches for risky experiments:
  - `sp/feat-<topic>`
  - `sp/fix-<topic>`
- Merge only after local verification and clear commit history.

## Tag Rules (Milestone Anchor)

- Tag every stable milestone.
- Naming format:
  - `sp-v5.0.7-xia-YYYY-MM-DD-XX`
- Example:
  - `sp-v5.0.7-xia-2026-04-22-01`
- Push tags to remote immediately after creation.

## Rollback Rules

- Single bad commit rollback:
  - `git revert <commit>`
- Return local workspace to a known milestone:
  - `git reset --hard <tag>`
- If rollback is needed on shared remote, prefer a new revert commit over rewriting remote history.

## Daily Minimum Loop

1. `git status -sb`
2. Scoped add under `superpowers/5.0.7`
3. Commit with clear topic
4. `git push`
5. If milestone reached: create and push tag
