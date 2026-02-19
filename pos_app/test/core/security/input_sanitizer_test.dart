import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/security/input_sanitizer.dart';

void main() {
  group('InputSanitizer', () {
    group('sanitize', () {
      test('يزيل HTML tags', () {
        final result = InputSanitizer.sanitize('<script>alert("xss")</script>');
        expect(result, isNot(contains('<script>')));
      });

      test('يحافظ على النص العربي', () {
        final result = InputSanitizer.sanitize('مرحبا بك');
        expect(result, equals('مرحبا بك'));
      });

      test('يزيل control characters', () {
        final result = InputSanitizer.sanitize('test\x00\x1F');
        expect(result, isNot(contains('\x00')));
      });
    });

    group('sanitizeForSql', () {
      test('يهرب الـ single quotes', () {
        final result = InputSanitizer.sanitizeForSql("O'Brien");
        expect(result, contains("''"));
      });

      test('يزيل SQL injection patterns', () {
        final result = InputSanitizer.sanitizeForSql("'; DROP TABLE users; --");
        expect(result.toLowerCase(), isNot(contains('drop')));
      });

      test('يزيل UNION attacks', () {
        final result = InputSanitizer.sanitizeForSql("1 UNION SELECT * FROM users");
        expect(result.toLowerCase(), isNot(contains('union')));
      });
    });

    group('sanitizeForHtml', () {
      test('يهرب HTML entities', () {
        final result = InputSanitizer.sanitizeForHtml('<div>test</div>');
        expect(result, contains('&lt;'));
        expect(result, contains('&gt;'));
      });

      test('يزيل javascript:', () {
        final result = InputSanitizer.sanitizeForHtml('javascript:alert(1)');
        expect(result.toLowerCase(), isNot(contains('javascript:')));
      });

      test('يزيل onclick handlers', () {
        final result = InputSanitizer.sanitizeForHtml('<a onclick="evil()">');
        expect(result.toLowerCase(), isNot(contains('onclick=')));
      });
    });

    group('sanitizeFilePath', () {
      test('يزيل path traversal', () {
        final result = InputSanitizer.sanitizeFilePath('../../../etc/passwd');
        expect(result, isNot(contains('..')));
      });

      test('يزيل encoded path traversal', () {
        final result = InputSanitizer.sanitizeFilePath('%2e%2e/etc/passwd');
        expect(result.toLowerCase(), isNot(contains('%2e%2e')));
      });

      test('يزيل null bytes', () {
        final result = InputSanitizer.sanitizeFilePath('file.txt\x00.jpg');
        expect(result, isNot(contains('\x00')));
      });
    });

    group('validate', () {
      test('يكشف SQL injection', () {
        final result = InputSanitizer.validate(
          "'; DELETE FROM users; --",
          checkSql: true,
        );
        expect(result.isValid, isFalse);
        expect(result.issues, contains('Potential SQL injection detected'));
      });

      test('يكشف XSS', () {
        final result = InputSanitizer.validate(
          '<script>alert("xss")</script>',
          checkXss: true,
        );
        expect(result.isValid, isFalse);
        expect(result.issues, contains('Potential XSS detected'));
      });

      test('يقبل النص العادي', () {
        final result = InputSanitizer.validate('Hello World');
        expect(result.isValid, isTrue);
        expect(result.issues, isEmpty);
      });
    });

    group('validateEmail', () {
      test('يقبل email صحيح', () {
        final result = InputSanitizer.validateEmail('test@example.com');
        expect(result.isValid, isTrue);
        expect(result.sanitizedValue, equals('test@example.com'));
      });

      test('يرفض email غير صحيح', () {
        final result = InputSanitizer.validateEmail('invalid-email');
        expect(result.isValid, isFalse);
      });

      test('يحول لـ lowercase', () {
        final result = InputSanitizer.validateEmail('Test@EXAMPLE.com');
        expect(result.sanitizedValue, equals('test@example.com'));
      });
    });

    group('validatePhone', () {
      test('يقبل رقم سعودي صحيح', () {
        final result = InputSanitizer.validatePhone('0512345678');
        expect(result.isValid, isTrue);
        expect(result.sanitizedValue, equals('+966512345678'));
      });

      test('يقبل رقم مع +966', () {
        final result = InputSanitizer.validatePhone('+966512345678');
        expect(result.isValid, isTrue);
      });

      test('يرفض رقم غير صحيح', () {
        final result = InputSanitizer.validatePhone('123');
        expect(result.isValid, isFalse);
      });

      test('يزيل المسافات', () {
        final result = InputSanitizer.validatePhone('051 234 5678');
        expect(result.isValid, isTrue);
      });
    });

    group('validatePin', () {
      test('يقبل PIN صحيح', () {
        final result = InputSanitizer.validatePin('1379');
        expect(result.isValid, isTrue);
      });

      test('يرفض PIN قصير جداً', () {
        final result = InputSanitizer.validatePin('123');
        expect(result.isValid, isFalse);
        expect(result.issues, contains('PIN must be 4-6 digits'));
      });

      test('يرفض PIN مع حروف', () {
        final result = InputSanitizer.validatePin('12ab');
        expect(result.isValid, isFalse);
      });

      test('يرفض PIN ضعيف - أرقام متكررة', () {
        final result = InputSanitizer.validatePin('1111');
        expect(result.isValid, isFalse);
        expect(result.issues, contains('PIN is too weak'));
      });

      test('يرفض PIN ضعيف - تسلسلي', () {
        final result = InputSanitizer.validatePin('1234');
        expect(result.isValid, isFalse);
      });
    });

    group('validateAmount', () {
      test('يقبل مبلغ صحيح', () {
        final result = InputSanitizer.validateAmount('100.50');
        expect(result.isValid, isTrue);
        expect(result.sanitizedValue, equals('100.50'));
      });

      test('يقبل مبلغ بدون كسور', () {
        final result = InputSanitizer.validateAmount('100');
        expect(result.isValid, isTrue);
      });

      test('يرفض مبلغ سالب', () {
        final result = InputSanitizer.validateAmount('-100');
        expect(result.isValid, isFalse);
      });

      test('يرفض نص غير رقمي', () {
        final result = InputSanitizer.validateAmount('abc');
        expect(result.isValid, isFalse);
      });
    });

    group('validateBarcode', () {
      test('يقبل barcode صحيح', () {
        final result = InputSanitizer.validateBarcode('ABC123');
        expect(result.isValid, isTrue);
        expect(result.sanitizedValue, equals('ABC123'));
      });

      test('يرفض barcode قصير', () {
        final result = InputSanitizer.validateBarcode('AB');
        expect(result.isValid, isFalse);
      });

      test('يرفض حروف خاصة', () {
        final result = InputSanitizer.validateBarcode('ABC@123');
        expect(result.isValid, isFalse);
      });
    });
  });

  group('SanitizeExtension', () {
    test('sanitized يعمل', () {
      expect('<script>'.sanitized, isNot(contains('<')));
    });

    test('sqlSafe يعمل', () {
      expect("O'Brien".sqlSafe, contains("''"));
    });

    test('htmlSafe يعمل', () {
      expect('<div>'.htmlSafe, contains('&lt;'));
    });

    test('validated يعمل', () {
      expect('Hello'.validated.isValid, isTrue);
    });
  });
}
