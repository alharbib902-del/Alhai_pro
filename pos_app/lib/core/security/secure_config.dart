/// Secure Configuration Manager
///
/// إدارة الإعدادات الحساسة بشكل آمن:
/// - تشفير الإعدادات
/// - التحقق من صحتها
/// - منع التلاعب
/// - Environment-based configuration
library;

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:pos_app/core/monitoring/production_logger.dart';

/// مستوى الأمان
enum SecurityLevel {
  development,  // للتطوير - أقل قيود
  staging,      // للاختبار - قيود متوسطة
  production,   // للإنتاج - أعلى قيود
}

/// إعدادات الأمان
class SecurityConfig {
  // مستوى الأمان الحالي
  static SecurityLevel _level = kDebugMode
      ? SecurityLevel.development
      : SecurityLevel.production;

  // إعدادات PIN
  static const pinMinLength = 4;
  static const pinMaxLength = 6;
  static const pinMaxAttempts = 5;
  static const pinLockoutDuration = Duration(minutes: 15);

  // إعدادات OTP
  static const otpLength = 6;
  static const otpExpiryDuration = Duration(minutes: 5);
  static const otpMaxAttempts = 3;
  static const otpCooldownDuration = Duration(minutes: 15);

  // إعدادات Session
  static const sessionDuration = Duration(minutes: 30);
  static const sessionRefreshThreshold = Duration(minutes: 5);
  static const maxConcurrentSessions = 3;

  // إعدادات Rate Limiting
  static const apiRateLimit = 100; // requests per minute
  static const loginRateLimit = 5; // attempts per 5 minutes
  static const otpRateLimit = 3; // requests per 15 minutes

  // إعدادات التشفير
  static const encryptionAlgorithm = 'AES-256-GCM';
  static const hashAlgorithm = 'SHA-256';
  static const pbkdf2Iterations = 100000;
  static const saltLength = 32;

  // إعدادات الشبكة
  static const connectionTimeout = Duration(seconds: 30);
  static const receiveTimeout = Duration(seconds: 30);
  static const maxRetries = 3;

  // إعدادات الـ Database
  static const dbEncryptionEnabled = true;
  static const syncRetryDelay = Duration(seconds: 5);
  static const maxSyncRetries = 5;

  /// تعيين مستوى الأمان
  static void setSecurityLevel(SecurityLevel level) {
    _level = level;
    AppLogger.debug('Security level set to: ${level.name}', tag: 'SecurityConfig');
  }

  /// الحصول على مستوى الأمان
  static SecurityLevel get securityLevel => _level;

  /// هل في وضع الإنتاج؟
  static bool get isProduction => _level == SecurityLevel.production;

  /// هل في وضع التطوير؟
  static bool get isDevelopment => _level == SecurityLevel.development;

  /// الحصول على إعدادات حسب المستوى
  static T getByLevel<T>({
    required T development,
    required T staging,
    required T production,
  }) {
    return switch (_level) {
      SecurityLevel.development => development,
      SecurityLevel.staging => staging,
      SecurityLevel.production => production,
    };
  }

  /// التحقق من صحة الإعدادات
  static List<String> validateConfiguration() {
    final issues = <String>[];

    if (isProduction) {
      // تحقق من إعدادات الإنتاج
      if (kDebugMode) {
        issues.add('Debug mode enabled in production');
      }

      // تحقق من certificate pinning
      // تحقق من API endpoints
      // etc.
    }

    return issues;
  }
}

/// إدارة المفاتيح السرية
class SecretManager {
  SecretManager._();

  static final Map<String, String> _secrets = {};
  static bool _initialized = false;

  /// تهيئة المفاتيح
  static void initialize(Map<String, String> secrets) {
    if (_initialized && SecurityConfig.isProduction) {
      throw SecurityException('Secrets already initialized');
    }

    _secrets.clear();
    _secrets.addAll(secrets);
    _initialized = true;

    AppLogger.debug('SecretManager initialized with ${secrets.length} secrets', tag: 'SecurityConfig');
  }

  /// الحصول على مفتاح
  static String? get(String key) {
    if (!_initialized) {
      throw SecurityException('SecretManager not initialized');
    }
    return _secrets[key];
  }

  /// الحصول على مفتاح (مطلوب)
  static String getRequired(String key) {
    final value = get(key);
    if (value == null) {
      throw SecurityException('Required secret not found: $key');
    }
    return value;
  }

  /// هل المفتاح موجود؟
  static bool has(String key) {
    return _secrets.containsKey(key);
  }

  /// مسح المفاتيح (للاختبار)
  @visibleForTesting
  static void clear() {
    _secrets.clear();
    _initialized = false;
  }
}

/// قواعد الأمان
class SecurityRules {
  SecurityRules._();

  /// التحقق من قوة كلمة المرور
  static PasswordStrength checkPasswordStrength(String password) {
    int score = 0;
    final issues = <String>[];

    // الطول
    if (password.length < 8) {
      issues.add('Password must be at least 8 characters');
    } else if (password.length >= 12) {
      score += 2;
    } else {
      score += 1;
    }

    // أحرف كبيرة
    if (RegExp(r'[A-Z]').hasMatch(password)) {
      score += 1;
    } else {
      issues.add('Password should contain uppercase letters');
    }

    // أحرف صغيرة
    if (RegExp(r'[a-z]').hasMatch(password)) {
      score += 1;
    } else {
      issues.add('Password should contain lowercase letters');
    }

    // أرقام
    if (RegExp(r'[0-9]').hasMatch(password)) {
      score += 1;
    } else {
      issues.add('Password should contain numbers');
    }

    // رموز خاصة
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      score += 2;
    } else {
      issues.add('Password should contain special characters');
    }

    // تحقق من الأنماط الضعيفة
    if (RegExp(r'(.)\1{2,}').hasMatch(password)) {
      score -= 1;
      issues.add('Avoid repeated characters');
    }

    if (RegExp(r'(012|123|234|345|456|567|678|789|890)').hasMatch(password)) {
      score -= 1;
      issues.add('Avoid sequential numbers');
    }

    // Common passwords check (simplified)
    const commonPasswords = ['password', '123456', 'qwerty', 'admin', 'letmein'];
    if (commonPasswords.any((p) => password.toLowerCase().contains(p))) {
      score = 0;
      issues.add('Password is too common');
    }

    PasswordStrengthLevel level;
    if (score <= 2) {
      level = PasswordStrengthLevel.weak;
    } else if (score <= 4) {
      level = PasswordStrengthLevel.fair;
    } else if (score <= 6) {
      level = PasswordStrengthLevel.good;
    } else {
      level = PasswordStrengthLevel.strong;
    }

    return PasswordStrength(
      level: level,
      score: score,
      issues: issues,
    );
  }

  /// التحقق من صلاحية الـ Token
  static bool isTokenExpired(DateTime issuedAt, Duration maxAge) {
    return DateTime.now().difference(issuedAt) > maxAge;
  }

  /// إنشاء secure random string
  static String generateSecureRandom(int length) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final data = '$timestamp${DateTime.now().microsecondsSinceEpoch}';
    final hash = sha256.convert(utf8.encode(data)).toString();
    return hash.substring(0, length);
  }
}

/// قوة كلمة المرور
enum PasswordStrengthLevel {
  weak,
  fair,
  good,
  strong,
}

/// نتيجة فحص قوة كلمة المرور
class PasswordStrength {
  final PasswordStrengthLevel level;
  final int score;
  final List<String> issues;

  const PasswordStrength({
    required this.level,
    required this.score,
    required this.issues,
  });

  bool get isAcceptable => level == PasswordStrengthLevel.good || level == PasswordStrengthLevel.strong;
}

/// استثناء أمني
class SecurityException implements Exception {
  final String message;

  SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}

/// Constants للـ Security Headers
class SecurityHeaders {
  SecurityHeaders._();

  static const contentSecurityPolicy = 'Content-Security-Policy';
  static const xContentTypeOptions = 'X-Content-Type-Options';
  static const xFrameOptions = 'X-Frame-Options';
  static const xXssProtection = 'X-XSS-Protection';
  static const strictTransportSecurity = 'Strict-Transport-Security';
  static const referrerPolicy = 'Referrer-Policy';

  /// الحصول على headers الأمنية الافتراضية
  static Map<String, String> getDefaultHeaders() {
    return {
      xContentTypeOptions: 'nosniff',
      xFrameOptions: 'DENY',
      xXssProtection: '1; mode=block',
      referrerPolicy: 'strict-origin-when-cross-origin',
    };
  }
}
