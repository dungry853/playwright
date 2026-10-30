# Playwright Test Project

End-to-end test project built with [Playwright](https://playwright.dev/) and TypeScript, running inside Docker. It includes the **Playwright CLI** (`@playwright/cli`) and supports **Playwright Test Agents** (planner, generator, healer).

## Table of Contents

- [Playwright Test Project](#playwright-test-project)
  - [Table of Contents](#table-of-contents)
  - [Tech Stack](#tech-stack)
  - [Project Structure](#project-structure)
  - [Prerequisites](#prerequisites)
  - [Build \& Setup](#build--setup)
    - [Option A: Docker (recommended)](#option-a-docker-recommended)
    - [Option B: Local (without Docker)](#option-b-local-without-docker)
    - [Verify the build](#verify-the-build)
    - [Rebuilding after changes](#rebuilding-after-changes)
  - [Environment Variables](#environment-variables)
  - [Running Tests](#running-tests)
    - [npm scripts](#npm-scripts)
    - [Browsers](#browsers)
    - [Artifacts](#artifacts)
  - [Playwright CLI](#playwright-cli)
    - [`scripts/pw.cmd`](#scriptspwcmd)
  - [Playwright Agents](#playwright-agents)
  - [Initialize AI Agents](#initialize-ai-agents)
    - [1. Initialize Playwright Test Agents](#1-initialize-playwright-test-agents)
    - [2. Install Playwright CLI Skills](#2-install-playwright-cli-skills)
  - [Writing Tests](#writing-tests)
    - [Conventions](#conventions)
  - [Reports \& Debugging](#reports--debugging)
  - [How the Docker Setup Works](#how-the-docker-setup-works)
  - [Git Conventions](#git-conventions)
  - [Troubleshooting](#troubleshooting)
  - [References](#references)

## Tech Stack

| Component | Version |
| --- | --- |
| Playwright (`@playwright/test`) | 1.64.1 (pinned) |
| TypeScript | ^5.8 |
| Node.js types | ^22 |
| dotenv | ^16.4 |
| Docker base image | `mcr.microsoft.com/playwright:v1.64.1-noble` |

> `PLAYWRIGHT_VERSION` (Docker) **must match** the `@playwright/test` version in `package.json`. That is why `@playwright/test` is pinned without a `^`. A mismatch causes browser incompatibility errors, and the container prints a warning on startup if it detects one.

## Project Structure

```text
playwright/
├── data/                   # Test data (JSON, CSV, upload files, ...)
├── docker/
│   ├── Dockerfile          # Playwright image + @playwright/cli
│   ├── docker-compose.yml  # playwright (shell) and test (one-shot run) services
│   └── entrypoint.sh       # Auto-installs dependencies when package-lock.json changes
├── fixtures/
│   └── test.ts             # Custom fixtures (extends @playwright/test)
├── pages/                  # Page Object Model classes
├── scripts/
│   └── pw.cmd              # Windows helper script
├── tests/
│   └── example.spec.ts     # Test files (*.spec.ts)
├── utils/                  # Shared helpers
├── playwright-report/      # HTML report (generated, git-ignored)
├── test-results/           # Traces, screenshots, videos (generated, git-ignored)
├── .env                    # Local environment variables (not committed)
├── .env.example            # Environment template (committed)
├── .dockerignore
├── .gitignore
├── package.json
├── package-lock.json       # Commit this file
├── playwright.config.ts    # Playwright configuration
├── tsconfig.json
└── README.md
```

## Prerequisites

**Docker (recommended)**

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) or Docker Engine with Compose **v2.24 or newer** (needed for the optional `env_file` setting)
- Git

**Local (optional)**

- Node.js 20 or newer
- npm 10 or newer

## Build & Setup

### Option A: Docker (recommended)

**1. Clone the repository**

```bash
git clone <repo-url>
```

**2. Create the environment file**

```bash
# macOS / Linux / Git Bash
cp .env.example .env

# Windows (cmd)
copy .env.example .env
```

Edit `.env` and set `BASE_URL` to the application under test (see [Environment Variables](#environment-variables)). `.env` and `.env.example` start with a dot, so some file browsers hide them.

**3. Build the Docker image**

```bash
docker compose -f docker/docker-compose.yml build
```

Optional: add a shortcut for the long command.

```bash
# macOS / Linux / Git Bash
alias dcp='docker compose -f docker/docker-compose.yml'
# Window
alias dcp=docker compose -f docker/docker-compose.yml $*
```

The examples below use `dcp` as shorthand for the full command.


**4. Install dependencies on Windows (Optional)**

If you use VS Code or another IDE on Windows and want IntelliSense, TypeScript autocompletion, and code navigation, install dependencies locally:

```bash
npm ci
```

> This step is optional and only needed for IDE support. Tests still run inside Docker, where dependencies are managed separately.

**5. Open a shell in the container**

```bash
dcp run --rm playwright
```

You are now in `/workspace`, which is your project folder mounted into the container. On the first start, the entrypoint runs `npm ci` automatically, so there is **no manual install step**.

**6. Type-check and run the tests**

```bash
npm run typecheck
npm test
```

Or run all tests in one command without opening a shell:

```bash
dcp --profile test run --rm test
```

### Option B: Local (without Docker)

```bash
git clone <repo-url>
cd playwright

cp .env.example .env                  # set BASE_URL to http://localhost:<port>
npm ci                                # install dependencies
npx playwright install --with-deps    # download browsers and OS dependencies
npm run typecheck
npm test
```

When running locally, `BASE_URL` should point to `http://localhost:<port>` instead of `host.docker.internal`.

### Verify the build

| Check | Command | Expected result |
| --- | --- | --- |
| Compose file is valid | `dcp config` | Prints the resolved configuration, with your `BASE_URL` |
| Docker image builds | `dcp build` | Completes without errors |
| Dependencies installed | `npm ls @playwright/test` | Shows version `1.64.1` |
| TypeScript compiles | `npm run typecheck` | No output, exit code 0 |
| Tests are discovered | `npx playwright test --list` | Lists tests from `tests/` |
| Playwright CLI available | `playwright-cli --help` | Prints usage |

> There is no separate compile step. Playwright transpiles TypeScript on the fly, and `npm run typecheck` (`tsc --noEmit`) validates types only.

### Rebuilding after changes

| Change | What to do |
| --- | --- |
| Edited `package.json` dependencies | Run `npm install` in the container, commit the updated `package-lock.json`. The entrypoint reinstalls automatically on the next start |
| Edited `Dockerfile` or `entrypoint.sh` | `dcp build` |
| Changed `PLAYWRIGHT_VERSION` or `PLAYWRIGHT_CLI_VERSION` | `dcp --env-file .env build --no-cache` (see the note below) |
| Corrupted or stale `node_modules` volume | `dcp down -v`, then start the container again |
| Upgrading Playwright | Update `PLAYWRIGHT_VERSION` in `.env` and `@playwright/test` in `package.json`, then `dcp --env-file .env build --no-cache`, `dcp down -v`, and start again |

> **Why `--env-file .env` for builds?** Compose reads values for `${...}` interpolation (such as the build args) from a `.env` next to the compose file, not from the project root. Pass `--env-file .env` whenever you override `PLAYWRIGHT_VERSION` or `PLAYWRIGHT_CLI_VERSION`. Runtime variables such as `BASE_URL` and `CI` are loaded separately through `env_file` and need no flag.

## Environment Variables

Defined in `.env` (copy from `.env.example`):

| Variable | Default | Description |
| --- | --- | --- |
| `PLAYWRIGHT_VERSION` | `1.64.1` | Playwright image version used at Docker build time. Must match `@playwright/test` |
| `PLAYWRIGHT_CLI_VERSION` | `latest` | Version of `@playwright/cli` installed in the image. Pin it for reproducible builds (`npm view @playwright/cli version`) |
| `BASE_URL` | `http://host.docker.internal:8000` | URL of the application under test. **Required**: the config throws an error if it is missing |
| `CI` | `false` | When `true`: 2 retries, 1 worker, and `test.only` is forbidden |

To reach an app running on your host machine from inside the container, use `host.docker.internal` instead of `localhost`. The compose file maps it via `extra_hosts`, so it also works on Linux. Make sure your app listens on `0.0.0.0`, not only `127.0.0.1`.

## Running Tests

Run these inside the container (or locally for Option B):

```bash
npm test                 # all tests, headless
npm run test:report      # open the HTML report
npm run typecheck        # TypeScript check
```

Targeted runs:

```bash
npx playwright test tests/example.spec.ts          # one file
npx playwright test -g "test title"                # by title
npx playwright test --project=chromium             # one browser
npx playwright test --project=firefox --project=webkit
npx playwright test --list                         # list without running
```

One-shot runs from the host (no interactive shell), for example in CI:

```bash
dcp --profile test run --rm test                                   # all tests
dcp --profile test run --rm test npx playwright test --project=chromium
```

### npm scripts

| Script | Command | Description |
| --- | --- | --- |
| `npm test` | `playwright test` | Run tests headless |
| `npm run test:headed` | `playwright test --headed` | Run with a visible browser* |
| `npm run test:ui` | `playwright test --ui` | Open UI Mode* |
| `npm run test:debug` | `playwright test --debug` | Debug with Playwright Inspector* |
| `npm run test:report` | `playwright show-report` | Open the HTML report |
| `npm run agents:init` | `playwright init-agents` | Initialize Playwright Agents |
| `npm run typecheck` | `tsc --noEmit` | Type-check only |

\* Headed, UI, and debug modes need a display and do not work directly inside the container. Run them locally (Option B), or set up X11/VNC forwarding for the container.

### Browsers

Configured in `playwright.config.ts`: **Chromium**, **Firefox**, and **WebKit** (desktop). Mobile and branded Edge/Chrome projects are included as comments; uncomment them to enable.

### Artifacts

| Type | Policy |
| --- | --- |
| Trace | `retain-on-failure` |
| Screenshot | `only-on-failure` |
| Video | `retain-on-failure` |

Output goes to `test-results/`; the HTML report goes to `playwright-report/`.

## Playwright CLI

The Docker image installs `@playwright/cli` globally. It lets you drive a browser from the command line, which is useful for exploring pages, taking snapshots, and trying selectors, and it is the same tooling AI agents can use.

```bash
playwright-cli --help
```

Command names can change between versions, so use `--help` for the current list. If the CLI creates new folders in the project root (for example snapshots), check `git status` and add them to `.gitignore`.

### `scripts/pw.cmd`

A Windows helper script for running Playwright-related commands without typing the full Docker Compose command. See the file for exact usage, for example:

```bat
scripts\pw.cmd npx playwright test
```

## Playwright Agents

Playwright Test Agents provide three roles:

| Agent | Role |
| --- | --- |
| Planner | Explores the app and writes a Markdown test plan |
| Generator | Turns the plan into Playwright test files |
| Healer | Runs tests and repairs failing ones |


## Initialize AI Agents

### 1. Initialize Playwright Test Agents

Generate agent definitions for your preferred AI coding tool.
Supported AI tools:

```bash
npx playwright init-agents --loop=vscode
npx playwright init-agents --loop=claude
npx playwright init-agents --loop=opencode
```

Run the following command to see all available options:

```bash
npx playwright init-agents --help
```

### 2. Install Playwright CLI Skills

Install the official Playwright CLI skill for AI coding agents.

```bash
playwright-cli install --skills=agents
```

The skill provides instructions for browser automation using Playwright CLI.

**Notes:**
- Run commands from the project root.
- Commit generated agent definitions and skills to share them with your team.
- Re-run `agents:init` after upgrading Playwright to refresh agent definitions.

## Writing Tests

The project uses the **Page Object Model** and **custom fixtures**.

`pages/login.page.ts`

```typescript
import { Page, Locator } from "@playwright/test";

export class LoginPage {
  readonly username: Locator;
  readonly password: Locator;
  readonly submit: Locator;

  constructor(private readonly page: Page) {
    this.username = page.getByLabel("Username");
    this.password = page.getByLabel("Password");
    this.submit = page.getByRole("button", { name: "Sign in" });
  }

  async goto() {
    await this.page.goto("/login");
  }

  async login(user: string, pass: string) {
    await this.username.fill(user);
    await this.password.fill(pass);
    await this.submit.click();
  }
}
```

`fixtures/test.ts`

```typescript
import { test as base } from "@playwright/test";
import { LoginPage } from "../pages/login.page";

export const test = base.extend<{ loginPage: LoginPage }>({
  loginPage: async ({ page }, use) => {
    await use(new LoginPage(page));
  },
});

export { expect } from "@playwright/test";
```

`tests/login.spec.ts`

```typescript
import { test, expect } from "../fixtures/test";

test("user can sign in", async ({ loginPage, page }) => {
  await loginPage.goto();
  await loginPage.login("demo", "secret");
  await expect(page).toHaveURL(/dashboard/);
});
```

### Conventions

- Put tests in `tests/` and name them `*.spec.ts`.
- Put page objects in `pages/`, test data in `data/`, shared helpers in `utils/`.
- Prefer user-facing locators: `getByRole`, `getByLabel`, `getByText`, `getByTestId`.
- Use relative paths with `baseURL`: `page.goto("/login")`.
- Never commit `test.only` (CI fails on it via `forbidOnly`).
- Keep authentication state in `.auth/` (git-ignored), never in committed files.

## Reports & Debugging

```bash
npm run test:report
```

`playwright show-report` starts a server inside the container. To view it from your host, serve it on all interfaces and open <http://localhost:9323>:

```bash
npx playwright show-report --host 0.0.0.0 --port 9323
```

Port `9323` is already published by the `playwright` service. You can also open `playwright-report/index.html` directly, since the folder is mounted to your machine.

Open the trace of a failed test:

```bash
npx playwright show-trace test-results/<test-folder>/trace.zip
```

## How the Docker Setup Works

| Piece | Purpose |
| --- | --- |
| `docker/Dockerfile` | Starts from the official Playwright image (browsers preinstalled at `/ms-playwright`) and installs `@playwright/cli`. Uses an npm cache mount for faster rebuilds |
| `docker/entrypoint.sh` | Runs `npm ci` on startup only when `package-lock.json` changed, and warns if `@playwright/test` does not match the image version |
| `playwright` service | Interactive shell (`bash`), publishes port `9323` for the report server |
| `test` service | One-shot `npx playwright test`, enabled with `--profile test` |
| `env_file: ../.env` | Loads `BASE_URL`, `CI`, etc. from the project root (optional file) |
| `node_modules` volume | Keeps dependencies inside Docker, separate from the host, for speed and OS compatibility |
| `npm_cache` volume | Reuses the npm download cache across `npm ci` runs |
| `..:/workspace` mount | Your source is mounted live, so host edits appear immediately |
| `ipc: host` | Prevents Chromium crashes caused by limited shared memory |
| `init: true` | Reaps zombie browser processes |
| `.dockerignore` | Allows only `docker/entrypoint.sh` into the build context, because the source is mounted at runtime |

Browsers are preinstalled in the image, so `npx playwright install` is not needed in the container.

## Git Conventions

- **Commit** `package-lock.json` (the entrypoint and `npm ci` depend on it) and `.env.example`.
- **Do not commit** `.env`, `node_modules/`, `playwright-report/`, `test-results/`, `.auth/`, `.storage/`.
- Recommended `.gitignore`:

```gitignore
node_modules/

.env
.env.*
!.env.example

playwright-report/
test-results/
blob-report/
playwright/.cache/

.auth/
.storage/

*.log
.DS_Store
```

## Troubleshooting

| Symptom | Cause / Fix |
| --- | --- |
| `BASE_URL is required...` | `.env` is missing in the project root. Create it from `.env.example` |
| `BASE_URL` seems ignored | Run `dcp config` to see the resolved value. Check that `.env` is in the project root and the Compose version is 2.24 or newer |
| `ERR_CONNECTION_REFUSED` | App is not running or listens only on `127.0.0.1`. Bind to `0.0.0.0` and use `host.docker.internal` |
| `WARNING: @playwright/test is X but the image is Y` | Versions differ. Align `package.json` and `PLAYWRIGHT_VERSION`, then rebuild |
| `Executable doesn't exist` or browser version errors | Same cause as above |
| `npm ci` fails with a lockfile error | `package.json` and `package-lock.json` are out of sync. Run `npm install` and commit the lockfile |
| Dependencies did not update | Delete the volume: `dcp down -v`, then start again |
| Chromium crashes or hangs | Check that `ipc: host` is still in the compose file |
| `entrypoint.sh: not found` or `\r` errors | Line endings issue; the Dockerfile strips CRLF, so rebuild with `dcp build --no-cache` |
| Root-owned files on a Linux host | The container runs as root; run `sudo chown -R $USER .` on the host |
| Old `docker_playwright_node_modules` volume left over | Remove it with `docker volume rm docker_playwright_node_modules` |

## References

- [Playwright Documentation](https://playwright.dev/docs/intro)
- [Playwright with Docker](https://playwright.dev/docs/docker)
- [Playwright Test Agents](https://playwright.dev/docs/test-agents)
- [Page Object Models](https://playwright.dev/docs/pom)
