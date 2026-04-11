/// Unit tests for suppliers providers
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

class MockSuppliersDao extends Mock implements SuppliersDao {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockAppDatabase mockDb;
  late MockSuppliersDao mockSuppliersDao;

  setUp(() {
    mockDb = MockAppDatabase();
    mockSuppliersDao = MockSuppliersDao();

    when(() => mockDb.suppliersDao).thenReturn(mockSuppliersDao);

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

  group('suppliersListProvider', () {
    test('returns empty list when no store id', () async {
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => null)],
      );
      addTearDown(container.dispose);

      final result = await container.read(suppliersListProvider.future);
      expect(result, isEmpty);
    });

    test('returns suppliers from dao', () async {
      when(
        () => mockSuppliersDao.getAllSuppliers('store-1'),
      ).thenAnswer((_) async => []);

      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => 'store-1')],
      );
      addTearDown(container.dispose);

      final result = await container.read(suppliersListProvider.future);
      expect(result, isEmpty);
    });
  });

  group('activeSuppliersProvider', () {
    test('returns empty list when no store id', () async {
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => null)],
      );
      addTearDown(container.dispose);

      final result = await container.read(activeSuppliersProvider.future);
      expect(result, isEmpty);
    });
  });

  group('supplierDetailProvider', () {
    test('returns supplier when found', () async {
      final supplier = SuppliersTableData(
        id: 'sup-1',
        storeId: 'store-1',
        name: 'Test Supplier',
        isActive: true,
        balance: 0,
        rating: 0,
        createdAt: DateTime(2026, 1, 1),
      );
      when(
        () => mockSuppliersDao.getSupplierById('sup-1'),
      ).thenAnswer((_) async => supplier);

      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => 'store-1')],
      );
      addTearDown(container.dispose);

      final result = await container.read(
        supplierDetailProvider('sup-1').future,
      );
      expect(result, isNotNull);
      expect(result?.name, 'Test Supplier');
    });

    test('returns null when not found', () async {
      when(
        () => mockSuppliersDao.getSupplierById('missing'),
      ).thenAnswer((_) async => null);

      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => 'store-1')],
      );
      addTearDown(container.dispose);

      final result = await container.read(
        supplierDetailProvider('missing').future,
      );
      expect(result, isNull);
    });
  });

  group('supplierSearchProvider', () {
    test('returns empty list for empty query', () async {
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => 'store-1')],
      );
      addTearDown(container.dispose);

      final result = await container.read(supplierSearchProvider('').future);
      expect(result, isEmpty);
    });
  });
}
