/// خدمة المصادقة البيومترية - Biometric Authentication Service
///
/// تُدير المصادقة بالبصمة و Face ID
library;

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'secure_storage_service.dart';

// ============================================================================
// BIOMETRIC SERVICE
// ============================================================================

/// خدمة المصادقة البيومترية
class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static const String _biometricEnabledKey = 'biometric_enabled';

  // ============================================================================
  // AVAILABILITY
  // ============================================================================

  /// التحقق من توفر المصادقة البيومترية
  static Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } on PlatformException {
      return false;
    }
  }

  /// الحصول على الأنواع المتاحة
  static Future<List<BiometricType>> getAvailableTypes() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  /// التحقق من دعم البصمة
  static Future<bool> hasFingerprintSupport() async {
    final types = await getAvailableTypes();
    return types.contains(BiometricType.fingerprint);
  }

  /// التحقق من دعم Face ID
  static Future<bool> hasFaceIdSupport() async {
    final types = await getAvailableTypes();
    return types.contains(BiometricType.face);
  }

  // ============================================================================
  // SETTINGS
  // ============================================================================

  /// التحقق من تفعيل البيومترية
  static Future<bool> isEnabled() async {
    final enabled = await SecureStorageService.read(_biometricEnabledKey);
    return enabled == 'true';
  }

  /// تفعيل البيومترية
  static Future<bool> enable() async {
    // التحقق أولاً من توفر البيومترية
    if (!await isAvailable()) return false;

    // طلب المصادقة للتأكيد
    final authenticated = await authenticate(
      reason: 'قم بالمصادقة لتفعيل الدخول بالبصمة',
    );

    if (authenticated) {
      await SecureStorageService.write(_biometricEnabledKey, 'true');
      return true;
    }

    return false;
  }

  /// تعطيل البيومترية
  static Future<void> disable() async {
    await SecureStorageService.delete(_biometricEnabledKey);
  }

  // ============================================================================
  // AUTHENTICATION
  // ============================================================================

  /// المصادقة بالبيومترية
  static Future<bool> authenticate({
    String reason = 'قم بالمصادقة للمتابعة',
    bool stickyAuth = true,
    bool sensitiveTransaction = false,
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          stickyAuth: stickyAuth,
          sensitiveTransaction: sensitiveTransaction,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      // معالجة الأخطاء
      if (e.code == 'NotAvailable') {
        return false;
      }
      if (e.code == 'NotEnrolled') {
        return false;
      }
      if (e.code == 'LockedOut') {
        return false;
      }
      if (e.code == 'PermanentlyLockedOut') {
        return false;
      }
      return false;
    }
  }

  /// تسجيل الدخول بالبيومترية
  static Future<BiometricLoginResult> login() async {
    // التحقق من التفعيل
    if (!await isEnabled()) {
      return BiometricLoginResult.notEnabled();
    }

    // التحقق من التوفر
    if (!await isAvailable()) {
      return BiometricLoginResult.notAvailable();
    }

    // محاولة المصادقة
    final authenticated = await authenticate(
      reason: 'قم بالمصادقة لتسجيل الدخول',
      sensitiveTransaction: true,
    );

    if (authenticated) {
      return BiometricLoginResult.success();
    }

    return BiometricLoginResult.failed();
  }
}

// ============================================================================
// RESULT CLASSES
// ============================================================================

/// نتيجة تسجيل الدخول البيومتري
class BiometricLoginResult {
  final bool isSuccess;
  final String? error;
  final BiometricLoginError? errorType;

  const BiometricLoginResult._({
    required this.isSuccess,
    this.error,
    this.errorType,
  });

  factory BiometricLoginResult.success() =>
      const BiometricLoginResult._(isSuccess: true);

  factory BiometricLoginResult.failed() => const BiometricLoginResult._(
        isSuccess: false,
        error: 'فشلت المصادقة',
        errorType: BiometricLoginError.failed,
      );

  factory BiometricLoginResult.notEnabled() => const BiometricLoginResult._(
        isSuccess: false,
        error: 'البصمة غير مفعلة',
        errorType: BiometricLoginError.notEnabled,
      );

  factory BiometricLoginResult.notAvailable() => const BiometricLoginResult._(
        isSuccess: false,
        error: 'البصمة غير متوفرة على هذا الجهاز',
        errorType: BiometricLoginError.notAvailable,
      );

  factory BiometricLoginResult.lockedOut() => const BiometricLoginResult._(
        isSuccess: false,
        error: 'تم قفل البصمة بسبب كثرة المحاولات',
        errorType: BiometricLoginError.lockedOut,
      );
}

/// أنواع أخطاء البيومترية
enum BiometricLoginError {
  failed,
  notEnabled,
  notAvailable,
  lockedOut,
}
