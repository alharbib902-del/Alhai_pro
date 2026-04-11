/// Widget tests for CustomerDetailScreen
///
/// Tests: loading state, not-found state, data display, tabs, profile card
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';

import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockAppDatabase extends Mock implements AppDatabase {}

class MockAccountsDao extends Mock implements AccountsDao {}

class MockTransactionsDao extends Mock implements TransactionsDao {}

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

AccountsTableData _createTestAccount({
  String id = 'acc-1',
  String name = 'Ahmad Ali',
  String? phone = '0501234567',
  double balance = 500,
  double creditLimit = 5000,
}) {
  return AccountsTableData(
    id: id,
    storeId: 'test-store-id',
    type: 'receivable',
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
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1.0;
}

Widget _buildTestWidget({String? customerId}) {
  return ProviderScope(
    overrides: [currentStoreIdProvider.overrideWith((ref) => 'test-store-id')],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: CustomerDetailScreen(customerId: customerId)),
    ),
  );
}

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

  final originalOnError = FlutterError.onError;
  setUp(() {
    FlutterError.onError = (details) {
      if (details.toString().contains('overflowed')) return;
      originalOnError?.call(details);
    };
  });
  tearDown(() {
    FlutterError.onError = originalOnError;
    final getIt = GetIt.instance;
    if (getIt.isRegistered<AppDatabase>()) {
      getIt.unregister<AppDatabase>();
    }
  });

  group('CustomerDetailScreen', () {
    testWidgets('renders without errors when no customerId', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(CustomerDetailScreen), findsOneWidget);
    });

    testWidgets('shows customer not found when account is null', (
      tester,
    ) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      when(
        () => mockAccountsDao.getAccountById('missing-id'),
      ).thenAnswer((_) async => null);
      when(
        () => mockTransactionsDao.getAccountTransactions('missing-id'),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(_buildTestWidget(customerId: 'missing-id'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byIcon(Icons.person_off_outlined), findsOneWidget);
    });

    testWidgets('shows customer data when account exists', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      final testAccount = _createTestAccount();
      when(
        () => mockAccountsDao.getAccountById('acc-1'),
      ).thenAnswer((_) async => testAccount);
      when(
        () => mockTransactionsDao.getAccountTransactions('acc-1'),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(_buildTestWidget(customerId: 'acc-1'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Ahmad Ali'), findsWidgets);
    });

    testWidgets('has TabBar with 4 tabs', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      final testAccount = _createTestAccount();
      when(
        () => mockAccountsDao.getAccountById('acc-1'),
      ).thenAnswer((_) async => testAccount);
      when(
        () => mockTransactionsDao.getAccountTransactions('acc-1'),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(_buildTestWidget(customerId: 'acc-1'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byType(Tab), findsNWidgets(4));
    });

    testWidgets('shows refresh button', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      final testAccount = _createTestAccount();
      when(
        () => mockAccountsDao.getAccountById('acc-1'),
      ).thenAnswer((_) async => testAccount);
      when(
        () => mockTransactionsDao.getAccountTransactions('acc-1'),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(_buildTestWidget(customerId: 'acc-1'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
    });
  });
}
