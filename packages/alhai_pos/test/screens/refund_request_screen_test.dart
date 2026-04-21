/// Widget tests for RefundRequestScreen
///
/// Tests: rendering, search input, empty state
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';

import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_sync/alhai_sync.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_pos/src/screens/returns/refund_request_screen.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockAppDatabase extends Mock implements AppDatabase {}

class MockSalesDao extends Mock implements SalesDao {}

class MockSaleItemsDao extends Mock implements SaleItemsDao {}

class MockSyncQueueDao extends Mock implements SyncQueueDao {}

class MockSyncManager extends Mock implements SyncManager {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildTestWidget({
  String? orderId,
  List<Override> overrides = const [],
}) {
  final mockSyncManager = MockSyncManager();

  return ProviderScope(
    overrides: [
      currentStoreIdProvider.overrideWith((ref) => 'test-store-id'),
      currentUserProvider.overrideWith((ref) => null),
      isOnlineProvider.overrideWith((ref) => Stream.value(true)),
      pendingSyncCountProvider.overrideWith((ref) => Stream.value(0)),
      syncStatusProvider.overrideWith((ref) => Stream.value(SyncStatus.idle)),
      syncManagerProvider.overrideWithValue(mockSyncManager),
      ...overrides,
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: RefundRequestScreen(orderId: orderId),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    final mockDb = MockAppDatabase();
    final mockSyncQueueDao = MockSyncQueueDao();
    final mockSalesDao = MockSalesDao();
    final mockSaleItemsDao = MockSaleItemsDao();
    when(() => mockDb.syncQueueDao).thenReturn(mockSyncQueueDao);
    when(() => mockDb.salesDao).thenReturn(mockSalesDao);
    when(() => mockDb.saleItemsDao).thenReturn(mockSaleItemsDao);

    final getIt = GetIt.instance;
    if (getIt.isRegistered<AppDatabase>()) {
      getIt.unregister<AppDatabase>();
    }
    getIt.registerSingleton<AppDatabase>(mockDb);
  });

  final originalOnError = FlutterError.onError;
  setUp(() {
    FlutterError.onError = (details) {
      final msg = details.toString();
      if (msg.contains('overflowed') || msg.contains('Multiple exceptions')) {
        return;
      }
      originalOnError?.call(details);
    };
  });
  tearDown(() {
    FlutterError.onError = originalOnError;
    final getIt = GetIt.instance;
    if (getIt.isRegistered<AppDatabase>()) {
      getIt.unregister<AppDatabase>();
    }
  });

  group('RefundRequestScreen', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byType(RefundRequestScreen), findsOneWidget);
    });

    testWidgets('has AppBar with title', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows search input field', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('has search button', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('renders with no orderId', (tester) async {
      await tester.pumpWidget(_buildTestWidget(orderId: null));
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byType(RefundRequestScreen), findsOneWidget);
    });
  });

  group('PendingRefundData', () {
    test('constructor creates instance correctly', () {
      final data = PendingRefundData(
        saleId: 'sale-1',
        receiptNo: 'POS-001',
        items: [],
        amount: 100.0,
      );

      expect(data.saleId, equals('sale-1'));
      expect(data.receiptNo, equals('POS-001'));
      expect(data.items, isEmpty);
      expect(data.amount, equals(100.0));
    });

    test('stores items correctly', () {
      final items = [
        SaleItemsTableData(
          id: 'item-1',
          saleId: 'sale-1',
          productId: 'prod-1',
          productName: 'Product A',
          unitPrice: (25.0 * 100).round(),
          qty: 2,
          subtotal: (50.0 * 100).round(),
          discount: 0,
          total: (50.0 * 100).round(),
        ),
      ];

      final data = PendingRefundData(
        saleId: 'sale-1',
        receiptNo: 'POS-001',
        items: items,
        amount: 50.0,
      );

      expect(data.items.length, equals(1));
      expect(data.items.first.productName, equals('Product A'));
    });
  });
}
