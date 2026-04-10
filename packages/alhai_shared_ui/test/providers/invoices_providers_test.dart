/// Unit tests for invoices providers
///
/// Tests: InvoiceDetailData, InvoiceStatusCounts, provider definitions
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

class MockSalesDao extends Mock implements SalesDao {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockAppDatabase mockDb;
  late MockSalesDao mockSalesDao;

  setUp(() {
    mockDb = MockAppDatabase();
    mockSalesDao = MockSalesDao();

    when(() => mockDb.salesDao).thenReturn(mockSalesDao);

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

  group('InvoiceStatusCounts', () {
    test('has correct default values', () {
      const counts = InvoiceStatusCounts();
      expect(counts.totalCount, 0);
      expect(counts.completedCount, 0);
      expect(counts.voidedCount, 0);
      expect(counts.completedTotal, 0);
      expect(counts.voidedTotal, 0);
    });

    test('can be created with custom values', () {
      const counts = InvoiceStatusCounts(
        totalCount: 10,
        completedCount: 8,
        voidedCount: 2,
        completedTotal: 5000,
        voidedTotal: 500,
      );
      expect(counts.totalCount, 10);
      expect(counts.completedCount, 8);
      expect(counts.voidedCount, 2);
      expect(counts.completedTotal, 5000);
      expect(counts.voidedTotal, 500);
    });
  });

  group('invoicesListProvider', () {
    test('returns empty list when no store id', () async {
      final container = ProviderContainer(overrides: [
        currentStoreIdProvider.overrideWith((ref) => null),
      ]);
      addTearDown(container.dispose);

      final result = await container.read(invoicesListProvider.future);
      expect(result, isEmpty);
    });

    test('returns invoices from dao', () async {
      when(() => mockSalesDao.getAllSales('store-1'))
          .thenAnswer((_) async => []);

      final container = ProviderContainer(overrides: [
        currentStoreIdProvider.overrideWith((ref) => 'store-1'),
      ]);
      addTearDown(container.dispose);

      final result = await container.read(invoicesListProvider.future);
      expect(result, isEmpty);
    });
  });

  group('invoicesStatsProvider', () {
    test('returns default stats when no store id', () async {
      final container = ProviderContainer(overrides: [
        currentStoreIdProvider.overrideWith((ref) => null),
      ]);
      addTearDown(container.dispose);

      final result = await container.read(invoicesStatsProvider.future);
      expect(result.count, 0);
      expect(result.total, 0);
    });
  });
}
