import 'dart:async';

import 'package:admin/screens/purchases/send_to_distributor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late MockAppDatabase mockDb;
  late MockPurchasesDao mockPurchasesDao;
  late MockSuppliersDao mockSuppliersDao;

  setUpAll(() {
    suppressOverflowErrors();
    registerAdminFallbackValues();
  });

  setUp(() {
    mockPurchasesDao = MockPurchasesDao();
    mockSuppliersDao = MockSuppliersDao();
    mockDb = setupMockDatabase(
      purchasesDao: mockPurchasesDao,
      suppliersDao: mockSuppliersDao,
    );
    setupTestGetIt(mockDb: mockDb);
  });

  tearDown(() {
    tearDownTestGetIt();
  });

  group('SendToDistributorScreen', () {
    testWidgets('shows loading indicator initially', (tester) async {
      final completer = Completer<PurchasesTableData?>();
      when(() => mockPurchasesDao.getPurchaseById(any()))
          .thenAnswer((_) => completer.future);
      when(() => mockSuppliersDao.getActiveSuppliers(any()))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget(
          const SendToDistributorScreen(purchaseId: 'pur-1')));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error when purchase not found', (tester) async {
      when(() => mockPurchasesDao.getPurchaseById('pur-1'))
          .thenAnswer((_) async => null);
      when(() => mockSuppliersDao.getActiveSuppliers(any()))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget(
          const SendToDistributorScreen(purchaseId: 'pur-1')));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsWidgets);
    });

    testWidgets('renders screen when purchase loaded', (tester) async {
      final purchase = createTestPurchase(
        id: 'pur-1',
        status: 'draft',
        purchaseNumber: 'PUR-SEND-001',
      );
      when(() => mockPurchasesDao.getPurchaseById('pur-1'))
          .thenAnswer((_) async => purchase);
      when(() => mockPurchasesDao.getPurchaseItems('pur-1'))
          .thenAnswer((_) async => []);
      when(() => mockSuppliersDao.getActiveSuppliers(any()))
          .thenAnswer((_) async => [createTestSupplier()]);

      await tester.pumpWidget(createTestWidget(
          const SendToDistributorScreen(purchaseId: 'pur-1')));
      await tester.pumpAndSettle();

      expect(find.byType(SendToDistributorScreen), findsOneWidget);
    });

    testWidgets('shows purchase number when loaded', (tester) async {
      final purchase = createTestPurchase(
        id: 'pur-1',
        status: 'draft',
        purchaseNumber: 'PUR-SEND-001',
      );
      when(() => mockPurchasesDao.getPurchaseById('pur-1'))
          .thenAnswer((_) async => purchase);
      when(() => mockPurchasesDao.getPurchaseItems('pur-1'))
          .thenAnswer((_) async => []);
      when(() => mockSuppliersDao.getActiveSuppliers(any()))
          .thenAnswer((_) async => [createTestSupplier()]);

      await tester.pumpWidget(createTestWidget(
          const SendToDistributorScreen(purchaseId: 'pur-1')));
      await tester.pumpAndSettle();

      expect(find.text('PUR-SEND-001'), findsWidgets);
    });

    testWidgets('shows send button', (tester) async {
      final purchase = createTestPurchase(
        id: 'pur-1',
        status: 'draft',
      );
      when(() => mockPurchasesDao.getPurchaseById('pur-1'))
          .thenAnswer((_) async => purchase);
      when(() => mockPurchasesDao.getPurchaseItems('pur-1'))
          .thenAnswer((_) async => []);
      when(() => mockSuppliersDao.getActiveSuppliers(any()))
          .thenAnswer((_) async => [createTestSupplier()]);

      await tester.pumpWidget(createTestWidget(
          const SendToDistributorScreen(purchaseId: 'pur-1')));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.send_rounded), findsWidgets);
    });
  });
}
