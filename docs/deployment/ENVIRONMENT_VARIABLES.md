# Environment Variables Reference

> **CRITICAL:** Never commit `.env` files, keystores, or API keys to git. All `.env` files are gitignored.

## Injection Method

All Flutter apps use `--dart-define-from-file=.env`:

```bash
flutter run --dart-define-from-file=.env
flutter build apk --release --dart-define-from-file=.env
flutter build web --release --dart-define-from-file=.env
```

Variables are read in Dart via `String.fromEnvironment('KEY')`. Missing variables return empty string — apps validate at startup and throw `StateError` if required vars are missing.

---

## Variable Reference

### Shared (All Apps)

| Variable | Required | Example | Description |
|----------|----------|---------|-------------|
| `SUPABASE_URL` | **Yes** | `https://xxxx.supabase.co` | Supabase project URL |
| `SUPABASE_ANON_KEY` | **Yes** | `eyJhbGci...` | Supabase anonymous/public key |
| `FLAVOR` | No | `dev` / `staging` / `prod` | App environment flavor |

### Customer App

| Variable | Required | Example | Description |
|----------|----------|---------|-------------|
| `SENTRY_DSN_CUSTOMER` | **Yes** (prod) | `https://xxx@sentry.io/yyy` | Sentry DSN for customer app |
| `SUPABASE_CERT_FINGERPRINT` | **Yes** (prod) | `base64string==` | Primary TLS certificate SHA-256 pin |
| `SUPABASE_CERT_FINGERPRINT_BACKUP` | Recommended | `base64string==` | Backup pin for cert rotation |

### Driver App

| Variable | Required | Example | Description |
|----------|----------|---------|-------------|
| `SENTRY_DSN_DRIVER` | **Yes** (prod) | `https://xxx@sentry.io/yyy` | Sentry DSN for driver app |
| `SUPABASE_CERT_FINGERPRINT` | **Yes** (prod) | `base64string==` | Primary TLS certificate SHA-256 pin |
| `SUPABASE_CERT_FINGERPRINT_BACKUP` | Recommended | `base64string==` | Backup pin for cert rotation |

### Distributor Portal

| Variable | Required | Example | Description |
|----------|----------|---------|-------------|
| `SENTRY_DSN_DISTRIBUTOR` | **Yes** (prod) | `https://xxx@sentry.io/yyy` | Sentry DSN for distributor portal |

> **Note:** Distributor portal (web) does not use certificate pinning — the browser handles TLS.

### Admin Apps (Not part of this deployment, for reference)

| Variable | Required | Description |
|----------|----------|-------------|
| `SENTRY_DSN_ADMIN` | Yes (prod) | Sentry DSN for admin app |
| `SENTRY_DSN_SUPER_ADMIN` | Yes (prod) | Sentry DSN for super admin |
| `AI_SERVER_URL` | No | AI report generation endpoint |
| `WASENDER_API_TOKEN` | No | WhatsApp OTP (WaSender) |
| `WASENDER_DEVICE_ID` | No | WaSender device ID |
| `WASENDER_PHONE` | No | WaSender phone number |
| `WASENDER_NAME` | No | Store name for WhatsApp |
| `WASENDER_WEBHOOK_SECRET` | No | WaSender webhook verification |

### AI Server (Python — not Flutter)

| Variable | Required | Description |
|----------|----------|-------------|
| `SUPABASE_URL` | Yes | Same Supabase project URL |
| `SUPABASE_SERVICE_ROLE_KEY` | Yes | Service role key (full access — server-side only!) |
| `JWT_SECRET` | Yes | Supabase JWT secret for token verification |
| `OPENAI_API_KEY` | Yes | OpenAI API key for AI features |
| `HOST` | No | Server host (default: `0.0.0.0`) |
| `PORT` | No | Server port (default: `8000`) |
| `DEBUG` | No | Debug mode (default: `false`) |
| `ALLOWED_ORIGINS` | No | CORS allowed origins |

---

## How to Generate Values

### Supabase URL and Anon Key

1. Go to https://supabase.com/dashboard
2. Select your project
3. Settings → API
4. Copy **Project URL** and **anon/public** key

### Sentry DSN

1. Go to https://sentry.io
2. Create a project (Flutter platform)
3. Settings → Client Keys (DSN)
4. Copy the DSN URL

### Certificate Pinning Fingerprint

```bash
# Replace <project> with your Supabase project ref or custom domain
openssl s_client \
  -connect <project>.supabase.co:443 \
  -servername <project>.supabase.co \
  < /dev/null 2>/dev/null \
  | openssl x509 -outform DER \
  | openssl dgst -sha256 -binary \
  | base64

# Output: something like "AAAA+BBBB/CCCC+DDDD/EEEE+FFFF/GGGG+HHHH/III="
```

> **Important:** Regenerate the backup fingerprint with a known future certificate or use the intermediate CA certificate pin for rotation safety.

### Google Maps API Key

1. Go to https://console.cloud.google.com
2. APIs & Services → Credentials → Create credentials → API key
3. Restrict to: Maps SDK for Android, Maps SDK for iOS
4. Restrict to your app's package name / bundle ID

---

## .env File Templates

### customer_app/.env

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SENTRY_DSN_CUSTOMER=https://examplekey@o123456.ingest.sentry.io/1234567
SUPABASE_CERT_FINGERPRINT=AAAA+BBBB/CCCC==
SUPABASE_CERT_FINGERPRINT_BACKUP=XXXX+YYYY/ZZZZ==
FLAVOR=prod
```

### driver_app/.env

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SENTRY_DSN_DRIVER=https://examplekey@o123456.ingest.sentry.io/7654321
SUPABASE_CERT_FINGERPRINT=AAAA+BBBB/CCCC==
SUPABASE_CERT_FINGERPRINT_BACKUP=XXXX+YYYY/ZZZZ==
FLAVOR=prod
```

### distributor_portal/.env

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SENTRY_DSN_DISTRIBUTOR=https://examplekey@o123456.ingest.sentry.io/1111111
FLAVOR=prod
```

---

## CI/CD Secrets

For GitHub Actions or similar CI:

```yaml
# .github/workflows/build.yml (example)
env:
  SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
  SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_ANON_KEY }}
  SENTRY_DSN_CUSTOMER: ${{ secrets.SENTRY_DSN_CUSTOMER }}
  # ... etc

steps:
  - name: Create .env
    run: |
      echo "SUPABASE_URL=$SUPABASE_URL" > .env
      echo "SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY" >> .env
      # ... etc

  - name: Build
    run: flutter build apk --release --dart-define-from-file=.env
```

---

## Security Notes

1. **Never use `service_role` key in client apps** — it bypasses RLS.
2. **Rotate keys periodically** — Supabase allows key regeneration in dashboard.
3. **Certificate pins expire** — monitor cert expiry and update pins before rotation.
4. **Sentry DSN is semi-public** — it allows sending events but not reading them. Still, don't expose unnecessarily.
5. **Store secrets in a password manager** or company vault (1Password, Bitwarden, AWS Secrets Manager).

---

*Last updated: April 16, 2026*
