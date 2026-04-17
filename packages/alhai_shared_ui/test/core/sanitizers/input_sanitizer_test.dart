import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/src/core/sanitizers/input_sanitizer.dart';

void main() {
  group('TextInputSanitizer.sanitize', () {
    test('null input returns empty string', () {
      expect(TextInputSanitizer.sanitize(null), '');
    });

    test('simple text passes through unchanged', () {
      expect(TextInputSanitizer.sanitize('Hello'), 'Hello');
    });

    test('strips bidi override U+202E', () {
      // "100" + RIGHT-TO-LEFT OVERRIDE + "003"  →  bidi removed, digits joined
      expect(TextInputSanitizer.sanitize('100\u202E003'), '100003');
    });

    test('strips zero-width space U+200B', () {
      expect(TextInputSanitizer.sanitize('a\u200Bb'), 'ab');
    });

    test('strips zero-width joiner and BOM', () {
      expect(TextInputSanitizer.sanitize('x\u200Dy\uFEFFz'), 'xyz');
    });

    test('strips HTML script tags', () {
      expect(
        TextInputSanitizer.sanitize('<script>alert(1)</script>'),
        'alert(1)',
      );
    });

    test('strips HTML line break tag', () {
      expect(TextInputSanitizer.sanitize('name<br>rest'), 'namerest');
    });

    test('strips control char BEL (0x07)', () {
      expect(TextInputSanitizer.sanitize('a\x07b'), 'ab');
    });

    test('preserveNewlines: true keeps \\n', () {
      expect(
        TextInputSanitizer.sanitize('line1\nline2', preserveNewlines: true),
        'line1\nline2',
      );
    });

    test('preserveNewlines: false collapses \\n to space', () {
      expect(
        TextInputSanitizer.sanitize('line1\nline2'),
        'line1 line2',
      );
    });

    test('collapses runs of spaces', () {
      expect(TextInputSanitizer.sanitize('a    b'), 'a b');
    });

    test('maxLength truncates and re-trims', () {
      expect(
        TextInputSanitizer.sanitize('abcdefghij', maxLength: 5),
        'abcde',
      );
    });

    test('maxLength with trailing space after truncation', () {
      // "a b c d e" truncated to 6 = "a b c " → re-trimmed → "a b c"
      expect(
        TextInputSanitizer.sanitize('a b c d e', maxLength: 6),
        'a b c',
      );
    });

    test('allowHtml: true retains angle brackets', () {
      expect(
        TextInputSanitizer.sanitize('<b>bold</b>', allowHtml: true),
        '<b>bold</b>',
      );
    });

    test('preserves Arabic text', () {
      expect(TextInputSanitizer.sanitize('مرحبا بالعالم'), 'مرحبا بالعالم');
    });

    test('trims leading and trailing whitespace', () {
      expect(TextInputSanitizer.sanitize('   hello   '), 'hello');
    });

    test('strips C1 control range U+0080..U+009F', () {
      expect(TextInputSanitizer.sanitize('a\u0085b'), 'ab');
    });

    test('strips left-to-right mark U+200E', () {
      expect(TextInputSanitizer.sanitize('a\u200Eb'), 'ab');
    });
  });

  group('TextInputSanitizer.sanitizePhone', () {
    test('null returns empty', () {
      expect(TextInputSanitizer.sanitizePhone(null), '');
    });

    test('Saudi international format with spaces and dashes', () {
      expect(
        TextInputSanitizer.sanitizePhone('+966 50-123-4567'),
        '+966501234567',
      );
    });

    test('local format strips trailing letters', () {
      expect(
        TextInputSanitizer.sanitizePhone('0501234567abc'),
        '0501234567',
      );
    });

    test('parentheses stripped', () {
      expect(
        TextInputSanitizer.sanitizePhone('(050) 123-4567'),
        '0501234567',
      );
    });

    test('plus preserved only if leading', () {
      expect(TextInputSanitizer.sanitizePhone('050+123'), '050123');
    });
  });

  group('TextInputSanitizer.sanitizeName', () {
    test('trims whitespace', () {
      expect(TextInputSanitizer.sanitizeName('  John Doe  '), 'John Doe');
    });

    test('enforces 200-char ceiling', () {
      final long = 'a' * 250;
      expect(TextInputSanitizer.sanitizeName(long).length, 200);
    });

    test('strips bidi override (receipt integrity)', () {
      expect(
        TextInputSanitizer.sanitizeName('Ahmed\u202Eevil'),
        'Ahmedevil',
      );
    });

    test('strips zero-width joiner (loyalty-alias defense)', () {
      expect(
        TextInputSanitizer.sanitizeName('Ahmed\u200D'),
        'Ahmed',
      );
    });

    test('collapses internal whitespace runs', () {
      expect(
        TextInputSanitizer.sanitizeName('John      Doe'),
        'John Doe',
      );
    });
  });

  group('TextInputSanitizer.sanitizeNote', () {
    test('preserves newlines', () {
      expect(
        TextInputSanitizer.sanitizeNote('line1\nline2\nline3'),
        'line1\nline2\nline3',
      );
    });

    test('respects 2000 char ceiling', () {
      final long = 'n' * 2500;
      expect(TextInputSanitizer.sanitizeNote(long).length, 2000);
    });

    test('strips HTML inside a note', () {
      expect(
        TextInputSanitizer.sanitizeNote('note<img src=x>body'),
        'notebody',
      );
    });

    test('preserves tabs', () {
      expect(
        TextInputSanitizer.sanitizeNote('col1\tcol2'),
        'col1\tcol2',
      );
    });
  });
}
