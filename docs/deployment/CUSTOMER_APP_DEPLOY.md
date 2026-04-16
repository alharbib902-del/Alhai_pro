# Customer App — Mobile Deployment Guide

## Overview

| Item | Value |
|------|-------|
| **App name** | حي — عميل (Alhai — Customer) |
| **Android ID** | `com.alhai.customer_app` |
| **iOS Bundle ID** | `com.alhai.customer` |
| **Version** | 1.0.0-beta.1+1 |
| **Min Android SDK** | 21 (Android 5.0) |
| **Min iOS** | 12.0 |

> **Note:** Android and iOS bundle IDs differ (`customer_app` vs `customer`). This is by design but should be documented for future reference.

---

## Android Deployment

### 1. Generate Keystore

```bash
# Generate upload keystore (do this ONCE, store securely)
keytool -genkey -v \
  -keystore ~/alhai-customer-upload.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload \
  -storetype JKS

# You will be prompted for:
# - Keystore password
# - Key password
# - Name, organization, location info
```

> **CRITICAL:** Back up your keystore file and passwords. If lost, you cannot update your app on Play Store. Store in a secure password manager or company vault.

### 2. Configure Signing

Create `customer_app/android/key.properties`:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=/path/to/alhai-customer-upload.jks
```

A template exists at `customer_app/android/key.properties.example`.

> **WARNING:** Never commit `key.properties` or `.jks` files to git.

### 3. Build Signed Release

```bash
cd customer_app

# Build APK (for direct distribution/testing)
flutter build apk --release --dart-define-from-file=.env

# Build AAB (for Play Store — required)
flutter build appbundle --release --dart-define-from-file=.env

# Output locations:
# APK: build/app/outputs/flutter-apk/app-release.apk
# AAB: build/app/outputs/bundle/release/app-release.aab
```

### 4. Google Play Store Upload

#### First-time Setup

1. **Create Google Play Console account** ($25 one-time fee)
   - https://play.google.com/console
2. **Create app:**
   - App name: `حي — بقالة الحي للتوصيل السريع`
   - Default language: Arabic (ar)
   - App type: App
   - Free/Paid: Free
   - Category: Food & Drink
3. **Complete Store listing:**
   - Short description (80 chars max)
   - Full description (4000 chars max)
   - Screenshots (see app store assets docs)
   - Feature graphic (1024x500px)
   - App icon (512x512px)
4. **Content rating:** Complete IARC questionnaire
5. **Target audience:** 18+ (not directed at children)
6. **Privacy Policy URL:** `https://alhai.store/privacy` or `https://portal.alhai.store/privacy`

#### Release Tracks

| Track | Purpose | Review time |
|-------|---------|-------------|
| Internal testing | Team only (up to 100 testers) | No review |
| Closed testing (Alpha) | Selected testers | No review |
| Open testing (Beta) | Public beta | ~2 days |
| Production | Public release | ~3-7 days |

**Recommended rollout:**
1. Upload AAB to **Internal testing** → test thoroughly
2. Promote to **Closed testing** → share with beta testers
3. Promote to **Open testing** → wider audience
4. Promote to **Production** → staged rollout (10% → 25% → 50% → 100%)

```
Internal → Alpha → Beta → Production (staged)
```

#### Upload Steps

1. Play Console → Your app → Release → select track
2. Create new release
3. Upload `app-release.aab`
4. Add release notes (Arabic + English)
5. Review and roll out

### 5. Google Maps API Key

The customer app uses Google Maps. Configure before release:

```bash
# Android: Pass via Gradle property
flutter build apk --release \
  --dart-define-from-file=.env \
  -PGOOGLE_MAPS_API_KEY=AIza...your-key

# iOS: Create ios/Flutter/Maps.xcconfig
# GOOGLE_MAPS_API_KEY=AIza...your-key
# Template: ios/Flutter/Maps.xcconfig.example
```

**Required Google Cloud APIs:**
- Maps SDK for Android
- Maps SDK for iOS
- Places API (if used)

---

## iOS Deployment

### 1. Prerequisites

- macOS with Xcode 15+
- Apple Developer account ($99/year) at https://developer.apple.com
- Physical iOS device for testing (simulator has limitations)

### 2. Apple Developer Setup

1. **Enroll** at https://developer.apple.com/enroll
2. **Create App ID:**
   - Bundle ID: `com.alhai.customer`
   - Capabilities: Push Notifications (for future Firebase)
3. **Create certificates:**
   - iOS Distribution certificate
   - Push notification certificate (future)
4. **Create provisioning profiles:**
   - Development: for testing on devices
   - Distribution (App Store): for App Store submission

### 3. Xcode Configuration

```bash
cd customer_app/ios
pod install  # Flutter does this automatically on build

# Open in Xcode
open Runner.xcworkspace
```

In Xcode:
1. Select **Runner** target
2. **Signing & Capabilities:**
   - Team: Select your Apple Developer team
   - Bundle Identifier: `com.alhai.customer`
   - Signing Certificate: iOS Distribution
3. **General:**
   - Display Name: `الهاي`
   - Version: 1.0.0
   - Build: 1

### 4. Build for App Store

```bash
cd customer_app

# Build iOS release
flutter build ios --release --dart-define-from-file=.env

# Then in Xcode:
# Product → Archive
# Window → Organizer → Distribute App → App Store Connect
```

### 5. TestFlight

1. **Xcode Organizer** → Distribute App → App Store Connect → Upload
2. **App Store Connect** (https://appstoreconnect.apple.com):
   - Select your app → TestFlight
   - Add internal testers (up to 100)
   - Add external testers (up to 10,000) — requires beta review
3. **Test on devices** via TestFlight app

### 6. App Store Submission

1. **App Store Connect** → Your app → App Store tab
2. Complete all required fields:
   - App name: `حي — بقالة الحي للتوصيل السريع`
   - Subtitle: `طلبك من أقرب بقالة بدقائق`
   - Category: Food & Drink
   - Screenshots (iPhone 6.7", 6.5", 5.5"; iPad if universal)
   - App Preview (optional video)
   - Description, keywords, support URL, privacy URL
3. **Review notes** for Apple reviewer (see app store assets docs)
4. Submit for review

#### Review Timeline
- First submission: 7-14 business days
- Subsequent updates: 1-3 business days
- Expedited review: available for critical fixes

#### Common Rejection Reasons (and our mitigations)
| Reason | Mitigation |
|--------|-----------|
| Missing account deletion | ✅ Built in Profile screen |
| Missing privacy policy | Must publish before submission |
| Location permission without purpose | ✅ `NSLocationWhenInUseUsageDescription` in Info.plist |
| Login issues | Provide test account in review notes |

---

## Environment Variables

See [ENVIRONMENT_VARIABLES.md](./ENVIRONMENT_VARIABLES.md) for the complete list. Key variables for customer_app:

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SENTRY_DSN_CUSTOMER=https://your-customer-sentry-dsn
SUPABASE_CERT_FINGERPRINT=base64-sha256-fingerprint
SUPABASE_CERT_FINGERPRINT_BACKUP=backup-fingerprint
FLAVOR=prod
```

---

## Pre-Launch Checklist

### Android
- [ ] Keystore generated and backed up securely
- [ ] `key.properties` configured (not committed to git)
- [ ] Release APK/AAB builds successfully
- [ ] Google Maps API key configured
- [ ] `google-services.json` placed (Firebase)
- [ ] ProGuard rules tested (app works after minification)
- [ ] Play Store listing complete
- [ ] Privacy Policy URL added to Play Store listing
- [ ] Content rating questionnaire completed
- [ ] Internal testing track verified

### iOS
- [ ] Apple Developer account active
- [ ] Certificates and provisioning profiles created
- [ ] Bundle ID registered (`com.alhai.customer`)
- [ ] Maps.xcconfig configured
- [ ] `GoogleService-Info.plist` placed (Firebase)
- [ ] App Store Connect listing complete
- [ ] TestFlight build uploaded and tested
- [ ] Review notes prepared with test account
- [ ] `NSLocationWhenInUseUsageDescription` set
- [ ] App icon (1024x1024) provided

---

*Last updated: April 16, 2026*
