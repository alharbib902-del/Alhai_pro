import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/security/ssl_pinning_validator.dart';

void main() {
  // SHA-256 fingerprint صالح (64 hex chars)
  const validSha256 =
      'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2';

  // SHA-1 fingerprint صالح (40 hex chars)
  const validSha1 = 'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2';

  group('SSLPinningValidator', () {
    group('validate', () {
      test('يعيد enabled لـ fingerprints صالحة', () async {
        final result = await SSLPinningValidator.validate(
          certificateFingerprints: {
            'api.example.com': validSha256,
          },
        );

        expect(result.status, equals(SSLPinningStatus.enabled));
        expect(result.isValid, isTrue);
        expect(result.issues, isEmpty);
      });

      test('يعيد disabled لـ fingerprints فارغة', () async {
        final result = await SSLPinningValidator.validate(
          certificateFingerprints: {},
        );

        expect(result.status, equals(SSLPinningStatus.disabled));
        expect(result.isValid, isFalse);
      });

      test('يعيد invalid لـ fingerprint غير صالح', () async {
        final result = await SSLPinningValidator.validate(
          certificateFingerprints: {
            'api.example.com': 'invalid-fingerprint',
          },
        );

        expect(result.status, equals(SSLPinningStatus.invalid));
        expect(result.isValid, isFalse);
        expect(result.issues, isNotEmpty);
      });

      test('يكشف SHA-1 مع تحذير', () async {
        final result = await SSLPinningValidator.validate(
          certificateFingerprints: {
            'api.example.com': validSha1,
          },
        );

        expect(result.status, equals(SSLPinningStatus.enabled));
        expect(result.warnings, isNotEmpty);
        expect(
          result.warnings.any((w) => w.contains('SHA-1')),
          isTrue,
        );
      });

      test('يرفض MD5', () async {
        final result = await SSLPinningValidator.validate(
          certificateFingerprints: {
            'api.example.com': 'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4', // 32 chars
          },
        );

        expect(result.status, equals(SSLPinningStatus.invalid));
        expect(result.issues.any((i) => i.contains('MD5')), isTrue);
      });

      test('يتعامل مع fingerprints متعددة', () async {
        final result = await SSLPinningValidator.validate(
          certificateFingerprints: {
            'api.example.com': validSha256,
            'cdn.example.com': validSha256,
          },
        );

        expect(result.status, equals(SSLPinningStatus.enabled));
        expect(result.certificates.length, equals(2));
      });

      test('يضيف تحذيرات production', () async {
        final result = await SSLPinningValidator.validate(
          certificateFingerprints: {
            'api.example.com': validSha256,
          },
          isProduction: true,
        );

        expect(result.warnings, isNotEmpty);
        expect(
          result.warnings.any((w) => w.contains('backup')),
          isTrue,
        );
      });

      test('يكشف خطأ في production بدون fingerprints', () async {
        final result = await SSLPinningValidator.validate(
          certificateFingerprints: {},
          isProduction: true,
        );

        expect(result.status, equals(SSLPinningStatus.disabled));
        expect(result.issues, isNotEmpty);
        expect(
          result.issues.any((i) => i.contains('production')),
          isTrue,
        );
      });
    });

    group('fingerprint format', () {
      test('يقبل fingerprint مع colons', () async {
        const fpWithColons =
            'a1:b2:c3:d4:e5:f6:a1:b2:c3:d4:e5:f6:a1:b2:c3:d4:e5:f6:a1:b2:c3:d4:e5:f6:a1:b2:c3:d4:e5:f6:a1:b2';

        final result = await SSLPinningValidator.validate(
          certificateFingerprints: {
            'api.example.com': fpWithColons,
          },
        );

        expect(result.status, equals(SSLPinningStatus.enabled));
      });

      test('يقبل fingerprint مع مسافات', () async {
        const fpWithSpaces =
            'a1b2c3d4 e5f6a1b2 c3d4e5f6 a1b2c3d4 e5f6a1b2 c3d4e5f6 a1b2c3d4 e5f6a1b2';

        final result = await SSLPinningValidator.validate(
          certificateFingerprints: {
            'api.example.com': fpWithSpaces,
          },
        );

        expect(result.status, equals(SSLPinningStatus.enabled));
      });

      test('يقبل uppercase و lowercase', () async {
        final fpUppercase = validSha256.toUpperCase();

        final result = await SSLPinningValidator.validate(
          certificateFingerprints: {
            'api.example.com': fpUppercase,
          },
        );

        expect(result.status, equals(SSLPinningStatus.enabled));
      });

      test('يرفض fingerprint فارغ', () async {
        final result = await SSLPinningValidator.validate(
          certificateFingerprints: {
            'api.example.com': '',
          },
        );

        expect(result.status, equals(SSLPinningStatus.invalid));
        expect(result.issues.any((i) => i.contains('Empty')), isTrue);
      });

      test('يرفض أحرف غير hex', () async {
        const invalidFp = 'g1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2';

        final result = await SSLPinningValidator.validate(
          certificateFingerprints: {
            'api.example.com': invalidFp,
          },
        );

        expect(result.status, equals(SSLPinningStatus.invalid));
        expect(result.issues.any((i) => i.contains('Invalid characters')), isTrue);
      });
    });

    group('isDomainPinned', () {
      test('يعيد true للـ domain المثبت', () {
        final fps = {'api.example.com': validSha256};
        expect(SSLPinningValidator.isDomainPinned('api.example.com', fps), isTrue);
      });

      test('يعيد false للـ domain غير المثبت', () {
        final fps = {'api.example.com': validSha256};
        expect(SSLPinningValidator.isDomainPinned('other.com', fps), isFalse);
      });
    });

    group('quickCheck', () {
      test('يعيد enabled لـ SHA-256 صالح', () {
        final status = SSLPinningValidator.quickCheck(
          certificateFingerprints: {'api.example.com': validSha256},
        );
        expect(status, equals(SSLPinningStatus.enabled));
      });

      test('يعيد disabled لـ fingerprints فارغة', () {
        final status = SSLPinningValidator.quickCheck(
          certificateFingerprints: {},
        );
        expect(status, equals(SSLPinningStatus.disabled));
      });

      test('يعيد invalid لطول غير صحيح', () {
        final status = SSLPinningValidator.quickCheck(
          certificateFingerprints: {'api.example.com': 'shortfp'},
        );
        expect(status, equals(SSLPinningStatus.invalid));
      });
    });

    group('generateSecurityReport', () {
      test('ينشئ تقرير أمان كامل', () async {
        final report = await SSLPinningValidator.generateSecurityReport(
          certificateFingerprints: {'api.example.com': validSha256},
          isProduction: false,
        );

        expect(report['timestamp'], isNotNull);
        expect(report['platform'], isNotNull);
        expect(report['validation'], isNotNull);
        expect(report['recommendations'], isNotNull);
      });

      test('يضيف توصيات للـ disabled', () async {
        final report = await SSLPinningValidator.generateSecurityReport(
          certificateFingerprints: {},
          isProduction: false,
        );

        final recommendations = report['recommendations'] as List;
        expect(
          recommendations.any((r) => r.toString().contains('Enable')),
          isTrue,
        );
      });

      test('يضيف توصيات عاجلة للـ production', () async {
        final report = await SSLPinningValidator.generateSecurityReport(
          certificateFingerprints: {},
          isProduction: true,
        );

        final recommendations = report['recommendations'] as List;
        expect(
          recommendations.any((r) => r.toString().contains('URGENT')),
          isTrue,
        );
      });
    });
  });

  group('SSLValidationResult', () {
    test('enabled factory يعمل', () {
      final result = SSLValidationResult.enabled(
        certificates: {
          'api.example.com': const CertificateInfo(
            domain: 'api.example.com',
            fingerprint: validSha256,
            type: FingerprintType.sha256,
            isValid: true,
          ),
        },
      );

      expect(result.status, equals(SSLPinningStatus.enabled));
      expect(result.isValid, isTrue);
    });

    test('disabled factory يعمل', () {
      final result = SSLValidationResult.disabled(
        issues: ['No fingerprints'],
      );

      expect(result.status, equals(SSLPinningStatus.disabled));
      expect(result.isValid, isFalse);
    });

    test('invalid factory يعمل', () {
      final result = SSLValidationResult.invalid(
        issues: ['Invalid format'],
      );

      expect(result.status, equals(SSLPinningStatus.invalid));
      expect(result.isValid, isFalse);
    });

    test('toJson يعيد map صحيح', () {
      final result = SSLValidationResult.enabled(
        certificates: {},
        warnings: ['Test warning'],
      );

      final json = result.toJson();

      expect(json['status'], equals('enabled'));
      expect(json['isValid'], isTrue);
      expect(json['warnings'], contains('Test warning'));
    });

    test('toString يعيد تنسيق صحيح', () {
      final result = SSLValidationResult.enabled(certificates: {});
      expect(result.toString(), contains('enabled'));
    });
  });

  group('CertificateInfo', () {
    test('toJson يخفي جزء من الـ fingerprint', () {
      const cert = CertificateInfo(
        domain: 'api.example.com',
        fingerprint: validSha256,
        type: FingerprintType.sha256,
        isValid: true,
      );

      final json = cert.toJson();

      expect(json['fingerprint'], contains('...'));
      expect(json['fingerprint'].length, lessThan(validSha256.length));
    });

    test('يتضمن expiry date إذا موجود', () {
      final cert = CertificateInfo(
        domain: 'api.example.com',
        fingerprint: validSha256,
        type: FingerprintType.sha256,
        isValid: true,
        expiryDate: DateTime(2025, 12, 31),
      );

      final json = cert.toJson();

      expect(json['expiryDate'], isNotNull);
    });
  });

  group('FingerprintType', () {
    test('SHA-256 يكتشف بشكل صحيح', () async {
      final result = await SSLPinningValidator.validate(
        certificateFingerprints: {'test': validSha256},
      );

      expect(
        result.certificates['test']?.type,
        equals(FingerprintType.sha256),
      );
    });

    test('SHA-1 يكتشف بشكل صحيح', () async {
      final result = await SSLPinningValidator.validate(
        certificateFingerprints: {'test': validSha1},
      );

      expect(
        result.certificates['test']?.type,
        equals(FingerprintType.sha1),
      );
    });
  });

  group('SSLPinningException', () {
    test('toString يعيد رسالة صحيحة', () {
      const exception = SSLPinningException('Test error');
      expect(exception.toString(), contains('Test error'));
    });
  });
}


