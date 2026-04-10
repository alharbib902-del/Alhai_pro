import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:drift/drift.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_auth/alhai_auth.dart';

// =============================================================================
// MOCK CLASSES
// =============================================================================

class MockAppDatabase extends Mock implements AppDatabase {}

class MockSalesDao extends Mock implements SalesDao {}

class MockSaleItemsDao extends Mock implements SaleItemsDao {}

class MockProductsDao extends Mock implements ProductsDao {}

class MockExpensesDao extends Mock implements ExpensesDao {}

class MockUsersDao extends Mock implements UsersDao {}

class MockAccountsDao extends Mock implements AccountsDao {}

class MockSelectable<T> extends Mock implements Selectable<T> {}

// =============================================================================
// FALLBACK VALUES
// =============================================================================

void registerWidgetTestFallbackValues() {
  registerFallbackValue(DateTime(2026, 1, 1));
  registerFallbackValue(Variable.withString(''));
}

// =============================================================================
// TEST APP WRAPPER
// =============================================================================

/// Wraps a widget with MaterialApp + localization + ProviderScope for testing.
/// Provides a mock storeId via currentStoreIdProvider override.
Widget buildTestableWidget(
  Widget child, {
  String? storeId = 'test-store-id',
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: [
      if (storeId != null)
        currentStoreIdProvider.overrideWith((ref) => storeId),
      ...overrides,
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ar'),
      home: child,
    ),
  );
}

// =============================================================================
// GETIT SETUP / TEARDOWN
// =============================================================================

/// Sets up a mock AppDatabase in GetIt with all DAOs stubbed to return empty
/// data by default. Returns a record of the mock database and its DAOs so
/// tests can add more specific stubs.
({
  MockAppDatabase db,
  MockSalesDao salesDao,
  MockSaleItemsDao saleItemsDao,
  MockProductsDao productsDao,
  MockExpensesDao expensesDao,
  MockUsersDao usersDao,
  MockAccountsDao accountsDao,
}) setupMockGetIt() {
  final mockDb = MockAppDatabase();
  final mockSalesDao = MockSalesDao();
  final mockSaleItemsDao = MockSaleItemsDao();
  final mockProductsDao = MockProductsDao();
  final mockExpensesDao = MockExpensesDao();
  final mockUsersDao = MockUsersDao();
  final mockAccountsDao = MockAccountsDao();

  when(() => mockDb.salesDao).thenReturn(mockSalesDao);
  when(() => mockDb.saleItemsDao).thenReturn(mockSaleItemsDao);
  when(() => mockDb.productsDao).thenReturn(mockProductsDao);
  when(() => mockDb.expensesDao).thenReturn(mockExpensesDao);
  when(() => mockDb.usersDao).thenReturn(mockUsersDao);
  when(() => mockDb.accountsDao).thenReturn(mockAccountsDao);

  // Default stubs returning empty data
  when(() => mockSalesDao.getSalesByDate(any(), any()))
      .thenAnswer((_) async => <SalesTableData>[]);

  when(() => mockSalesDao.getSalesStats(
        any(),
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
        cashierId: any(named: 'cashierId'),
      )).thenAnswer((_) async => const SalesStats(
        count: 0,
        total: 0,
        average: 0,
        maxSale: 0,
        minSale: 0,
      ));

  when(() => mockProductsDao.getAllProducts(any()))
      .thenAnswer((_) async => <ProductsTableData>[]);

  when(() => mockExpensesDao.getExpensesByDateRange(any(), any(), any()))
      .thenAnswer((_) async => <ExpensesTableData>[]);

  when(() => mockUsersDao.getAllUsers(any()))
      .thenAnswer((_) async => <UsersTableData>[]);

  when(() => mockAccountsDao.getReceivableAccounts(any()))
      .thenAnswer((_) async => <AccountsTableData>[]);

  // Register in GetIt
  final getIt = GetIt.instance;
  if (getIt.isRegistered<AppDatabase>()) {
    getIt.unregister<AppDatabase>();
  }
  getIt.registerSingleton<AppDatabase>(mockDb);

  return (
    db: mockDb,
    salesDao: mockSalesDao,
    saleItemsDao: mockSaleItemsDao,
    productsDao: mockProductsDao,
    expensesDao: mockExpensesDao,
    usersDao: mockUsersDao,
    accountsDao: mockAccountsDao,
  );
}

/// Tear down mock GetIt registration.
void teardownMockGetIt() {
  final getIt = GetIt.instance;
  if (getIt.isRegistered<AppDatabase>()) {
    getIt.unregister<AppDatabase>();
  }
}
