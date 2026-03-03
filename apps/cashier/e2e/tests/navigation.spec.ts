import { test, expect } from '@playwright/test';
import { login } from '../helpers/auth';

test.describe('Navigation', () => {
  test.beforeEach(async ({ page }) => {
    // Login first
    await login(page);
    await page.waitForTimeout(2_000);
  });

  test('navigate to Sales page', async ({ page }) => {
    await page.goto('/#/sales');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(2_000);

    expect(page.url()).toContain('/sales');
    await expect(page.locator('body')).toBeVisible();
  });

  test('navigate to Customers page', async ({ page }) => {
    await page.goto('/#/customers');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(2_000);

    expect(page.url()).toContain('/customers');
    await expect(page.locator('body')).toBeVisible();
  });

  test('navigate to Inventory page', async ({ page }) => {
    await page.goto('/#/inventory');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(2_000);

    expect(page.url()).toContain('/inventory');
    await expect(page.locator('body')).toBeVisible();
  });

  test('navigate to Settings page', async ({ page }) => {
    await page.goto('/#/settings');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(2_000);

    expect(page.url()).toContain('/settings');
    await expect(page.locator('body')).toBeVisible();
  });

  test('navigate to Reports page', async ({ page }) => {
    await page.goto('/#/reports');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(2_000);

    expect(page.url()).toContain('/reports');
    await expect(page.locator('body')).toBeVisible();
  });

  test('navigate to Shifts page', async ({ page }) => {
    await page.goto('/#/shifts');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(2_000);

    expect(page.url()).toContain('/shifts');
    await expect(page.locator('body')).toBeVisible();
  });
});
