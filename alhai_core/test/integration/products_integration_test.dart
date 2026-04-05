import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_core/src/repositories/products_repository.dart';
import 'package:alhai_core/src/repositories/impl/products_repository_impl.dart';
import 'package:alhai_core/src/datasources/remote/products_remote_datasource.dart';
import 'package:alhai_core/src/dto/products/product_response.dart';
import 'package:alhai_core/src/dto/products/create_product_request.dart';
import 'package:alhai_core/src/dto/products/update_product_request.dart';
import 'package:alhai_core/src/models/create_product_params.dart';
import 'package:alhai_core/src/models/update_product_params.dart';

/// Mock classes
class MockProductsRemoteDataSource extends Mock
    implements ProductsRemoteDataSource {}

class FakeCreateProductRequest extends Fake implements CreateProductRequest {}

class FakeUpdateProductRequest extends Fake implements UpdateProductRequest {}

/// Integration Tests for ProductsRepository
void main() {
  late ProductsRepository productsRepository;
  late MockProductsRemoteDataSource mockRemote;

  setUpAll(() {
    registerFallbackValue(FakeCreateProductRequest());
    registerFallbackValue(FakeUpdateProductRequest());
  });

  setUp(() {
    mockRemote = MockProductsRemoteDataSource();
    productsRepository = ProductsRepositoryImpl(remote: mockRemote);
  });

  final testProductResponse = ProductResponse.fromJson({
    'id': 'prod-123',
    'store_id': 'store-123',
    'name': 'Test Product',
    'barcode': '1234567890',
    'sku': 'SKU-001',
    'category_id': 'cat-123',
    'cost_price': 10.0,
    'price': 15.0,
    'stock_qty': 100,
    'min_stock_level': 10,
    'is_active': true,
    'created_at': '2026-01-19T00:00:00Z',
  });

  group('Products Integration Tests', () {
    group('Get Products', () {
      test('should return paginated list of products', () async {
        // Arrange
        const storeId = 'store-123';
        when(() => mockRemote.getProducts(storeId, page: 1, limit: 20))
            .thenAnswer((_) async => [testProductResponse]);

        // Act
        final paginated = await productsRepository.getProducts(storeId);

        // Assert
        expect(paginated.items.length, 1);
        expect(paginated.items.first.name, 'Test Product');
      });

      test('should handle empty list', () async {
        // Arrange
        const storeId = 'store-123';
        when(() => mockRemote.getProducts(storeId, page: 1, limit: 20))
            .thenAnswer((_) async => []);

        // Act
        final paginated = await productsRepository.getProducts(storeId);

        // Assert
        expect(paginated.items.isEmpty, true);
      });
    });

    group('Get Product by ID', () {
      test('should return product by ID', () async {
        // Arrange
        const productId = 'prod-123';
        when(() => mockRemote.getProduct(productId))
            .thenAnswer((_) async => testProductResponse);

        // Act
        final product = await productsRepository.getProduct(productId);

        // Assert
        expect(product.id, productId);
        expect(product.name, 'Test Product');
      });

      test('should throw on not found', () async {
        // Arrange
        const productId = 'nonexistent';
        when(() => mockRemote.getProduct(productId)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/products/$productId'),
            response: Response(
              requestOptions: RequestOptions(path: '/products/$productId'),
              statusCode: 404,
            ),
          ),
        );

        // Act & Assert
        await expectLater(
          productsRepository.getProduct(productId),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Get Product by Barcode', () {
      test('should return product by barcode', () async {
        // Arrange
        const barcode = '1234567890';
        when(() => mockRemote.getByBarcode(barcode))
            .thenAnswer((_) async => testProductResponse);

        // Act
        final product = await productsRepository.getByBarcode(barcode);

        // Assert
        expect(product?.barcode, barcode);
      });

      test('should return null for unknown barcode', () async {
        // Arrange
        const barcode = 'unknown';
        when(() => mockRemote.getByBarcode(barcode))
            .thenAnswer((_) async => null);

        // Act
        final product = await productsRepository.getByBarcode(barcode);

        // Assert
        expect(product, isNull);
      });
    });

    group('Create Product', () {
      test('should create product successfully', () async {
        // Arrange
        const params = CreateProductParams(
          storeId: 'store-123',
          name: 'New Product',
          price: 15.0,
        );
        when(() => mockRemote.createProduct(any()))
            .thenAnswer((_) async => testProductResponse);

        // Act
        final product = await productsRepository.createProduct(params);

        // Assert
        expect(product.name, 'Test Product');
        verify(() => mockRemote.createProduct(any())).called(1);
      });
    });

    group('Update Product', () {
      test('should update product successfully', () async {
        // Arrange
        const params = UpdateProductParams(
          id: 'prod-123',
          name: 'Updated Product',
          price: 20.0,
        );
        when(() => mockRemote.updateProduct(any(), any()))
            .thenAnswer((_) async => testProductResponse);

        // Act
        final product = await productsRepository.updateProduct(params);

        // Assert
        expect(product.id, 'prod-123');
        verify(() => mockRemote.updateProduct(any(), any())).called(1);
      });
    });

    group('Delete Product', () {
      test('should delete product successfully', () async {
        // Arrange
        const productId = 'prod-123';
        when(() => mockRemote.deleteProduct(productId))
            .thenAnswer((_) async {});

        // Act & Assert
        await expectLater(
          productsRepository.deleteProduct(productId),
          completes,
        );
        verify(() => mockRemote.deleteProduct(productId)).called(1);
      });

      test('should throw on RLS policy violation', () async {
        // Arrange
        const productId = 'prod-123';
        when(() => mockRemote.deleteProduct(productId)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/products/$productId'),
            response: Response(
              requestOptions: RequestOptions(path: '/products/$productId'),
              statusCode: 403,
            ),
          ),
        );

        // Act & Assert
        await expectLater(
          productsRepository.deleteProduct(productId),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
