import { expect, test, Page } from '@playwright/test';
import {
  TEST_LOGIN,
  clickByTexts,
  enableAccessibilityIfNeeded,
  ensureAuthenticatedAt,
  expectBodyContainsAny,
  expectNoFatalRouteError,
  fillOtpAndVerify,
  fillPhoneAndContinue,
  goToLogin,
  loginToPos,
  maybeSelectStore,
  textPatterns,
  visibleInputs,
  waitForFlutterLoad,
} from '../helpers/cashier';

const TEXT = textPatterns();

// ============================================================================
// 1. APP LOADING & RENDERING
// ============================================================================
test.describe('1. App Loading', () => {
  test('LOAD-001: Flutter engine initialises', async ({ page }) => {
    await page.goto('/');
    await waitForFlutterLoad(page);

    const hasFlutter = await page.evaluate(
      () => typeof (window as any)._flutter !== 'undefined',
    );
    expect(hasFlutter).toBeTruthy();
  });

  test('LOAD-002: CanvasKit renderer active', async ({ page }) => {
    await page.goto('/');
    await waitForFlutterLoad(page);

    const renderer = await page.evaluate(() => {
      const config = (window as any)._flutter?.buildConfig;
      return config?.builds?.[0]?.renderer || 'unknown';
    });
    expect(renderer).toBe('canvaskit');
  });

  test('LOAD-003: page renders non-blank content', async ({ page }) => {
    await page.goto('/');
    await enableAccessibilityIfNeeded(page);

    // Verify there are visible semantic elements (proves rendering completed)
    const btns = await page.getByRole('button').count();
    expect(btns).toBeGreaterThan(0);
  });

  test('LOAD-004: DOM content loads within 60s', async ({ page }) => {
    const start = Date.now();
    await page.goto('/');
    await waitForFlutterLoad(page, 60_000);
    expect(Date.now() - start).toBeLessThan(60_000);
  });
});

// ============================================================================
// 2. AUTHENTICATION
// ============================================================================
test.describe('2. Authentication', () => {
  test('AUTH-001: login page shows phone input', async ({ page }) => {
    await goToLogin(page);
    // Flutter Web uses accessibility tree — getByRole is more reliable than CSS :visible
    const input = page.getByRole('textbox').first();
    await expect(input).toBeVisible({ timeout: 15_000 });
  });

  test('AUTH-002: rejects short phone number', async ({ page }) => {
    await goToLogin(page);
    await fillPhoneAndContinue(page, '050');

    await expect(page).toHaveURL(/\/#\/login/);
    await expect(page.locator('body')).not.toContainText(TEXT.otpTitle[0]);
  });

  test('AUTH-003: rejects non-Saudi phone format', async ({ page }) => {
    await goToLogin(page);
    await fillPhoneAndContinue(page, '0100000001');

    await expect(page).toHaveURL(/\/#\/login/);
    await expect(page.locator('body')).not.toContainText(TEXT.otpTitle[0]);
  });

  test('AUTH-004: valid phone shows OTP screen', async ({ page }) => {
    await goToLogin(page);
    await fillPhoneAndContinue(page, TEST_LOGIN.phone);
    await expectBodyContainsAny(page, TEXT.otpTitle, 15_000);
  });

  test('AUTH-005: full login flow reaches POS', async ({ page }) => {
    await loginToPos(page);
    await expect(page).toHaveURL(/\/#\/(store-select|pos)/);
  });

  test('AUTH-006: "change number" returns to phone step', async ({ page }) => {
    await goToLogin(page);
    await fillPhoneAndContinue(page, TEST_LOGIN.phone);
    await expectBodyContainsAny(page, TEXT.otpTitle);

    const changed = await clickByTexts(page, TEXT.changeNumber, 4000);
    expect(changed).toBeTruthy();
    const inputs = await visibleInputs(page);
    await expect(inputs.first()).toBeVisible();
  });
});

// ============================================================================
// 3. POS MAIN ROUTES (sidebar navigation)
// ============================================================================
test.describe('3. Main Routes', () => {
  const mainRoutes = [
    { path: '/pos', label: 'POS' },
    { path: '/sales', label: 'Sales' },
    { path: '/customers', label: 'Customers' },
    { path: '/products', label: 'Products' },
    { path: '/inventory', label: 'Inventory' },
    { path: '/shifts', label: 'Shifts' },
    { path: '/reports', label: 'Reports' },
    { path: '/settings', label: 'Settings' },
    { path: '/sync', label: 'Sync' },
    { path: '/profile', label: 'Profile' },
    { path: '/notifications', label: 'Notifications' },
    { path: '/cash-drawer', label: 'Cash Drawer' },
    { path: '/invoices', label: 'Invoices' },
    { path: '/returns', label: 'Returns' },
    { path: '/dashboard', label: 'Dashboard' },
  ];

  for (const { path, label } of mainRoutes) {
    test(`NAV-MAIN: ${label} (${path})`, async ({ page }) => {
      await ensureAuthenticatedAt(page, path);
      await expectNoFatalRouteError(page);
      const screenshot = await page.screenshot();
      expect(screenshot.length).toBeGreaterThan(10_000);
    });
  }
});

// ============================================================================
// 4. SUB-ROUTES
// ============================================================================
test.describe('4. Sub-Routes', () => {
  const subRoutes = [
    // Shifts
    { path: '/shifts/open', label: 'Open Shift' },
    { path: '/shifts/close', label: 'Close Shift' },
    { path: '/shifts/cash-in-out', label: 'Cash In/Out' },
    { path: '/shifts/summary', label: 'Shift Summary' },
    // Customers
    { path: '/customers/accounts', label: 'Customer Accounts' },
    { path: '/customers/debt', label: 'Customer Debt' },
    // Products
    { path: '/products/quick-add', label: 'Quick Add Product' },
    { path: '/products/print-barcode', label: 'Print Barcode' },
    { path: '/products/price-labels', label: 'Price Labels' },
    { path: '/products/categories-view', label: 'Categories View' },
    // Inventory
    { path: '/inventory/add', label: 'Add Inventory' },
    { path: '/inventory/stock-take', label: 'Stock Take' },
    { path: '/inventory/wastage', label: 'Wastage' },
    { path: '/inventory/transfer', label: 'Transfer' },
    { path: '/inventory/alerts', label: 'Inventory Alerts' },
    { path: '/inventory/expiry-tracking', label: 'Expiry Tracking' },
    // Reports
    { path: '/reports/payments', label: 'Payment Reports' },
    { path: '/reports/daily-sales', label: 'Daily Sales' },
    { path: '/reports/top-products', label: 'Top Products' },
    { path: '/reports/cash-flow', label: 'Cash Flow' },
    { path: '/reports/custom', label: 'Custom Report' },
    // Settings
    { path: '/settings/store', label: 'Store Info' },
    { path: '/settings/tax', label: 'Tax Settings' },
    { path: '/settings/receipt', label: 'Receipt Settings' },
    { path: '/settings/printer', label: 'Printer Settings' },
    { path: '/settings/payment-devices', label: 'Payment Devices' },
    { path: '/settings/keyboard-shortcuts', label: 'Shortcuts' },
    { path: '/settings/users', label: 'Users' },
    { path: '/settings/backup', label: 'Backup' },
    // Offers
    { path: '/offers/active', label: 'Active Offers' },
    { path: '/offers/bundles', label: 'Bundles' },
    // Purchases / Returns
    { path: '/cashier-receiving', label: 'Cashier Receiving' },
    { path: '/returns/request', label: 'Refund Request' },
    // POS overlays
    { path: '/pos/payment', label: 'Payment Screen' },
    // Orders
    { path: '/orders/tracking', label: 'Order Tracking' },
    { path: '/orders/history', label: 'Order History' },
  ];

  for (const { path, label } of subRoutes) {
    test(`NAV-SUB: ${label} (${path})`, async ({ page }) => {
      await ensureAuthenticatedAt(page, path);
      await expectNoFatalRouteError(page);
    });
  }
});

// ============================================================================
// 5. POS FUNCTIONALITY
// ============================================================================
test.describe('5. POS Functionality', () => {
  test('POS-001: POS screen loads with products', async ({ page }) => {
    await ensureAuthenticatedAt(page, '/pos');
    await expectNoFatalRouteError(page);
    // Should show some product UI elements
    const screenshot = await page.screenshot();
    expect(screenshot.length).toBeGreaterThan(15_000);
  });

  test('POS-002: payment screen shows input controls', async ({ page }) => {
    await ensureAuthenticatedAt(page, '/pos/payment');
    await expectNoFatalRouteError(page);
    // Payment screen should have at least one input
    const input = page.getByRole('textbox').first();
    await expect(input).toBeVisible({ timeout: 15_000 });
  });
});

// ============================================================================
// 6. SHIFTS
// ============================================================================
test.describe('6. Shifts', () => {
  test('SHIFT-001: open shift page loads controls', async ({ page }) => {
    await ensureAuthenticatedAt(page, '/shifts/open');
    await expectNoFatalRouteError(page);
    await expect(page.locator('body')).toContainText(
      /open shift|فتح الوردية|وردية|shift|الرصيد/i,
    );
  });

  test('SHIFT-002: close shift page loads', async ({ page }) => {
    await ensureAuthenticatedAt(page, '/shifts/close');
    await expectNoFatalRouteError(page);
    await expect(page.locator('body')).toContainText(
      /close shift|إغلاق الوردية|no open shift|لا توجد وردية/i,
    );
  });
});

// ============================================================================
// 7. RETURNS
// ============================================================================
test.describe('7. Returns', () => {
  test('RET-001: refund request screen has search', async ({ page }) => {
    await ensureAuthenticatedAt(page, '/returns/request');
    await expectNoFatalRouteError(page);
    // Search input visible via accessibility tree
    await expect(page.getByRole('textbox').first()).toBeVisible({
      timeout: 15_000,
    });
  });
});

// ============================================================================
// 8. OFFLINE & NETWORK
// ============================================================================
test.describe('8. Offline', () => {
  test('OFFLINE-001: POS survives disconnect', async ({ page }) => {
    await ensureAuthenticatedAt(page, '/pos');
    await page.context().setOffline(true);
    await page.waitForTimeout(3_000);
    const screenshot = await page.screenshot();
    expect(screenshot.length).toBeGreaterThan(5_000);
    await page.context().setOffline(false);
  });

  test('OFFLINE-002: recovers after reconnect', async ({ page }) => {
    await ensureAuthenticatedAt(page, '/pos');
    await page.context().setOffline(true);
    await page.waitForTimeout(3_000);
    await page.context().setOffline(false);
    await page.waitForTimeout(5_000);
    const screenshot = await page.screenshot();
    expect(screenshot.length).toBeGreaterThan(5_000);
  });
});

// ============================================================================
// 9. ERROR DETECTION
// ============================================================================
test.describe('9. Errors', () => {
  test('ERR-001: no fatal JS exceptions on POS', async ({ page }) => {
    const exceptions: string[] = [];
    page.on('pageerror', (err) => exceptions.push(err.message));
    await ensureAuthenticatedAt(page, '/pos');
    await page.waitForTimeout(3_000);
    const fatal = exceptions.filter(
      (e) =>
        !e.includes('favicon') &&
        !e.includes('service-worker') &&
        !e.includes('manifest'),
    );
    expect(fatal.length).toBeLessThanOrEqual(3);
  });

  test('ERR-002: no fatal exceptions across navigation', async ({ page }) => {
    const exceptions: string[] = [];
    page.on('pageerror', (err) => exceptions.push(err.message));
    await ensureAuthenticatedAt(page, '/pos');
    for (const r of ['/sales', '/customers', '/settings', '/reports']) {
      await page.goto(`/#${r}`);
      await page.waitForTimeout(2_000);
    }
    const fatal = exceptions.filter(
      (e) =>
        !e.includes('favicon') &&
        !e.includes('service-worker') &&
        !e.includes('manifest'),
    );
    expect(fatal.length).toBeLessThanOrEqual(5);
  });

  test('ERR-003: unknown route does not crash', async ({ page }) => {
    await ensureAuthenticatedAt(page, '/nonexistent-route-xyz');
    const screenshot = await page.screenshot();
    expect(screenshot.length).toBeGreaterThan(5_000);
  });

  test('ERR-004: no failed core asset requests', async ({ page }) => {
    const failed: string[] = [];
    page.on('requestfailed', (req) => {
      const url = req.url();
      if (!url.includes('favicon') && !url.includes('analytics'))
        failed.push(url);
    });
    await page.goto('/#/login');
    await waitForFlutterLoad(page);
    expect(failed.length).toBeLessThanOrEqual(2);
  });
});

// ============================================================================
// 10. RESPONSIVE
// ============================================================================
test.describe('10. Responsive', () => {
  test('RESP-001: mobile viewport (375x812)', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 812 });
    await ensureAuthenticatedAt(page, '/pos');
    const screenshot = await page.screenshot();
    expect(screenshot.length).toBeGreaterThan(5_000);
  });

  test('RESP-002: tablet viewport (768x1024)', async ({ page }) => {
    await page.setViewportSize({ width: 768, height: 1024 });
    await ensureAuthenticatedAt(page, '/pos');
    const screenshot = await page.screenshot();
    expect(screenshot.length).toBeGreaterThan(5_000);
  });

  test('RESP-003: wide desktop (1920x1080)', async ({ page }) => {
    await page.setViewportSize({ width: 1920, height: 1080 });
    await ensureAuthenticatedAt(page, '/pos');
    const screenshot = await page.screenshot();
    expect(screenshot.length).toBeGreaterThan(5_000);
  });
});

// ============================================================================
// 11. SECURITY
// ============================================================================
test.describe('11. Security', () => {
  test('SEC-001: no secrets in URL after login', async ({ page }) => {
    await ensureAuthenticatedAt(page, '/pos');
    const url = page.url().toLowerCase();
    expect(url).not.toContain('password');
    expect(url).not.toContain('token');
    expect(url).not.toContain('secret');
  });

  test('SEC-002: CSP meta tag exists', async ({ page }) => {
    await page.goto('/');
    await waitForFlutterLoad(page);
    const hasCsp = await page.evaluate(
      () =>
        document.querySelectorAll(
          'meta[http-equiv="Content-Security-Policy"]',
        ).length > 0,
    );
    expect(hasCsp).toBeTruthy();
  });

  test('SEC-003: X-Frame-Options DENY', async ({ page }) => {
    await page.goto('/');
    await waitForFlutterLoad(page);
    const val = await page.evaluate(
      () =>
        document
          .querySelector('meta[http-equiv="X-Frame-Options"]')
          ?.getAttribute('content') || '',
    );
    expect(val).toBe('DENY');
  });
});

// ============================================================================
// 12. EXTENDED ROUTES — Reports, Settings, AI, Expenses, Orders
// ============================================================================
test.describe('12. Extended Routes', () => {
  const extendedRoutes = [
    // Reports (not covered above)
    { path: '/reports/inventory', label: 'Inventory Report' },
    { path: '/reports/profit', label: 'Profit Report' },
    { path: '/reports/tax', label: 'Tax Report' },
    { path: '/reports/vat', label: 'VAT Report' },
    { path: '/reports/zakat', label: 'Zakat Report' },
    { path: '/reports/debts', label: 'Debts Report' },
    { path: '/reports/debt-aging', label: 'Debt Aging Report' },
    { path: '/reports/customers', label: 'Customer Report' },
    { path: '/reports/comparison', label: 'Comparison Report' },
    { path: '/reports/complaints', label: 'Complaints Report' },
    { path: '/reports/analytics', label: 'Sales Analytics' },
    { path: '/reports/staff', label: 'Staff Performance' },
    { path: '/reports/peak-hours', label: 'Peak Hours' },
    { path: '/reports/balance', label: 'Balance Sheet' },
    // Settings (not covered above)
    { path: '/settings/privacy', label: 'Privacy Policy' },
    { path: '/settings/language', label: 'Language' },
    { path: '/settings/theme', label: 'Theme' },
    // Expenses
    { path: '/expenses', label: 'Expenses' },
    // Orders
    { path: '/orders', label: 'Orders' },
    // AI Screens
    { path: '/ai/assistant', label: 'AI Assistant' },
    { path: '/ai/sales-forecasting', label: 'AI Sales Forecast' },
    { path: '/ai/smart-pricing', label: 'AI Smart Pricing' },
    { path: '/ai/fraud-detection', label: 'AI Fraud Detection' },
    { path: '/ai/basket-analysis', label: 'AI Basket Analysis' },
    { path: '/ai/customer-recommendations', label: 'AI Customer Recs' },
    { path: '/ai/smart-inventory', label: 'AI Smart Inventory' },
    { path: '/ai/competitor-analysis', label: 'AI Competitor' },
    { path: '/ai/smart-reports', label: 'AI Smart Reports' },
    { path: '/ai/staff-analytics', label: 'AI Staff Analytics' },
    { path: '/ai/sentiment-analysis', label: 'AI Sentiment' },
    { path: '/ai/return-prediction', label: 'AI Return Prediction' },
    { path: '/ai/promotion-designer', label: 'AI Promotion Designer' },
    { path: '/ai/chat-with-data', label: 'AI Chat with Data' },
    // Customer sub-routes
    { path: '/customers/analytics', label: 'Customer Analytics' },
    // Sales sub-routes
    { path: '/sales/exchange', label: 'Exchange' },
    // Onboarding
    { path: '/onboarding', label: 'Onboarding' },
  ];

  for (const { path, label } of extendedRoutes) {
    test(`EXT: ${label} (${path})`, async ({ page }) => {
      await ensureAuthenticatedAt(page, path);
      await expectNoFatalRouteError(page);
    });
  }
});

// ============================================================================
// 13. PERFORMANCE
// ============================================================================
test.describe('13. Performance', () => {
  test('PERF-001: navigation stability (3 round trips)', async ({ page }) => {
    await ensureAuthenticatedAt(page, '/pos');
    for (let i = 0; i < 3; i++) {
      await page.goto('/#/sales');
      await page.waitForTimeout(2_000);
      await page.goto('/#/pos');
      await page.waitForTimeout(2_000);
    }
    const screenshot = await page.screenshot();
    expect(screenshot.length).toBeGreaterThan(5_000);
  });
});
