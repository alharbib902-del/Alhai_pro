import 'dart:async';

import 'package:admin/screens/purchases/purchases_list_screen.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late MockAppDatabase mockDb;
  late MockPurchasesDao mockPurchasesDao;

  setUpAll(() {
    suppressOverflowErrors();
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

  group('PurchasesListScreen', () {
    testWidgets('shows loading indicator initially', (tester) async {
      final completer1 = Completer<List<dynamic>>();
      final completer2 = Completer<List<dynamic>>();
      when(() => mockPurchasesDao.getAllPurchases(any()))
          .thenAnswer((_) => completer1.future.then((v) => v.cast()));
      when(() => mockPurchasesDao.getPurchasesByStatus(any(), any()))
          .thenAnswer((_) => completer2.future.then((v) => v.cast()));

      await tester
          .pumpWidget(createTestWidget(const PurchasesListScreen()));
      await tester.pump();

      expect(find.byType(ShimmerList), findsWidgets);
    });

    testWidgets('renders with tab bar containing 5 tabs', (tester) async {
      when(() => mockPurchasesDao.getAllPurchases(any()))
          .thenAnswer((_) async => []);
      when(() => mockPurchasesDao.getPurchasesByStatus(any(), any()))
          .thenAnswer((_) async => []);

      await tester
          .pumpWidget(createTestWidget(const PurchasesListScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byType(Tab), findsNWidgets(5));
    });

    testWidgets('shows empty state when no purchases', (tester) async {
      when(() => mockPurchasesDao.getAllPurchases(any()))
          .thenAnswer((_) async => []);
      when(() => mockPurchasesDao.getPurchasesByStatus(any(), any()))
          .thenAnswer((_) async => []);

      await tester
          .pumpWidget(createTestWidget(const PurchasesListScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    });

    testWidgets('displays purchases when data is available', (tester) async {
      final purchases = [
        createTestPurchase(
            id: 'p-1',
            purchaseNumber: 'PUR-001',
            status: 'draft',
            total: 500),
      ];
      when(() => mockPurchasesDao.getAllPurchases(any()))
          .thenAnswer((_) async => purchases);
      when(() => mockPurchasesDao.getPurchasesByStatus(any(), any()))
          .thenAnswer((_) async => []);

      await tester
          .pumpWidget(createTestWidget(const PurchasesListScreen()));
      await tester.pumpAndSettle();

      expect(find.text('PUR-001'), findsOneWidget);
    });

    testWidgets('shows FAB for new purchase order', (tester) async {
      final purchases = [
        createTestPurchase(id: 'p-1'),
      ];
      when(() => mockPurchasesDao.getAllPurchases(any()))
          .thenAnswer((_) async => purchases);
      when(() => mockPurchasesDao.getPurchasesByStatus(any(), any()))
          .thenAnswer((_) async => []);

      await tester
          .pumpWidget(createTestWidget(const PurchasesListScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('shows Arabic tab labels', (tester) async {
      when(() => mockPurchasesDao.getAllPurchases(any()))
          .thenAnswer((_) async => []);
      when(() => mockPurchasesDao.getPurchasesByStatus(any(), any()))
          .thenAnswer((_) async => []);

      await tester
          .pumpWidget(createTestWidget(const PurchasesListScreen()));
      await tester.pumpAndSettle();

      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('مسودة'), findsOneWidget);
    });
  });
}
