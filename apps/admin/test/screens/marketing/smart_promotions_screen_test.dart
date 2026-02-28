import 'dart:async';

import 'package:admin/screens/marketing/smart_promotions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late MockAppDatabase mockDb;
  late MockDiscountsDao mockDiscountsDao;
  late MockProductsDao mockProductsDao;

  setUpAll(() {
    suppressOverflowErrors();
    registerAdminFallbackValues();
  });

  setUp(() {
    mockDiscountsDao = MockDiscountsDao();
    mockProductsDao = MockProductsDao();
    mockDb = setupMockDatabase(
      discountsDao: mockDiscountsDao,
      productsDao: mockProductsDao,
    );
    setupTestGetIt(mockDb: mockDb);
  });

  tearDown(() {
    tearDownTestGetIt();
  });

  group('SmartPromotionsScreen', () {
    testWidgets('shows loading indicator initially', (tester) async {
      final completerPromos = Completer<List<dynamic>>();
      final completerProducts = Completer<List<dynamic>>();
      when(() => mockDiscountsDao.getActivePromotions(any()))
          .thenAnswer((_) => completerPromos.future.then((v) => v.cast()));
      when(() => mockProductsDao.getLowStockProducts(any()))
          .thenAnswer((_) => completerProducts.future.then((v) => v.cast()));

      await tester
          .pumpWidget(createTestWidget(const SmartPromotionsScreen()));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders three tabs', (tester) async {
      when(() => mockDiscountsDao.getActivePromotions(any()))
          .thenAnswer((_) async => []);
      when(() => mockProductsDao.getLowStockProducts(any()))
          .thenAnswer((_) async => []);

      await tester
          .pumpWidget(createTestWidget(const SmartPromotionsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(Tab), findsNWidgets(3));
      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('shows AI suggestions tab with no suggestions message',
        (tester) async {
      when(() => mockDiscountsDao.getActivePromotions(any()))
          .thenAnswer((_) async => []);
      when(() => mockProductsDao.getLowStockProducts(any()))
          .thenAnswer((_) async => []);

      await tester
          .pumpWidget(createTestWidget(const SmartPromotionsScreen()));
      await tester.pumpAndSettle();

      // First tab (AI suggestions) is active by default
      expect(find.byIcon(Icons.lightbulb_outline), findsWidgets);
    });

    testWidgets('shows suggestion cards for low stock products',
        (tester) async {
      when(() => mockDiscountsDao.getActivePromotions(any()))
          .thenAnswer((_) async => []);
      when(() => mockProductsDao.getLowStockProducts(any()))
          .thenAnswer((_) async => [
                createTestProduct(
                  id: 'p-1',
                  name: 'منتج بطيء',
                  stockQty: 2,
                  minQty: 10,
                ),
              ]);

      await tester
          .pumpWidget(createTestWidget(const SmartPromotionsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('منتج بطيء'), findsOneWidget);
    });

    testWidgets('shows active promotions tab content', (tester) async {
      final now = DateTime.now();
      final activePromotions = [
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
      when(() => mockDiscountsDao.getActivePromotions(any()))
          .thenAnswer((_) async => activePromotions);
      when(() => mockProductsDao.getLowStockProducts(any()))
          .thenAnswer((_) async => []);

      await tester
          .pumpWidget(createTestWidget(const SmartPromotionsScreen()));
      await tester.pumpAndSettle();

      // Navigate to second tab
      await tester.tap(find.byIcon(Icons.local_offer));
      await tester.pumpAndSettle();

      expect(find.text('عرض نشط'), findsOneWidget);
    });

    testWidgets('shows history tab placeholder', (tester) async {
      when(() => mockDiscountsDao.getActivePromotions(any()))
          .thenAnswer((_) async => []);
      when(() => mockProductsDao.getLowStockProducts(any()))
          .thenAnswer((_) async => []);

      await tester
          .pumpWidget(createTestWidget(const SmartPromotionsScreen()));
      await tester.pumpAndSettle();

      // Navigate to third tab
      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.history), findsWidgets);
    });
  });
}
