import { expect, Locator, Page } from '@playwright/test';

export interface CashierLoginData {
  phone: string;
  otp: string;
  countryCode: string;
  preferredStoreName: string;
}

export const TEST_LOGIN: CashierLoginData = {
  phone: '0500000001',
  otp: '123456',
  countryCode: '+966',
  preferredStoreName: 'سوبرماركت الحي',
};

const TEXT = {
  onboardingSkip: [/تخطي/i, /skip/i],
  loginTitle: [/تسجيل الدخول/i, /login/i],
  next: [/التالي/i, /next/i, /continue/i],
  otpTitle: [/رمز التحقق/i, /otp/i, /verification code/i],
  verify: [/تحقق/i, /تأكيد/i, /verify/i, /confirm/i],
  changeNumber: [/تغيير الرقم/i, /change number/i],
  maxAttempts: [/الحد الأقصى/i, /max attempts/i, /too many attempts/i],
  phoneValidation: [/رقم جوال صحيح/i, /valid phone/i, /05/i],
  store: [/سوبرماركت/i, /store/i, /branch/i, /فرع/i],
  noShift: [/لا توجد وردية مفتوحة/i, /no open shift/i],
};

async function isVisible(locator: Locator, timeoutMs = 1200): Promise<boolean> {
  return locator.first().isVisible({ timeout: timeoutMs }).catch(() => false);
}

export async function enableAccessibilityIfNeeded(page: Page): Promise<void> {
  const button = page
    .getByRole('button', { name: /enable accessibility/i })
    .first();

  const appeared = await expect
    .poll(
      async () => {
        const hasTextbox = (await page.getByRole('textbox').count()) > 0;
        const hasToggle = await isVisible(button, 120).catch(() => false);
        return hasTextbox || hasToggle;
      },
      { timeout: 20_000 },
    )
    .toBeTruthy()
    .then(() => true)
    .catch(() => false);

  if (!appeared) {
    return;
  }

  if ((await page.getByRole('textbox').count()) > 0) {
    return;
  }

  // In Flutter web, this toggle can be rendered outside viewport.
  // Repeated keyboard activation is the most reliable way in CI.
  for (let i = 0; i < 12; i++) {
    if ((await page.getByRole('textbox').count()) > 0) {
      return;
    }

    try {
      await page.keyboard.press('Tab');
      await page.keyboard.press('Enter');
    } catch {
      // continue trying
    }
    await page.waitForTimeout(350);
  }
}

export async function clickByTexts(
  page: Page,
  patterns: RegExp[],
  timeoutMs = 3000,
): Promise<boolean> {
  const deadline = Date.now() + timeoutMs;
  while (Date.now() < deadline) {
    for (const pattern of patterns) {
      const candidate = page.getByText(pattern).first();
      if (await isVisible(candidate, 250)) {
        await candidate.click();
        return true;
      }
    }
    await page.waitForTimeout(150);
  }
  return false;
}

export async function expectBodyContainsAny(
  page: Page,
  patterns: RegExp[],
  timeoutMs = 10_000,
): Promise<void> {
  const deadline = Date.now() + timeoutMs;
  while (Date.now() < deadline) {
    for (const pattern of patterns) {
      const found = await isVisible(page.getByText(pattern).first(), 250);
      if (found) {
        return;
      }
    }
    await page.waitForTimeout(150);
  }
  throw new Error(`None of the expected texts were found: ${patterns.join(', ')}`);
}

export async function visibleInputs(page: Page): Promise<Locator> {
  return page.locator(
    'input:visible, textarea:visible, [role="textbox"]:visible, [contenteditable="true"]:visible',
  );
}

export async function firstVisibleInput(page: Page): Promise<Locator> {
  const inputs = await visibleInputs(page);
  await expect(inputs.first()).toBeVisible({ timeout: 15_000 });
  return inputs.first();
}

async function setFieldValue(
  page: Page,
  locator: Locator,
  value: string,
): Promise<void> {
  await locator.click();
  try {
    await locator.fill(value);
    return;
  } catch {
    // Flutter semantics textboxes are not always native <input>
  }

  await page.keyboard.press('Control+A').catch(() => {});
  await page.keyboard.press('Meta+A').catch(() => {});
  await page.keyboard.press('Backspace').catch(() => {});
  await page.keyboard.type(value, { delay: 20 });
}

export async function goToLogin(page: Page): Promise<void> {
  await page.goto('/#/login');
  await page.waitForLoadState('domcontentloaded');
  await enableAccessibilityIfNeeded(page);
  await clickByTexts(page, TEXT.onboardingSkip, 1500);

  if (!page.url().includes('/login')) {
    await page.goto('/#/login');
    await page.waitForLoadState('domcontentloaded');
    await enableAccessibilityIfNeeded(page);
    await clickByTexts(page, TEXT.onboardingSkip, 1500);
  }

  await expect(page.locator('body')).toBeVisible({ timeout: 15_000 });
}

export async function fillPhoneAndContinue(
  page: Page,
  phone = TEST_LOGIN.phone,
): Promise<void> {
  const phoneInput = await firstVisibleInput(page);
  await setFieldValue(page, phoneInput, phone);

  const nextClicked = await clickByTexts(page, TEXT.next, 5000);
  if (!nextClicked) {
    await page.keyboard.press('Enter');
  }
}

export async function fillOtpAndVerify(
  page: Page,
  otp = TEST_LOGIN.otp,
): Promise<void> {
  const inputs = await visibleInputs(page);
  const count = await inputs.count();

  if (count >= 6) {
    for (let i = 0; i < 6; i++) {
      await setFieldValue(page, inputs.nth(i), otp[i] ?? '');
    }
  } else {
    await setFieldValue(page, inputs.first(), otp);
  }

  await clickByTexts(page, TEXT.verify, 3000);
}

export async function maybeSelectStore(page: Page): Promise<void> {
  const onStoreSelect = page.url().includes('/store-select');
  if (!onStoreSelect) {
    return;
  }

  const preferred = page.getByText(TEST_LOGIN.preferredStoreName).first();
  if (await isVisible(preferred, 4000)) {
    await preferred.click();
    return;
  }

  if (await clickByTexts(page, TEXT.store, 4000)) {
    return;
  }

  const firstSelectable = page.locator('[role="button"]:visible').first();
  if (await isVisible(firstSelectable, 2000)) {
    await firstSelectable.click();
  }
}

export async function loginToPos(page: Page): Promise<void> {
  await goToLogin(page);
  await fillPhoneAndContinue(page);

  await expectBodyContainsAny(page, TEXT.otpTitle, 15_000);

  await fillOtpAndVerify(page);
  await page.waitForTimeout(1000);
  await maybeSelectStore(page);

  await expect
    .poll(() => page.url(), { timeout: 30_000 })
    .toMatch(/\/#\/(store-select|pos)/);

  if (page.url().includes('/store-select')) {
    await maybeSelectStore(page);
    await expect
      .poll(() => page.url(), { timeout: 30_000 })
      .toContain('/#/pos');
  }
}

export async function ensureAuthenticatedAt(
  page: Page,
  hashRoute: string,
): Promise<void> {
  await page.goto(`/#${hashRoute}`);
  await page.waitForLoadState('domcontentloaded');
  await enableAccessibilityIfNeeded(page);

  if (page.url().includes('/login') || page.url().includes('/onboarding')) {
    await loginToPos(page);
  }

  await page.goto(`/#${hashRoute}`);
  await page.waitForLoadState('domcontentloaded');
  await expect(page.locator('body')).toBeVisible({ timeout: 15_000 });
}

export async function expectNoFatalRouteError(page: Page): Promise<void> {
  await expect(page.getByText(/الصفحة غير موجودة/i)).toHaveCount(0);
  await expect(page.getByText(/page not found/i)).toHaveCount(0);
}

export function textPatterns() {
  return TEXT;
}
