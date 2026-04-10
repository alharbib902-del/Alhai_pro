/// Unit tests for expenses providers
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

class MockExpensesDao extends Mock implements ExpensesDao {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockAppDatabase mockDb;
  late MockExpensesDao mockExpensesDao;

  setUp(() {
    mockDb = MockAppDatabase();
    mockExpensesDao = MockExpensesDao();

    when(() => mockDb.expensesDao).thenReturn(mockExpensesDao);

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

  group('expensesListProvider', () {
    test('returns empty list when no store id', () async {
      final container = ProviderContainer(overrides: [
        currentStoreIdProvider.overrideWith((ref) => null),
      ]);
      addTearDown(container.dispose);

      final result = await container.read(expensesListProvider.future);
      expect(result, isEmpty);
    });

    test('returns expenses from dao', () async {
      when(() => mockExpensesDao.getAllExpenses('store-1'))
          .thenAnswer((_) async => []);

      final container = ProviderContainer(overrides: [
        currentStoreIdProvider.overrideWith((ref) => 'store-1'),
      ]);
      addTearDown(container.dispose);

      final result = await container.read(expensesListProvider.future);
      expect(result, isEmpty);
    });
  });

  group('todayExpensesTotalProvider', () {
    test('returns 0 when no store id', () async {
      final container = ProviderContainer(overrides: [
        currentStoreIdProvider.overrideWith((ref) => null),
      ]);
      addTearDown(container.dispose);

      final result = await container.read(todayExpensesTotalProvider.future);
      expect(result, 0.0);
    });

    test('returns total from dao', () async {
      when(() => mockExpensesDao.getTodayExpensesTotal('store-1'))
          .thenAnswer((_) async => 750.0);

      final container = ProviderContainer(overrides: [
        currentStoreIdProvider.overrideWith((ref) => 'store-1'),
      ]);
      addTearDown(container.dispose);

      final result = await container.read(todayExpensesTotalProvider.future);
      expect(result, 750.0);
    });
  });

  group('expenseCategoriesProvider', () {
    test('returns empty list when no store id', () async {
      final container = ProviderContainer(overrides: [
        currentStoreIdProvider.overrideWith((ref) => null),
      ]);
      addTearDown(container.dispose);

      final result = await container.read(expenseCategoriesProvider.future);
      expect(result, isEmpty);
    });
  });
}
