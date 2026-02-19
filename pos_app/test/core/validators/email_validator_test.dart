import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/validators/email_validator.dart';

void main() {
  group('EmailValidator.validate()', () {
    test('accepts test@example.com', () {
      expect(EmailValidator.validate('test@example.com').isValid, isTrue);
    });
    test('accepts user.name@domain.co', () {
      expect(EmailValidator.validate('user.name@domain.co').isValid, isTrue);
    });
    test('accepts user+tag@example.com', () {
      expect(EmailValidator.validate('user+tag@example.com').isValid, isTrue);
    });
    test('accepts subdomain', () {
      expect(EmailValidator.validate('user@mail.example.com').isValid, isTrue);
    });
    test('rejects null', () {
      final r = EmailValidator.validate(null);
      expect(r.isValid, isFalse);
      expect(r.errorCode, equals('EMAIL_REQUIRED'));
    });
    test('rejects empty', () {
      final r = EmailValidator.validate('');
      expect(r.isValid, isFalse);
      expect(r.errorCode, equals('EMAIL_REQUIRED'));
    });
    test('rejects without @', () {
      expect(EmailValidator.validate('testexample.com').isValid, isFalse);
    });
    test('rejects without domain', () {
      expect(EmailValidator.validate('test@').isValid, isFalse);
    });
    test('rejects short TLD', () {
      final r = EmailValidator.validate('test@example.c');
      expect(r.isValid, isFalse);
      expect(r.errorCode, equals('EMAIL_INVALID_TLD'));
    });
    test('rejects no dot in domain', () {
      final r = EmailValidator.validate('test@localhost');
      expect(r.isValid, isFalse);
      expect(r.errorCode, equals('EMAIL_INVALID_DOMAIN'));
    });
    test('rejects too long email', () {
      final longLocal = 'a' * 245;
      final r = EmailValidator.validate('$longLocal@example.com');
      expect(r.isValid, isFalse);
      expect(r.errorCode, equals('EMAIL_TOO_LONG'));
    });
  });

  group('EmailValidator.validateNotDisposable()', () {
    test('rejects tempmail.com', () {
      final r = EmailValidator.validateNotDisposable('user@tempmail.com');
      expect(r.isValid, isFalse);
      expect(r.errorCode, equals('EMAIL_DISPOSABLE'));
    });
    test('rejects mailinator.com', () {
      final r = EmailValidator.validateNotDisposable('user@mailinator.com');
      expect(r.isValid, isFalse);
      expect(r.errorCode, equals('EMAIL_DISPOSABLE'));
    });
    test('rejects guerrillamail.com', () {
      final r = EmailValidator.validateNotDisposable('user@guerrillamail.com');
      expect(r.isValid, isFalse);
      expect(r.errorCode, equals('EMAIL_DISPOSABLE'));
    });
    test('accepts gmail.com', () {
      expect(EmailValidator.validateNotDisposable('user@gmail.com').isValid, isTrue);
    });
    test('accepts corporate domain', () {
      expect(EmailValidator.validateNotDisposable('user@company.com').isValid, isTrue);
    });
    test('rejects null', () {
      final r = EmailValidator.validateNotDisposable(null);
      expect(r.isValid, isFalse);
      expect(r.errorCode, equals('EMAIL_REQUIRED'));
    });
    test('rejects invalid format', () {
      expect(EmailValidator.validateNotDisposable('invalid').isValid, isFalse);
    });
  });

  group('EmailValidator.normalize()', () {
    test('trims whitespace', () {
      expect(EmailValidator.normalize('  test@example.com  '), equals('test@example.com'));
    });
    test('converts to lowercase', () {
      expect(EmailValidator.normalize('Test@Example.COM'), equals('test@example.com'));
    });
    test('trims and lowercases', () {
      expect(EmailValidator.normalize('  TEST@EXAMPLE.COM  '), equals('test@example.com'));
    });
  });

  group('EmailValidator.formValidator()', () {
    test('required rejects empty', () {
      expect(EmailValidator.formValidator(required: true)(''), isNotNull);
    });
    test('required rejects null', () {
      expect(EmailValidator.formValidator(required: true)(null), isNotNull);
    });
    test('optional accepts empty', () {
      expect(EmailValidator.formValidator(required: false)(''), isNull);
    });
    test('optional accepts null', () {
      expect(EmailValidator.formValidator(required: false)(null), isNull);
    });
    test('allowDisposable=false rejects disposable', () {
      final v = EmailValidator.formValidator(required: true, allowDisposable: false);
      expect(v('user@tempmail.com'), isNotNull);
    });
    test('allowDisposable=true accepts disposable', () {
      expect(EmailValidator.formValidator(required: true)('user@tempmail.com'), isNull);
    });
    test('en locale returns English error', () {
      final err = EmailValidator.formValidator(locale: 'en', required: true)('');
      expect(err, isNotNull);
      expect(err, contains('required'));
    });
    test('ar locale returns Arabic error', () {
      final err = EmailValidator.formValidator(locale: 'ar', required: true)('');
      expect(err, isNotNull);
    });
    test('valid email returns null', () {
      expect(EmailValidator.formValidator(required: true)('test@example.com'), isNull);
    });
  });
}
