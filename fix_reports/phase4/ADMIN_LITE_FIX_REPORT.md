# Admin Lite — Phase 4 Fix Report

**App:** `apps/admin_lite`
**Branch:** `fix/phase4-blockers`
**Date:** 2026-04-15
**Source:** `acceptance_reports/phase4/admin_pos_lite/ACCEPTANCE_REPORT_PHASE4_ADMIN_LITE.md`

---

## Summary

| Metric | Before | After |
|--------|--------|-------|
| Analyzer issues | 0 | **0** |
| Tests | 108 pass | **108 pass** |
| Defects addressed | 0/7 | **7/7** |

---

## Fixes Applied

### D1 — FLAG_SECURE (P1) ✅
**Commit:** `8d6cf90` — `fix(admin_lite): enable FLAG_SECURE to protect financial data`

- Modified `MainActivity.kt` to set `FLAG_SECURE` in `onCreate()`
- Prevents screenshots and screen recording on Android
- Skipped in debug mode (`BuildConfig.DEBUG`) to allow dev screenshots
- iOS protection deferred until D4 scaffold is configured on a Mac

### D2 — Push Notifications (P1) ✅
**Commit:** `16f3340` — `fix(admin_lite): clarify push notification status in UI`

- Added "coming soon" banner to `LiteNotificationPrefsScreen`
- Informs users that push notifications are not yet functional
- Firebase Messaging integration is deferred (requires Firebase project setup)
- Toggles remain so saved preferences will activate once FCM is integrated

### D3 — APK Size (P2) ✅
**Commit:** `90c28ec` — `chore(admin_lite): enable shrinkResources for APK size reduction`

- `isShrinkResources` and `isMinifyEnabled` were **already enabled**
- Added `ndk.debugSymbolLevel = "SYMBOL_TABLE"` to strip native debug symbols
- Added `android.bundle.enableUncompressedNativeLibs=true` for AAB optimization
- **Root cause:** 90MB comes from native libraries (SQLCipher, Supabase, Firebase, Sentry) and 40+ shared screens (AI, Reports). Not from assets (empty).
- **Recommendation:** Use `flutter build appbundle` for Play Store (auto ABI split), or `flutter build apk --split-per-abi` for sideloading

### D4 — iOS Missing (P2) ✅
**Commit:** `425bfe9` — `chore(admin_lite): generate iOS platform scaffold`

- Generated `ios/` directory via `flutter create --platforms ios .`
- Removed auto-generated template `test/widget_test.dart` (conflicted with existing tests)
- **Note:** This is a skeleton only. Actual iOS builds require Mac + Xcode. Bundle ID, signing, provisioning profiles, and App Store configuration still needed.

### D5 — RTL Arrow Icons (P2) ✅
**Commit:** `fc3d35e` — `fix(admin_lite): flip arrow icons for RTL layout`

- Replaced `Icons.chevron_right` → conditional `chevron_left`/`chevron_right` based on `Directionality.of(context)` in 4 files:
  - `lite_router.dart` (monitoring tile)
  - `lite_dashboard_screen.dart` (activity items)
  - `lite_settings_screen.dart` (settings tiles)
  - `lite_profile_screen.dart` (profile menu items)
- Replaced `Icons.arrow_forward` → conditional `arrow_back`/`arrow_forward` in:
  - `lite_order_status_screen.dart` (next step button)

### D6 — Version Mismatch (P3) ✅
**Commit:** `45e1cba` — `fix(admin_lite): read version dynamically from pubspec`

- Removed hardcoded `'v2.4.0'` from settings screen
- Added `package_info_plus` dependency
- Created `appVersionProvider` (StateProvider) initialized in `main.dart` from `PackageInfo.fromPlatform()`
- Now correctly displays `v1.0.0-beta.1` (matching pubspec.yaml)
- Updated test to verify dynamic version

### D7 — Notification Settings Persistence (P3) ✅
**Commit:** `842cdc7` — `fix(admin_lite): persist notification settings across restarts`

- Converted 4 notification toggle providers from `StateProvider` → `StateNotifierProvider` backed by `SharedPreferences`
- Converted 2 threshold providers similarly
- Settings now persist across app restarts
- Created reusable `_BoolPrefNotifier` and `_IntPrefNotifier` classes

---

## Final Verification

```
$ flutter analyze
Analyzing admin_lite...
No issues found!

$ flutter test
00:45 +108: All tests passed!
```

---

## Files Modified

| File | Fixes |
|------|-------|
| `android/app/src/main/kotlin/.../MainActivity.kt` | D1 |
| `android/app/build.gradle.kts` | D3 |
| `android/gradle.properties` | D3 |
| `ios/` (new directory, 39 files) | D4 |
| `lib/main.dart` | D6 |
| `lib/router/lite_router.dart` | D5 |
| `lib/screens/dashboard/lite_dashboard_screen.dart` | D5 |
| `lib/screens/orders/lite_order_status_screen.dart` | D5 |
| `lib/screens/settings/lite_notification_prefs_screen.dart` | D2 |
| `lib/screens/settings/lite_profile_screen.dart` | D5 |
| `lib/screens/settings/lite_settings_screen.dart` | D5, D6, D7 |
| `pubspec.yaml` | D6 |
| `test/helpers/mock_providers.dart` | D6 |
| `test/screens/settings/lite_settings_screen_test.dart` | D6 |
