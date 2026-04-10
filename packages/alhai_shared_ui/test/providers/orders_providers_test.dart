/// Unit tests for orders providers
///
/// Tests: OrderDetailData model, provider definitions
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

class MockOrdersDao extends Mock implements OrdersDao {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockAppDatabase mockDb;
  late MockOrdersDao mockOrdersDao;

  setUp(() {
    mockDb = MockAppDatabase();
    mockOrdersDao = MockOrdersDao();

    when(() => mockDb.ordersDao).thenReturn(mockOrdersDao);

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

  group('ordersListProvider', () {
    test('returns empty list when no store id', () async {
      final container = ProviderContainer(overrides: [
        currentStoreIdProvider.overrideWith((ref) => null),
      ]);
      addTearDown(container.dispose);

      final result = await container.read(ordersListProvider.future);
      expect(result, isEmpty);
    });

    test('returns orders from dao', () async {
      when(() => mockOrdersDao.getOrders('store-1'))
          .thenAnswer((_) async => []);

      final container = ProviderContainer(overrides: [
        currentStoreIdProvider.overrideWith((ref) => 'store-1'),
      ]);
      addTearDown(container.dispose);

      final result = await container.read(ordersListProvider.future);
      expect(result, isEmpty);
    });
  });

  group('pendingOrdersCountProvider', () {
    test('returns 0 when no store id', () async {
      final container = ProviderContainer(overrides: [
        currentStoreIdProvider.overrideWith((ref) => null),
      ]);
      addTearDown(container.dispose);

      final result =
          await container.read(pendingOrdersCountProvider.future);
      expect(result, 0);
    });

    test('returns count from dao', () async {
      when(() => mockOrdersDao.getPendingOrdersCount('store-1'))
          .thenAnswer((_) async => 5);

      final container = ProviderContainer(overrides: [
        currentStoreIdProvider.overrideWith((ref) => 'store-1'),
      ]);
      addTearDown(container.dispose);

      final result =
          await container.read(pendingOrdersCountProvider.future);
      expect(result, 5);
    });
  });

  group('todayOrdersTotalProvider', () {
    test('returns 0 when no store id', () async {
      final container = ProviderContainer(overrides: [
        currentStoreIdProvider.overrideWith((ref) => null),
      ]);
      addTearDown(container.dispose);

      final result =
          await container.read(todayOrdersTotalProvider.future);
      expect(result, 0.0);
    });
  });

  group('ordersStatsProvider', () {
    test('returns empty map when no store id', () async {
      final container = ProviderContainer(overrides: [
        currentStoreIdProvider.overrideWith((ref) => null),
      ]);
      addTearDown(container.dispose);

      final result = await container.read(ordersStatsProvider.future);
      expect(result, isEmpty);
    });
  });
}
