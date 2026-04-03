/**
 * Playwright Global Setup
 *
 * Warms up the Flutter app and saves an empty storage state.
 * Flutter's auth state lives in memory (Riverpod/Supabase), not cookies,
 * so each fresh browser context will re-login via ensureAuthenticatedAt().
 * This setup just ensures the service worker is cached and the state file exists.
 */
import { chromium, FullConfig } from '@playwright/test';
import * as fs from 'fs';
import * as path from 'path';

const STORAGE_STATE_PATH = 'e2e/.auth/state.json';

export default async function globalSetup(config: FullConfig) {
  // Ensure the .auth directory exists
  const authDir = path.dirname(STORAGE_STATE_PATH);
  if (!fs.existsSync(authDir)) {
    fs.mkdirSync(authDir, { recursive: true });
  }

  const baseURL =
    process.env.E2E_BASE_URL ??
    config.projects[0]?.use?.baseURL ??
    'http://localhost:5000';

  console.log(`[global-setup] Warming up against ${baseURL}...`);

  const browser = await chromium.launch({
    args: ['--enable-webgl', '--use-gl=angle', '--use-angle=swiftshader'],
  });
  const context = await browser.newContext({
    locale: 'ar-SA',
    timezoneId: 'Asia/Riyadh',
  });
  const page = await context.newPage();

  try {
    // Load the app to warm up service workers and cache assets
    await page.goto(`${baseURL}/`);

    // Wait for Flutter to load (up to 60s)
    let flutterLoaded = false;
    for (let i = 0; i < 12; i++) {
      await page.waitForTimeout(5000);
      const has = await page.evaluate(
        () => !!document.querySelector('flutter-view'),
      );
      if (has) {
        flutterLoaded = true;
        console.log(`[global-setup] Flutter loaded after ${(i + 1) * 5}s`);
        break;
      }
    }

    if (!flutterLoaded) {
      console.warn('[global-setup] Flutter did not load within 60s — tests may be slow');
    }
  } catch (err) {
    console.warn(`[global-setup] Warmup error: ${err}`);
  }

  // Save storage state (mostly empty, but creates the file Playwright expects)
  await context.storageState({ path: STORAGE_STATE_PATH });
  console.log('[global-setup] Storage state saved.');
  await browser.close();
}
