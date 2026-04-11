import 'package:admin/providers/marketing_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';

import '../helpers/test_helpers.dart';

void main() {
  late MockAppDatabase mockDb;
  late MockDiscountsDao mockDiscountsDao;

  setUpAll(() {
    registerAdminFallbackValues();
  });

  setUp(() {
    mockDiscountsDao = MockDiscountsDao();
    mockDb = setupMockDatabase(discountsDao: mockDiscountsDao);
    setupTestGetIt(mockDb: mockDb);
  });

  tearDown(() {
    tearDownTestGetIt();
  });

  // ============================================================================
  // discountsListProvider
  // ============================================================================
  group('discountsListProvider', () {
    test('returns empty list when storeId is null', () async {
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => null)],
      );
      addTearDown(container.dispose);

      final result = await container.read(discountsListProvider.future);

      expect(result, isEmpty);
    });

    test('returns discounts from database when storeId is set', () async {
      final discounts = [
        createTestDiscount(id: 'd-1', name: 'خصم 1'),
        createTestDiscount(id: 'd-2', name: 'خصم 2'),
      ];
      when(
        () => mockDiscountsDao.getAllDiscounts('test-store-1'),
      ).thenAnswer((_) async => discounts);

      final container = ProviderContainer(
        overrides: [
          currentStoreIdProvider.overrideWith((ref) => 'test-store-1'),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(discountsListProvider.future);

      expect(result, hasLength(2));
      expect(result.first.name, 'خصم 1');
    });
  });

  // ============================================================================
  // activeDiscountsProvider
  // ============================================================================
  group('activeDiscountsProvider', () {
    test('returns empty list when storeId is null', () async {
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => null)],
      );
      addTearDown(container.dispose);

      final result = await container.read(activeDiscountsProvider.future);

      expect(result, isEmpty);
    });

    test('returns only active discounts', () async {
      final activeDiscounts = [
        createTestDiscount(id: 'd-active', isActive: true),
      ];
      when(
        () => mockDiscountsDao.getActiveDiscounts('test-store-1'),
      ).thenAnswer((_) async => activeDiscounts);

      final container = ProviderContainer(
        overrides: [
          currentStoreIdProvider.overrideWith((ref) => 'test-store-1'),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(activeDiscountsProvider.future);

      expect(result, hasLength(1));
      expect(result.first.isActive, isTrue);
    });
  });

  // ============================================================================
  // couponsListProvider
  // ============================================================================
  group('couponsListProvider', () {
    test('returns empty list when storeId is null', () async {
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => null)],
      );
      addTearDown(container.dispose);

      final result = await container.read(couponsListProvider.future);

      expect(result, isEmpty);
    });

    test('returns coupons from database', () async {
      final coupons = [
        createTestCoupon(id: 'c-1', code: 'SAVE10'),
        createTestCoupon(id: 'c-2', code: 'SAVE20'),
      ];
      when(
        () => mockDiscountsDao.getAllCoupons('test-store-1'),
      ).thenAnswer((_) async => coupons);

      final container = ProviderContainer(
        overrides: [
          currentStoreIdProvider.overrideWith((ref) => 'test-store-1'),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(couponsListProvider.future);

      expect(result, hasLength(2));
      expect(result.first.code, 'SAVE10');
    });
  });

  // ============================================================================
  // promotionsListProvider
  // ============================================================================
  group('promotionsListProvider', () {
    test('returns empty list when storeId is null', () async {
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => null)],
      );
      addTearDown(container.dispose);

      final result = await container.read(promotionsListProvider.future);

      expect(result, isEmpty);
    });
  });

  // ============================================================================
  // activePromotionsProvider
  // ============================================================================
  group('activePromotionsProvider', () {
    test('returns empty list when storeId is null', () async {
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => null)],
      );
      addTearDown(container.dispose);

      final result = await container.read(activePromotionsProvider.future);

      expect(result, isEmpty);
    });
  });
}
