import 'dart:async';

import 'package:admin/screens/purchases/purchase_detail_screen.dart';
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

  group('PurchaseDetailScreen', () {
    testWidgets('shows loading indicator initially', (tester) async {
      final completer = Completer<PurchasesTableData?>();
      when(
        () => mockPurchasesDao.getPurchaseById(any()),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        createTestWidget(const PurchaseDetailScreen(purchaseId: 'pur-1')),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error state when purchase not found', (tester) async {
      when(
        () => mockPurchasesDao.getPurchaseById('nonexistent'),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(
        createTestWidget(const PurchaseDetailScreen(purchaseId: 'nonexistent')),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('displays purchase details when data loaded', (tester) async {
      final purchase = createTestPurchase(
        id: 'pur-1',
        purchaseNumber: 'PUR-TEST-001',
        status: 'draft',
        total: 1150.0,
      );
      when(
        () => mockPurchasesDao.getPurchaseById('pur-1'),
      ).thenAnswer((_) async => purchase);
      when(
        () => mockPurchasesDao.getPurchaseItems('pur-1'),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(
        createTestWidget(const PurchaseDetailScreen(purchaseId: 'pur-1')),
      );
      await tester.pumpAndSettle();

      expect(find.text('PUR-TEST-001'), findsWidgets);
    });

    testWidgets('shows timeline for draft status', (tester) async {
      final purchase = createTestPurchase(id: 'pur-1', status: 'draft');
      when(
        () => mockPurchasesDao.getPurchaseById('pur-1'),
      ).thenAnswer((_) async => purchase);
      when(
        () => mockPurchasesDao.getPurchaseItems('pur-1'),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(
        createTestWidget(const PurchaseDetailScreen(purchaseId: 'pur-1')),
      );
      await tester.pumpAndSettle();

      // Timeline should show status flow
      expect(find.byIcon(Icons.timeline_rounded), findsOneWidget);
    });

    testWidgets('shows send to distributor button for draft', (tester) async {
      final purchase = createTestPurchase(id: 'pur-1', status: 'draft');
      when(
        () => mockPurchasesDao.getPurchaseById('pur-1'),
      ).thenAnswer((_) async => purchase);
      when(
        () => mockPurchasesDao.getPurchaseItems('pur-1'),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(
        createTestWidget(const PurchaseDetailScreen(purchaseId: 'pur-1')),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    });

    testWidgets('shows received message for received status', (tester) async {
      final purchase = createTestPurchase(id: 'pur-1', status: 'received');
      when(
        () => mockPurchasesDao.getPurchaseById('pur-1'),
      ).thenAnswer((_) async => purchase);
      when(
        () => mockPurchasesDao.getPurchaseItems('pur-1'),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(
        createTestWidget(const PurchaseDetailScreen(purchaseId: 'pur-1')),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle_rounded), findsWidgets);
    });
  });
}
