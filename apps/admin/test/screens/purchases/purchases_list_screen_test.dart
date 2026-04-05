import 'dart:async';

import 'package:admin/screens/purchases/purchases_list_screen.dart';
import 'package:alhai_database/alhai_database.dart';
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

  /// Stub the paginated methods used by paginatedPurchasesProvider.
  void stubPurchasesMethods({List<PurchasesTableData>? data}) {
    final items = data ?? <PurchasesTableData>[];
    when(() => mockPurchasesDao.getPurchasesPaginated(
          any(),
          offset: any(named: 'offset'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => items);
    when(() => mockPurchasesDao.getPurchasesByStatusPaginated(
          any(),
          any(),
          offset: any(named: 'offset'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => items);
    when(() => mockPurchasesDao.getPurchasesCount(any(),
        status: any(named: 'status'))).thenAnswer((_) async => items.length);
  }

  group('PurchasesListScreen', () {
    testWidgets('shows loading indicator initially', (tester) async {
      final completer1 = Completer<List<PurchasesTableData>>();
      when(() => mockPurchasesDao.getPurchasesPaginated(
            any(),
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) => completer1.future);
      when(() => mockPurchasesDao.getPurchasesCount(any(),
          status: any(named: 'status'))).thenAnswer((_) async => 0);
      when(() => mockPurchasesDao.getPurchasesByStatusPaginated(
            any(),
            any(),
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) => Completer<List<PurchasesTableData>>().future);

      await tester.pumpWidget(createTestWidget(const PurchasesListScreen()));
      await tester.pump();

      expect(find.byType(ShimmerList), findsWidgets);
    });

    testWidgets('renders with tab bar containing 5 tabs', (tester) async {
      stubPurchasesMethods();

      await tester.pumpWidget(createTestWidget(const PurchasesListScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byType(Tab), findsNWidgets(5));
    });

    testWidgets('shows empty state when no purchases', (tester) async {
      stubPurchasesMethods();

      await tester.pumpWidget(createTestWidget(const PurchasesListScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    });

    testWidgets('displays purchases when data is available', (tester) async {
      final purchases = [
        createTestPurchase(
            id: 'p-1', purchaseNumber: 'PUR-001', status: 'draft', total: 500),
      ];
      stubPurchasesMethods(data: purchases);

      await tester.pumpWidget(createTestWidget(const PurchasesListScreen()));
      await tester.pumpAndSettle();

      expect(find.text('PUR-001'), findsOneWidget);
    });

    testWidgets('shows FAB for new purchase order', (tester) async {
      final purchases = [
        createTestPurchase(id: 'p-1'),
      ];
      stubPurchasesMethods(data: purchases);

      await tester.pumpWidget(createTestWidget(const PurchasesListScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('shows Arabic tab labels', (tester) async {
      stubPurchasesMethods();

      await tester.pumpWidget(createTestWidget(const PurchasesListScreen()));
      await tester.pumpAndSettle();

      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('مسودة'), findsOneWidget);
    });
  });
}
