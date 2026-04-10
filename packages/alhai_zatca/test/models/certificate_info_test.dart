import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_zatca/src/models/certificate_info.dart';

void main() {
  group('CertificateInfo', () {
    const basePem =
        '-----BEGIN CERTIFICATE-----\nMIIB\n-----END CERTIFICATE-----';
    const baseKey =
        '-----BEGIN PRIVATE KEY-----\nMIIC\n-----END PRIVATE KEY-----';

    // ── Construction ─────────────────────────────────────

    group('construction', () {
      test('creates with all required fields', () {
        const info = CertificateInfo(
          certificatePem: basePem,
          privateKeyPem: baseKey,
          csid: 'csid-123',
          secret: 'secret-456',
        );

        expect(info.certificatePem, basePem);
        expect(info.privateKeyPem, baseKey);
        expect(info.csid, 'csid-123');
        expect(info.secret, 'secret-456');
      });

      test('defaults optional fields to null and isProduction to false', () {
        const info = CertificateInfo(
          certificatePem: basePem,
          privateKeyPem: baseKey,
          csid: 'csid',
          secret: 'secret',
        );

        expect(info.serialNumber, isNull);
        expect(info.issuerName, isNull);
        expect(info.subjectName, isNull);
        expect(info.validFrom, isNull);
        expect(info.validTo, isNull);
        expect(info.isProduction, isFalse);
      });

      test('stores all optional fields when provided', () {
        final validFrom = DateTime.utc(2026, 1, 1);
        final validTo = DateTime.utc(2027, 1, 1);

        final info = CertificateInfo(
          certificatePem: basePem,
          privateKeyPem: baseKey,
          csid: 'csid',
          secret: 'secret',
          serialNumber: 'SN-001',
          issuerName: 'ZATCA CA',
          subjectName: 'My Store',
          validFrom: validFrom,
          validTo: validTo,
          isProduction: true,
        );

        expect(info.serialNumber, 'SN-001');
        expect(info.issuerName, 'ZATCA CA');
        expect(info.subjectName, 'My Store');
        expect(info.validFrom, validFrom);
        expect(info.validTo, validTo);
        expect(info.isProduction, isTrue);
      });
    });

    // ── isValid ──────────────────────────────────────────

    group('isValid', () {
      test('returns true when validTo is null (no expiry set)', () {
        const info = CertificateInfo(
          certificatePem: basePem,
          privateKeyPem: baseKey,
          csid: 'csid',
          secret: 'secret',
        );
        expect(info.isValid, isTrue);
      });

      test('returns true when validTo is in the future', () {
        final info = CertificateInfo(
          certificatePem: basePem,
          privateKeyPem: baseKey,
          csid: 'csid',
          secret: 'secret',
          validTo: DateTime.now().add(const Duration(days: 60)),
        );
        expect(info.isValid, isTrue);
      });

      test('returns false when validTo is in the past', () {
        final info = CertificateInfo(
          certificatePem: basePem,
          privateKeyPem: baseKey,
          csid: 'csid',
          secret: 'secret',
          validTo: DateTime.now().subtract(const Duration(days: 1)),
        );
        expect(info.isValid, isFalse);
      });
    });

    // ── daysUntilExpiry ──────────────────────────────────

    group('daysUntilExpiry', () {
      test('returns null when validTo is not set', () {
        const info = CertificateInfo(
          certificatePem: basePem,
          privateKeyPem: baseKey,
          csid: 'csid',
          secret: 'secret',
        );
        expect(info.daysUntilExpiry, isNull);
      });

      test('returns positive days when validTo is in the future', () {
        final info = CertificateInfo(
          certificatePem: basePem,
          privateKeyPem: baseKey,
          csid: 'csid',
          secret: 'secret',
          validTo: DateTime.now().add(const Duration(days: 45)),
        );
        // Allow tolerance for time-of-execution
        expect(info.daysUntilExpiry, inInclusiveRange(43, 45));
      });

      test('returns negative days when validTo is in the past', () {
        final info = CertificateInfo(
          certificatePem: basePem,
          privateKeyPem: baseKey,
          csid: 'csid',
          secret: 'secret',
          validTo: DateTime.now().subtract(const Duration(days: 10)),
        );
        expect(info.daysUntilExpiry, lessThan(0));
      });
    });

    // ── isNearExpiry ─────────────────────────────────────

    group('isNearExpiry', () {
      test('returns false when validTo is null', () {
        const info = CertificateInfo(
          certificatePem: basePem,
          privateKeyPem: baseKey,
          csid: 'csid',
          secret: 'secret',
        );
        expect(info.isNearExpiry, isFalse);
      });

      test('returns true when less than 30 days until expiry', () {
        final info = CertificateInfo(
          certificatePem: basePem,
          privateKeyPem: baseKey,
          csid: 'csid',
          secret: 'secret',
          validTo: DateTime.now().add(const Duration(days: 10)),
        );
        expect(info.isNearExpiry, isTrue);
      });

      test('returns false when more than 30 days until expiry', () {
        final info = CertificateInfo(
          certificatePem: basePem,
          privateKeyPem: baseKey,
          csid: 'csid',
          secret: 'secret',
          validTo: DateTime.now().add(const Duration(days: 90)),
        );
        expect(info.isNearExpiry, isFalse);
      });
    });

    // ── copyWith ─────────────────────────────────────────

    group('copyWith', () {
      test('returns identical copy when no arguments given', () {
        const info = CertificateInfo(
          certificatePem: basePem,
          privateKeyPem: baseKey,
          csid: 'csid',
          secret: 'secret',
          isProduction: true,
        );
        final copy = info.copyWith();
        expect(copy.certificatePem, info.certificatePem);
        expect(copy.privateKeyPem, info.privateKeyPem);
        expect(copy.csid, info.csid);
        expect(copy.secret, info.secret);
        expect(copy.isProduction, info.isProduction);
      });

      test('updates only specified fields', () {
        const info = CertificateInfo(
          certificatePem: basePem,
          privateKeyPem: baseKey,
          csid: 'old-csid',
          secret: 'old-secret',
        );
        final updated = info.copyWith(
          csid: 'new-csid',
          isProduction: true,
        );
        expect(updated.csid, 'new-csid');
        expect(updated.isProduction, isTrue);
        // Unchanged
        expect(updated.certificatePem, basePem);
        expect(updated.secret, 'old-secret');
      });
    });

    // ── Serialization ────────────────────────────────────

    group('toJson / fromJson', () {
      test('roundtrips with minimal fields', () {
        const info = CertificateInfo(
          certificatePem: basePem,
          privateKeyPem: baseKey,
          csid: 'csid',
          secret: 'secret',
        );
        final json = info.toJson();
        final restored = CertificateInfo.fromJson(json);

        expect(restored.certificatePem, info.certificatePem);
        expect(restored.privateKeyPem, info.privateKeyPem);
        expect(restored.csid, info.csid);
        expect(restored.secret, info.secret);
        expect(restored.isProduction, isFalse);
        expect(restored.serialNumber, isNull);
      });

      test('roundtrips with all fields including dates', () {
        final validFrom = DateTime.utc(2026, 1, 1);
        final validTo = DateTime.utc(2027, 6, 30);

        final info = CertificateInfo(
          certificatePem: basePem,
          privateKeyPem: baseKey,
          csid: 'csid',
          secret: 'secret',
          serialNumber: 'SN-999',
          issuerName: 'Issuer',
          subjectName: 'Subject',
          validFrom: validFrom,
          validTo: validTo,
          isProduction: true,
        );

        final json = info.toJson();
        final restored = CertificateInfo.fromJson(json);

        expect(restored.serialNumber, 'SN-999');
        expect(restored.issuerName, 'Issuer');
        expect(restored.subjectName, 'Subject');
        expect(restored.validFrom, validFrom);
        expect(restored.validTo, validTo);
        expect(restored.isProduction, isTrue);
      });

      test('toJson omits null optional fields', () {
        const info = CertificateInfo(
          certificatePem: basePem,
          privateKeyPem: baseKey,
          csid: 'csid',
          secret: 'secret',
        );
        final json = info.toJson();
        expect(json.containsKey('serialNumber'), isFalse);
        expect(json.containsKey('issuerName'), isFalse);
        expect(json.containsKey('validFrom'), isFalse);
        expect(json.containsKey('validTo'), isFalse);
      });

      test('fromJson defaults isProduction to false when missing', () {
        final json = <String, dynamic>{
          'certificatePem': basePem,
          'privateKeyPem': baseKey,
          'csid': 'csid',
          'secret': 'secret',
        };
        final info = CertificateInfo.fromJson(json);
        expect(info.isProduction, isFalse);
      });
    });
  });
}
