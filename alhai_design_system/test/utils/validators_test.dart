import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

void main() {
  group('AlhaiValidators.saudiPhone', () {
    test('returns null for valid Saudi phone (05x format)', () {
      expect(AlhaiValidators.saudiPhone('0512345678'), isNull);
      expect(AlhaiValidators.saudiPhone('0551234567'), isNull);
    });

    test('returns null for valid Saudi phone (966 format)', () {
      expect(AlhaiValidators.saudiPhone('966512345678'), isNull);
      expect(AlhaiValidators.saudiPhone('966551234567'), isNull);
    });

    test('returns error for empty value', () {
      expect(AlhaiValidators.saudiPhone(null), isNotNull);
      expect(AlhaiValidators.saudiPhone(''), isNotNull);
    });

    test('returns error for invalid number', () {
      expect(AlhaiValidators.saudiPhone('123'), isNotNull);
      expect(AlhaiValidators.saudiPhone('0112345678'), isNotNull);
    });

    test('accepts custom error message', () {
      final result = AlhaiValidators.saudiPhone('', errorMessage: 'Custom error');
      expect(result, 'Custom error');
    });
  });

  group('AlhaiValidators.internationalPhone', () {
    test('returns null for valid numbers', () {
      expect(AlhaiValidators.internationalPhone('12345678'), isNull);
      expect(AlhaiValidators.internationalPhone('+966512345678'), isNull);
    });

    test('returns error for too short', () {
      expect(AlhaiValidators.internationalPhone('1234'), isNotNull);
    });

    test('returns error for too long', () {
      expect(AlhaiValidators.internationalPhone('1234567890123456'), isNotNull);
    });
  });

  group('AlhaiValidators.otp', () {
    test('returns null for valid 6-digit OTP', () {
      expect(AlhaiValidators.otp('123456'), isNull);
    });

    test('returns error for wrong length', () {
      expect(AlhaiValidators.otp('12345'), isNotNull);
      expect(AlhaiValidators.otp('1234567'), isNotNull);
    });

    test('accepts custom length', () {
      expect(AlhaiValidators.otp('1234', length: 4), isNull);
      expect(AlhaiValidators.otp('1234', length: 6), isNotNull);
    });

    test('returns error for empty', () {
      expect(AlhaiValidators.otp(null), isNotNull);
      expect(AlhaiValidators.otp(''), isNotNull);
    });
  });

  group('AlhaiValidators.email', () {
    test('returns null for valid emails', () {
      expect(AlhaiValidators.email('user@example.com'), isNull);
      expect(AlhaiValidators.email('test.user@domain.co'), isNull);
      expect(AlhaiValidators.email('admin+tag@test.org'), isNull);
    });

    test('returns error for invalid emails', () {
      expect(AlhaiValidators.email('notanemail'), isNotNull);
      expect(AlhaiValidators.email('@domain.com'), isNotNull);
      expect(AlhaiValidators.email('user@'), isNotNull);
    });

    test('returns error for empty', () {
      expect(AlhaiValidators.email(null), isNotNull);
      expect(AlhaiValidators.email(''), isNotNull);
    });
  });

  group('AlhaiValidators.required', () {
    test('returns null for non-empty values', () {
      expect(AlhaiValidators.required('hello'), isNull);
      expect(AlhaiValidators.required('  text  '), isNull);
    });

    test('returns error for empty/null/whitespace', () {
      expect(AlhaiValidators.required(null), isNotNull);
      expect(AlhaiValidators.required(''), isNotNull);
      expect(AlhaiValidators.required('   '), isNotNull);
    });
  });

  group('AlhaiValidators.requiredWithMinLength', () {
    test('returns null for valid input', () {
      expect(
        AlhaiValidators.requiredWithMinLength('hello', minLength: 3),
        isNull,
      );
    });

    test('returns error for too short', () {
      expect(
        AlhaiValidators.requiredWithMinLength('hi', minLength: 3),
        isNotNull,
      );
    });

    test('returns error for empty', () {
      expect(
        AlhaiValidators.requiredWithMinLength('', minLength: 1),
        isNotNull,
      );
    });

    test('trims whitespace before checking length', () {
      expect(
        AlhaiValidators.requiredWithMinLength('  a  ', minLength: 3),
        isNotNull,
      );
    });
  });

  group('AlhaiValidators.currency', () {
    test('returns null for valid amounts', () {
      expect(AlhaiValidators.currency('100'), isNull);
      expect(AlhaiValidators.currency('99.99'), isNull);
      expect(AlhaiValidators.currency('0.50'), isNull);
    });

    test('returns error for invalid amounts', () {
      expect(AlhaiValidators.currency('abc'), isNotNull);
      expect(AlhaiValidators.currency(null), isNotNull);
      expect(AlhaiValidators.currency(''), isNotNull);
    });

    test('respects min constraint', () {
      expect(AlhaiValidators.currency('5', min: 10), isNotNull);
      expect(AlhaiValidators.currency('15', min: 10), isNull);
    });

    test('respects max constraint', () {
      expect(AlhaiValidators.currency('150', max: 100), isNotNull);
      expect(AlhaiValidators.currency('50', max: 100), isNull);
    });
  });

  group('AlhaiValidators.quantity', () {
    test('returns null for valid quantities', () {
      expect(AlhaiValidators.quantity('5'), isNull);
      expect(AlhaiValidators.quantity('1'), isNull);
      expect(AlhaiValidators.quantity('100'), isNull);
    });

    test('returns error for zero or negative', () {
      expect(AlhaiValidators.quantity('0'), isNotNull);
      expect(AlhaiValidators.quantity('-1'), isNotNull);
    });

    test('returns error for non-integer', () {
      expect(AlhaiValidators.quantity('1.5'), isNotNull);
      expect(AlhaiValidators.quantity('abc'), isNotNull);
    });

    test('respects max constraint', () {
      expect(AlhaiValidators.quantity('200', max: 100), isNotNull);
      expect(AlhaiValidators.quantity('50', max: 100), isNull);
    });
  });

  group('AlhaiValidators.password', () {
    test('returns null for strong password', () {
      expect(AlhaiValidators.password('Abc123!@#'), isNull);
    });

    test('returns error for short password', () {
      expect(AlhaiValidators.password('Ab1!'), isNotNull);
    });

    test('returns error for missing uppercase', () {
      expect(AlhaiValidators.password('abc12345!'), isNotNull);
    });

    test('returns error for missing lowercase', () {
      expect(AlhaiValidators.password('ABC12345!'), isNotNull);
    });

    test('returns error for missing digit', () {
      expect(AlhaiValidators.password('Abcdefgh!'), isNotNull);
    });

    test('returns error for missing special char', () {
      expect(AlhaiValidators.password('Abcdefg1'), isNotNull);
    });

    test('relaxed validation with flags disabled', () {
      expect(
        AlhaiValidators.password(
          'simple',
          minLength: 4,
          requireUppercase: false,
          requireLowercase: false,
          requireDigit: false,
          requireSpecialChar: false,
        ),
        isNull,
      );
    });
  });

  group('AlhaiValidators.confirmPassword', () {
    test('returns null for matching passwords', () {
      expect(AlhaiValidators.confirmPassword('abc123', 'abc123'), isNull);
    });

    test('returns error for mismatched passwords', () {
      expect(AlhaiValidators.confirmPassword('abc123', 'xyz789'), isNotNull);
    });

    test('returns error for empty confirmation', () {
      expect(AlhaiValidators.confirmPassword(null, 'abc123'), isNotNull);
      expect(AlhaiValidators.confirmPassword('', 'abc123'), isNotNull);
    });
  });

  group('AlhaiValidators.combine', () {
    test('runs validators in order and returns first error', () {
      final validator = AlhaiValidators.combine([
        (value) => AlhaiValidators.required(value),
        (value) => AlhaiValidators.requiredWithMinLength(value, minLength: 5),
      ]);

      expect(validator(null), isNotNull); // fails at required
      expect(validator('hi'), isNotNull); // fails at minLength
      expect(validator('hello world'), isNull); // passes both
    });

    test('returns null if all validators pass', () {
      final validator = AlhaiValidators.combine([
        (value) => AlhaiValidators.required(value),
        (value) => AlhaiValidators.email(value),
      ]);

      expect(validator('user@example.com'), isNull);
    });
  });
}
