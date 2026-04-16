# Performance Audit — distributor_portal

**Date:** 2026-04-16
**Branch:** fix/phase5-tier3-e2e
**Phase:** 5 / Tier 3 — E2E + Performance

---

## 1. Analyzer Results

```
flutter analyze distributor_portal/
No issues found! (ran in 30.4s)
```

**Verdict:** Clean — 0 issues.

---

## 2. Test Summary

| Category | Count | Status |
|----------|-------|--------|
| Unit/Widget tests | 429 | All passing |
| Integration tests | 3 files (30 test widgets) | Require device emulator |
| Test files (unit) | 36 | — |
| Integration test files | 3 | — |

**Duration:** ~52s for unit tests on Windows.

---

## 3. Codebase Metrics

| Metric | Value |
|--------|-------|
| Dart source files (lib/) | 80 |
| Direct dependencies | 18 (runtime) + 4 (dev) |
| Screens | 22 screen files |
| Providers | 14 provider files |
| Data models | 15 model files |

---

## 4. Dependency Analysis

### Runtime Dependencies (18)
- **Core:** alhai_core, alhai_design_system, alhai_l10n, alhai_zatca (local packages)
- **State:** flutter_riverpod, get_it, injectable
- **Navigation:** go_router
- **Backend:** supabase_flutter, http
- **Storage:** shared_preferences
- **UI:** fl_chart (dashboard charts), qr_flutter (ZATCA QR)
- **Utils:** intl, hijri, uuid, crypto
- **Web:** web (dart:html replacement)
- **Files:** file_picker
- **Crash:** sentry_flutter

### Potentially Unused
- `get_it` + `injectable` — App primarily uses Riverpod; DI setup is minimal
- `http` — Supabase handles HTTP; verify direct usage

### Dev Dependencies (4)
- flutter_test, integration_test, build_runner, flutter_lints, mocktail

**Note:** Lightest dependency footprint of all 3 apps.

---

## 5. Startup Performance (Web)

### Initialization Chain (main.dart)
1. `WidgetsFlutterBinding.ensureInitialized()`
2. `SentryFlutter.init()` — ~100ms
3. `Supabase.initialize()` — ~300-700ms (network-dependent)
4. `SharedPreferences.getInstance()` — ~5ms (web storage)
5. Session restore + org_id lookup
6. Widget tree build + GoRouter redirect

### Web-Specific Concerns
- **Initial load (TTFB):** Flutter Web has ~2-4s initial JS parse time
- **Service worker caching:** Not configured — repeat visits reload everything
- **Font loading:** Arabic fonts can be 200-500KB
- **Deferred loading:** Pricing, Reports, PricingTiers screens use `deferred as` — good

### Recommendations
- **Add service worker** for caching static assets
- **Preload Arabic font subset** in index.html
- **Use CanvasKit renderer** for production (better text rendering for Arabic)
- **Compress main.dart.js** with gzip/brotli on deployment

---

## 6. Memory & Rendering

### Data Table Performance
- Orders list uses `DataTable` with sorting — O(n log n) per sort
- Invoices list with 5 tabs — each tab fetches independently (no shared cache)
- Products list with search — client-side filtering (acceptable for <1000 products)

### Charts
- `fl_chart` on dashboard — renders on every provider rebuild
- Recommendation: wrap charts in `RepaintBoundary` and debounce data updates

### State Management
- Riverpod with `autoDispose` on FutureProviders — good
- `DistributorDatasource` has built-in TTL cache and rate limiter — excellent
- Session timeout wrapper handles idle detection

### Potential Issues
- **Large order lists:** No pagination on orders — fetches up to 50 per call
- **Invoice PDF rendering:** QR generation on every build; should be cached
- **Admin notifications polling:** Consider WebSocket instead of periodic fetch

---

## 7. Bundle Size Analysis (Web)

### Current State
Flutter Web build was not executed (CI required). Static analysis:

### Heavy Dependencies (Web Impact)
| Package | Est. JS Size | Notes |
|---------|-------------|-------|
| fl_chart | ~150KB min | Dashboard charts |
| qr_flutter | ~50KB min | ZATCA QR codes |
| supabase_flutter | ~200KB min | Core requirement |
| sentry_flutter | ~100KB min | Crash reporting |
| alhai_zatca | ~30KB min | Invoice helpers |

### Estimated Total
- **main.dart.js:** ~3-5MB uncompressed, ~800KB-1.2MB gzipped
- **canvaskit.wasm:** ~2.5MB (cached after first load)
- **fonts:** ~300-500KB (Arabic + Material Icons)

### Recommendations
- **Enable gzip/brotli** on web server
- **Configure service worker** for asset caching
- **Deferred loading** already applied to 3 screens — extend to admin screens
- **Remove unused fl_chart** styles/data if only using 2-3 chart types

---

## 8. Performance Recommendations

### P0 — Critical
1. **Add service worker** for Flutter Web caching (repeat visit speed)
2. **Enable gzip/brotli compression** on hosting (Nginx/CDN)
3. **Use CanvasKit renderer** for production builds (better Arabic text)

### P1 — Important
4. **Paginate orders/invoices** — server-side with offset/limit (already in datasource)
5. **Cache QR code images** — generate once, reuse on subsequent renders
6. **Debounce search** in products screen (currently fires on every keystroke)
7. **Add RepaintBoundary** around dashboard charts

### P2 — Nice to Have
8. **Preload Arabic font** in index.html `<link rel="preload">`
9. **Add loading skeleton** for deferred screens (already using SkeletonLoading)
10. **Consider WebSocket** for admin notifications instead of polling

---

## 9. Blockers for Production

| Blocker | Severity | Notes |
|---------|----------|-------|
| Web hosting setup | P0 | No deploy pipeline exists |
| Supabase prod config | P0 | Production project URL/anon key |
| Custom domain + SSL | P0 | HTTPS required for web auth |
| Sentry DSN (prod) | P1 | Production DSN needed |
| Service worker | P1 | Required for offline/caching |
| Web build verification | P1 | `flutter build web` not tested in CI |
| MFA secret management | P1 | TOTP secrets stored in Supabase user metadata |
