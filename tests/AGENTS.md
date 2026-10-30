# Playwright test rules (applies under tests/)
<!-- Nearest AGENTS.md wins; this file adds to the root one. Adjust paths to your repo. -->

## Project map
- Specs: `tests/e2e/**/*.spec.ts` | Page objects: `tests/pages/*.page.ts`
- Fixtures: `tests/fixtures.ts`. Import `test` and `expect` from here, never directly from `@playwright/test`.
- Seed/setup: `tests/seed.spec.ts` | Config: `playwright.config.ts` (do not edit without asking)

## Commands
- All: `npx playwright test` | One file: `npx playwright test tests/e2e/<name>.spec.ts`
- UI mode: `npx playwright test --ui` | Flake check: `npx playwright test <file> --repeat-each=3`

## Locators
- Priority: `getByRole` > `getByLabel` / `getByText` > `getByTestId`.
- No CSS classes, XPath, or `nth()` unless no accessible attribute exists; add a comment explaining why.
- Test ids: `data-testid`, kebab-case.

## Waits and assertions
- Never use `page.waitForTimeout()`. Use web-first assertions: `await expect(locator).toBeVisible()`.
- Do not use `if (await locator.isVisible())` for checks. It does not wait.
- Navigation: `await expect(page).toHaveURL(/dashboard/)`.

## Isolation and data
- Each test passes alone and in any order; no shared mutable state.
- Log in via the auth fixture (`storageState`), never through the UI inside a test body.
- Create data via API helper `tests/helpers/api.ts`; clean up in fixture teardown.
- Use `baseURL` from config. No hardcoded hosts or ports.

## Network
- Mock third-party services with `page.route()`. Never mock our own API in E2E tests.

## Definition of done
- `--repeat-each=3` passes; lint clean.
- One scenario per `test()`, titled as a user outcome (e.g. "shows an error for a wrong password").
- Diff contains test code only: no changes to snapshots, config, or CI.

## Out of scope
- No new dependencies. No `test.skip` / `test.fixme` to get green. Report the failure instead.