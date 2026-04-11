/// Unit tests for sync providers
///
/// Tests: provider registration and basic behavior
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_sync/alhai_sync.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockAppDatabase extends Mock implements AppDatabase {}

class MockSyncQueueDao extends Mock implements SyncQueueDao {}

class MockSyncMetadataDao extends Mock implements SyncMetadataDao {}

class MockStockDeltasDao extends Mock implements StockDeltasDao {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockAppDatabase mockDb;
  late MockSyncQueueDao mockSyncQueueDao;
  late MockSyncMetadataDao mockSyncMetadataDao;
  late MockStockDeltasDao mockStockDeltasDao;

  setUp(() {
    mockDb = MockAppDatabase();
    mockSyncQueueDao = MockSyncQueueDao();
    mockSyncMetadataDao = MockSyncMetadataDao();
    mockStockDeltasDao = MockStockDeltasDao();

    when(() => mockDb.syncQueueDao).thenReturn(mockSyncQueueDao);
    when(() => mockDb.syncMetadataDao).thenReturn(mockSyncMetadataDao);
    when(() => mockDb.stockDeltasDao).thenReturn(mockStockDeltasDao);

    final getIt = GetIt.instance;
    if (getIt.isRegistered<AppDatabase>()) {
      getIt.unregister<AppDatabase>();
    }
    getIt.registerSingleton<AppDatabase>(mockDb);
  });

  tearDown(() {
    final getIt = GetIt.instance;
    if (getIt.isRegistered<AppDatabase>()) {
      getIt.unregister<AppDatabase>();
    }
  });

  group('appDatabaseProvider', () {
    test('provides AppDatabase from GetIt', () {
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => 'store-1')],
      );
      addTearDown(container.dispose);

      final db = container.read(appDatabaseProvider);
      expect(db, isNotNull);
      expect(db, isA<AppDatabase>());
    });
  });

  group('syncServiceProvider', () {
    test('provides SyncService', () {
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => 'store-1')],
      );
      addTearDown(container.dispose);

      final service = container.read(syncServiceProvider);
      expect(service, isNotNull);
      expect(service, isA<SyncService>());
    });
  });

  group('syncApiServiceProvider', () {
    test('returns null when SupabaseClient not registered', () {
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => 'store-1')],
      );
      addTearDown(container.dispose);

      // SupabaseClient is not registered in GetIt, so should return null
      final api = container.read(syncApiServiceProvider);
      expect(api, isNull);
    });
  });
}
