/** @type {import('playwright').LaunchOptions} */
module.exports = {
  baseURL: 'http://localhost:8080',
  headless: true,
  timeout: 30000,
  navigationTimeout: 15000,
  screenshotTimeout: 10000,
  viewport: { width: 1440, height: 900 },
  locale: 'ar',
  colorScheme: 'light',
  deviceScaleFactor: 1,
  retries: 0,
  workers: 1,
};
