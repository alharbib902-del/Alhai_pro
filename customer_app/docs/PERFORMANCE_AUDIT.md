# Performance Audit — customer_app

**Date:** 2026-04-16
**Branch:** fix/phase5-tier3-e2e
**Phase:** 5 / Tier 3 — E2E + Performance

---

## 1. Analyzer Results

```
flutter analyze customer_app/
1 info issue (curly_braces_in_flow_control_structures in login_screen.dart:89)
No errors, no warnings.
```

**Verdict:** Clean. The single info is cosmetic.

---

## 2. Test Summary

| Category | Count | Status |
|----------|-------|--------|
| Unit/Widget tests | 130 | All passing |
| Integration tests | 4 files (52+ test widgets) | Require device emulator |
| Test files (unit) | 18 | — |
| Integration test files | 4 | — |

**Duration:** ~1m 40s for unit tests on Windows.

---

## 3. Codebase Metrics

| Metric | Value |
|--------|-------|
| Dart source files (lib/) | 54 |
| Direct dependencies | 24 (runtime) + 7 (dev) |
| Total resolved packages | ~107 outdated |
| Features | auth, home, catalog, cart, checkout, orders, tracking, profile, search, addresses |

---

## 4. Dependency Analysis

### Runtime Dependencies (24)
- **Core:** alhai_core, alhai_design_system, alhai_zatca (local packages)
- **State:** flutter_riverpod
- **Navigation:** go_router
- **Backend:** supabase_flutter, dio, http
- **Storage:** shared_preferences, flutter_secure_storage
- **UI:** cached_network_image, shimmer, flutter_spinkit
- **Maps:** google_maps_flutter, geolocator (for nearby stores)
- **Utils:** intl, uuid, connectivity_plus, package_info_plus, permission_handler
- **Crash:** sentry_flutter

### Potentially Unused
- `dio` — Supabase client handles HTTP internally; check if any direct usage exists
- `flutter_spinkit` — Check if shimmer already covers loading states

### Dev Dependencies (7)
- flutter_test, integration_test, build_runner, riverpod_generator, injectable_generator, flutter_lints, mocktail, faker

---

## 5. Startup Performance

### Initialization Chain (main.dart)
1. `WidgetsFlutterBinding.ensureInitialized()`
2. `SentryFlutter.init()` — ~50-100ms cold
3. Firebase init (unused for core flow)
4. `Supabase.initialize()` — ~200-500ms (network-dependent)
5. `SharedPreferences.getInstance()` — ~10ms
6. Widget tree build

### Recommendations
- **Defer Firebase init** if not used for push notifications in MVP
- **Lazy-load google_maps_flutter** — only used on NearbyStoresScreen (deferred)
- **Preload critical data** (store list, user profile) during splash instead of on HomeScreen mount

---

## 6. Memory & Rendering

### Image Loading
- Uses `CachedNetworkImage` with disk cache — good
- Hero animations on product detail — review transition frame budget
- Product grid uses `SliverGrid` — efficient for large catalogs

### State Management
- Riverpod with `.autoDispose` on most providers — memory-safe
- `CartNotifier` persists to SharedPreferences — watch for large carts
- Real-time order streams dispose properly via `autoDispose`

### Potential Issues
- **Cart serialization:** JSON encode/decode on every mutation; consider debouncing
- **Catalog pagination:** Good — uses offset-based pagination from Supabase
- **Order tracking screen:** Real-time stream + Google Maps — high memory on older devices

---

## 7. Bundle Size Estimation

### Heavy Dependencies
| Package | Est. Size | Notes |
|---------|-----------|-------|
| google_maps_flutter | ~2MB | Only for nearby stores (deferred) |
| supabase_flutter | ~500KB | Core requirement |
| sentry_flutter | ~400KB | Crash reporting |
| cached_network_image | ~200KB | Image caching |
| geolocator | ~150KB | Location services |

### Recommendations
- **Deferred loading** for google_maps_flutter screens (already implemented)
- **Tree-shake** unused Supabase modules (realtime, storage if not used)
- Target APK < 25MB, iOS < 30MB

---

## 8. Performance Recommendations

### P0 — Critical
1. **Defer Firebase initialization** unless push notifications are active
2. **Add const constructors** to all stateless widgets in features/shared/

### P1 — Important
3. **Lazy-load images** with placeholder shimmer (partially done)
4. **Debounce cart persistence** — batch writes instead of per-mutation
5. **Paginate order history** — currently fetches all orders

### P2 — Nice to Have
6. **Precompute VAT** on server side to reduce client computation
7. **Cache category list** locally with TTL (reduces API calls)
8. **Use RepaintBoundary** around frequently-updated widgets (cart badge, connectivity banner)

---

## 9. Blockers for Production

| Blocker | Severity | Notes |
|---------|----------|-------|
| Google Maps API key | P0 | Needed for NearbyStoresScreen |
| Firebase config | P1 | Push notifications config pending |
| App signing (keystore) | P0 | Not configured for release |
| iOS provisioning | P0 | No Apple Developer account setup |
| Sentry DSN | P1 | Production DSN needed |
