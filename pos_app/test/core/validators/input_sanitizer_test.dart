import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/validators/input_sanitizer.dart';

void main() {
  group('InputSanitizer.sanitize', () {
    test('trims whitespace', () {
      expect(InputSanitizer.sanitize('  hello  '), equals('hello'));
    });

    test('normalizes multiple spaces', () {
      expect(InputSanitizer.sanitize('hello   world'), equals('hello world'));
    });

    test('removes control characters', () {
      expect(InputSanitizer.sanitize('hello\x00world'), equals('helloworld'));
    });

    test('preserves Arabic text', () {
      expect(InputSanitizer.sanitize('مرحبا بالعالم'), equals('مرحبا بالعالم'));
    });

    test('handles empty string', () {
      expect(InputSanitizer.sanitize(''), equals(''));
    });

    test('normalizes newlines to spaces', () {
      // \n is \x0A which survives control char removal
      // but \s+ replaces all whitespace including \n with single space
      expect(InputSanitizer.sanitize('hello\nworld'), equals('hello world'));
    });
  });

  group('InputSanitizer.sanitizeHtml', () {
    test('escapes angle brackets', () {
      final result = InputSanitizer.sanitizeHtml('<script>alert(1)</script>');
      expect(result, contains('&lt;'));
      expect(result, contains('&gt;'));
      expect(result, isNot(contains('<script>')));
    });

    test('escapes ampersand', () {
      expect(InputSanitizer.sanitizeHtml('a&b'), contains('&amp;'));
    });

    test('escapes double quotes', () {
      expect(InputSanitizer.sanitizeHtml('a"b'), contains('&quot;'));
    });

    test('escapes single quotes', () {
      expect(InputSanitizer.sanitizeHtml("a'b"), contains('&#x27;'));
    });

    test('escapes forward slash', () {
      expect(InputSanitizer.sanitizeHtml('a/b'), contains('&#x2F;'));
    });

    test('escapes backtick', () {
      expect(InputSanitizer.sanitizeHtml('a`b'), contains('&#x60;'));
    });

    test('escapes equals sign', () {
      expect(InputSanitizer.sanitizeHtml('a=b'), contains('&#x3D;'));
    });
  });

  group('InputSanitizer.stripHtmlTags', () {
    test('strips simple HTML tags', () {
      expect(
        InputSanitizer.stripHtmlTags('<b>bold</b>'),
        equals('bold'),
      );
    });

    test('strips script tags', () {
      expect(
        InputSanitizer.stripHtmlTags('<script>alert(1)</script>'),
        equals('alert(1)'),
      );
    });

    test('strips nested tags', () {
      expect(
        InputSanitizer.stripHtmlTags('<div><p>text</p></div>'),
        equals('text'),
      );
    });

    test('returns plain text unchanged', () {
      expect(
        InputSanitizer.stripHtmlTags('no tags here'),
        equals('no tags here'),
      );
    });
  });

  group('InputSanitizer.sanitizeForDb', () {
    test('escapes single quotes', () {
      expect(
        InputSanitizer.sanitizeForDb("it's"),
        contains("''"),
      );
    });

    test('escapes backslash', () {
      expect(
        InputSanitizer.sanitizeForDb('a\\b'),
        contains('\\\\'),
      );
    });

    test('escapes double quotes', () {
      expect(
        InputSanitizer.sanitizeForDb('a"b'),
        contains('\\"'),
      );
    });

    test('removes control characters', () {
      final result = InputSanitizer.sanitizeForDb('hello\x00world');
      expect(result, isNot(contains('\x00')));
    });

    test('removes newlines (control char removal happens first)', () {
      final result = InputSanitizer.sanitizeForDb('line1\nline2');
      // \n (\x0A) is in [\x00-\x1F] range, so gets removed first
      expect(result, isNot(contains('\n')));
    });

    test('removes tabs (control char removal happens first)', () {
      final result = InputSanitizer.sanitizeForDb('col1\tcol2');
      // \t (\x09) is in [\x00-\x1F] range, so gets removed first
      expect(result, isNot(contains('\t')));
    });
  });

  group('InputSanitizer.sanitizePath', () {
    test('removes double dot traversal', () {
      final result = InputSanitizer.sanitizePath('../etc/passwd');
      expect(result, isNot(contains('..')));
    });

    test('removes double slashes', () {
      final result = InputSanitizer.sanitizePath('path//to//file');
      expect(result, isNot(contains('//')));
    });

    test('removes dangerous characters', () {
      final result = InputSanitizer.sanitizePath('file<>:"|?*name');
      expect(result, isNot(contains('<')));
      expect(result, isNot(contains('>')));
      expect(result, isNot(contains('"')));
    });

    test('preserves valid paths', () {
      final result = InputSanitizer.sanitizePath('path/to/file.txt');
      expect(result, contains('path'));
      expect(result, contains('file.txt'));
    });
  });

  group('InputSanitizer.sanitizeForShell', () {
    test('removes semicolons', () {
      expect(
        InputSanitizer.sanitizeForShell('cmd; rm -rf /'),
        isNot(contains(';')),
      );
    });

    test('removes pipe operator', () {
      expect(
        InputSanitizer.sanitizeForShell('cmd | cat /etc/passwd'),
        isNot(contains('|')),
      );
    });

    test('removes backticks', () {
      expect(
        InputSanitizer.sanitizeForShell('cmd `whoami`'),
        isNot(contains('`')),
      );
    });

    test('removes dollar sign', () {
      expect(
        InputSanitizer.sanitizeForShell('echo \$HOME'),
        isNot(contains('\$')),
      );
    });
  });

  group('InputSanitizer.sanitizePhone', () {
    test('keeps only digits and plus', () {
      expect(
        InputSanitizer.sanitizePhone('+966 50 123-4567'),
        equals('+966501234567'),
      );
    });

    test('removes spaces', () {
      expect(
        InputSanitizer.sanitizePhone('050 123 4567'),
        equals('0501234567'),
      );
    });

    test('removes dashes', () {
      expect(
        InputSanitizer.sanitizePhone('050-123-4567'),
        equals('0501234567'),
      );
    });

    test('removes parentheses', () {
      expect(
        InputSanitizer.sanitizePhone('(050) 1234567'),
        equals('0501234567'),
      );
    });
  });

  group('InputSanitizer.sanitizeEmail', () {
    test('trims whitespace', () {
      expect(
        InputSanitizer.sanitizeEmail('  user@example.com  '),
        equals('user@example.com'),
      );
    });

    test('converts to lowercase', () {
      expect(
        InputSanitizer.sanitizeEmail('User@Example.COM'),
        equals('user@example.com'),
      );
    });
  });

  group('InputSanitizer.sanitizeName', () {
    test('preserves Arabic names', () {
      expect(
        InputSanitizer.sanitizeName('أحمد محمد'),
        equals('أحمد محمد'),
      );
    });

    test('preserves English names', () {
      expect(
        InputSanitizer.sanitizeName('John Smith'),
        equals('John Smith'),
      );
    });

    test('removes numbers', () {
      expect(
        InputSanitizer.sanitizeName('Ahmed123'),
        equals('Ahmed'),
      );
    });

    test('removes special characters', () {
      expect(
        InputSanitizer.sanitizeName('Ahmed@#\$'),
        equals('Ahmed'),
      );
    });

    test('preserves hyphens', () {
      expect(
        InputSanitizer.sanitizeName('Al-Ahmed'),
        equals('Al-Ahmed'),
      );
    });

    test('normalizes spaces', () {
      expect(
        InputSanitizer.sanitizeName('Ahmed   Mohammed'),
        equals('Ahmed Mohammed'),
      );
    });
  });

  group('InputSanitizer.sanitizeFilename', () {
    test('preserves valid filenames', () {
      expect(
        InputSanitizer.sanitizeFilename('report.pdf'),
        equals('report.pdf'),
      );
    });

    test('removes special characters', () {
      expect(
        InputSanitizer.sanitizeFilename('file<>name.txt'),
        equals('filename.txt'),
      );
    });

    test('removes multiple dots', () {
      final result = InputSanitizer.sanitizeFilename('file...name.txt');
      expect(result, isNot(contains('..')));
    });

    test('preserves Arabic characters', () {
      final result = InputSanitizer.sanitizeFilename('تقرير.pdf');
      expect(result, contains('تقرير'));
    });
  });

  group('InputSanitizer.sanitizeUrl', () {
    test('blocks javascript: protocol', () {
      expect(
        InputSanitizer.sanitizeUrl('javascript:alert(1)'),
        equals(''),
      );
    });

    test('blocks data: protocol', () {
      expect(
        InputSanitizer.sanitizeUrl('data:text/html,<h1>test</h1>'),
        equals(''),
      );
    });

    test('blocks vbscript: protocol', () {
      expect(
        InputSanitizer.sanitizeUrl('vbscript:msgbox(1)'),
        equals(''),
      );
    });

    test('allows https URLs', () {
      final result = InputSanitizer.sanitizeUrl('https://example.com/path');
      expect(result, contains('https'));
      expect(result, contains('example.com'));
    });
  });

  group('InputSanitizer.containsDangerousContent', () {
    test('detects script tags', () {
      expect(
        InputSanitizer.containsDangerousContent('<script>alert(1)</script>'),
        isTrue,
      );
    });

    test('detects javascript protocol', () {
      expect(
        InputSanitizer.containsDangerousContent('javascript:alert(1)'),
        isTrue,
      );
    });

    test('detects onerror handler', () {
      expect(
        InputSanitizer.containsDangerousContent('onerror=alert(1)'),
        isTrue,
      );
    });

    test('detects onload handler', () {
      expect(
        InputSanitizer.containsDangerousContent('onload=alert(1)'),
        isTrue,
      );
    });

    test('detects onclick handler', () {
      expect(
        InputSanitizer.containsDangerousContent('onclick=alert(1)'),
        isTrue,
      );
    });

    test('detects SQL injection: semicolon', () {
      expect(
        InputSanitizer.containsDangerousContent("'; DROP TABLE users;"),
        isTrue,
      );
    });

    test('detects SQL injection: UNION SELECT', () {
      expect(
        InputSanitizer.containsDangerousContent('1 UNION SELECT * FROM users'),
        isTrue,
      );
    });

    test('detects SQL injection: OR', () {
      expect(
        InputSanitizer.containsDangerousContent("1' or '1'='1"),
        isTrue,
      );
    });

    test('detects SQL comment --', () {
      expect(
        InputSanitizer.containsDangerousContent("admin'--"),
        isTrue,
      );
    });

    test('allows safe content', () {
      expect(
        InputSanitizer.containsDangerousContent('Hello World'),
        isFalse,
      );
    });

    test('allows Arabic content', () {
      expect(
        InputSanitizer.containsDangerousContent('مرحبا بالعالم'),
        isFalse,
      );
    });

    test('allows numbers', () {
      expect(
        InputSanitizer.containsDangerousContent('12345'),
        isFalse,
      );
    });
  });

  group('InputSanitizer.sanitizeNumeric', () {
    test('keeps only digits', () {
      expect(InputSanitizer.sanitizeNumeric('abc123def'), equals('123'));
    });

    test('removes spaces and dashes', () {
      expect(InputSanitizer.sanitizeNumeric('123-456 789'), equals('123456789'));
    });

    test('returns empty for non-numeric input', () {
      expect(InputSanitizer.sanitizeNumeric('abc'), equals(''));
    });
  });

  group('InputSanitizer.sanitizeDecimal', () {
    test('keeps digits and dot', () {
      expect(InputSanitizer.sanitizeDecimal('12.50'), equals('12.50'));
    });

    test('removes non-numeric non-dot characters', () {
      expect(InputSanitizer.sanitizeDecimal('\$12.50'), equals('12.50'));
    });

    test('handles multiple dots by keeping only first', () {
      final result = InputSanitizer.sanitizeDecimal('12.50.30');
      // Should join extra decimal parts
      expect(result, equals('12.5030'));
    });
  });

  group('InputSanitizer.sanitizeJsonString', () {
    test('escapes backslash', () {
      expect(
        InputSanitizer.sanitizeJsonString('a\\b'),
        contains('\\\\'),
      );
    });

    test('escapes double quotes', () {
      expect(
        InputSanitizer.sanitizeJsonString('a"b'),
        contains('\\"'),
      );
    });

    test('escapes newlines', () {
      expect(
        InputSanitizer.sanitizeJsonString('line1\nline2'),
        contains('\\n'),
      );
    });
  });

  group('StringSanitizer extension', () {
    test('sanitizedHtml escapes HTML', () {
      expect('<b>'.sanitizedHtml, contains('&lt;'));
    });

    test('sanitizedForDb escapes for DB', () {
      expect("it's".sanitizedForDb, contains("''"));
    });

    test('sanitized trims and normalizes', () {
      expect('  hello   world  '.sanitized, equals('hello world'));
    });

    test('sanitizedName removes numbers', () {
      expect('Ahmed123'.sanitizedName, equals('Ahmed'));
    });

    test('sanitizedPhone keeps digits and plus', () {
      expect('+966-50-123'.sanitizedPhone, equals('+96650123'));
    });

    test('sanitizedEmail lowercases and trims', () {
      expect('  User@EXAMPLE.com  '.sanitizedEmail, equals('user@example.com'));
    });

    test('hasDangerousContent detects XSS', () {
      expect('<script>alert(1)</script>'.hasDangerousContent, isTrue);
    });

    test('hasDangerousContent returns false for safe text', () {
      expect('Hello World'.hasDangerousContent, isFalse);
    });
  });
}
