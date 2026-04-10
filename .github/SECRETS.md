# Required GitHub Secrets

This document lists all secrets that must be configured in GitHub repo settings (Settings → Secrets and variables → Actions) before release builds will succeed.

## Android Signing

| Secret | Description | How to Generate |
|--------|-------------|-----------------|
| `KEYSTORE_BASE64` | Base64-encoded release keystore (.jks) | `base64 -i keystore.jks \| pbcopy` (macOS) or `base64 keystore.jks` (Linux) |
| `KEYSTORE_PASSWORD` | Keystore password | Set when generating keystore |
| `KEY_ALIAS` | Key alias within keystore | Set when generating keystore |
| `KEY_PASSWORD` | Key password (can be same as store) | Set when generating keystore |

### Generating the keystore (one time)
```bash
keytool -genkey -v -keystore alhai-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias alhai-release
```

## iOS Signing (Apple Developer account required)

| Secret | Description |
|--------|-------------|
| `IOS_CERTIFICATE_BASE64` | Base64-encoded .p12 distribution certificate |
| `IOS_CERTIFICATE_PASSWORD` | Password for the .p12 certificate |
| `PROVISIONING_PROFILE_BASE64` | Base64-encoded provisioning profile |
| `KEYCHAIN_PASSWORD` | Any password for temporary CI keychain (e.g., random string) |

## Supabase

| Secret | Description |
|--------|-------------|
| `SUPABASE_URL` | Production Supabase project URL |
| `SUPABASE_ANON_KEY` | Production anon key (safe for client, protected by RLS) |
| `SUPABASE_SERVICE_ROLE_KEY` | NEVER used in client builds — only for server-side functions |

## Certificate Pinning

| Secret | Description |
|--------|-------------|
| `SUPABASE_CERT_FINGERPRINT` | Supabase project SHA-256 cert fingerprint (current) |
| `SUPABASE_CERT_FINGERPRINT_BACKUP` | Backup fingerprint |
| `WASENDER_CERT_FINGERPRINT` | WaSender cert fingerprint (if used) |

Obtain Supabase fingerprint:
```bash
openssl s_client -connect <project>.supabase.co:443 < /dev/null 2>/dev/null | openssl x509 -fingerprint -sha256 -noout
```

## Crash Reporting (Sentry)

| Secret | Description |
|--------|-------------|
| `SENTRY_DSN_CASHIER` | Sentry project DSN for cashier app |
| `SENTRY_DSN_ADMIN` | Sentry DSN for admin app |
| `SENTRY_DSN_ADMIN_LITE` | Sentry DSN for admin_lite |
| `SENTRY_DSN_CUSTOMER` | Sentry DSN for customer_app |
| `SENTRY_DSN_DRIVER` | Sentry DSN for driver_app |
| `SENTRY_DSN_SUPER_ADMIN` | Sentry DSN for super_admin |
| `SENTRY_DSN_DISTRIBUTOR` | Sentry DSN for distributor_portal |

## Webhook Security (new)

| Secret | Description |
|--------|-------------|
| `WEBHOOK_SHARED_SECRET` | Shared secret for delivery-webhook and notify-driver Edge Functions |

Set the same value in Supabase Edge Function environment via:
```bash
supabase secrets set WEBHOOK_SHARED_SECRET=<random-long-string>
```

## Store Publishing (future)

| Secret | Description |
|--------|-------------|
| `GOOGLE_PLAY_JSON_KEY` | Google Play service account JSON (for upload-google-play action) |
| `APPLE_ID` | Apple Developer ID email |
| `APPLE_ID_PASSWORD` | App-specific password |
| `APPLE_TEAM_ID` | Apple Developer Team ID |
