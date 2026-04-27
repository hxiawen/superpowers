# Historical Leak Pilot (Template Fill Example)

Purpose: demonstrate how the upgraded templates make a previously missed bug auditable.

## Scenario

- Historical symptom: automation passed, but manual check found state inconsistency after panel reopen.
- Target behavior: panel should restore previously selected session after popup restart.

## PR-Level Fill Example (`T-xxx`)

- **Test ID:** `T-017`
- **Test Scope:** `e2e`
- **Test Point:** `panel/session-selection persistence path`
- **Preconditions:** session list has at least 3 items; session `S-2` is selected
- **Actions:** open panel -> select `S-2` -> close popup -> reopen popup -> open panel
- **Expected Result:** selected session remains `S-2`
- **Assertion Target:** `expect(selectedSessionId).toBe("S-2")`
- **Negative/Edge Case:** if storage read fails, show deterministic fallback state with error banner
- **Out of Scope:** cross-device synchronization

## Version-Level Fill Example (`TC-xxx`)

### Coverage Matrix

| feature_domain | must_cover_test_point | linked_case_id | layer (unit/integration/e2e) | status |
|---|---|---|---|---|
| panel_state | reopen preserves selected session | `TC-031` | `e2e` | `pass` |
| storage_error | storage read failure fallback | `TC-032` | `integration` | `pass` |

### Expectation Index

| case_id | expected_result | assertion_target | command_or_suite |
|---|---|---|---|
| `TC-031` | selected session persists after reopen | `expect(selectedSessionId).toBe("S-2")` | `npx playwright test panel-state.spec.ts -g "preserves selected session"` |
| `TC-032` | error banner shown and UI enters fallback state | `expect(errorBanner).toContainText("Storage unavailable")` | `pnpm vitest storage-fallback.test.ts` |

### Known Blind Spots

- no coverage for corrupted IndexedDB schema migration in this pilot
- no coverage for service-worker crash during write path

## Validation Outcome

- With the old template, this case could appear as "passed" with visibility-only checks.
- With the new required fields, reviewer can verify:
  1. exact test point
  2. deterministic expected result
  3. machine-checkable assertion target
  4. declared blind spots
