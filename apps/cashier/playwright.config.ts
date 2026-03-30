import { defineConfig } from '@playwright/test';

const baseURL = process.env.E2E_BASE_URL ?? 'http://localhost:5000';

export default defineConfig({
  testDir: './e2e/tests',
  // Flutter Web + CanvasKit needs 30-45s to load in headless Chromium.
  // Each test gets 120s to account for navigation + assertions.
  timeout: 120_000,
  expect: {
    timeout: 15_000,
  },
  fullyParallel: false,
  retries: 2,
  workers: 1,
  reporter: [['html', { open: 'never' }], ['list']],
  // Global setup: login once, save auth state
  globalSetup: require.resolve('./e2e/global-setup'),
  use: {
    baseURL,
    screenshot: 'only-on-failure',
    trace: 'on-first-retry',
    locale: 'ar-SA',
    timezoneId: 'Asia/Riyadh',
    // Reuse auth state from global setup
    storageState: 'e2e/.auth/state.json',
    // Grant clipboard permissions for OTP paste functionality
    permissions: ['clipboard-read', 'clipboard-write'],
    // Flutter CanvasKit requires WebGL. SwiftShader provides software
    // rendering in headless Chromium so the canvas can initialise.
    launchOptions: {
      args: [
        '--enable-webgl',
        '--use-gl=angle',
        '--use-angle=swiftshader',
      ],
    },
  },
  projects: [
    {
      name: 'chromium',
      use: { browserName: 'chromium' },
    },
  ],
});
