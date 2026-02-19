/// SSL Pinning Validator
///
/// التحقق من تكوين Certificate Pinning في التطبيق
/// يتحقق من:
/// - وجود Certificate fingerprints
/// - صحة تنسيق الـ fingerprints
/// - تحذير في Production إذا معطل
///
/// ⚠️ هام: Certificate Pinning لا يعمل على الويب
library;

import 'package:flutter/foundation.dart';

/// حالة SSL Pinning
enum SSLPinningStatus {
  /// مفعّل وصحيح
  enabled,

  /// معطّل
  disabled,

  /// تكوين غير صحيح
  invalid,

  /// غير مدعوم (مثل الويب)
  unsupported,
}

/// نتيجة التحقق من SSL
class SSLValidationResult {
  final SSLPinningStatus status;
  final List<String> issues;
  final List<String> warnings;
  final Map<String, CertificateInfo> certificates;

  const SSLValidationResult({
    required this.status,
    this.issues = const [],
    this.warnings = const [],
    this.certificates = const {},
  });

  bool get isValid => status == SSLPinningStatus.enabled && issues.isEmpty;
  bool get hasWarnings => warnings.isNotEmpty;

  factory SSLValidationResult.enabled({
    required Map<String, CertificateInfo> certificates,
    List<String> warnings = const [],
  }) {
    return SSLValidationResult(
      status: SSLPinningStatus.enabled,
      certificates: certificates,
      warnings: warnings,
    );
  }

  factory SSLValidationResult.disabled({List<String> issues = const []}) {
    return SSLValidationResult(
      status: SSLPinningStatus.disabled,
      issues: issues,
    );
  }

  factory SSLValidationResult.invalid({required List<String> issues}) {
    return SSLValidationResult(
      status: SSLPinningStatus.invalid,
      issues: issues,
    );
  }

  factory SSLValidationResult.unsupported() {
    return const SSLValidationResult(
      status: SSLPinningStatus.unsupported,
      warnings: ['SSL Pinning is not supported on this platform (Web)'],
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status.name,
        'isValid': isValid,
        'issues': issues,
        'warnings': warnings,
        'certificates': certificates.map((k, v) => MapEntry(k, v.toJson())),
      };

  @override
  String toString() {
    return 'SSLValidationResult(status: ${status.name}, valid: $isValid, '
        'issues: ${issues.length}, warnings: ${warnings.length})';
  }
}

/// معلومات الشهادة
class CertificateInfo {
  final String domain;
  final String fingerprint;
  final FingerprintType type;
  final bool isValid;
  final DateTime? expiryDate;

  const CertificateInfo({
    required this.domain,
    required this.fingerprint,
    required this.type,
    required this.isValid,
    this.expiryDate,
  });

  Map<String, dynamic> toJson() => {
        'domain': domain,
        'fingerprint': _maskFingerprint(fingerprint),
        'type': type.name,
        'isValid': isValid,
        'expiryDate': expiryDate?.toIso8601String(),
      };

  String _maskFingerprint(String fp) {
    if (fp.length <= 16) return fp;
    return '${fp.substring(0, 8)}...${fp.substring(fp.length - 8)}';
  }
}

/// نوع الـ Fingerprint
enum FingerprintType {
  sha256,
  sha1,
  md5,
  unknown,
}

/// SSL Pinning Validator
class SSLPinningValidator {
  SSLPinningValidator._();

  static const _sha256Length = 64; // 256 bits = 64 hex chars
  static const _sha1Length = 40; // 160 bits = 40 hex chars

  /// التحقق من تكوين SSL Pinning
  static Future<SSLValidationResult> validate({
    required Map<String, String> certificateFingerprints,
    bool isProduction = false,
  }) async {
    // الويب لا يدعم Certificate Pinning
    if (kIsWeb) {
      return SSLValidationResult.unsupported();
    }

    final issues = <String>[];
    final warnings = <String>[];
    final certificates = <String, CertificateInfo>{};

    // التحقق من وجود fingerprints
    if (certificateFingerprints.isEmpty) {
      if (isProduction) {
        issues.add('No certificate fingerprints configured in production mode');
      } else {
        warnings.add('Certificate pinning is disabled (no fingerprints configured)');
      }
      return SSLValidationResult.disabled(issues: issues);
    }

    // التحقق من كل fingerprint
    for (final entry in certificateFingerprints.entries) {
      final domain = entry.key;
      final fingerprint = entry.value;
      final validationResult = _validateFingerprint(domain, fingerprint);

      certificates[domain] = validationResult.certificate;

      if (!validationResult.isValid) {
        issues.addAll(validationResult.issues);
      }
      warnings.addAll(validationResult.warnings);
    }

    // تحذيرات إضافية للـ production
    if (isProduction) {
      _addProductionWarnings(certificateFingerprints, warnings);
    }

    if (issues.isNotEmpty) {
      return SSLValidationResult.invalid(issues: issues);
    }

    return SSLValidationResult.enabled(
      certificates: certificates,
      warnings: warnings,
    );
  }

  /// التحقق من fingerprint واحد
  static _FingerprintValidation _validateFingerprint(
    String domain,
    String fingerprint,
  ) {
    final issues = <String>[];
    final warnings = <String>[];

    // إزالة المسافات والـ colons
    final cleanedFp = fingerprint.replaceAll(RegExp(r'[\s:]'), '').toLowerCase();

    // تحديد النوع
    final type = _detectFingerprintType(cleanedFp);

    // التحقق من الطول
    bool isValid = _validateFingerprintFormat(cleanedFp, type, domain, issues);

    // تحذير إذا كان sha1 أو md5
    if (type == FingerprintType.sha1) {
      warnings.add('$domain: SHA-1 fingerprint detected. Consider upgrading to SHA-256');
    } else if (type == FingerprintType.md5) {
      issues.add('$domain: MD5 fingerprint is insecure and not recommended');
      isValid = false;
    }

    // التحقق من أن الـ fingerprint ليس فارغاً
    if (cleanedFp.isEmpty) {
      issues.add('$domain: Empty fingerprint');
      isValid = false;
    }

    // التحقق من أنه hex فقط
    if (!RegExp(r'^[a-f0-9]+$').hasMatch(cleanedFp) && cleanedFp.isNotEmpty) {
      issues.add('$domain: Invalid characters in fingerprint (must be hex)');
      isValid = false;
    }

    return _FingerprintValidation(
      certificate: CertificateInfo(
        domain: domain,
        fingerprint: cleanedFp,
        type: type,
        isValid: isValid,
      ),
      issues: issues,
      warnings: warnings,
      isValid: isValid,
    );
  }

  /// تحديد نوع الـ fingerprint من الطول
  static FingerprintType _detectFingerprintType(String fingerprint) {
    return switch (fingerprint.length) {
      _sha256Length => FingerprintType.sha256,
      _sha1Length => FingerprintType.sha1,
      32 => FingerprintType.md5,
      _ => FingerprintType.unknown,
    };
  }

  /// التحقق من تنسيق الـ fingerprint
  static bool _validateFingerprintFormat(
    String fingerprint,
    FingerprintType type,
    String domain,
    List<String> issues,
  ) {
    if (type == FingerprintType.unknown) {
      issues.add(
        '$domain: Invalid fingerprint length (${fingerprint.length}). '
        'Expected 64 (SHA-256) or 40 (SHA-1)',
      );
      return false;
    }
    return true;
  }

  /// إضافة تحذيرات الـ production
  static void _addProductionWarnings(
    Map<String, String> fingerprints,
    List<String> warnings,
  ) {
    // تحذير إذا كان عدد الـ fingerprints قليل
    if (fingerprints.length < 2) {
      warnings.add(
        'Consider adding backup certificate fingerprints for certificate rotation',
      );
    }

    // تحذير حول تجديد الشهادات
    warnings.add(
      'Remember to update fingerprints before certificate expiry. '
      'Set reminders for 30 days before expiry.',
    );
  }

  /// التحقق من domain معين
  static bool isDomainPinned(
    String domain,
    Map<String, String> certificateFingerprints,
  ) {
    return certificateFingerprints.containsKey(domain);
  }

  /// تحذير في Production إذا معطّل
  static void warnIfDisabled({
    required Map<String, String> certificateFingerprints,
    bool isProduction = false,
  }) {
    if (kIsWeb) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ SSL Pinning is not supported on Web platform. '
          'Consider using HSTS and other web security measures.',
        );
      }
      return;
    }

    if (certificateFingerprints.isEmpty) {
      final message = isProduction
          ? '🚨 CRITICAL: SSL Pinning is DISABLED in PRODUCTION! '
              'This exposes the app to MITM attacks.'
          : '⚠️ SSL Pinning is disabled. '
              'Enable it before deploying to production.';

      if (kDebugMode) {
        debugPrint(message);
      }

      // في production، يمكن إرسال alert للـ monitoring
      if (isProduction) {
        // TODO: Send alert to monitoring service
      }
    }
  }

  /// توليد تقرير أمان SSL
  static Future<Map<String, dynamic>> generateSecurityReport({
    required Map<String, String> certificateFingerprints,
    bool isProduction = false,
  }) async {
    final validation = await validate(
      certificateFingerprints: certificateFingerprints,
      isProduction: isProduction,
    );

    return {
      'timestamp': DateTime.now().toIso8601String(),
      'platform': kIsWeb ? 'web' : 'native',
      'isProduction': isProduction,
      'validation': validation.toJson(),
      'recommendations': _getRecommendations(validation, isProduction),
    };
  }

  /// الحصول على التوصيات
  static List<String> _getRecommendations(
    SSLValidationResult validation,
    bool isProduction,
  ) {
    final recommendations = <String>[];

    switch (validation.status) {
      case SSLPinningStatus.disabled:
        recommendations.add('Enable SSL Pinning by configuring certificate fingerprints');
        recommendations.add('Use SHA-256 fingerprints for better security');
        if (isProduction) {
          recommendations.add('⚠️ URGENT: SSL Pinning must be enabled in production');
        }
      case SSLPinningStatus.invalid:
        recommendations.add('Fix the certificate fingerprint configuration');
        recommendations.addAll(validation.issues.map((i) => '• Fix: $i'));
      case SSLPinningStatus.unsupported:
        recommendations.add('Implement HSTS headers for web security');
        recommendations.add('Use secure cookies with SameSite attribute');
        recommendations.add('Enable Content-Security-Policy headers');
      case SSLPinningStatus.enabled:
        recommendations.add('Regularly update certificate fingerprints');
        recommendations.add('Monitor certificate expiry dates');
        recommendations.add('Test SSL Pinning in staging environment');
    }

    return recommendations;
  }

  /// فحص سريع لحالة SSL
  static SSLPinningStatus quickCheck({
    required Map<String, String> certificateFingerprints,
  }) {
    if (kIsWeb) return SSLPinningStatus.unsupported;
    if (certificateFingerprints.isEmpty) return SSLPinningStatus.disabled;

    // فحص سريع للتنسيق
    for (final fp in certificateFingerprints.values) {
      final clean = fp.replaceAll(RegExp(r'[\s:]'), '');
      if (clean.length != _sha256Length && clean.length != _sha1Length) {
        return SSLPinningStatus.invalid;
      }
    }

    return SSLPinningStatus.enabled;
  }
}

/// نتيجة التحقق من fingerprint
class _FingerprintValidation {
  final CertificateInfo certificate;
  final List<String> issues;
  final List<String> warnings;
  final bool isValid;

  const _FingerprintValidation({
    required this.certificate,
    required this.issues,
    required this.warnings,
    required this.isValid,
  });
}

/// Mixin للتطبيقات التي تستخدم SSL Pinning
mixin SSLPinningMixin {
  /// الحصول على certificate fingerprints
  Map<String, String> get certificateFingerprints;

  /// هل التطبيق في production؟
  bool get isProductionMode;

  /// التحقق من SSL Pinning عند بدء التطبيق
  Future<void> validateSSLPinning() async {
    final result = await SSLPinningValidator.validate(
      certificateFingerprints: certificateFingerprints,
      isProduction: isProductionMode,
    );

    if (!result.isValid && isProductionMode) {
      throw SSLPinningException(
        'SSL Pinning validation failed: ${result.issues.join(", ")}',
      );
    }

    SSLPinningValidator.warnIfDisabled(
      certificateFingerprints: certificateFingerprints,
      isProduction: isProductionMode,
    );
  }
}

/// استثناء SSL Pinning
class SSLPinningException implements Exception {
  final String message;

  const SSLPinningException(this.message);

  @override
  String toString() => 'SSLPinningException: $message';
}
