/// اختبارات مزودات المنتجات
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_core/alhai_core.dart';
import 'package:pos_app/providers/products_providers.dart';

// ============================================================================
// MOCKS
// ============================================================================

class MockProductsRepository extends Mock implements ProductsRepository {}

class MockCategoriesRepository extends Mock implements CategoriesRepository {}

// ============================================================================
// TEST DATA
// ============================================================================

List<Product> _createTestProducts(int count) {
  return List.generate(
    count,
    (i) => Product(
      id: 'product-$i',
      storeId: 'store-1',
      name: 'منتج $i',
      price: 10.0 * (i + 1),
      stockQty: i < 3 ? 0 : (i < 5 ? 3 : 100), // 3 out of stock, 2 low stock
      minQty: 5,
      isActive: true,
      createdAt: DateTime.now(),
    ),
  );
}

List<Category> _createTestCategories(int count) {
  return List.generate(
    count,
    (i) => Category(
      id: 'category-$i',
      name: 'تصنيف $i',
      sortOrder: i,
    ),
  );
}

// ============================================================================
// TESTS
// ============================================================================

void main() {
  late MockProductsRepository mockProductsRepository;
  late MockCategoriesRepository mockCategoriesRepository;

  setUp(() {
    mockProductsRepository = MockProductsRepository();
    mockCategoriesRepository = MockCategoriesRepository();
  });

  group('ProductsState', () {
    test('الحالة الأولية صحيحة', () {
      const state = ProductsState();

      expect(state.products, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.currentPage, 1);
      expect(state.hasMore, isTrue);
      expect(state.searchQuery, isNull);
      expect(state.categoryId, isNull);
    });

    test('copyWith يعمل بشكل صحيح', () {
      const state = ProductsState();
      final newState = state.copyWith(
        isLoading: true,
        currentPage: 5,
        searchQuery: 'بحث',
      );

      expect(newState.isLoading, isTrue);
      expect(newState.currentPage, 5);
      expect(newState.searchQuery, 'بحث');
    });
  });

  group('ProductsNotifier', () {
    test('يُحمّل المنتجات بنجاح', () async {
      // Arrange
      final testProducts = _createTestProducts(10);
      when(() => mockProductsRepository.getProducts(
            any(),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => Paginated<Product>(
            items: testProducts,
            total: 10,
            page: 1,
            limit: 20,
          ));

      final notifier = ProductsNotifier(mockProductsRepository);

      // Act
      await notifier.loadProducts(storeId: 'store-1');

      // Assert
      expect(notifier.state.products.length, 10);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.error, isNull);
    });

    test('يُعالج الأخطاء بشكل صحيح', () async {
      // Arrange
      when(() => mockProductsRepository.getProducts(
            any(),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          )).thenThrow(Exception('خطأ في التحميل'));

      final notifier = ProductsNotifier(mockProductsRepository);

      // Act
      await notifier.loadProducts(storeId: 'store-1');

      // Assert
      expect(notifier.state.products, isEmpty);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.error, isNotNull);
    });

    test('search يُعيّن searchQuery', () async {
      // Arrange
      when(() => mockProductsRepository.getProducts(
            any(),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => const Paginated<Product>(
            items: [],
            total: 0,
            page: 1,
            limit: 20,
          ));

      final notifier = ProductsNotifier(mockProductsRepository);

      // Act
      await notifier.search('تفاح', storeId: 'store-1');

      // Assert
      expect(notifier.state.searchQuery, 'تفاح');
    });

    test('filterByCategory يُعيّن categoryId', () async {
      // Arrange
      when(() => mockProductsRepository.getProducts(
            any(),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => const Paginated<Product>(
            items: [],
            total: 0,
            page: 1,
            limit: 20,
          ));

      final notifier = ProductsNotifier(mockProductsRepository);

      // Act
      await notifier.filterByCategory('cat-1', storeId: 'store-1');

      // Assert
      expect(notifier.state.categoryId, 'cat-1');
    });

    test('clearError يمسح الخطأ', () async {
      // Arrange
      when(() => mockProductsRepository.getProducts(
            any(),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          )).thenThrow(Exception('خطأ'));

      final notifier = ProductsNotifier(mockProductsRepository);
      await notifier.loadProducts(storeId: 'store-1');

      expect(notifier.state.error, isNotNull);

      // Act
      notifier.clearError();

      // Assert
      expect(notifier.state.error, isNull);
    });
  });

  group('Provider Integration', () {
    test('productsListProvider يُرجع قائمة المنتجات', () async {
      // Arrange
      final testProducts = _createTestProducts(5);
      when(() => mockProductsRepository.getProducts(
            any(),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => Paginated<Product>(
            items: testProducts,
            total: 5,
            page: 1,
            limit: 20,
          ));

      final container = ProviderContainer(
        overrides: [
          productsRepositoryProvider.overrideWithValue(mockProductsRepository),
        ],
      );
      addTearDown(container.dispose);

      // Act
      await container.read(productsStateProvider.notifier).loadProducts(storeId: 'store-1');

      // Assert
      final products = container.read(productsListProvider);
      expect(products.length, 5);
    });

    test('productByIdProvider يُرجع المنتج الصحيح', () async {
      // Arrange
      final testProducts = _createTestProducts(5);
      when(() => mockProductsRepository.getProducts(
            any(),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => Paginated<Product>(
            items: testProducts,
            total: 5,
            page: 1,
            limit: 20,
          ));

      final container = ProviderContainer(
        overrides: [
          productsRepositoryProvider.overrideWithValue(mockProductsRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(productsStateProvider.notifier).loadProducts(storeId: 'store-1');

      // Act & Assert
      final product = container.read(productByIdProvider('product-2'));
      expect(product, isNotNull);
      expect(product?.name, 'منتج 2');

      final notFound = container.read(productByIdProvider('not-found'));
      expect(notFound, isNull);
    });

    test('lowStockProductsProvider يُرجع المنتجات منخفضة المخزون', () async {
      // Arrange
      final testProducts = _createTestProducts(10);
      when(() => mockProductsRepository.getProducts(
            any(),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => Paginated<Product>(
            items: testProducts,
            total: 10,
            page: 1,
            limit: 20,
          ));

      final container = ProviderContainer(
        overrides: [
          productsRepositoryProvider.overrideWithValue(mockProductsRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(productsStateProvider.notifier).loadProducts(storeId: 'store-1');

      // Act
      final lowStock = container.read(lowStockProductsProvider);

      // Assert - المنتجات 3,4 لديها stockQty=3 وminQty=5
      expect(lowStock.length, 5); // 0,1,2 (out of stock) + 3,4 (low stock)
    });

    test('outOfStockProductsProvider يُرجع المنتجات النفذة', () async {
      // Arrange
      final testProducts = _createTestProducts(10);
      when(() => mockProductsRepository.getProducts(
            any(),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => Paginated<Product>(
            items: testProducts,
            total: 10,
            page: 1,
            limit: 20,
          ));

      final container = ProviderContainer(
        overrides: [
          productsRepositoryProvider.overrideWithValue(mockProductsRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(productsStateProvider.notifier).loadProducts(storeId: 'store-1');

      // Act
      final outOfStock = container.read(outOfStockProductsProvider);

      // Assert - المنتجات 0,1,2 لديها stockQty=0
      expect(outOfStock.length, 3);
    });

    test('categoriesProvider يُحمّل التصنيفات', () async {
      // Arrange
      final testCategories = _createTestCategories(5);
      when(() => mockCategoriesRepository.getCategories(any()))
          .thenAnswer((_) async => testCategories);

      final container = ProviderContainer(
        overrides: [
          categoriesRepositoryProvider.overrideWithValue(mockCategoriesRepository),
          currentStoreIdProvider.overrideWith((ref) => 'store-1'),
        ],
      );
      addTearDown(container.dispose);

      // Act
      final categories = await container.read(categoriesProvider.future);

      // Assert
      expect(categories.length, 5);
    });
  });
}
