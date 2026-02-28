import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/src/core/validators/email_validator.dart';

void main() {
  group('EmailValidator', () {
    group('validate', () {
      test('should reject null', () {
        final result = EmailValidator.validate(null);
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'EMAIL_REQUIRED');
      });

      test('should reject empty string', () {
        final result = EmailValidator.validate('');
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'EMAIL_REQUIRED');
      });

      test('should accept valid email', () {
        final result = EmailValidator.validate('user@example.com');
        expect(result.isValid, isTrue);
      });

      test('should accept email with subdomain', () {
        final result = EmailValidator.validate('user@mail.example.com');
        expect(result.isValid, isTrue);
      });

      test('should accept email with dots in local part', () {
        final result = EmailValidator.validate('first.last@example.com');
        expect(result.isValid, isTrue);
      });

      test('should accept email with plus sign', () {
        final result = EmailValidator.validate('user+tag@example.com');
        expect(result.isValid, isTrue);
      });

      test('should handle uppercase emails (normalized to lowercase)', () {
        final result = EmailValidator.validate('USER@EXAMPLE.COM');
        expect(result.isValid, isTrue);
      });

      test('should handle emails with leading/trailing spaces', () {
        final result = EmailValidator.validate('  user@example.com  ');
        expect(result.isValid, isTrue);
      });

      test('should reject email without @', () {
        final result = EmailValidator.validate('userexample.com');
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'EMAIL_INVALID_FORMAT');
      });

      test('should reject email without domain', () {
        final result = EmailValidator.validate('user@');
        expect(result.isValid, isFalse);
      });

      test('should reject email without local part', () {
        final result = EmailValidator.validate('@example.com');
        expect(result.isValid, isFalse);
      });

      test('should reject email without TLD', () {
        final result = EmailValidator.validate('user@example');
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'EMAIL_INVALID_DOMAIN');
      });

      test('should reject email with single-char TLD', () {
        final result = EmailValidator.validate('user@example.c');
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'EMAIL_INVALID_TLD');
      });

      test('should reject too long email (>254 chars)', () {
        final longLocal = 'a' * 250;
        final result = EmailValidator.validate('$longLocal@x.co');
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'EMAIL_TOO_LONG');
      });
    });

    group('validateNotDisposable', () {
      test('should accept regular email', () {
        final result = EmailValidator.validateNotDisposable('user@gmail.com');
        expect(result.isValid, isTrue);
      });

      test('should reject tempmail.com', () {
        final result =
            EmailValidator.validateNotDisposable('user@tempmail.com');
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'EMAIL_DISPOSABLE');
      });

      test('should reject mailinator.com', () {
        final result =
            EmailValidator.validateNotDisposable('test@mailinator.com');
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'EMAIL_DISPOSABLE');
      });

      test('should reject guerrillamail.com', () {
        final result =
            EmailValidator.validateNotDisposable('x@guerrillamail.com');
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'EMAIL_DISPOSABLE');
      });

      test('should still validate basic format', () {
        final result = EmailValidator.validateNotDisposable('invalid');
        expect(result.isValid, isFalse);
      });
    });

    group('normalize', () {
      test('should trim and lowercase', () {
        expect(EmailValidator.normalize('  USER@EXAMPLE.COM  '),
            'user@example.com');
      });

      test('should handle already normalized email', () {
        expect(EmailValidator.normalize('user@example.com'),
            'user@example.com');
      });
    });

    group('formValidator', () {
      test('should return null for valid email', () {
        final validator = EmailValidator.formValidator();
        expect(validator('user@example.com'), isNull);
      });

      test('should return error for invalid email', () {
        final validator = EmailValidator.formValidator();
        expect(validator('invalid'), isNotNull);
      });

      test('should allow empty when not required', () {
        final validator = EmailValidator.formValidator(required: false);
        expect(validator(null), isNull);
        expect(validator(''), isNull);
      });

      test('should reject empty when required', () {
        final validator = EmailValidator.formValidator(required: true);
        expect(validator(null), isNotNull);
      });

      test('should check disposable when allowDisposable is false', () {
        final validator = EmailValidator.formValidator(allowDisposable: false);
        expect(validator('user@tempmail.com'), isNotNull);
      });

      test('should allow disposable when allowDisposable is true', () {
        final validator = EmailValidator.formValidator(allowDisposable: true);
        expect(validator('user@tempmail.com'), isNull);
      });

      test('should return English error when locale is en', () {
        final validator =
            EmailValidator.formValidator(locale: 'en', required: true);
        final error = validator('');
        expect(error, isNotNull);
      });
    });
  });
}
