import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_zatca/alhai_zatca.dart' show ZatcaTlvEncoder;
import 'package:cashier/core/services/zatca/zatca_qr_service.dart';

void main() {
  late ZatcaTlvEncoder encoder;

  setUp(() {
    encoder = ZatcaTlvEncoder();
  });

  group('ZatcaTlvEncoder (package)', () {
    group('encodeSimplified', () {
      test('should produce valid base64 with all 5 tags', () {
        final base64 = encoder.encodeSimplified(
          sellerName: 'Al-HAI Store',
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 3, 1, 14, 30),
          totalWithVat: 115.0,
          vatAmount: 15.0,
        );

        final tags = encoder.decodeToStrings(base64);

        expect(tags.length, equals(5));
        expect(tags[1], equals('Al-HAI Store'));
        expect(tags[2], equals('300000000000003'));
        expect(tags[3], contains('2026'));
        expect(tags[4], equals('115.00'));
        expect(tags[5], equals('15.00'));
      });

      test('should encode Arabic seller name correctly', () {
        final base64 = encoder.encodeSimplified(
          sellerName: 'متجر الهاي',
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 1, 1),
          totalWithVat: 50.0,
          vatAmount: 6.52,
        );

        final tags = encoder.decodeToStrings(base64);
        expect(tags[1], equals('متجر الهاي'));
      });

      test('should format amounts to 2 decimal places', () {
        final base64 = encoder.encodeSimplified(
          sellerName: 'Test',
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 1, 1),
          totalWithVat: 99.9,
          vatAmount: 13.0347826,
        );

        final tags = encoder.decodeToStrings(base64);
        expect(tags[4], equals('99.90'));
        expect(tags[5], equals('13.03'));
      });

      test('should handle zero amounts', () {
        final base64 = encoder.encodeSimplified(
          sellerName: 'Store',
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 1, 1),
          totalWithVat: 0.0,
          vatAmount: 0.0,
        );

        final tags = encoder.decodeToStrings(base64);
        expect(tags[4], equals('0.00'));
        expect(tags[5], equals('0.00'));
      });

      test('should handle very large amounts', () {
        final base64 = encoder.encodeSimplified(
          sellerName: 'Store',
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 6, 15),
          totalWithVat: 999999.99,
          vatAmount: 130434.78,
        );

        final tags = encoder.decodeToStrings(base64);
        expect(tags[4], equals('999999.99'));
        expect(tags[5], equals('130434.78'));
      });

      test('should return valid Base64 string', () {
        final result = encoder.encodeSimplified(
          sellerName: 'Al-HAI Store',
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 1, 15, 10, 30),
          totalWithVat: 115.0,
          vatAmount: 15.0,
        );

        expect(() => base64Decode(result), returnsNormally);
      });
    });

    group('decode roundtrip', () {
      test('should roundtrip encode -> decode correctly', () {
        final base64 = encoder.encodeSimplified(
          sellerName: 'متجر الهاي',
          vatNumber: '312345678901234',
          timestamp: DateTime(2026, 6, 1, 15, 0),
          totalWithVat: 575.0,
          vatAmount: 75.0,
        );

        final decoded = encoder.decodeToStrings(base64);

        expect(decoded[1], equals('متجر الهاي'));
        expect(decoded[2], equals('312345678901234'));
        expect(decoded[4], equals('575.00'));
        expect(decoded[5], equals('75.00'));
      });
    });
  });

  group('ZatcaQrService', () {
    group('generateQrData', () {
      test('should return valid Base64 with all 5 TLV tags', () {
        final qrData = ZatcaQrService.generateQrData(
          sellerName: 'Al-HAI Store',
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 3, 1),
          totalWithVat: 115.0,
          vatAmount: 15.0,
        );

        final decoded = encoder.decodeToStrings(qrData);
        expect(decoded.length, equals(5));
        expect(decoded[1], equals('Al-HAI Store'));
        expect(decoded[2], equals('300000000000003'));
      });

      test('tag 3 timestamp is emitted in UTC (ends with Z)', () {
        // Local time in any non-UTC zone must be converted to UTC before
        // being written to TLV tag 3 (ZATCA QR compliance).
        final localTs = DateTime(2026, 3, 1, 14, 30);
        final qrData = ZatcaQrService.generateQrData(
          sellerName: 'Al-HAI Store',
          vatNumber: '300000000000003',
          timestamp: localTs,
          totalWithVat: 115.0,
          vatAmount: 15.0,
        );
        final tags = encoder.decodeToStrings(qrData);
        expect(
          tags[3],
          equals(localTs.toUtc().toIso8601String()),
          reason: 'Tag 3 must be UTC ISO-8601 (ends with Z)',
        );
        expect(tags[3], endsWith('Z'));
      });

      test('already-UTC timestamp stays UTC', () {
        final utcTs = DateTime.utc(2026, 3, 1, 14, 30);
        final qrData = ZatcaQrService.generateQrData(
          sellerName: 'Al-HAI Store',
          vatNumber: '300000000000003',
          timestamp: utcTs,
          totalWithVat: 115.0,
          vatAmount: 15.0,
        );
        final tags = encoder.decodeToStrings(qrData);
        expect(tags[3], equals(utcTs.toIso8601String()));
        expect(tags[3], endsWith('Z'));
      });

      test('different invoices should produce different QR data', () {
        final qr1 = ZatcaQrService.generateQrData(
          sellerName: 'Store A',
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 1, 1),
          totalWithVat: 100.0,
          vatAmount: 13.04,
        );

        final qr2 = ZatcaQrService.generateQrData(
          sellerName: 'Store B',
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 1, 1),
          totalWithVat: 100.0,
          vatAmount: 13.04,
        );

        expect(qr1, isNot(equals(qr2)));
      });
    });

    group('isValidVatNumber', () {
      test('accepts valid 15-digit VAT starting with 3', () {
        expect(ZatcaQrService.isValidVatNumber('300000000000003'), isTrue);
        expect(ZatcaQrService.isValidVatNumber('312345678901234'), isTrue);
      });

      test('rejects numbers not starting with 3', () {
        expect(ZatcaQrService.isValidVatNumber('100000000000003'), isFalse);
        expect(ZatcaQrService.isValidVatNumber('200000000000003'), isFalse);
      });

      test('rejects wrong length', () {
        expect(ZatcaQrService.isValidVatNumber('30000000000003'), isFalse);
        expect(ZatcaQrService.isValidVatNumber('3000000000000030'), isFalse);
        expect(ZatcaQrService.isValidVatNumber(''), isFalse);
      });

      test('rejects non-digit characters', () {
        expect(ZatcaQrService.isValidVatNumber('30000000000000A'), isFalse);
        expect(ZatcaQrService.isValidVatNumber('300-000-000-000'), isFalse);
      });
    });

    group('formatVatNumber', () {
      test('formats 15-digit VAT with spaces', () {
        expect(
          ZatcaQrService.formatVatNumber('300000000000003'),
          equals('300 000 000 000 003'),
        );
      });

      test('returns input unchanged for invalid length', () {
        expect(ZatcaQrService.formatVatNumber('12345'), equals('12345'));
        expect(ZatcaQrService.formatVatNumber(''), equals(''));
      });
    });

    group('validateQrData', () {
      test('valid QR data passes validation', () {
        final qrData = ZatcaQrService.generateQrData(
          sellerName: 'Store',
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 1, 1),
          totalWithVat: 100.0,
          vatAmount: 13.04,
        );

        expect(ZatcaQrService.validateQrData(qrData), isTrue);
      });

      test('invalid Base64 fails validation', () {
        expect(ZatcaQrService.validateQrData('not-valid-base64!!!'), isFalse);
      });
    });
  });
  // VatCalculator math coverage lives in
  // packages/alhai_zatca/test/qr/vat_calculator_test.dart.
}
