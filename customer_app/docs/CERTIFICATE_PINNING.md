# Certificate Pinning — customer_app

## Overview

The customer app uses **TLS certificate pinning** to prevent MITM attacks on
Supabase API connections. The implementation lives in
`lib/core/network/certificate_pinning_service.dart` and is integrated into
Supabase initialization via `lib/core/supabase/supabase_client.dart`.

## Behavior

| Mode    | Pins configured | Behavior                              |
|---------|-----------------|---------------------------------------|
| Debug   | Any             | Pinning **disabled** (dev tools work) |
| Release | Yes             | Pinning **enforced** (fail-closed)    |
| Release | No              | **StateError** — app refuses to start |

## How to obtain the SHA-256 pin

```bash
openssl s_client \
  -connect <project>.supabase.co:443 \
  -servername <project>.supabase.co < /dev/null 2>/dev/null \
  | openssl x509 -outform DER \
  | openssl dgst -sha256 -binary \
  | base64
```

This gives you the **base64-encoded SHA-256 of the DER certificate** (RFC 7469
HPKP-style pin).

## Build with pins

```bash
flutter build apk --release \
  --dart-define=SUPABASE_CERT_FINGERPRINT=<primary_base64> \
  --dart-define=SUPABASE_CERT_FINGERPRINT_BACKUP=<backup_base64>
```

Both values are optional at build time, but at least one **must** be provided
for a release build or the app will crash at startup with a `StateError`.

## Rotation strategy

1. **Before** the current certificate expires, obtain the **new** certificate's
   fingerprint using the openssl command above.
2. Set the new fingerprint as `SUPABASE_CERT_FINGERPRINT_BACKUP` and keep the
   current one as `SUPABASE_CERT_FINGERPRINT`.
3. Ship an app update with both pins.
4. After the certificate rotates, promote the backup to primary and add the
   next upcoming certificate as the new backup.

Always keep **two** pins active to avoid lockout during rotation windows.

## Security properties

- **Fail-closed**: Release builds without pins refuse to start.
- **Constant-time comparison**: Fingerprint matching uses XOR-based comparison
  to prevent timing oracles.
- **Base64 / RFC 7469 format**: Same format used by HPKP and `curl --pinnedpubkey`.
- **Dual-pin support**: Primary + backup for seamless rotation.
