# Cashier — Supabase Certificate Pinning

**Phase 4 §4.1** — تفعيل Certificate Pinning على تطبيق Cashier لحماية اتصالات
Supabase ضد هجمات MITM في الشبكات غير الموثوقة (Wi-Fi عامة، captive portals،
شهادات صادرة من CA مخترق).

> للتفاصيل الكاملة عن الخدمة المشتركة، إجراء التدوير، وقائمة التحقق قبل
> الإصدار، راجع الدليل المرجعي:
> [`docs/security/cert-pin-rotation.md`](security/cert-pin-rotation.md). هذا
> الملف يختصر ما يخص cashier فقط.

## ما الذي يحدث في التطبيق

عند `main.dart` قبل `Supabase.initialize`:

```dart
dynamic pinnedClient;
try {
  pinnedClient = CertificatePinningService.createPinnedClient();
} catch (e, st) {
  // release بلا pins → graceful fallback لا يمنع تهيئة Supabase
  reportError(e, stackTrace: st, hint: 'Certificate pinning init failed');
  pinnedClient = null;
}
await Supabase.initialize(
  url: SupabaseConfig.url,
  anonKey: SupabaseConfig.anonKey,
  httpClient: pinnedClient,
);
```

- **Debug build** — الخدمة تُرجع `IOClient` عادي بدون pinning (للسماح بأدوات
  الفحص مثل mitmproxy / Charles). إن كانت `SUPABASE_CERT_FINGERPRINT_1` مضبوطة
  في debug، تُطبع سجلات إعلامية فقط.
- **Release build مع pins** — `_PinnedClient` ينفّذ فحص SHA-256 للشهادة
  بعد الـ handshake ويُغلق الاتصال عند عدم التطابق (fail-closed).
- **Release build بدون pins** — الـ service يرمي `StateError`. الـ main.dart
  يمسكه ويُكمل التهيئة بـ HTTP client افتراضي + يُرسل الخطأ إلى Sentry. هذا
  سيناريو E2E CI أو أول release قبل نشر الـ secret — production-release
  الطبيعي يجب أن يكون دائماً مع pins مكوَّنة.

## كيفية استخراج SHA-256 fingerprint

راجع [دليل التدوير المرجعي](security/cert-pin-rotation.md#how-to-obtain-a-pin-hash).
باختصار:

```bash
openssl s_client -servername <project>.supabase.co \
  -connect <project>.supabase.co:443 -showcerts </dev/null 2>/dev/null \
  | openssl x509 -outform DER \
  | openssl dgst -sha256 -binary \
  | base64
```

المُخرَج هو القيمة الصحيحة لـ `--dart-define=SUPABASE_CERT_FINGERPRINT_N`
(SHA-256 للـ full DER، **ليس** SPKI ولا الصيغة hex colon-separated).

## كيفية إضافة Fingerprint كـ GitHub Secret

1. اذهب إلى `Settings → Secrets and variables → Actions` في repo الـ GitHub.
2. أضف secret بالاسم `SUPABASE_CERT_FINGERPRINT_1` وضع القيمة من الأمر
   أعلاه (base64 string).
3. كرّر لـ `SUPABASE_CERT_FINGERPRINT_2` (الشهادة التالية / intermediate) و
   `SUPABASE_CERT_FINGERPRINT_3` (headroom لدورة تدوير لاحقة).
4. أعد تشغيل الـ workflow المناسب (`Release Android (Play Store)` أو
   `Build Web`).

الـ workflows التالية تُحقن الـ pins تلقائياً:

- `.github/workflows/release-android.yml` — صياغة signed APK/AAB للـ Play
  Store (cashier + admin + admin_lite).
- `.github/workflows/build-android.yml` — بناء signed release APK+AAB للـ
  matrix الكامل. cashier يحصل على الـ pins من هنا.
- `.github/workflows/build-web.yml` — بناء web + نشر cashier على GitHub
  Pages. الـ pins تُمرَّر لكن الـ BrowserClient في flutter_web يستخدم
  fetch API للمتصفح، لذا طبقة IO pinning inert على الويب (محمي أصلاً بـ
  trust store للمتصفح + HSTS). الـ pins موجودة لتوحيد أوامر البناء مع
  native.
- `.github/workflows/release.yml` — build web لـ staging/production +
  GitHub Release tags.

## N-pin Rotation Policy

**اسكن ثلاثة pins في كل release مشحون:** `_1` (الـ leaf الحالي)، `_2` (الـ
intermediate أو الـ leaf التالي)، `_3` (next-generation headroom). هذا
يسمح بتدوير الشهادة بدون الحاجة لـ app update — الـ pins يُفحصن بترتيب
deduplicated مع دعم حتى 10 slots (`_1` إلى `_10`).

**الإجراء الموصى به** (مختصر من [الدليل المرجعي](security/cert-pin-rotation.md#recommended-rotation-procedure)):

- T − 6 months: أضف الـ pin الجديد إلى الـ slot التالي (مثلاً `_4` إذا كانت
  `_1.._3` مشغولة). شحن release. الـ pins الجديدة والقديمة كلها مقبولة.
- T = 0: server يبدأ بتقديم شهادة جديدة. الـ releases الحالية تستمر.
- T + 3 months: شحن release يُزيل الـ pin المنتهي من CI secrets. الحدّ الأدنى
  المدعوم يصبح current + next فقط.

**أبداً** لا تترك release واحد pin فقط — إذا فشل الـ rotation سيُعطل
الـ app على الأجهزة.

## التشخيص

في debug logs عند بدء التطبيق:

```
✅ Supabase initialized — cert pinning: ACTIVE (3 pin(s))
```

القيم المحتملة لـ `CertificatePinningService.diagnosticStatus`:

- `ACTIVE (N pin(s))` — release mode + N ≥ 1 pins.
- `NOT CONFIGURED (no pins)` — release بلا pins (graceful fallback يعمل).
- `DISABLED (debug mode, N pin(s) configured)` — debug + pins موجودة لكن
  معطَّلة لدعم mitmproxy.
- `DISABLED (debug mode, no pins)` — debug بلا pins.

عند رفض شهادة في release:

```
[CertificatePinning] REJECTED response from <host> (fingerprint mismatch)
```

الاتصال يُغلق والطلبات التالية تفشل. أي mismatch في production يُشير إلى:
- pin منتهي ولم يُحدَّث قبل rotation → شحن hotfix release مع pin جديد.
- MITM فعلي → حادثة أمنية.

## ممنوعات

- لا تُلصق الـ fingerprint الحقيقية في الـ repo أو `.env.example`. الـ القيم
  الحقيقية في CI secrets فقط.
- لا تُعطّل الـ pinning في production بتعديل `createPinnedClient()`. الـ
  graceful fallback في main.dart هو الطريقة الوحيدة المقبولة.
- لا تُضف pins غير صالحة فقط لـ "تجاوز الـ fail-closed" — `StateError`
  علامة على مشكلة إعداد يجب إصلاحها.

## الحالة الحالية (2026-04-23)

- ✅ `main.dart` يحقن `CertificatePinningService.createPinnedClient()` في
  `Supabase.initialize(httpClient:)`.
- ✅ Workflows: release-android, build-android, build-web, release.yml
  تُمرّر `SUPABASE_CERT_FINGERPRINT_1..3`.
- ⚠️ الـ GitHub Secrets الحقيقية (`SUPABASE_CERT_FINGERPRINT_1..3`) ليست
  مضبوطة بعد — أول release بعد هذا التغيير سيعمل بـ fallback (بدون
  pinning) ويُرسل تحذير Sentry. بعد ضبط الـ secrets والـ rebuild، الـ
  pinning ينشَّط تلقائياً.
