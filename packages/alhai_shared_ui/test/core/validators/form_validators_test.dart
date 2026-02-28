import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/src/core/validators/form_validators.dart';

void main() {
  group('FormValidators', () {
    group('phone', () {
      test('should return null for valid phone', () {
        final validator = FormValidators.phone();
        expect(validator('0512345678'), isNull);
      });

      test('should return error for invalid phone', () {
        final validator = FormValidators.phone();
        expect(validator('123'), isNotNull);
      });

      test('should allow empty when not required', () {
        final validator = FormValidators.phone(required: false);
        expect(validator(''), isNull);
      });
    });

    group('email', () {
      test('should return null for valid email', () {
        final validator = FormValidators.email();
        expect(validator('user@example.com'), isNull);
      });

      test('should return error for invalid email', () {
        final validator = FormValidators.email();
        expect(validator('invalid'), isNotNull);
      });
    });

    group('price', () {
      test('should return null for valid price', () {
        final validator = FormValidators.price();
        expect(validator('99.99'), isNull);
      });

      test('should return error for invalid price', () {
        final validator = FormValidators.price();
        expect(validator('abc'), isNotNull);
      });

      test('should reject zero when allowZero is false', () {
        final validator = FormValidators.price(allowZero: false);
        expect(validator('0'), isNotNull);
      });
    });

    group('barcode', () {
      test('should return null for valid barcode', () {
        final validator = FormValidators.barcode();
        expect(validator('ABC123'), isNull);
      });

      test('should return error for empty when required', () {
        final validator = FormValidators.barcode(required: true);
        expect(validator(''), isNotNull);
      });
    });

    group('iban', () {
      test('should return null for valid IBAN', () {
        final validator = FormValidators.iban();
        expect(validator('SA0380000000608010167519'), isNull);
      });

      test('should return error for invalid IBAN', () {
        final validator = FormValidators.iban();
        expect(validator('INVALID'), isNotNull);
      });
    });

    group('quantity', () {
      test('should return null for valid quantity', () {
        final validator = FormValidators.quantity();
        expect(validator('5'), isNull);
      });

      test('should reject zero by default', () {
        final validator = FormValidators.quantity();
        expect(validator('0'), isNotNull);
      });

      test('should accept zero when allowed', () {
        final validator = FormValidators.quantity(allowZero: true);
        expect(validator('0'), isNull);
      });

      test('should reject decimal by default', () {
        final validator = FormValidators.quantity();
        expect(validator('1.5'), isNotNull);
      });

      test('should accept decimal when allowed', () {
        final validator = FormValidators.quantity(allowDecimal: true);
        expect(validator('1.5'), isNull);
      });

      test('should allow empty when not required', () {
        final validator = FormValidators.quantity(required: false);
        expect(validator(''), isNull);
      });
    });

    group('discount', () {
      test('should return null for empty (optional)', () {
        final validator = FormValidators.discount();
        expect(validator(''), isNull);
        expect(validator(null), isNull);
      });

      test('should return null for valid discount', () {
        final validator = FormValidators.discount();
        expect(validator('25'), isNull);
      });

      test('should return error for > 100', () {
        final validator = FormValidators.discount();
        expect(validator('150'), isNotNull);
      });
    });

    group('requiredField', () {
      test('should reject null', () {
        final validator = FormValidators.requiredField();
        expect(validator(null), isNotNull);
      });

      test('should reject empty string', () {
        final validator = FormValidators.requiredField();
        expect(validator(''), isNotNull);
      });

      test('should reject whitespace-only string', () {
        final validator = FormValidators.requiredField();
        expect(validator('   '), isNotNull);
      });

      test('should accept valid text', () {
        final validator = FormValidators.requiredField();
        expect(validator('Hello'), isNull);
      });

      test('should reject text exceeding maxLength', () {
        final validator = FormValidators.requiredField(maxLength: 5);
        expect(validator('123456'), isNotNull);
      });

      test('should reject dangerous content', () {
        final validator = FormValidators.requiredField();
        expect(validator('<script>alert(1)</script>'), isNotNull);
      });

      test('should use custom field name in error message (Arabic)', () {
        final validator =
            FormValidators.requiredField(fieldName: 'الاسم', locale: 'ar');
        final error = validator('');
        expect(error, contains('الاسم'));
      });

      test('should use custom field name in error message (English)', () {
        final validator =
            FormValidators.requiredField(fieldName: 'Name', locale: 'en');
        final error = validator('');
        expect(error, contains('Name'));
      });
    });

    group('name', () {
      test('should accept Arabic name', () {
        final validator = FormValidators.name();
        expect(validator('محمد أحمد'), isNull);
      });

      test('should accept English name', () {
        final validator = FormValidators.name();
        expect(validator('John Doe'), isNull);
      });

      test('should accept name with hyphen', () {
        final validator = FormValidators.name();
        expect(validator('Al-Ali'), isNull);
      });

      test('should accept name with dot', () {
        final validator = FormValidators.name();
        expect(validator('Dr. Smith'), isNull);
      });

      test('should reject name with numbers', () {
        final validator = FormValidators.name();
        expect(validator('John123'), isNotNull);
      });

      test('should reject name with special characters', () {
        final validator = FormValidators.name();
        expect(validator('John@#\$'), isNotNull);
      });

      test('should reject when required and empty', () {
        final validator = FormValidators.name(isRequired: true);
        expect(validator(''), isNotNull);
      });

      test('should allow empty when not required', () {
        final validator = FormValidators.name(isRequired: false);
        expect(validator(''), isNull);
      });

      test('should reject exceeding maxLength', () {
        final validator = FormValidators.name(maxLength: 5);
        expect(validator('John Doe'), isNotNull);
      });

      test('should reject dangerous content', () {
        final validator = FormValidators.name();
        expect(validator('<script>'), isNotNull);
      });
    });

    group('notes', () {
      test('should accept null (optional)', () {
        final validator = FormValidators.notes();
        expect(validator(null), isNull);
      });

      test('should accept empty (optional)', () {
        final validator = FormValidators.notes();
        expect(validator(''), isNull);
      });

      test('should accept valid text', () {
        final validator = FormValidators.notes();
        expect(validator('Some notes here'), isNull);
      });

      test('should reject exceeding maxLength', () {
        final validator = FormValidators.notes(maxLength: 10);
        expect(validator('A very long note text'), isNotNull);
      });

      test('should reject dangerous content', () {
        final validator = FormValidators.notes();
        expect(validator('<script>alert(1)</script>'), isNotNull);
      });
    });

    group('numeric', () {
      test('should accept valid integer', () {
        final validator = FormValidators.numeric();
        expect(validator('42'), isNull);
      });

      test('should reject non-integer', () {
        final validator = FormValidators.numeric();
        expect(validator('abc'), isNotNull);
      });

      test('should reject negative', () {
        final validator = FormValidators.numeric();
        expect(validator('-1'), isNotNull);
      });

      test('should reject zero by default', () {
        final validator = FormValidators.numeric();
        expect(validator('0'), isNotNull);
      });

      test('should accept zero when allowed', () {
        final validator = FormValidators.numeric(allowZero: true);
        expect(validator('0'), isNull);
      });

      test('should reject above max', () {
        final validator = FormValidators.numeric(max: 10);
        expect(validator('15'), isNotNull);
      });

      test('should allow empty when not required', () {
        final validator = FormValidators.numeric(isRequired: false);
        expect(validator(''), isNull);
      });
    });

    group('sku', () {
      test('should accept valid SKU', () {
        final validator = FormValidators.sku();
        expect(validator('SKU-001'), isNull);
      });

      test('should accept SKU with underscores', () {
        final validator = FormValidators.sku();
        expect(validator('SKU_001'), isNull);
      });

      test('should reject SKU with spaces', () {
        final validator = FormValidators.sku();
        expect(validator('SKU 001'), isNotNull);
      });

      test('should reject SKU with special chars', () {
        final validator = FormValidators.sku();
        expect(validator('SKU@001'), isNotNull);
      });

      test('should allow empty when not required', () {
        final validator = FormValidators.sku(isRequired: false);
        expect(validator(''), isNull);
      });

      test('should reject empty when required', () {
        final validator = FormValidators.sku(isRequired: true);
        expect(validator(''), isNotNull);
      });

      test('should reject exceeding maxLength', () {
        final validator = FormValidators.sku(maxLength: 5);
        expect(validator('SKU-001-LONG'), isNotNull);
      });
    });

    group('vatNumber', () {
      test('should accept valid VAT number (15 digits starting with 3)', () {
        final validator = FormValidators.vatNumber();
        expect(validator('300000000000003'), isNull);
      });

      test('should reject VAT not starting with 3', () {
        final validator = FormValidators.vatNumber();
        expect(validator('100000000000003'), isNotNull);
      });

      test('should reject wrong length', () {
        final validator = FormValidators.vatNumber();
        expect(validator('3000000'), isNotNull);
      });

      test('should allow empty when not required', () {
        final validator = FormValidators.vatNumber(isRequired: false);
        expect(validator(''), isNull);
      });

      test('should reject empty when required', () {
        final validator = FormValidators.vatNumber(isRequired: true);
        expect(validator(''), isNotNull);
      });
    });

    group('crNumber', () {
      test('should accept valid CR number (10 digits)', () {
        final validator = FormValidators.crNumber();
        expect(validator('1234567890'), isNull);
      });

      test('should reject wrong length', () {
        final validator = FormValidators.crNumber();
        expect(validator('12345'), isNotNull);
      });

      test('should reject non-numeric', () {
        final validator = FormValidators.crNumber();
        expect(validator('123456789A'), isNotNull);
      });

      test('should allow empty when not required', () {
        final validator = FormValidators.crNumber(isRequired: false);
        expect(validator(''), isNull);
      });
    });
  });
}
