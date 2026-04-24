# Certificate Pin Rotation / دليل تدوير بصمات الشهادة

Applies to `alhai_core/lib/src/security/certificate_pinning_service.dart`,
consumed by `apps/cashier` (Phase 4 §4.1), `apps/admin`, `apps/admin_lite`,
`customer_app`, `driver_app`.

## Why we pin / لماذا نثبت البصمات

We pin the **Supabase TLS endpoint** so a compromised or rogue Certificate
Authority cannot MITM our clients even if the device trusts it. The app
hashes the server's DER-encoded leaf certificate, base64-encodes it, and
compares against a hardcoded list — anything else is rejected in release
builds (fail-closed).

نثبّت شهادة Supabase لمنع هجمات MITM حتى في حال ثقة الجهاز بمرجع
تصديق مخترق. أي شهادة غير مطابقة تُرفض في بنى الإصدار.

## How to obtain a pin hash / كيفية استخراج البصمة

```bash
openssl s_client -servername <project>.supabase.co \
  -connect <project>.supabase.co:443 -showcerts </dev/null 2>/dev/null \
  | openssl x509 -outform DER \
  | openssl dgst -sha256 -binary \
  | base64
```

The output is the exact `String.fromEnvironment` value to inject — it is
**SHA-256 of the full DER cert**, not the SPKI sub-public-key, and not
the colon-hex format printed by `openssl x509 -fingerprint`.

## Injecting pins at build time / حقن البصمات عند البناء

Up to ten numbered slots are supported. Set the ones you need and leave
the rest empty — non-empty slots are collected, trimmed, deduplicated:

```bash
flutter build apk --release \
  --dart-define=SUPABASE_CERT_FINGERPRINT_1=<current-leaf-b64> \
  --dart-define=SUPABASE_CERT_FINGERPRINT_2=<intermediate-b64> \
  --dart-define=SUPABASE_CERT_FINGERPRINT_3=<next-leaf-b64>
```

Add `_4`, `_5`, … `_10` in CI secrets when you need more headroom. No
code change required — just rebuild.

## Backward compatibility / التوافق الخلفي

Legacy variables `SUPABASE_CERT_FINGERPRINT` and
`SUPABASE_CERT_FINGERPRINT_BACKUP` are still honoured. They take effect
**only when all numbered slots are empty**. Pipelines that set the
legacy variables continue to work unchanged; there is no deprecation
cutoff. When migrating, move to numbered slots and drop the legacy two
in the same release.

Precedence (first match wins):
1. Any non-empty value in `_1 … _10` → use those, ignore legacy.
2. Else → `SUPABASE_CERT_FINGERPRINT`, `SUPABASE_CERT_FINGERPRINT_BACKUP`.
3. Else → empty list → fail-closed in release (throws `StateError`).

## Recommended rotation procedure / إجراء التدوير الموصى به

Assume the current primary pin is in slot `_1` and expires in `T` days.

- **T − 6 months:** obtain the next-generation pin (rotating leaf, or
  fresh intermediate). Add it to the next free slot (e.g. `_3`) in CI
  secrets. Ship a release. Both old and new pins are now accepted.
- **T − 0 (rotation day):** server begins serving the new cert.
  Both existing released builds keep working because they already trust
  the new pin.
- **T + 3 months:** ship a release that removes the expired pin from CI
  secrets. Minimum supported build now only trusts current + next pins.

Keep at least **two live pins in every shipped build** so one rotation
never bricks clients.

Calendar reminder: query `openssl s_client | openssl x509 -noout -dates`
on the Supabase host quarterly and confirm the expected rotation date.

## Diagnostic output / الخرج التشخيصي

`CertificatePinningService.diagnosticStatus` returns one of:

- `ACTIVE (N pin(s))` — release, N ≥ 1 pins resolved.
- `NOT CONFIGURED (no pins)` — release with no pins (client throws on
  creation).
- `DISABLED (debug mode, N pin(s) configured)` — debug build.
- `DISABLED (debug mode, no pins)` — debug build, no pins.

`CertificatePinningService.pinCount` returns the resolved count for
structured logging / Sentry tags.

## Pre-flight checklist / قائمة التحقق قبل الإصدار

- [ ] Current leaf fingerprint obtained with the openssl pipeline above.
- [ ] Next fingerprint (intermediate or next leaf) obtained and differs
      from the current one.
- [ ] Both pasted into CI secrets under `SUPABASE_CERT_FINGERPRINT_1`
      and `SUPABASE_CERT_FINGERPRINT_2` (or the next free slots).
- [ ] Release build smoke-tested — confirm
      `[CertificatePinning] Accepted pinned certificate for ...` in
      logs. If you see `REJECTED certificate` or `No pinned
      fingerprints configured`, abort and re-verify the pin.
- [ ] Calendar reminder set ~30 days before current leaf expiry so the
      next rotation lands before users hit a hard failure.
- [ ] Rollback build with the previous pin set still available in the
      distribution channel.

**Never commit real fingerprints to the repo.** Keep `.env.example`
placeholders; real values live in the CI secret store and are injected
via `--dart-define` at build time.
