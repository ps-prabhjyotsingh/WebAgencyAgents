---
name: playwright-testing
description: Sets up and manages Playwright end-to-end testing for web applications across all supported stacks (Laravel standalone, Laravel+React, Node.js). Use this skill when users need E2E tests, browser testing, integration tests with Playwright, visual regression testing, or when setting up automated testing pipelines. Also use when users mention "testing the UI", "end-to-end tests", "browser tests", or "E2E" in the context of any supported stack.
---

# Playwright Testing Skill

Sets up Playwright E2E testing with stack-aware configuration, Docker integration, and common test patterns.

## Stack Detection

Determine the stack before generating configuration:

1. **Laravel standalone** — `composer.json` exists, no separate React frontend, Blade/Livewire templates
2. **Laravel + React** — `composer.json` for backend + separate React app (Vite/CRA) with its own `package.json`
3. **Node.js** — `package.json` with Express/Fastify/NestJS/Koa, no `composer.json`

## Setup

### Step 1: Install Playwright

```bash
# In the frontend directory (or project root for Node.js/Laravel standalone)
npm init playwright@latest -- --quiet --browser=chromium --browser=firefox --browser=webkit
```

For Laravel standalone without existing `package.json`:
```bash
npm init -y
npm init playwright@latest -- --quiet --browser=chromium --browser=firefox --browser=webkit
```

### Step 2: Generate Config

Use the appropriate config template based on detected stack.

#### Laravel Standalone Config

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ['html', { outputFolder: 'tests/e2e/reports' }],
    ['list'],
  ],
  use: {
    baseURL: process.env.APP_URL || 'http://localhost:8000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
    {
      name: 'mobile-chrome',
      use: { ...devices['Pixel 5'] },
    },
  ],
  webServer: {
    command: 'php artisan serve --port=8000',
    url: 'http://localhost:8000',
    reuseExistingServer: !process.env.CI,
    timeout: 30000,
  },
});
```

#### Laravel + React Config

```typescript
// playwright.config.ts (in React frontend directory)
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ['html', { outputFolder: 'tests/e2e/reports' }],
    ['list'],
  ],
  use: {
    baseURL: process.env.FRONTEND_URL || 'http://localhost:5173',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
    {
      name: 'mobile-chrome',
      use: { ...devices['Pixel 5'] },
    },
  ],
  webServer: [
    {
      command: 'npm run dev',
      url: 'http://localhost:5173',
      reuseExistingServer: !process.env.CI,
      timeout: 30000,
    },
  ],
});
```

#### Node.js Config

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ['html', { outputFolder: 'tests/e2e/reports' }],
    ['list'],
  ],
  use: {
    baseURL: process.env.APP_URL || 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
    {
      name: 'mobile-chrome',
      use: { ...devices['Pixel 5'] },
    },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
    timeout: 30000,
  },
});
```

### Step 3: Create Directory Structure

```
tests/
  e2e/
    fixtures/       # Shared test fixtures and helpers
    pages/          # Page Object Model classes
    specs/          # Test spec files
    reports/        # HTML test reports (gitignored)
    global-setup.ts # Global setup (auth, seeding, etc.)
```

### Step 4: Create Base Fixtures

```typescript
// tests/e2e/fixtures/base.ts
import { test as base } from '@playwright/test';

export const test = base.extend({
  // Auto-wait for page to be stable
  page: async ({ page }, use) => {
    page.setDefaultTimeout(10000);
    page.setDefaultNavigationTimeout(15000);
    await use(page);
  },
});

export { expect } from '@playwright/test';
```

### Step 5: Add Scripts to package.json

```json
{
  "scripts": {
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui",
    "test:e2e:debug": "playwright test --debug",
    "test:e2e:report": "playwright show-report tests/e2e/reports"
  }
}
```

### Step 6: Update .gitignore

Add these entries:
```
tests/e2e/reports/
test-results/
playwright-report/
blob-report/
```

## Common Test Patterns

### Authentication Flow

```typescript
// tests/e2e/specs/auth.spec.ts
import { test, expect } from '../fixtures/base';

test.describe('Authentication', () => {
  test('user can register', async ({ page }) => {
    await page.goto('/register');
    await page.getByLabel('Name').fill('Test User');
    await page.getByLabel('Email').fill('test@example.com');
    await page.getByLabel('Password', { exact: true }).fill('password123');
    await page.getByLabel('Confirm Password').fill('password123');
    await page.getByRole('button', { name: 'Register' }).click();
    await expect(page).toHaveURL('/dashboard');
  });

  test('user can login', async ({ page }) => {
    await page.goto('/login');
    await page.getByLabel('Email').fill('test@example.com');
    await page.getByLabel('Password').fill('password123');
    await page.getByRole('button', { name: 'Log in' }).click();
    await expect(page).toHaveURL('/dashboard');
  });

  test('user can logout', async ({ page }) => {
    // Assume authenticated via storageState or fixture
    await page.goto('/dashboard');
    await page.getByRole('button', { name: 'Logout' }).click();
    await expect(page).toHaveURL('/');
  });
});
```

### Reusable Auth State (Global Setup)

```typescript
// tests/e2e/global-setup.ts
import { chromium, FullConfig } from '@playwright/test';

async function globalSetup(config: FullConfig) {
  const { baseURL } = config.projects[0].use;
  const browser = await chromium.launch();
  const page = await browser.newPage();

  await page.goto(`${baseURL}/login`);
  await page.getByLabel('Email').fill(process.env.TEST_USER_EMAIL || 'admin@example.com');
  await page.getByLabel('Password').fill(process.env.TEST_USER_PASSWORD || 'password');
  await page.getByRole('button', { name: 'Log in' }).click();
  await page.waitForURL('**/dashboard');

  await page.context().storageState({ path: 'tests/e2e/.auth/user.json' });
  await browser.close();
}

export default globalSetup;
```

### CRUD Operations Pattern

```typescript
// tests/e2e/specs/crud-resource.spec.ts
import { test, expect } from '../fixtures/base';

test.describe('Resource CRUD', () => {
  test.use({ storageState: 'tests/e2e/.auth/user.json' });

  test('can create resource', async ({ page }) => {
    await page.goto('/resources/create');
    await page.getByLabel('Title').fill('Test Resource');
    await page.getByLabel('Description').fill('A test resource');
    await page.getByRole('button', { name: 'Save' }).click();
    await expect(page.getByText('Resource created')).toBeVisible();
  });

  test('can list resources', async ({ page }) => {
    await page.goto('/resources');
    await expect(page.getByRole('table')).toBeVisible();
    await expect(page.getByText('Test Resource')).toBeVisible();
  });

  test('can edit resource', async ({ page }) => {
    await page.goto('/resources');
    await page.getByText('Test Resource').click();
    await page.getByRole('link', { name: 'Edit' }).click();
    await page.getByLabel('Title').fill('Updated Resource');
    await page.getByRole('button', { name: 'Save' }).click();
    await expect(page.getByText('Resource updated')).toBeVisible();
  });

  test('can delete resource', async ({ page }) => {
    await page.goto('/resources');
    await page.getByText('Updated Resource').click();
    await page.getByRole('button', { name: 'Delete' }).click();
    await page.getByRole('button', { name: 'Confirm' }).click();
    await expect(page.getByText('Resource deleted')).toBeVisible();
  });
});
```

### Page Object Model

```typescript
// tests/e2e/pages/login.page.ts
import { Page, Locator, expect } from '@playwright/test';

export class LoginPage {
  readonly page: Page;
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly submitButton: Locator;
  readonly errorMessage: Locator;

  constructor(page: Page) {
    this.page = page;
    this.emailInput = page.getByLabel('Email');
    this.passwordInput = page.getByLabel('Password');
    this.submitButton = page.getByRole('button', { name: 'Log in' });
    this.errorMessage = page.getByRole('alert');
  }

  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }

  async expectError(message: string) {
    await expect(this.errorMessage).toContainText(message);
  }
}
```

### API Testing Pattern (Node.js / Laravel API)

```typescript
// tests/e2e/specs/api.spec.ts
import { test, expect } from '@playwright/test';

test.describe('API Endpoints', () => {
  let authToken: string;

  test.beforeAll(async ({ request }) => {
    const response = await request.post('/api/login', {
      data: { email: 'admin@example.com', password: 'password' },
    });
    const body = await response.json();
    authToken = body.token;
  });

  test('GET /api/resources returns list', async ({ request }) => {
    const response = await request.get('/api/resources', {
      headers: { Authorization: `Bearer ${authToken}` },
    });
    expect(response.ok()).toBeTruthy();
    const body = await response.json();
    expect(body.data).toBeInstanceOf(Array);
  });

  test('POST /api/resources creates resource', async ({ request }) => {
    const response = await request.post('/api/resources', {
      headers: { Authorization: `Bearer ${authToken}` },
      data: { title: 'New Resource', description: 'Created via API test' },
    });
    expect(response.status()).toBe(201);
  });
});
```

## Docker Integration

### Running Playwright in Docker

Add to `docker-compose.yml` for CI/headless runs:

```yaml
  playwright:
    image: mcr.microsoft.com/playwright:v1.52.0-noble
    container_name: {{PROJECT_NAME}}-playwright
    volumes:
      - .:/app
    working_dir: /app
    environment:
      - CI=true
      - APP_URL=http://app:{{APP_PORT}}
    depends_on:
      app:
        condition: service_healthy
    networks:
      - {{PROJECT_NAME}}-network
    command: npx playwright test
```

### Running Tests Against Docker Services

Override `baseURL` via environment variable:
```bash
# Against Docker services
APP_URL=http://localhost:8000 npx playwright test

# Against Docker network (from within container)
APP_URL=http://app:3000 npx playwright test
```

### Makefile Targets

```makefile
test-e2e:
	docker compose exec app npx playwright test

test-e2e-ui:
	npx playwright test --ui

test-e2e-docker:
	docker compose run --rm playwright
```

## Best Practices

- Use `getByRole`, `getByLabel`, `getByText` locators — avoid CSS/XPath selectors
- Use Page Object Model for complex pages with many interactions
- Keep tests independent — each test should set up its own state
- Use `test.describe` to group related tests
- Use `test.beforeAll` for expensive setup like authentication
- Use `storageState` to share auth across tests without re-logging in
- Name test files as `*.spec.ts` in `tests/e2e/specs/`
- Add `tests/e2e/reports/` and `test-results/` to `.gitignore`
- Use `expect(page).toHaveURL()` for navigation assertions
- Use `expect(locator).toBeVisible()` before interacting with elements
- Set reasonable timeouts: 10s default, 15s navigation, 30s for server startup
- For flaky tests, add `test.retry(2)` or investigate root cause
