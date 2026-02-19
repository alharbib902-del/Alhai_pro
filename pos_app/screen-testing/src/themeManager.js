/**
 * Theme Manager - handles Light/Dark theme enforcement for Flutter web
 *
 * Flutter renders on canvas, so we can't easily detect theme from CSS.
 * Strategy:
 *   1. Use browser colorScheme context (set at context creation)
 *   2. Navigate with ?theme param as hint
 *   3. Fallback: screenshot-based detection not reliable for canvas
 *
 * For Flutter, the main way to set theme is:
 *   - Browser's prefers-color-scheme (via Playwright context colorScheme)
 *   - The app reads this via MediaQuery.platformBrightness
 */

class ThemeManager {
  constructor(page, baseURL) {
    this.page = page;
    this.baseURL = baseURL;
  }

  /**
   * Detect current theme - for Flutter canvas, this is approximate
   * We check the browser's color scheme preference
   */
  async detectCurrentTheme() {
    try {
      const result = await this.page.evaluate(() => {
        return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
      });
      return result;
    } catch {
      return 'unknown';
    }
  }

  /**
   * Set theme via query parameter (if app supports it)
   */
  async setThemeViaParam(theme, currentPath) {
    const separator = currentPath.includes('?') ? '&' : '?';
    const url = `${this.baseURL}/#${currentPath}${separator}theme=${theme}`;
    await this.page.goto(url, { waitUntil: 'domcontentloaded', timeout: 10000 }).catch(() => {});
    await this.page.waitForTimeout(2000);
    const detected = await this.detectCurrentTheme();
    return detected === theme;
  }

  /**
   * Enforce a specific theme
   * For Flutter web, the primary mechanism is the browser context colorScheme
   * which was already set when creating the context.
   */
  async enforceTheme(theme, currentPath = '/dashboard') {
    // Check if browser's colorScheme matches
    const detected = await this.detectCurrentTheme();

    if (detected === theme) {
      return { success: true, method: 'browser-context', detected: theme };
    }

    // Try query param
    const paramSuccess = await this.setThemeViaParam(theme, currentPath);
    if (paramSuccess) {
      return { success: true, method: 'query-param', detected: theme };
    }

    // For Flutter, the colorScheme is set at context level
    // If it doesn't match, the app may have its own theme override
    return {
      success: detected === theme,
      method: detected === theme ? 'browser-context' : 'best-effort',
      detected,
      warning: detected !== theme ? `Browser colorScheme set to ${theme} but app may use internal theme state` : null,
    };
  }
}

module.exports = { ThemeManager };
