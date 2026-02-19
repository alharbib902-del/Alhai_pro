# Security Review Report - Alhai POS App

**Date:** 2026-02-15
**Scope:** `lib/screens/auth/`, `lib/core/security/`, `lib/core/network/`, `lib/services/`, `lib/providers/auth_providers.dart`
**Focus:** API keys, hardcoded secrets, input validation, auth flows, data encryption

---

## Severity Legend

| Level | Description |
|-------|-------------|
| **CRITICAL** | Exploitable in production, immediate fix required |
| **HIGH** | Significant risk, fix before release |
| **MEDIUM** | Should be addressed, defense-in-depth concern |
| **LOW** | Minor issue or best-practice improvement |
| **INFO** | Observation, no action required |

---

## 1. CRITICAL Issues

### 1.1 Hardcoded Default Manager PIN

**File:** `lib/services/manager_approval_service.dart:44`
**Severity:** CRITICAL

```dart
static Future<bool> requestApprovalWithLocalVerification({
  required BuildContext context,
  required String action,
  String? description,
  String expectedPin = '1234', // PIN افتراضي للاختبار
}) async {
```

The `requestManagerApprovalFor` extension method (line 151) calls this directly, meaning any caller using the extension in production would use `1234` as the manager PIN. This grants manager-level access (void sales, refunds, price modifications, data exports) to anyone who knows the default.

**Recommendation:** Remove the default value. Require server-side PIN verification via `onVerify` callback in all code paths. Delete the `requestApprovalWithLocalVerification` method or gate it behind `kDebugMode`.

---

### 1.2 OTP Hash Without Salt (Brute-Forceable)

**File:** `lib/services/whatsapp_otp_service.dart:401-405`
**Severity:** CRITICAL

```dart
static String _hashOtp(String otp) {
  final bytes = utf8.encode(otp);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
```

OTP is 6 digits (1,000,000 possibilities). SHA-256 without salt means the hash can be brute-forced in milliseconds if the stored hash is accessed (e.g., via device backup, secure storage export, or memory dump). An attacker with access to the hash doesn't need to intercept the WhatsApp message.

**Recommendation:** Add a per-session random salt to the OTP hash, or better yet, move OTP verification entirely server-side.

---

## 2. HIGH Issues

### 2.1 Client-Side OTP Generation & Verification

**Files:** `lib/services/whatsapp_otp_service.dart`, `lib/core/security/otp_service.dart`
**Severity:** HIGH

The entire OTP lifecycle (generation, storage, verification) happens on the client:

1. Client generates OTP (line 392)
2. Client sends OTP to user via WhatsApp API (line 253)
3. Client stores OTP hash locally (line 272)
4. Client verifies OTP against local hash (line 338)

An attacker with device access can bypass authentication by:
- Reading the OTP hash from secure storage and brute-forcing it (see 1.2)
- Clearing app data to reset rate limiting
- Intercepting the API call to extract the plaintext OTP from the request body

The `otp_service.dart` file itself documents this limitation (lines 11-17), which is good awareness, but the issue remains unresolved.

**Recommendation:** Implement server-side OTP generation and verification. The client should only relay the user-entered OTP to the server for verification.

---

### 2.2 XOR Encryption Masquerading as AES-256-GCM

**File:** `lib/core/security/web_encryption_service.dart:322-337`
**Severity:** HIGH

```dart
/// تشفير/فك تشفير XOR (تطبيق مبسط)
/// ⚠️ في الإنتاج، استخدم AES-GCM عبر Web Crypto API
static Future<Uint8List> _xorEncrypt(
  Uint8List data, Uint8List key, Uint8List iv,
) async {
  final keystream = _generateKeystream(key, iv, data.length);
  final result = Uint8List(data.length);
  for (var i = 0; i < data.length; i++) {
    result[i] = data[i] ^ keystream[i];
  }
  return result;
}
```

The `EncryptionConfig` enum advertises `aes256Gcm` but the actual implementation is XOR with HMAC-derived keystream. While the HMAC auth tag provides integrity, the confidentiality is weaker than true AES-GCM. The keystream generation reuses the same HMAC key for every block, which can leak information about the key.

**Recommendation:** Use the `webcrypto` package or `dart:js_interop` to access the browser's native Web Crypto API for actual AES-256-GCM encryption on web.

---

### 2.3 PIN Hash Comparison Not Constant-Time

**File:** `lib/core/security/pin_service.dart:156`
**Severity:** HIGH

```dart
if (inputHash == savedHash) {
```

Standard Dart string equality (`==`) is not constant-time. It short-circuits on the first differing character, making it vulnerable to timing attacks. An attacker making repeated requests can progressively determine the correct hash by measuring response times.

Note: Other services (CSRF, request signer, web encryption) correctly use constant-time comparison, but `PinService` does not.

**Recommendation:** Implement constant-time comparison:
```dart
if (_constantTimeEquals(inputHash, savedHash)) {
```

---

## 3. MEDIUM Issues

### 3.1 Client-Side Rate Limiting Only

**Files:** `lib/services/whatsapp_otp_service.dart`, `lib/core/security/otp_service.dart`, `lib/core/security/rate_limiter.dart`
**Severity:** MEDIUM

All rate limiting (OTP sends, login attempts, API calls) is enforced client-side using in-memory maps. This can be bypassed by:
- Reinstalling the app
- Clearing app data
- Using multiple devices
- Modifying the app binary

The code documents this limitation (otp_service.dart lines 11-17) but it remains unaddressed.

**Recommendation:** Implement server-side rate limiting using Redis or similar. Client-side limiting is useful for UX but should not be the only layer.

---

### 3.2 Dev Mode OTP Exposure Risk

**Files:** `lib/services/whatsapp_otp_service.dart:222-248`, `lib/screens/auth/login_screen.dart:95-126`
**Severity:** MEDIUM

In dev mode:
1. OTP is printed to console in plaintext (line 229)
2. OTP is returned as `devOtp` in the result object (line 247)
3. OTP is displayed in a SnackBar on screen for 30 seconds (line 121)

If `TEST_MODE` is accidentally set to `true` in a production build via `--dart-define=TEST_MODE=true`, OTP would be exposed to anyone watching the screen. The flag check is:
```dart
static bool get isDevMode => kDebugMode || _testMode;
```

**Recommendation:** Remove `_testMode` from `isDevMode` check. Only rely on `kDebugMode` which is automatically `false` in release builds. For testing in release mode, use a separate test endpoint.

---

### 3.3 Weak Request ID Generation

**File:** `lib/core/network/security_interceptor.dart:163-166`
**Severity:** MEDIUM

```dart
String _generateRequestId() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final random = timestamp.hashCode.abs() % 10000;
  return '$timestamp-$random';
}
```

`hashCode` is deterministic for the same timestamp, making request IDs predictable. This weakens request tracing and could enable replay attacks if request IDs are used for deduplication.

**Recommendation:** Use `Random.secure()` or a UUID package for request ID generation.

---

### 3.4 Certificate Pinning Disabled on Web

**File:** `lib/core/network/secure_http_client.dart:60`
**Severity:** MEDIUM

```dart
if (!kIsWeb && certificateFingerprint != null && certificateFingerprint.isNotEmpty) {
  _applyCertificatePinning(dio, certificateFingerprint);
}
```

Certificate pinning is skipped entirely on web platform. While browsers handle their own certificate validation, this means the web version has no protection against compromised CAs or MITM proxies that install their own root certificates.

**Recommendation:** For web, consider using Subresource Integrity (SRI) and strict CSP headers. Document this as an accepted risk for web deployments.

---

### 3.5 Silent Storage Error Handling

**File:** `lib/services/whatsapp_otp_service.dart:480, 499-501`
**Severity:** MEDIUM

```dart
static Future<void> _saveOtpToStorage(OtpData data) async {
  try {
    // ...
  } catch (_) {
    // تجاهل أخطاء التخزين
  }
}
```

Storage errors are silently swallowed. If OTP data fails to persist, the user may enter a correct OTP but verification fails because the data was lost. This creates a confusing UX and could lock users out.

**Recommendation:** Log storage errors and fall back to in-memory cache with a warning.

---

## 4. LOW Issues

### 4.1 Session Duration Managed Client-Side Only

**Files:** `lib/providers/auth_providers.dart:18`, `lib/core/security/session_manager.dart:36`
**Severity:** LOW

Session expiry is set to 30 minutes purely on the client. If the server has a different session duration, there could be mismatches where the client thinks the session is valid but the server rejects requests.

**Recommendation:** Derive session expiry from the server response (e.g., JWT `exp` claim or response header).

---

### 4.2 CSRF Token In-Memory Only

**File:** `lib/core/security/csrf_protection.dart:18-19`
**Severity:** LOW

CSRF tokens are stored in static variables and lost on app restart. This is acceptable for a mobile/desktop app but means any pending request after a hot restart will fail with CSRF errors.

**Recommendation:** Acceptable for current architecture. Consider persisting to secure storage if CSRF failures after restart become a UX issue.

---

### 4.3 Legacy SHA-256 PIN Support

**File:** `lib/core/security/pin_service.dart:151-153`
**Severity:** LOW

```dart
} else {
  // الإصدار القديم (SHA256) - للتوافق مع الـ PINs القديمة
  inputHash = _hashPinLegacy(pin);
}
```

The legacy SHA-256 (no salt) PIN verification is still supported for backwards compatibility. While migration to PBKDF2 happens automatically on successful login (line 160), users who haven't logged in since the upgrade remain on the weaker scheme.

**Recommendation:** After a reasonable migration period, force PIN reset for users still on v1.

---

## 5. Positive Findings (Strengths)

### 5.1 No Hardcoded API Keys or Secrets
All sensitive credentials use `String.fromEnvironment()` with no default values:
- `WASENDER_API_TOKEN` (whatsapp_config.dart:27)
- `WASENDER_DEVICE_ID` (whatsapp_config.dart:34)
- `WASENDER_PHONE` (whatsapp_config.dart:41)
- `SUPABASE_CERT_FINGERPRINT` (secure_http_client.dart:24)
- `WASENDER_CERT_FINGERPRINT` (secure_http_client.dart:30)

### 5.2 Proper Secure Storage Usage
`FlutterSecureStorage` with platform-specific configuration:
- Android: `encryptedSharedPreferences: true` (secure_storage_service.dart:24-26)
- iOS: `KeychainAccessibility.first_unlock_this_device` (secure_storage_service.dart:27-29)
- Database encryption key generated with `Random.secure()` (secure_storage_service.dart:214)

### 5.3 Strong PIN Hashing (v2)
- PBKDF2 with HMAC-SHA256 (pin_service.dart:258-295)
- 100,000 iterations (pin_service.dart:33)
- 32-byte random salt (pin_service.dart:29-30)
- 32-byte derived key (pin_service.dart:36)
- Version migration support (pin_service.dart:160)

### 5.4 Comprehensive Input Sanitization
- SQL injection patterns (input_sanitizer.dart:49-56)
- XSS patterns (input_sanitizer.dart:58-67)
- Path traversal patterns (input_sanitizer.dart:69-75)
- Command injection patterns (input_sanitizer.dart:77-83)
- NoSQL injection patterns (input_sanitizer.dart:85-93)
- Weak PIN detection (input_sanitizer.dart:335-353)

### 5.5 HTTPS Everywhere
All external API calls use HTTPS:
- WaSenderAPI: `https://www.wasenderapi.com/api` (whatsapp_config.dart:23)
- WaSender v2: `https://api.wasenderapi.com/api/v1` (secure_http_client.dart:198)

### 5.6 Certificate Pinning (Native)
SHA-256 fingerprint verification on native platforms (secure_http_client.dart:74-100).

### 5.7 CSRF Protection with Constant-Time Comparison
Token generation with secure random + SHA-256 and timing-attack-safe validation (csrf_protection.dart:28-97).

### 5.8 Request Signing
HMAC-SHA256 signatures with timestamp and nonce for replay attack prevention (request_signer.dart:41-78).

### 5.9 Advanced Rate Limiting Architecture
Token Bucket and Sliding Window algorithms with escalating block durations (rate_limiter.dart).

### 5.10 Sensitive Data Masking in Logs
Both `ProductionLogger` and `AuditTrail` mask sensitive keys (password, pin, token, secret, cvv, card_number) before logging.

### 5.11 Security Headers on HTTP Requests
Cache-Control, Pragma, Request-ID, and Client-Version headers added automatically (security_interceptor.dart:145-159).

---

## 6. Summary Table

| # | Issue | Severity | Status |
|---|-------|----------|--------|
| 1.1 | Hardcoded default manager PIN `1234` | CRITICAL | Open |
| 1.2 | OTP hash without salt (brute-forceable) | CRITICAL | Open |
| 2.1 | Client-side OTP generation & verification | HIGH | Open |
| 2.2 | XOR encryption instead of AES-256-GCM | HIGH | Open |
| 2.3 | PIN hash comparison not constant-time | HIGH | Open |
| 3.1 | Client-side rate limiting only | MEDIUM | Open |
| 3.2 | Dev mode OTP exposure risk via TEST_MODE | MEDIUM | Open |
| 3.3 | Weak request ID generation | MEDIUM | Open |
| 3.4 | Certificate pinning disabled on web | MEDIUM | Accepted |
| 3.5 | Silent storage error handling | MEDIUM | Open |
| 4.1 | Session duration client-side only | LOW | Open |
| 4.2 | CSRF token in-memory only | LOW | Accepted |
| 4.3 | Legacy SHA-256 PIN support | LOW | Open |

---

## 7. Priority Action Items

1. **Immediate:** Remove hardcoded PIN `1234` from `ManagerApprovalService` (CRITICAL)
2. **Immediate:** Add salt to OTP hashing or move to server-side verification (CRITICAL)
3. **Before Release:** Fix PIN constant-time comparison in `PinService` (HIGH)
4. **Before Release:** Replace XOR encryption with Web Crypto API (HIGH)
5. **Before Release:** Plan server-side OTP verification architecture (HIGH)
6. **Short-term:** Remove `_testMode` from `isDevMode` check (MEDIUM)
7. **Short-term:** Fix request ID generation to use secure random (MEDIUM)
8. **Medium-term:** Implement server-side rate limiting (MEDIUM)

---

## الملخص التنفيذي بالعربية

### نظرة عامة

تم إجراء مراجعة أمنية شاملة لتطبيق الحي POS تغطي مجلدات المصادقة والشبكة والأمان والخدمات. فحصنا **44 ملفاً** تتضمن خدمات المصادقة، التشفير، حماية الشبكة، والتحقق من المدخلات.

### النتائج الرئيسية

**التطبيق يتمتع ببنية أمنية جيدة بشكل عام**، مع عدة نقاط قوة ملحوظة:
- لا توجد مفاتيح API أو أسرار مشفرة في الكود (كلها تُمرر عبر `--dart-define`)
- استخدام `FlutterSecureStorage` مع إعدادات خاصة بكل منصة
- تشفير PIN باستخدام PBKDF2 مع 100,000 تكرار و salt عشوائي
- تنظيف شامل للمدخلات ضد SQL Injection و XSS وغيرها
- جميع الاتصالات عبر HTTPS مع Certificate Pinning

### المشاكل التي تتطلب اهتماماً فورياً

1. **رمز PIN افتراضي `1234` مشفر في الكود** (خطورة حرجة): خدمة موافقة المدير تستخدم PIN ثابت `1234` كقيمة افتراضية، مما يسمح لأي شخص بتنفيذ عمليات حساسة مثل إلغاء الفواتير والاسترجاع وتعديل الأسعار. يجب إزالته فوراً.

2. **تشفير OTP بدون salt** (خطورة حرجة): رمز OTP المكون من 6 أرقام يُشفر بـ SHA-256 بدون salt، مما يجعله قابلاً للكسر في أجزاء من الثانية إذا تم الوصول للـ hash المخزن.

3. **التحقق من OTP يتم على جهاز العميل فقط** (خطورة عالية): دورة حياة OTP كاملة (التوليد، الإرسال، التحقق) تتم على الجهاز دون تحقق من الخادم، مما يفتح ثغرات متعددة.

4. **تشفير XOR بدلاً من AES-256-GCM** (خطورة عالية): خدمة تشفير الويب تدّعي استخدام AES-256-GCM لكنها تستخدم XOR مع keystream مشتق من HMAC، وهو أضعف بكثير.

5. **مقارنة hash الـ PIN غير آمنة ضد هجمات التوقيت** (خطورة عالية): يستخدم المقارنة العادية (`==`) بدلاً من المقارنة ثابتة الوقت.

### التوصيات

- **فوري**: إزالة PIN الافتراضي وإضافة salt لتشفير OTP
- **قبل الإطلاق**: إصلاح مقارنة PIN واستبدال تشفير XOR بـ Web Crypto API
- **على المدى القصير**: نقل التحقق من OTP للخادم وتطبيق rate limiting على مستوى الخادم

### التقييم النهائي

البنية الأمنية الأساسية للتطبيق **متينة ومدروسة**، مع وجود **مشكلتين حرجتين** و**3 مشاكل عالية الخطورة** تحتاج معالجة قبل إطلاق الإصدار الإنتاجي. معظم المشاكل المكتشفة تتعلق بالاعتماد على التحقق من جانب العميل فقط، وهو أمر طبيعي في المراحل الأولى من التطوير لكنه يحتاج لتعزيز بتحقق من جانب الخادم قبل الاستخدام التجاري.
