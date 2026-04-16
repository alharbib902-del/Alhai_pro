# Certificate Pinning — Fingerprint Rotation Guide

## Why this matters

Certificate pinning protects our mobile apps against man-in-the-middle attacks
even when a rogue Certificate Authority is trusted by the device OS. The apps
compare the server's TLS certificate against a hardcoded set of SHA-256
fingerprints and refuse any connection that does not match — so a rotation
procedure is required whenever an upstream TLS cert is renewed.

## Which apps enforce pinning

| App           | Service file                                                           | Backing env vars                                             |
| ------------- | ---------------------------------------------------------------------- | ------------------------------------------------------------ |
| Customer App  | `customer_app/lib/core/network/certificate_pinning_service.dart`       | `SUPABASE_CERT_FINGERPRINT`, `SUPABASE_CERT_FINGERPRINT_BACKUP` |
| Driver App    | `driver_app/lib/core/services/certificate_pinning_service.dart`        | `SUPABASE_CERT_FINGERPRINT`, `SUPABASE_CERT_FINGERPRINT_BACKUP` |

Pins are **injected at build time via `--dart-define`**; they are not read
from a runtime `.env` file. The env-example files document the variable names
so operators know what to pass to `flutter build`.

The expected value is the **base64-encoded SHA-256 of the DER-encoded
certificate** (the `sha256//` format used by RFC 7469 HPKP pinning), not the
colon-separated hex fingerprint that `openssl x509 -fingerprint` prints.

## How to obtain the SHA-256 fingerprint

Run this one-liner against each production host. It prints the pin value
exactly as it should be pasted into the build command:

```bash
echo | openssl s_client -servername <host> -connect <host>:443 2>/dev/null \
  | openssl x509 -pubkey -noout \
  | openssl pkey -pubin -outform der \
  | openssl dgst -sha256 -binary \
  | openssl enc -base64
```

Hosts to pin:

- Supabase REST + Realtime: `<your-project>.supabase.co`
- AI Server (if the client talks to it directly): `api.alhai.store`

Run the command twice — once for the **leaf** certificate (current) and once
against the chain's **intermediate** so you have a backup pin whose rotation
window is independent of the leaf's.

## When to rotate

Rotate the pinned fingerprints:

1. Before the current leaf certificate expires (Supabase typically renews
   every 60–90 days; check `openssl s_client | openssl x509 -noout -dates`).
2. Whenever Supabase or our CDN announces an infrastructure change that
   affects the TLS chain.
3. Immediately after any suspected key compromise.

Ship **at least two pins** (current + next) in every release so a rotation
never requires a forced client update.

## Where to paste the new fingerprints

Pins are passed as `--dart-define` flags at build time. They are read by the
`String.fromEnvironment` calls in each service:

- `customer_app/lib/core/network/certificate_pinning_service.dart` lines
  **50–57** (`_primaryFingerprint`, `_backupFingerprint`).
- `driver_app/lib/core/services/certificate_pinning_service.dart` lines
  **50–57** (`_primaryFingerprint`, `_backupFingerprint`).

Example release build:

```bash
flutter build apk --release \
  --dart-define-from-file=.env \
  --dart-define=SUPABASE_CERT_FINGERPRINT=<current-base64-sha256> \
  --dart-define=SUPABASE_CERT_FINGERPRINT_BACKUP=<next-base64-sha256>
```

Do **not** commit real fingerprints to the repo. The `.env.example` files
keep placeholder strings only; the real values live in the CI secret store
and are injected at build time.

## Pre-flight checklist before a production release

- [ ] Current Supabase leaf certificate fingerprint obtained with the
      `openssl` pipeline above.
- [ ] Backup fingerprint (intermediate or next leaf) obtained and verified
      to differ from the primary.
- [ ] Both fingerprints stored in the CI secret store under
      `SUPABASE_CERT_FINGERPRINT` and `SUPABASE_CERT_FINGERPRINT_BACKUP`.
- [ ] Release build of both Customer App and Driver App performed with the
      new `--dart-define` values.
- [ ] Smoke test: launch the release APK and confirm log line
      `[CertificatePinning] Accepted pinned certificate for ...` appears.
      If you see `REJECTED certificate` or `No pinned fingerprints
      configured`, stop the release — the pin is wrong.
- [ ] Calendar reminder set for ~30 days before the leaf cert expires so the
      next rotation lands before users hit a hard failure.
- [ ] Old-version rollback APK with the previous pins is still in the
      distribution channel in case the new pin set is incorrect.
