# iOS — Al-HAI Cashier

Scaffold created Phase 5 §5.3 (2026-04-24). Build + release require a macOS
host + Apple Developer account.

## Status

| Item                        | Status |
|-----------------------------|--------|
| Flutter iOS scaffold        | ✅ created via `flutter create --platforms=ios .` |
| Bundle ID                   | ✅ `com.alhai.cashier` |
| Deployment target           | ✅ iOS 13.0 |
| CFBundleDisplayName         | ✅ `Al-HAI Cashier` |
| Info.plist entitlements     | ⚠️ default only — update before store submit |
| Signing (Apple Dev Account) | ⏳ owner action |
| Provisioning profile        | ⏳ owner action |
| TestFlight build            | ⏳ owner action |

## Building locally (macOS)

```bash
cd apps/cashier
flutter pub get
cd ios && pod install && cd ..
flutter build ios --release --no-codesign \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=SENTRY_DSN=$SENTRY_DSN
```

`--no-codesign` produces an unsigned `.app` for local testing. Uploading
to TestFlight requires `--codesign` + a valid provisioning profile.

## Release checklist (before App Store submit)

- [ ] Apple Developer Program membership active
- [ ] App ID `com.alhai.cashier` registered on developer.apple.com
- [ ] Distribution certificate + App Store provisioning profile generated
- [ ] Xcode signing → Team set + auto-manage signing
- [ ] App Transport Security: review Info.plist
- [ ] NSMicrophoneUsageDescription / NSCameraUsageDescription if barcode
      scanning uses the camera (currently only external hardware scanners)
- [ ] Icon set (1024×1024 marketing + all app icon sizes) placed in
      `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- [ ] Launch screen tuned to match Android splash
- [ ] Version + build bumped in `pubspec.yaml`
- [ ] `flutter build ipa --release` → `build/ios/ipa/*.ipa`
- [ ] Upload via Transporter or Xcode Organizer
- [ ] TestFlight internal build → internal testers → beta reviewers

## Why this is a scaffold only

The Phase 5 plan marks iOS as "تتطلب تفويض المالك (Apple Developer
Account)". The scaffold unblocks future work — bundle ID, deployment
target, and `Info.plist` keys are in the right shape — but signing,
provisioning, and TestFlight are owner actions that cannot be automated
from CI without Apple secrets.
