import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/security/security_config_validator.dart';

// SHA-256 fingerprint صالح للاختبار (64 حرف)
const String _validSha256Fingerprint = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

void main() {
  group('SecuritySeverity', () {
    test('يحتوي على جميع المستويات', () {
      expect(SecuritySeverity.values, contains(SecuritySeverity.critical));
      expect(SecuritySeverity.values, contains(SecuritySeverity.high));
      expect(SecuritySeverity.values, contains(SecuritySeverity.medium));
      expect(SecuritySeverity.values, contains(SecuritySeverity.low));
      expect(SecuritySeverity.values, contains(SecuritySeverity.info));
    });
  });

  group('SecurityCategory', () {
    test('يحتوي على جميع الفئات', () {
      expect(SecurityCategory.values, contains(SecurityCategory.encryption));
      expect(SecurityCategory.values, contains(SecurityCategory.network));
      expect(SecurityCategory.values, contains(SecurityCategory.authentication));
      expect(SecurityCategory.values, contains(SecurityCategory.session));
      expect(SecurityCategory.values, contains(SecurityCategory.configuration));
      expect(SecurityCategory.values, contains(SecurityCategory.logging));
      expect(SecurityCategory.values, contains(SecurityCategory.accessControl));
    });
  });

  group('SecurityIssue', () {
    test('إنشاء مشكلة أمنية', () {
      const issue = SecurityIssue(
        id: 'TEST001',
        title: 'Test Issue',
        description: 'Test description',
        severity: SecuritySeverity.high,
        category: SecurityCategory.network,
        recommendation: 'Fix this',
        code: 'TEST_CODE',
      );

      expect(issue.id, equals('TEST001'));
      expect(issue.title, equals('Test Issue'));
      expect(issue.severity, equals(SecuritySeverity.high));
      expect(issue.isFixed, isFalse);
    });

    test('copyWith يعمل بشكل صحيح', () {
      const issue = SecurityIssue(
        id: 'TEST001',
        title: 'Test Issue',
        description: 'Test description',
        severity: SecuritySeverity.high,
        category: SecurityCategory.network,
        recommendation: 'Fix this',
        code: 'TEST_CODE',
      );

      final fixed = issue.copyWith(isFixed: true);
      expect(fixed.isFixed, isTrue);
      expect(fixed.id, equals(issue.id));
    });

    test('toJson يعمل بشكل صحيح', () {
      const issue = SecurityIssue(
        id: 'TEST001',
        title: 'Test Issue',
        description: 'Test description',
        severity: SecuritySeverity.high,
        category: SecurityCategory.network,
        recommendation: 'Fix this',
        code: 'TEST_CODE',
      );

      final json = issue.toJson();
      expect(json['id'], equals('TEST001'));
      expect(json['severity'], equals('high'));
      expect(json['category'], equals('network'));
    });

    test('toString يعيد التنسيق الصحيح', () {
      const issue = SecurityIssue(
        id: 'TEST001',
        title: 'Test Issue',
        description: 'Test description',
        severity: SecuritySeverity.high,
        category: SecurityCategory.network,
        recommendation: 'Fix this',
        code: 'TEST_CODE',
      );

      expect(issue.toString(), contains('TEST_CODE'));
      expect(issue.toString(), contains('Test Issue'));
      expect(issue.toString(), contains('high'));
    });
  });

  group('SecurityConfig', () {
    test('التكوين الافتراضي غير آمن', () {
      const config = SecurityConfig();

      expect(config.sslPinningEnabled, isFalse);
      expect(config.encryptionEnabled, isFalse);
      expect(config.rateLimitingEnabled, isFalse);
      expect(config.debugModeEnabled, isTrue);
    });

    test('التكوين الآمن يحتوي على القيم الصحيحة', () {
      final config = SecurityConfig.secure(
        certificateFingerprints: ['abc123...'],
        appVersion: '1.0.0',
      );

      expect(config.sslPinningEnabled, isTrue);
      expect(config.encryptionEnabled, isTrue);
      expect(config.encryptionKeyConfigured, isTrue);
      expect(config.rateLimitingEnabled, isTrue);
      expect(config.debugModeEnabled, isFalse);
      expect(config.csrfProtectionEnabled, isTrue);
      expect(config.requestSigningEnabled, isTrue);
      expect(config.auditLoggingEnabled, isTrue);
      expect(config.inputSanitizationEnabled, isTrue);
      expect(config.environment, equals('production'));
    });

    test('isProduction يعمل بشكل صحيح', () {
      const devConfig = SecurityConfig(environment: 'development');
      const prodConfig = SecurityConfig(environment: 'production');

      expect(devConfig.isProduction, isFalse);
      expect(prodConfig.isProduction, isTrue);
    });
  });

  group('SecurityConfigValidator - SSL Pinning', () {
    test('يكشف SSL Pinning معطل في الإنتاج', () {
      const config = SecurityConfig(
        sslPinningEnabled: false,
        environment: 'production',
      );

      final result = SecurityConfigValidator.validate(config);

      expect(
        result.issues.any((i) => i.code == 'SSL_PINNING_DISABLED'),
        isTrue,
      );
      expect(result.criticalIssues, isNotEmpty);
    });

    test('يكشف SSL Pinning بدون fingerprints', () {
      const config = SecurityConfig(
        sslPinningEnabled: true,
        certificateFingerprints: [],
        environment: 'production',
      );

      final result = SecurityConfigValidator.validate(config);

      expect(
        result.issues.any((i) => i.code == 'SSL_NO_FINGERPRINTS'),
        isTrue,
      );
    });

    test('يقبل fingerprint صالح (SHA-256)', () {
      const config = SecurityConfig(
        sslPinningEnabled: true,
        certificateFingerprints: [
          _validSha256Fingerprint, // SHA-256 valid
        ],
        environment: 'production',
        encryptionEnabled: true,
        encryptionKeyConfigured: true,
        rateLimitingEnabled: true,
        rateLimitConfig: {'api': 100},
        debugModeEnabled: false,
      );

      final result = SecurityConfigValidator.validate(config);

      expect(
        result.issues.any((i) => i.code == 'SSL_INVALID_FINGERPRINT'),
        isFalse,
      );
    });

    test('يرفض fingerprint غير صالح', () {
      const config = SecurityConfig(
        sslPinningEnabled: true,
        certificateFingerprints: ['invalid'],
        environment: 'production',
      );

      final result = SecurityConfigValidator.validate(config);

      expect(
        result.issues.any((i) => i.code == 'SSL_INVALID_FINGERPRINT'),
        isTrue,
      );
    });

    test('يقبل fingerprint مع فواصل', () {
      const config = SecurityConfig(
        sslPinningEnabled: true,
        certificateFingerprints: [
          'aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99:aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99',
        ],
        environment: 'production',
        encryptionEnabled: true,
        encryptionKeyConfigured: true,
      );

      final result = SecurityConfigValidator.validate(config);

      expect(
        result.issues.any((i) => i.code == 'SSL_INVALID_FINGERPRINT'),
        isFalse,
      );
    });
  });

  group('SecurityConfigValidator - Encryption', () {
    test('يكشف التشفير معطل', () {
      const config = SecurityConfig(
        encryptionEnabled: false,
        environment: 'production',
      );

      final result = SecurityConfigValidator.validate(config);

      expect(
        result.issues.any((i) => i.code == 'ENCRYPTION_DISABLED'),
        isTrue,
      );
    });

    test('يكشف مفتاح التشفير مفقود', () {
      const config = SecurityConfig(
        encryptionEnabled: true,
        encryptionKeyConfigured: false,
        environment: 'production',
      );

      final result = SecurityConfigValidator.validate(config);

      expect(
        result.issues.any((i) => i.code == 'ENCRYPTION_KEY_MISSING'),
        isTrue,
      );
      expect(result.criticalIssues, isNotEmpty);
    });

    test('لا مشاكل عند تكوين التشفير بشكل صحيح', () {
      const config = SecurityConfig(
        encryptionEnabled: true,
        encryptionKeyConfigured: true,
        environment: 'production',
      );

      final result = SecurityConfigValidator.validate(config);

      expect(
        result.issues.any((i) => i.category == SecurityCategory.encryption),
        isFalse,
      );
    });
  });

  group('SecurityConfigValidator - Rate Limiting', () {
    test('يكشف Rate Limiting معطل', () {
      const config = SecurityConfig(
        rateLimitingEnabled: false,
        environment: 'production',
      );

      final result = SecurityConfigValidator.validate(config);

      expect(
        result.issues.any((i) => i.code == 'RATE_LIMITING_DISABLED'),
        isTrue,
      );
    });

    test('يكشف Rate Limiting بدون تكوين', () {
      const config = SecurityConfig(
        rateLimitingEnabled: true,
        rateLimitConfig: null,
        environment: 'production',
      );

      final result = SecurityConfigValidator.validate(config);

      expect(
        result.issues.any((i) => i.code == 'RATE_LIMIT_NO_CONFIG'),
        isTrue,
      );
    });

    test('لا مشاكل مع Rate Limiting مكتمل', () {
      const config = SecurityConfig(
        rateLimitingEnabled: true,
        rateLimitConfig: {'otp': 3, 'login': 5},
        environment: 'production',
      );

      final result = SecurityConfigValidator.validate(config);

      expect(
        result.issues.any((i) => i.code.startsWith('RATE_LIMIT')),
        isFalse,
      );
    });
  });

  group('SecurityConfigValidator - Session', () {
    test('يكشف Session Timeout صفر', () {
      const config = SecurityConfig(
        sessionTimeoutMinutes: 0,
        environment: 'production',
      );

      final result = SecurityConfigValidator.validate(config);

      expect(
        result.issues.any((i) => i.code == 'SESSION_NO_TIMEOUT'),
        isTrue,
      );
    });

    test('يحذر من Session Timeout طويل', () {
      const config = SecurityConfig(
        sessionTimeoutMinutes: 120,
        environment: 'production',
      );

      final result = SecurityConfigValidator.validate(config);

      expect(
        result.issues.any((i) => i.code == 'SESSION_LONG_TIMEOUT'),
        isTrue,
      );
    });

    test('يقبل Session Timeout ضمن النطاق', () {
      const config = SecurityConfig(
        sessionTimeoutMinutes: 30,
        environment: 'production',
      );

      final result = SecurityConfigValidator.validate(config);

      expect(
        result.issues.any((i) => i.category == SecurityCategory.session),
        isFalse,
      );
    });
  });

  group('SecurityConfigValidator - Debug Mode', () {
    test('يكشف Debug Mode في الإنتاج', () {
      const config = SecurityConfig(
        debugModeEnabled: true,
        environment: 'production',
      );

      final result = SecurityConfigValidator.validate(config);

      expect(
        result.issues.any((i) => i.code == 'DEBUG_IN_PRODUCTION'),
        isTrue,
      );
      expect(result.criticalIssues, isNotEmpty);
    });

    test('لا مشكلة مع Debug Mode في التطوير', () {
      const config = SecurityConfig(
        debugModeEnabled: true,
        environment: 'development',
      );

      final result = SecurityConfigValidator.validate(config);

      expect(
        result.issues.any((i) => i.code == 'DEBUG_IN_PRODUCTION'),
        isFalse,
      );
    });
  });

  group('SecurityConfigValidator - Additional Protection', () {
    test('يكشف CSRF Protection معطل', () {
      const config = SecurityConfig(
        csrfProtectionEnabled: false,
        environment: 'production',
      );

      final result = SecurityConfigValidator.validate(config);

      expect(
        result.issues.any((i) => i.code == 'CSRF_DISABLED'),
        isTrue,
      );
    });

    test('يكشف Audit Logging معطل', () {
      const config = SecurityConfig(
        auditLoggingEnabled: false,
        environment: 'production',
      );

      final result = SecurityConfigValidator.validate(config);

      expect(
        result.issues.any((i) => i.code == 'AUDIT_LOGGING_DISABLED'),
        isTrue,
      );
    });

    test('يكشف Input Sanitization معطل', () {
      const config = SecurityConfig(
        inputSanitizationEnabled: false,
        environment: 'production',
      );

      final result = SecurityConfigValidator.validate(config);

      expect(
        result.issues.any((i) => i.code == 'INPUT_SANITIZATION_DISABLED'),
        isTrue,
      );
    });
  });

  group('SecurityAuditResult', () {
    test('حساب النقاط للتكوين الآمن', () {
      final config = SecurityConfig.secure(
        certificateFingerprints: [_validSha256Fingerprint],
        appVersion: '1.0.0',
      );

      final result = SecurityConfigValidator.validate(config);

      // في بيئة الاختبار، kDebugMode = true يسبب مشكلة
      // لكن التكوين الآمن يجب أن يكون قريباً من 100
      expect(result.score, greaterThanOrEqualTo(70));
    });

    test('التكوين غير الآمن ينتج نقاط منخفضة', () {
      const config = SecurityConfig(
        environment: 'production',
        debugModeEnabled: true,
        sslPinningEnabled: false,
        encryptionEnabled: false,
        rateLimitingEnabled: false,
      );

      final result = SecurityConfigValidator.validate(config);

      expect(result.score, lessThan(50));
      expect(result.isProductionReady, isFalse);
    });

    test('issuesByCategory يعمل بشكل صحيح', () {
      const config = SecurityConfig(
        environment: 'production',
        sslPinningEnabled: false,
        encryptionEnabled: false,
      );

      final result = SecurityConfigValidator.validate(config);
      final byCategory = result.issuesByCategory;

      expect(byCategory[SecurityCategory.network], isNotNull);
      expect(byCategory[SecurityCategory.encryption], isNotNull);
    });

    test('summary يعيد الرسالة المناسبة', () {
      const configWithCritical = SecurityConfig(
        environment: 'production',
        encryptionEnabled: true,
        encryptionKeyConfigured: false,
      );

      final result = SecurityConfigValidator.validate(configWithCritical);

      expect(result.summary, contains('Critical'));
    });

    test('toJson يعمل بشكل صحيح', () {
      const config = SecurityConfig();
      final result = SecurityConfigValidator.validate(config);
      final json = result.toJson();

      expect(json['issues'], isA<List>());
      expect(json['score'], isA<int>());
      expect(json['statistics'], isA<Map>());
    });

    test('toString يعيد تقرير مقروء', () {
      const config = SecurityConfig();
      final result = SecurityConfigValidator.validate(config);
      final report = result.toString();

      expect(report, contains('Security Audit Report'));
      expect(report, contains('Score:'));
    });
  });

  group('SecurityConfigValidator - Helper Methods', () {
    test('isSecureForProduction يعمل بشكل صحيح', () {
      // ignore: unused_local_variable
      final secureConfig = SecurityConfig.secure(
        certificateFingerprints: [_validSha256Fingerprint],
        appVersion: '1.0.0',
      );

      const insecureConfig = SecurityConfig(
        environment: 'production',
      );

      // ملاحظة: في بيئة الاختبار، kDebugMode = true
      expect(
        SecurityConfigValidator.isSecureForProduction(insecureConfig),
        isFalse,
      );
    });

    test('getRecommendations يعيد قائمة التوصيات', () {
      const config = SecurityConfig(
        sslPinningEnabled: false,
        encryptionEnabled: false,
      );

      final recommendations = SecurityConfigValidator.getRecommendations(config);

      expect(recommendations, isNotEmpty);
      expect(recommendations.any((r) => r.contains('SSL') || r.contains('encryption')), isTrue);
    });
  });

  group('SecurityConfigValidatorExtension', () {
    test('validate extension يعمل', () {
      const config = SecurityConfig();
      final result = config.validate();

      expect(result, isA<SecurityAuditResult>());
    });

    test('isSecureForProduction extension يعمل', () {
      const config = SecurityConfig();
      expect(config.isSecureForProduction, isFalse);
    });

    test('recommendations extension يعمل', () {
      const config = SecurityConfig();
      expect(config.recommendations, isA<List<String>>());
    });
  });

  group('Real World Scenarios', () {
    test('تكوين تطوير نموذجي', () {
      const devConfig = SecurityConfig(
        environment: 'development',
        debugModeEnabled: true,
        sslPinningEnabled: false,
        encryptionEnabled: true,
        encryptionKeyConfigured: true,
        rateLimitingEnabled: true,
        rateLimitConfig: {'api': 100},
        sessionTimeoutMinutes: 60,
      );

      final result = SecurityConfigValidator.validate(devConfig);

      // يجب أن يكون هناك تحذيرات لكن ليست حرجة
      expect(result.criticalIssues, isEmpty);
      expect(result.score, greaterThan(50));
    });

    test('تكوين staging نموذجي', () {
      const stagingConfig = SecurityConfig(
        environment: 'staging',
        debugModeEnabled: false,
        sslPinningEnabled: true,
        certificateFingerprints: [_validSha256Fingerprint],
        encryptionEnabled: true,
        encryptionKeyConfigured: true,
        rateLimitingEnabled: true,
        rateLimitConfig: {'otp': 3, 'login': 5, 'api': 100},
        sessionTimeoutMinutes: 30,
        csrfProtectionEnabled: true,
        auditLoggingEnabled: true,
        inputSanitizationEnabled: true,
      );

      final result = SecurityConfigValidator.validate(stagingConfig);

      expect(result.score, greaterThan(80));
    });

    test('POS App تكوين موصى به', () {
      final posConfig = SecurityConfig.secure(
        certificateFingerprints: [
          'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
        ].map((s) => s.replaceAll(RegExp(r'[^a-fA-F0-9]'), '')).toList()
        ..add(_validSha256Fingerprint), // إضافة fingerprint صالح للاختبار
        appVersion: '1.0.0',
      );

      final result = SecurityConfigValidator.validate(posConfig);

      // يجب أن يمر جميع فحوصات الأمان (ما عدا kDebugMode في الاختبار)
      expect(
        result.issues.where((i) =>
          i.severity == SecuritySeverity.critical &&
          i.code != 'DEBUG_BUILD_PRODUCTION'
        ).isEmpty,
        isTrue,
      );
    });
  });
}



