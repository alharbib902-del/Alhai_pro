/// Widget tests for ProductsScreen
///
/// Tests: loading state, empty state, data display, search, soft-delete wiring
library;

import 'dart:ui';

import 'package:alhai_core/alhai_core.dart' hide SyncStatus;
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
// Mock
// ---------------------------------------------------------------------------

class MockAppDatabase extends Mock implements AppDatabase {}

class MockSyncQueueDao extends Mock implements SyncQueueDao {}

class MockSyncManager extends Mock implements SyncManager {}

class MockProductsDao extends Mock implements ProductsDao {}

class MockAuditLogDao extends Mock implements AuditLogDao {}

class _MockProductsNotifier extends StateNotifier<ProductsState>
    with Mock
    implements ProductsNotifier {
  _MockProductsNotifier([ProductsState? initial])
    : super(initial ?? const ProductsState());

  int loadProductsCalls = 0;

  @override
  Future<void> loadProducts({
    required String storeId,
    bool refresh = false,
  }) async {
    loadProductsCalls++;
  }
}

Product _fixtureProduct({String id = 'p1', String name = 'Test Product'}) {
  return Product(
    id: id,
    storeId: 'test-store-id',
    name: name,
    price: 1000, // cents
    stockQty: 5,
    isActive: true,
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
  ProductsState? productsState,
  bool showDeleteAction = false,
  _MockProductsNotifier? notifier,
}) {
  final mockSyncManager = MockSyncManager();
  return ProviderScope(
    overrides: [
      currentStoreIdProvider.overrideWith((ref) => 'test-store-id'),
      productsStateProvider.overrideWith(
        (ref) => notifier ?? _MockProductsNotifier(productsState),
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
      home: Scaffold(body: ProductsScreen(showDeleteAction: showDeleteAction)),
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

  group('ProductsScreen', () {
    testWidgets('renders without errors', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(ProductsScreen), findsOneWidget);
    });

    testWidgets('has Scaffold structure', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows empty state with no products', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestWidget(
          productsState: const ProductsState(products: [], isLoading: false),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(ProductsScreen), findsOneWidget);
    });

    testWidgets('shows search icon', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byIcon(Icons.search), findsWidgets);
    });
  });

  group('ProductsScreen — soft-delete wiring', () {
    testWidgets('with showDeleteAction=false, no delete icon on hover', (
      tester,
    ) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      final product = _fixtureProduct();
      await tester.pumpWidget(
        _buildTestWidget(
          productsState: ProductsState(
            products: [product],
            isLoading: false,
            hasMore: false,
          ),
          showDeleteAction: false,
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final cardFinder = find.text('Test Product').first;
      final gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(cardFinder));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
    });

    testWidgets(
      'with showDeleteAction=true, delete icon visible on hover and opens dialog',
      (tester) async {
        _setLargeViewport(tester);
        addTearDown(() => tester.view.resetPhysicalSize());

        final product = _fixtureProduct(name: 'Hover Me');
        await tester.pumpWidget(
          _buildTestWidget(
            productsState: ProductsState(
              products: [product],
              isLoading: false,
              hasMore: false,
            ),
            showDeleteAction: true,
          ),
        );
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final cardFinder = find.text('Hover Me').first;
        final gesture = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
        );
        await gesture.addPointer(location: Offset.zero);
        addTearDown(gesture.removePointer);
        await gesture.moveTo(tester.getCenter(cardFinder));
        await tester.pumpAndSettle();

        final deleteIcon = find.byIcon(Icons.delete_outline_rounded);
        expect(deleteIcon, findsWidgets);

        await tester.tap(deleteIcon.first);
        await tester.pumpAndSettle();

        // Confirmation dialog should show product name in confirmation body
        expect(find.textContaining('Hover Me'), findsWidgets);
        expect(find.byType(AlertDialog), findsOneWidget);
      },
    );

    testWidgets('cancelling the confirm dialog does not refresh list', (
      tester,
    ) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      final notifier = _MockProductsNotifier(
        ProductsState(
          products: [_fixtureProduct(name: 'Cancel Me')],
          isLoading: false,
          hasMore: false,
        ),
      );

      await tester.pumpWidget(
        _buildTestWidget(notifier: notifier, showDeleteAction: true),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final initialLoadCalls = notifier.loadProductsCalls;

      final cardFinder = find.text('Cancel Me').first;
      final gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(cardFinder));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline_rounded).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      // No additional refresh load was triggered
      expect(notifier.loadProductsCalls, initialLoadCalls);
    });
  });
}
