/// Unit tests for notifications providers
///
/// Tests: provider definitions and data flow
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockAppDatabase extends Mock implements AppDatabase {}

class MockNotificationsDao extends Mock implements NotificationsDao {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockAppDatabase mockDb;
  late MockNotificationsDao mockNotificationsDao;

  setUp(() {
    mockDb = MockAppDatabase();
    mockNotificationsDao = MockNotificationsDao();

    when(() => mockDb.notificationsDao).thenReturn(mockNotificationsDao);

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

  group('dbNotificationsListProvider', () {
    test('returns empty list when no store id', () async {
      final container = ProviderContainer(overrides: [
        currentStoreIdProvider.overrideWith((ref) => null),
      ]);
      addTearDown(container.dispose);

      final result = await container.read(dbNotificationsListProvider.future);
      expect(result, isEmpty);
    });

    test('returns notifications from dao', () async {
      when(() => mockNotificationsDao.getAllNotifications('store-1'))
          .thenAnswer((_) async => []);

      final container = ProviderContainer(overrides: [
        currentStoreIdProvider.overrideWith((ref) => 'store-1'),
      ]);
      addTearDown(container.dispose);

      final result = await container.read(dbNotificationsListProvider.future);
      expect(result, isEmpty);
    });
  });

  group('dbUnreadNotificationsProvider', () {
    test('returns empty list when no store id', () async {
      final container = ProviderContainer(overrides: [
        currentStoreIdProvider.overrideWith((ref) => null),
      ]);
      addTearDown(container.dispose);

      final result = await container.read(dbUnreadNotificationsProvider.future);
      expect(result, isEmpty);
    });
  });

  group('dbUnreadCountProvider', () {
    test('returns 0 when no notifications', () async {
      when(() => mockNotificationsDao.getUnreadNotifications('store-1'))
          .thenAnswer((_) async => []);

      final container = ProviderContainer(overrides: [
        currentStoreIdProvider.overrideWith((ref) => 'store-1'),
      ]);
      addTearDown(container.dispose);

      final result = await container.read(dbUnreadCountProvider.future);
      expect(result, 0);
    });
  });
}
