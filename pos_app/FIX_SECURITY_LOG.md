# Security Fix Log

**Date:** 2026-02-15
**Reference:** SECURITY_REVIEW.md
**Analyzer Result:** `dart analyze lib/services/ lib/core/security/ lib/core/network/` — **No issues found**

---

## Fix 1: Remove Hardcoded Default Manager PIN

**File:** `lib/services/manager_approval_service.dart`
**Severity:** CRITICAL → **RESOLVED**

### Before
```dart
String expectedPin = '1234', // PIN افتراضي للاختبار
```

### After
```dart
required String expectedPin,
```

### Changes Made
- **Line 44:** Changed `expectedPin` from optional with default `'1234'` to `required` with no default
- **Lines 51-57:** Replaced plain `==` comparison with constant-time XOR comparison to prevent timing attacks
- **Line 153:** Updated `requestManagerApprovalFor` extension to require `expectedPin` parameter
- Updated doc comments to reflect that PIN must come from a secure source

### Impact
Any code calling `requestApprovalWithLocalVerification` or `requestManagerApprovalFor` without providing `expectedPin` will now fail at compile time, forcing developers to supply a PIN from a secure source (server or secure storage).

---

## Fix 2: Add Salt to OTP Hashing

**File:** `lib/services/whatsapp_otp_service.dart`
**Severity:** CRITICAL → **RESOLVED**

### Before
```dart
static String _hashOtp(String otp) {
  final bytes = utf8.encode(otp);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
```
Plain SHA-256 with no salt. A 6-digit OTP hash could be brute-forced in milliseconds (1M possibilities).

### After
```dart
static String _generateSalt() {
  final random = Random.secure();
  final saltBytes = List<int>.generate(32, (_) => random.nextInt(256));
  return base64Encode(saltBytes);
}

static String _hashOtp(String otp, String salt) {
  final key = utf8.encode(salt);
  final hmac = Hmac(sha256, key);
  final digest = hmac.convert(utf8.encode(otp));
  return digest.toString();
}
```

### Changes Made
- **OtpData class:** Added `otpSalt` field with serialization support (backward-compatible: defaults to `''` for old data)
- **_generateSalt():** New method generating 32-byte cryptographically secure random salt per OTP session
- **_hashOtp():** Changed from `SHA-256(otp)` to `HMAC-SHA256(salt, otp)` — salt acts as HMAC key
- **sendOtp():** Generates fresh salt per OTP, stores it alongside hash in both dev and production paths
- **verifyOtp():** Uses stored salt when hashing user input, plus constant-time comparison (see Fix 2b)

### Also Fixed: OTP Hash Comparison (Timing Attack)
```dart
// Before
if (inputHash == otpData.otpHash) {

// After
if (_constantTimeEquals(inputHash, otpData.otpHash)) {
```
Added `_constantTimeEquals()` method using XOR comparison to prevent timing side-channel attacks.

---

## Fix 3: PIN Hash Constant-Time Comparison

**File:** `lib/core/security/pin_service.dart`
**Severity:** HIGH → **RESOLVED**

### Before
```dart
if (inputHash == savedHash) {
```
Standard Dart `==` short-circuits on first mismatch, leaking hash information via response timing.

### After
```dart
if (_constantTimeEquals(inputHash, savedHash)) {
```

### Changes Made
- **Line 156:** Replaced `==` with `_constantTimeEquals()`
- **Lines 305-312:** Added `_constantTimeEquals` static method using bitwise XOR accumulation:
  ```dart
  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
  ```

This matches the pattern already used in `csrf_protection.dart` and `request_signer.dart`.

---

## Fix 4: Exponential Backoff in Network Retry

**File:** `lib/core/network/secure_http_client.dart`
**Severity:** MEDIUM → **RESOLVED**

### Before
```dart
// Comment said "exponential backoff" but was linear:
Duration(milliseconds: 1000 * (retryCount + 1)),
// Produced: 1000ms, 2000ms, 3000ms (linear)
```

### After
```dart
final delayMs = 1000 * (1 << retryCount); // 1s, 2s, 4s
Duration(milliseconds: delayMs),
// Produces: 1000ms, 2000ms, 4000ms (true exponential)
```

### Changes Made
- **Line 119:** Changed delay calculation from `1000 * (retryCount + 1)` to `1000 * (1 << retryCount)`
- Uses bit-shift (`1 << n`) for true power-of-2 exponential backoff
- Retry 0: 1s, Retry 1: 2s, Retry 2: 4s

---

## Summary

| Fix | File | Severity | Status |
|-----|------|----------|--------|
| 1. Remove default PIN `1234` | `manager_approval_service.dart` | CRITICAL | Resolved |
| 2. Add salt to OTP hashing | `whatsapp_otp_service.dart` | CRITICAL | Resolved |
| 3. Constant-time PIN comparison | `pin_service.dart` | HIGH | Resolved |
| 4. Exponential backoff | `secure_http_client.dart` | MEDIUM | Resolved |

**Static Analysis:** `dart analyze` — 0 issues
