/// Unit tests for customers providers
///
/// Tests: customerDetailProvider, receivableAccountsProvider, totalReceivableProvider
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

class MockAccountsDao extends Mock implements AccountsDao {}

class MockTransactionsDao extends Mock implements TransactionsDao {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockAppDatabase mockDb;
  late MockAccountsDao mockAccountsDao;
  late MockTransactionsDao mockTransactionsDao;

  setUp(() {
    mockDb = MockAppDatabase();
    mockAccountsDao = MockAccountsDao();
    mockTransactionsDao = MockTransactionsDao();

    when(() => mockDb.accountsDao).thenReturn(mockAccountsDao);
    when(() => mockDb.transactionsDao).thenReturn(mockTransactionsDao);

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

  group('customerDetailProvider', () {
    test('returns account when found', () async {
      final account = AccountsTableData(
        id: 'acc-1',
        storeId: 'store-1',
        type: 'receivable',
        name: 'Ahmad',
        balance: 500,
        creditLimit: 1000,
        isActive: true,
        createdAt: DateTime(2026, 1, 1),
      );
      when(() => mockAccountsDao.getAccountById('acc-1'))
          .thenAnswer((_) async => account);

      final container = ProviderContainer(overrides: [
        currentStoreIdProvider.overrideWith((ref) => 'store-1'),
      ]);
      addTearDown(container.dispose);

      final result =
          await container.read(customerDetailProvider('acc-1').future);
      expect(result, isNotNull);
      expect(result?.name, 'Ahmad');
    });

    test('returns null when account not found', () async {
      when(() => mockAccountsDao.getAccountById('missing'))
          .thenAnswer((_) async => null);

      final container = ProviderContainer(overrides: [
        currentStoreIdProvider.overrideWith((ref) => 'store-1'),
      ]);
      addTearDown(container.dispose);

      final result =
          await container.read(customerDetailProvider('missing').future);
      expect(result, isNull);
    });
  });

  group('customerTransactionsProvider', () {
    test('returns transactions list', () async {
      when(() => mockTransactionsDao.getAccountTransactions('acc-1'))
          .thenAnswer((_) async => []);

      final container = ProviderContainer(overrides: [
        currentStoreIdProvider.overrideWith((ref) => 'store-1'),
      ]);
      addTearDown(container.dispose);

      final result =
          await container.read(customerTransactionsProvider('acc-1').future);
      expect(result, isEmpty);
    });
  });

  group('totalReceivableProvider', () {
    test('returns 0 when no store id', () async {
      final container = ProviderContainer(overrides: [
        currentStoreIdProvider.overrideWith((ref) => null),
      ]);
      addTearDown(container.dispose);

      final result = await container.read(totalReceivableProvider.future);
      expect(result, 0.0);
    });

    test('returns total from dao', () async {
      when(() => mockAccountsDao.getTotalReceivable('store-1'))
          .thenAnswer((_) async => 1500.0);

      final container = ProviderContainer(overrides: [
        currentStoreIdProvider.overrideWith((ref) => 'store-1'),
      ]);
      addTearDown(container.dispose);

      final result = await container.read(totalReceivableProvider.future);
      expect(result, 1500.0);
    });
  });
}
