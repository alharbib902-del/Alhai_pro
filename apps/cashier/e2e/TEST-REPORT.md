# Cashier App E2E Test Report

**Date:** 2026-03-04
**Target:** https://alhai-cashier.pages.dev
**Engine:** Playwright + Chromium (headless) with SwiftShader WebGL

---

## Summary

| Category | Tests | Passed | Flaky | Failed |
|---|---|---|---|---|
| 1. App Loading | 4 | 4 | 0 | 0 |
| 2. Authentication | 6 | 6 | 0 | 0 |
| 3. Main Routes | 15 | 15 | 0 | 0 |
| 4. Sub-Routes | 36 | 36 | 0 | 0 |
| 5. POS Functionality | 2 | 2 | 0 | 0 |
| 6. Shifts | 2 | 2 | 0 | 0 |
| 7. Returns | 1 | 1 | 0 | 0 |
| 8. Offline | 2 | 2 | 0 | 0 |
| 9. Errors | 4 | 4 | 0 | 0 |
| 10. Responsive | 3 | 3 | 0 | 0 |
| 11. Security | 3 | 3 | 0 | 0 |
| 12. Performance | 1 | 1 | 0 | 0 |
| **Total** | **79** | **79** | **0** | **0** |

All 79 tests pass with retries enabled (some are flaky on first attempt due to
Flutter CanvasKit + SwiftShader loading variability).

---

## How to Run

```bash
# Run against live deployment
E2E_BASE_URL=https://alhai-cashier.pages.dev npx playwright test

# Run against local build
npx playwright test

# Run specific category
npx playwright test --grep "AUTH-"
npx playwright test --grep "NAV-MAIN"

# Run with visible browser
npx playwright test --headed --grep "AUTH-005"
```

---

## Test Details

### 1. App Loading (4 tests)
- **LOAD-001**: Flutter engine initialises (flutter-view element exists)
- **LOAD-002**: CanvasKit renderer active (buildConfig confirms canvaskit)
- **LOAD-003**: Page renders non-blank content (semantics tree populated)
- **LOAD-004**: DOM content loads within 60s

### 2. Authentication (6 tests)
- **AUTH-001**: Login page shows phone input
- **AUTH-002**: Rejects short phone number (stays on login)
- **AUTH-003**: Rejects non-Saudi phone format
- **AUTH-004**: Valid phone shows OTP screen
- **AUTH-005**: Full login flow reaches POS (phone + OTP + store select)
- **AUTH-006**: "Change number" returns to phone step

### 3. Main Routes (15 tests)
Tests that each main sidebar route loads without crash:
POS, Sales, Customers, Products, Inventory, Shifts, Reports,
Settings, Sync, Profile, Notifications, Cash Drawer, Invoices,
Returns, Dashboard

### 4. Sub-Routes (36 tests)
Tests that each sub-route loads without crash:
- Shifts: open, close, cash-in-out, summary
- Customers: accounts, debt
- Products: quick-add, print-barcode, price-labels, categories-view
- Inventory: add, stock-take, wastage, transfer, alerts, expiry-tracking
- Reports: payments, daily-sales, top-products, cash-flow, custom
- Settings: store, tax, receipt, printer, payment-devices, shortcuts, users, backup
- Offers: active, bundles
- Cashier receiving, returns/request, POS/payment
- Orders: tracking, history

### 5. POS Functionality (2 tests)
- **POS-001**: POS screen loads with product UI elements
- **POS-002**: Payment screen shows input controls

### 6. Shifts (2 tests)
- **SHIFT-001**: Open shift page loads controls
- **SHIFT-002**: Close shift page loads

### 7. Returns (1 test)
- **RET-001**: Refund request screen has search

### 8. Offline (2 tests)
- **OFFLINE-001**: POS survives disconnect (offline mode)
- **OFFLINE-002**: Recovers after reconnect

### 9. Errors (4 tests)
- **ERR-001**: No fatal JS exceptions on POS
- **ERR-002**: No fatal exceptions across navigation
- **ERR-003**: Unknown route does not crash
- **ERR-004**: No failed core asset requests

### 10. Responsive (3 tests)
- **RESP-001**: Mobile viewport (375x812)
- **RESP-002**: Tablet viewport (768x1024)
- **RESP-003**: Wide desktop (1920x1080)

### 11. Security (3 tests)
- **SEC-001**: No secrets in URL after login
- **SEC-002**: CSP meta tag exists
- **SEC-003**: X-Frame-Options DENY

### 12. Performance (1 test)
- **PERF-001**: Navigation stability (3 round trips POS ↔ Sales)

---

## Known Flakiness

| Issue | Cause | Mitigation |
|---|---|---|
| Flutter load timeout (60s) | SwiftShader WebGL is slow in headless Chromium | Retries (2 configured) |
| Phone input timing | Force click + type has variable timing | Retry loop in phone entry |
| OTP entry | Individual fields need clipboard paste | Uses "paste code" button |

---

## Architecture Notes

- Flutter Web uses **CanvasKit renderer** (renders to `<canvas>`)
- Headless Chromium needs `--enable-webgl --use-gl=angle --use-angle=swiftshader`
- Flutter's **semantics tree** (`flt-semantics-host`) provides ARIA roles
- Accessibility enabled via Tab+Enter to populate semantics tree
- Auth state is **in-memory** (Riverpod/Supabase), not in cookies
- Each test context requires fresh login via `ensureAuthenticatedAt()`
- OTP entry uses **clipboard paste** (most reliable for Flutter OTP widgets)
- Click interactions use `{ force: true }` to bypass semantics overlay
