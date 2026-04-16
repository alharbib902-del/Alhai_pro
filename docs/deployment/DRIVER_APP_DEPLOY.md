# Driver App — Mobile Deployment Guide

## Overview

| Item | Value |
|------|-------|
| **App name** | حي — سائق (Alhai — Driver) |
| **Android ID** | `com.alhai.driver_app` |
| **iOS Bundle ID** | `com.alhai.driver` |
| **Version** | 1.0.0-beta.1+1 |
| **Min Android SDK** | 21 (Android 5.0) |
| **Min iOS** | 12.0 |

> **Note:** Android and iOS bundle IDs differ (`driver_app` vs `driver`). Same pattern as customer_app.

### Key Differences from Customer App

The driver app has additional requirements:
- **Background location** — continuous GPS tracking during active deliveries
- **Foreground service** — Android notification for active delivery tracking
- **Stricter keystore enforcement** — build fails without keystore (no debug fallback)
- **Certificate pinning** — same service as customer_app, also reads `SUPABASE_CERT_FINGERPRINT`

---

## Android Deployment

### 1. Generate Keystore

```bash
keytool -genkey -v \
  -keystore ~/alhai-driver-upload.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload \
  -storetype JKS
```

> **CRITICAL:** The driver app **will not build** in release mode without a valid keystore. Unlike customer_app, there is no debug fallback — `GradleException` is thrown.

### 2. Configure Signing

Create `driver_app/android/key.properties`:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=/path/to/alhai-driver-upload.jks
```

Template: `driver_app/android/key.properties.example`

### 3. Build Signed Release

```bash
cd driver_app

# Build APK
flutter build apk --release --dart-define-from-file=.env

# Build AAB (for Play Store)
flutter build appbundle --release --dart-define-from-file=.env
```

### 4. Android Permissions

The driver app requests these permissions (already configured in `AndroidManifest.xml`):

| Permission | Purpose | Type |
|-----------|---------|------|
| `ACCESS_FINE_LOCATION` | Delivery navigation | Runtime |
| `ACCESS_COARSE_LOCATION` | Approximate location | Runtime |
| `ACCESS_BACKGROUND_LOCATION` | Tracking during active delivery | Runtime (Android 10+) |
| `FOREGROUND_SERVICE` | Active delivery notification | Normal |
| `CAMERA` | Proof of delivery photos | Runtime |
| `INTERNET` | API communication | Normal |

> **Play Store note:** Background location requires a declaration in Play Console explaining why it's necessary. Reason: "Real-time delivery tracking for customers and dispatchers while driver is on an active delivery."

### 5. Foreground Service Configuration

The driver app uses an Android foreground service for continuous location tracking during active deliveries. This appears as a persistent notification.

**Notification channel** should be configured in the app for:
- Channel name: "Active Delivery" / "توصيل نشط"
- Importance: Default
- Shows: current delivery status and destination

### 6. Google Play Store Upload

Same process as customer_app. Key differences:

| Setting | Value |
|---------|-------|
| App name | `حي — السائقين` |
| Category | Maps & Navigation |
| Target audience | 18+ (drivers only) |
| Background location declaration | Required |
| Privacy Policy URL | `https://alhai.store/privacy` |

**Release track recommendation:** Same as customer_app (Internal → Alpha → Beta → Production).

---

## iOS Deployment

### 1. Apple Developer Setup

Same as customer_app, with these differences:

| Setting | Value |
|---------|-------|
| Bundle ID | `com.alhai.driver` |
| Capabilities | Push Notifications, Location Updates (Background Mode) |

### 2. Background Location (iOS)

The driver app needs **Background Modes** capability:
- Location updates

In `Info.plist` (already configured):
- `NSLocationWhenInUseUsageDescription` — "لتحديد موقعك أثناء التوصيل"
- `NSLocationAlwaysAndWhenInUseUsageDescription` — "لتتبع التوصيل في الخلفية"
- `UIBackgroundModes` — `location`

> **App Store note:** Apple is strict about background location. The app must demonstrate active use during review. Provide detailed review notes with a test driver account and explain the delivery tracking workflow.

### 3. Build and Submit

```bash
cd driver_app
flutter build ios --release --dart-define-from-file=.env

# Then in Xcode: Product → Archive → Distribute to App Store Connect
```

### 4. App Store Submission

Same process as customer_app. Additional review notes needed:
- Explain background location use case
- Provide test driver account credentials
- Describe the delivery workflow: accept order → navigate → deliver → confirm

---

## Firebase Setup (Future — Push Notifications)

Both customer_app and driver_app depend on `firebase_core` and `firebase_messaging` but Firebase is not yet configured.

### When Ready:

1. **Create Firebase project** at https://console.firebase.google.com
2. **Add Android app:**
   - Package name: `com.alhai.driver_app`
   - Download `google-services.json`
   - Place in: `driver_app/android/app/google-services.json`
3. **Add iOS app:**
   - Bundle ID: `com.alhai.driver`
   - Download `GoogleService-Info.plist`
   - Place in: `driver_app/ios/Runner/GoogleService-Info.plist`
4. **Run FlutterFire CLI** (optional, for `firebase_options.dart`):
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure --project=your-firebase-project
   ```

> **Note:** `google-services.json` and `GoogleService-Info.plist` are gitignored. They must be provided at build time or via CI secrets.

---

## Environment Variables

See [ENVIRONMENT_VARIABLES.md](./ENVIRONMENT_VARIABLES.md). Key variables for driver_app:

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SENTRY_DSN_DRIVER=https://your-driver-sentry-dsn
SUPABASE_CERT_FINGERPRINT=base64-sha256-fingerprint
SUPABASE_CERT_FINGERPRINT_BACKUP=backup-fingerprint
FLAVOR=prod
```

---

## Pre-Launch Checklist

### Android
- [ ] Keystore generated and backed up securely
- [ ] `key.properties` configured — build verified (no `GradleException`)
- [ ] Release AAB builds and installs correctly
- [ ] Background location declaration submitted in Play Console
- [ ] Foreground service notification working
- [ ] `google-services.json` placed (when Firebase is ready)
- [ ] ProGuard rules tested
- [ ] Play Store listing complete
- [ ] Category set to Maps & Navigation

### iOS
- [ ] Apple Developer account active
- [ ] Bundle ID registered (`com.alhai.driver`)
- [ ] Background Modes → Location Updates enabled
- [ ] All location permission strings set in Info.plist
- [ ] `GoogleService-Info.plist` placed (when Firebase is ready)
- [ ] TestFlight build tested by real drivers
- [ ] Review notes explain background location usage
- [ ] Test driver account credentials provided to Apple reviewer

### Both Platforms
- [ ] Certificate pinning fingerprints configured
- [ ] Sentry DSN configured and receiving reports
- [ ] Location tracking tested in real delivery scenarios
- [ ] Privacy Policy accessible via URL
- [ ] Camera permission for proof-of-delivery tested

---

*Last updated: April 16, 2026*
