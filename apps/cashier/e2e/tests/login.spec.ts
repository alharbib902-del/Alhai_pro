import { test, expect } from '@playwright/test';
import { skipOnboarding } from '../helpers/auth';

test.describe('Login Flow', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(3_000);
    await skipOnboarding(page);

    // Navigate to login
    if (!page.url().includes('/login')) {
      await page.goto('/#/login');
      await page.waitForLoadState('networkidle');
      await page.waitForTimeout(2_000);
      await skipOnboarding(page);
    }
  });

  test('login page loads correctly', async ({ page }) => {
    // Login title should be visible
    await expect(page.getByText('تسجيل الدخول')).toBeVisible({ timeout: 15_000 });

    // Phone input should be visible
    const phoneInput = page.locator('input[type="text"]').first();
    await expect(phoneInput).toBeVisible();

    // Next button should be visible
    await expect(page.getByText('التالي')).toBeVisible();

    // Country code +966 should be displayed
    await expect(page.getByText('966')).toBeVisible();
  });

  test('phone validation - too short number', async ({ page }) => {
    await expect(page.getByText('تسجيل الدخول')).toBeVisible({ timeout: 15_000 });

    // Enter short number
    const phoneInput = page.locator('input[type="text"]').first();
    await phoneInput.fill('050');

    // Click next
    await page.getByText('التالي').click();

    // Should show validation error
    await expect(
      page.getByText('رقم جوال صحيح').or(page.getByText('يرجى إدخال'))
    ).toBeVisible({ timeout: 5_000 });
  });

  test('phone validation - invalid Saudi format', async ({ page }) => {
    await expect(page.getByText('تسجيل الدخول')).toBeVisible({ timeout: 15_000 });

    // Enter number not starting with 05
    const phoneInput = page.locator('input[type="text"]').first();
    await phoneInput.fill('0100000001');

    // Click next
    await page.getByText('التالي').click();

    // Should show format error
    await expect(
      page.getByText('05').or(page.getByText('رقم جوال صحيح'))
    ).toBeVisible({ timeout: 5_000 });
  });

  test('successful login flow - phone to OTP to POS', async ({ page }) => {
    await expect(page.getByText('تسجيل الدخول')).toBeVisible({ timeout: 15_000 });

    // Enter valid phone
    const phoneInput = page.locator('input[type="text"]').first();
    await phoneInput.click();
    await phoneInput.fill('0500000001');

    // Click next
    await page.getByText('التالي').click();

    // Wait for OTP screen
    await expect(
      page.getByText('رمز التحقق').or(page.getByText('أدخل رمز'))
    ).toBeVisible({ timeout: 15_000 });

    // Enter OTP 123456
    const otpInputs = page.locator('input');
    const inputCount = await otpInputs.count();

    if (inputCount >= 6) {
      const digits = '123456';
      for (let i = 0; i < 6; i++) {
        await otpInputs.nth(i).fill(digits[i]);
      }
    } else {
      await otpInputs.first().fill('123456');
    }

    // Click verify if visible
    const verifyBtn = page.getByText('تحقق').or(page.getByText('تأكيد'));
    if (await verifyBtn.isVisible({ timeout: 3_000 }).catch(() => false)) {
      await verifyBtn.click();
    }

    // Should navigate to store-select or POS
    await expect(
      page.getByText('سوبرماركت الحي').or(page.locator('body'))
    ).toBeVisible({ timeout: 20_000 });

    // If store selection appears, click the store
    try {
      const store = page.getByText('سوبرماركت الحي');
      if (await store.isVisible({ timeout: 5_000 }).catch(() => false)) {
        await store.click();
      }
    } catch {
      // Already redirected
    }

    // Should end up on POS
    await page.waitForURL(/\/#\/pos/, { timeout: 30_000 });
    expect(page.url()).toContain('/pos');
  });
});
