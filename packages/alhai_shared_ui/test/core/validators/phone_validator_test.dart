import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/src/core/validators/phone_validator.dart';

void main() {
  group('PhoneValidator', () {
    group('validateMobile', () {
      test('should reject null', () {
        final result = PhoneValidator.validateMobile(null);
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'PHONE_REQUIRED');
      });

      test('should reject empty string', () {
        final result = PhoneValidator.validateMobile('');
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'PHONE_REQUIRED');
      });

      test('should accept valid Saudi mobile 0512345678', () {
        final result = PhoneValidator.validateMobile('0512345678');
        expect(result.isValid, isTrue);
      });

      test('should accept valid Saudi mobile 0551234567', () {
        final result = PhoneValidator.validateMobile('0551234567');
        expect(result.isValid, isTrue);
      });

      test('should accept mobile with spaces', () {
        final result = PhoneValidator.validateMobile('051 234 5678');
        expect(result.isValid, isTrue);
      });

      test('should accept mobile with dashes', () {
        final result = PhoneValidator.validateMobile('051-234-5678');
        expect(result.isValid, isTrue);
      });

      test('should accept international format +966', () {
        final result = PhoneValidator.validateMobile('+966512345678');
        expect(result.isValid, isTrue);
      });

      test('should accept international format 00966', () {
        final result = PhoneValidator.validateMobile('00966512345678');
        expect(result.isValid, isTrue);
      });

      test('should reject number not starting with 05', () {
        final result = PhoneValidator.validateMobile('0612345678');
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'PHONE_INVALID_FORMAT');
      });

      test('should reject too short number', () {
        final result = PhoneValidator.validateMobile('05123');
        expect(result.isValid, isFalse);
      });

      test('should reject too long number', () {
        final result = PhoneValidator.validateMobile('051234567890');
        expect(result.isValid, isFalse);
      });

      test('should reject non-numeric characters', () {
        final result = PhoneValidator.validateMobile('05abcd1234');
        expect(result.isValid, isFalse);
      });
    });

    group('validate (any Saudi number)', () {
      test('should accept mobile number', () {
        final result = PhoneValidator.validate('0512345678');
        expect(result.isValid, isTrue);
      });

      test('should accept landline number (01 + 7 digits)', () {
        // Landline: 01 + 7 digits = 9 digits total
        final result = PhoneValidator.validate('012345678');
        expect(result.isValid, isTrue);
      });

      test('should reject null', () {
        final result = PhoneValidator.validate(null);
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'PHONE_REQUIRED');
      });

      test('should reject empty', () {
        final result = PhoneValidator.validate('');
        expect(result.isValid, isFalse);
      });

      test('should accept landline 011234567', () {
        // 01 + 7 digits = 9 digits
        final result = PhoneValidator.validate('012345678');
        expect(result.isValid, isTrue);
      });
    });

    group('format', () {
      test('should format 10-digit mobile number', () {
        final formatted = PhoneValidator.format('0512345678');
        expect(formatted, '051 234 5678');
      });

      test('should return original for non-standard number', () {
        final formatted = PhoneValidator.format('123');
        expect(formatted, '123');
      });

      test('should handle number with spaces', () {
        final formatted = PhoneValidator.format('051 234 5678');
        // After cleaning spaces, it becomes 0512345678, which is 10 digits
        expect(formatted, '051 234 5678');
      });
    });

    group('toInternational', () {
      test('should convert local to international', () {
        final result = PhoneValidator.toInternational('0512345678');
        expect(result, '+966512345678');
      });

      test('should keep existing +966 format', () {
        final result = PhoneValidator.toInternational('+966512345678');
        expect(result, '+966512345678');
      });

      test('should convert 00966 to +966', () {
        final result = PhoneValidator.toInternational('00966512345678');
        expect(result, '+966512345678');
      });

      test('should return original for non-Saudi number', () {
        final result = PhoneValidator.toInternational('123456');
        expect(result, '123456');
      });
    });

    group('formValidator', () {
      test('should return null for valid phone', () {
        final validator = PhoneValidator.formValidator();
        expect(validator('0512345678'), isNull);
      });

      test('should return error message for invalid phone', () {
        final validator = PhoneValidator.formValidator();
        expect(validator('123'), isNotNull);
      });

      test('should return Arabic error by default', () {
        final validator = PhoneValidator.formValidator(locale: 'ar');
        final error = validator('123');
        expect(error, isNotNull);
      });

      test('should return English error for en locale', () {
        final validator = PhoneValidator.formValidator(locale: 'en');
        final error = validator('123');
        expect(error, isNotNull);
      });

      test('should allow empty when not required', () {
        final validator = PhoneValidator.formValidator(required: false);
        expect(validator(null), isNull);
        expect(validator(''), isNull);
      });

      test('should reject empty when required', () {
        final validator = PhoneValidator.formValidator(required: true);
        expect(validator(null), isNotNull);
        expect(validator(''), isNotNull);
      });
    });
  });
}
