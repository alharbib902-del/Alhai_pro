import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_core/src/datasources/remote/products_remote_datasource.dart';
import 'package:alhai_core/src/dto/products/product_response.dart';
import 'package:alhai_core/src/dto/products/create_product_request.dart';
import 'package:alhai_core/src/dto/products/update_product_request.dart';
import 'package:alhai_core/src/exceptions/app_exception.dart';
import 'package:alhai_core/src/models/create_product_params.dart';
import 'package:alhai_core/src/models/update_product_params.dart';
import 'package:alhai_core/src/repositories/impl/products_repository_impl.dart';

// Mock class
class MockProductsRemoteDataSource extends Mock
    implements ProductsRemoteDataSource {}

// Fake classes for registerFallbackValue
class FakeCreateProductRequest extends Fake implements CreateProductRequest {}

class FakeUpdateProductRequest extends Fake implements UpdateProductRequest {}

void main() {
  late ProductsRepositoryImpl repository;
  late MockProductsRemoteDataSource mockRemote;

  // Test data
  final testProductResponse = ProductResponse(
    id: 'prod-1',
    storeId: 'store-1',
    name: 'Test Product',
    sku: 'SKU001',
    barcode: '123456789',
    price: 99.99,
    costPrice: 50.0,
    stockQty: 100,
    minQty: 10,
    unit: 'piece',
    description: 'Test description',
    imageThumbnail: 'https://example.com/image-thumb.jpg',
    categoryId: 'cat-1',
    isActive: true,
    trackInventory: true,
    createdAt: '2026-01-10T10:00:00Z',
    updatedAt: '2026-01-11T10:00:00Z',
  );

  setUpAll(() {
    registerFallbackValue(FakeCreateProductRequest());
    registerFallbackValue(FakeUpdateProductRequest());
  });

  setUp(() {
    mockRemote = MockProductsRemoteDataSource();
    repository = ProductsRepositoryImpl(remote: mockRemote);
  });

  group('ProductsRepositoryImpl', () {
    group('getProducts', () {
      test('returns Paginated<Product> on success', () async {
        // Arrange
        when(() => mockRemote.getProducts(
              any(),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => [testProductResponse]);

        // Act
        final result =
            await repository.getProducts('store-1', page: 1, limit: 20);

        // Assert
        expect(result.items, hasLength(1));
        expect(result.items.first.id, equals('prod-1'));
        expect(result.items.first.name, equals('Test Product'));
        expect(result.page, equals(1));
        expect(result.limit, equals(20));
        verify(() => mockRemote.getProducts('store-1', page: 1, limit: 20))
            .called(1);
      });

      test('throws AppException on network error', () async {
        // Arrange
        when(() => mockRemote.getProducts(
              any(),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenThrow(DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: '/products'),
        ));

        // Act & Assert
        expect(
          () => repository.getProducts('store-1'),
          throwsA(isA<NetworkException>()),
        );
      });

      test('returns empty list when no products', () async {
        // Arrange
        when(() => mockRemote.getProducts(
              any(),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => []);

        // Act
        final result = await repository.getProducts('store-1');

        // Assert
        expect(result.items, isEmpty);
        expect(result.hasMore, isFalse);
      });
    });

    group('getProduct', () {
      test('returns Product on success', () async {
        // Arrange
        when(() => mockRemote.getProduct(any()))
            .thenAnswer((_) async => testProductResponse);

        // Act
        final result = await repository.getProduct('prod-1');

        // Assert
        expect(result.id, equals('prod-1'));
        expect(result.name, equals('Test Product'));
        expect(result.price, equals(99.99));
        expect(result.costPrice, equals(50.0));
        verify(() => mockRemote.getProduct('prod-1')).called(1);
      });

      test('throws NotFoundException on 404', () async {
        // Arrange
        when(() => mockRemote.getProduct(any())).thenThrow(DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 404,
            data: {'message': 'Product not found'},
            requestOptions: RequestOptions(path: '/products/invalid'),
          ),
          requestOptions: RequestOptions(path: '/products/invalid'),
        ));

        // Act & Assert
        expect(
          () => repository.getProduct('invalid'),
          throwsA(isA<NotFoundException>()),
        );
      });
    });

    group('getByBarcode', () {
      test('returns Product when barcode exists', () async {
        // Arrange
        when(() => mockRemote.getByBarcode(any()))
            .thenAnswer((_) async => testProductResponse);

        // Act
        final result = await repository.getByBarcode('123456789');

        // Assert
        expect(result, isNotNull);
        expect(result!.barcode, equals('123456789'));
      });

      test('returns null when barcode not found', () async {
        // Arrange
        when(() => mockRemote.getByBarcode(any()))
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.getByBarcode('unknown');

        // Assert
        expect(result, isNull);
      });
    });

    group('createProduct', () {
      test('creates product with correct DTO mapping', () async {
        // Arrange
        final params = CreateProductParams(
          storeId: 'store-1',
          name: 'New Product',
          price: 49.99,
        );

        when(() => mockRemote.createProduct(any()))
            .thenAnswer((_) async => testProductResponse);

        // Act
        final result = await repository.createProduct(params);

        // Assert
        expect(result.id, equals('prod-1'));
        verify(() => mockRemote.createProduct(any())).called(1);
      });

      test('throws ValidationException on 400', () async {
        // Arrange
        final params = CreateProductParams(
          storeId: 'store-1',
          name: '',
          price: -1,
        );

        when(() => mockRemote.createProduct(any())).thenThrow(DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 400,
            data: {
              'message': 'Validation failed',
              'errors': {
                'name': ['Name is required']
              }
            },
            requestOptions: RequestOptions(path: '/products'),
          ),
          requestOptions: RequestOptions(path: '/products'),
        ));

        // Act & Assert
        expect(
          () => repository.createProduct(params),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('updateProduct', () {
      test('updates product with correct DTO mapping', () async {
        // Arrange
        final params = UpdateProductParams(
          id: 'prod-1',
          name: 'Updated Product',
          price: 79.99,
        );

        when(() => mockRemote.updateProduct(any(), any()))
            .thenAnswer((_) async => testProductResponse);

        // Act
        final result = await repository.updateProduct(params);

        // Assert
        expect(result.id, equals('prod-1'));
        verify(() => mockRemote.updateProduct('prod-1', any())).called(1);
      });
    });

    group('deleteProduct', () {
      test('deletes product successfully', () async {
        // Arrange
        when(() => mockRemote.deleteProduct(any())).thenAnswer((_) async {});

        // Act & Assert
        await expectLater(repository.deleteProduct('prod-1'), completes);
        verify(() => mockRemote.deleteProduct('prod-1')).called(1);
      });

      test('throws ServerException on 500', () async {
        // Arrange
        when(() => mockRemote.deleteProduct(any())).thenThrow(DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 500,
            data: {'message': 'Internal server error'},
            requestOptions: RequestOptions(path: '/products/prod-1'),
          ),
          requestOptions: RequestOptions(path: '/products/prod-1'),
        ));

        // Act & Assert
        expect(
          () => repository.deleteProduct('prod-1'),
          throwsA(isA<ServerException>()),
        );
      });
    });
  });
}
