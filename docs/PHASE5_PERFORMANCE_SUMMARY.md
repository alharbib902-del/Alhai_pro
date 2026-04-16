# Phase 5 — Performance Summary

**Date:** 2026-04-16
**Branch:** fix/phase5-tier3-e2e
**Tier:** 3 — Part 1 (E2E + Performance)

---

## Aggregate Numbers

| Metric | customer_app | driver_app | distributor_portal | Total |
|--------|-------------|-----------|-------------------|-------|
| Unit/Widget tests | 130 | 152 | 429 | **711** |
| Integration test files | 4 | 3 | 3 | **10** |
| Integration test widgets | ~52 | ~33 | ~30 | **~115** |
| Dart source files | 54 | 58 | 80 | 192 |
| Runtime dependencies | 24 | 30 | 18 | — |
| Analyzer issues | 1 info | 0 | 0 | 1 info |
| Test duration | 1m 40s | 50s | 52s | ~3m 22s |

---

## Test Coverage by App

### customer_app (B2C)
- **Unit/widget:** 130 tests across 18 files
- **Integration (new):** 4 files — happy paths (catalog → cart → checkout → order), auth flow (OTP rate limiting, account deletion, login cycle), error recovery (offline banner, empty cart guard, network retry)
- **Existing integration:** 1 file — online order flow (routing tests)

### driver_app (Delivery)
- **Unit/widget:** 152 tests across 22 files
- **Integration (new):** 3 files — delivery lifecycle (accept → pickup OTP → proof → delivered), safety features (SOS, wake lock, GPS detection, shift guard), offline queue (queue mutations, banner, flush on reconnect)

### distributor_portal (Flutter Web)
- **Unit/widget:** 429 tests across 36 files
- **Integration (new):** 3 files — order management (approve, invoice, products), admin flow (MFA login, distributor approval, document review, notifications), pricing tiers (create, default, assign, discount calculation)

---

## Top 5 Performance Recommendations

### 1. Web Hosting & Caching (distributor_portal) — P0
The distributor portal has **no deploy pipeline** and no service worker. First-load performance will be 3-5s on Flutter Web without caching. Add:
- Service worker for asset caching
- Gzip/brotli compression
- CanvasKit renderer for Arabic text

### 2. Parallelize Initialization (all apps) — P0
All 3 apps initialize Firebase, Supabase, and Sentry sequentially. These are independent operations that can run in parallel, saving ~300-500ms on cold start.

### 3. Compress Proof Photos (driver_app) — P0
Camera captures can be 5-10MB. The proof upload flow should resize images to max 1024px width before upload to reduce upload time and storage costs.

### 4. Batch Location Updates (driver_app) — P1
GPS location updates stream to Supabase on every tick. Batching every 10-15 seconds would reduce:
- Network calls by ~90%
- Battery consumption
- Supabase real-time channel load

### 5. Defer Heavy Dependencies (customer_app, driver_app) — P1
Both apps load Google Maps at startup even though maps are only used in specific screens. Use deferred loading (`deferred as`) for map-heavy screens.

---

## Ghost Bugs Discovered

| Bug | App | Severity | Notes |
|-----|-----|----------|-------|
| `dio` and `http` both in deps | customer_app, driver_app | Low | One should be sufficient; Supabase uses its own HTTP client |
| `get_it` + `injectable` underused | distributor_portal | Low | Only Riverpod is used for DI; GetIt setup is minimal |
| No pagination on order history | customer_app | Medium | Fetches all orders; will scale poorly |
| `flutter_spinkit` may be redundant | customer_app, driver_app | Low | `shimmer` already provides loading states |

---

## Integration Test Execution

Integration tests use `IntegrationTestWidgetsFlutterBinding` and require a device emulator or physical device. They **cannot run in headless CI** without:

### How to Run Locally
```bash
# customer_app (Android emulator or iOS simulator)
cd customer_app
flutter test integration_test/

# driver_app (Android emulator or iOS simulator)
cd driver_app
flutter test integration_test/

# distributor_portal (Chrome)
cd distributor_portal
flutter test integration_test/ -d chrome
```

### CI Setup Required
- **Android:** Use GitHub Actions with `reactivecircus/android-emulator-runner`
- **iOS:** Use macOS runner with Xcode simulator
- **Web:** Use `chromedriver` with `flutter drive --driver=test_driver/integration_test.dart`

---

## Blockers for Production (Cross-App)

| Blocker | Apps Affected | Severity |
|---------|--------------|----------|
| App signing (keystore/provisioning) | customer_app, driver_app | P0 |
| Google Maps API key | customer_app, driver_app | P0 |
| Firebase prod config | customer_app, driver_app | P0 |
| Web hosting + SSL | distributor_portal | P0 |
| Supabase prod project | All | P0 |
| Sentry prod DSN | All | P1 |
| Bundle ID registration | driver_app | P1 |
| CI/CD pipeline | All | P1 |

---

## Next Steps (Part 2 — Docs/Assets)

Part 2 of Tier 3 will cover:
- API documentation
- Asset optimization (images, icons, fonts)
- README updates per app
- CI/CD pipeline templates
- Release checklists
