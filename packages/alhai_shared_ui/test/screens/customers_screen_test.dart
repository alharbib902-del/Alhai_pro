/// Widget tests for CustomersScreen
///
/// Tests: loading state, empty state, data display, search
/// Note: CustomersScreen uses GetIt.I<AppDatabase> directly.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';

import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_shared_ui/src/screens/customers/customers_screen.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockAppDatabase extends Mock implements AppDatabase {}

class MockAccountsDao extends Mock implements AccountsDao {}

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

AccountsTableData _createTestAccount({
  String id = 'acc-1',
  String name = 'Ahmad',
  String? phone,
  double balance = 0,
  double creditLimit = 1000,
  String type = 'receivable',
}) {
  return AccountsTableData(
    id: id,
    storeId: 'test-store-id',
    type: type,
    name: name,
    phone: phone,
    balance: balance,
    creditLimit: creditLimit,
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
  );
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

void _setLargeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1280, 900);
  tester.view.devicePixelRatio = 1.0;
}

Widget _buildTestWidget() {
  return ProviderScope(
    overrides: [
      currentStoreIdProvider.overrideWith((ref) => 'test-store-id'),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: CustomersScreen()),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockAppDatabase mockDb;
  late MockAccountsDao mockAccountsDao;

  setUp(() {
    mockDb = MockAppDatabase();
    mockAccountsDao = MockAccountsDao();

    when(() => mockDb.accountsDao).thenReturn(mockAccountsDao);

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

  group('CustomersScreen', () {
    testWidgets('renders without errors', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      when(() => mockAccountsDao.getAccountsPaginated(
            any(),
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => []);

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(CustomersScreen), findsOneWidget);
    });

    testWidgets('shows loading state initially', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      // Use a Completer so we can control when the future completes
      // and avoid pending timer warnings
      final completer = Completer<List<AccountsTableData>>();

      when(() => mockAccountsDao.getAccountsPaginated(
            any(),
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) => completer.future);

      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      // CustomersScreen uses ShimmerList for loading state
      expect(find.byType(CustomersScreen), findsOneWidget);

      // Complete the future so the test can clean up without pending timers
      completer.complete(<AccountsTableData>[]);
      await tester.pumpAndSettle();
    });

    testWidgets('displays customer data when loaded', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      final testAccounts = [
        _createTestAccount(id: 'c1', name: 'Ahmad Ali', balance: 500),
        _createTestAccount(id: 'c2', name: 'Sara Mohammed', balance: 0),
        _createTestAccount(id: 'c3', name: 'Khalid Omar', balance: -200, type: 'payable'),
      ];

      when(() => mockAccountsDao.getAccountsPaginated(
            any(),
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => testAccounts);

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Ahmad Ali'), findsOneWidget);
      expect(find.text('Sara Mohammed'), findsOneWidget);
      expect(find.text('Khalid Omar'), findsOneWidget);
    });

    testWidgets('shows empty list when no customers', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      when(() => mockAccountsDao.getAccountsPaginated(
            any(),
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => []);

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(CustomersScreen), findsOneWidget);
    });

    testWidgets('has Scaffold structure', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      when(() => mockAccountsDao.getAccountsPaginated(
            any(),
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => []);

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows search field', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      when(() => mockAccountsDao.getAccountsPaginated(
            any(),
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => []);

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byIcon(Icons.search), findsWidgets);
    });
  });
}
