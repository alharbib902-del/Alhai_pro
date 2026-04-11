import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_core/src/datasources/remote/analytics_remote_datasource.dart';
import 'package:alhai_core/src/dto/analytics/slow_moving_product_response.dart';
import 'package:alhai_core/src/dto/analytics/sales_forecast_response.dart';
import 'package:alhai_core/src/dto/analytics/smart_alert_response.dart';
import 'package:alhai_core/src/dto/analytics/reorder_suggestion_response.dart';
import 'package:alhai_core/src/exceptions/app_exception.dart';
import 'package:alhai_core/src/repositories/impl/analytics_repository_impl.dart';

// Mock class
class MockAnalyticsRemoteDataSource extends Mock
    implements AnalyticsRemoteDataSource {}

void main() {
  late AnalyticsRepositoryImpl repository;
  late MockAnalyticsRemoteDataSource mockRemote;

  // Test data
  const testSlowMovingResponse = SlowMovingProductResponse(
    productId: 'prod-1',
    productName: 'Slow Product',
    stockQty: 50,
    daysSinceLastSale: 45,
    stockValue: 2500.0,
  );

  const testForecastResponse = SalesForecastResponse(
    date: '2026-01-20',
    predictedRevenue: 8000.0,
    predictedOrders: 40,
    confidence: 0.85,
  );

  const testAlertResponse = SmartAlertResponse(
    id: 'alert-1',
    type: 'lowStock',
    title: 'Low Stock Alert',
    message: 'Product XYZ is running low',
    isRead: false,
    createdAt: '2026-01-19T10:00:00Z',
  );

  const testReorderResponse = ReorderSuggestionResponse(
    productId: 'prod-1',
    productName: 'Test Product',
    currentStock: 10,
    suggestedQuantity: 50,
    daysUntilStockout: 3,
    averageDailySales: 5.0,
    preferredSupplierId: 'sup-1',
    preferredSupplierName: 'Test Supplier',
  );

  setUp(() {
    mockRemote = MockAnalyticsRemoteDataSource();
    repository = AnalyticsRepositoryImpl(remote: mockRemote);
  });

  group('AnalyticsRepositoryImpl', () {
    group('getSlowMovingProducts', () {
      test('returns list of SlowMovingProduct', () async {
        // Arrange
        when(
          () => mockRemote.getSlowMovingProducts(
            any(),
            daysThreshold: any(named: 'daysThreshold'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => [testSlowMovingResponse]);

        // Act
        final result = await repository.getSlowMovingProducts('store-1');

        // Assert
        expect(result, hasLength(1));
        expect(result.first.productName, equals('Slow Product'));
        expect(result.first.daysSinceLastSale, equals(45));
      });

      test('throws NetworkException on connection error', () async {
        // Arrange
        when(
          () => mockRemote.getSlowMovingProducts(
            any(),
            daysThreshold: any(named: 'daysThreshold'),
            limit: any(named: 'limit'),
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.connectionError,
            requestOptions: RequestOptions(path: '/analytics'),
          ),
        );

        // Act & Assert
        expect(
          () => repository.getSlowMovingProducts('store-1'),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('getSalesForecast', () {
      test('returns list of SalesForecast', () async {
        // Arrange
        when(
          () => mockRemote.getSalesForecast(any(), days: any(named: 'days')),
        ).thenAnswer((_) async => [testForecastResponse]);

        // Act
        final result = await repository.getSalesForecast('store-1', days: 7);

        // Assert
        expect(result, hasLength(1));
        expect(result.first.predictedRevenue, equals(8000.0));
        expect(result.first.confidence, equals(0.85));
      });
    });

    group('getSmartAlerts', () {
      test('returns list of SmartAlert', () async {
        // Arrange
        when(
          () => mockRemote.getSmartAlerts(
            any(),
            unreadOnly: any(named: 'unreadOnly'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => [testAlertResponse]);

        // Act
        final result = await repository.getSmartAlerts('store-1');

        // Assert
        expect(result, hasLength(1));
        expect(result.first.title, equals('Low Stock Alert'));
        // Priority is derived from type via extension method
        expect(result.first.priority, equals(4));
      });
    });

    group('markAlertRead', () {
      test('marks alert as read successfully', () async {
        // Arrange
        when(() => mockRemote.markAlertRead(any())).thenAnswer((_) async {});

        // Act & Assert
        await expectLater(repository.markAlertRead('alert-1'), completes);
        verify(() => mockRemote.markAlertRead('alert-1')).called(1);
      });
    });

    group('getReorderSuggestions', () {
      test('returns list of ReorderSuggestion', () async {
        // Arrange
        when(
          () => mockRemote.getReorderSuggestions(
            any(),
            daysAhead: any(named: 'daysAhead'),
          ),
        ).thenAnswer((_) async => [testReorderResponse]);

        // Act
        final result = await repository.getReorderSuggestions('store-1');

        // Assert
        expect(result, hasLength(1));
        expect(result.first.suggestedQuantity, equals(50));
        expect(result.first.daysUntilStockout, equals(3));
      });
    });
  });
}
