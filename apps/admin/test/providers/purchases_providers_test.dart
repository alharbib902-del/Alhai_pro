import 'package:admin/providers/purchases_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';

import '../helpers/test_helpers.dart';

void main() {
  late MockAppDatabase mockDb;
  late MockPurchasesDao mockPurchasesDao;

  setUpAll(() {
    registerAdminFallbackValues();
  });

  setUp(() {
    mockPurchasesDao = MockPurchasesDao();
    mockDb = setupMockDatabase(purchasesDao: mockPurchasesDao);
    setupTestGetIt(mockDb: mockDb);
  });

  tearDown(() {
    tearDownTestGetIt();
  });

  // ============================================================================
  // purchasesListProvider
  // ============================================================================
  group('purchasesListProvider', () {
    test('returns empty list when storeId is null', () async {
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => null)],
      );
      addTearDown(container.dispose);

      final result = await container.read(purchasesListProvider.future);

      expect(result, isEmpty);
    });

    test('returns purchases from database when storeId is set', () async {
      final purchases = [
        createTestPurchase(id: 'p-1', status: 'draft'),
        createTestPurchase(id: 'p-2', status: 'received'),
      ];
      when(
        () => mockPurchasesDao.getAllPurchases('test-store-1'),
      ).thenAnswer((_) async => purchases);

      final container = ProviderContainer(
        overrides: [
          currentStoreIdProvider.overrideWith((ref) => 'test-store-1'),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(purchasesListProvider.future);

      expect(result, hasLength(2));
      expect(result.first.status, 'draft');
    });
  });

  // ============================================================================
  // purchasesByStatusProvider
  // ============================================================================
  group('purchasesByStatusProvider', () {
    test('returns empty list when storeId is null', () async {
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => null)],
      );
      addTearDown(container.dispose);

      final result = await container.read(
        purchasesByStatusProvider('draft').future,
      );

      expect(result, isEmpty);
    });

    test('returns filtered purchases by status', () async {
      final draftPurchases = [createTestPurchase(id: 'p-1', status: 'draft')];
      when(
        () => mockPurchasesDao.getPurchasesByStatus('test-store-1', 'draft'),
      ).thenAnswer((_) async => draftPurchases);

      final container = ProviderContainer(
        overrides: [
          currentStoreIdProvider.overrideWith((ref) => 'test-store-1'),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(
        purchasesByStatusProvider('draft').future,
      );

      expect(result, hasLength(1));
      expect(result.first.status, 'draft');
    });
  });

  // ============================================================================
  // purchaseDetailProvider
  // ============================================================================
  group('purchaseDetailProvider', () {
    test('returns null when purchase not found', () async {
      when(
        () => mockPurchasesDao.getPurchaseById('nonexistent'),
      ).thenAnswer((_) async => null);

      final container = ProviderContainer(
        overrides: [
          currentStoreIdProvider.overrideWith((ref) => 'test-store-1'),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(
        purchaseDetailProvider('nonexistent').future,
      );

      expect(result, isNull);
    });

    test('returns purchase with items when found', () async {
      final purchase = createTestPurchase(id: 'p-1', status: 'draft');
      when(
        () => mockPurchasesDao.getPurchaseById('p-1'),
      ).thenAnswer((_) async => purchase);
      when(
        () => mockPurchasesDao.getPurchaseItems('p-1'),
      ).thenAnswer((_) async => []);

      final container = ProviderContainer(
        overrides: [
          currentStoreIdProvider.overrideWith((ref) => 'test-store-1'),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(purchaseDetailProvider('p-1').future);

      expect(result, isNotNull);
      expect(result!.purchase.id, 'p-1');
      expect(result.items, isEmpty);
    });
  });

  // ============================================================================
  // PurchaseDetailData model
  // ============================================================================
  group('PurchaseDetailData', () {
    test('stores purchase and items correctly', () {
      final purchase = createTestPurchase(id: 'p-1');
      final data = PurchaseDetailData(purchase: purchase, items: const []);

      expect(data.purchase.id, 'p-1');
      expect(data.items, isEmpty);
    });
  });
}
