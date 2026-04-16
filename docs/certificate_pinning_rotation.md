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

The apps compute `sha256(cert.der)` (see `_matchesPinnedFingerprint` in the
service files — it hashes `X509Certificate.der`, the FULL DER-encoded
certificate, NOT the SPKI subkey). The openssl pipeline that matches
exactly is:

```bash
echo | openssl s_client -servername <host> -connect <host>:443 -showcerts 2>/dev/null \
  | openssl x509 -outform DER \
  | openssl dgst -sha256 -binary \
  | openssl enc -base64
```

Hosts to pin:

- Supabase REST + Realtime: `<your-project>.supabase.co`
- AI Server (if the client talks to it directly): `api.alhai.store`
- POS web (if the client talks to it directly): `pos.alhai.store`

### Getting both primary AND backup pins from the full chain

For a chain of N certificates, save the stream and split them so you can
hash each one individually. Primary = intermediate (stable ~5 yrs).
Backup = either the root (most stable) or the leaf (current, rotates):

```bash
echo | openssl s_client -servername <host> -connect <host>:443 -showcerts 2>/dev/null > chain.txt
awk '/BEGIN CERTIFICATE/{n++} {print > "cert_" n ".pem"}' chain.txt

for i in 1 2 3; do
  [ -f cert_$i.pem ] || continue
  echo "Cert $i:"
  openssl x509 -in cert_$i.pem -noout -subject
  openssl x509 -in cert_$i.pem -outform DER | openssl dgst -sha256 -binary | openssl enc -base64
done
```

Cert 1 is the leaf, cert 2 is the intermediate, cert 3 is the root (if
the server sends it).

### Pinning strategy

- **Primary pin → intermediate cert** (~5 year stability, survives leaf
  rotation, recommended for any app you can't push-update instantly).
- **Backup pin → root cert** if the server sends it (~10 year stability),
  otherwise the current leaf (~60-90 day rotation).
- **Never pin only the leaf** for a published app — the next cert renewal
  will hard-break every installed build until you ship an update.

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
