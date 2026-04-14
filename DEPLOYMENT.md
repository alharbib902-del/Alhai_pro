# Deployment Guide / دليل النشر

Instructions for building, configuring, and deploying Alhai Platform apps.

> For the full detailed guide, see [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md).

---

## 1. Environments / البيئات

| Environment     | Purpose            | Domain              |
|-----------------|--------------------|---------------------|
| **Development** | Local development  | `localhost`         |
| **Staging**     | QA and testing     | `staging.alhai.store` |
| **Production**  | Live users         | `alhai.store`       |

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

Passed at build time via `--dart-define` flags:

| Variable            | Required | Description                              |
|---------------------|----------|------------------------------------------|
| `SUPABASE_URL`      | Yes      | Supabase project URL                     |
| `SUPABASE_ANON_KEY` | Yes      | Supabase anonymous (public) key          |
| `ENV`               | Yes      | `development`, `staging`, or `production`|
| `SENTRY_DSN`        | No       | Sentry error tracking DSN               |
| `AI_SERVER_URL`     | No       | FastAPI AI server URL (Railway)          |

### GitHub Actions Secrets

Configure in Settings > Secrets and variables > Actions:

- `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SENTRY_DSN`
- `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD` (Android signing)

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
cd apps/cashier
flutter build apk --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=ENV=production
```

Via Melos: `melos run build:cashier:apk` or `melos run build:lite:apk`

### Android App Bundle (AAB) -- for Play Store

```bash
cd apps/cashier
flutter build appbundle --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

### iOS IPA

```bash
cd apps/cashier
flutter build ipa --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
# Upload to App Store Connect via Transporter or Xcode
```

### Web

```bash
cd apps/cashier
flutter build web --no-tree-shake-icons \
  --dart-define=ENV=production \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

Via Melos: `melos run build:admin:web`

### Build All

```bash
melos run build:all    # Builds cashier APK, admin web, admin_lite APK
```

---

## 5. Supabase Setup / اعداد Supabase

1. Create a new Supabase project at https://supabase.com
2. Run the base schema: `supabase/supabase_init.sql`
3. Run migrations in chronological order from `supabase/migrations/`
4. Bootstrap the first super_admin user:
   ```sql
   UPDATE public.users SET role = 'super_admin' WHERE id = '<user-uuid>';
   ```
5. Execute `supabase/sync_rpc_functions.sql` for sync stored procedures
6. Execute `supabase/storage_policies.sql` for Storage bucket permissions
7. Enable Realtime for: `orders`, `deliveries`, `driver_locations`, `notifications`

---

## 6. CI/CD Pipelines / انابيب التكامل المستمر

All workflows are in `.github/workflows/`:

| Workflow            | File                  | Trigger                        | Purpose                        |
|---------------------|-----------------------|--------------------------------|--------------------------------|
| **CI**              | `ci.yml`              | Push/PR to `main`, `develop`   | Analyze + format check + test  |
| **Build Android**   | `build-android.yml`   | After CI passes on `main`      | Build APKs for 5 mobile apps   |
| **Build iOS**       | `build-ios.yml`       | After CI passes on `main`      | Build iOS apps                 |
| **Build Web**       | `build-web.yml`       | After CI passes on `main`      | Build web apps                 |
| **Release**         | `release.yml`         | Tag `v*` or manual dispatch    | Build + deploy to staging/prod |

The Android workflow builds 5 apps in parallel via matrix strategy: cashier, admin, admin_lite, customer_app, driver_app.

---

## 7. Web Deployment / نشر الويب

### Cloudflare Pages (recommended)

```bash
cd apps/cashier
flutter build web --no-tree-shake-icons --dart-define=ENV=production
npx wrangler pages deploy build/web --project-name=alhai-cashier
```

Alternatively, upload `build/web/` to any static hosting provider (Vercel, Netlify, Firebase Hosting, S3).

---

## 8. AI Server Deployment / نشر خادم الذكاء الاصطناعي

The AI server (`ai_server/`) is a FastAPI application deployed on Railway:

```bash
cd ai_server
pip install -r requirements.txt
uvicorn main:app --reload --port 8000
```

Environment variables: `OPENAI_API_KEY`, `PORT` (set automatically by Railway).

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

### Monitoring
- [ ] Sentry DSN configured for error tracking
- [ ] Supabase dashboard monitoring active

### Security
- [ ] RLS policies verified on all tables
- [ ] API keys stored in GitHub Secrets (not in source)
- [ ] ZATCA certificates configured for e-invoicing (Saudi stores)
