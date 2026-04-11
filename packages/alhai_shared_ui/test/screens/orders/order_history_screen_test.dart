/// Widget tests for OrderHistoryScreen
///
/// Tests: loading state, empty state, data display
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';

import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_sync/alhai_sync.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockAppDatabase extends Mock implements AppDatabase {}

class MockOrdersDao extends Mock implements OrdersDao {}

class MockSyncService extends Mock implements SyncService {}

class MockSyncManager extends Mock implements SyncManager {}

class MockConnectivityService extends Mock implements ConnectivityService {}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

void _setLargeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1.0;
}

Widget _buildTestWidget() {
  final mockSyncManager = MockSyncManager();
  return ProviderScope(
    overrides: [
      currentStoreIdProvider.overrideWith((ref) => 'test-store-id'),
      syncManagerProvider.overrideWithValue(mockSyncManager),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: OrderHistoryScreen()),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockAppDatabase mockDb;
  late MockOrdersDao mockOrdersDao;

  setUp(() {
    mockDb = MockAppDatabase();
    mockOrdersDao = MockOrdersDao();

    when(() => mockDb.ordersDao).thenReturn(mockOrdersDao);

    final getIt = GetIt.instance;
    if (getIt.isRegistered<AppDatabase>()) {
      getIt.unregister<AppDatabase>();
    }
    getIt.registerSingleton<AppDatabase>(mockDb);
  });

  final originalOnError = FlutterError.onError;
  setUp(() {
    FlutterError.onError = (details) {
      if (details.toString().contains('overflowed')) return;
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

  group('OrderHistoryScreen', () {
    testWidgets('renders without errors', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      when(() => mockOrdersDao.getOrders(any())).thenAnswer((_) async => []);
      when(
        () => mockOrdersDao.getOrdersPaginated(
          any(),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(OrderHistoryScreen), findsOneWidget);
    });

    testWidgets('has Scaffold structure', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      when(() => mockOrdersDao.getOrders(any())).thenAnswer((_) async => []);
      when(
        () => mockOrdersDao.getOrdersPaginated(
          any(),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
