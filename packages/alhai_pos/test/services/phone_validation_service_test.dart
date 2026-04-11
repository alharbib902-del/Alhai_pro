import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_pos/src/services/whatsapp/phone_validation_service.dart';

void main() {
  group('PhoneValidationService', () {
    group('formatPhone (static)', () {
      test('should convert 05x to 9665x format', () {
        expect(
          PhoneValidationService.formatPhone('0512345678'),
          equals('966512345678'),
        );
      });

      test('should convert 5x to 9665x format', () {
        expect(
          PhoneValidationService.formatPhone('512345678'),
          equals('966512345678'),
        );
      });

      test('should keep 966x format unchanged', () {
        expect(
          PhoneValidationService.formatPhone('966512345678'),
          equals('966512345678'),
        );
      });

      test('should strip + prefix', () {
        expect(
          PhoneValidationService.formatPhone('+966512345678'),
          equals('966512345678'),
        );
      });

      test('should strip 00 prefix', () {
        expect(
          PhoneValidationService.formatPhone('00966512345678'),
          equals('966512345678'),
        );
      });

      test('should remove spaces and special chars', () {
        expect(
          PhoneValidationService.formatPhone('05 1234 5678'),
          equals('966512345678'),
        );
        expect(
          PhoneValidationService.formatPhone('(05)12345678'),
          equals('966512345678'),
        );
        expect(
          PhoneValidationService.formatPhone('05-1234-5678'),
          equals('966512345678'),
        );
      });

      test('should return cleaned number for non-Saudi formats', () {
        // Non-Saudi numbers should be returned after cleanup
        expect(
          PhoneValidationService.formatPhone('123456789012345'),
          equals('123456789012345'),
        );
      });
    });

    group('isValidPhone (static)', () {
      test('should accept Saudi mobile numbers', () {
        expect(PhoneValidationService.isValidPhone('0512345678'), isTrue);
        expect(PhoneValidationService.isValidPhone('512345678'), isTrue);
        expect(PhoneValidationService.isValidPhone('966512345678'), isTrue);
        expect(PhoneValidationService.isValidPhone('+966512345678'), isTrue);
        expect(PhoneValidationService.isValidPhone('00966512345678'), isTrue);
      });

      test('should reject empty strings', () {
        expect(PhoneValidationService.isValidPhone(''), isFalse);
        expect(PhoneValidationService.isValidPhone('   '), isFalse);
      });

      test('should reject too short numbers', () {
        expect(PhoneValidationService.isValidPhone('12345'), isFalse);
      });
    });

    group('isSaudiPhone (static)', () {
      test('should accept Saudi numbers starting with 5', () {
        expect(PhoneValidationService.isSaudiPhone('0512345678'), isTrue);
        expect(PhoneValidationService.isSaudiPhone('966512345678'), isTrue);
        expect(PhoneValidationService.isSaudiPhone('+966512345678'), isTrue);
      });

      test('should reject non-Saudi numbers', () {
        expect(PhoneValidationService.isSaudiPhone('1234567890'), isFalse);
      });
    });
  });
}
