# Plan PR Splitting Rules

Use these rules when converting plan tasks into PR groups.

## Rule 1: Dependency-first grouping

- Tasks with direct dependency chain belong to the same PR.
- If Task B requires Task A artifacts, group A+B in one PR unless there is a clear interface boundary.

## Rule 2: Independence separation

- Unrelated features or independent modules should be split into different PRs.
- Avoid mixed-purpose PRs that increase review complexity.

## Rule 3: Risk isolation

- Security-sensitive or migration-heavy tasks should have dedicated PRs.
- High-risk refactors should not be bundled with feature additions.

## Required Plan Section

Every `Vx.y.z-plan.md` must include:

```md
## PR Grouping

- Vx.y.z-PR1
  - Tasks: T1, T2, T3
  - Reason: <dependency rationale>

- Vx.y.z-PR2
  - Tasks: T4, T5
  - Reason: <independence rationale>
```
