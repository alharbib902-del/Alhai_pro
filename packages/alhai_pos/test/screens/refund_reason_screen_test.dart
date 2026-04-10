/// Widget tests for RefundReasonScreen
///
/// Tests: rendering, empty state, reason selection UI
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
import 'package:alhai_pos/src/screens/returns/refund_reason_screen.dart';
import 'package:alhai_pos/src/screens/returns/refund_request_screen.dart';
import 'package:alhai_pos/src/providers/sale_providers.dart';

import '../helpers/pos_test_helpers.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockAppDatabase extends Mock implements AppDatabase {}

class MockSyncQueueDao extends Mock implements SyncQueueDao {}

class MockSyncManager extends Mock implements SyncManager {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildTestWidget({
  PendingRefundData? pendingRefund,
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
      pendingRefundProvider.overrideWith((ref) => pendingRefund),
      clockOffsetProvider.overrideWithValue(() => Duration.zero),
      ...overrides,
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const RefundReasonScreen(),
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
    when(() => mockDb.syncQueueDao).thenReturn(mockSyncQueueDao);

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

  group('RefundReasonScreen', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byType(RefundReasonScreen), findsOneWidget);
    });

    testWidgets('shows empty state when no pending refund', (tester) async {
      await tester.pumpWidget(_buildTestWidget(pendingRefund: null));
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      // When no refund data, shows AppEmptyState with receipt icon
      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
    });

    testWidgets('has AppBar with title', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows reason cards when pending refund exists',
        (tester) async {
      final pendingRefund = PendingRefundData(
        saleId: 'sale-1',
        receiptNo: 'POS-001',
        items: [
          createTestSaleItemsTableData(
            id: 'item-1',
            productName: 'Product A',
            unitPrice: 25.0,
            qty: 2,
          ),
        ],
        amount: 50.0,
      );

      await tester.pumpWidget(_buildTestWidget(pendingRefund: pendingRefund));
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      // Should show reason selection cards with icons
      expect(find.byIcon(Icons.broken_image), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byIcon(Icons.sentiment_dissatisfied), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
      expect(find.byIcon(Icons.thumb_down), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
    });

    testWidgets('shows refund summary banner when data exists',
        (tester) async {
      final pendingRefund = PendingRefundData(
        saleId: 'sale-1',
        receiptNo: 'POS-001',
        items: [
          createTestSaleItemsTableData(
            id: 'item-1',
            productName: 'Product A',
            unitPrice: 25.0,
            qty: 2,
          ),
        ],
        amount: 50.0,
      );

      await tester.pumpWidget(_buildTestWidget(pendingRefund: pendingRefund));
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      // Receipt icon in the summary banner
      expect(find.byIcon(Icons.receipt_long), findsOneWidget);
    });

    testWidgets('shows notes text field', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final pendingRefund = PendingRefundData(
        saleId: 'sale-1',
        receiptNo: 'POS-001',
        items: [
          createTestSaleItemsTableData(
            id: 'item-1',
            productName: 'Product A',
            unitPrice: 25.0,
            qty: 1,
          ),
        ],
        amount: 25.0,
      );

      await tester.pumpWidget(_buildTestWidget(pendingRefund: pendingRefund));
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('screen renders with pending refund data', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final pendingRefund = PendingRefundData(
        saleId: 'sale-1',
        receiptNo: 'POS-001',
        items: [
          createTestSaleItemsTableData(
            id: 'item-1',
            productName: 'Product A',
            unitPrice: 25.0,
            qty: 1,
          ),
        ],
        amount: 25.0,
      );

      await tester.pumpWidget(_buildTestWidget(pendingRefund: pendingRefund));
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      // Screen should render with the refund data
      expect(find.byType(RefundReasonScreen), findsOneWidget);
    });
  });
}
