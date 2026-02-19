import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/validators/barcode_validator.dart';

void main() {
  group('BarcodeValidator.validate - EAN-13', () {
    test('accepts valid EAN-13 barcode', () {
      // 4006381333931 is a valid EAN-13
      expect(
        BarcodeValidator.validate('4006381333931', type: BarcodeType.ean13)
            .isValid,
        isTrue,
      );
    });

    test('rejects EAN-13 with wrong length', () {
      final result =
          BarcodeValidator.validate('12345', type: BarcodeType.ean13);
      expect(result.isValid, isFalse);
      expect(result.errorCode, equals('BARCODE_EAN13_LENGTH'));
    });

    test('rejects EAN-13 with invalid checksum', () {
      final result =
          BarcodeValidator.validate('4006381333932', type: BarcodeType.ean13);
      expect(result.isValid, isFalse);
      expect(result.errorCode, equals('BARCODE_INVALID_CHECKSUM'));
    });
  });

  group('BarcodeValidator.validate - EAN-8', () {
    test('accepts valid EAN-8 barcode', () {
      // 96385074 is a valid EAN-8
      expect(
        BarcodeValidator.validate('96385074', type: BarcodeType.ean8).isValid,
        isTrue,
      );
    });

    test('rejects EAN-8 with wrong length', () {
      final result =
          BarcodeValidator.validate('12345', type: BarcodeType.ean8);
      expect(result.isValid, isFalse);
      expect(result.errorCode, equals('BARCODE_EAN8_LENGTH'));
    });

    test('rejects EAN-8 with invalid checksum', () {
      final result =
          BarcodeValidator.validate('96385075', type: BarcodeType.ean8);
      expect(result.isValid, isFalse);
      expect(result.errorCode, equals('BARCODE_INVALID_CHECKSUM'));
    });
  });

  group('BarcodeValidator.validate - UPC-A', () {
    test('accepts valid UPC-A barcode', () {
      // 036000291452 is a valid UPC-A
      expect(
        BarcodeValidator.validate('036000291452', type: BarcodeType.upcA)
            .isValid,
        isTrue,
      );
    });

    test('rejects UPC-A with wrong length', () {
      final result =
          BarcodeValidator.validate('12345', type: BarcodeType.upcA);
      expect(result.isValid, isFalse);
      expect(result.errorCode, equals('BARCODE_UPCA_LENGTH'));
    });

    test('rejects UPC-A with invalid checksum', () {
      final result =
          BarcodeValidator.validate('036000291453', type: BarcodeType.upcA);
      expect(result.isValid, isFalse);
      expect(result.errorCode, equals('BARCODE_INVALID_CHECKSUM'));
    });
  });

  group('BarcodeValidator.validate - Code 128', () {
    test('accepts valid ASCII text', () {
      expect(
        BarcodeValidator.validate('ABC-123', type: BarcodeType.code128).isValid,
        isTrue,
      );
    });

    test('accepts alphanumeric Code 128', () {
      expect(
        BarcodeValidator.validate('PROD-001', type: BarcodeType.code128)
            .isValid,
        isTrue,
      );
    });

    test('rejects non-ASCII characters', () {
      final result =
          BarcodeValidator.validate('مرحبا', type: BarcodeType.code128);
      expect(result.isValid, isFalse);
      expect(result.errorCode, equals('BARCODE_CODE128_INVALID'));
    });
  });

  group('BarcodeValidator.validate - any type', () {
    test('accepts EAN-13 with type any', () {
      expect(
        BarcodeValidator.validate('4006381333931').isValid,
        isTrue,
      );
    });

    test('accepts non-numeric ASCII as Code 128 fallback', () {
      expect(
        BarcodeValidator.validate('ABC-123').isValid,
        isTrue,
      );
    });

    test('rejects null input', () {
      final result = BarcodeValidator.validate(null);
      expect(result.isValid, isFalse);
      expect(result.errorCode, equals('BARCODE_REQUIRED'));
    });

    test('rejects empty string', () {
      final result = BarcodeValidator.validate('');
      expect(result.isValid, isFalse);
      expect(result.errorCode, equals('BARCODE_REQUIRED'));
    });
  });

  group('BarcodeValidator.generateEan13Checksum', () {
    test('generates valid checksum for 12-digit base', () {
      final result = BarcodeValidator.generateEan13Checksum('400638133393');
      expect(result, equals('4006381333931'));
      expect(result.length, equals(13));
    });

    test('generated barcode passes validation', () {
      final barcode = BarcodeValidator.generateEan13Checksum('590123412345');
      expect(
        BarcodeValidator.validate(barcode, type: BarcodeType.ean13).isValid,
        isTrue,
      );
    });

    test('throws for non-12-digit input', () {
      expect(
        () => BarcodeValidator.generateEan13Checksum('12345'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('BarcodeValidator.detectType', () {
    test('detects EAN-13', () {
      expect(
        BarcodeValidator.detectType('4006381333931'),
        equals(BarcodeType.ean13),
      );
    });

    test('detects EAN-8', () {
      expect(
        BarcodeValidator.detectType('96385074'),
        equals(BarcodeType.ean8),
      );
    });

    test('detects UPC-A', () {
      expect(
        BarcodeValidator.detectType('036000291452'),
        equals(BarcodeType.upcA),
      );
    });

    test('detects Code 128 for ASCII', () {
      expect(
        BarcodeValidator.detectType('ABC-123'),
        equals(BarcodeType.code128),
      );
    });

    test('returns null for non-ASCII', () {
      expect(
        BarcodeValidator.detectType('مرحبا'),
        isNull,
      );
    });
  });

  group('BarcodeValidator.formValidator', () {
    test('returns null for valid barcode', () {
      final validator = BarcodeValidator.formValidator(locale: 'ar');
      expect(validator('4006381333931'), isNull);
    });

    test('returns error for null when required', () {
      final validator =
          BarcodeValidator.formValidator(locale: 'ar', required: true);
      expect(validator(null), isNotNull);
    });

    test('returns null for null when not required', () {
      final validator =
          BarcodeValidator.formValidator(locale: 'ar', required: false);
      expect(validator(null), isNull);
    });

    test('returns null for empty when not required', () {
      final validator =
          BarcodeValidator.formValidator(locale: 'ar', required: false);
      expect(validator(''), isNull);
    });

    test('returns Arabic error for invalid barcode', () {
      final validator =
          BarcodeValidator.formValidator(locale: 'ar', required: true);
      final error = validator(null);
      expect(error, isNotNull);
      expect(error, contains('الباركود'));
    });

    test('returns English error for invalid barcode', () {
      final validator =
          BarcodeValidator.formValidator(locale: 'en', required: true);
      final error = validator(null);
      expect(error, isNotNull);
      expect(error!.toLowerCase(), contains('barcode'));
    });
  });

  group('BarcodeType enum', () {
    test('has 5 values', () {
      expect(BarcodeType.values, hasLength(5));
    });

    test('contains expected values', () {
      expect(BarcodeType.values, contains(BarcodeType.ean13));
      expect(BarcodeType.values, contains(BarcodeType.ean8));
      expect(BarcodeType.values, contains(BarcodeType.upcA));
      expect(BarcodeType.values, contains(BarcodeType.code128));
      expect(BarcodeType.values, contains(BarcodeType.any));
    });
  });
}
