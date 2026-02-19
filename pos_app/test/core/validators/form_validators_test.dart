import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/validators/form_validators.dart';

void main() {
  // =========================================================
  // FormValidators.phone()
  // =========================================================
  group('FormValidators.phone()', () {
    test('valid Saudi mobile returns null', () {
      expect(FormValidators.phone()('0512345678'), isNull);
    });

    test('valid with +966 returns null', () {
      expect(FormValidators.phone()('+966512345678'), isNull);
    });

    test('null returns error when required', () {
      expect(FormValidators.phone()(null), isNotNull);
    });

    test('empty returns error when required', () {
      expect(FormValidators.phone()(''), isNotNull);
    });

    test('null returns null when not required', () {
      expect(FormValidators.phone(required: false)(null), isNull);
    });

    test('empty returns null when not required', () {
      expect(FormValidators.phone(required: false)(''), isNull);
    });

    test('invalid phone returns error', () {
      expect(FormValidators.phone()('123'), isNotNull);
    });

    test('locale en returns English error', () {
      final error = FormValidators.phone(locale: 'en')(null);
      expect(error, isNotNull);
    });
  });

  // =========================================================
  // FormValidators.email()
  // =========================================================
  group('FormValidators.email()', () {
    test('valid email returns null', () {
      expect(FormValidators.email()('user@example.com'), isNull);
    });

    test('null returns error when required', () {
      expect(FormValidators.email()(null), isNotNull);
    });

    test('empty returns error when required', () {
      expect(FormValidators.email()(''), isNotNull);
    });

    test('null returns null when not required', () {
      expect(FormValidators.email(required: false)(null), isNull);
    });

    test('invalid email returns error', () {
      expect(FormValidators.email()('not-an-email'), isNotNull);
    });

    test('locale en returns English error', () {
      final error = FormValidators.email(locale: 'en')(null);
      expect(error, isNotNull);
    });
  });

  // =========================================================
  // FormValidators.price()
  // =========================================================
  group('FormValidators.price()', () {
    test('valid price returns null', () {
      expect(FormValidators.price()('10.50'), isNull);
    });

    test('null returns error when required', () {
      expect(FormValidators.price()(null), isNotNull);
    });

    test('empty returns error when required', () {
      expect(FormValidators.price()(''), isNotNull);
    });

    test('null returns null when not required', () {
      expect(FormValidators.price(required: false)(null), isNull);
    });

    test('non-numeric returns error', () {
      expect(FormValidators.price()('abc'), isNotNull);
    });

    test('negative returns error', () {
      expect(FormValidators.price()('-5'), isNotNull);
    });

    test('zero allowed by default', () {
      expect(FormValidators.price()('0'), isNull);
    });

    test('zero rejected when allowZero false', () {
      expect(FormValidators.price(allowZero: false)('0'), isNotNull);
    });

    test('exceeds maxValue returns error', () {
      expect(FormValidators.price(maxValue: 100)('200'), isNotNull);
    });

    test('comma-separated thousands accepted', () {
      expect(FormValidators.price()('1,000'), isNull);
    });

    test('locale en returns English error', () {
      final error = FormValidators.price(locale: 'en')('abc');
      expect(error, isNotNull);
    });
  });

  // =========================================================
  // FormValidators.barcode()
  // =========================================================
  group('FormValidators.barcode()', () {
    test('valid barcode returns null', () {
      expect(FormValidators.barcode()('4006381333931'), isNull);
    });

    test('null returns error when required', () {
      expect(FormValidators.barcode()(null), isNotNull);
    });

    test('null returns null when not required', () {
      expect(FormValidators.barcode(required: false)(null), isNull);
    });

    test('locale en returns English error', () {
      final error = FormValidators.barcode(locale: 'en')(null);
      expect(error, isNotNull);
    });
  });

  // =========================================================
  // FormValidators.iban()
  // =========================================================
  group('FormValidators.iban()', () {
    test('valid Saudi IBAN returns null', () {
      expect(FormValidators.iban()('SA0380000000608010167519'), isNull);
    });

    test('null returns error when required', () {
      expect(FormValidators.iban()(null), isNotNull);
    });

    test('null returns null when not required', () {
      expect(FormValidators.iban(required: false)(null), isNull);
    });

    test('invalid IBAN returns error', () {
      expect(FormValidators.iban()('INVALID'), isNotNull);
    });

    test('locale en returns English error', () {
      final error = FormValidators.iban(locale: 'en')(null);
      expect(error, isNotNull);
    });
  });

  // =========================================================
  // FormValidators.quantity()
  // =========================================================
  group('FormValidators.quantity()', () {
    test('valid quantity returns null', () {
      expect(FormValidators.quantity()('5'), isNull);
    });

    test('null returns error when required', () {
      expect(FormValidators.quantity()(null), isNotNull);
    });

    test('null returns null when not required', () {
      expect(FormValidators.quantity(required: false)(null), isNull);
    });

    test('empty returns null when not required', () {
      expect(FormValidators.quantity(required: false)(''), isNull);
    });

    test('zero rejected by default', () {
      expect(FormValidators.quantity()('0'), isNotNull);
    });

    test('zero allowed when allowZero true', () {
      expect(FormValidators.quantity(allowZero: true)('0'), isNull);
    });

    test('negative returns error', () {
      expect(FormValidators.quantity()('-3'), isNotNull);
    });

    test('decimal rejected by default', () {
      expect(FormValidators.quantity()('5.5'), isNotNull);
    });

    test('decimal allowed when allowDecimal true', () {
      expect(FormValidators.quantity(allowDecimal: true)('5.5'), isNull);
    });

    test('exceeds maxValue returns error', () {
      expect(FormValidators.quantity(maxValue: 10)('20'), isNotNull);
    });

    test('non-numeric returns error', () {
      expect(FormValidators.quantity()('abc'), isNotNull);
    });

    test('locale en returns English error', () {
      final error = FormValidators.quantity(locale: 'en')('abc');
      expect(error, isNotNull);
    });
  });

  // =========================================================
  // FormValidators.discount()
  // =========================================================
  group('FormValidators.discount()', () {
    test('valid discount returns null', () {
      expect(FormValidators.discount()('50'), isNull);
    });

    test('null returns null (optional)', () {
      expect(FormValidators.discount()(null), isNull);
    });

    test('empty returns null (optional)', () {
      expect(FormValidators.discount()(''), isNull);
    });

    test('greater than 100 returns error', () {
      expect(FormValidators.discount()('101'), isNotNull);
    });

    test('negative value returns error', () {
      expect(FormValidators.discount()('-5'), isNotNull);
    });

    test('non-numeric returns error', () {
      expect(FormValidators.discount()('abc'), isNotNull);
    });

    test('boundary 0 is valid', () {
      expect(FormValidators.discount()('0'), isNull);
    });

    test('boundary 100 is valid', () {
      expect(FormValidators.discount()('100'), isNull);
    });

    test('locale en returns English error', () {
      final error = FormValidators.discount(locale: 'en')('150');
      expect(error, isNotNull);
    });
  });

  // =========================================================
  // FormValidators.requiredField()
  // =========================================================
  group('FormValidators.requiredField()', () {
    test('null returns error', () {
      expect(FormValidators.requiredField()(null), isNotNull);
    });

    test('empty string returns error', () {
      expect(FormValidators.requiredField()(''), isNotNull);
    });

    test('whitespace only returns error', () {
      expect(FormValidators.requiredField()('   '), isNotNull);
    });

    test('valid text returns null', () {
      expect(FormValidators.requiredField()('Hello World'), isNull);
    });

    test('text within maxLength returns null', () {
      expect(FormValidators.requiredField(maxLength: 10)('Short'), isNull);
    });

    test('text exceeding maxLength returns error', () {
      expect(
        FormValidators.requiredField(maxLength: 5)('This is way too long'),
        isNotNull,
      );
    });

    test('text exactly at maxLength returns null', () {
      expect(FormValidators.requiredField(maxLength: 5)('Hello'), isNull);
    });

    test('script tag returns error', () {
      expect(
        FormValidators.requiredField()('<script>alert(1)</script>'),
        isNotNull,
      );
    });

    test('javascript protocol returns error', () {
      expect(
        FormValidators.requiredField()('javascript:alert(1)'),
        isNotNull,
      );
    });

    test('onerror attribute returns error', () {
      expect(
        FormValidators.requiredField()('onerror=alert(1)'),
        isNotNull,
      );
    });

    test('custom fieldName in English error', () {
      final error = FormValidators.requiredField(
        locale: 'en',
        fieldName: 'Product name',
      )(null);
      expect(error, contains('Product name'));
    });

    test('locale en returns English error for empty', () {
      final error = FormValidators.requiredField(locale: 'en')('');
      expect(error, isNotNull);
      expect(error!.toLowerCase(), contains('required'));
    });

    test('locale en returns English error for maxLength', () {
      final error =
          FormValidators.requiredField(locale: 'en', maxLength: 3)('Long text');
      expect(error, isNotNull);
      expect(error!.toLowerCase(), contains('maximum'));
    });
  });

  // =========================================================
  // FormValidators.name()
  // =========================================================
  group('FormValidators.name()', () {
    test('valid English name returns null', () {
      expect(FormValidators.name()('Ahmed'), isNull);
    });

    test('valid Arabic name returns null', () {
      expect(FormValidators.name()('أحمد'), isNull);
    });

    test('name with hyphen returns null', () {
      expect(FormValidators.name()('Al-Ahmed'), isNull);
    });

    test('name with dot returns null', () {
      expect(FormValidators.name()('Dr. Ahmed'), isNull);
    });

    test('null returns error when required', () {
      expect(FormValidators.name()(null), isNotNull);
    });

    test('empty string returns error when required', () {
      expect(FormValidators.name()(''), isNotNull);
    });

    test('whitespace only returns error when required', () {
      expect(FormValidators.name()('   '), isNotNull);
    });

    test('name with numbers returns error', () {
      expect(FormValidators.name()('Ahmed123'), isNotNull);
    });

    test('name with special characters returns error', () {
      expect(FormValidators.name()('Ahmed@#'), isNotNull);
    });

    test('null returns null when optional', () {
      expect(FormValidators.name(isRequired: false)(null), isNull);
    });

    test('empty returns null when optional', () {
      expect(FormValidators.name(isRequired: false)(''), isNull);
    });

    test('whitespace only returns null when optional', () {
      expect(FormValidators.name(isRequired: false)('   '), isNull);
    });

    test('invalid name still returns error when optional', () {
      expect(FormValidators.name(isRequired: false)('Ahmed123'), isNotNull);
    });

    test('name exceeding maxLength returns error', () {
      expect(
        FormValidators.name(maxLength: 5)('Ahmed Mohammed'),
        isNotNull,
      );
    });

    test('locale en returns English error for empty', () {
      final error = FormValidators.name(locale: 'en')('');
      expect(error, isNotNull);
      expect(error!.toLowerCase(), contains('name'));
    });

    test('single character name is valid', () {
      expect(FormValidators.name()('A'), isNull);
    });
  });

  // =========================================================
  // FormValidators.notes()
  // =========================================================
  group('FormValidators.notes()', () {
    test('null returns null', () {
      expect(FormValidators.notes()(null), isNull);
    });

    test('empty returns null', () {
      expect(FormValidators.notes()(''), isNull);
    });

    test('whitespace only returns null', () {
      expect(FormValidators.notes()('   '), isNull);
    });

    test('valid text returns null', () {
      expect(FormValidators.notes()('Some notes here'), isNull);
    });

    test('text exceeding maxLength returns error', () {
      expect(
        FormValidators.notes(maxLength: 10)('This is a very long note that exceeds'),
        isNotNull,
      );
    });

    test('default maxLength is 500', () {
      final longText = List.filled(501, 'a').join();
      expect(FormValidators.notes()(longText), isNotNull);
      final okText = List.filled(500, 'a').join();
      expect(FormValidators.notes()(okText), isNull);
    });

    test('script tag returns error', () {
      expect(
        FormValidators.notes()('<script>alert(1)</script>'),
        isNotNull,
      );
    });

    test('javascript protocol returns error', () {
      expect(
        FormValidators.notes()('javascript:alert(1)'),
        isNotNull,
      );
    });

    test('locale en returns English error for maxLength', () {
      final error =
          FormValidators.notes(locale: 'en', maxLength: 5)('This is long text');
      expect(error, isNotNull);
      expect(error!.toLowerCase(), contains('maximum'));
    });
  });

  // =========================================================
  // FormValidators.numeric()
  // =========================================================
  group('FormValidators.numeric()', () {
    test('valid 42 returns null', () {
      expect(FormValidators.numeric()('42'), isNull);
    });

    test('null returns error when required', () {
      expect(FormValidators.numeric()(null), isNotNull);
    });

    test('empty returns error when required', () {
      expect(FormValidators.numeric()(''), isNotNull);
    });

    test('non-numeric returns error', () {
      expect(FormValidators.numeric()('abc'), isNotNull);
    });

    test('decimal returns error', () {
      expect(FormValidators.numeric()('3.5'), isNotNull);
    });

    test('negative returns error', () {
      expect(FormValidators.numeric()('-5'), isNotNull);
    });

    test('zero with allowZero false returns error', () {
      expect(FormValidators.numeric()('0'), isNotNull);
    });

    test('zero with allowZero true returns null', () {
      expect(FormValidators.numeric(allowZero: true)('0'), isNull);
    });

    test('value within max returns null', () {
      expect(FormValidators.numeric(max: 100)('50'), isNull);
    });

    test('value exceeding max returns error', () {
      expect(FormValidators.numeric(max: 100)('150'), isNotNull);
    });

    test('value equal to max returns null', () {
      expect(FormValidators.numeric(max: 100)('100'), isNull);
    });

    test('null returns null when optional', () {
      expect(FormValidators.numeric(isRequired: false)(null), isNull);
    });

    test('empty returns null when optional', () {
      expect(FormValidators.numeric(isRequired: false)(''), isNull);
    });

    test('locale en returns English error for empty', () {
      final error = FormValidators.numeric(locale: 'en')('');
      expect(error, isNotNull);
      expect(error!.toLowerCase(), contains('number'));
    });

    test('locale en returns English error for negative', () {
      final error = FormValidators.numeric(locale: 'en')('-5');
      expect(error, isNotNull);
      expect(error!.toLowerCase(), contains('negative'));
    });

    test('locale en returns English error for exceeding max', () {
      final error = FormValidators.numeric(locale: 'en', max: 10)('50');
      expect(error, isNotNull);
      expect(error!.toLowerCase(), contains('maximum'));
    });
  });

  // =========================================================
  // FormValidators.sku()
  // =========================================================
  group('FormValidators.sku()', () {
    test('null returns null when optional', () {
      expect(FormValidators.sku()(null), isNull);
    });

    test('empty returns null when optional', () {
      expect(FormValidators.sku()(''), isNull);
    });

    test('valid SKU ABC-123 returns null', () {
      expect(FormValidators.sku()('ABC-123'), isNull);
    });

    test('valid SKU with underscore returns null', () {
      expect(FormValidators.sku()('ABC_123'), isNull);
    });

    test('SKU with spaces returns error', () {
      expect(FormValidators.sku()('ABC 123'), isNotNull);
    });

    test('SKU with special chars returns error', () {
      expect(FormValidators.sku()('ABC@123'), isNotNull);
    });

    test('SKU with dots returns error', () {
      expect(FormValidators.sku()('ABC.123'), isNotNull);
    });

    test('null returns error when required', () {
      expect(FormValidators.sku(isRequired: true)(null), isNotNull);
    });

    test('empty returns error when required', () {
      expect(FormValidators.sku(isRequired: true)(''), isNotNull);
    });

    test('SKU exceeding maxLength returns error', () {
      expect(
        FormValidators.sku(maxLength: 5)('ABCDEF-123456'),
        isNotNull,
      );
    });

    test('locale en returns English error for required', () {
      final error = FormValidators.sku(locale: 'en', isRequired: true)('');
      expect(error, isNotNull);
      expect(error!.toLowerCase(), contains('sku'));
    });

    test('locale en returns English error for invalid chars', () {
      final error = FormValidators.sku(locale: 'en')('ABC@123');
      expect(error, isNotNull);
      expect(error!.toLowerCase(), contains('letters'));
    });
  });

  // =========================================================
  // FormValidators.vatNumber()
  // =========================================================
  group('FormValidators.vatNumber()', () {
    test('null returns null when optional', () {
      expect(FormValidators.vatNumber()(null), isNull);
    });

    test('empty returns null when optional', () {
      expect(FormValidators.vatNumber()(''), isNull);
    });

    test('valid 15-digit starting with 3 returns null', () {
      expect(FormValidators.vatNumber()('300000000000003'), isNull);
    });

    test('too short returns error', () {
      expect(FormValidators.vatNumber()('3000000'), isNotNull);
    });

    test('too long returns error', () {
      expect(FormValidators.vatNumber()('3000000000000000'), isNotNull);
    });

    test('does not start with 3 returns error', () {
      expect(FormValidators.vatNumber()('100000000000003'), isNotNull);
    });

    test('non-digits returns error', () {
      expect(FormValidators.vatNumber()('3000000abc00003'), isNotNull);
    });

    test('null returns error when required', () {
      expect(FormValidators.vatNumber(isRequired: true)(null), isNotNull);
    });

    test('empty returns error when required', () {
      expect(FormValidators.vatNumber(isRequired: true)(''), isNotNull);
    });

    test('locale en English error for required', () {
      final error =
          FormValidators.vatNumber(locale: 'en', isRequired: true)('');
      expect(error, isNotNull);
      expect(error!.toLowerCase(), contains('vat'));
    });

    test('locale en English error for wrong length', () {
      final error = FormValidators.vatNumber(locale: 'en')('300');
      expect(error, isNotNull);
      expect(error!.toLowerCase(), contains('15 digits'));
    });

    test('locale en error for not starting with 3', () {
      final error = FormValidators.vatNumber(locale: 'en')('100000000000003');
      expect(error, isNotNull);
      expect(error!.toLowerCase(), contains('start with 3'));
    });

    test('exactly 15 digits starting with 3 is valid', () {
      expect(FormValidators.vatNumber()('312345678901234'), isNull);
    });
  });

  // =========================================================
  // FormValidators.crNumber()
  // =========================================================
  group('FormValidators.crNumber()', () {
    test('null returns null when optional', () {
      expect(FormValidators.crNumber()(null), isNull);
    });

    test('empty returns null when optional', () {
      expect(FormValidators.crNumber()(''), isNull);
    });

    test('valid 10-digit returns null', () {
      expect(FormValidators.crNumber()('1010000000'), isNull);
    });

    test('too short returns error', () {
      expect(FormValidators.crNumber()('10100'), isNotNull);
    });

    test('too long returns error', () {
      expect(FormValidators.crNumber()('10100000001'), isNotNull);
    });

    test('non-digits returns error', () {
      expect(FormValidators.crNumber()('10100abc00'), isNotNull);
    });

    test('letters only returns error', () {
      expect(FormValidators.crNumber()('ABCDEFGHIJ'), isNotNull);
    });

    test('null returns error when required', () {
      expect(FormValidators.crNumber(isRequired: true)(null), isNotNull);
    });

    test('empty returns error when required', () {
      expect(FormValidators.crNumber(isRequired: true)(''), isNotNull);
    });

    test('locale en English error for required', () {
      final error =
          FormValidators.crNumber(locale: 'en', isRequired: true)('');
      expect(error, isNotNull);
      expect(error!.toLowerCase(), contains('cr'));
    });

    test('locale en English error for wrong length', () {
      final error = FormValidators.crNumber(locale: 'en')('101');
      expect(error, isNotNull);
      expect(error!.toLowerCase(), contains('10 digits'));
    });

    test('exactly 10 digits is valid', () {
      expect(FormValidators.crNumber()('1234567890'), isNull);
    });
  });

  // =========================================================
  // Return type verification
  // =========================================================
  group('Return type verification', () {
    test('all validators return String? Function(String?)', () {
      expect(FormValidators.phone(), isA<String? Function(String?)>());
      expect(FormValidators.email(), isA<String? Function(String?)>());
      expect(FormValidators.price(), isA<String? Function(String?)>());
      expect(FormValidators.barcode(), isA<String? Function(String?)>());
      expect(FormValidators.iban(), isA<String? Function(String?)>());
      expect(FormValidators.quantity(), isA<String? Function(String?)>());
      expect(FormValidators.discount(), isA<String? Function(String?)>());
      expect(FormValidators.requiredField(), isA<String? Function(String?)>());
      expect(FormValidators.name(), isA<String? Function(String?)>());
      expect(FormValidators.notes(), isA<String? Function(String?)>());
      expect(FormValidators.numeric(), isA<String? Function(String?)>());
      expect(FormValidators.sku(), isA<String? Function(String?)>());
      expect(FormValidators.vatNumber(), isA<String? Function(String?)>());
      expect(FormValidators.crNumber(), isA<String? Function(String?)>());
    });
  });

  // =========================================================
  // Edge cases
  // =========================================================
  group('Edge cases', () {
    test('phone: valid with leading/trailing spaces', () {
      expect(FormValidators.phone()(' 0512345678 '), isNull);
    });

    test('price: comma-separated thousands accepted', () {
      expect(FormValidators.price()('1,000'), isNull);
    });

    test('name: single character name is valid', () {
      expect(FormValidators.name()('A'), isNull);
    });

    test('numeric: very large number within max', () {
      expect(FormValidators.numeric(max: 999999)('999999'), isNull);
    });

    test('numeric: zero with allowZero true and max set', () {
      expect(FormValidators.numeric(allowZero: true, max: 100)('0'), isNull);
    });

    test('discount: boundary value 100.01 is invalid', () {
      expect(FormValidators.discount()('100.01'), isNotNull);
    });

    test('sku: empty whitespace when optional returns null', () {
      expect(FormValidators.sku()('   '), isNull);
    });
  });
}
