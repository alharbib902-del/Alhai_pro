import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/src/core/validators/price_validator.dart';

void main() {
  group('PriceValidator', () {
    group('validate', () {
      test('should reject null', () {
        final result = PriceValidator.validate(null);
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'PRICE_REQUIRED');
      });

      test('should reject empty string', () {
        final result = PriceValidator.validate('');
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'PRICE_REQUIRED');
      });

      test('should accept valid price', () {
        final result = PriceValidator.validate('99.99');
        expect(result.isValid, isTrue);
      });

      test('should accept zero when allowZero is true', () {
        final result = PriceValidator.validate('0', allowZero: true);
        expect(result.isValid, isTrue);
      });

      test('should reject zero when allowZero is false', () {
        final result = PriceValidator.validate('0', allowZero: false);
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'PRICE_ZERO');
      });

      test('should reject negative price', () {
        final result = PriceValidator.validate('-10');
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'PRICE_NEGATIVE');
      });

      test('should reject non-numeric input', () {
        final result = PriceValidator.validate('abc');
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'PRICE_INVALID_FORMAT');
      });

      test('should accept price with thousands separator', () {
        final result = PriceValidator.validate('1,234.56');
        expect(result.isValid, isTrue);
      });

      test('should reject price exceeding max (default 1M)', () {
        final result = PriceValidator.validate('1000001');
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'PRICE_TOO_HIGH');
      });

      test('should accept price at max boundary', () {
        final result = PriceValidator.validate('1000000');
        expect(result.isValid, isTrue);
      });

      test('should reject price below custom min', () {
        final result = PriceValidator.validate('5', minValue: 10);
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'PRICE_TOO_LOW');
      });

      test('should accept price at custom min', () {
        final result = PriceValidator.validate('10', minValue: 10);
        expect(result.isValid, isTrue);
      });

      test('should reject price above custom max', () {
        final result = PriceValidator.validate('200', maxValue: 100);
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'PRICE_TOO_HIGH');
      });

      test('should reject more than 2 decimal places', () {
        final result = PriceValidator.validate('10.999');
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'PRICE_TOO_MANY_DECIMALS');
      });

      test('should accept exactly 2 decimal places', () {
        final result = PriceValidator.validate('10.99');
        expect(result.isValid, isTrue);
      });

      test('should accept 1 decimal place', () {
        final result = PriceValidator.validate('10.5');
        expect(result.isValid, isTrue);
      });

      test('should accept integer price', () {
        final result = PriceValidator.validate('100');
        expect(result.isValid, isTrue);
      });
    });

    group('validateQuantity', () {
      test('should reject null', () {
        final result = PriceValidator.validateQuantity(null);
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'QUANTITY_REQUIRED');
      });

      test('should reject empty', () {
        final result = PriceValidator.validateQuantity('');
        expect(result.isValid, isFalse);
      });

      test('should accept valid integer quantity', () {
        final result = PriceValidator.validateQuantity('5');
        expect(result.isValid, isTrue);
      });

      test('should reject zero by default', () {
        final result = PriceValidator.validateQuantity('0');
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'QUANTITY_ZERO');
      });

      test('should accept zero when allowZero is true', () {
        final result = PriceValidator.validateQuantity('0', allowZero: true);
        expect(result.isValid, isTrue);
      });

      test('should reject negative quantity', () {
        final result = PriceValidator.validateQuantity('-1');
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'QUANTITY_NEGATIVE');
      });

      test('should reject decimal when allowDecimal is false', () {
        final result = PriceValidator.validateQuantity('1.5');
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'QUANTITY_INVALID');
      });

      test('should accept decimal when allowDecimal is true', () {
        final result =
            PriceValidator.validateQuantity('1.5', allowDecimal: true);
        expect(result.isValid, isTrue);
      });

      test('should reject quantity above max', () {
        final result = PriceValidator.validateQuantity('200', maxValue: 100);
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'QUANTITY_TOO_HIGH');
      });

      test('should accept quantity at max boundary', () {
        final result = PriceValidator.validateQuantity('100', maxValue: 100);
        expect(result.isValid, isTrue);
      });
    });

    group('validateDiscount', () {
      test('should accept null (discount is optional)', () {
        final result = PriceValidator.validateDiscount(null);
        expect(result.isValid, isTrue);
      });

      test('should accept empty (discount is optional)', () {
        final result = PriceValidator.validateDiscount('');
        expect(result.isValid, isTrue);
      });

      test('should accept 0%', () {
        final result = PriceValidator.validateDiscount('0');
        expect(result.isValid, isTrue);
      });

      test('should accept 50%', () {
        final result = PriceValidator.validateDiscount('50');
        expect(result.isValid, isTrue);
      });

      test('should accept 100%', () {
        final result = PriceValidator.validateDiscount('100');
        expect(result.isValid, isTrue);
      });

      test('should reject negative discount', () {
        final result = PriceValidator.validateDiscount('-5');
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'DISCOUNT_OUT_OF_RANGE');
      });

      test('should reject discount > 100', () {
        final result = PriceValidator.validateDiscount('101');
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'DISCOUNT_OUT_OF_RANGE');
      });

      test('should reject non-numeric discount', () {
        final result = PriceValidator.validateDiscount('abc');
        expect(result.isValid, isFalse);
        expect(result.errorCode, 'DISCOUNT_INVALID');
      });
    });

    group('format', () {
      test('should format with 2 decimal places', () {
        final formatted = PriceValidator.format(1234.5);
        expect(formatted, contains('1,234.50'));
      });

      test('should include currency by default', () {
        final formatted = PriceValidator.format(100.0);
        expect(formatted, contains('ريال'));
      });

      test('should hide currency when showCurrency is false', () {
        final formatted = PriceValidator.format(100.0, showCurrency: false);
        expect(formatted, isNot(contains('ريال')));
      });

      test('should use custom currency', () {
        final formatted = PriceValidator.format(100.0, currency: 'درهم');
        expect(formatted, contains('درهم'));
      });

      test('should format zero', () {
        final formatted = PriceValidator.format(0.0);
        expect(formatted, contains('0.00'));
      });

      test('should add thousands separator', () {
        final formatted = PriceValidator.format(1000000.0, showCurrency: false);
        expect(formatted, '1,000,000.00');
      });
    });

    group('parse', () {
      test('should parse valid price string', () {
        expect(PriceValidator.parse('99.99'), 99.99);
      });

      test('should parse price with commas', () {
        expect(PriceValidator.parse('1,234.56'), 1234.56);
      });

      test('should return null for null input', () {
        expect(PriceValidator.parse(null), isNull);
      });

      test('should return null for empty input', () {
        expect(PriceValidator.parse(''), isNull);
      });

      test('should return null for non-numeric', () {
        expect(PriceValidator.parse('abc'), isNull);
      });

      test('should handle spaces', () {
        expect(PriceValidator.parse('1 234'), 1234.0);
      });
    });

    group('formValidator', () {
      test('should return null for valid price', () {
        final validator = PriceValidator.formValidator();
        expect(validator('99.99'), isNull);
      });

      test('should return error for invalid price', () {
        final validator = PriceValidator.formValidator();
        expect(validator('abc'), isNotNull);
      });

      test('should allow empty when not required', () {
        final validator = PriceValidator.formValidator(required: false);
        expect(validator(null), isNull);
        expect(validator(''), isNull);
      });
    });
  });
}
