/// خدمة PIN Code - PIN Service
///
/// تُدير الدخول السريع برمز PIN
/// يستخدم PBKDF2 مع Salt لتشفير آمن
library;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'secure_storage_service.dart';

// ============================================================================
// CONSTANTS
// ============================================================================

/// الحد الأقصى للمحاولات الفاشلة
const int kMaxPinAttempts = 5;

/// مدة القفل (15 دقيقة)
const Duration kLockoutDuration = Duration(minutes: 15);

/// الحد الأدنى لطول PIN
const int kMinPinLength = 4;

/// الحد الأقصى لطول PIN
const int kMaxPinLength = 6;

/// طول Salt بالبايت
const int kSaltLength = 32;

/// عدد التكرارات لـ PBKDF2
const int kPbkdf2Iterations = 100000;

/// طول المفتاح الناتج بالبايت
const int kDerivedKeyLength = 32;

// ============================================================================
// PIN SERVICE
// ============================================================================

/// خدمة PIN Code
class PinService {
  static const String _pinHashKey = 'pin_hash';
  static const String _pinSaltKey = 'pin_salt';
  static const String _pinEnabledKey = 'pin_enabled';
  static const String _pinAttemptsKey = 'pin_attempts';
  static const String _pinLockedUntilKey = 'pin_locked_until';

  /// إصدار الـ hashing المستخدم (للترحيل في المستقبل)
  static const String _pinVersionKey = 'pin_version';
  static const int _currentVersion = 2; // v1 = SHA256, v2 = PBKDF2
  
  // ============================================================================
  // SETTINGS
  // ============================================================================
  
  /// التحقق من تفعيل PIN
  static Future<bool> isEnabled() async {
    final enabled = await SecureStorageService.read(_pinEnabledKey);
    return enabled == 'true';
  }
  
  /// إنشاء PIN جديد
  static Future<PinResult> createPin(String pin) async {
    // التحقق من الطول
    if (pin.length < kMinPinLength || pin.length > kMaxPinLength) {
      return PinResult.invalidLength();
    }

    // التحقق من أن PIN رقمي فقط
    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      return PinResult.invalidFormat();
    }

    // توليد Salt جديد
    final salt = _generateSalt();
    final saltBase64 = base64Encode(salt);

    // تشفير باستخدام PBKDF2
    final hash = _hashPinWithSalt(pin, salt);

    // حفظ الـ hash والـ salt والإصدار
    await SecureStorageService.write(_pinHashKey, hash);
    await SecureStorageService.write(_pinSaltKey, saltBase64);
    await SecureStorageService.write(_pinVersionKey, _currentVersion.toString());
    await SecureStorageService.write(_pinEnabledKey, 'true');
    await _resetAttempts();

    return PinResult.success();
  }
  
  /// تغيير PIN
  static Future<PinResult> changePin(String currentPin, String newPin) async {
    // التحقق من PIN الحالي
    final verifyResult = await verifyPin(currentPin);
    if (!verifyResult.isSuccess) {
      return verifyResult;
    }
    
    // إنشاء PIN جديد
    return createPin(newPin);
  }
  
  /// حذف PIN
  static Future<void> removePin() async {
    await SecureStorageService.delete(_pinHashKey);
    await SecureStorageService.delete(_pinSaltKey);
    await SecureStorageService.delete(_pinVersionKey);
    await SecureStorageService.delete(_pinEnabledKey);
    await _resetAttempts();
  }
  
  // ============================================================================
  // VERIFICATION
  // ============================================================================
  
  /// التحقق من PIN
  static Future<PinResult> verifyPin(String pin) async {
    // التحقق من القفل
    if (await isLockedOut()) {
      final lockedUntil = await _getLockedUntil();
      return PinResult.lockedOut(lockedUntil);
    }

    // التحقق من التفعيل
    if (!await isEnabled()) {
      return PinResult.notEnabled();
    }

    // الحصول على الهاش المحفوظ
    final savedHash = await SecureStorageService.read(_pinHashKey);
    if (savedHash == null) {
      return PinResult.notEnabled();
    }

    // الحصول على الإصدار
    final versionStr = await SecureStorageService.read(_pinVersionKey);
    final version = int.tryParse(versionStr ?? '1') ?? 1;

    // التحقق حسب الإصدار
    String inputHash;
    if (version >= 2) {
      // PBKDF2 مع Salt
      final saltBase64 = await SecureStorageService.read(_pinSaltKey);
      if (saltBase64 == null) {
        return PinResult.notEnabled();
      }
      final salt = base64Decode(saltBase64);
      inputHash = _hashPinWithSalt(pin, salt);
    } else {
      // الإصدار القديم (SHA256) - للتوافق مع الـ PINs القديمة
      inputHash = _hashPinLegacy(pin);
    }

    if (_constantTimeEquals(inputHash, savedHash)) {
      await _resetAttempts();

      // ترحيل الـ PIN القديم للإصدار الجديد
      if (version < _currentVersion) {
        await _migratePin(pin);
      }

      return PinResult.success();
    }

    // تسجيل المحاولة الفاشلة
    final attempts = await _incrementAttempts();
    final remaining = kMaxPinAttempts - attempts;

    if (remaining <= 0) {
      await _lockOut();
      final lockedUntil = await _getLockedUntil();
      return PinResult.lockedOut(lockedUntil);
    }

    return PinResult.incorrect(remaining);
  }

  /// ترحيل PIN من الإصدار القديم للجديد
  static Future<void> _migratePin(String pin) async {
    final salt = _generateSalt();
    final saltBase64 = base64Encode(salt);
    final hash = _hashPinWithSalt(pin, salt);

    await SecureStorageService.write(_pinHashKey, hash);
    await SecureStorageService.write(_pinSaltKey, saltBase64);
    await SecureStorageService.write(_pinVersionKey, _currentVersion.toString());
  }
  
  // ============================================================================
  // LOCKOUT
  // ============================================================================
  
  /// التحقق من القفل
  static Future<bool> isLockedOut() async {
    final lockedUntilStr = await SecureStorageService.read(_pinLockedUntilKey);
    if (lockedUntilStr == null) return false;
    
    final lockedUntil = DateTime.tryParse(lockedUntilStr);
    if (lockedUntil == null) return false;
    
    if (DateTime.now().isAfter(lockedUntil)) {
      // انتهى القفل
      await _resetAttempts();
      return false;
    }
    
    return true;
  }
  
  /// الحصول على وقت انتهاء القفل
  static Future<DateTime?> _getLockedUntil() async {
    final lockedUntilStr = await SecureStorageService.read(_pinLockedUntilKey);
    if (lockedUntilStr == null) return null;
    return DateTime.tryParse(lockedUntilStr);
  }
  
  /// قفل PIN
  static Future<void> _lockOut() async {
    final lockedUntil = DateTime.now().add(kLockoutDuration);
    await SecureStorageService.write(_pinLockedUntilKey, lockedUntil.toIso8601String());
  }
  
  /// الحصول على عدد المحاولات
  static Future<int> _getAttempts() async {
    final attemptsStr = await SecureStorageService.read(_pinAttemptsKey);
    return int.tryParse(attemptsStr ?? '0') ?? 0;
  }
  
  /// زيادة عدد المحاولات
  static Future<int> _incrementAttempts() async {
    final attempts = await _getAttempts() + 1;
    await SecureStorageService.write(_pinAttemptsKey, attempts.toString());
    return attempts;
  }
  
  /// إعادة تعيين المحاولات
  static Future<void> _resetAttempts() async {
    await SecureStorageService.delete(_pinAttemptsKey);
    await SecureStorageService.delete(_pinLockedUntilKey);
  }
  
  // ============================================================================
  // HELPERS
  // ============================================================================

  /// توليد Salt عشوائي آمن
  static Uint8List _generateSalt() {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(kSaltLength, (_) => random.nextInt(256)),
    );
  }

  /// تشفير PIN باستخدام PBKDF2 مع Salt
  /// هذا أكثر أماناً من SHA256 البسيط
  static String _hashPinWithSalt(String pin, Uint8List salt) {
    final pinBytes = utf8.encode(pin);

    // PBKDF2 implementation using HMAC-SHA256
    final hmac = Hmac(sha256, pinBytes);
    var block = Uint8List(salt.length + 4);
    block.setRange(0, salt.length, salt);

    var derivedKey = Uint8List(kDerivedKeyLength);
    var offset = 0;
    var blockNum = 1;

    while (offset < kDerivedKeyLength) {
      // Set block number (big-endian)
      block[salt.length] = (blockNum >> 24) & 0xff;
      block[salt.length + 1] = (blockNum >> 16) & 0xff;
      block[salt.length + 2] = (blockNum >> 8) & 0xff;
      block[salt.length + 3] = blockNum & 0xff;

      var u = hmac.convert(block).bytes;
      var result = Uint8List.fromList(u);

      for (var i = 1; i < kPbkdf2Iterations; i++) {
        u = hmac.convert(u).bytes;
        for (var j = 0; j < result.length; j++) {
          result[j] ^= u[j];
        }
      }

      final remaining = kDerivedKeyLength - offset;
      final toCopy = remaining < result.length ? remaining : result.length;
      derivedKey.setRange(offset, offset + toCopy, result);
      offset += toCopy;
      blockNum++;
    }

    return base64Encode(derivedKey);
  }

  /// تشفير PIN باستخدام SHA256 (للتوافق مع الإصدار القديم فقط)
  /// ⚠️ لا تستخدم هذا للـ PINs الجديدة
  static String _hashPinLegacy(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// مقارنة ثابتة الوقت لمنع هجمات التوقيت (timing attacks)
  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}

// ============================================================================
// RESULT CLASSES
// ============================================================================

/// نتيجة عملية PIN
class PinResult {
  final bool isSuccess;
  final String? error;
  final PinError? errorType;
  final int? remainingAttempts;
  final DateTime? lockedUntil;

  const PinResult._({
    required this.isSuccess,
    this.error,
    this.errorType,
    this.remainingAttempts,
    this.lockedUntil,
  });

  factory PinResult.success() => const PinResult._(isSuccess: true);
  
  factory PinResult.incorrect(int remaining) => PinResult._(
    isSuccess: false,
    error: 'رمز PIN غير صحيح',
    errorType: PinError.incorrect,
    remainingAttempts: remaining,
  );
  
  factory PinResult.invalidLength() => const PinResult._(
    isSuccess: false,
    error: 'يجب أن يكون رمز PIN من 4-6 أرقام',
    errorType: PinError.invalidLength,
  );
  
  factory PinResult.invalidFormat() => const PinResult._(
    isSuccess: false,
    error: 'يجب أن يحتوي رمز PIN على أرقام فقط',
    errorType: PinError.invalidFormat,
  );
  
  factory PinResult.notEnabled() => const PinResult._(
    isSuccess: false,
    error: 'رمز PIN غير مفعل',
    errorType: PinError.notEnabled,
  );
  
  factory PinResult.lockedOut(DateTime? until) => PinResult._(
    isSuccess: false,
    error: 'تم قفل PIN بسبب كثرة المحاولات',
    errorType: PinError.lockedOut,
    lockedUntil: until,
  );
}

/// أنواع أخطاء PIN
enum PinError {
  incorrect,
  invalidLength,
  invalidFormat,
  notEnabled,
  lockedOut,
}
