import 'dart:async';

import 'package:admin/screens/marketing/special_offers_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late MockAppDatabase mockDb;
  late MockDiscountsDao mockDiscountsDao;

  setUpAll(() {
    suppressOverflowErrors();
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

  group('SpecialOffersScreen', () {
    testWidgets('shows loading indicator initially', (tester) async {
      final completer = Completer<List<dynamic>>();
      when(() => mockDiscountsDao.getAllPromotions(any()))
          .thenAnswer((_) => completer.future.then((v) => v.cast()));

      await tester.pumpWidget(createTestWidget(const SpecialOffersScreen()));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when no promotions', (tester) async {
      when(() => mockDiscountsDao.getAllPromotions(any()))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget(const SpecialOffersScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(SpecialOffersScreen), findsOneWidget);
    });

    testWidgets('displays promotions list when data is available',
        (tester) async {
      final now = DateTime.now();
      final promotions = [
        PromotionsTableData(
          id: 'promo-1',
          storeId: 'test-store-1',
          name: 'عرض البنطلون',
          nameEn: 'Pants Sale',
          type: 'flash_sale',
          rules: '{}',
          startDate: now,
          endDate: now.add(const Duration(days: 30)),
          isActive: true,
          createdAt: now,
        ),
      ];
      when(() => mockDiscountsDao.getAllPromotions(any()))
          .thenAnswer((_) async => promotions);

      await tester.pumpWidget(createTestWidget(const SpecialOffersScreen()));
      await tester.pumpAndSettle();

      expect(find.text('عرض البنطلون'), findsOneWidget);
    });

    testWidgets('displays stat cards with counts', (tester) async {
      final now = DateTime.now();
      final promotions = [
        PromotionsTableData(
          id: 'promo-1',
          storeId: 'test-store-1',
          name: 'عرض 1',
          type: 'bundle',
          rules: '{}',
          startDate: now,
          endDate: now.add(const Duration(days: 30)),
          isActive: true,
          createdAt: now,
        ),
        PromotionsTableData(
          id: 'promo-2',
          storeId: 'test-store-1',
          name: 'عرض 2',
          type: 'buy_x_get_y',
          rules: '{}',
          startDate: now.subtract(const Duration(days: 60)),
          endDate: now.subtract(const Duration(days: 1)),
          isActive: false,
          createdAt: now.subtract(const Duration(days: 60)),
        ),
      ];
      when(() => mockDiscountsDao.getAllPromotions(any()))
          .thenAnswer((_) async => promotions);

      await tester.pumpWidget(createTestWidget(const SpecialOffersScreen()));
      await tester.pumpAndSettle();

      // Total: 2
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('contains switch for toggling promotion state', (tester) async {
      final now = DateTime.now();
      final promotions = [
        PromotionsTableData(
          id: 'promo-1',
          storeId: 'test-store-1',
          name: 'عرض نشط',
          type: 'flash_sale',
          rules: '{}',
          startDate: now,
          endDate: now.add(const Duration(days: 30)),
          isActive: true,
          createdAt: now,
        ),
      ];
      when(() => mockDiscountsDao.getAllPromotions(any()))
          .thenAnswer((_) async => promotions);

      await tester.pumpWidget(createTestWidget(const SpecialOffersScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('shows type-specific icon for promotions', (tester) async {
      final now = DateTime.now();
      final promotions = [
        PromotionsTableData(
          id: 'promo-1',
          storeId: 'test-store-1',
          name: 'عرض فلاش',
          type: 'flash_sale',
          rules: '{}',
          startDate: now,
          endDate: now.add(const Duration(days: 30)),
          isActive: true,
          createdAt: now,
        ),
      ];
      when(() => mockDiscountsDao.getAllPromotions(any()))
          .thenAnswer((_) async => promotions);

      await tester.pumpWidget(createTestWidget(const SpecialOffersScreen()));
      await tester.pumpAndSettle();

      // flash_sale uses Icons.flash_on
      expect(find.byIcon(Icons.flash_on), findsOneWidget);
    });
  });
}
