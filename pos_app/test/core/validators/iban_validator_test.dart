import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/validators/iban_validator.dart';

void main() {
  // Valid Saudi IBAN for Al Rajhi bank (bank code 80) that passes MOD97
  const validIban = 'SA0380000000608010167519';

  group('IbanValidator.validate()', () {
    test('accepts valid Saudi IBAN', () {
      expect(IbanValidator.validate(validIban).isValid, isTrue);
    });
    test('accepts IBAN with spaces', () {
      expect(IbanValidator.validate('SA03 8000 0000 6080 1016 7519').isValid, isTrue);
    });
    test('accepts lowercase IBAN', () {
      expect(IbanValidator.validate(validIban.toLowerCase()).isValid, isTrue);
    });
    test('rejects null', () {
      final r = IbanValidator.validate(null);
      expect(r.isValid, isFalse);
      expect(r.errorCode, equals('IBAN_REQUIRED'));
    });
    test('rejects empty', () {
      final r = IbanValidator.validate('');
      expect(r.isValid, isFalse);
      expect(r.errorCode, equals('IBAN_REQUIRED'));
    });
    test('rejects wrong country code', () {
      final r = IbanValidator.validate('GB0380000000608010167519');
      expect(r.isValid, isFalse);
      expect(r.errorCode, equals('IBAN_INVALID_COUNTRY'));
    });
    test('rejects wrong length (too short)', () {
      final r = IbanValidator.validate('SA038000000060801016');
      expect(r.isValid, isFalse);
      expect(r.errorCode, equals('IBAN_INVALID_LENGTH'));
    });
    test('rejects wrong length (too long)', () {
      final r = IbanValidator.validate('SA03800000006080101675190');
      expect(r.isValid, isFalse);
      expect(r.errorCode, equals('IBAN_INVALID_LENGTH'));
    });
    test('rejects invalid checksum', () {
      final r = IbanValidator.validate('SA0380000000608010167510');
      expect(r.isValid, isFalse);
      expect(r.errorCode, equals('IBAN_INVALID_CHECKSUM'));
    });
  });

  group('IbanValidator.parse()', () {
    test('returns IbanInfo for valid IBAN', () {
      final info = IbanValidator.parse(validIban);
      expect(info, isNotNull);
      expect(info!.countryCode, equals('SA'));
      expect(info.checkDigits, equals('03'));
      expect(info.bankCode, equals('80'));
      expect(info.accountNumber, equals('000000608010167519'));
      expect(info.iban, equals(validIban));
    });
    test('returns bank name', () {
      final info = IbanValidator.parse(validIban);
      expect(info, isNotNull);
      expect(info!.bankName, isNotNull);
    });
    test('returns null for invalid', () {
      expect(IbanValidator.parse('INVALID'), isNull);
    });
    test('returns null for empty', () {
      expect(IbanValidator.parse(''), isNull);
    });
    test('parses IBAN with spaces', () {
      final info = IbanValidator.parse('SA03 8000 0000 6080 1016 7519');
      expect(info, isNotNull);
      expect(info!.bankCode, equals('80'));
    });
  });

  group('IbanValidator.format()', () {
    test('formats with spaces every 4 chars', () {
      expect(IbanValidator.format(validIban), equals('SA03 8000 0000 6080 1016 7519'));
    });
    test('handles already formatted', () {
      expect(
        IbanValidator.format('SA03 8000 0000 6080 1016 7519'),
        equals('SA03 8000 0000 6080 1016 7519'),
      );
    });
    test('converts to uppercase', () {
      expect(IbanValidator.format(validIban.toLowerCase()),
          equals('SA03 8000 0000 6080 1016 7519'));
    });
  });

  group('SaudiBanks.getBankName()', () {
    test('Al Rajhi (80)', () {
      expect(SaudiBanks.getBankName('80'), isNotNull);
    });
    test('Al Ahli (10)', () {
      expect(SaudiBanks.getBankName('10'), isNotNull);
    });
    test('Inma (50)', () {
      expect(SaudiBanks.getBankName('50'), isNotNull);
    });
    test('Riyad (20)', () {
      expect(SaudiBanks.getBankName('20'), isNotNull);
    });
    test('unknown code returns null', () {
      expect(SaudiBanks.getBankName('99'), isNull);
    });
    test('empty code returns null', () {
      expect(SaudiBanks.getBankName(''), isNull);
    });
    test('all known bank codes have names', () {
      final knownCodes = ['10', '15', '20', '30', '40', '45', '50', '55', '60', '65', '80', '90'];
      for (final code in knownCodes) {
        expect(SaudiBanks.getBankName(code), isNotNull,
            reason: 'Bank code $code should have a name');
      }
    });
  });

  group('IbanValidator.formValidator()', () {
    test('required rejects empty', () {
      expect(IbanValidator.formValidator(required: true)(''), isNotNull);
    });
    test('required rejects null', () {
      expect(IbanValidator.formValidator(required: true)(null), isNotNull);
    });
    test('optional accepts empty', () {
      expect(IbanValidator.formValidator(required: false)(''), isNull);
    });
    test('optional accepts null', () {
      expect(IbanValidator.formValidator(required: false)(null), isNull);
    });
    test('en locale returns English error', () {
      final err = IbanValidator.formValidator(locale: 'en', required: true)('');
      expect(err, isNotNull);
      expect(err, contains('IBAN'));
    });
    test('valid IBAN returns null', () {
      expect(IbanValidator.formValidator(required: true)(validIban), isNull);
    });
    test('invalid IBAN returns error', () {
      expect(IbanValidator.formValidator(required: true)('INVALID'), isNotNull);
    });
  });

  group('IbanInfo.toString()', () {
    test('contains bank and account info', () {
      final info = IbanValidator.parse(validIban);
      expect(info, isNotNull);
      final str = info.toString();
      expect(str, contains('IbanInfo'));
      expect(str, contains('account'));
    });
  });
}
