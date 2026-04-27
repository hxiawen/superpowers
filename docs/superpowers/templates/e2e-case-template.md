# E2E Spec Case Template

Use this template when writing `*.spec.ts` cases to keep test points and expected results auditable.

## Naming Convention

`test('<behavior> under <condition> should <expected_result>', async (...) => { ... })`

Good examples:
- `test('panel reopens with persisted selection after popup restart', async (...) => { ... })`
- `test('session list shows error banner when storage write fails', async (...) => { ... })`

## Skeleton

```typescript
import { test, expect } from '@playwright/test';

test('name: <behavior> under <condition> should <expected_result>', async ({ page }) => {
  // Given: preconditions and setup
  // - seed data / prepare environment
  // - navigate to the exact entry point

  // When: reproducible user actions
  // - perform explicit steps in stable order

  // Then: strong assertions (not visibility-only)
  // 1) UI state assertion
  await expect(page.locator('<critical-selector>')).toHaveText('<expected-text>');

  // 2) Key business state assertion (count/value/status)
  const value = await page.locator('<critical-selector>').textContent();
  expect(value).toBe('<expected-value>');

  // 3) Persistence or side-effect assertion (if applicable)
  // - verify storage/db readback OR reload and re-check
});
```

## Minimum Assertion Set

Each high-value case should include:
1. One user-visible assertion (`toHaveText` / `toHaveCount` / `toBeEnabled` etc.)
2. One business-critical value assertion (`expect(actual).toBe(expected)`)
3. One persistence/reload assertion for stateful features

## Edge/Failure Case Pattern

```typescript
test('name: <failure path> should show deterministic error state', async ({ page }) => {
  // Given: force error precondition (network/storage/permission)
  // When: trigger the operation
  // Then: verify explicit error state (message/code/fallback behavior)
  await expect(page.locator('<error-banner>')).toContainText('<expected-error>');
});
```

## Evidence Capture Guidance

- Log critical command/suite name in `Vx.y.z-PRn-tdd-log.md`
- Keep failure evidence concise: failing assertion line + key output
- Prefer deterministic selectors and avoid brittle timing-only waits
