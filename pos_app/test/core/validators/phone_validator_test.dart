import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/validators/phone_validator.dart';

void main() {
  group('PhoneValidator.validate()', () {
    test('accepts local mobile 0512345678', () {
      expect(PhoneValidator.validate('0512345678').isValid, isTrue);
    });
    test('accepts +966512345678', () {
      expect(PhoneValidator.validate('+966512345678').isValid, isTrue);
    });
    test('accepts 00966512345678', () {
      expect(PhoneValidator.validate('00966512345678').isValid, isTrue);
    });
    test('accepts landline 011234567', () {
      expect(PhoneValidator.validate('011234567').isValid, isTrue);
    });
    test('accepts with spaces', () {
      expect(PhoneValidator.validate('051 234 5678').isValid, isTrue);
    });
    test('accepts with dashes', () {
      expect(PhoneValidator.validate('051-234-5678').isValid, isTrue);
    });
    test('rejects null', () {
      final r = PhoneValidator.validate(null);
      expect(r.isValid, isFalse);
      expect(r.errorCode, equals('PHONE_REQUIRED'));
    });
    test('rejects empty', () {
      final r = PhoneValidator.validate('');
      expect(r.isValid, isFalse);
      expect(r.errorCode, equals('PHONE_REQUIRED'));
    });
    test('rejects too short', () {
      final r = PhoneValidator.validate('051234');
      expect(r.isValid, isFalse);
      expect(r.errorCode, equals('PHONE_INVALID'));
    });
    test('rejects alphabetic', () {
      expect(PhoneValidator.validate('abcdefghij').isValid, isFalse);
    });
  });

  group('PhoneValidator.validateMobile()', () {
    test('accepts 0512345678', () {
      expect(PhoneValidator.validateMobile('0512345678').isValid, isTrue);
    });
    test('accepts +966512345678', () {
      expect(PhoneValidator.validateMobile('+966512345678').isValid, isTrue);
    });
    test('accepts 00966512345678', () {
      expect(PhoneValidator.validateMobile('00966512345678').isValid, isTrue);
    });
    test('accepts with spaces and dashes', () {
      expect(PhoneValidator.validateMobile('051-234 5678').isValid, isTrue);
    });
    test('rejects null', () {
      final r = PhoneValidator.validateMobile(null);
      expect(r.isValid, isFalse);
      expect(r.errorCode, equals('PHONE_REQUIRED'));
    });
    test('rejects empty', () {
      expect(PhoneValidator.validateMobile('').isValid, isFalse);
    });
    test('rejects landline', () {
      final r = PhoneValidator.validateMobile('011234567');
      expect(r.isValid, isFalse);
      expect(r.errorCode, equals('PHONE_INVALID_FORMAT'));
    });
    test('rejects too short', () {
      expect(PhoneValidator.validateMobile('051234').isValid, isFalse);
    });
  });

  group('PhoneValidator.format()', () {
    test('formats 0512345678', () {
      expect(PhoneValidator.format('0512345678'), equals('051 234 5678'));
    });
    test('strips dashes then formats', () {
      expect(PhoneValidator.format('051-234-5678'), equals('051 234 5678'));
    });
    test('returns original for international', () {
      expect(PhoneValidator.format('+966512345678'), equals('+966512345678'));
    });
    test('returns original for short', () {
      expect(PhoneValidator.format('0512'), equals('0512'));
    });
    test('returns original for non-05', () {
      expect(PhoneValidator.format('0112345678'), equals('0112345678'));
    });
  });

  group('PhoneValidator.toInternational()', () {
    test('05 to +966', () {
      expect(PhoneValidator.toInternational('0512345678'), equals('+966512345678'));
    });
    test('keeps +966', () {
      expect(PhoneValidator.toInternational('+966512345678'), equals('+966512345678'));
    });
    test('00966 to +966', () {
      expect(PhoneValidator.toInternational('00966512345678'), equals('+966512345678'));
    });
    test('strips spaces', () {
      expect(PhoneValidator.toInternational('051 234 5678'), equals('+966512345678'));
    });
    test('unrecognized returns original', () {
      expect(PhoneValidator.toInternational('1234567890'), equals('1234567890'));
    });
  });

  group('PhoneValidator.formValidator()', () {
    test('required rejects empty', () {
      expect(PhoneValidator.formValidator(required: true)(''), isNotNull);
    });
    test('required rejects null', () {
      expect(PhoneValidator.formValidator(required: true)(null), isNotNull);
    });
    test('optional accepts empty', () {
      expect(PhoneValidator.formValidator(required: false)(''), isNull);
    });
    test('optional accepts null', () {
      expect(PhoneValidator.formValidator(required: false)(null), isNull);
    });
    test('en locale error', () {
      final err = PhoneValidator.formValidator(locale: 'en', required: true)('');
      expect(err, isNotNull);
      expect(err, contains('required'));
    });
    test('valid returns null', () {
      expect(PhoneValidator.formValidator(required: true)('0512345678'), isNull);
    });
    test('invalid returns error', () {
      expect(PhoneValidator.formValidator(required: true)('051234'), isNotNull);
    });
  });
}
