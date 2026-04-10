import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_services/alhai_services.dart';

void main() {
  late BarcodeService barcodeService;

  setUp(() {
    barcodeService = BarcodeService();
  });

  group('BarcodeService', () {
    test('should be created', () {
      expect(barcodeService, isNotNull);
    });

    group('generateEan13', () {
      test('should generate 13-digit barcode', () {
        final barcode = barcodeService.generateEan13();
        expect(barcode, hasLength(13));
      });

      test('should start with default Saudi prefix 628', () {
        final barcode = barcodeService.generateEan13();
        expect(barcode, startsWith('628'));
      });

      test('should start with custom prefix', () {
        final barcode = barcodeService.generateEan13(prefix: '200');
        expect(barcode, startsWith('200'));
      });

      test('generated barcode should be valid', () {
        final barcode = barcodeService.generateEan13();
        expect(barcodeService.validateEan13(barcode), isTrue);
      });

      test('should generate unique barcodes', () {
        final barcodes =
            List.generate(100, (_) => barcodeService.generateEan13());
        expect(barcodes.toSet().length, equals(100));
      });
    });

    group('generateEan8', () {
      test('should generate 8-digit barcode', () {
        final barcode = barcodeService.generateEan8();
        expect(barcode, hasLength(8));
      });

      test('generated EAN-8 should be valid', () {
        final barcode = barcodeService.generateEan8();
        expect(barcodeService.validateEan8(barcode), isTrue);
      });
    });

    group('generateSku', () {
      test('should generate SKU with default prefix', () {
        final sku = barcodeService.generateSku();
        expect(sku, startsWith('SKU-'));
      });

      test('should generate SKU with custom prefix', () {
        final sku = barcodeService.generateSku(prefix: 'PRD');
        expect(sku, startsWith('PRD-'));
      });
    });

    group('generateCode128', () {
      test('should generate alphanumeric code of specified length', () {
        final code = barcodeService.generateCode128(length: 10);
        expect(code, hasLength(10));
        expect(code, matches(RegExp(r'^[0-9A-Z]+$')));
      });

      test('should respect custom length', () {
        final code = barcodeService.generateCode128(length: 20);
        expect(code, hasLength(20));
      });
    });

    group('validateEan13', () {
      test('should validate known valid EAN-13', () {
        expect(barcodeService.validateEan13('5901234123457'), isTrue);
      });

      test('should reject too short barcode', () {
        expect(barcodeService.validateEan13('123'), isFalse);
      });

      test('should reject too long barcode', () {
        expect(barcodeService.validateEan13('12345678901234'), isFalse);
      });

      test('should reject non-numeric barcode', () {
        expect(barcodeService.validateEan13('590123412345A'), isFalse);
      });

      test('should reject invalid check digit', () {
        expect(barcodeService.validateEan13('5901234123458'), isFalse);
      });
    });

    group('validateEan8', () {
      test('should validate correct EAN-8', () {
        // Generate one to ensure validity
        final barcode = barcodeService.generateEan8();
        expect(barcodeService.validateEan8(barcode), isTrue);
      });

      test('should reject wrong length', () {
        expect(barcodeService.validateEan8('12345'), isFalse);
      });

      test('should reject non-numeric', () {
        expect(barcodeService.validateEan8('1234567A'), isFalse);
      });
    });

    group('detectFormat', () {
      test('should detect valid EAN-13', () {
        expect(
          barcodeService.detectFormat('5901234123457'),
          equals(BarcodeFormat.ean13),
        );
      });

      test('should detect valid EAN-8', () {
        final ean8 = barcodeService.generateEan8();
        expect(
          barcodeService.detectFormat(ean8),
          equals(BarcodeFormat.ean8),
        );
      });

      test('should detect UPC-A (12 digits)', () {
        expect(
          barcodeService.detectFormat('012345678905'),
          equals(BarcodeFormat.upcA),
        );
      });

      test('should detect Code39 pattern', () {
        expect(
          barcodeService.detectFormat('ABC-123'),
          equals(BarcodeFormat.code39),
        );
      });

      test('should detect Code128 for arbitrary string', () {
        expect(
          barcodeService.detectFormat('abc-123'),
          equals(BarcodeFormat.code128),
        );
      });

      test('should return null for empty string', () {
        expect(barcodeService.detectFormat(''), isNull);
      });
    });

    group('QR code', () {
      test('generateQrCodeData should return JSON string', () {
        final data = barcodeService.generateQrCodeData({
          'orderId': 'order-1',
          'total': 100.0,
        });

        final decoded = jsonDecode(data);
        expect(decoded['orderId'], equals('order-1'));
      });

      test('parseQrCodeData should parse valid JSON', () {
        final json = jsonEncode({'key': 'value'});
        final result = barcodeService.parseQrCodeData(json);

        expect(result, isNotNull);
        expect(result!['key'], equals('value'));
      });

      test('parseQrCodeData should return null for invalid JSON', () {
        final result = barcodeService.parseQrCodeData('not-json');
        expect(result, isNull);
      });
    });
  });
}
