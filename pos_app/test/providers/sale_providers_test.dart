/// اختبارات مزودات المبيعات
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pos_app/data/local/app_database.dart';
import 'package:pos_app/data/local/daos/sync_queue_dao.dart';
import 'package:pos_app/services/sale_service.dart';
import 'package:pos_app/services/sync/sync_service.dart';
import 'package:pos_app/providers/sale_providers.dart';
import 'package:pos_app/providers/sync_providers.dart';

// ============================================================================
// MOCKS
// ============================================================================

class MockAppDatabase extends Mock implements AppDatabase {}

class MockSyncQueueDao extends Mock implements SyncQueueDao {}

class MockSaleService extends Mock implements SaleService {}

class MockSyncService extends Mock implements SyncService {}

// ============================================================================
// TESTS
// ============================================================================

void main() {
  group('Sale Providers', () {
    late MockAppDatabase mockDb;
    late MockSyncQueueDao mockSyncQueueDao;
    late MockSaleService mockSaleService;
    late MockSyncService mockSyncService;

    setUp(() {
      mockDb = MockAppDatabase();
      mockSyncQueueDao = MockSyncQueueDao();
      mockSaleService = MockSaleService();
      mockSyncService = MockSyncService();

      when(() => mockDb.syncQueueDao).thenReturn(mockSyncQueueDao);
    });

    group('saleServiceProvider', () {
      test('يُنشئ SaleService مع التبعيات الصحيحة', () {
        // Arrange
        final container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(mockDb),
            syncServiceProvider.overrideWithValue(mockSyncService),
          ],
        );
        addTearDown(container.dispose);

        // Act
        final saleService = container.read(saleServiceProvider);

        // Assert
        expect(saleService, isA<SaleService>());
      });
    });

    group('todaySalesTotalProvider', () {
      test('يُرجع إجمالي مبيعات اليوم', () async {
        // Arrange
        when(() => mockSaleService.getTodayTotal('store-1', 'cashier-1'))
            .thenAnswer((_) async => 1500.0);

        final container = ProviderContainer(
          overrides: [
            saleServiceProvider.overrideWithValue(mockSaleService),
          ],
        );
        addTearDown(container.dispose);

        // Act
        final result = await container.read(
          todaySalesTotalProvider(('store-1', 'cashier-1')).future,
        );

        // Assert
        expect(result, 1500.0);
        verify(() => mockSaleService.getTodayTotal('store-1', 'cashier-1'))
            .called(1);
      });

      test('يُرجع صفر إذا لم تكن هناك مبيعات', () async {
        // Arrange
        when(() => mockSaleService.getTodayTotal('store-1', 'cashier-1'))
            .thenAnswer((_) async => 0.0);

        final container = ProviderContainer(
          overrides: [
            saleServiceProvider.overrideWithValue(mockSaleService),
          ],
        );
        addTearDown(container.dispose);

        // Act
        final result = await container.read(
          todaySalesTotalProvider(('store-1', 'cashier-1')).future,
        );

        // Assert
        expect(result, 0.0);
      });

      test('يستخدم المعاملات الصحيحة', () async {
        // Arrange
        when(() => mockSaleService.getTodayTotal(any(), any()))
            .thenAnswer((_) async => 100.0);

        final container = ProviderContainer(
          overrides: [
            saleServiceProvider.overrideWithValue(mockSaleService),
          ],
        );
        addTearDown(container.dispose);

        // Act
        await container.read(
          todaySalesTotalProvider(('my-store', 'my-cashier')).future,
        );

        // Assert
        verify(() => mockSaleService.getTodayTotal('my-store', 'my-cashier'))
            .called(1);
      });
    });

    group('todaySalesCountProvider', () {
      test('يُرجع عدد مبيعات اليوم', () async {
        // Arrange
        when(() => mockSaleService.getTodayCount('store-1', 'cashier-1'))
            .thenAnswer((_) async => 25);

        final container = ProviderContainer(
          overrides: [
            saleServiceProvider.overrideWithValue(mockSaleService),
          ],
        );
        addTearDown(container.dispose);

        // Act
        final result = await container.read(
          todaySalesCountProvider(('store-1', 'cashier-1')).future,
        );

        // Assert
        expect(result, 25);
        verify(() => mockSaleService.getTodayCount('store-1', 'cashier-1'))
            .called(1);
      });

      test('يُرجع صفر إذا لم تكن هناك مبيعات', () async {
        // Arrange
        when(() => mockSaleService.getTodayCount('store-1', 'cashier-1'))
            .thenAnswer((_) async => 0);

        final container = ProviderContainer(
          overrides: [
            saleServiceProvider.overrideWithValue(mockSaleService),
          ],
        );
        addTearDown(container.dispose);

        // Act
        final result = await container.read(
          todaySalesCountProvider(('store-1', 'cashier-1')).future,
        );

        // Assert
        expect(result, 0);
      });

      test('يستخدم معاملات مختلفة بشكل صحيح', () async {
        // Arrange
        when(() => mockSaleService.getTodayCount('store-A', 'cashier-X'))
            .thenAnswer((_) async => 10);
        when(() => mockSaleService.getTodayCount('store-B', 'cashier-Y'))
            .thenAnswer((_) async => 20);

        final container = ProviderContainer(
          overrides: [
            saleServiceProvider.overrideWithValue(mockSaleService),
          ],
        );
        addTearDown(container.dispose);

        // Act
        final resultA = await container.read(
          todaySalesCountProvider(('store-A', 'cashier-X')).future,
        );
        final resultB = await container.read(
          todaySalesCountProvider(('store-B', 'cashier-Y')).future,
        );

        // Assert
        expect(resultA, 10);
        expect(resultB, 20);
      });
    });

    group('Provider Integration', () {
      test('saleServiceProvider يعتمد على appDatabaseProvider و syncServiceProvider',
          () {
        // Arrange
        final container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(mockDb),
            syncServiceProvider.overrideWithValue(mockSyncService),
          ],
        );
        addTearDown(container.dispose);

        // Act & Assert - Should not throw
        expect(
          () => container.read(saleServiceProvider),
          returnsNormally,
        );
      });

      test('todaySalesTotalProvider يعتمد على saleServiceProvider', () async {
        // Arrange
        when(() => mockSaleService.getTodayTotal(any(), any()))
            .thenAnswer((_) async => 100.0);

        final container = ProviderContainer(
          overrides: [
            saleServiceProvider.overrideWithValue(mockSaleService),
          ],
        );
        addTearDown(container.dispose);

        // Act & Assert - Should not throw
        await expectLater(
          container.read(todaySalesTotalProvider(('s', 'c')).future),
          completion(100.0),
        );
      });

      test('todaySalesCountProvider يعتمد على saleServiceProvider', () async {
        // Arrange
        when(() => mockSaleService.getTodayCount(any(), any()))
            .thenAnswer((_) async => 5);

        final container = ProviderContainer(
          overrides: [
            saleServiceProvider.overrideWithValue(mockSaleService),
          ],
        );
        addTearDown(container.dispose);

        // Act & Assert - Should not throw
        await expectLater(
          container.read(todaySalesCountProvider(('s', 'c')).future),
          completion(5),
        );
      });
    });

    group('Error Handling', () {
      test('todaySalesTotalProvider يُعالج الأخطاء', () async {
        // Arrange
        when(() => mockSaleService.getTodayTotal(any(), any()))
            .thenThrow(Exception('Database error'));

        final container = ProviderContainer(
          overrides: [
            saleServiceProvider.overrideWithValue(mockSaleService),
          ],
        );
        addTearDown(container.dispose);

        // Act & Assert
        await expectLater(
          container.read(todaySalesTotalProvider(('s', 'c')).future),
          throwsA(isA<Exception>()),
        );
      });

      test('todaySalesCountProvider يُعالج الأخطاء', () async {
        // Arrange
        when(() => mockSaleService.getTodayCount(any(), any()))
            .thenThrow(Exception('Database error'));

        final container = ProviderContainer(
          overrides: [
            saleServiceProvider.overrideWithValue(mockSaleService),
          ],
        );
        addTearDown(container.dispose);

        // Act & Assert
        await expectLater(
          container.read(todaySalesCountProvider(('s', 'c')).future),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
