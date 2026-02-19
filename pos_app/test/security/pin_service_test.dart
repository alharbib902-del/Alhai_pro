import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/security/pin_service.dart';

// ===========================================
// PIN Service Tests
// ===========================================

void main() {
  group('PinResult', () {
    group('factory constructors', () {
      test('success يُنشئ نتيجة ناجحة', () {
        final result = PinResult.success();
        expect(result.isSuccess, isTrue);
        expect(result.error, isNull);
        expect(result.errorType, isNull);
      });

      test('incorrect يُنشئ نتيجة فاشلة مع عدد المحاولات المتبقية', () {
        final result = PinResult.incorrect(3);
        expect(result.isSuccess, isFalse);
        expect(result.errorType, PinError.incorrect);
        expect(result.remainingAttempts, 3);
        expect(result.error, contains('غير صحيح'));
      });

      test('invalidLength يُنشئ نتيجة خطأ الطول', () {
        final result = PinResult.invalidLength();
        expect(result.isSuccess, isFalse);
        expect(result.errorType, PinError.invalidLength);
        expect(result.error, contains('4-6'));
      });

      test('invalidFormat يُنشئ نتيجة خطأ التنسيق', () {
        final result = PinResult.invalidFormat();
        expect(result.isSuccess, isFalse);
        expect(result.errorType, PinError.invalidFormat);
        expect(result.error, contains('أرقام فقط'));
      });

      test('notEnabled يُنشئ نتيجة عدم التفعيل', () {
        final result = PinResult.notEnabled();
        expect(result.isSuccess, isFalse);
        expect(result.errorType, PinError.notEnabled);
        expect(result.error, contains('غير مفعل'));
      });

      test('lockedOut يُنشئ نتيجة القفل مع الوقت', () {
        final lockTime = DateTime.now().add(const Duration(minutes: 15));
        final result = PinResult.lockedOut(lockTime);
        expect(result.isSuccess, isFalse);
        expect(result.errorType, PinError.lockedOut);
        expect(result.lockedUntil, lockTime);
        expect(result.error, contains('قفل'));
      });
    });
  });

  group('PinError enum', () {
    test('يحتوي على جميع أنواع الأخطاء', () {
      expect(PinError.values, contains(PinError.incorrect));
      expect(PinError.values, contains(PinError.invalidLength));
      expect(PinError.values, contains(PinError.invalidFormat));
      expect(PinError.values, contains(PinError.notEnabled));
      expect(PinError.values, contains(PinError.lockedOut));
      expect(PinError.values.length, 5);
    });
  });

  group('PIN Constants', () {
    test('kMaxPinAttempts يساوي 5', () {
      expect(kMaxPinAttempts, 5);
    });

    test('kLockoutDuration يساوي 15 دقيقة', () {
      expect(kLockoutDuration, const Duration(minutes: 15));
    });

    test('kMinPinLength يساوي 4', () {
      expect(kMinPinLength, 4);
    });

    test('kMaxPinLength يساوي 6', () {
      expect(kMaxPinLength, 6);
    });

    test('kSaltLength يساوي 32', () {
      expect(kSaltLength, 32);
    });

    test('kPbkdf2Iterations يساوي 100000', () {
      expect(kPbkdf2Iterations, 100000);
    });

    test('kDerivedKeyLength يساوي 32', () {
      expect(kDerivedKeyLength, 32);
    });
  });
}
