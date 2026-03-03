import { Page, expect } from '@playwright/test';

/**
 * Skip onboarding if it appears
 */
export async function skipOnboarding(page: Page) {
  try {
    const skipBtn = page.getByText('تخطي');
    if (await skipBtn.isVisible({ timeout: 5_000 }).catch(() => false)) {
      await skipBtn.click();
      await page.waitForTimeout(1_000);
    }
  } catch {
    // Onboarding not shown
  }
}

/**
 * Login helper - performs full login flow
 * Phone: 0500000001 | OTP: 123456
 */
export async function login(page: Page) {
  // 1. Go to app (may show onboarding first)
  await page.goto('/');
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(3_000);

  // 2. Skip onboarding if shown
  await skipOnboarding(page);

  // 3. Navigate to login if not already there
  if (!page.url().includes('/login')) {
    await page.goto('/#/login');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(2_000);
    await skipOnboarding(page);
  }

  // Wait for login form to be visible
  await expect(page.getByText('تسجيل الدخول')).toBeVisible({ timeout: 15_000 });

  // 2. Enter phone number
  const phoneInput = page.locator('input[type="text"]').first();
  await phoneInput.click();
  await phoneInput.fill('0500000001');

  // 3. Click "التالي" (Next) button
  await page.getByText('التالي').click();

  // 4. Wait for OTP step
  await expect(page.getByText('رمز التحقق').or(page.getByText('أدخل رمز التحقق'))).toBeVisible({
    timeout: 15_000,
  });

  // 5. Enter OTP digits (6 separate input fields)
  const otpInputs = page.locator('input');
  const otpDigits = '123456';

  // Try filling OTP - Flutter may render as individual inputs or single input
  const inputCount = await otpInputs.count();
  if (inputCount >= 6) {
    // Individual digit fields
    for (let i = 0; i < 6; i++) {
      await otpInputs.nth(i).fill(otpDigits[i]);
    }
  } else {
    // Single OTP input
    await otpInputs.first().fill(otpDigits);
  }

  // 6. Click verify button
  const verifyBtn = page.getByText('تحقق').or(page.getByText('تأكيد'));
  if (await verifyBtn.isVisible()) {
    await verifyBtn.click();
  }

  // 7. Handle store selection if it appears
  try {
    const storeItem = page.getByText('سوبرماركت الحي');
    await storeItem.waitFor({ timeout: 10_000 });
    await storeItem.click();

    // Wait for sync and redirect
    await page.waitForURL(/\/#\/pos/, { timeout: 30_000 });
  } catch {
    // Already redirected to POS or store auto-selected
    await page.waitForURL(/\/#\/pos/, { timeout: 30_000 });
  }
}

/**
 * Ensure we're on the POS page (login if needed)
 */
export async function ensureOnPOS(page: Page) {
  await page.goto('/#/pos');
  await page.waitForLoadState('networkidle');

  // If redirected to login, perform login
  if (page.url().includes('/login')) {
    await login(page);
  }

  await expect(page.locator('body')).toBeVisible();
}
