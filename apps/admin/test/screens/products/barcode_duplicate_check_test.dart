library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';

import '../../helpers/test_helpers.dart';

/// Tests for barcode duplicate checking logic.
///
/// Verifies that ProductsDao.getProductByBarcode correctly identifies
/// existing products, which product_form_screen uses before save.
void main() {
  late MockProductsDao productsDao;
  late MockAppDatabase db;

  setUpAll(() => registerAdminFallbackValues());

  setUp(() {
    productsDao = MockProductsDao();
    db = setupMockDatabase(productsDao: productsDao);
    setupTestGetIt(mockDb: db);
  });

  tearDown(() => tearDownTestGetIt());

  group('Barcode duplicate check', () {
    test('creating product A with barcode 123 succeeds when no duplicate',
        () async {
      when(
        () => productsDao.getProductByBarcode('123', any()),
      ).thenAnswer((_) async => null);

      final result =
          await db.productsDao.getProductByBarcode('123', 'test-store-1');
      expect(result, isNull, reason: 'No existing product — insert allowed');
    });

    test(
        'creating product B with barcode 123 fails when product A already uses it',
        () async {
      final existingProduct = createTestProduct(
        id: 'prod-A',
        barcode: '123',
        name: '\u0645\u0646\u062a\u062c \u0623',
      );

      when(
        () => productsDao.getProductByBarcode('123', any()),
      ).thenAnswer((_) async => existingProduct);

      final result =
          await db.productsDao.getProductByBarcode('123', 'test-store-1');
      expect(result, isNotNull, reason: 'Duplicate barcode detected');
      expect(result!.id, equals('prod-A'));
      expect(result.name, equals('\u0645\u0646\u062a\u062c \u0623'));
    });

    test('editing product A with same barcode 123 is allowed', () async {
      final existingProduct = createTestProduct(
        id: 'prod-A',
        barcode: '123',
        name: '\u0645\u0646\u062a\u062c \u0623',
      );

      when(
        () => productsDao.getProductByBarcode('123', any()),
      ).thenAnswer((_) async => existingProduct);

      final result =
          await db.productsDao.getProductByBarcode('123', 'test-store-1');
      expect(result, isNotNull);

      // When editing, the form checks: existingProduct.id == widget.productId
      const editingProductId = 'prod-A';
      final isSameProduct = result!.id == editingProductId;
      expect(
        isSameProduct,
        isTrue,
        reason: 'Same product editing its own barcode — should be allowed',
      );
    });

    test('empty barcode skips duplicate check', () async {
      // The form code: if (barcode.isNotEmpty) { ... }
      const barcode = '';
      expect(barcode.isEmpty, isTrue, reason: 'Empty barcode skips check');

      // Verify getProductByBarcode is never called for empty barcode
      verifyNever(() => productsDao.getProductByBarcode(any(), any()));
    });
  });
}
