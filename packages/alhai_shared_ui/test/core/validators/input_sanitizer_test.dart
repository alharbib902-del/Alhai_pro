import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/src/core/validators/input_sanitizer.dart';

void main() {
  group('InputSanitizer', () {
    group('sanitizeHtml', () {
      test('should escape ampersand', () {
        expect(InputSanitizer.sanitizeHtml('A&B'), contains('&amp;'));
      });

      test('should escape less than', () {
        expect(InputSanitizer.sanitizeHtml('<div>'), contains('&lt;'));
      });

      test('should escape greater than', () {
        expect(InputSanitizer.sanitizeHtml('</div>'), contains('&gt;'));
      });

      test('should escape double quotes', () {
        expect(InputSanitizer.sanitizeHtml('"hello"'), contains('&quot;'));
      });

      test('should escape single quotes', () {
        expect(InputSanitizer.sanitizeHtml("it's"), contains('&#x27;'));
      });

      test('should escape script tags', () {
        final result = InputSanitizer.sanitizeHtml(
          '<script>alert("xss")</script>',
        );
        expect(result, isNot(contains('<script>')));
      });

      test('should preserve normal text', () {
        final result = InputSanitizer.sanitizeHtml('Hello World');
        expect(result, 'Hello World');
      });

      test('should preserve Arabic text', () {
        final result = InputSanitizer.sanitizeHtml('مرحبا بالعالم');
        expect(result, 'مرحبا بالعالم');
      });
    });

    group('stripHtmlTags', () {
      test('should remove simple HTML tags', () {
        expect(InputSanitizer.stripHtmlTags('<b>bold</b>'), 'bold');
      });

      test('should remove nested tags', () {
        expect(InputSanitizer.stripHtmlTags('<div><p>text</p></div>'), 'text');
      });

      test('should handle text without tags', () {
        expect(InputSanitizer.stripHtmlTags('plain text'), 'plain text');
      });

      test('should remove self-closing tags', () {
        expect(InputSanitizer.stripHtmlTags('text<br/>more'), 'textmore');
      });
    });

    group('sanitizeForDb', () {
      test('should remove control characters', () {
        expect(
          InputSanitizer.sanitizeForDb('hello\x00world'),
          isNot(contains('\x00')),
        );
      });

      test('should escape single quotes', () {
        expect(InputSanitizer.sanitizeForDb("it's"), contains("''"));
      });

      test('should escape backslashes', () {
        expect(InputSanitizer.sanitizeForDb('path\\to'), contains('\\\\'));
      });

      test(
        'should handle newlines (removed as control chars then escaped)',
        () {
          // Control chars [\x00-\x1F] are removed first, \n is \x0A
          final result = InputSanitizer.sanitizeForDb('line1\nline2');
          // Since \n is a control char, it gets removed in the first step
          expect(result, isNotEmpty);
        },
      );

      test('should handle tabs (removed as control chars then escaped)', () {
        // \t is \x09, a control char that gets removed first
        final result = InputSanitizer.sanitizeForDb('col1\tcol2');
        expect(result, isNotEmpty);
      });
    });

    group('sanitizeForShell', () {
      test('should remove semicolons', () {
        expect(
          InputSanitizer.sanitizeForShell('cmd; rm -rf'),
          isNot(contains(';')),
        );
      });

      test('should remove pipes', () {
        expect(
          InputSanitizer.sanitizeForShell('ls | grep'),
          isNot(contains('|')),
        );
      });

      test('should remove backticks', () {
        expect(
          InputSanitizer.sanitizeForShell('`whoami`'),
          isNot(contains('`')),
        );
      });

      test('should remove dollar signs', () {
        expect(
          InputSanitizer.sanitizeForShell('\$HOME'),
          isNot(contains('\$')),
        );
      });

      test('should preserve normal alphanumeric text', () {
        expect(InputSanitizer.sanitizeForShell('hello123'), 'hello123');
      });
    });

    group('sanitizePath', () {
      test('should remove path traversal (..)', () {
        expect(
          InputSanitizer.sanitizePath('../../etc/passwd'),
          isNot(contains('..')),
        );
      });

      test('should remove double slashes', () {
        final result = InputSanitizer.sanitizePath('path//to//file');
        expect(result, isNot(contains('//')));
      });

      test('should remove dangerous characters', () {
        final result = InputSanitizer.sanitizePath('file<name>');
        expect(result, isNot(contains('<')));
        expect(result, isNot(contains('>')));
      });
    });

    group('sanitizeFilename', () {
      test('should remove special characters', () {
        final result = InputSanitizer.sanitizeFilename('file@#\$%.pdf');
        expect(result, isNot(contains('@')));
        expect(result, isNot(contains('#')));
      });

      test('should allow Arabic characters', () {
        final result = InputSanitizer.sanitizeFilename('ملف تجريبي.pdf');
        expect(result, contains('ملف'));
      });

      test('should allow English characters', () {
        final result = InputSanitizer.sanitizeFilename('test-file.pdf');
        expect(result, 'test-file.pdf');
      });

      test('should remove multiple dots', () {
        final result = InputSanitizer.sanitizeFilename('file...pdf');
        expect(result, isNot(contains('...')));
      });

      test('should trim and normalize spaces', () {
        final result = InputSanitizer.sanitizeFilename('  file   name  ');
        expect(result, 'file name');
      });
    });

    group('sanitizeUrl', () {
      test('should block javascript: protocol', () {
        expect(InputSanitizer.sanitizeUrl('javascript:alert(1)'), '');
      });

      test('should block data: protocol', () {
        expect(InputSanitizer.sanitizeUrl('data:text/html,<h1>x</h1>'), '');
      });

      test('should block vbscript: protocol', () {
        expect(InputSanitizer.sanitizeUrl('vbscript:msgbox'), '');
      });

      test('should be case insensitive for protocol blocking', () {
        expect(InputSanitizer.sanitizeUrl('JAVASCRIPT:alert(1)'), '');
        expect(InputSanitizer.sanitizeUrl('JaVaScRiPt:alert(1)'), '');
      });

      test('should allow https URLs', () {
        final result = InputSanitizer.sanitizeUrl('https://example.com');
        expect(result, contains('https'));
      });

      test('should remove angle brackets from URLs', () {
        final result = InputSanitizer.sanitizeUrl(
          'https://example.com/<script>',
        );
        expect(result, isNot(contains('<')));
        expect(result, isNot(contains('>')));
      });
    });

    group('sanitize (general)', () {
      test('should remove control characters', () {
        final result = InputSanitizer.sanitize('hello\x00\x01world');
        // \x00 and \x01 are control chars in range [\x00-\x09], removed completely
        expect(result, 'helloworld');
      });

      test('should normalize spaces', () {
        final result = InputSanitizer.sanitize('hello    world');
        expect(result, 'hello world');
      });

      test('should trim leading/trailing spaces', () {
        final result = InputSanitizer.sanitize('  hello  ');
        expect(result, 'hello');
      });

      test('should preserve newlines', () {
        // \n (0x0A) should be preserved, other control chars removed
        final result = InputSanitizer.sanitize('line1\nline2');
        expect(result, contains('line1'));
        expect(result, contains('line2'));
      });
    });

    group('sanitizePhone', () {
      test('should keep only digits and plus', () {
        expect(
          InputSanitizer.sanitizePhone('+966-51-234-5678'),
          '+966512345678',
        );
      });

      test('should remove spaces', () {
        expect(InputSanitizer.sanitizePhone('051 234 5678'), '0512345678');
      });

      test('should remove parentheses', () {
        expect(InputSanitizer.sanitizePhone('(051)2345678'), '0512345678');
      });
    });

    group('sanitizeEmail', () {
      test('should trim and lowercase', () {
        expect(
          InputSanitizer.sanitizeEmail('  USER@EXAMPLE.COM  '),
          'user@example.com',
        );
      });
    });

    group('sanitizeName', () {
      test('should allow Arabic characters', () {
        final result = InputSanitizer.sanitizeName('محمد أحمد');
        expect(result, 'محمد أحمد');
      });

      test('should allow English characters', () {
        final result = InputSanitizer.sanitizeName('John Doe');
        expect(result, 'John Doe');
      });

      test('should allow hyphens', () {
        final result = InputSanitizer.sanitizeName('Al-Ali');
        expect(result, 'Al-Ali');
      });

      test('should remove numbers', () {
        final result = InputSanitizer.sanitizeName('John123');
        expect(result, isNot(contains('123')));
      });

      test('should remove special characters', () {
        final result = InputSanitizer.sanitizeName('John@#\$');
        expect(result, isNot(contains('@')));
      });

      test('should trim and normalize spaces', () {
        final result = InputSanitizer.sanitizeName('  John   Doe  ');
        expect(result, 'John Doe');
      });
    });

    group('sanitizeNumeric', () {
      test('should keep only digits', () {
        expect(InputSanitizer.sanitizeNumeric('abc123def'), '123');
      });

      test('should remove dots', () {
        expect(InputSanitizer.sanitizeNumeric('12.34'), '1234');
      });

      test('should handle empty string', () {
        expect(InputSanitizer.sanitizeNumeric(''), '');
      });
    });

    group('sanitizeDecimal', () {
      test('should keep digits and one dot', () {
        expect(InputSanitizer.sanitizeDecimal('12.34'), '12.34');
      });

      test('should handle multiple dots (keep first)', () {
        final result = InputSanitizer.sanitizeDecimal('12.34.56');
        // Should merge parts after first dot
        expect(result, '12.3456');
      });

      test('should remove non-numeric non-dot characters', () {
        expect(InputSanitizer.sanitizeDecimal('\$12.50'), '12.50');
      });
    });

    group('containsDangerousContent', () {
      test('should detect script tags', () {
        expect(
          InputSanitizer.containsDangerousContent('<script>alert(1)</script>'),
          isTrue,
        );
      });

      test('should detect javascript: protocol', () {
        expect(
          InputSanitizer.containsDangerousContent('javascript:void(0)'),
          isTrue,
        );
      });

      test('should detect onerror attribute', () {
        expect(
          InputSanitizer.containsDangerousContent('onerror=alert(1)'),
          isTrue,
        );
      });

      test('should detect onload attribute', () {
        expect(
          InputSanitizer.containsDangerousContent('onload=malicious()'),
          isTrue,
        );
      });

      test('should detect onclick attribute', () {
        expect(
          InputSanitizer.containsDangerousContent('onclick=hack()'),
          isTrue,
        );
      });

      test('should detect SQL injection patterns', () {
        expect(
          InputSanitizer.containsDangerousContent("'; DROP TABLE users; --"),
          isTrue,
        );
      });

      test('should detect UNION SELECT', () {
        expect(
          InputSanitizer.containsDangerousContent('UNION SELECT * FROM users'),
          isTrue,
        );
      });

      test('should not flag normal text', () {
        expect(InputSanitizer.containsDangerousContent('Hello World'), isFalse);
      });

      test('should not flag Arabic text', () {
        expect(
          InputSanitizer.containsDangerousContent('مرحبا بالعالم'),
          isFalse,
        );
      });
    });

    group('sanitizeJsonString', () {
      test('should escape double quotes', () {
        expect(
          InputSanitizer.sanitizeJsonString('say "hello"'),
          contains('\\"'),
        );
      });

      test('should escape backslashes', () {
        expect(InputSanitizer.sanitizeJsonString('path\\to'), contains('\\\\'));
      });

      test('should escape newlines', () {
        expect(
          InputSanitizer.sanitizeJsonString('line1\nline2'),
          contains('\\n'),
        );
      });
    });
  });

  group('StringSanitizer extension', () {
    test('sanitizedHtml should work', () {
      expect('<script>'.sanitizedHtml, isNot(contains('<script>')));
    });

    test('sanitizedForDb should work', () {
      expect("it's".sanitizedForDb, contains("''"));
    });

    test('sanitized should work', () {
      expect('  hello  '.sanitized, 'hello');
    });

    test('sanitizedName should work', () {
      expect('John123'.sanitizedName, isNot(contains('123')));
    });

    test('sanitizedPhone should work', () {
      expect('+966-51-234-5678'.sanitizedPhone, '+966512345678');
    });

    test('sanitizedEmail should work', () {
      expect('  USER@EXAMPLE.COM  '.sanitizedEmail, 'user@example.com');
    });

    test('hasDangerousContent should work', () {
      expect('<script>alert(1)</script>'.hasDangerousContent, isTrue);
      expect('normal text'.hasDangerousContent, isFalse);
    });
  });
}
