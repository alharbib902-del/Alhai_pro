# Deployment Guide / دليل النشر

Instructions for building, configuring, and deploying Alhai Platform apps.

---

## 1. Environments / البيئات

| Environment  | Purpose                    | Supabase Project        | Domain              |
|--------------|----------------------------|-------------------------|---------------------|
| **Development** | Local development        | Local or dev project    | `localhost`         |
| **Staging**     | QA and testing           | Staging project         | `staging.alhai.store` |
| **Production**  | Live users               | Production project      | `alhai.store`       |

Environment is selected via `--dart-define=ENV=development|staging|production` at build time.

---

## 2. Prerequisites / المتطلبات

| Tool          | Version   | Installation                              |
|---------------|-----------|-------------------------------------------|
| Flutter       | >= 3.27   | https://docs.flutter.dev/get-started/install |
| Dart          | >= 3.4    | Bundled with Flutter                      |
| Melos         | >= 6.2    | `dart pub global activate melos`          |
| Java JDK      | 17        | https://adoptium.net/                     |
| Android SDK   | 34        | Via Android Studio                        |
| Xcode         | >= 15     | Mac App Store (iOS builds only)           |
| Node.js       | >= 18     | https://nodejs.org/ (E2E tests)           |
| Supabase CLI  | latest    | `npm install -g supabase`                 |

---

## 3. Environment Variables / متغيرات البيئة

These are passed at build time via `--dart-define` flags:

| Variable            | Required | Description                              |
|---------------------|----------|------------------------------------------|
| `SUPABASE_URL`      | Yes      | Supabase project URL                     |
| `SUPABASE_ANON_KEY` | Yes      | Supabase anonymous (public) key          |
| `ENV`               | Yes      | `development`, `staging`, or `production`|
| `SENTRY_DSN`        | No       | Sentry error tracking DSN               |
| `AI_SERVER_URL`     | No       | FastAPI AI server URL (Railway)          |

### GitHub Actions Secrets

Configure these in the repository settings under Settings > Secrets and variables > Actions:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SENTRY_DSN`
- `KEYSTORE_BASE64` (Android release signing)
- `KEYSTORE_PASSWORD`
- `KEY_ALIAS`
- `KEY_PASSWORD`

---

## 4. Building Apps / بناء التطبيقات

### Bootstrap First

```bash
dart pub global activate melos
melos bootstrap
melos run codegen    # Generate Drift, Injectable, Freezed code
```

### Android APK

```bash
# Single app
cd apps/cashier
flutter build apk --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=ENV=production

# Output: build/app/outputs/flutter-apk/app-release.apk
```

Via Melos:
```bash
melos run build:cashier:apk
melos run build:lite:apk
```

### Android App Bundle (AAB) -- for Play Store

```bash
cd apps/cashier
flutter build appbundle --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY

# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS IPA

```bash
cd apps/cashier
flutter build ipa --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY

# Output: build/ios/ipa/cashier.ipa
# Upload to App Store Connect via Transporter or Xcode
```

### Web

```bash
cd apps/cashier
flutter build web --no-tree-shake-icons \
  --dart-define=ENV=production \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY

# Output: build/web/
```

Via Melos:
```bash
melos run build:admin:web
```

### Build All

```bash
melos run build:all    # Builds cashier APK, admin web, admin_lite APK
```

---

## 5. Supabase Setup / اعداد Supabase

### Initial Setup

1. Create a new Supabase project at https://supabase.com
2. Run the base schema:
   ```bash
   # From Supabase SQL Editor, execute:
   supabase/supabase_init.sql
   ```
3. Run migrations in order:
   ```bash
   # Execute each migration file in supabase/migrations/
   # in chronological order (20260115 -> 20260119 -> ... -> 20260401)
   ```
4. Bootstrap the first super_admin user manually:
   ```sql
   -- After a user signs up, promote them via SQL Editor:
   UPDATE public.users SET role = 'super_admin' WHERE id = '<user-uuid>';
   ```

### RPC Functions

Execute `supabase/sync_rpc_functions.sql` to create the sync-related stored procedures.

### Storage Policies

Execute `supabase/storage_policies.sql` to configure Supabase Storage bucket permissions for product images.

### Realtime

Enable Realtime for these tables in the Supabase dashboard (Database > Replication):
- `orders`
- `deliveries`
- `driver_locations`
- `notifications`

---

## 6. CI/CD Pipelines / انابيب التكامل المستمر

All workflows are in `.github/workflows/`:

| Workflow            | File                  | Trigger                        | Purpose                        |
|---------------------|-----------------------|--------------------------------|--------------------------------|
| **CI**              | `ci.yml`              | Push/PR to `main`, `develop`   | Analyze + format check + test  |
| **Flutter CI**      | `flutter_ci.yml`      | Push/PR to `main`, `develop`   | Analyze + test (alternate)     |
| **Build Android**   | `build-android.yml`   | After CI passes on `main`      | Build APKs for 5 mobile apps   |
| **Build iOS**       | `build-ios.yml`       | After CI passes on `main`      | Build iOS apps                 |
| **Build Web**       | `build-web.yml`       | After CI passes on `main`      | Build web apps                 |
| **Release**         | `release.yml`         | Tag `v*` or manual dispatch    | Build + deploy to staging/prod |

### CI Pipeline Flow

```
Push to main/develop
        |
        v
   [ci.yml] Analyze + Format Check
        |
        v
   [ci.yml] Test
        |
        v (on main only)
   +----+----+----+
   |         |    |
   v         v    v
 Android   iOS   Web
  Build   Build  Build
        |
        v (on tag v*)
   [release.yml]
   Build + Deploy
```

### Build Matrix (Android)

The Android workflow builds 5 apps in parallel via matrix strategy:
- `cashier` (apps/cashier)
- `admin` (apps/admin)
- `admin_lite` (apps/admin_lite)
- `customer_app` (customer_app)
- `driver_app` (driver_app)

---

## 7. Web Deployment / نشر الويب

### Cloudflare Pages (recommended)

```bash
# Build
cd apps/cashier
flutter build web --no-tree-shake-icons --dart-define=ENV=production

# Deploy
npx wrangler pages deploy build/web --project-name=alhai-cashier
```

### Firebase Hosting

```bash
firebase deploy --only hosting
```

### Manual Upload

Upload the contents of `build/web/` to any static hosting provider (Vercel, Netlify, S3, etc.).

---

## 8. AI Server Deployment / نشر خادم الذكاء الاصطناعي

The AI server (`ai_server/`) is a FastAPI application deployed on Railway:

```bash
# Local development
cd ai_server
pip install -r requirements.txt
uvicorn main:app --reload --port 8000

# Railway deployment
# Configured via Dockerfile and railway.toml in the repo
# Uses Railway PORT environment variable
```

Environment variables for AI server:
- `OPENAI_API_KEY` -- OpenAI API key
- `PORT` -- Set automatically by Railway

---

## 9. Post-Deployment Checklist / قائمة ما بعد النشر

### Database
- [ ] Base schema (`supabase_init.sql`) executed
- [ ] All migrations applied in order
- [ ] First super_admin user created
- [ ] RPC functions deployed
- [ ] Storage policies configured
- [ ] Realtime enabled for orders, deliveries, driver_locations, notifications

### Apps
- [ ] Environment variables configured (SUPABASE_URL, SUPABASE_ANON_KEY, ENV)
- [ ] Release builds use `--obfuscate --split-debug-info`
- [ ] Android signing keystore configured
- [ ] iOS certificates and provisioning profiles set up
- [ ] Web builds include CSP meta tags and X-Frame-Options: DENY

### Monitoring
- [ ] Sentry DSN configured for error tracking
- [ ] Firebase Analytics enabled (if applicable)
- [ ] Supabase dashboard monitoring active

### Security
- [ ] RLS policies verified on all tables
- [ ] API keys stored in GitHub Secrets (not in source)
- [ ] Debug info symbols archived for crash symbolication
- [ ] ZATCA certificates configured for e-invoicing (Saudi stores)
