import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_pos/src/services/zatca_service.dart';

/// Expanded tests for ZatcaService - edge cases and boundary conditions
void main() {
  group('ZatcaService - Expanded', () {
    group('generateQrData edge cases', () {
      test('should handle very large amounts correctly', () {
        // Arrange & Act
        final result = ZatcaService.generateQrData(
          sellerName: 'Store',
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 6, 15, 14, 0),
          totalWithVat: 999999.99,
          vatAmount: 130434.78,
        );

        // Assert - decode and verify large amounts preserved
        final decoded = base64Decode(result);
        final tags = _parseTlv(decoded);
        expect(tags[4], equals('999999.99'));
        expect(tags[5], equals('130434.78'));
      });

      test('should handle zero amounts', () {
        final result = ZatcaService.generateQrData(
          sellerName: 'Store',
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 1, 1),
          totalWithVat: 0.0,
          vatAmount: 0.0,
        );

        final decoded = base64Decode(result);
        final tags = _parseTlv(decoded);
        expect(tags[4], equals('0.00'));
        expect(tags[5], equals('0.00'));
      });

      test('should produce different QR for different timestamps', () {
        final result1 = ZatcaService.generateQrData(
          sellerName: 'Store',
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 1, 1, 10, 0),
          totalWithVat: 100.0,
          vatAmount: 13.04,
        );

        final result2 = ZatcaService.generateQrData(
          sellerName: 'Store',
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 6, 15, 14, 30),
          totalWithVat: 100.0,
          vatAmount: 13.04,
        );

        expect(result1, isNot(equals(result2)));
      });

      test('should handle empty seller name', () {
        final result = ZatcaService.generateQrData(
          sellerName: '',
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 1, 1),
          totalWithVat: 100.0,
          vatAmount: 13.04,
        );

        final decoded = base64Decode(result);
        final tags = _parseTlv(decoded);
        expect(tags[1], equals(''));
      });

      test('should handle long seller name with special characters', () {
        const longName =
            'متجر الهاي للإلكترونيات والأجهزة - فرع الرياض الرئيسي';
        final result = ZatcaService.generateQrData(
          sellerName: longName,
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 1, 1),
          totalWithVat: 100.0,
          vatAmount: 13.04,
        );

        final decoded = base64Decode(result);
        final tags = _parseTlv(decoded);
        expect(tags[1], equals(longName));
      });

      test('TLV tags should be in sequential order 1-5', () {
        final result = ZatcaService.generateQrData(
          sellerName: 'Test',
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 1, 1),
          totalWithVat: 115.0,
          vatAmount: 15.0,
        );

        final decoded = base64Decode(result);
        final bytes = Uint8List.fromList(decoded);

        // Extract tag numbers in order
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

    group('isValidVatNumber edge cases', () {
      test('should reject null-like inputs', () {
        expect(ZatcaService.isValidVatNumber(''), isFalse);
        expect(ZatcaService.isValidVatNumber(' '), isFalse);
      });

      test('should reject VAT numbers with spaces', () {
        expect(ZatcaService.isValidVatNumber('300 000 000 000 003'), isFalse);
      });

      test('should reject VAT numbers with leading/trailing whitespace', () {
        expect(ZatcaService.isValidVatNumber(' 300000000000003'), isFalse);
        expect(ZatcaService.isValidVatNumber('300000000000003 '), isFalse);
      });

      test('should accept various valid 15-digit numbers starting with 3', () {
        expect(ZatcaService.isValidVatNumber('300000000000003'), isTrue);
        expect(ZatcaService.isValidVatNumber('399999999999999'), isTrue);
        expect(ZatcaService.isValidVatNumber('312345678901234'), isTrue);
      });

      test('should reject numbers starting with 0-2 or 4-9', () {
        expect(ZatcaService.isValidVatNumber('000000000000000'), isFalse);
        expect(ZatcaService.isValidVatNumber('100000000000000'), isFalse);
        expect(ZatcaService.isValidVatNumber('200000000000000'), isFalse);
        expect(ZatcaService.isValidVatNumber('400000000000000'), isFalse);
        expect(ZatcaService.isValidVatNumber('500000000000000'), isFalse);
        expect(ZatcaService.isValidVatNumber('900000000000000'), isFalse);
      });
    });

    group('formatVatNumber edge cases', () {
      test('should format correctly with groups of 3', () {
        // 300 000 000 000 003
        final result = ZatcaService.formatVatNumber('312345678901234');
        expect(result, equals('312 345 678 901 234'));
      });

      test('should return input unchanged for various invalid lengths', () {
        expect(ZatcaService.formatVatNumber(''), equals(''));
        expect(ZatcaService.formatVatNumber('3'), equals('3'));
        expect(
          ZatcaService.formatVatNumber('300000000000'),
          equals('300000000000'),
        );
        expect(
          ZatcaService.formatVatNumber('3000000000000030'),
          equals('3000000000000030'),
        );
      });
    });

    group('ZatcaInvoiceData - Expanded', () {
      test('fromTotal should default to 15% VAT rate', () {
        final invoice = ZatcaInvoiceData.fromTotal(
          sellerName: 'Test',
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 1, 1),
          totalWithVat: 230.0,
        );

        // 230 / 1.15 = 200, VAT = 30
        expect(invoice.vatAmount, closeTo(30.0, 0.01));
      });

      test('fromTotal should work with 5% VAT rate', () {
        final invoice = ZatcaInvoiceData.fromTotal(
          sellerName: 'Test',
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 1, 1),
          totalWithVat: 105.0,
          vatRate: 0.05,
        );

        // 105 / 1.05 = 100, VAT = 5
        expect(invoice.vatAmount, closeTo(5.0, 0.01));
      });

      test('fromTotal should handle small amounts with precision', () {
        final invoice = ZatcaInvoiceData.fromTotal(
          sellerName: 'Test',
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 1, 1),
          totalWithVat: 1.15,
        );

        // 1.15 / 1.15 = 1.0, VAT = 0.15
        expect(invoice.vatAmount, closeTo(0.15, 0.01));
      });

      test('constructor should generate QR code matching generateQrData', () {
        final timestamp = DateTime(2026, 3, 15, 12, 0);
        final invoice = ZatcaInvoiceData(
          sellerName: 'My Store',
          vatNumber: '300000000000003',
          timestamp: timestamp,
          totalWithVat: 115.0,
          vatAmount: 15.0,
        );

        final directQr = ZatcaService.generateQrData(
          sellerName: 'My Store',
          vatNumber: '300000000000003',
          timestamp: timestamp,
          totalWithVat: 115.0,
          vatAmount: 15.0,
        );

        expect(invoice.qrCode, equals(directQr));
      });

      test('different invoices should produce different QR codes', () {
        final invoice1 = ZatcaInvoiceData(
          sellerName: 'Store A',
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 1, 1),
          totalWithVat: 100.0,
          vatAmount: 13.04,
        );

        final invoice2 = ZatcaInvoiceData(
          sellerName: 'Store B',
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 1, 1),
          totalWithVat: 100.0,
          vatAmount: 13.04,
        );

        expect(invoice1.qrCode, isNot(equals(invoice2.qrCode)));
      });
    });

    group('TLV length-overflow guard (C-5)', () {
      test(
        'sellerName byte count > 255 throws TlvLengthOverflowException',
        () {
          // 200 Arabic "م" letters × 2 UTF-8 bytes/letter = 400 bytes.
          final overlong = 'م' * 200;
          expect(utf8.encode(overlong).length, greaterThan(255));
          expect(
            () => ZatcaService.generateQrData(
              sellerName: overlong,
              vatNumber: '300000000000003',
              timestamp: DateTime(2026, 1, 1),
              totalWithVat: 100.0,
              vatAmount: 13.04,
            ),
            throwsA(isA<TlvLengthOverflowException>()),
          );
        },
      );

      test('exception reports the offending tag and byte length', () {
        try {
          ZatcaService.generateQrData(
            sellerName: 'x' * 500,
            vatNumber: '300000000000003',
            timestamp: DateTime(2026, 1, 1),
            totalWithVat: 100.0,
            vatAmount: 13.04,
          );
          fail('expected TlvLengthOverflowException');
        } on TlvLengthOverflowException catch (e) {
          expect(e.tag, 1);
          expect(e.byteLength, 500);
          expect(e.toString(), contains('tag 1'));
          expect(e.toString(), contains('500 bytes'));
        }
      });

      test(
        'boundary: 255-byte value still encodes (ASCII "x" × 255)',
        () {
          final edge = 'x' * 255;
          final qr = ZatcaService.generateQrData(
            sellerName: edge,
            vatNumber: '300000000000003',
            timestamp: DateTime(2026, 1, 1),
            totalWithVat: 0,
            vatAmount: 0,
          );
          final decoded = ZatcaService.decodeQrData(qr);
          expect(decoded[1], equals(edge));
        },
      );
    });

    group('encodeTag (C-5)', () {
      test('produces [tag, length, ...value] layout', () {
        final bytes = ZatcaService.encodeTag(1, [0x41, 0x42, 0x43]);
        expect(bytes, equals([1, 3, 0x41, 0x42, 0x43]));
      });

      test('accepts empty value → [tag, 0]', () {
        expect(ZatcaService.encodeTag(7, const []), equals([7, 0]));
      });

      test('rejects tag > 255', () {
        expect(
          () => ZatcaService.encodeTag(256, const [1]),
          throwsArgumentError,
        );
      });

      test('rejects tag < 0', () {
        expect(
          () => ZatcaService.encodeTag(-1, const [1]),
          throwsArgumentError,
        );
      });
    });

    group('decodeQrData (C-5)', () {
      test('round-trips a full 5-tag payload', () {
        final qr = ZatcaService.generateQrData(
          sellerName: 'Round Trip Store',
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 4, 23, 10, 0),
          totalWithVat: 115.0,
          vatAmount: 15.0,
        );
        final decoded = ZatcaService.decodeQrData(qr);
        expect(decoded[1], 'Round Trip Store');
        expect(decoded[2], '300000000000003');
        expect(
          decoded[3],
          DateTime(2026, 4, 23, 10, 0).toIso8601String(),
        );
        expect(decoded[4], '115.00');
        expect(decoded[5], '15.00');
      });

      test('round-trips Arabic UTF-8 cleanly', () {
        final qr = ZatcaService.generateQrData(
          sellerName: 'متجر الهاي',
          vatNumber: '300000000000003',
          timestamp: DateTime(2026, 1, 1),
          totalWithVat: 50.0,
          vatAmount: 6.52,
        );
        expect(ZatcaService.decodeQrData(qr)[1], 'متجر الهاي');
      });

      test('throws FormatException on truncated header', () {
        // One loose byte — no length field possible.
        final truncated = base64Encode([1]);
        expect(
          () => ZatcaService.decodeQrData(truncated),
          throwsA(isA<FormatException>()),
        );
      });

      test(
        'throws FormatException on length byte promising more bytes '
        'than remain',
        () {
          // Tag 1, length 10, but only 3 bytes provided.
          final malformed = base64Encode([1, 10, 0x41, 0x42, 0x43]);
          expect(
            () => ZatcaService.decodeQrData(malformed),
            throwsA(isA<FormatException>()),
          );
        },
      );
    });
  });
}

/// Helper to parse TLV bytes into a tag->value map
Map<int, String> _parseTlv(List<int> bytes) {
  final tags = <int, String>{};
  int index = 0;
  while (index < bytes.length) {
    final tag = bytes[index++];
    final length = bytes[index++];
    final value = utf8.decode(bytes.sublist(index, index + length));
    tags[tag] = value;
    index += length;
  }
  return tags;
}
