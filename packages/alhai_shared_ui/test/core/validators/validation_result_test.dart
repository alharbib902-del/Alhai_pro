import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/src/core/validators/validation_result.dart';

void main() {
  group('ValidationResult', () {
    group('success', () {
      test('isValid should be true', () {
        const result = ValidationResult.success();
        expect(result.isValid, isTrue);
      });

      test('errors should be null', () {
        const result = ValidationResult.success();
        expect(result.errorAr, isNull);
        expect(result.errorEn, isNull);
        expect(result.errorCode, isNull);
      });

      test('getError should return null for any locale', () {
        const result = ValidationResult.success();
        expect(result.getError('ar'), isNull);
        expect(result.getError('en'), isNull);
      });

      test('toFormError should return null', () {
        const result = ValidationResult.success();
        expect(result.toFormError('ar'), isNull);
        expect(result.toFormError('en'), isNull);
      });

      test('toString should indicate valid', () {
        const result = ValidationResult.success();
        expect(result.toString(), contains('Valid'));
      });
    });

    group('failure', () {
      test('isValid should be false', () {
        const result = ValidationResult.failure(
          messageAr: 'خطأ',
          messageEn: 'Error',
          code: 'TEST_ERROR',
        );
        expect(result.isValid, isFalse);
      });

      test('should store error messages', () {
        const result = ValidationResult.failure(
          messageAr: 'خطأ عربي',
          messageEn: 'English error',
          code: 'ERR_CODE',
        );
        expect(result.errorAr, 'خطأ عربي');
        expect(result.errorEn, 'English error');
        expect(result.errorCode, 'ERR_CODE');
      });

      test('getError should return Arabic message for ar locale', () {
        const result = ValidationResult.failure(
          messageAr: 'خطأ',
          messageEn: 'Error',
        );
        expect(result.getError('ar'), 'خطأ');
      });

      test('getError should return English message for en locale', () {
        const result = ValidationResult.failure(
          messageAr: 'خطأ',
          messageEn: 'Error',
        );
        expect(result.getError('en'), 'Error');
      });

      test('toString should indicate invalid with Arabic message', () {
        const result = ValidationResult.failure(
          messageAr: 'خطأ',
          messageEn: 'Error',
        );
        expect(result.toString(), contains('Invalid'));
        expect(result.toString(), contains('خطأ'));
      });
    });

    group('fromBool', () {
      test('should create valid result when true', () {
        final result = ValidationResult.fromBool(true);
        expect(result.isValid, isTrue);
      });

      test('should create invalid result when false', () {
        final result = ValidationResult.fromBool(
          false,
          errorAr: 'فشل',
          errorEn: 'Failed',
        );
        expect(result.isValid, isFalse);
        expect(result.errorAr, 'فشل');
      });
    });

    group('ValidationResultExtension', () {
      test('isInvalid should be true for failure', () {
        const result = ValidationResult.failure(
          messageAr: 'خطأ',
          messageEn: 'Error',
        );
        expect(result.isInvalid, isTrue);
      });

      test('isInvalid should be false for success', () {
        const result = ValidationResult.success();
        expect(result.isInvalid, isFalse);
      });
    });
  });
}
