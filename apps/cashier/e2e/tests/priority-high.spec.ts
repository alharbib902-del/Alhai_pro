import { expect, test, Page } from '@playwright/test';
import {
  ensureAuthenticatedAt,
  expectNoFatalRouteError,
} from '../helpers/cashier';

async function assertProtectedRouteLoads(page: Page, route: string): Promise<void> {
  await ensureAuthenticatedAt(page, route);
  await expectNoFatalRouteError(page);
  await expect(page).toHaveURL(new RegExp(`/#${route.replace('/', '\\/')}`));
  await expect(page.locator('body')).toBeVisible();
}

test.describe('@high Cashier High Priority Flows', () => {
  const customerRoutes = [
    '/customers',
    '/customers/accounts',
    '/customers/transaction',
    '/customers/apply-interest',
    '/invoices/create',
  ];

  for (const route of customerRoutes) {
    test(`HIGH-CUST: route ${route} loads`, async ({ page }) => {
      await assertProtectedRouteLoads(page, route);
    });
  }

  const reportRoutes = [
    '/reports',
    '/reports/daily-sales',
    '/reports/top-products',
    '/reports/cash-flow',
    '/reports/payments',
    '/reports/custom',
  ];

  for (const route of reportRoutes) {
    test(`HIGH-REPORT: route ${route} loads`, async ({ page }) => {
      await assertProtectedRouteLoads(page, route);
    });
  }

  const settingsRoutes = [
    '/settings',
    '/settings/store',
    '/settings/tax',
    '/settings/receipt',
    '/settings/payment-devices',
    '/settings/printer',
    '/settings/keyboard-shortcuts',
    '/settings/users',
    '/settings/backup',
    '/settings/language',
    '/settings/theme',
  ];

  for (const route of settingsRoutes) {
    test(`HIGH-SETTINGS: route ${route} loads`, async ({ page }) => {
      await assertProtectedRouteLoads(page, route);
    });
  }

  test('HIGH-I18N-001: POS renders Arabic/English currency markers correctly', async ({
    page,
  }) => {
    await ensureAuthenticatedAt(page, '/pos');
    await expect(page.locator('body')).toContainText(/SAR|ر\.?س|ريال/i);
  });

  test('HIGH-RWD-001: mobile layout at 375px loads POS without route errors', async ({
    page,
  }) => {
    await page.setViewportSize({ width: 375, height: 812 });
    await assertProtectedRouteLoads(page, '/pos');
  });

  test('HIGH-RWD-002: tablet layout at 768px loads POS without route errors', async ({
    page,
  }) => {
    await page.setViewportSize({ width: 768, height: 1024 });
    await assertProtectedRouteLoads(page, '/pos');
  });

  test('HIGH-RWD-003: desktop layout at 1280px loads POS without route errors', async ({
    page,
  }) => {
    await page.setViewportSize({ width: 1280, height: 900 });
    await assertProtectedRouteLoads(page, '/pos');
  });
});
