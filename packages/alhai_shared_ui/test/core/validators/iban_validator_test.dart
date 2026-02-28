import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/src/core/validators/iban_validator.dart';

void main() {
  group('IbanValidator', () {
    // A known valid Saudi IBAN for testing:
    // SA03 8000 0000 6080 1016 7519 (Al Rajhi Bank, code 80)
    const validIban = 'SA0380000000608010167519';

    group('validate', () {
      test('should reject null', () {
        final result = IbanValidator.validate(null);
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'IBAN_REQUIRED');
      });

      test('should reject empty string', () {
        final result = IbanValidator.validate('');
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'IBAN_REQUIRED');
      });

      test('should accept valid Saudi IBAN', () {
        final result = IbanValidator.validate(validIban);
        expect(result.isValid, isTrue);
      });

      test('should accept IBAN with spaces', () {
        final result = IbanValidator.validate(
            'SA03 8000 0000 6080 1016 7519');
        expect(result.isValid, isTrue);
      });

      test('should accept lowercase iban (normalized to uppercase)', () {
        final result = IbanValidator.validate(validIban.toLowerCase());
        expect(result.isValid, isTrue);
      });

      test('should reject wrong length', () {
        final result = IbanValidator.validate('SA0380000000');
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'IBAN_INVALID_LENGTH');
      });

      test('should reject non-SA country code', () {
        final result =
            IbanValidator.validate('DE0380000000608010167519');
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'IBAN_INVALID_COUNTRY');
      });

      test('should reject unknown bank code', () {
        // Bank code 99 does not exist
        final result =
            IbanValidator.validate('SA0399000000608010167519');
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'IBAN_UNKNOWN_BANK');
      });

      test('should reject invalid checksum', () {
        // Change last digit to invalidate checksum
        final result =
            IbanValidator.validate('SA0380000000608010167510');
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'IBAN_INVALID_CHECKSUM');
      });

      test('should reject IBAN with non-numeric body', () {
        final result =
            IbanValidator.validate('SA03ABCDEFGHIJKLMNOPQRST');
        expect(result.isValid, isFalse);
      });
    });

    group('parse', () {
      test('should parse valid IBAN', () {
        final info = IbanValidator.parse(validIban);
        expect(info, isNotNull);
        expect(info!.countryCode, 'SA');
        expect(info.checkDigits, '03');
        expect(info.bankCode, '80');
        expect(info.bankName, isNotNull);
        expect(info.bankName, contains('الراجحي'));
      });

      test('should return null for invalid IBAN', () {
        final info = IbanValidator.parse('INVALID');
        expect(info, isNull);
      });

      test('should return null for null IBAN', () {
        final info = IbanValidator.parse('');
        expect(info, isNull);
      });
    });

    group('format', () {
      test('should format IBAN with spaces every 4 chars', () {
        final formatted = IbanValidator.format(validIban);
        expect(formatted, 'SA03 8000 0000 6080 1016 7519');
      });

      test('should handle IBAN with existing spaces', () {
        final formatted =
            IbanValidator.format('SA03 8000 0000 6080 1016 7519');
        expect(formatted, 'SA03 8000 0000 6080 1016 7519');
      });

      test('should handle lowercase', () {
        final formatted = IbanValidator.format(validIban.toLowerCase());
        expect(formatted, 'SA03 8000 0000 6080 1016 7519');
      });
    });

    group('formValidator', () {
      test('should return null for valid IBAN', () {
        final validator = IbanValidator.formValidator();
        expect(validator(validIban), isNull);
      });

      test('should return error for invalid IBAN', () {
        final validator = IbanValidator.formValidator();
        expect(validator('INVALID'), isNotNull);
      });

      test('should allow empty when not required', () {
        final validator = IbanValidator.formValidator(required: false);
        expect(validator(null), isNull);
        expect(validator(''), isNull);
      });

      test('should reject empty when required', () {
        final validator = IbanValidator.formValidator(required: true);
        expect(validator(''), isNotNull);
      });
    });
  });

  group('SaudiBanks', () {
    test('should have known bank codes', () {
      expect(SaudiBanks.codes.containsKey('80'), isTrue); // Rajhi
      expect(SaudiBanks.codes.containsKey('10'), isTrue); // NCB
      expect(SaudiBanks.codes.containsKey('50'), isTrue); // Inma
    });

    test('getBankName should return name for valid code', () {
      final name = SaudiBanks.getBankName('80');
      expect(name, isNotNull);
      expect(name, contains('الراجحي'));
    });

    test('getBankName should return null for invalid code', () {
      final name = SaudiBanks.getBankName('99');
      expect(name, isNull);
    });
  });

  group('IbanInfo', () {
    test('toString should include bank name', () {
      const info = IbanInfo(
        iban: 'SA0380000000608010167519',
        countryCode: 'SA',
        checkDigits: '03',
        bankCode: '80',
        accountNumber: '0000608010167519',
        bankName: 'الراجحي',
      );
      final str = info.toString();
      expect(str, contains('الراجحي'));
      expect(str, contains('IbanInfo'));
    });
  });
}
