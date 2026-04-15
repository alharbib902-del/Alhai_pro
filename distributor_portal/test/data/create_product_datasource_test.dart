import 'package:flutter_test/flutter_test.dart';

import 'package:distributor_portal/data/distributor_datasource.dart';
import 'package:distributor_portal/data/models.dart';

/// Unit tests for createProduct-related validation and error handling.
/// Note: actual Supabase calls cannot be tested without a real/mock client,
/// but we test the validation layer and error categorization.
void main() {
  group('createProduct validation', () {
    test('validatePrice rejects zero', () {
      expect(validatePrice(0), isNotNull);
      expect(validatePrice(0)!, contains('at least'));
    });

    test('validatePrice rejects negative', () {
      expect(validatePrice(-5.0), isNotNull);
    });

    test('validatePrice rejects values above max', () {
      expect(validatePrice(1000000.00), isNotNull);
      expect(validatePrice(1000000.00)!, contains('at most'));
    });

    test('validatePrice accepts valid prices', () {
      expect(validatePrice(0.01), isNull);
      expect(validatePrice(10.50), isNull);
      expect(validatePrice(999999.99), isNull);
    });

    test('DatasourceError for storage failure includes message', () {
      const error = DatasourceError(
        type: DatasourceErrorType.unknown,
        message: 'فشل رفع الصورة: Object not found',
      );
      expect(error.message, contains('فشل رفع الصورة'));
      expect(error.type, DatasourceErrorType.unknown);
    });

    test('DatasourceError for validation failure', () {
      const error = DatasourceError(
        type: DatasourceErrorType.validation,
        message: 'Product name must be at least 3 characters.',
      );
      expect(error.type, DatasourceErrorType.validation);
      expect(error.message, contains('3 characters'));
    });

    test('DatasourceError for no store found', () {
      const error = DatasourceError(
        type: DatasourceErrorType.validation,
        message: 'No store found for this organization.',
      );
      expect(error.type, DatasourceErrorType.validation);
      expect(error.message, contains('No store'));
    });

    test('validateTextLength rejects too-long text', () {
      final result = validateTextLength('a' * 501, 500, 'notes');
      expect(result, isNotNull);
      expect(result!, contains('500'));
    });

    test('validateTextLength accepts valid text', () {
      expect(validateTextLength('hello', 500, 'notes'), isNull);
    });
  });

  group('DistributorProduct.fromJson for created product', () {
    test('parses product with categories join', () {
      final json = {
        'id': 'test-uuid',
        'name': 'منتج جديد',
        'barcode': '1234567890',
        'categories': {'name': 'مواد غذائية'},
        'price': 25.50,
        'stock': 100,
        'updated_at': '2026-04-16T10:00:00Z',
      };

      final product =
          DistributorProduct.fromJson(json);
      expect(product.id, 'test-uuid');
      expect(product.name, 'منتج جديد');
      expect(product.barcode, '1234567890');
      expect(product.category, 'مواد غذائية');
      expect(product.price, 25.50);
      expect(product.stock, 100);
    });

    test('parses product with category_name fallback', () {
      final json = {
        'id': 'test-uuid',
        'name': 'منتج',
        'category_name': 'مشروبات',
        'price': 10.0,
        'stock': 0,
      };

      final product =
          DistributorProduct.fromJson(json);
      expect(product.category, 'مشروبات');
    });

    test('handles null optional fields', () {
      final json = {
        'id': 'test-uuid',
        'name': 'منتج',
        'price': 5.0,
        'stock': 0,
      };

      final product =
          DistributorProduct.fromJson(json);
      expect(product.barcode, isNull);
      expect(product.category, '');
      expect(product.updatedAt, isNull);
    });

    test('equality works correctly', () {
      const p1 = DistributorProduct(
        id: 'a',
        name: 'X',
        category: 'Y',
        price: 10,
        stock: 5,
      );
      const p2 = DistributorProduct(
        id: 'a',
        name: 'X',
        category: 'Y',
        price: 10,
        stock: 5,
      );
      const p3 = DistributorProduct(
        id: 'b',
        name: 'X',
        category: 'Y',
        price: 10,
        stock: 5,
      );

      expect(p1, equals(p2));
      expect(p1, isNot(equals(p3)));
      expect(p1.hashCode, equals(p2.hashCode));
    });
  });

  group('userFriendlyMessage', () {
    test('returns network message', () {
      final msg = userFriendlyMessage(const DatasourceError(
        type: DatasourceErrorType.network,
        message: 'err',
      ));
      expect(msg, contains('internet'));
    });

    test('returns auth message', () {
      final msg = userFriendlyMessage(const DatasourceError(
        type: DatasourceErrorType.auth,
        message: 'err',
      ));
      expect(msg, contains('session'));
    });

    test('returns validation message', () {
      final msg = userFriendlyMessage(const DatasourceError(
        type: DatasourceErrorType.validation,
        message: 'err',
      ));
      expect(msg, contains('Invalid'));
    });
  });
}
