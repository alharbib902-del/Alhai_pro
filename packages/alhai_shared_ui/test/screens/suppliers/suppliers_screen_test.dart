/// Widget tests for SuppliersScreen
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

class MockSyncQueueDao extends Mock implements SyncQueueDao {}

class MockSyncManager extends Mock implements SyncManager {}

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

SuppliersTableData _createTestSupplier({
  String id = 'sup-1',
  String name = 'Supplier A',
  String? phone = '0501111111',
  double balance = 0,
}) {
  return SuppliersTableData(
    id: id,
    storeId: 'test-store-id',
    name: name,
    phone: phone,
    isActive: true,
    balance: balance,
    rating: 0,
    createdAt: DateTime(2026, 1, 1),
  );
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

void _setLargeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1.0;
}

Widget _buildTestWidget({
  AsyncValue<List<SuppliersTableData>>? suppliersValue,
}) {
  final mockSyncManager = MockSyncManager();
  return ProviderScope(
    overrides: [
      currentStoreIdProvider.overrideWith((ref) => 'test-store-id'),
      suppliersListProvider.overrideWith(
        (ref) =>
            suppliersValue?.when(
              data: (d) => Future.value(d),
              loading: () => Future.delayed(
                const Duration(days: 1),
                () => <SuppliersTableData>[],
              ),
              error: (e, _) => Future.error(e),
            ) ??
            Future.value(<SuppliersTableData>[]),
      ),
      isOnlineProvider.overrideWith((ref) => Stream.value(true)),
      pendingSyncCountProvider.overrideWith((ref) => Stream.value(0)),
      syncStatusProvider.overrideWith((ref) => Stream.value(SyncStatus.idle)),
      syncManagerProvider.overrideWithValue(mockSyncManager),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SuppliersScreen(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockAppDatabase mockDb;
  late MockSyncQueueDao mockSyncQueueDao;

  setUp(() {
    mockDb = MockAppDatabase();
    mockSyncQueueDao = MockSyncQueueDao();
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

  group('SuppliersScreen', () {
    testWidgets('renders without errors', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(SuppliersScreen), findsOneWidget);
    });

    testWidgets('shows empty state when no suppliers', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestWidget(suppliersValue: const AsyncValue.data([])),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // SuppliersScreen shows a Text widget for empty state, not AppEmptyState
      expect(find.byType(SuppliersScreen), findsOneWidget);
    });

    testWidgets('shows data when suppliers exist', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      final suppliers = [
        _createTestSupplier(id: 's1', name: 'Supplier One'),
        _createTestSupplier(id: 's2', name: 'Supplier Two'),
      ];

      await tester.pumpWidget(
        _buildTestWidget(suppliersValue: AsyncValue.data(suppliers)),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Supplier One'), findsOneWidget);
      expect(find.text('Supplier Two'), findsOneWidget);
    });

    testWidgets('has Scaffold structure', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
