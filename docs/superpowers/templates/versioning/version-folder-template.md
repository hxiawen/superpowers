# Version Folder Template

Use this structure for each version:

```text
docs/
  Vx.y.z-<topic>/
    Vx.y.z-design.md
    Vx.y.z-spec.md
    Vx.y.z-plan.md
    Vx.y.z-changelog.md
    Vx.y.z-decisions.md
    Vx.y.z-test.md
    Vx.y.z-PR1/
    Vx.y.z-PR2/
```

## Required Root Docs

- `Vx.y.z-design.md`: design rationale and solution outline
- `Vx.y.z-spec.md`: implementable requirements and acceptance criteria
- `Vx.y.z-plan.md`: task decomposition and PR grouping
- `Vx.y.z-changelog.md`: incremental version-level change log
- `Vx.y.z-decisions.md`: key decisions and tradeoffs
- `Vx.y.z-test.md`: version-level test summary; hooks read `autotest` / `mocktest` / `devicetest` **only** under the exact H2 `## Acceptance status (hooks)` (see `version-test-template.md`)

## Naming Rules

- Version root must start with `V` and semantic-like version (`V0.1.1-...`)
- `<topic>` must use exactly 2 theme keywords separated by `-`
- Example names: `v0.1.4-scroll-highlight`, `v0.1.5-panel-ui`
- PR folders must be `Vx.y.z-PRn`
- Keep topic suffix stable within a version
