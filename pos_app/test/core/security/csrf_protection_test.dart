import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/security/csrf_protection.dart';

void main() {
  group('CsrfProtection', () {
    setUp(() {
      // إعادة تعيين الحالة قبل كل اختبار
      CsrfProtection.invalidate();
    });

    group('generateToken', () {
      test('ينشئ token غير فارغ', () {
        final token = CsrfProtection.generateToken();

        expect(token, isNotEmpty);
      });

      test('ينشئ tokens مختلفة في كل مرة', () {
        final token1 = CsrfProtection.generateToken();
        CsrfProtection.invalidate();
        final token2 = CsrfProtection.generateToken();

        expect(token1, isNot(equals(token2)));
      });

      test('Token له طول مناسب', () {
        final token = CsrfProtection.generateToken();

        // SHA-256 hash في base64 = ~43 characters
        expect(token.length, greaterThan(40));
      });
    });

    group('getToken', () {
      test('يعيد نفس الـ token إذا لم ينتهِ', () {
        final token1 = CsrfProtection.getToken();
        final token2 = CsrfProtection.getToken();

        expect(token1, equals(token2));
      });

      test('ينشئ token جديد إذا لم يكن موجوداً', () {
        final token = CsrfProtection.getToken();

        expect(token, isNotEmpty);
      });
    });

    group('validateToken', () {
      test('يقبل token صحيح', () {
        final token = CsrfProtection.generateToken();

        final isValid = CsrfProtection.validateToken(token);

        expect(isValid, isTrue);
      });

      test('يرفض token خاطئ', () {
        CsrfProtection.generateToken();

        final isValid = CsrfProtection.validateToken('invalid-token');

        expect(isValid, isFalse);
      });

      test('يرفض token فارغ', () {
        CsrfProtection.generateToken();

        final isValid = CsrfProtection.validateToken('');

        expect(isValid, isFalse);
      });

      test('يرفض إذا لم يكن هناك token مخزن', () {
        // لا ننشئ token
        final isValid = CsrfProtection.validateToken('any-token');

        expect(isValid, isFalse);
      });

      test('يرفض token بطول مختلف', () {
        CsrfProtection.generateToken();

        final isValid = CsrfProtection.validateToken('short');

        expect(isValid, isFalse);
      });
    });

    group('invalidate', () {
      test('يبطل الـ token الحالي', () {
        final token = CsrfProtection.generateToken();

        CsrfProtection.invalidate();

        final isValid = CsrfProtection.validateToken(token);
        expect(isValid, isFalse);
      });

      test('يسمح بإنشاء token جديد بعد الإبطال', () {
        final oldToken = CsrfProtection.generateToken();
        CsrfProtection.invalidate();
        final newToken = CsrfProtection.generateToken();

        expect(newToken, isNot(equals(oldToken)));
        expect(CsrfProtection.validateToken(newToken), isTrue);
      });
    });

    group('getHeaders', () {
      test('يعيد headers مع X-CSRF-Token', () {
        final headers = CsrfProtection.getHeaders();

        expect(headers, containsPair('X-CSRF-Token', isNotEmpty));
      });

      test('يعيد نفس الـ token في الـ headers', () {
        final token = CsrfProtection.getToken();
        final headers = CsrfProtection.getHeaders();

        expect(headers['X-CSRF-Token'], equals(token));
      });
    });

    group('constant time comparison', () {
      test('يمنع timing attacks - tokens متشابهة', () {
        final token = CsrfProtection.generateToken();

        // Token مع اختلاف بسيط في البداية
        final similarToken = 'X${token.substring(1)}';

        final isValid = CsrfProtection.validateToken(similarToken);
        expect(isValid, isFalse);
      });
    });
  });

  group('CsrfException', () {
    test('يحتوي على الرسالة الصحيحة', () {
      final exception = CsrfException('Test message');

      expect(exception.message, equals('Test message'));
      expect(exception.toString(), contains('Test message'));
    });
  });

  group('CsrfValidatorMixin', () {
    test('validateCsrfHeader يقبل header صحيح', () {
      final validator = _TestValidator();
      final token = CsrfProtection.generateToken();

      final result = validator.validateCsrfHeader({'X-CSRF-Token': token});

      expect(result, isTrue);
    });

    test('validateCsrfHeader يقبل header بحروف صغيرة', () {
      final validator = _TestValidator();
      final token = CsrfProtection.generateToken();

      final result = validator.validateCsrfHeader({'x-csrf-token': token});

      expect(result, isTrue);
    });

    test('validateCsrfHeader يرمي استثناء عند غياب الـ header', () {
      final validator = _TestValidator();
      CsrfProtection.generateToken();

      expect(
        () => validator.validateCsrfHeader({}),
        throwsA(isA<CsrfException>()),
      );
    });

    test('validateCsrfHeader يرمي استثناء عند token خاطئ', () {
      final validator = _TestValidator();
      CsrfProtection.generateToken();

      expect(
        () => validator.validateCsrfHeader({'X-CSRF-Token': 'invalid'}),
        throwsA(isA<CsrfException>()),
      );
    });
  });
}

/// فئة اختبار للـ Mixin
class _TestValidator with CsrfValidatorMixin {}
