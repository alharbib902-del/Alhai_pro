import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_core/src/datasources/remote/inventory_remote_datasource.dart';
import 'package:alhai_core/src/dto/inventory/stock_adjustment_response.dart';
import 'package:alhai_core/src/dto/inventory/adjust_stock_request.dart';
import 'package:alhai_core/src/dto/inventory/low_stock_product_response.dart';
import 'package:alhai_core/src/exceptions/app_exception.dart';
import 'package:alhai_core/src/models/stock_adjustment.dart';
import 'package:alhai_core/src/repositories/impl/inventory_repository_impl.dart';

// Mock class
class MockInventoryRemoteDataSource extends Mock
    implements InventoryRemoteDataSource {}

// Fake classes
class FakeAdjustStockRequest extends Fake implements AdjustStockRequest {}

void main() {
  late InventoryRepositoryImpl repository;
  late MockInventoryRemoteDataSource mockRemote;

  // Test data - using 'sold' which is a valid AdjustmentType enum value
  const testAdjustmentResponse = StockAdjustmentResponse(
    id: 'adj-1',
    productId: 'prod-1',
    storeId: 'store-1',
    type: 'sold',
    quantity: 5,
    previousQty: 100,
    newQty: 95,
    reason: 'Sale',
    createdAt: '2026-01-19T10:00:00Z',
  );

  const testLowStockResponse = LowStockProductResponse(
    productId: 'prod-1',
    productName: 'Test Product',
    currentQty: 5,
    minQty: 10,
  );

  setUpAll(() {
    registerFallbackValue(FakeAdjustStockRequest());
  });

  setUp(() {
    mockRemote = MockInventoryRemoteDataSource();
    repository = InventoryRepositoryImpl(remote: mockRemote);
  });

  group('InventoryRepositoryImpl', () {
    group('getAdjustments', () {
      test('returns Paginated<StockAdjustment> on success', () async {
        // Arrange
        when(
          () => mockRemote.getAdjustments(
            any(),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => [testAdjustmentResponse]);

        // Act
        final result = await repository.getAdjustments(
          'prod-1',
          page: 1,
          limit: 20,
        );

        // Assert
        expect(result.items, hasLength(1));
        expect(result.items.first.id, equals('adj-1'));
        expect(result.items.first.type, equals(AdjustmentType.sold));
        expect(result.page, equals(1));
        verify(
          () => mockRemote.getAdjustments('prod-1', page: 1, limit: 20),
        ).called(1);
      });

      test('throws NetworkException on connection error', () async {
        // Arrange
        when(
          () => mockRemote.getAdjustments(
            any(),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.connectionError,
            requestOptions: RequestOptions(path: '/inventory'),
          ),
        );

        // Act & Assert
        expect(
          () => repository.getAdjustments('prod-1'),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('adjustStock', () {
      test('adjusts stock and returns StockAdjustment', () async {
        // Arrange
        when(
          () => mockRemote.adjustStock(any()),
        ).thenAnswer((_) async => testAdjustmentResponse);

        // Act
        final result = await repository.adjustStock(
          productId: 'prod-1',
          storeId: 'store-1',
          type: AdjustmentType.sold,
          quantity: 5,
        );

        // Assert
        expect(result.id, equals('adj-1'));
        expect(result.quantity, equals(5));
        verify(() => mockRemote.adjustStock(any())).called(1);
      });
    });

    group('getLowStockProducts', () {
      test('returns list of LowStockProduct', () async {
        // Arrange
        when(
          () => mockRemote.getLowStockProducts(any()),
        ).thenAnswer((_) async => [testLowStockResponse]);

        // Act
        final result = await repository.getLowStockProducts('store-1');

        // Assert
        expect(result, hasLength(1));
        expect(result.first.productId, equals('prod-1'));
        expect(result.first.deficit, equals(5));
      });
    });

    group('getOutOfStockProductIds', () {
      test('returns list of product IDs', () async {
        // Arrange
        when(
          () => mockRemote.getOutOfStockProductIds(any()),
        ).thenAnswer((_) async => ['prod-1', 'prod-2']);

        // Act
        final result = await repository.getOutOfStockProductIds('store-1');

        // Assert
        expect(result, hasLength(2));
        expect(result, contains('prod-1'));
      });
    });
  });
}
