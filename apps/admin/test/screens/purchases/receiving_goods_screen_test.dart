import 'dart:async';

import 'package:admin/screens/purchases/receiving_goods_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';

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

  group('ReceivingGoodsScreen', () {
    testWidgets('shows loading indicator initially', (tester) async {
      final completer = Completer<PurchasesTableData?>();
      when(
        () => mockPurchasesDao.getPurchaseById(any()),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        createTestWidget(const ReceivingGoodsScreen(purchaseId: 'pur-1')),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error when purchase not found', (tester) async {
      when(
        () => mockPurchasesDao.getPurchaseById('pur-1'),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(
        createTestWidget(const ReceivingGoodsScreen(purchaseId: 'pur-1')),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsWidgets);
    });

    testWidgets('displays receiving form when purchase is loaded', (
      tester,
    ) async {
      final purchase = createTestPurchase(
        id: 'pur-1',
        status: 'approved',
        purchaseNumber: 'PUR-001',
      );
      when(
        () => mockPurchasesDao.getPurchaseById('pur-1'),
      ).thenAnswer((_) async => purchase);
      when(
        () => mockPurchasesDao.getPurchaseItems('pur-1'),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(
        createTestWidget(const ReceivingGoodsScreen(purchaseId: 'pur-1')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ReceivingGoodsScreen), findsOneWidget);
    });

    testWidgets('shows purchase number in content', (tester) async {
      final purchase = createTestPurchase(
        id: 'pur-1',
        status: 'approved',
        purchaseNumber: 'PUR-TEST-001',
      );
      when(
        () => mockPurchasesDao.getPurchaseById('pur-1'),
      ).thenAnswer((_) async => purchase);
      when(
        () => mockPurchasesDao.getPurchaseItems('pur-1'),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(
        createTestWidget(const ReceivingGoodsScreen(purchaseId: 'pur-1')),
      );
      await tester.pumpAndSettle();

      expect(find.text('PUR-TEST-001'), findsWidgets);
    });
  });
}
