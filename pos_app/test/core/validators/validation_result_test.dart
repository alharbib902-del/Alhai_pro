import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/validators/validation_result.dart';

void main() {
  group('ValidationResult.success()', () {
    test('isValid returns true', () {
      const result = ValidationResult.success();
      expect(result.isValid, isTrue);
    });

    test('errorAr is null', () {
      const result = ValidationResult.success();
      expect(result.errorAr, isNull);
    });

    test('errorEn is null', () {
      const result = ValidationResult.success();
      expect(result.errorEn, isNull);
    });

    test('errorCode is null', () {
      const result = ValidationResult.success();
      expect(result.errorCode, isNull);
    });
  });

  group('ValidationResult.failure()', () {
    test('isValid returns false', () {
      const result = ValidationResult.failure(
        messageAr: 'error_ar',
        messageEn: 'Error',
      );
      expect(result.isValid, isFalse);
    });

    test('stores Arabic error message', () {
      const result = ValidationResult.failure(
        messageAr: 'phone_required_ar',
        messageEn: 'Phone number is required',
      );
      expect(result.errorAr, equals('phone_required_ar'));
    });

    test('stores English error message', () {
      const result = ValidationResult.failure(
        messageAr: 'phone_required_ar',
        messageEn: 'Phone number is required',
      );
      expect(result.errorEn, equals('Phone number is required'));
    });

    test('stores error code when provided', () {
      const result = ValidationResult.failure(
        messageAr: 'error_ar',
        messageEn: 'Error',
        code: 'ERR_001',
      );
      expect(result.errorCode, equals('ERR_001'));
    });

    test('errorCode is null when not provided', () {
      const result = ValidationResult.failure(
        messageAr: 'error_ar',
        messageEn: 'Error',
      );
      expect(result.errorCode, isNull);
    });
  });

  group('ValidationResult.fromBool()', () {
    test('valid=true creates valid result', () {
      final result = ValidationResult.fromBool(true);
      expect(result.isValid, isTrue);
    });

    test('valid=false creates invalid result with all fields', () {
      final result = ValidationResult.fromBool(false,
          errorAr: 'error_ar', errorEn: 'Error', code: 'ERR');
      expect(result.isValid, isFalse);
      expect(result.errorAr, equals('error_ar'));
      expect(result.errorEn, equals('Error'));
      expect(result.errorCode, equals('ERR'));
    });

    test('valid=true causes getError to return null', () {
      final result = ValidationResult.fromBool(true,
          errorAr: 'error_ar', errorEn: 'Error');
      expect(result.isValid, isTrue);
      expect(result.getError('en'), isNull);
      expect(result.getError('ar'), isNull);
    });
  });

  group('getError()', () {
    test('returns null for success result regardless of locale', () {
      const result = ValidationResult.success();
      expect(result.getError('ar'), isNull);
      expect(result.getError('en'), isNull);
    });

    test('returns Arabic error for locale ar', () {
      const result = ValidationResult.failure(
        messageAr: 'invalid_phone_ar',
        messageEn: 'Invalid phone number',
      );
      expect(result.getError('ar'), equals('invalid_phone_ar'));
    });

    test('returns English error for locale en', () {
      const result = ValidationResult.failure(
        messageAr: 'invalid_phone_ar',
        messageEn: 'Invalid phone number',
      );
      expect(result.getError('en'), equals('Invalid phone number'));
    });

    test('returns English error for any non-ar locale', () {
      const result = ValidationResult.failure(
        messageAr: 'error_ar',
        messageEn: 'Error',
      );
      expect(result.getError('fr'), equals('Error'));
      expect(result.getError('de'), equals('Error'));
    });
  });

  group('toFormError()', () {
    test('returns null for success', () {
      const result = ValidationResult.success();
      expect(result.toFormError('ar'), isNull);
      expect(result.toFormError('en'), isNull);
    });

    test('returns localized error for failure', () {
      const result = ValidationResult.failure(
        messageAr: 'required_ar',
        messageEn: 'Required',
      );
      expect(result.toFormError('ar'), equals('required_ar'));
      expect(result.toFormError('en'), equals('Required'));
    });
  });

  group('isInvalid extension', () {
    test('returns false for success result', () {
      const result = ValidationResult.success();
      expect(result.isInvalid, isFalse);
    });

    test('returns true for failure result', () {
      const result = ValidationResult.failure(
        messageAr: 'error_ar',
        messageEn: 'Error',
      );
      expect(result.isInvalid, isTrue);
    });
  });

  group('toString()', () {
    test('success result contains Valid', () {
      const result = ValidationResult.success();
      expect(result.toString(), contains('Valid'));
    });

    test('failure result contains Invalid', () {
      const result = ValidationResult.failure(
        messageAr: 'phone_required_ar',
        messageEn: 'Phone number is required',
      );
      expect(result.toString(), contains('Invalid'));
    });
  });
}
