import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_pos/src/services/zatca_service.dart';

void main() {
  group('ZatcaService', () {
    group('generateQrData', () {
      test('should generate valid Base64 encoded TLV data', () {
        final result = ZatcaService.generateQrData(
          sellerName: 'Al-HAI Store',
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 1, 15, 10, 30),
          totalWithVat: 115.0,
          vatAmount: 15.0,
        );

        // Should be valid Base64
        expect(() => base64Decode(result), returnsNormally);
      });

      test('should encode all 5 TLV tags correctly', () {
        final result = ZatcaService.generateQrData(
          sellerName: 'Test',
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 1, 15, 10, 30),
          totalWithVat: 100.00,
          vatAmount: 13.04,
        );

        final decoded = base64Decode(result);
        final bytes = Uint8List.fromList(decoded);

        // Parse TLV structure
        int index = 0;
        final tags = <int, String>{};

        while (index < bytes.length) {
          final tag = bytes[index++];
          final length = bytes[index++];
          final value = utf8.decode(bytes.sublist(index, index + length));
          tags[tag] = value;
          index += length;
        }

        // All 5 ZATCA tags should be present
        expect(tags.length, equals(5));
        expect(tags[1], equals('Test')); // Seller Name
        expect(tags[2], equals('300000000000003')); // VAT Number
        expect(tags[3], isNotEmpty); // Timestamp (ISO 8601)
        expect(tags[4], equals('100.00')); // Total with VAT
        expect(tags[5], equals('13.04')); // VAT Amount
      });

      test('should format amounts to 2 decimal places', () {
        final result = ZatcaService.generateQrData(
          sellerName: 'X',
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 1, 1),
          totalWithVat: 99.9,
          vatAmount: 13.0347826,
        );

        final decoded = base64Decode(result);
        final bytes = Uint8List.fromList(decoded);

        int index = 0;
        final tags = <int, String>{};
        while (index < bytes.length) {
          final tag = bytes[index++];
          final length = bytes[index++];
          final value = utf8.decode(bytes.sublist(index, index + length));
          tags[tag] = value;
          index += length;
        }

        expect(tags[4], equals('99.90'));
        expect(tags[5], equals('13.03'));
      });

      test('should handle Arabic seller name', () {
        final result = ZatcaService.generateQrData(
          sellerName: 'متجر الهاي',
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 1, 1),
          totalWithVat: 50.0,
          vatAmount: 6.52,
        );

        final decoded = base64Decode(result);
        final bytes = Uint8List.fromList(decoded);

        // Tag 1 should be the Arabic seller name
        expect(bytes[0], equals(1)); // Tag 1
        final nameLength = bytes[1];
        final nameBytes = bytes.sublist(2, 2 + nameLength);
        final name = utf8.decode(nameBytes);
        expect(name, equals('متجر الهاي'));
      });
    });

    group('isValidVatNumber', () {
      test('should accept valid 15-digit VAT starting with 3', () {
        expect(ZatcaService.isValidVatNumber('300000000000003'), isTrue);
        expect(ZatcaService.isValidVatNumber('310000000000001'), isTrue);
      });

      test('should reject numbers not starting with 3', () {
        expect(ZatcaService.isValidVatNumber('100000000000003'), isFalse);
        expect(ZatcaService.isValidVatNumber('200000000000003'), isFalse);
      });

      test('should reject numbers with wrong length', () {
        expect(ZatcaService.isValidVatNumber('30000000000003'), isFalse); // 14
        expect(
          ZatcaService.isValidVatNumber('3000000000000030'),
          isFalse,
        ); // 16
        expect(ZatcaService.isValidVatNumber(''), isFalse);
      });

      test('should reject numbers with non-digit characters', () {
        expect(ZatcaService.isValidVatNumber('30000000000000A'), isFalse);
        expect(ZatcaService.isValidVatNumber('300-000-000-000'), isFalse);
      });
    });

    group('formatVatNumber', () {
      test('should format 15-digit VAT number with spaces', () {
        final result = ZatcaService.formatVatNumber('300000000000003');
        expect(result, equals('300 000 000 000 003'));
      });

      test('should return input unchanged if not 15 digits', () {
        expect(ZatcaService.formatVatNumber('12345'), equals('12345'));
        expect(ZatcaService.formatVatNumber(''), equals(''));
      });
    });
  });

  group('ZatcaInvoiceData', () {
    test('should auto-generate QR code on construction', () {
      final invoice = ZatcaInvoiceData(
        sellerName: 'Test Store',
        vatNumber: '300000000000003',
        timestamp: DateTime(2026, 1, 15),
        totalWithVat: 115.0,
        vatAmount: 15.0,
      );

      expect(invoice.qrCode, isNotNull);
      expect(invoice.qrCode, isNotEmpty);
      // Should be valid Base64
      expect(() => base64Decode(invoice.qrCode!), returnsNormally);
    });

    test('fromTotal should calculate VAT correctly', () {
      final invoice = ZatcaInvoiceData.fromTotal(
        sellerName: 'Test',
        vatNumber: '300000000000003',
        timestamp: DateTime(2026, 1, 1),
        totalWithVat: 115.0,
        vatRate: 0.15,
      );

      // 115 / 1.15 = 100, so VAT = 15
      expect(invoice.vatAmount, closeTo(15.0, 0.01));
      expect(invoice.totalWithVat, equals(115.0));
    });

    test('fromTotal with different VAT rate', () {
      final invoice = ZatcaInvoiceData.fromTotal(
        sellerName: 'Test',
        vatNumber: '300000000000003',
        timestamp: DateTime(2026, 1, 1),
        totalWithVat: 110.0,
        vatRate: 0.10,
      );

      // 110 / 1.10 = 100, so VAT = 10
      expect(invoice.vatAmount, closeTo(10.0, 0.01));
    });

    test('fromTotal with zero total', () {
      final invoice = ZatcaInvoiceData.fromTotal(
        sellerName: 'Test',
        vatNumber: '300000000000003',
        timestamp: DateTime(2026, 1, 1),
        totalWithVat: 0.0,
      );

      expect(invoice.vatAmount, equals(0.0));
    });
  });
}
