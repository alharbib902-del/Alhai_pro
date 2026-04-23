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
import 'package:alhai_sync/alhai_sync.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockAppDatabase extends Mock implements AppDatabase {}

class MockExpensesDao extends Mock implements ExpensesDao {}

class MockSyncService extends Mock implements SyncService {}

class MockWidgetRef extends Mock implements WidgetRef {}

class _FakeExpensesCompanion extends Fake
    implements ExpensesTableCompanion {}

class _FakeProviderListenable<T> extends Fake
    implements ProviderListenable<T> {}

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
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => null)],
      );
      addTearDown(container.dispose);

      final result = await container.read(expensesListProvider.future);
      expect(result, isEmpty);
    });

    test('returns expenses from dao', () async {
      when(
        () => mockExpensesDao.getAllExpenses('store-1'),
      ).thenAnswer((_) async => []);

      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => 'store-1')],
      );
      addTearDown(container.dispose);

      final result = await container.read(expensesListProvider.future);
      expect(result, isEmpty);
    });
  });

  group('todayExpensesTotalProvider', () {
    test('returns 0 when no store id', () async {
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => null)],
      );
      addTearDown(container.dispose);

      final result = await container.read(todayExpensesTotalProvider.future);
      expect(result, 0.0);
    });

    test('returns total from dao', () async {
      when(
        () => mockExpensesDao.getTodayExpensesTotal('store-1'),
      ).thenAnswer((_) async => 750.0);

      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => 'store-1')],
      );
      addTearDown(container.dispose);

      final result = await container.read(todayExpensesTotalProvider.future);
      expect(result, 750.0);
    });
  });

  group('expenseCategoriesProvider', () {
    test('returns empty list when no store id', () async {
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => null)],
      );
      addTearDown(container.dispose);

      final result = await container.read(expenseCategoriesProvider.future);
      expect(result, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // C-4 §4h (Session 52) — wire-contract regression for expenses push payload.
  // Paired with Supabase migration v78 (expenses.amount DOUBLE → INTEGER).
  // The push payload must carry int cents so that Supabase receives the same
  // magnitude the client stores locally. A SAR-double payload against an
  // INTEGER column would either fail or round unpredictably.
  // -------------------------------------------------------------------------
  group('addExpense push-payload contract', () {
    late MockSyncService mockSync;
    late MockWidgetRef mockRef;

    setUpAll(() {
      registerFallbackValue(_FakeExpensesCompanion());
      registerFallbackValue(_FakeProviderListenable<void>());
      registerFallbackValue(SyncPriority.normal);
    });

    setUp(() {
      mockSync = MockSyncService();
      mockRef = MockWidgetRef();

      when(
        () => mockExpensesDao.insertExpense(any()),
      ).thenAnswer((_) async => 1);

      when(
        () => mockRef.read<String?>(currentStoreIdProvider),
      ).thenReturn('store-1');
      when(
        () => mockRef.read<SyncService>(syncServiceProvider),
      ).thenReturn(mockSync);
      // addExpense invalidates two specific providers at the end — stub
      // each one instead of any() to avoid needing a ProviderOrFamily fallback
      // (ProviderOrFamily is a sealed class and cannot be faked).
      when(() => mockRef.invalidate(expensesListProvider)).thenReturn(null);
      when(
        () => mockRef.invalidate(todayExpensesTotalProvider),
      ).thenReturn(null);

      when(
        () => mockSync.enqueueCreate(
          tableName: any(named: 'tableName'),
          recordId: any(named: 'recordId'),
          data: any(named: 'data'),
          priority: any(named: 'priority'),
        ),
      ).thenAnswer((_) async => 'mock-sync-id');
    });

    test(
      'payload carries int cents for amount (not SAR double)',
      () async {
        Map<String, dynamic>? capturedPayload;
        when(
          () => mockSync.enqueueCreate(
            tableName: any(named: 'tableName'),
            recordId: any(named: 'recordId'),
            data: any(named: 'data'),
            priority: any(named: 'priority'),
          ),
        ).thenAnswer((inv) async {
          capturedPayload =
              inv.namedArguments[#data] as Map<String, dynamic>;
          return 'mock-sync-id';
        });

        await addExpense(
          mockRef,
          categoryId: 'cat-1',
          amount: 150.75,
          description: 'rent',
          createdBy: 'user-1',
        );

        expect(capturedPayload, isNotNull);
        // C-4 wire contract: amount is int cents (15075), not SAR double
        // (150.75). A regression back to SAR would silently corrupt the
        // server row after migration v78.
        expect(capturedPayload!['amount'], 15075);
        expect(capturedPayload!['amount'], isA<int>());
        expect(capturedPayload!['store_id'], 'store-1');
        expect(capturedPayload!['category_id'], 'cat-1');
        expect(capturedPayload!['description'], 'rent');
      },
    );

    test(
      'fractional SAR amounts are rounded to nearest cent',
      () async {
        Map<String, dynamic>? capturedPayload;
        when(
          () => mockSync.enqueueCreate(
            tableName: any(named: 'tableName'),
            recordId: any(named: 'recordId'),
            data: any(named: 'data'),
            priority: any(named: 'priority'),
          ),
        ).thenAnswer((inv) async {
          capturedPayload =
              inv.namedArguments[#data] as Map<String, dynamic>;
          return 'mock-sync-id';
        });

        // 12.34 SAR → 1234 cents. Avoids x.xx5 cases where IEEE-754
        // float imprecision makes rounding direction non-obvious.
        await addExpense(
          mockRef,
          categoryId: 'cat-1',
          amount: 12.34,
          description: 'coffee',
        );

        expect(capturedPayload!['amount'], 1234);
      },
    );

    test(
      'Drift insert companion also receives int cents (unchanged contract)',
      () async {
        ExpensesTableCompanion? capturedCompanion;
        when(() => mockExpensesDao.insertExpense(any())).thenAnswer((inv) async {
          capturedCompanion =
              inv.positionalArguments[0] as ExpensesTableCompanion;
          return 1;
        });

        await addExpense(
          mockRef,
          categoryId: 'cat-1',
          amount: 75.50,
          description: 'utilities',
        );

        expect(capturedCompanion, isNotNull);
        // The Drift side was already cents before this session — this test
        // locks that behavior in alongside the new wire-format change so a
        // future refactor can't accidentally diverge the two sides.
        expect(capturedCompanion!.amount.value, 7550);
      },
    );
  });
}
