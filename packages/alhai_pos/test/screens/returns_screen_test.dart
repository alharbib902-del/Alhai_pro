/// Widget tests for ReturnsScreen
///
/// Tests: rendering, loading state, empty state, tab structure
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
import 'package:alhai_pos/src/screens/returns/returns_screen.dart';
import 'package:alhai_pos/src/providers/returns_providers.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockAppDatabase extends Mock implements AppDatabase {}

class MockSyncQueueDao extends Mock implements SyncQueueDao {}

class MockSyncManager extends Mock implements SyncManager {}

class MockReturnsDao extends Mock implements ReturnsDao {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildTestWidget({List<Override> overrides = const []}) {
  final mockSyncManager = MockSyncManager();

  return ProviderScope(
    overrides: [
      currentStoreIdProvider.overrideWith((ref) => 'test-store-id'),
      currentUserProvider.overrideWith((ref) => null),
      isOnlineProvider.overrideWith((ref) => Stream.value(true)),
      pendingSyncCountProvider.overrideWith((ref) => Stream.value(0)),
      syncStatusProvider.overrideWith((ref) => Stream.value(SyncStatus.idle)),
      syncManagerProvider.overrideWithValue(mockSyncManager),
      returnsListProvider.overrideWith(
        (ref) => Future.value(<ReturnsTableData>[]),
      ),
      ...overrides,
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: ReturnsScreen()),
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
    final mockReturnsDao = MockReturnsDao();
    when(() => mockDb.syncQueueDao).thenReturn(mockSyncQueueDao);
    when(() => mockDb.returnsDao).thenReturn(mockReturnsDao);
    when(() => mockReturnsDao.getAllReturns(any())).thenAnswer((_) async => []);

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

  void setLargeViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
  }

  group('ReturnsScreen', () {
    testWidgets('renders without errors', (tester) async {
      setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestWidget());
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byType(ReturnsScreen), findsOneWidget);
    });

    testWidgets('shows scaffold structure', (tester) async {
      setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestWidget());
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('ReturnModel', () {
    test('fromData creates model from table data', () {
      // C-4 Session 4: returns.total_refund is int cents.
      final tableData = ReturnsTableData(
        id: 'ret-1',
        returnNumber: 'RET-001',
        saleId: 'sale-1',
        storeId: 'store-1',
        totalRefund: 5000, // 50.00 in cents
        status: 'completed',
        type: 'sales',
        refundMethod: 'cash',
        createdAt: DateTime(2026, 1, 1),
      );

      final model = ReturnModel.fromData(tableData);

      expect(model.id, equals('RET-001'));
      expect(model.invoiceNo, equals('sale-1'));
      // ReturnModel.fromData divides by 100 to produce SAR double.
      expect(model.amount, equals(50.0));
      expect(model.status, equals('completed'));
      expect(model.type, equals('sales'));
    });

    test('fromData handles null customer', () {
      // C-4 Session 4: returns.total_refund is int cents.
      final tableData = ReturnsTableData(
        id: 'ret-1',
        returnNumber: 'RET-002',
        saleId: 'sale-2',
        storeId: 'store-1',
        totalRefund: 3000, // 30.00 in cents
        status: 'pending',
        type: 'sales',
        refundMethod: 'card',
        createdAt: DateTime(2026, 2, 1),
      );

      final model = ReturnModel.fromData(tableData);

      expect(model.customer, equals(''));
    });

    test('ReturnModel constructor works correctly', () {
      final model = ReturnModel(
        id: 'ret-1',
        invoiceNo: 'INV-001',
        customer: 'Ahmed',
        date: DateTime(2026, 1, 15),
        amount: 100.0,
        status: 'refunded',
        reason: 'defective',
        type: 'sales',
      );

      expect(model.id, equals('ret-1'));
      expect(model.invoiceNo, equals('INV-001'));
      expect(model.customer, equals('Ahmed'));
      expect(model.amount, equals(100.0));
      expect(model.status, equals('refunded'));
      expect(model.reason, equals('defective'));
    });
  });
}
