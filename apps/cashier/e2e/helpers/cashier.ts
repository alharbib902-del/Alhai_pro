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

/**
 * Wait for Flutter CanvasKit to finish loading.
 * In headless Chromium with SwiftShader, Flutter can take 30-45s to initialise.
 */
export async function waitForFlutterLoad(page: Page, timeoutMs = 60_000): Promise<void> {
  await expect
    .poll(
      () => page.evaluate(() => !!document.querySelector('flutter-view')),
      { timeout: timeoutMs, message: 'Flutter never loaded (no flutter-view)' },
    )
    .toBeTruthy();
  // Give CanvasKit a moment to finish rendering after the element appears
  await page.waitForTimeout(3000);
}

/**
 * Enable Flutter's accessibility/semantics tree via Tab+Enter.
 * Waits until the tree has >1 button (the Flutter default is 1 for the
 * accessibility enable button itself).
 */
export async function enableAccessibilityIfNeeded(page: Page): Promise<void> {
  await waitForFlutterLoad(page);

  for (let i = 0; i < 20; i++) {
    const btns = await page.getByRole('button').count().catch(() => 0);
    if (btns > 1) {
      // Tree is populated — wait for it to stabilise
      await page.waitForTimeout(1500);
      return;
    }

    await page.keyboard.press('Tab').catch(() => {});
    await page.waitForTimeout(300);
    await page.keyboard.press('Enter').catch(() => {});
    await page.waitForTimeout(700);
  }

  // Even if we didn't detect many buttons, give it time
  await page.waitForTimeout(2000);
}

/**
 * Click an element matching one of the text patterns.
 * Uses force:true to bypass Flutter semantics overlay interception.
 */
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
        await candidate.click({ force: true }).catch(() => {});
        return true;
      }
    }
    await page.waitForTimeout(150);
  }
  return false;
}

/**
 * Click an element matching one of the ARIA role + text patterns.
 * More precise than clickByTexts — targets specific interactive elements.
 */
async function clickByRole(
  page: Page,
  role: 'button' | 'link' | 'textbox',
  patterns: RegExp[],
  timeoutMs = 3000,
): Promise<boolean> {
  const deadline = Date.now() + timeoutMs;
  while (Date.now() < deadline) {
    for (const pattern of patterns) {
      const candidate = page.getByRole(role, { name: pattern }).first();
      if (await isVisible(candidate, 250)) {
        await candidate.click({ force: true }).catch(() => {});
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
      if (found) return;
    }
    await page.waitForTimeout(150);
  }
  throw new Error(`None of the expected texts were found: ${patterns.join(', ')}`);
}

export async function visibleInputs(page: Page): Promise<Locator> {
  const roleTextbox = page.getByRole('textbox');
  if ((await roleTextbox.count()) > 0) return roleTextbox;
  return page.locator('input:visible, textarea:visible, [role="textbox"]');
}

export async function firstVisibleInput(page: Page): Promise<Locator> {
  const roleTextbox = page.getByRole('textbox').first();
  const hasRole = await expect(roleTextbox)
    .toBeVisible({ timeout: 15_000 })
    .then(() => true)
    .catch(() => false);
  if (hasRole) return roleTextbox;

  const cssInput = page.locator('input:visible, textarea:visible').first();
  await expect(cssInput).toBeVisible({ timeout: 5_000 });
  return cssInput;
}

/**
 * Focus a Flutter text field and type a value using keyboard-only interaction.
 *
 * Strategy:
 * 1. Force-click the semantics element to trigger Flutter's focus handler
 * 2. Wait for Flutter to create the native <input> in flt-text-editing-host
 * 3. Clear existing content and type the new value
 */
async function focusAndType(page: Page, locator: Locator, value: string): Promise<void> {
  // Force-click to trigger Flutter focus on the text field
  await locator.click({ force: true }).catch(() => {});
  // Give Flutter time to create the native text editing input
  await page.waitForTimeout(800);

  // Clear existing content
  await page.keyboard.press('Control+A').catch(() => {});
  await page.waitForTimeout(100);
  await page.keyboard.press('Backspace').catch(() => {});
  await page.waitForTimeout(200);

  // Type the value character by character
  await page.keyboard.type(value, { delay: 50 });
  await page.waitForTimeout(300);
}

export async function goToLogin(page: Page): Promise<void> {
  await page.goto('/#/login');
  await page.waitForLoadState('domcontentloaded');
  await enableAccessibilityIfNeeded(page);

  // Skip onboarding if present
  await clickByTexts(page, TEXT.onboardingSkip, 2000);

  // Verify we're on the login page
  if (!page.url().includes('/login')) {
    await page.goto('/#/login');
    await page.waitForLoadState('domcontentloaded');
    await enableAccessibilityIfNeeded(page);
    await clickByTexts(page, TEXT.onboardingSkip, 2000);
  }

  await expect(page.locator('body')).toBeVisible({ timeout: 15_000 });
}

export async function fillPhoneAndContinue(
  page: Page,
  phone = TEST_LOGIN.phone,
): Promise<void> {
  const phoneInput = await firstVisibleInput(page);
  await focusAndType(page, phoneInput, phone);
  await page.waitForTimeout(500);

  // Try clicking "التالي" (Next) button first, then Enter as fallback
  const nextClicked = await clickByRole(page, 'button', TEXT.next, 2000);
  if (!nextClicked) {
    await page.keyboard.press('Enter');
  }
}

export async function fillOtpAndVerify(
  page: Page,
  otp = TEST_LOGIN.otp,
): Promise<void> {
  // Wait for the OTP screen to fully render
  await page.waitForTimeout(3000);

  // The OTP screen has 6 individual textbox fields and a "لصق الرمز" (paste code) button.
  // Pasting via clipboard is more reliable than typing digit-by-digit into Flutter fields.
  let otpEntered = false;

  // Strategy 1: Clipboard paste via the paste button
  try {
    // Set clipboard content
    await page.evaluate(
      (code) => navigator.clipboard.writeText(code),
      otp,
    );
    await page.waitForTimeout(300);

    // Click the paste button
    const pasteBtn = page.getByRole('button', { name: /لصق الرمز|لصق|paste/i }).first();
    if (await pasteBtn.isVisible({ timeout: 3000 }).catch(() => false)) {
      await pasteBtn.click({ force: true }).catch(() => {});
      await page.waitForTimeout(2000);
      otpEntered = true;
    }
  } catch {
    // Clipboard API may not be available in headless mode
  }

  // Strategy 2: Ctrl+V paste into first field
  if (!otpEntered) {
    try {
      await page.evaluate(
        (code) => navigator.clipboard.writeText(code),
        otp,
      );
      const firstField = page.getByRole('textbox').first();
      if (await firstField.isVisible({ timeout: 3000 }).catch(() => false)) {
        await firstField.click({ force: true }).catch(() => {});
        await page.waitForTimeout(800);
        await page.keyboard.press('Control+V');
        await page.waitForTimeout(2000);
        otpEntered = true;
      }
    } catch {
      // Clipboard fallback failed
    }
  }

  // Strategy 3: Type digit-by-digit with longer waits for first fields
  if (!otpEntered) {
    const otpFields = page.getByRole('textbox');
    const fieldCount = await otpFields.count();

    if (fieldCount >= otp.length) {
      for (let i = 0; i < otp.length; i++) {
        const field = otpFields.nth(i);
        if (await field.isVisible({ timeout: 2000 }).catch(() => false)) {
          await field.click({ force: true }).catch(() => {});
          // Extra wait for first fields — Flutter needs time to set up text editing
          await page.waitForTimeout(i < 2 ? 1200 : 600);
          await page.keyboard.press('Control+A').catch(() => {});
          await page.waitForTimeout(100);
          await page.keyboard.type(otp[i]);
          await page.waitForTimeout(500);
        }
      }
    } else {
      // Fallback: type all digits via keyboard
      await page.keyboard.type(otp, { delay: 200 });
    }
  }

  await page.waitForTimeout(2000);

  // Check if OTP was auto-submitted (URL changed from login)
  if (!page.url().includes('/login') && !page.url().includes('/otp')) {
    return; // Already navigated away
  }

  // Click the "تحقق" (verify) button
  const verifyBtn = page.getByRole('button', { name: /تحقق|verify/i }).first();
  if (await verifyBtn.isVisible({ timeout: 3000 }).catch(() => false)) {
    await verifyBtn.click({ force: true }).catch(() => {});
    await page.waitForTimeout(5000);
  }

  // Fallback: press Enter
  if (page.url().includes('/login') || page.url().includes('/otp')) {
    await page.keyboard.press('Enter');
  }
}

export async function maybeSelectStore(page: Page): Promise<void> {
  await page.waitForTimeout(2000);
  if (!page.url().includes('/store-select')) return;

  // Strategy 1: Click the preferred store by role (button with store name)
  const preferredBtn = page.getByRole('button', { name: /سوبرماركت الحي/i }).first();
  if (await isVisible(preferredBtn, 3000)) {
    await preferredBtn.click({ force: true }).catch(() => {});
    await page.waitForTimeout(3000);
    if (!page.url().includes('/store-select')) return;
  }

  // Strategy 2: Click the preferred store text
  const preferred = page.getByText(TEST_LOGIN.preferredStoreName).first();
  if (await isVisible(preferred, 2000)) {
    await preferred.click({ force: true }).catch(() => {});
    await page.waitForTimeout(3000);
    if (!page.url().includes('/store-select')) return;
  }

  // Strategy 3: Click any store/branch text
  if (await clickByTexts(page, TEXT.store, 3000)) {
    await page.waitForTimeout(3000);
    if (!page.url().includes('/store-select')) return;
  }

  // Strategy 4: Click any button on the page (stores are likely buttons)
  const anyButton = page.getByRole('button').first();
  if (await isVisible(anyButton, 2000)) {
    await anyButton.click({ force: true }).catch(() => {});
    await page.waitForTimeout(3000);
    if (!page.url().includes('/store-select')) return;
  }

  // Strategy 5: Coordinate-based click in center of viewport
  const viewport = page.viewportSize() ?? { width: 1280, height: 720 };
  await page.mouse.click(viewport.width / 2, viewport.height * 0.45);
  await page.waitForTimeout(3000);
}

/**
 * Full login flow: navigate to login → enter phone → enter OTP → select store.
 *
 * Retry strategy: only retry the PHONE step (not OTP) because the backend
 * rate-limits OTP verification attempts. Submitting a wrong OTP code
 * consumes an attempt, so we must get it right the first time.
 */
export async function loginToPos(page: Page): Promise<void> {
  // ── Phase 1: Phone entry (retryable) ──
  let otpReached = false;
  for (let attempt = 0; attempt < 3; attempt++) {
    await goToLogin(page);
    await fillPhoneAndContinue(page);
    await page.waitForTimeout(5000);

    otpReached = await expectBodyContainsAny(page, TEXT.otpTitle, 15_000)
      .then(() => true)
      .catch(() => false);

    if (otpReached) break;

    // Phone entry failed — reload and retry
    await page.goto('/#/login');
    await page.waitForTimeout(3000);
  }

  if (!otpReached) {
    throw new Error('OTP screen never appeared after 3 phone entry attempts');
  }

  // ── Phase 2: OTP entry (single attempt — rate limited) ──
  await fillOtpAndVerify(page);
  await page.waitForTimeout(5000);

  // After OTP, we should be on store-select or pos
  await expect
    .poll(() => page.url(), { timeout: 30_000 })
    .toMatch(/\/#\/(store-select|pos|dashboard)/);

  // ── Phase 3: Store selection ──
  if (page.url().includes('/store-select')) {
    await maybeSelectStore(page);

    // If still on store-select, navigate directly to POS
    if (page.url().includes('/store-select')) {
      await page.goto('/#/pos');
      await page.waitForTimeout(5000);
    }
  }
}

export async function ensureAuthenticatedAt(
  page: Page,
  hashRoute: string,
): Promise<void> {
  await page.goto(`/#${hashRoute}`);
  await page.waitForLoadState('domcontentloaded');
  await enableAccessibilityIfNeeded(page);

  const url = page.url();
  if (url.includes('/login') || url.includes('/onboarding') || url.includes('/splash')) {
    await loginToPos(page);
    await page.goto(`/#${hashRoute}`);
    await page.waitForLoadState('domcontentloaded');
    await page.waitForTimeout(2000);
    // Re-enable accessibility after navigation
    for (let i = 0; i < 8; i++) {
      const btns = await page.getByRole('button').count().catch(() => 0);
      if (btns > 1) break;
      await page.keyboard.press('Tab').catch(() => {});
      await page.waitForTimeout(200);
      await page.keyboard.press('Enter').catch(() => {});
      await page.waitForTimeout(500);
    }
  }

  await expect(page.locator('body')).toBeVisible({ timeout: 15_000 });
}

export async function expectNoFatalRouteError(page: Page): Promise<void> {
  await expect(page.getByText(/الصفحة غير موجودة/i)).toHaveCount(0);
  await expect(page.getByText(/page not found/i)).toHaveCount(0);
}

export function textPatterns() {
  return TEXT;
}
