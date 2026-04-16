# Performance Audit — driver_app

**Date:** 2026-04-16
**Branch:** fix/phase5-tier3-e2e
**Phase:** 5 / Tier 3 — E2E + Performance

---

## 1. Analyzer Results

```
flutter analyze driver_app/
1 info issue (prefer_const_literals in safety_features_test.dart — fixed)
No errors, no warnings.
```

**Verdict:** Clean.

---

## 2. Test Summary

| Category | Count | Status |
|----------|-------|--------|
| Unit/Widget tests | 152 | All passing |
| Integration tests | 3 files (33 test widgets) | Require device emulator |
| Test files (unit) | 22 | — |
| Integration test files | 3 | — |

**Duration:** ~50s for unit tests on Windows.

---

## 3. Codebase Metrics

| Metric | Value |
|--------|-------|
| Dart source files (lib/) | 58 |
| Direct dependencies | 30 (runtime) + 12 (dev) |
| Features | auth, home, deliveries, proof, chat, earnings, profile, navigation |

---

## 4. Dependency Analysis

### Runtime Dependencies (30)
- **Core:** alhai_core, alhai_design_system (local packages)
- **State:** flutter_riverpod, riverpod_annotation, get_it, injectable
- **Navigation:** go_router
- **Backend:** supabase_flutter, dio, http, crypto
- **Storage:** shared_preferences, flutter_secure_storage
- **Location:** google_maps_flutter, geolocator, flutter_background_service
- **Media:** cached_network_image, image_picker, signature
- **UI:** shimmer, flutter_spinkit
- **Notifications:** firebase_core, firebase_messaging, flutter_local_notifications
- **Safety:** wakelock_plus, flutter_tts
- **Utils:** intl, uuid, connectivity_plus, package_info_plus, permission_handler, url_launcher

### Potentially Unused
- `dio` — Supabase handles HTTP; verify direct usage
- `http` — Same as dio; check if both needed
- `flutter_spinkit` — shimmer may cover all loading states

### Dev Dependencies (12)
- flutter_test, integration_test, build_runner, riverpod_generator, injectable_generator
- flutter_lints, mocktail, faker
- Platform interface mocks: geolocator, image_picker, plugin, url_launcher, wakelock_plus

---

## 5. Startup Performance

### Initialization Chain (main.dart)
1. `WidgetsFlutterBinding.ensureInitialized()`
2. `SentryFlutter.init()` — ~50-100ms
3. Firebase Core init — ~200-400ms
4. `Supabase.initialize()` — ~200-500ms
5. `SharedPreferences.getInstance()` — ~10ms
6. Session restore check
7. Widget tree build

### Recommendations
- **Parallelize** Firebase + Supabase init (both are independent)
- **Defer flutter_tts** init until driving mode is activated
- **Lazy-load google_maps_flutter** — only needed on NavigationScreen
- **Background service init** should happen AFTER login, not on cold start

---

## 6. Memory & Rendering

### Location Tracking
- Background location service runs continuously during active delivery
- GPS polling interval impacts battery — current interval unknown, audit needed
- Location updates stream to Supabase — consider batching (every 10s instead of real-time)

### Image Handling
- Proof photos captured via ImagePicker — raw camera images can be 5-10MB
- **Compress before upload** — verify compression is applied
- Signature capture as base64 — typically small (~50KB)

### State Management
- Riverpod streams for real-time delivery updates — efficient
- Offline queue stored in memory + disk — good
- Local cache service uses SQLite — efficient

### Potential Issues
- **Wakelock battery drain** — screen stays on during entire delivery (could be 30+ minutes)
- **Background location** — battery impact on older devices
- **Chat screen** — real-time stream may not dispose if navigated away improperly

---

## 7. Bundle Size Estimation

### Heavy Dependencies
| Package | Est. Size | Notes |
|---------|-----------|-------|
| google_maps_flutter | ~2MB | Maps navigation |
| firebase_core + messaging | ~1.5MB | Push notifications |
| geolocator + background_service | ~500KB | Location tracking |
| supabase_flutter | ~500KB | Core requirement |
| sentry_flutter | ~400KB | Crash reporting |
| flutter_tts | ~300KB | Voice prompts |
| signature | ~100KB | Signature capture |

### Recommendations
- Target APK < 30MB (heavier than customer_app due to maps/location)
- **Deferred loading** for NavigationScreen (Google Maps)
- Consider **on-demand download** for TTS language data

---

## 8. Performance Recommendations

### P0 — Critical
1. **Compress proof photos** before upload (resize to max 1024px width)
2. **Batch location updates** — send every 10-15s instead of every GPS tick
3. **Parallelize Firebase + Supabase init** to reduce cold start by ~300ms

### P1 — Important
4. **Defer background service start** until driver activates shift
5. **Add const constructors** to all stateless widgets
6. **Debounce offline queue writes** — avoid disk thrashing on rapid status changes
7. **Lazy-load flutter_tts** — only initialize when driving mode enabled

### P2 — Nice to Have
8. **Add frame monitoring** for delivery list scroll performance
9. **Use RepaintBoundary** around delivery cards with real-time status badges
10. **Cache store/pickup location** data to reduce repeated geocoding

---

## 9. Blockers for Production

| Blocker | Severity | Notes |
|---------|----------|-------|
| Google Maps API key | P0 | Needed for NavigationScreen |
| Firebase config (prod) | P0 | Push notifications config |
| App signing (keystore) | P0 | Debug signing currently |
| iOS provisioning | P0 | No Apple Developer setup |
| Background location permission | P0 | Android 12+ requires foreground service type |
| Sentry DSN (prod) | P1 | Production DSN needed |
| Bundle ID placeholders | P1 | com.alhai.driver needs registration |
| Desugaring config | P1 | Android minSdk compatibility |
