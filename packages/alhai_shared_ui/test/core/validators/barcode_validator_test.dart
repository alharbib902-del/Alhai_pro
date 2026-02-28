import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/src/core/validators/barcode_validator.dart';

void main() {
  group('BarcodeValidator', () {
    group('validate - any type', () {
      test('should reject null', () {
        final result = BarcodeValidator.validate(null);
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'BARCODE_REQUIRED');
      });

      test('should reject empty string', () {
        final result = BarcodeValidator.validate('');
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'BARCODE_REQUIRED');
      });

      test('should accept valid EAN-13', () {
        // 4006381333931 is a valid EAN-13
        final result = BarcodeValidator.validate('4006381333931');
        expect(result.isValid, isTrue);
      });

      test('should accept valid EAN-8', () {
        // 96385074 is a valid EAN-8
        final result = BarcodeValidator.validate('96385074');
        expect(result.isValid, isTrue);
      });

      test('should accept any non-empty ASCII string for code128 fallback', () {
        final result = BarcodeValidator.validate('ABC-123');
        expect(result.isValid, isTrue);
      });

      test('should handle barcode with whitespace (trimmed)', () {
        final result = BarcodeValidator.validate('  4006381333931  ');
        expect(result.isValid, isTrue);
      });
    });

    group('validate - EAN-13', () {
      test('should accept valid EAN-13 barcode', () {
        final result = BarcodeValidator.validate(
          '4006381333931',
          type: BarcodeType.ean13,
        );
        expect(result.isValid, isTrue);
      });

      test('should reject EAN-13 with wrong length', () {
        final result = BarcodeValidator.validate(
          '400638133',
          type: BarcodeType.ean13,
        );
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'BARCODE_EAN13_LENGTH');
      });

      test('should reject EAN-13 with invalid checksum', () {
        final result = BarcodeValidator.validate(
          '4006381333932', // last digit should be 1, not 2
          type: BarcodeType.ean13,
        );
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'BARCODE_INVALID_CHECKSUM');
      });

      test('should reject non-numeric EAN-13', () {
        final result = BarcodeValidator.validate(
          '400638133393A',
          type: BarcodeType.ean13,
        );
        expect(result.isValid, isFalse);
      });
    });

    group('validate - EAN-8', () {
      test('should accept valid EAN-8 barcode', () {
        final result = BarcodeValidator.validate(
          '96385074',
          type: BarcodeType.ean8,
        );
        expect(result.isValid, isTrue);
      });

      test('should reject EAN-8 with wrong length', () {
        final result = BarcodeValidator.validate(
          '9638507',
          type: BarcodeType.ean8,
        );
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'BARCODE_EAN8_LENGTH');
      });

      test('should reject EAN-8 with invalid checksum', () {
        final result = BarcodeValidator.validate(
          '96385075', // wrong check digit
          type: BarcodeType.ean8,
        );
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'BARCODE_INVALID_CHECKSUM');
      });
    });

    group('validate - UPC-A', () {
      test('should accept valid UPC-A barcode', () {
        // 036000291452 is a valid UPC-A
        final result = BarcodeValidator.validate(
          '036000291452',
          type: BarcodeType.upcA,
        );
        expect(result.isValid, isTrue);
      });

      test('should reject UPC-A with wrong length', () {
        final result = BarcodeValidator.validate(
          '03600029145',
          type: BarcodeType.upcA,
        );
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'BARCODE_UPCA_LENGTH');
      });

      test('should reject UPC-A with invalid checksum', () {
        final result = BarcodeValidator.validate(
          '036000291453', // wrong check digit
          type: BarcodeType.upcA,
        );
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'BARCODE_INVALID_CHECKSUM');
      });
    });

    group('validate - Code 128', () {
      test('should accept ASCII string', () {
        final result = BarcodeValidator.validate(
          'ABC-123-def',
          type: BarcodeType.code128,
        );
        expect(result.isValid, isTrue);
      });

      test('should reject non-ASCII characters', () {
        final result = BarcodeValidator.validate(
          'مرحبا', // Arabic characters
          type: BarcodeType.code128,
        );
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'BARCODE_CODE128_INVALID');
      });
    });

    group('generateEan13Checksum', () {
      test('should generate correct EAN-13 with checksum', () {
        final fullBarcode =
            BarcodeValidator.generateEan13Checksum('400638133393');
        expect(fullBarcode, '4006381333931');
        expect(fullBarcode.length, 13);
      });

      test('should throw for wrong length input', () {
        expect(
          () => BarcodeValidator.generateEan13Checksum('12345'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('generated barcode should pass validation', () {
        final fullBarcode =
            BarcodeValidator.generateEan13Checksum('590123412345');
        final result = BarcodeValidator.validate(
          fullBarcode,
          type: BarcodeType.ean13,
        );
        expect(result.isValid, isTrue);
      });
    });

    group('detectType', () {
      test('should detect EAN-13', () {
        final type = BarcodeValidator.detectType('4006381333931');
        expect(type, BarcodeType.ean13);
      });

      test('should detect EAN-8', () {
        final type = BarcodeValidator.detectType('96385074');
        expect(type, BarcodeType.ean8);
      });

      test('should detect UPC-A', () {
        final type = BarcodeValidator.detectType('036000291452');
        expect(type, BarcodeType.upcA);
      });

      test('should detect Code 128 for ASCII text', () {
        final type = BarcodeValidator.detectType('ABC-123');
        expect(type, BarcodeType.code128);
      });

      test('should return null for non-ASCII non-standard', () {
        final type = BarcodeValidator.detectType('مرحبا');
        expect(type, isNull);
      });

      test('should handle whitespace trimming', () {
        final type = BarcodeValidator.detectType('  4006381333931  ');
        expect(type, BarcodeType.ean13);
      });
    });

    group('formValidator', () {
      test('should return null for valid barcode', () {
        final validator = BarcodeValidator.formValidator();
        expect(validator('ABC-123'), isNull);
      });

      test('should return error for empty when required', () {
        final validator = BarcodeValidator.formValidator(required: true);
        expect(validator(''), isNotNull);
      });

      test('should allow empty when not required', () {
        final validator = BarcodeValidator.formValidator(required: false);
        expect(validator(''), isNull);
        expect(validator(null), isNull);
      });
    });
  });
}
