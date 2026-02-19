import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/validators/price_validator.dart';

void main() {
  group('PriceValidator.validate', () {
    test('accepts valid prices', () {
      expect(PriceValidator.validate('10.5').isValid, isTrue);
      expect(PriceValidator.validate('100').isValid, isTrue);
      expect(PriceValidator.validate('0.99').isValid, isTrue);
      expect(PriceValidator.validate('999999').isValid, isTrue);
      expect(PriceValidator.validate('1000000').isValid, isTrue);
    });

    test('rejects negative prices', () {
      final result = PriceValidator.validate('-5');
      expect(result.isValid, isFalse);
      expect(result.errorCode, equals('PRICE_NEGATIVE'));
      expect(result.getError('en'), contains('negative'));
    });

    test('allows zero by default', () {
      expect(PriceValidator.validate('0').isValid, isTrue);
    });

    test('rejects zero when allowZero is false', () {
      final result = PriceValidator.validate('0', allowZero: false);
      expect(result.isValid, isFalse);
      expect(result.errorCode, equals('PRICE_ZERO'));
      expect(result.getError('en'), contains('greater than zero'));
    });

    test('rejects price exceeding default max (1M)', () {
      final result = PriceValidator.validate('1000001');
      expect(result.isValid, isFalse);
      expect(result.errorCode, equals('PRICE_TOO_HIGH'));
    });

    test('rejects price exceeding custom max', () {
      final result = PriceValidator.validate('500', maxValue: 100);
      expect(result.isValid, isFalse);
      expect(result.errorCode, equals('PRICE_TOO_HIGH'));
    });

    test('rejects price below custom min', () {
      final result = PriceValidator.validate('5', minValue: 10);
      expect(result.isValid, isFalse);
      expect(result.errorCode, equals('PRICE_TOO_LOW'));
    });

    test('rejects too many decimal places', () {
      final result = PriceValidator.validate('10.999');
      expect(result.isValid, isFalse);
      expect(result.errorCode, equals('PRICE_TOO_MANY_DECIMALS'));
    });

    test('accepts exactly 2 decimal places', () {
      expect(PriceValidator.validate('10.99').isValid, isTrue);
      expect(PriceValidator.validate('10.9').isValid, isTrue);
    });

    test('rejects null input', () {
      final result = PriceValidator.validate(null);
      expect(result.isValid, isFalse);
      expect(result.errorCode, equals('PRICE_REQUIRED'));
    });

    test('rejects empty string', () {
      final result = PriceValidator.validate('');
      expect(result.isValid, isFalse);
      expect(result.errorCode, equals('PRICE_REQUIRED'));
    });

    test('rejects non-numeric string', () {
      final result = PriceValidator.validate('abc');
      expect(result.isValid, isFalse);
      expect(result.errorCode, equals('PRICE_INVALID_FORMAT'));
    });

    test('accepts price with comma thousands separator', () {
      expect(PriceValidator.validate('1,000.50').isValid, isTrue);
    });

    test('boundary: exactly at max price is valid', () {
      expect(PriceValidator.validate('1000000').isValid, isTrue);
    });

    test('boundary: exactly at custom max is valid', () {
      expect(PriceValidator.validate('100', maxValue: 100).isValid, isTrue);
    });

    test('Arabic error message for negative', () {
      final result = PriceValidator.validate('-5');
      expect(result.getError('ar'), contains('سالب'));
    });

    test('English error message for negative', () {
      final result = PriceValidator.validate('-5');
      expect(result.getError('en'), contains('negative'));
    });

    test('handles price with leading zeros', () {
      expect(PriceValidator.validate('007.50').isValid, isTrue);
    });

    test('handles price with only decimal part', () {
      expect(PriceValidator.validate('.50').isValid, isTrue);
    });
  });

  group('PriceValidator.validateQuantity', () {
    test('accepts valid integer quantity', () {
      expect(PriceValidator.validateQuantity('5').isValid, isTrue);
    });

    test('rejects zero by default', () {
      final result = PriceValidator.validateQuantity('0');
      expect(result.isValid, isFalse);
      expect(result.errorCode, equals('QUANTITY_ZERO'));
    });

    test('allows zero when allowZero is true', () {
      expect(
        PriceValidator.validateQuantity('0', allowZero: true).isValid,
        isTrue,
      );
    });

    test('rejects negative quantity', () {
      final result = PriceValidator.validateQuantity('-3');
      expect(result.isValid, isFalse);
      expect(result.errorCode, equals('QUANTITY_NEGATIVE'));
    });

    test('rejects quantity exceeding max', () {
      final result = PriceValidator.validateQuantity('200', maxValue: 100);
      expect(result.isValid, isFalse);
      expect(result.errorCode, equals('QUANTITY_TOO_HIGH'));
    });

    test('rejects null input', () {
      expect(PriceValidator.validateQuantity(null).isValid, isFalse);
    });

    test('rejects empty string', () {
      expect(PriceValidator.validateQuantity('').isValid, isFalse);
    });

    test('rejects decimal when allowDecimal is false', () {
      final result = PriceValidator.validateQuantity('5.5');
      expect(result.isValid, isFalse);
      expect(result.errorCode, equals('QUANTITY_INVALID'));
    });

    test('accepts decimal when allowDecimal is true', () {
      expect(
        PriceValidator.validateQuantity('5.5', allowDecimal: true).isValid,
        isTrue,
      );
    });

    test('rejects non-numeric string', () {
      expect(PriceValidator.validateQuantity('abc').isValid, isFalse);
    });
  });

  group('PriceValidator.validateDiscount', () {
    test('accepts valid discount percentages', () {
      expect(PriceValidator.validateDiscount('0').isValid, isTrue);
      expect(PriceValidator.validateDiscount('50').isValid, isTrue);
      expect(PriceValidator.validateDiscount('100').isValid, isTrue);
      expect(PriceValidator.validateDiscount('10.5').isValid, isTrue);
    });

    test('rejects discount greater than 100', () {
      final result = PriceValidator.validateDiscount('101');
      expect(result.isValid, isFalse);
      expect(result.errorCode, equals('DISCOUNT_OUT_OF_RANGE'));
    });

    test('rejects negative discount', () {
      final result = PriceValidator.validateDiscount('-5');
      expect(result.isValid, isFalse);
      expect(result.errorCode, equals('DISCOUNT_OUT_OF_RANGE'));
    });

    test('null is valid because discount is optional', () {
      expect(PriceValidator.validateDiscount(null).isValid, isTrue);
    });

    test('empty string is valid because discount is optional', () {
      expect(PriceValidator.validateDiscount('').isValid, isTrue);
    });

    test('rejects non-numeric string', () {
      final result = PriceValidator.validateDiscount('abc');
      expect(result.isValid, isFalse);
      expect(result.errorCode, equals('DISCOUNT_INVALID'));
    });
  });

  group('PriceValidator.format', () {
    test('formats price with default currency', () {
      final formatted = PriceValidator.format(1234.5);
      expect(formatted, contains('1,234.50'));
    });

    test('formats without currency when showCurrency is false', () {
      final formatted = PriceValidator.format(1234.5, showCurrency: false);
      expect(formatted, equals('1,234.50'));
    });

    test('formats with custom currency', () {
      final formatted = PriceValidator.format(100, currency: 'SAR');
      expect(formatted, contains('SAR'));
      expect(formatted, contains('100.00'));
    });

    test('formats with thousands separator', () {
      expect(
        PriceValidator.format(1000000, showCurrency: false),
        equals('1,000,000.00'),
      );
    });

    test('formats small price correctly', () {
      expect(PriceValidator.format(0.99, showCurrency: false), equals('0.99'));
    });

    test('formats zero correctly', () {
      expect(PriceValidator.format(0, showCurrency: false), equals('0.00'));
    });

    test('always shows 2 decimal places', () {
      expect(PriceValidator.format(10, showCurrency: false), equals('10.00'));
    });
  });

  group('PriceValidator.parse', () {
    test('parses simple numeric string', () {
      expect(PriceValidator.parse('10.5'), equals(10.5));
      expect(PriceValidator.parse('100'), equals(100.0));
    });

    test('parses string with commas', () {
      expect(PriceValidator.parse('1,000.50'), equals(1000.50));
      expect(PriceValidator.parse('1,000,000'), equals(1000000.0));
    });

    test('parses string with spaces', () {
      expect(PriceValidator.parse('1 000'), equals(1000.0));
    });

    test('returns null for null input', () {
      expect(PriceValidator.parse(null), isNull);
    });

    test('returns null for empty string', () {
      expect(PriceValidator.parse(''), isNull);
    });

    test('returns null for non-numeric string', () {
      expect(PriceValidator.parse('abc'), isNull);
    });
  });

  group('PriceValidator.formValidator', () {
    test('returns null for valid price in ar locale', () {
      final validator = PriceValidator.formValidator(locale: 'ar');
      expect(validator('10.5'), isNull);
    });

    test('returns error for invalid price in ar locale', () {
      final validator = PriceValidator.formValidator(locale: 'ar');
      expect(validator('abc'), isNotNull);
    });

    test('returns English error for invalid price in en locale', () {
      final validator = PriceValidator.formValidator(locale: 'en');
      final error = validator('abc');
      expect(error, isNotNull);
      expect(error!.toLowerCase(), contains('price'));
    });

    test('returns null for empty when not required', () {
      final validator = PriceValidator.formValidator(
        locale: 'en',
        required: false,
      );
      expect(validator(null), isNull);
      expect(validator(''), isNull);
    });

    test('returns error for empty when required', () {
      final validator = PriceValidator.formValidator(
        locale: 'en',
        required: true,
      );
      expect(validator(null), isNotNull);
      expect(validator(''), isNotNull);
    });

    test('respects allowZero parameter', () {
      final validator = PriceValidator.formValidator(
        locale: 'en',
        allowZero: false,
      );
      expect(validator('0'), isNotNull);
    });

    test('respects maxValue parameter', () {
      final validator = PriceValidator.formValidator(
        locale: 'en',
        maxValue: 100,
      );
      expect(validator('200'), isNotNull);
    });

    test('respects minValue parameter', () {
      final validator = PriceValidator.formValidator(
        locale: 'en',
        minValue: 10,
      );
      expect(validator('5'), isNotNull);
    });
  });

  group('PriceValidator constants', () {
    test('maxDecimalPlaces is 2', () {
      expect(PriceValidator.maxDecimalPlaces, equals(2));
    });

    test('maxPrice is 1 million', () {
      expect(PriceValidator.maxPrice, equals(1000000.0));
    });

    test('minPrice is 0', () {
      expect(PriceValidator.minPrice, equals(0.0));
    });
  });

  group('PriceValidator edge cases', () {
    test('handles price at boundary 999999.99', () {
      expect(PriceValidator.validate('999999.99').isValid, isTrue);
    });

    test('handles price with leading zeros', () {
      expect(PriceValidator.validate('007.50').isValid, isTrue);
    });

    test('handles price with only decimal part', () {
      expect(PriceValidator.validate('.50').isValid, isTrue);
    });
  });
}
