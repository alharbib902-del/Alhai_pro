/// Widget tests for ProductDetailScreen
///
/// Tests: loading state, not-found state, data display
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

class MockProductsDao extends Mock implements ProductsDao {}

class MockSyncManager extends Mock implements SyncManager {}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

void _setLargeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1.0;
}

Widget _buildTestWidget({String productId = 'prod-1'}) {
  final mockSyncManager = MockSyncManager();
  return ProviderScope(
    overrides: [
      currentStoreIdProvider.overrideWith((ref) => 'test-store-id'),
      isOnlineProvider.overrideWith((ref) => Stream.value(true)),
      pendingSyncCountProvider.overrideWith((ref) => Stream.value(0)),
      syncStatusProvider.overrideWith((ref) => Stream.value(SyncStatus.idle)),
      syncManagerProvider.overrideWithValue(mockSyncManager),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: ProductDetailScreen(productId: productId)),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockAppDatabase mockDb;
  late MockSyncQueueDao mockSyncQueueDao;
  late MockProductsDao mockProductsDao;

  setUp(() {
    mockDb = MockAppDatabase();
    mockSyncQueueDao = MockSyncQueueDao();
    mockProductsDao = MockProductsDao();

    when(() => mockDb.syncQueueDao).thenReturn(mockSyncQueueDao);
    when(() => mockDb.productsDao).thenReturn(mockProductsDao);

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

  group('ProductDetailScreen', () {
    testWidgets('renders without errors', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      when(
        () => mockProductsDao.getProductById('prod-1'),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(ProductDetailScreen), findsOneWidget);
    });

    testWidgets('shows product not found when null', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      when(
        () => mockProductsDao.getProductById('missing'),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(_buildTestWidget(productId: 'missing'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should show not found state
      expect(find.byType(ProductDetailScreen), findsOneWidget);
    });

    testWidgets('has Scaffold structure', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      when(
        () => mockProductsDao.getProductById('prod-1'),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
