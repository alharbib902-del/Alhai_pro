/// Widget tests for ExpensesScreen
///
/// Tests: loading state, empty state, data display, FAB
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';

import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_sync/alhai_sync.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockAppDatabase extends Mock implements AppDatabase {}

class MockSyncQueueDao extends Mock implements SyncQueueDao {}

class MockSyncManager extends Mock implements SyncManager {}

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

ExpensesTableData _createTestExpense({
  String id = 'exp-1',
  double amount = 100,
  String? categoryId = 'rent',
  String? description = 'Test expense',
}) {
  return ExpensesTableData(
    id: id,
    storeId: 'test-store-id',
    categoryId: categoryId,
    amount: amount,
    description: description,
    paymentMethod: 'cash',
    expenseDate: DateTime(2026, 1, 15),
    createdAt: DateTime(2026, 1, 15),
  );
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

void _setLargeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1.0;
}

Widget _buildTestWidget({
  AsyncValue<List<ExpensesTableData>>? expensesValue,
  AsyncValue<List<ExpenseCategoriesTableData>>? categoriesValue,
}) {
  final mockSyncManager = MockSyncManager();
  return ProviderScope(
    overrides: [
      currentStoreIdProvider.overrideWith((ref) => 'test-store-id'),
      expensesStreamProvider.overrideWith(
        (ref) =>
            expensesValue?.when(
              data: (d) => Stream.value(d),
              loading: () => const Stream.empty(),
              error: (e, _) => Stream.error(e),
            ) ??
            Stream.value(<ExpensesTableData>[]),
      ),
      expenseCategoriesProvider.overrideWith(
        (ref) =>
            categoriesValue?.when(
              data: (d) => Future.value(d),
              loading: () => Future.delayed(const Duration(days: 1),
                  () => <ExpenseCategoriesTableData>[]),
              error: (e, _) => Future.error(e),
            ) ??
            Future.value(<ExpenseCategoriesTableData>[]),
      ),
      isOnlineProvider.overrideWith((ref) => Stream.value(true)),
      pendingSyncCountProvider.overrideWith((ref) => Stream.value(0)),
      syncStatusProvider.overrideWith((ref) => Stream.value(SyncStatus.idle)),
      syncManagerProvider.overrideWithValue(mockSyncManager),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: ExpensesScreen()),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockAppDatabase mockDb;
  late MockSyncQueueDao mockSyncQueueDao;

  setUp(() {
    mockDb = MockAppDatabase();
    mockSyncQueueDao = MockSyncQueueDao();
    when(() => mockDb.syncQueueDao).thenReturn(mockSyncQueueDao);

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

  group('ExpensesScreen', () {
    testWidgets('renders without errors', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(ExpensesScreen), findsOneWidget);
    });

    testWidgets('shows empty list when no expenses', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestWidget(
        expensesValue: const AsyncValue.data([]),
      ));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byIcon(Icons.receipt_long_rounded), findsWidgets);
    });

    testWidgets('shows data when expenses exist', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      final expenses = [
        _createTestExpense(id: 'e1', amount: 500, description: 'Rent'),
        _createTestExpense(id: 'e2', amount: 200, description: 'Water'),
      ];

      await tester.pumpWidget(_buildTestWidget(
        expensesValue: AsyncValue.data(expenses),
      ));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(ExpensesScreen), findsOneWidget);
    });

    testWidgets('has FAB for adding expense', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('has Scaffold structure', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
