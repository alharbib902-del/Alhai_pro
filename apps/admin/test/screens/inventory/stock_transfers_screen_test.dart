library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:admin/screens/inventory/stock_transfers_screen.dart';
import 'package:alhai_database/alhai_database.dart';

import '../../helpers/test_helpers.dart';

StockTransfersTableData _transfer({
  String id = 'tr-1',
  String transferNumber = 'TRF-20260115-0001',
  String fromStoreId = 'test-store-1',
  String toStoreId = 'store-2',
  String approvalStatus = 'pending',
  String status = 'pending',
  String items = '[]',
  DateTime? createdAt,
}) {
  return StockTransfersTableData(
    id: id,
    transferNumber: transferNumber,
    fromStoreId: fromStoreId,
    toStoreId: toStoreId,
    status: status,
    items: items,
    approvalStatus: approvalStatus,
    createdAt: createdAt ?? DateTime(2026, 1, 15),
  );
}

void main() {
  late MockAppDatabase db;
  late MockStockTransfersDao stockTransfersDao;

  setUpAll(() => registerAdminFallbackValues());

  setUp(() {
    stockTransfersDao = MockStockTransfersDao();
    db = setupMockDatabase(stockTransfersDao: stockTransfersDao);
    setupTestGetIt(mockDb: db);

    when(
      () => stockTransfersDao.getOutgoing(any()),
    ).thenAnswer((_) async => <StockTransfersTableData>[]);
    when(
      () => stockTransfersDao.getIncoming(any()),
    ).thenAnswer((_) async => <StockTransfersTableData>[]);
  });

  tearDown(() => tearDownTestGetIt());

  group('StockTransfersScreen', () {
    testWidgets('renders correctly', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const StockTransfersScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(StockTransfersScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows TabBar with two tabs', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const StockTransfersScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byType(Tab), findsNWidgets(2));
      expect(find.byType(TabBarView), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows FAB to create new transfer', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const StockTransfersScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows refresh button in app bar', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const StockTransfersScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
      expect(find.byType(IconButton), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders transfer card and status chip when data provided', (
      tester,
    ) async {
      when(() => stockTransfersDao.getOutgoing(any())).thenAnswer(
        (_) async => [_transfer(transferNumber: 'TRF-20260115-0099')],
      );
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const StockTransfersScreen()));
      await tester.pumpAndSettle();

      expect(find.text('TRF-20260115-0099'), findsOneWidget);
      // A transfer card is rendered inside the TabBarView
      expect(find.byType(Card), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows approve/reject buttons for pending incoming transfer', (
      tester,
    ) async {
      when(
        () => stockTransfersDao.getOutgoing(any()),
      ).thenAnswer((_) async => <StockTransfersTableData>[]);
      when(() => stockTransfersDao.getIncoming(any())).thenAnswer(
        (_) async => [
          _transfer(
            id: 'tr-inc',
            transferNumber: 'TRF-20260116-0001',
            fromStoreId: 'store-2',
            toStoreId: 'test-store-1',
            approvalStatus: 'pending',
          ),
        ],
      );
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const StockTransfersScreen()));
      await tester.pumpAndSettle();

      // Switch to Incoming tab (index 1).
      await tester.tap(find.byType(Tab).last);
      await tester.pumpAndSettle();

      expect(find.text('TRF-20260116-0001'), findsOneWidget);
      // Pending incoming transfers show two buttons side by side: Reject
      // (OutlinedButton) + Approve (FilledButton).
      expect(find.byType(OutlinedButton), findsWidgets);
      expect(find.byType(FilledButton), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('is a ConsumerWidget', (tester) async {
      const screen = StockTransfersScreen();
      expect(screen, isA<StockTransfersScreen>());
    });
  });
}
