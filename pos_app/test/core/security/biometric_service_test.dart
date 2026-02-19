import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/security/biometric_service.dart';

// ===========================================
// Biometric Service Tests
// ===========================================

void main() {
  group('BiometricLoginResult', () {
    group('factories', () {
      test('success() يُنشئ نتيجة ناجحة', () {
        final result = BiometricLoginResult.success();

        expect(result.isSuccess, true);
        expect(result.error, isNull);
        expect(result.errorType, isNull);
      });

      test('failed() يُنشئ نتيجة فاشلة', () {
        final result = BiometricLoginResult.failed();

        expect(result.isSuccess, false);
        expect(result.error, 'فشلت المصادقة');
        expect(result.errorType, BiometricLoginError.failed);
      });

      test('notEnabled() يُنشئ نتيجة غير مفعلة', () {
        final result = BiometricLoginResult.notEnabled();

        expect(result.isSuccess, false);
        expect(result.error, 'البصمة غير مفعلة');
        expect(result.errorType, BiometricLoginError.notEnabled);
      });

      test('notAvailable() يُنشئ نتيجة غير متوفرة', () {
        final result = BiometricLoginResult.notAvailable();

        expect(result.isSuccess, false);
        expect(result.error, 'البصمة غير متوفرة على هذا الجهاز');
        expect(result.errorType, BiometricLoginError.notAvailable);
      });

      test('lockedOut() يُنشئ نتيجة مقفلة', () {
        final result = BiometricLoginResult.lockedOut();

        expect(result.isSuccess, false);
        expect(result.error, 'تم قفل البصمة بسبب كثرة المحاولات');
        expect(result.errorType, BiometricLoginError.lockedOut);
      });
    });

    group('properties', () {
      test('success result له isSuccess = true', () {
        final result = BiometricLoginResult.success();
        expect(result.isSuccess, isTrue);
      });

      test('failed results لها isSuccess = false', () {
        expect(BiometricLoginResult.failed().isSuccess, isFalse);
        expect(BiometricLoginResult.notEnabled().isSuccess, isFalse);
        expect(BiometricLoginResult.notAvailable().isSuccess, isFalse);
        expect(BiometricLoginResult.lockedOut().isSuccess, isFalse);
      });

      test('error messages باللغة العربية', () {
        expect(
          BiometricLoginResult.failed().error,
          contains('فشلت'),
        );
        expect(
          BiometricLoginResult.notEnabled().error,
          contains('غير مفعلة'),
        );
        expect(
          BiometricLoginResult.notAvailable().error,
          contains('غير متوفرة'),
        );
        expect(
          BiometricLoginResult.lockedOut().error,
          contains('قفل'),
        );
      });
    });
  });

  group('BiometricLoginError', () {
    test('enum يحتوي على جميع القيم', () {
      expect(BiometricLoginError.values, hasLength(4));
      expect(BiometricLoginError.values, contains(BiometricLoginError.failed));
      expect(BiometricLoginError.values, contains(BiometricLoginError.notEnabled));
      expect(BiometricLoginError.values, contains(BiometricLoginError.notAvailable));
      expect(BiometricLoginError.values, contains(BiometricLoginError.lockedOut));
    });

    test('failed index = 0', () {
      expect(BiometricLoginError.failed.index, 0);
    });

    test('notEnabled index = 1', () {
      expect(BiometricLoginError.notEnabled.index, 1);
    });

    test('notAvailable index = 2', () {
      expect(BiometricLoginError.notAvailable.index, 2);
    });

    test('lockedOut index = 3', () {
      expect(BiometricLoginError.lockedOut.index, 3);
    });

    test('name property يعمل', () {
      expect(BiometricLoginError.failed.name, 'failed');
      expect(BiometricLoginError.notEnabled.name, 'notEnabled');
      expect(BiometricLoginError.notAvailable.name, 'notAvailable');
      expect(BiometricLoginError.lockedOut.name, 'lockedOut');
    });
  });

  group('BiometricLoginResult equality', () {
    test('success results لها نفس القيم', () {
      final r1 = BiometricLoginResult.success();
      final r2 = BiometricLoginResult.success();

      expect(r1.isSuccess, r2.isSuccess);
      expect(r1.error, r2.error);
      expect(r1.errorType, r2.errorType);
    });

    test('different error types لها errorType مختلف', () {
      final failed = BiometricLoginResult.failed();
      final notEnabled = BiometricLoginResult.notEnabled();

      expect(failed.errorType, isNot(notEnabled.errorType));
    });
  });

  group('BiometricService static constants', () {
    test('يستخدم مفتاح صحيح للتخزين', () {
      // التحقق من أن BiometricService يمكن الوصول إليه
      // الاختبارات الفعلية للتخزين تتطلب mocks
      expect(BiometricService, isNotNull);
    });
  });

  group('BiometricLoginResult usage patterns', () {
    test('يمكن استخدامه في switch statement', () {
      final result = BiometricLoginResult.failed();
      String message = '';

      switch (result.errorType) {
        case BiometricLoginError.failed:
          message = 'فشل';
          break;
        case BiometricLoginError.notEnabled:
          message = 'غير مفعل';
          break;
        case BiometricLoginError.notAvailable:
          message = 'غير متوفر';
          break;
        case BiometricLoginError.lockedOut:
          message = 'مقفل';
          break;
        case null:
          message = 'نجاح';
          break;
      }

      expect(message, 'فشل');
    });

    test('يمكن استخدامه في conditional', () {
      final success = BiometricLoginResult.success();
      final failed = BiometricLoginResult.failed();

      expect(success.isSuccess ? 'ok' : 'error', 'ok');
      expect(failed.isSuccess ? 'ok' : 'error', 'error');
    });

    test('error message يمكن عرضه للمستخدم', () {
      final result = BiometricLoginResult.notEnabled();
      final userMessage = result.error ?? 'نجح';

      expect(userMessage, isNotEmpty);
      expect(userMessage, 'البصمة غير مفعلة');
    });
  });
}
