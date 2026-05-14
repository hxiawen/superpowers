# Platform / repo release — test summary

Use this file as **`docs/platform-release-test.md`** when the repo is in a **platform-only** release (no new `docs/{prefix}vX.Y.Z-<topic>/` version directory). Create an empty marker **`/.superpowers/platform-release`** (optional first line: human label such as `chatbobi/v0.1.0`) so Stop gate and related hooks use this document instead of extension autotest/mocktest/devicetest.

Remove **`.superpowers/platform-release`** when returning to normal product version work so hooks resolve the latest `docs/{prefix}v*` directory again.

## Acceptance status (hooks)

Hooks read **only** this block (exact H2 title). Order must be **structure → build → git-history**.

```text
structure: pass
build: pass
git-history: pass
```

Supported status tokens match `hooks/acceptance-order-common` (pass, skip, N/A, 通过, …).

## Detailed Test Cases

- `TC-001` Repo layout / rename sanity | assertion: expected paths exist | status: pass

## Coverage Matrix

| domain | must_cover | linked_case_id | status |
|--------|------------|----------------|--------|
| layout | critical dirs | TC-001 | pass |

## Expectation Index

| case_id | expected_result | assertion_target |
|---------|-----------------|-------------------|
| TC-001 | structure matches plan | paths / globs |

## Known blind spots

- intentionally not covered in this platform bump
