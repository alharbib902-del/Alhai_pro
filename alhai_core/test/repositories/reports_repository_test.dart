import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_core/src/datasources/remote/reports_remote_datasource.dart';
import 'package:alhai_core/src/dto/reports/sales_summary_response.dart';
import 'package:alhai_core/src/dto/reports/product_sales_response.dart';
import 'package:alhai_core/src/dto/reports/inventory_value_response.dart';
import 'package:alhai_core/src/exceptions/app_exception.dart';
import 'package:alhai_core/src/repositories/impl/reports_repository_impl.dart';

// Mock class
class MockReportsRemoteDataSource extends Mock
    implements ReportsRemoteDataSource {}

void main() {
  late ReportsRepositoryImpl repository;
  late MockReportsRemoteDataSource mockRemote;

  // Test data
  const testSalesSummaryResponse = SalesSummaryResponse(
    date: '2026-01-19',
    revenue: 10000.0,
    cost: 7000.0,
    profit: 3000.0,
    ordersCount: 50,
    itemsSold: 200,
  );

  const testProductSalesResponse = ProductSalesResponse(
    productId: 'prod-1',
    productName: 'Test Product',
    quantitySold: 100,
    revenue: 5000.0,
    cost: 3500.0,
    profit: 1500.0,
  );

  const testInventoryValueResponse = InventoryValueResponse(
    costValue: 50000.0,
    retailValue: 75000.0,
    totalProducts: 100,
    totalUnits: 500,
    lowStockCount: 10,
    outOfStockCount: 2,
  );

  setUp(() {
    mockRemote = MockReportsRemoteDataSource();
    repository = ReportsRepositoryImpl(remote: mockRemote);
  });

  group('ReportsRepositoryImpl', () {
    group('getDailySummary', () {
      test('returns SalesSummary on success', () async {
        // Arrange
        when(
          () => mockRemote.getDailySummary(any(), any()),
        ).thenAnswer((_) async => testSalesSummaryResponse);

        // Act
        final result = await repository.getDailySummary(
          'store-1',
          DateTime(2026, 1, 19),
        );

        // Assert
        expect(result.revenue, equals(10000.0));
        expect(result.ordersCount, equals(50));
        verify(
          () => mockRemote.getDailySummary('store-1', '2026-01-19'),
        ).called(1);
      });

      test('throws NetworkException on connection error', () async {
        // Arrange
        when(() => mockRemote.getDailySummary(any(), any())).thenThrow(
          DioException(
            type: DioExceptionType.connectionError,
            requestOptions: RequestOptions(path: '/reports'),
          ),
        );

        // Act & Assert
        expect(
          () => repository.getDailySummary('store-1', DateTime(2026, 1, 19)),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('getTopProducts', () {
      test('returns list of ProductSales', () async {
        // Arrange
        when(
          () => mockRemote.getTopProducts(
            any(),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => [testProductSalesResponse]);

        // Act
        final result = await repository.getTopProducts(
          'store-1',
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 1, 31),
          limit: 10,
        );

        // Assert
        expect(result, hasLength(1));
        expect(result.first.productName, equals('Test Product'));
        expect(result.first.quantitySold, equals(100));
      });
    });

    group('getInventoryValue', () {
      test('returns InventoryValue on success', () async {
        // Arrange
        when(
          () => mockRemote.getInventoryValue(any()),
        ).thenAnswer((_) async => testInventoryValueResponse);

        // Act
        final result = await repository.getInventoryValue('store-1');

        // Assert
        expect(result.costValue, equals(50000.0));
        expect(result.retailValue, equals(75000.0));
        expect(result.lowStockCount, equals(10));
      });
    });

    group('getHourlySales', () {
      test('returns hourly sales map', () async {
        // Arrange
        when(
          () => mockRemote.getHourlySales(any(), any()),
        ).thenAnswer((_) async => {'9': 500.0, '10': 800.0, '11': 1200.0});

        // Act
        final result = await repository.getHourlySales(
          'store-1',
          DateTime(2026, 1, 19),
        );

        // Assert
        expect(result[9], equals(500.0));
        expect(result[10], equals(800.0));
        expect(result[11], equals(1200.0));
      });
    });
  });
}
