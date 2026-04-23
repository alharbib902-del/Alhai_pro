# Release Checklist — customer_app + driver_app

Single-page checklist for first-production release of the two end-user
apps. Both apps are Flutter + Supabase, target Android (Play Store)
with optional iOS track (App Store). This doc is reviewed end-to-end
per release.

Last verified against repo state: **§4h complete (Sessions 51-54, 2026-04-25).**

---

## 0. Prerequisites — gather before starting

### Secrets you MUST have on hand

- [ ] **Android upload keystore** (one per app — do NOT share between apps).
  Generate via `bash scripts/generate_keystores.sh` — it handles both
  customer_app and driver_app.
- [ ] **Firebase projects** configured for both apps.
  Either one shared project with two apps, or two separate projects.
  Required files:
  - `customer_app/android/app/google-services.json`
  - `driver_app/android/app/google-services.json`
- [ ] **Google Play Console account** with permission to create apps.
- [ ] *(iOS only)* **Apple Developer account** + configured App Store
  Connect entry for each bundle ID.

### Optional but recommended

- [ ] **Sentry DSN** per app (free tier covers ≤ 5k events/month).
- [ ] **Play Console service-account JSON** (for CI/CD upload later).
- [ ] **GOOGLE_MAPS_API_KEY** (customer_app only — used by delivery-map
  widget). Pass via `~/.gradle/gradle.properties`:
  `GOOGLE_MAPS_API_KEY=AIza...`.

### DO NOT commit any of the above to git.
The `.gitignore` already excludes:
`**/*.jks`, `**/key.properties`, `**/google-services.json`, `**/*.keystore`.

---

## 1. Pre-release verification (≤ 10 min)

Run these before every release to catch regressions early.

### Tests pass

```bash
cd customer_app && flutter test
cd ../driver_app && flutter test
```

Expected (last known good):
- customer_app: **142 / 142**
- driver_app: **156 / 156**

### Analyzer clean

```bash
cd customer_app && flutter analyze
cd ../driver_app && flutter analyze
```

No `error -` or new `warning -` lines. Pre-existing `info -` is fine.

### Version bumped

Each release must bump both parts of `pubspec.yaml::version`:

```
version: 1.0.0-beta.1+1
         │         │  │
         │         │  └── build number (MUST increment per Play upload)
         │         └──── pre-release tag (beta/rc/final)
         └────────────── semver
```

Play Console rejects AABs with a build number ≤ the last uploaded one,
so `+N` must be strictly monotonic per app.

---

## 2. Android build (≤ 15 min per app)

### Build customer_app AAB

```bash
bash scripts/build_customer_release.sh
```

The script runs pre-flight checks (keystore present, google-services
optional but warned, flutter available), bumps through `flutter clean`,
`flutter pub get`, then produces a signed AAB with obfuscation and
split debug symbols at:

- `customer_app/build/app/outputs/bundle/release/app-release.aab`
- `dist/customer_app-<version>-<build>.aab` (dated copy for upload)
- `customer_app/build/symbols/` (Dart obfuscation map — keep for crash
  deobfuscation)

### Build driver_app AAB

```bash
bash scripts/build_driver_release.sh
```

Same outputs under `driver_app/` and `dist/driver_app-*.aab`.

### Sanity-check the AAB

```bash
# Confirm the AAB is signed with your upload keystore (not the debug one):
bundletool dump manifest --bundle=dist/customer_app-*.aab \
    | grep -E 'versionCode|versionName|package='

# Verify there are NO cleartext networking permissions:
bundletool dump manifest --bundle=dist/customer_app-*.aab \
    | grep 'usesCleartextTraffic'
# Expected: android:usesCleartextTraffic="false"  (or absent)
```

---

## 3. Play Console — first-time upload

Per app, first time only:

- [ ] Create app entry in Play Console → select **Add app**.
- [ ] App details:
  - customer_app: name "الهاي - عميل", package `com.alhai.customer`.
  - driver_app: name "الهاي - سائق", package `com.alhai.driver_app`.
- [ ] Complete "Main store listing": short/full description,
  screenshots (2+ phone, 1+ tablet recommended), feature graphic
  (1024×500 PNG), app icon (512×512 PNG).
- [ ] Content rating questionnaire (both apps → "Business" category).
- [ ] Target audience: 13+ (Saudi POS / commercial context).
- [ ] Privacy policy URL (REQUIRED — link to your hosted privacy page).
- [ ] Data safety form — declare what data the app collects and whether
  encrypted in transit (yes — all HTTPS / certificate-pinned).

---

## 4. Internal testing track upload (safer first round)

Per release:

- [ ] Play Console → Testing → Internal testing → Create new release.
- [ ] Drag & drop the `dist/*-<ver>-<build>.aab`.
- [ ] Release notes (Arabic + English).
- [ ] Start rollout to up to 100 internal testers.
- [ ] Install on a real Android device (must be signed in with a
  tester Google account). Smoke test:
  - [ ] Login flow works.
  - [ ] Data syncs (Supabase reachable).
  - [ ] Push notifications delivered (if Firebase configured).
  - [ ] Background location works (driver_app only).

After 24 hours of clean crash-free rate on internal track, promote
to `closed testing` / `production`.

---

## 5. iOS (optional — only if App Store release planned)

**Current state (2026-04-25):** iOS `Runner.xcworkspace` exists for
both apps but has not been verified end-to-end this session. Before
first iOS release:

- [ ] Open `customer_app/ios/Runner.xcworkspace` in Xcode — resolve
  signing errors; use automatic signing with a Team ID.
- [ ] Confirm `Info.plist` has all required permission strings:
  - `NSCameraUsageDescription` (barcode/receipt scan).
  - `NSLocationWhenInUseUsageDescription` (delivery / driver).
  - `NSLocationAlwaysAndWhenInUseUsageDescription` (driver_app only).
  - `NSUserTrackingUsageDescription` (if you add analytics ads).
- [ ] `flutter build ipa --release --obfuscate --split-debug-info=build/symbols`.
- [ ] Upload via Xcode Organizer or `xcrun altool`.
- [ ] TestFlight internal test first; rollout to external testers
  before submitting for App Review.

---

## 6. Post-deploy monitoring

First 48 hours after a release:

- [ ] Play Console → Statistics → crash-free rate per version.
  Target: ≥ 99.5% for ≥ 100 device sessions.
- [ ] Supabase — confirm sync_queue is draining:
  ```sql
  SELECT 'sales' AS t, COUNT(*) FROM public.sales
  UNION ALL SELECT 'sale_items', COUNT(*) FROM public.sale_items
  UNION ALL SELECT 'invoices', COUNT(*) FROM public.invoices;
  ```
  Row counts should be climbing in proportion to per-device local sales
  counts. If flat, the push payload contract has regressed — see
  Session 53 log for the last known pattern (`docs/sessions/FIX_SESSION_LOG.md`).
- [ ] Sentry (if configured) — any new-in-release error class > 1% of
  affected users is a candidate for hotfix.

---

## 7. Rollback

If a bad release hits production:

- [ ] Play Console → Testing → halt rollout for the bad AAB.
- [ ] Bump build number, rebuild previous version (or last known good),
  re-upload as a NEW release (Play does not allow overwriting a build
  number once uploaded).
- [ ] If a Supabase schema migration went along with the bad release,
  coordinate rollback per the migration's own rollback DDL header
  (see `supabase/migrations/*.sql` headers — each has a gated rollback
  block).

---

## 8. Keystore discipline — lose this, lose the app

The upload keystore is **the** identity anchor for the app on Play
Store. Losing it means you cannot ship any future update — you'd have
to publish as a new package name and ask every user to reinstall.

- [ ] Back up `*.jks` files in a secure place (password manager vault,
  encrypted cloud, hardware key store) — not in git, not on a shared
  drive.
- [ ] Back up `key.properties` with matching passwords.
- [ ] Document who on the team has access, and rotate access on leavers.
- [ ] Optional: enable Google Play App Signing. Once enabled, Google
  manages a second signing key and you only need to keep the upload
  key safe. Recommended for long-term maintenance.

---

## Quick-reference session trail

Relevant recent sessions (full details in `docs/sessions/FIX_SESSION_LOG.md`):

- Session 46 (2026-04-24) — customer_app CurrencyFormatter vendored.
- Session 52 (2026-04-25) — expense push payload int cents.
- Session 53 (2026-04-25) — sale + invoice push P0 (critical; any
  earlier release was accumulating dead-lettered pushes).
- Session 54 (2026-04-25) — qty DOUBLE PRECISION Supabase alignment.
- Session 55 (2026-04-25) — this prep work; driver_app Android
  hardening parity brought in line with customer_app.
