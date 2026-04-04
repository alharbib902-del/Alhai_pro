import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_pos/src/core/errors/app_exceptions.dart';

void main() {
  group('NetworkException', () {
    test('default constructor has English message and Arabic userMessage', () {
      const ex = NetworkException();
      expect(ex.message, isNotEmpty);
      expect(ex.userMessage, isNotEmpty);
    });

    test('noConnection factory', () {
      final ex = NetworkException.noConnection();
      expect(ex.code, equals('NO_CONNECTION'));
      expect(ex.userMessage, isNotEmpty);
    });

    test('timeout factory', () {
      final ex = NetworkException.timeout();
      expect(ex.code, equals('TIMEOUT'));
    });

    test('serverError factory with status code', () {
      final ex = NetworkException.serverError(500);
      expect(ex.code, equals('SERVER_ERROR'));
      expect(ex.details, isNotNull);
    });

    test('toString includes runtime type', () {
      const ex = NetworkException();
      expect(ex.toString(), contains('NetworkException'));
    });
  });

  group('AuthException', () {
    test('sessionExpired factory', () {
      final ex = AuthException.sessionExpired();
      expect(ex.code, equals('SESSION_EXPIRED'));
    });

    test('unauthorized factory', () {
      final ex = AuthException.unauthorized();
      expect(ex.code, equals('UNAUTHORIZED'));
    });

    test('invalidOtp factory', () {
      final ex = AuthException.invalidOtp();
      expect(ex.code, equals('INVALID_OTP'));
    });

    test('invalidPhone factory', () {
      final ex = AuthException.invalidPhone();
      expect(ex.code, equals('INVALID_PHONE'));
    });

    test('tokenExpired factory', () {
      final ex = AuthException.tokenExpired();
      expect(ex.code, equals('TOKEN_EXPIRED'));
    });
  });

  group('DatabaseException', () {
    test('insertFailed factory', () {
      final ex = DatabaseException.insertFailed('sales');
      expect(ex.code, equals('INSERT_FAILED'));
      expect(ex.details, isNotNull);
    });

    test('updateFailed factory', () {
      final ex = DatabaseException.updateFailed('products');
      expect(ex.code, equals('UPDATE_FAILED'));
    });

    test('notFound factory', () {
      final ex = DatabaseException.notFound('uuid-123');
      expect(ex.code, equals('NOT_FOUND'));
    });
  });

  group('ValidationException', () {
    test('required factory', () {
      final ex = ValidationException.required('name');
      expect(ex.code, equals('REQUIRED'));
      expect(ex.details, equals({'field': 'name'}));
    });

    test('invalid factory', () {
      final ex = ValidationException.invalid('email');
      expect(ex.code, equals('INVALID'));
    });
  });

  group('BusinessException', () {
    test('outOfStock factory with product name', () {
      final ex = BusinessException.outOfStock('Milk');
      expect(ex.code, equals('OUT_OF_STOCK'));
      expect(ex.userMessage, contains('Milk'));
    });

    test('outOfStock factory without product name', () {
      final ex = BusinessException.outOfStock();
      expect(ex.userMessage, isNotEmpty);
    });

    test('insufficientBalance factory', () {
      final ex = BusinessException.insufficientBalance();
      expect(ex.code, equals('INSUFFICIENT_BALANCE'));
    });

    test('maxQuantity factory', () {
      final ex = BusinessException.maxQuantity(10);
      expect(ex.code, equals('MAX_QUANTITY'));
      expect(ex.userMessage, contains('10'));
    });
  });

  group('SaleException', () {
    test('notFound factory', () {
      final ex = SaleException.notFound('sale-123');
      expect(ex.code, equals('SALE_NOT_FOUND'));
    });

    test('alreadyVoided factory', () {
      final ex = SaleException.alreadyVoided('sale-123');
      expect(ex.code, equals('SALE_ALREADY_VOIDED'));
    });

    test('emptyCart factory', () {
      final ex = SaleException.emptyCart();
      expect(ex.code, equals('EMPTY_CART'));
    });

    test('invalidPaymentMethod factory', () {
      final ex = SaleException.invalidPaymentMethod('bitcoin');
      expect(ex.code, equals('INVALID_PAYMENT_METHOD'));
    });

    test('cannotVoid factory', () {
      final ex = SaleException.cannotVoid('Too old');
      expect(ex.code, equals('CANNOT_VOID'));
      expect(ex.userMessage, contains('Too old'));
    });

    test('insufficientStock factory', () {
      final ex = SaleException.insufficientStock('Milk', 5, 10);
      expect(ex.code, equals('INSUFFICIENT_STOCK'));
      expect(ex.userMessage, contains('Milk'));
      expect(ex.userMessage, contains('5'));
      expect(ex.userMessage, contains('10'));
      expect(
          ex.details,
          equals({
            'productName': 'Milk',
            'available': 5,
            'requested': 10,
          }));
    });
  });

  group('PermissionException', () {
    test('required factory', () {
      final ex = PermissionException.required('admin');
      expect(ex.code, equals('PERMISSION_REQUIRED'));
    });

    test('insufficientRole factory', () {
      final ex = PermissionException.insufficientRole('admin', 'cashier');
      expect(ex.code, equals('INSUFFICIENT_ROLE'));
      expect(
          ex.details,
          equals({
            'required': 'admin',
            'current': 'cashier',
          }));
    });
  });

  group('AppException implements Exception', () {
    test('all exceptions implement Exception', () {
      expect(const NetworkException(), isA<Exception>());
      expect(const AuthException(), isA<Exception>());
      expect(const DatabaseException(), isA<Exception>());
      expect(const ValidationException(), isA<Exception>());
      expect(const BusinessException(), isA<Exception>());
      expect(const SaleException(), isA<Exception>());
      expect(const PermissionException(), isA<Exception>());
    });
  });
}
