import { expect, test, Page } from '@playwright/test';
import {
  ensureAuthenticatedAt,
  expectNoFatalRouteError,
} from '../helpers/cashier';

async function assertProtectedRouteLoads(page: Page, route: string): Promise<void> {
  await ensureAuthenticatedAt(page, route);
  await expectNoFatalRouteError(page);
  await expect(page).toHaveURL(new RegExp(`/#${route.replace('/', '\\/')}`));
}

test.describe('@medium Cashier Medium Priority Flows', () => {
  const offersRoutes = ['/offers/active', '/offers/coupon', '/offers/bundles'];
  const inventoryRoutes = [
    '/inventory',
    '/inventory/add',
    '/inventory/remove',
    '/inventory/transfer',
    '/inventory/stock-take',
    '/inventory/wastage',
  ];
  const productRoutes = [
    '/products/quick-add',
    '/products/print-barcode',
    '/products/categories-view',
    '/products/price-labels',
  ];
  const purchasesRoutes = ['/purchase-request', '/cashier-receiving'];
  const dashboardRoutes = ['/home', '/sales'];

  for (const route of offersRoutes) {
    test(`MEDIUM-OFFERS: route ${route} loads`, async ({ page }) => {
      await assertProtectedRouteLoads(page, route);
    });
  }

  for (const route of inventoryRoutes) {
    test(`MEDIUM-INVENTORY: route ${route} loads`, async ({ page }) => {
      await assertProtectedRouteLoads(page, route);
    });
  }

  for (const route of productRoutes) {
    test(`MEDIUM-PRODUCTS: route ${route} loads`, async ({ page }) => {
      await assertProtectedRouteLoads(page, route);
    });
  }

  for (const route of purchasesRoutes) {
    test(`MEDIUM-PURCHASES: route ${route} loads`, async ({ page }) => {
      await assertProtectedRouteLoads(page, route);
    });
  }

  for (const route of dashboardRoutes) {
    test(`MEDIUM-DASHBOARD: route ${route} loads`, async ({ page }) => {
      await assertProtectedRouteLoads(page, route);
    });
  }

  test('MEDIUM-RTL-LTR-001: language settings screen is reachable', async ({
    page,
  }) => {
    await assertProtectedRouteLoads(page, '/settings/language');
    await expect(page.locator('body')).toContainText(/language|اللغة/i);
  });
});

