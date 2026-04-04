import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:cashier/core/services/zatca/zatca_tlv_encoder.dart';
import 'package:cashier/core/services/zatca/zatca_qr_service.dart';
import 'package:cashier/core/services/zatca/vat_calculator.dart';

void main() {
  group('ZatcaTlvEncoder', () {
    group('encode', () {
      test('should produce valid TLV bytes with all 5 tags', () {
        final bytes = ZatcaTlvEncoder.encode(
          sellerName: 'Al-HAI Store',
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 3, 1, 14, 30),
          totalWithVat: 115.0,
          vatAmount: 15.0,
        );

        final tags = ZatcaTlvEncoder.decode(bytes);

        expect(tags.length, equals(5));
        expect(tags[1], equals('Al-HAI Store'));
        expect(tags[2], equals('300000000000003'));
        expect(tags[3], contains('2026'));
        expect(tags[4], equals('115.00'));
        expect(tags[5], equals('15.00'));
      });

      test('should encode Arabic seller name correctly', () {
        final bytes = ZatcaTlvEncoder.encode(
          sellerName: 'متجر الهاي',
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 1, 1),
          totalWithVat: 50.0,
          vatAmount: 6.52,
        );

        final tags = ZatcaTlvEncoder.decode(bytes);
        expect(tags[1], equals('متجر الهاي'));
      });

      test('should format amounts to 2 decimal places', () {
        final bytes = ZatcaTlvEncoder.encode(
          sellerName: 'Test',
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 1, 1),
          totalWithVat: 99.9,
          vatAmount: 13.0347826,
        );

        final tags = ZatcaTlvEncoder.decode(bytes);
        expect(tags[4], equals('99.90'));
        expect(tags[5], equals('13.03'));
      });

      test('should handle zero amounts', () {
        final bytes = ZatcaTlvEncoder.encode(
          sellerName: 'Store',
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 1, 1),
          totalWithVat: 0.0,
          vatAmount: 0.0,
        );

        final tags = ZatcaTlvEncoder.decode(bytes);
        expect(tags[4], equals('0.00'));
        expect(tags[5], equals('0.00'));
      });

      test('should handle very large amounts', () {
        final bytes = ZatcaTlvEncoder.encode(
          sellerName: 'Store',
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 6, 15),
          totalWithVat: 999999.99,
          vatAmount: 130434.78,
        );

        final tags = ZatcaTlvEncoder.decode(bytes);
        expect(tags[4], equals('999999.99'));
        expect(tags[5], equals('130434.78'));
      });

      test('TLV tags should be in sequential order 1-5', () {
        final bytes = ZatcaTlvEncoder.encode(
          sellerName: 'Test',
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 1, 1),
          totalWithVat: 100.0,
          vatAmount: 13.04,
        );

        // Parse tag numbers in order
        final tagOrder = <int>[];
        int index = 0;
        while (index < bytes.length) {
          tagOrder.add(bytes[index]);
          final length = bytes[index + 1];
          index += 2 + length;
        }

        expect(tagOrder, equals([1, 2, 3, 4, 5]));
      });
    });

    group('encodeToBase64', () {
      test('should return valid Base64 string', () {
        final result = ZatcaTlvEncoder.encodeToBase64(
          sellerName: 'Al-HAI Store',
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 1, 15, 10, 30),
          totalWithVat: 115.0,
          vatAmount: 15.0,
        );

        expect(() => base64Decode(result), returnsNormally);
      });

      test('should produce same result as encode + base64Encode', () {
        final timestamp = DateTime(2026, 3, 1, 12, 0);
        final bytes = ZatcaTlvEncoder.encode(
          sellerName: 'Store',
          vatNumber: '300000000000003',
          timestamp: timestamp,
          totalWithVat: 200.0,
          vatAmount: 26.09,
        );
        final directBase64 = base64Encode(bytes);

        final serviceBase64 = ZatcaTlvEncoder.encodeToBase64(
          sellerName: 'Store',
          vatNumber: '300000000000003',
          timestamp: timestamp,
          totalWithVat: 200.0,
          vatAmount: 26.09,
        );

        expect(serviceBase64, equals(directBase64));
      });
    });

    group('decode', () {
      test('should decode TLV bytes back to original values', () {
        final original = {
          'sellerName': 'Test Store',
          'vatNumber': '300000000000003',
          'total': 230.0,
          'vat': 30.0,
        };
        final timestamp = DateTime(2026, 2, 15, 9, 45);

        final bytes = ZatcaTlvEncoder.encode(
          sellerName: original['sellerName'] as String,
          vatNumber: original['vatNumber'] as String,
          timestamp: timestamp,
          totalWithVat: original['total'] as double,
          vatAmount: original['vat'] as double,
        );

        final decoded = ZatcaTlvEncoder.decode(bytes);

        expect(decoded[1], equals(original['sellerName']));
        expect(decoded[2], equals(original['vatNumber']));
        expect(decoded[3], equals(timestamp.toIso8601String()));
        expect(decoded[4], equals('230.00'));
        expect(decoded[5], equals('30.00'));
      });

      test('should handle empty bytes gracefully', () {
        final decoded = ZatcaTlvEncoder.decode(Uint8List(0));
        expect(decoded, isEmpty);
      });
    });

    group('decodeFromBase64', () {
      test('should roundtrip encode → decode correctly', () {
        final base64 = ZatcaTlvEncoder.encodeToBase64(
          sellerName: 'متجر الهاي',
          vatNumber: '312345678901234',
          timestamp: DateTime(2026, 6, 1, 15, 0),
          totalWithVat: 575.0,
          vatAmount: 75.0,
        );

        final decoded = ZatcaTlvEncoder.decodeFromBase64(base64);

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

        final decoded = ZatcaTlvEncoder.decodeFromBase64(qrData);
        expect(decoded.length, equals(5));
        expect(decoded[1], equals('Al-HAI Store'));
        expect(decoded[2], equals('300000000000003'));
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

  group('VatCalculator', () {
    group('calculateVat', () {
      test('calculates 15% VAT correctly', () {
        expect(VatCalculator.calculateVat(100), closeTo(15.0, 0.001));
        expect(VatCalculator.calculateVat(200), closeTo(30.0, 0.001));
        expect(VatCalculator.calculateVat(0), equals(0.0));
      });

      test('supports custom VAT rate', () {
        expect(
          VatCalculator.calculateVat(100, rate: 0.10),
          closeTo(10.0, 0.001),
        );
        expect(
          VatCalculator.calculateVat(100, rate: 0.05),
          closeTo(5.0, 0.001),
        );
      });
    });

    group('addVat', () {
      test('adds 15% VAT correctly', () {
        expect(VatCalculator.addVat(100), closeTo(115.0, 0.001));
        expect(VatCalculator.addVat(200), closeTo(230.0, 0.001));
        expect(VatCalculator.addVat(0), equals(0.0));
      });
    });

    group('removeVat', () {
      test('extracts amount before VAT from total', () {
        expect(VatCalculator.removeVat(115), closeTo(100.0, 0.01));
        expect(VatCalculator.removeVat(230), closeTo(200.0, 0.01));
        expect(VatCalculator.removeVat(0), equals(0.0));
      });
    });

    group('extractVat', () {
      test('extracts VAT amount from total including VAT', () {
        expect(VatCalculator.extractVat(115), closeTo(15.0, 0.01));
        expect(VatCalculator.extractVat(230), closeTo(30.0, 0.01));
        expect(VatCalculator.extractVat(0), equals(0.0));
      });
    });

    group('breakdown', () {
      test('calculates full invoice breakdown', () {
        final result = VatCalculator.breakdown(100);

        expect(result.subtotal, equals(100));
        expect(result.discount, equals(0));
        expect(result.taxableAmount, equals(100));
        expect(result.vatRate, equals(0.15));
        expect(result.vatAmount, closeTo(15.0, 0.001));
        expect(result.total, closeTo(115.0, 0.001));
      });

      test('calculates breakdown with discount', () {
        final result = VatCalculator.breakdown(100, discount: 20);

        expect(result.subtotal, equals(100));
        expect(result.discount, equals(20));
        expect(result.taxableAmount, equals(80));
        expect(result.vatAmount, closeTo(12.0, 0.001));
        expect(result.total, closeTo(92.0, 0.001));
      });

      test('calculates breakdown with custom rate', () {
        final result = VatCalculator.breakdown(100, rate: 0.10);

        expect(result.vatRate, equals(0.10));
        expect(result.vatAmount, closeTo(10.0, 0.001));
        expect(result.total, closeTo(110.0, 0.001));
      });
    });
  });
}
