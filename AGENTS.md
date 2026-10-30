# AGENTS.md
<!-- Last reviewed: YYYY-MM-DD | Stack versions: <fill in> -->
<!-- Keep under ~150 lines. Every line must be a rule a reviewer could check. -->

## Project map
- Source: `src/` | Tests: `tests/` | Docs: `docs/` | Scripts: `scripts/`
- Entry point: `<path>` | Config: `<path>` (ask before editing)
- Shared helpers live in `<path>`. Search there before creating a new helper.

## Commands (use these exact commands)
- Install: `<npm ci | pnpm i --frozen-lockfile | pip install -r requirements.txt>`
- Dev: `<command>`
- Build: `<command>`
- Test all: `<command>` | Test one file: `<command> <path>`
- Lint + format: `<command>` | Typecheck: `<command>`

## Working rules
- Read the relevant files before editing. Do not guess paths, APIs, or function names; search the repo.
- Match the style of surrounding code. Do not reformat or rename unrelated code.
- Make the smallest change that solves the task. One concern per change/PR.
- Reuse existing utilities and patterns instead of adding new ones.
- If the task is ambiguous or touches more than ~5 files, state your plan first and ask.

## Code conventions
- Language/version: `<fill in>`. Strict typing on; no `any` / untyped escapes without a comment explaining why.
- Naming: `<camelCase | snake_case>` for functions, `<PascalCase>` for types/classes, kebab-case for file names.
- Handle errors explicitly. Never swallow exceptions with an empty catch.
- No `console.log` / `print` debugging left in committed code. Use the project logger: `<path>`.
- Comments explain why, not what. Remove dead code instead of commenting it out.

## Security and secrets
- Never commit secrets, tokens, or `.env` files. Read config from environment variables.
- Never log credentials or personal data.
- Validate and sanitize all external input. Use parameterized queries only.
- Do not add or upgrade dependencies without asking. If approved, pin the version.

## Testing
- New behavior needs a test. A bug fix needs a regression test that fails before the fix.
- Tests must be deterministic: no real network, no fixed sleeps, no dependence on test order.
- Never delete, skip, or weaken a test to make a run pass. Report the failure instead.
- E2E / Playwright rules: see `tests/AGENTS.md`.

## Git and PRs
- Branch: `<type>/<short-description>`. Commits: Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`, `test:`).
- Do not commit to `main`, force-push, or rewrite shared history.
- PR description: what changed, why, how it was tested.

## Definition of done
- [ ] Build, lint, and typecheck pass.
- [ ] Relevant tests pass (run them; do not assume).
- [ ] No unrelated files changed; no leftover debug code or TODOs without an issue link.
- [ ] Docs/README updated if behavior or commands changed.
- Final message: list files changed, commands run with results, and anything left unverified.

## Out of scope (ask first)
- CI/CD files, infra, Dockerfiles, lockfiles (unless the task is about them).
- Database migrations, public API contracts, auth/payment code.
- Deleting files or data, bulk renames, large refactors.
- Anything under `vendor/`, `dist/`, `build/`, `generated/`.