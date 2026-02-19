// Security Configuration Validator
// يتحقق من إعدادات الأمان في التطبيق
//
// الوظائف:
// - فحص SSL Pinning
// - فحص مفاتيح التشفير
// - فحص Rate Limiting
// - فحص وضع Debug
// - فحص Session Timeout
// - توليد تقرير أمني شامل
library;

import 'package:flutter/foundation.dart';

/// مستوى خطورة مشكلة الأمان
enum SecuritySeverity {
  /// خطورة حرجة - يجب الإصلاح فوراً
  critical,

  /// خطورة عالية - يجب الإصلاح قبل Production
  high,

  /// خطورة متوسطة - يفضل الإصلاح
  medium,

  /// خطورة منخفضة - تحسين اختياري
  low,

  /// معلوماتي فقط
  info,
}

/// فئة مشكلة الأمان
enum SecurityCategory {
  /// التشفير
  encryption,

  /// الشبكة
  network,

  /// المصادقة
  authentication,

  /// الجلسات
  session,

  /// التكوين
  configuration,

  /// التسجيل
  logging,

  /// التحكم في الوصول
  accessControl,
}

/// مشكلة أمنية
class SecurityIssue {
  /// معرف المشكلة
  final String id;

  /// عنوان المشكلة
  final String title;

  /// وصف المشكلة
  final String description;

  /// مستوى الخطورة
  final SecuritySeverity severity;

  /// الفئة
  final SecurityCategory category;

  /// التوصية للإصلاح
  final String recommendation;

  /// هل تم الإصلاح
  final bool isFixed;

  /// رمز المشكلة للتتبع
  final String code;

  const SecurityIssue({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.category,
    required this.recommendation,
    this.isFixed = false,
    required this.code,
  });

  SecurityIssue copyWith({bool? isFixed}) {
    return SecurityIssue(
      id: id,
      title: title,
      description: description,
      severity: severity,
      category: category,
      recommendation: recommendation,
      isFixed: isFixed ?? this.isFixed,
      code: code,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'severity': severity.name,
        'category': category.name,
        'recommendation': recommendation,
        'isFixed': isFixed,
        'code': code,
      };

  @override
  String toString() => '[$code] $title (${severity.name})';
}

/// نتيجة فحص الأمان
class SecurityAuditResult {
  /// قائمة المشاكل المكتشفة
  final List<SecurityIssue> issues;

  /// وقت الفحص
  final DateTime timestamp;

  /// إصدار التطبيق
  final String appVersion;

  /// البيئة
  final String environment;

  /// نقاط الأمان (0-100)
  final int score;

  /// هل التطبيق جاهز للإنتاج
  final bool isProductionReady;

  const SecurityAuditResult({
    required this.issues,
    required this.timestamp,
    required this.appVersion,
    required this.environment,
    required this.score,
    required this.isProductionReady,
  });

  /// المشاكل الحرجة
  List<SecurityIssue> get criticalIssues =>
      issues.where((i) => i.severity == SecuritySeverity.critical && !i.isFixed).toList();

  /// المشاكل العالية الخطورة
  List<SecurityIssue> get highIssues =>
      issues.where((i) => i.severity == SecuritySeverity.high && !i.isFixed).toList();

  /// المشاكل المتوسطة الخطورة
  List<SecurityIssue> get mediumIssues =>
      issues.where((i) => i.severity == SecuritySeverity.medium && !i.isFixed).toList();

  /// المشاكل المنخفضة الخطورة
  List<SecurityIssue> get lowIssues =>
      issues.where((i) => i.severity == SecuritySeverity.low && !i.isFixed).toList();

  /// المشاكل غير المصلحة
  List<SecurityIssue> get unfixedIssues => issues.where((i) => !i.isFixed).toList();

  /// المشاكل المصلحة
  List<SecurityIssue> get fixedIssues => issues.where((i) => i.isFixed).toList();

  /// عدد المشاكل حسب الفئة
  Map<SecurityCategory, int> get issuesByCategory {
    final map = <SecurityCategory, int>{};
    for (final issue in unfixedIssues) {
      map[issue.category] = (map[issue.category] ?? 0) + 1;
    }
    return map;
  }

  /// ملخص النتيجة
  String get summary {
    if (criticalIssues.isNotEmpty) {
      return 'Critical issues found - immediate action required';
    }
    if (highIssues.isNotEmpty) {
      return 'High severity issues found - fix before production';
    }
    if (mediumIssues.isNotEmpty) {
      return 'Medium severity issues found - recommended to fix';
    }
    if (lowIssues.isNotEmpty) {
      return 'Minor issues found - optional improvements';
    }
    return 'No security issues found - excellent!';
  }

  Map<String, dynamic> toJson() => {
        'issues': issues.map((i) => i.toJson()).toList(),
        'timestamp': timestamp.toIso8601String(),
        'appVersion': appVersion,
        'environment': environment,
        'score': score,
        'isProductionReady': isProductionReady,
        'summary': summary,
        'statistics': {
          'total': issues.length,
          'critical': criticalIssues.length,
          'high': highIssues.length,
          'medium': mediumIssues.length,
          'low': lowIssues.length,
          'fixed': fixedIssues.length,
        },
      };

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Security Audit Report');
    buffer.writeln('=' * 50);
    buffer.writeln('Score: $score/100');
    buffer.writeln('Production Ready: ${isProductionReady ? "Yes" : "No"}');
    buffer.writeln('Summary: $summary');
    buffer.writeln();
    buffer.writeln('Issues: ${unfixedIssues.length} unfixed, ${fixedIssues.length} fixed');
    if (unfixedIssues.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Unfixed Issues:');
      for (final issue in unfixedIssues) {
        buffer.writeln('  - $issue');
      }
    }
    return buffer.toString();
  }
}

/// تكوين الأمان للتحقق
class SecurityConfig {
  /// هل SSL Pinning مفعل
  final bool sslPinningEnabled;

  /// بصمات الشهادات
  final List<String> certificateFingerprints;

  /// هل التشفير مفعل
  final bool encryptionEnabled;

  /// مفتاح التشفير موجود
  final bool encryptionKeyConfigured;

  /// هل Rate Limiting مفعل
  final bool rateLimitingEnabled;

  /// تكوين Rate Limiting
  final Map<String, int>? rateLimitConfig;

  /// مهلة الجلسة بالدقائق
  final int sessionTimeoutMinutes;

  /// هل وضع Debug مفعل
  final bool debugModeEnabled;

  /// هل Biometric مفعل
  final bool biometricEnabled;

  /// هل CSRF Protection مفعل
  final bool csrfProtectionEnabled;

  /// هل Request Signing مفعل
  final bool requestSigningEnabled;

  /// هل Audit Logging مفعل
  final bool auditLoggingEnabled;

  /// هل Input Sanitization مفعل
  final bool inputSanitizationEnabled;

  /// إصدار التطبيق
  final String appVersion;

  /// البيئة (development, staging, production)
  final String environment;

  const SecurityConfig({
    this.sslPinningEnabled = false,
    this.certificateFingerprints = const [],
    this.encryptionEnabled = false,
    this.encryptionKeyConfigured = false,
    this.rateLimitingEnabled = false,
    this.rateLimitConfig,
    this.sessionTimeoutMinutes = 30,
    this.debugModeEnabled = true,
    this.biometricEnabled = false,
    this.csrfProtectionEnabled = false,
    this.requestSigningEnabled = false,
    this.auditLoggingEnabled = false,
    this.inputSanitizationEnabled = false,
    this.appVersion = '1.0.0',
    this.environment = 'development',
  });

  /// تكوين إنتاجي آمن
  factory SecurityConfig.secure({
    required List<String> certificateFingerprints,
    required String appVersion,
  }) {
    return SecurityConfig(
      sslPinningEnabled: true,
      certificateFingerprints: certificateFingerprints,
      encryptionEnabled: true,
      encryptionKeyConfigured: true,
      rateLimitingEnabled: true,
      rateLimitConfig: {
        'otp': 3,
        'login': 5,
        'api': 100,
      },
      sessionTimeoutMinutes: 30,
      debugModeEnabled: false,
      biometricEnabled: true,
      csrfProtectionEnabled: true,
      requestSigningEnabled: true,
      auditLoggingEnabled: true,
      inputSanitizationEnabled: true,
      appVersion: appVersion,
      environment: 'production',
    );
  }

  bool get isProduction => environment == 'production';
}

/// مدقق تكوين الأمان
class SecurityConfigValidator {
  /// التحقق من تكوين الأمان
  static SecurityAuditResult validate(SecurityConfig config) {
    final issues = <SecurityIssue>[];
    int score = 100;

    // فحص SSL Pinning
    final sslResult = _validateSslPinning(config);
    issues.addAll(sslResult.issues);
    score -= sslResult.deduction;

    // فحص التشفير
    final encryptionResult = _validateEncryption(config);
    issues.addAll(encryptionResult.issues);
    score -= encryptionResult.deduction;

    // فحص Rate Limiting
    final rateLimitResult = _validateRateLimiting(config);
    issues.addAll(rateLimitResult.issues);
    score -= rateLimitResult.deduction;

    // فحص الجلسات
    final sessionResult = _validateSession(config);
    issues.addAll(sessionResult.issues);
    score -= sessionResult.deduction;

    // فحص وضع Debug
    final debugResult = _validateDebugMode(config);
    issues.addAll(debugResult.issues);
    score -= debugResult.deduction;

    // فحص المصادقة
    final authResult = _validateAuthentication(config);
    issues.addAll(authResult.issues);
    score -= authResult.deduction;

    // فحص الحماية الإضافية
    final additionalResult = _validateAdditionalProtection(config);
    issues.addAll(additionalResult.issues);
    score -= additionalResult.deduction;

    // حساب النقاط النهائية
    score = score.clamp(0, 100);

    // تحديد جاهزية الإنتاج
    final isProductionReady = issues.every((i) =>
        i.isFixed ||
        i.severity == SecuritySeverity.low ||
        i.severity == SecuritySeverity.info);

    return SecurityAuditResult(
      issues: issues,
      timestamp: DateTime.now(),
      appVersion: config.appVersion,
      environment: config.environment,
      score: score,
      isProductionReady: isProductionReady,
    );
  }

  /// فحص سريع للإنتاج
  static bool isSecureForProduction(SecurityConfig config) {
    final result = validate(config);
    return result.isProductionReady && result.score >= 80;
  }

  /// الحصول على التوصيات
  static List<String> getRecommendations(SecurityConfig config) {
    final result = validate(config);
    return result.unfixedIssues.map((i) => i.recommendation).toList();
  }

  // فحص SSL Pinning
  static _ValidationResult _validateSslPinning(SecurityConfig config) {
    final issues = <SecurityIssue>[];
    var deduction = 0;

    if (!config.sslPinningEnabled) {
      if (config.isProduction) {
        issues.add(const SecurityIssue(
          id: 'SSL001',
          title: 'SSL Pinning Disabled',
          description: 'SSL Certificate Pinning is disabled in production',
          severity: SecuritySeverity.critical,
          category: SecurityCategory.network,
          recommendation: 'Enable SSL pinning with valid certificate fingerprints',
          code: 'SSL_PINNING_DISABLED',
        ));
        deduction += 15;
      } else {
        issues.add(const SecurityIssue(
          id: 'SSL002',
          title: 'SSL Pinning Not Configured',
          description: 'SSL Certificate Pinning is not configured',
          severity: SecuritySeverity.medium,
          category: SecurityCategory.network,
          recommendation: 'Configure SSL pinning before production deployment',
          code: 'SSL_PINNING_NOT_CONFIGURED',
        ));
        deduction += 5;
      }
    } else if (config.certificateFingerprints.isEmpty) {
      issues.add(const SecurityIssue(
        id: 'SSL003',
        title: 'No Certificate Fingerprints',
        description: 'SSL Pinning enabled but no fingerprints configured',
        severity: SecuritySeverity.high,
        category: SecurityCategory.network,
        recommendation: 'Add at least one SHA-256 certificate fingerprint',
        code: 'SSL_NO_FINGERPRINTS',
      ));
      deduction += 10;
    } else {
      // التحقق من صحة الـ fingerprints
      for (final fp in config.certificateFingerprints) {
        if (!_isValidFingerprint(fp)) {
          issues.add(SecurityIssue(
            id: 'SSL004',
            title: 'Invalid Certificate Fingerprint',
            description: 'Fingerprint format is invalid: ${fp.length > 10 ? '${fp.substring(0, 10)}...' : fp}',
            severity: SecuritySeverity.high,
            category: SecurityCategory.network,
            recommendation: 'Use valid SHA-256 (64 chars) or SHA-1 (40 chars) fingerprint',
            code: 'SSL_INVALID_FINGERPRINT',
          ));
          deduction += 5;
        }
      }
    }

    return _ValidationResult(issues: issues, deduction: deduction);
  }

  // فحص التشفير
  static _ValidationResult _validateEncryption(SecurityConfig config) {
    final issues = <SecurityIssue>[];
    var deduction = 0;

    if (!config.encryptionEnabled) {
      issues.add(SecurityIssue(
        id: 'ENC001',
        title: 'Encryption Disabled',
        description: 'Database encryption is disabled',
        severity: config.isProduction ? SecuritySeverity.critical : SecuritySeverity.high,
        category: SecurityCategory.encryption,
        recommendation: 'Enable database encryption for sensitive data protection',
        code: 'ENCRYPTION_DISABLED',
      ));
      deduction += config.isProduction ? 15 : 10;
    } else if (!config.encryptionKeyConfigured) {
      issues.add(const SecurityIssue(
        id: 'ENC002',
        title: 'Encryption Key Not Configured',
        description: 'Encryption is enabled but key is not properly configured',
        severity: SecuritySeverity.critical,
        category: SecurityCategory.encryption,
        recommendation: 'Generate and securely store encryption key',
        code: 'ENCRYPTION_KEY_MISSING',
      ));
      deduction += 15;
    }

    return _ValidationResult(issues: issues, deduction: deduction);
  }

  // فحص Rate Limiting
  static _ValidationResult _validateRateLimiting(SecurityConfig config) {
    final issues = <SecurityIssue>[];
    var deduction = 0;

    if (!config.rateLimitingEnabled) {
      issues.add(SecurityIssue(
        id: 'RL001',
        title: 'Rate Limiting Disabled',
        description: 'Rate limiting is not enabled',
        severity: config.isProduction ? SecuritySeverity.high : SecuritySeverity.medium,
        category: SecurityCategory.accessControl,
        recommendation: 'Enable rate limiting to prevent brute force attacks',
        code: 'RATE_LIMITING_DISABLED',
      ));
      deduction += config.isProduction ? 10 : 5;
    } else if (config.rateLimitConfig == null || config.rateLimitConfig!.isEmpty) {
      issues.add(const SecurityIssue(
        id: 'RL002',
        title: 'Rate Limit Config Missing',
        description: 'Rate limiting is enabled but not configured',
        severity: SecuritySeverity.medium,
        category: SecurityCategory.accessControl,
        recommendation: 'Configure rate limits for OTP, login, and API endpoints',
        code: 'RATE_LIMIT_NO_CONFIG',
      ));
      deduction += 5;
    }

    return _ValidationResult(issues: issues, deduction: deduction);
  }

  // فحص الجلسات
  static _ValidationResult _validateSession(SecurityConfig config) {
    final issues = <SecurityIssue>[];
    var deduction = 0;

    if (config.sessionTimeoutMinutes <= 0) {
      issues.add(const SecurityIssue(
        id: 'SES001',
        title: 'No Session Timeout',
        description: 'Session timeout is not configured',
        severity: SecuritySeverity.high,
        category: SecurityCategory.session,
        recommendation: 'Set session timeout between 15-60 minutes',
        code: 'SESSION_NO_TIMEOUT',
      ));
      deduction += 10;
    } else if (config.sessionTimeoutMinutes > 60) {
      issues.add(const SecurityIssue(
        id: 'SES002',
        title: 'Long Session Timeout',
        description: 'Session timeout exceeds 60 minutes',
        severity: SecuritySeverity.low,
        category: SecurityCategory.session,
        recommendation: 'Consider reducing session timeout to 30-60 minutes',
        code: 'SESSION_LONG_TIMEOUT',
      ));
      deduction += 2;
    }

    return _ValidationResult(issues: issues, deduction: deduction);
  }

  // فحص وضع Debug
  static _ValidationResult _validateDebugMode(SecurityConfig config) {
    final issues = <SecurityIssue>[];
    var deduction = 0;

    if (config.debugModeEnabled && config.isProduction) {
      issues.add(const SecurityIssue(
        id: 'DBG001',
        title: 'Debug Mode in Production',
        description: 'Debug mode is enabled in production environment',
        severity: SecuritySeverity.critical,
        category: SecurityCategory.configuration,
        recommendation: 'Disable debug mode in production builds',
        code: 'DEBUG_IN_PRODUCTION',
      ));
      deduction += 15;
    }

    // التحقق من kDebugMode
    if (kDebugMode && config.isProduction) {
      issues.add(const SecurityIssue(
        id: 'DBG002',
        title: 'Running Debug Build in Production',
        description: 'Application is running as debug build in production',
        severity: SecuritySeverity.critical,
        category: SecurityCategory.configuration,
        recommendation: 'Use release build for production deployment',
        code: 'DEBUG_BUILD_PRODUCTION',
      ));
      deduction += 15;
    }

    return _ValidationResult(issues: issues, deduction: deduction);
  }

  // فحص المصادقة
  static _ValidationResult _validateAuthentication(SecurityConfig config) {
    final issues = <SecurityIssue>[];
    var deduction = 0;

    if (!config.biometricEnabled && config.isProduction) {
      issues.add(const SecurityIssue(
        id: 'AUTH001',
        title: 'Biometric Not Enabled',
        description: 'Biometric authentication is not enabled',
        severity: SecuritySeverity.low,
        category: SecurityCategory.authentication,
        recommendation: 'Enable biometric authentication for enhanced security',
        code: 'BIOMETRIC_DISABLED',
      ));
      deduction += 2;
    }

    return _ValidationResult(issues: issues, deduction: deduction);
  }

  // فحص الحماية الإضافية
  static _ValidationResult _validateAdditionalProtection(SecurityConfig config) {
    final issues = <SecurityIssue>[];
    var deduction = 0;

    if (!config.csrfProtectionEnabled && config.isProduction) {
      issues.add(const SecurityIssue(
        id: 'PROT001',
        title: 'CSRF Protection Disabled',
        description: 'Cross-Site Request Forgery protection is not enabled',
        severity: SecuritySeverity.high,
        category: SecurityCategory.network,
        recommendation: 'Enable CSRF token validation for API requests',
        code: 'CSRF_DISABLED',
      ));
      deduction += 8;
    }

    if (!config.requestSigningEnabled && config.isProduction) {
      issues.add(const SecurityIssue(
        id: 'PROT002',
        title: 'Request Signing Disabled',
        description: 'API request signing is not enabled',
        severity: SecuritySeverity.medium,
        category: SecurityCategory.network,
        recommendation: 'Enable HMAC request signing for sensitive operations',
        code: 'REQUEST_SIGNING_DISABLED',
      ));
      deduction += 5;
    }

    if (!config.auditLoggingEnabled) {
      issues.add(const SecurityIssue(
        id: 'PROT003',
        title: 'Audit Logging Disabled',
        description: 'Security audit logging is not enabled',
        severity: SecuritySeverity.medium,
        category: SecurityCategory.logging,
        recommendation: 'Enable audit logging for security event tracking',
        code: 'AUDIT_LOGGING_DISABLED',
      ));
      deduction += 5;
    }

    if (!config.inputSanitizationEnabled) {
      issues.add(SecurityIssue(
        id: 'PROT004',
        title: 'Input Sanitization Disabled',
        description: 'Input sanitization is not enabled',
        severity: config.isProduction ? SecuritySeverity.high : SecuritySeverity.medium,
        category: SecurityCategory.accessControl,
        recommendation: 'Enable input sanitization to prevent injection attacks',
        code: 'INPUT_SANITIZATION_DISABLED',
      ));
      deduction += config.isProduction ? 8 : 5;
    }

    return _ValidationResult(issues: issues, deduction: deduction);
  }

  // التحقق من صحة البصمة
  static bool _isValidFingerprint(String fingerprint) {
    final cleaned = fingerprint.replaceAll(RegExp(r'[:\s-]'), '').toLowerCase();
    // SHA-256: 64 chars, SHA-1: 40 chars
    if (cleaned.length != 64 && cleaned.length != 40) {
      return false;
    }
    return RegExp(r'^[a-f0-9]+$').hasMatch(cleaned);
  }
}

/// نتيجة فحص داخلية
class _ValidationResult {
  final List<SecurityIssue> issues;
  final int deduction;

  const _ValidationResult({
    required this.issues,
    required this.deduction,
  });
}

/// امتداد لسهولة الاستخدام
extension SecurityConfigValidatorExtension on SecurityConfig {
  /// التحقق من التكوين
  SecurityAuditResult validate() => SecurityConfigValidator.validate(this);

  /// هل التكوين آمن للإنتاج
  bool get isSecureForProduction =>
      SecurityConfigValidator.isSecureForProduction(this);

  /// الحصول على التوصيات
  List<String> get recommendations =>
      SecurityConfigValidator.getRecommendations(this);
}
