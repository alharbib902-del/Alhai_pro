import { expect, test } from '@playwright/test';
import {
  TEST_LOGIN,
  clickByTexts,
  ensureAuthenticatedAt,
  expectBodyContainsAny,
  expectNoFatalRouteError,
  fillOtpAndVerify,
  fillPhoneAndContinue,
  goToLogin,
  loginToPos,
  textPatterns,
  visibleInputs,
} from '../helpers/cashier';

const TEXT = textPatterns();

test.describe('@critical Cashier Critical Flows', () => {
  test('CRIT-LOGIN-001: rejects short phone number', async ({ page }) => {
    await goToLogin(page);
    await fillPhoneAndContinue(page, '050');

    await expect(page).toHaveURL(/\/#\/login/);
    await expect(page.locator('body')).not.toContainText(TEXT.otpTitle[0]);
  });

  test('CRIT-LOGIN-002: rejects non-Saudi phone format', async ({ page }) => {
    await goToLogin(page);
    await fillPhoneAndContinue(page, '0100000001');

    await expect(page).toHaveURL(/\/#\/login/);
    await expect(page.locator('body')).not.toContainText(TEXT.otpTitle[0]);
  });

  test('CRIT-LOGIN-003: valid phone + OTP reaches store-select/POS', async ({
    page,
  }) => {
    await loginToPos(page);
    await expect(page).toHaveURL(/\/#\/(store-select|pos)/);
  });

  test('CRIT-LOGIN-004: OTP locks after 3 failed attempts', async ({
    page,
  }) => {
    await goToLogin(page);
    await fillPhoneAndContinue(page, TEST_LOGIN.phone);
    await expectBodyContainsAny(page, TEXT.otpTitle);

    for (let i = 0; i < 3; i++) {
      await fillOtpAndVerify(page, '000000');
      await page.waitForTimeout(350);
    }

    await expectBodyContainsAny(page, TEXT.maxAttempts);
  });

  test('CRIT-LOGIN-005: "change number" returns to phone step', async ({
    page,
  }) => {
    await goToLogin(page);
    await fillPhoneAndContinue(page, TEST_LOGIN.phone);
    await expectBodyContainsAny(page, TEXT.otpTitle);

    const changed = await clickByTexts(page, TEXT.changeNumber, 4000);
    expect(changed).toBeTruthy();
    const inputs = await visibleInputs(page);
    await expect(inputs.first()).toBeVisible();
    await expect(page.locator('body')).not.toContainText(TEXT.maxAttempts[0]);
  });

  test('CRIT-POS-001: POS loads and accepts quick add from keyboard', async ({
    page,
  }) => {
    await ensureAuthenticatedAt(page, '/pos');
    await expectNoFatalRouteError(page);

    await page.locator('body').click();
    await page.keyboard.press('Digit1');
    await page.waitForTimeout(700);

    await expect(page.locator('body')).toContainText(/cart|السلة|shopping cart/i);
  });

  test('CRIT-PAY-001: cash payment screen shows change section', async ({
    page,
  }) => {
    await ensureAuthenticatedAt(page, '/pos/payment');
    await expectNoFatalRouteError(page);

    const firstInput = page.locator('input:visible').first();
    await expect(firstInput).toBeVisible({ timeout: 10_000 });
    await firstInput.fill('500');

    await expect(page.locator('body')).toContainText(/change|الباقي/i);
  });

  test('CRIT-PAY-002: card payment requires reference before confirm', async ({
    page,
  }) => {
    await ensureAuthenticatedAt(page, '/pos/payment');

    await page.getByText(/card|بطاقة/i).first().click();

    const confirmBtn = page
      .getByRole('button', { name: /confirm payment|تأكيد الدفع/i })
      .first();
    await expect(confirmBtn).toBeVisible();
    await expect(confirmBtn).toBeDisabled();

    const rrnInput = page.locator('input:visible').first();
    await rrnInput.fill('RRN-123456');
    await expect(confirmBtn).toBeEnabled();
  });

  test('CRIT-SHIFT-001: shift open screen loads opening balance controls', async ({
    page,
  }) => {
    await ensureAuthenticatedAt(page, '/shifts/open');
    await expectNoFatalRouteError(page);
    await expect(page.locator('body')).toContainText(/open shift|فتح الوردية/i);
    await expect(page.locator('input:visible').first()).toBeVisible();
  });

  test('CRIT-SHIFT-002: shift close screen loads', async ({ page }) => {
    await ensureAuthenticatedAt(page, '/shifts/close');
    await expectNoFatalRouteError(page);

    const body = page.locator('body');
    await expect(body).toContainText(/close shift|إغلاق الوردية|no open shift/i);
  });

  test('CRIT-RET-001: refund request screen loads search controls', async ({
    page,
  }) => {
    await ensureAuthenticatedAt(page, '/returns/request');
    await expectNoFatalRouteError(page);

    await expect(page.locator('input:visible').first()).toBeVisible();
    await expect(page.locator('body')).toContainText(/search|بحث/i);
  });

  test('CRIT-OFFLINE-001: sync status page opens', async ({ page }) => {
    await ensureAuthenticatedAt(page, '/sync');
    await expectNoFatalRouteError(page);
    await expect(page).toHaveURL(/\/#\/sync/);
  });
});
