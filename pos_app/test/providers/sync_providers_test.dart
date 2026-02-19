/// اختبارات مزودات المزامنة
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pos_app/data/local/app_database.dart';
import 'package:pos_app/data/local/daos/sync_queue_dao.dart';
import 'package:pos_app/services/connectivity_service.dart';
import 'package:pos_app/services/sync/sync_service.dart';
import 'package:pos_app/services/sync/sync_manager.dart';
import 'package:pos_app/providers/sync_providers.dart';

// ============================================================================
// MOCKS
// ============================================================================

class MockAppDatabase extends Mock implements AppDatabase {}

class MockSyncQueueDao extends Mock implements SyncQueueDao {}

class MockConnectivityService extends Mock implements ConnectivityService {}

class MockSyncService extends Mock implements SyncService {}

class MockSyncManager extends Mock implements SyncManager {}

// ============================================================================
// TESTS
// ============================================================================

void main() {
  group('Sync Providers', () {
    late MockAppDatabase mockDb;
    late MockSyncQueueDao mockSyncQueueDao;
    late MockConnectivityService mockConnectivityService;
    late MockSyncService mockSyncService;
    late MockSyncManager mockSyncManager;
    late StreamController<bool> connectivityController;
    late StreamController<int> pendingCountController;
    late StreamController<SyncStatus> statusController;

    setUp(() {
      mockDb = MockAppDatabase();
      mockSyncQueueDao = MockSyncQueueDao();
      mockConnectivityService = MockConnectivityService();
      mockSyncService = MockSyncService();
      mockSyncManager = MockSyncManager();
      connectivityController = StreamController<bool>.broadcast();
      pendingCountController = StreamController<int>.broadcast();
      statusController = StreamController<SyncStatus>.broadcast();

      when(() => mockDb.syncQueueDao).thenReturn(mockSyncQueueDao);
      when(() => mockConnectivityService.onConnectivityChanged)
          .thenAnswer((_) => connectivityController.stream);
      when(() => mockSyncService.watchPendingCount())
          .thenAnswer((_) => pendingCountController.stream);
      when(() => mockSyncManager.statusStream)
          .thenAnswer((_) => statusController.stream);
    });

    tearDown(() {
      connectivityController.close();
      pendingCountController.close();
      statusController.close();
    });

    group('isOnlineProvider', () {
      test('يُبث حالة الاتصال', () async {
        // Arrange
        final container = ProviderContainer(
          overrides: [
            connectivityServiceProvider.overrideWithValue(mockConnectivityService),
          ],
        );
        addTearDown(container.dispose);

        // Act - Listen to the provider directly
        final emissions = <AsyncValue<bool>>[];
        container.listen(isOnlineProvider, (_, value) => emissions.add(value));

        connectivityController.add(true);
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(emissions.isNotEmpty, isTrue);
      });
    });

    group('syncServiceProvider', () {
      test('يُنشئ SyncService مع SyncQueueDao', () {
        // Arrange
        final container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(mockDb),
          ],
        );
        addTearDown(container.dispose);

        // Act
        final syncService = container.read(syncServiceProvider);

        // Assert
        expect(syncService, isA<SyncService>());
      });
    });

    group('pendingSyncCountProvider', () {
      test('يُراقب عدد العناصر المعلقة', () async {
        // Arrange
        final container = ProviderContainer(
          overrides: [
            syncServiceProvider.overrideWithValue(mockSyncService),
          ],
        );
        addTearDown(container.dispose);

        // Act - Listen to the provider directly
        final emissions = <AsyncValue<int>>[];
        container.listen(pendingSyncCountProvider, (_, value) => emissions.add(value));

        pendingCountController.add(10);
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(emissions.isNotEmpty, isTrue);
      });
    });

    group('syncStatusProvider', () {
      test('يُراقب حالة المزامنة', () async {
        // Arrange
        final container = ProviderContainer(
          overrides: [
            syncManagerProvider.overrideWithValue(mockSyncManager),
          ],
        );
        addTearDown(container.dispose);

        // Act - Listen to the provider directly
        final emissions = <AsyncValue<SyncStatus>>[];
        container.listen(syncStatusProvider, (_, value) => emissions.add(value));

        statusController.add(SyncStatus.idle);
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(emissions.isNotEmpty, isTrue);
      });
    });

    group('syncNowProvider', () {
      test('يُنفذ المزامنة ويُرجع النتيجة', () async {
        // Arrange
        final expectedResult = SyncResult(
          successCount: 5,
          failedCount: 0,
          errors: [],
        );

        when(() => mockSyncManager.syncPending())
            .thenAnswer((_) async => expectedResult);

        final container = ProviderContainer(
          overrides: [
            syncManagerProvider.overrideWithValue(mockSyncManager),
          ],
        );
        addTearDown(container.dispose);

        // Act
        final result = await container.read(syncNowProvider.future);

        // Assert
        expect(result.successCount, 5);
        expect(result.failedCount, 0);
        expect(result.hasErrors, isFalse);
        verify(() => mockSyncManager.syncPending()).called(1);
      });

      test('يُعالج أخطاء المزامنة', () async {
        // Arrange
        final expectedResult = SyncResult(
          successCount: 3,
          failedCount: 2,
          errors: ['Error 1', 'Error 2'],
        );

        when(() => mockSyncManager.syncPending())
            .thenAnswer((_) async => expectedResult);

        final container = ProviderContainer(
          overrides: [
            syncManagerProvider.overrideWithValue(mockSyncManager),
          ],
        );
        addTearDown(container.dispose);

        // Act
        final result = await container.read(syncNowProvider.future);

        // Assert
        expect(result.successCount, 3);
        expect(result.failedCount, 2);
        expect(result.hasErrors, isTrue);
        expect(result.errors.length, 2);
      });
    });

    group('Provider Dependencies', () {
      test('syncServiceProvider يعتمد على appDatabaseProvider', () {
        // Arrange
        final container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(mockDb),
          ],
        );
        addTearDown(container.dispose);

        // Act & Assert - Should not throw
        expect(
          () => container.read(syncServiceProvider),
          returnsNormally,
        );
      });

      test('pendingSyncCountProvider يعتمد على syncServiceProvider', () {
        // Arrange
        final container = ProviderContainer(
          overrides: [
            syncServiceProvider.overrideWithValue(mockSyncService),
          ],
        );
        addTearDown(container.dispose);

        // Act & Assert - Should not throw
        expect(
          () => container.read(pendingSyncCountProvider),
          returnsNormally,
        );
      });
    });
  });
}
