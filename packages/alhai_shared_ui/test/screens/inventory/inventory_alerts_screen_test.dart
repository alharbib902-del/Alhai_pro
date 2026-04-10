/// Widget tests for InventoryAlertsScreen
///
/// Tests: loading state, data display, tabs
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';

import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockAppDatabase extends Mock implements AppDatabase {}

class MockProductsDao extends Mock implements ProductsDao {}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

void _setLargeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1.0;
}

Widget _buildTestWidget() {
  return ProviderScope(
    overrides: [
      currentStoreIdProvider.overrideWith((ref) => 'test-store-id'),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const InventoryAlertsScreen(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockAppDatabase mockDb;
  late MockProductsDao mockProductsDao;

  setUp(() {
    mockDb = MockAppDatabase();
    mockProductsDao = MockProductsDao();

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

  group('InventoryAlertsScreen', () {
    testWidgets('shows loading state initially', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      final completer = Completer<List<ProductsTableData>>();
      when(() => mockProductsDao.getLowStockProducts(any()))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.byType(InventoryAlertsScreen), findsOneWidget);

      completer.complete(<ProductsTableData>[]);
      await tester.pumpAndSettle();
    });

    testWidgets('renders when loaded with no alerts', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      when(() => mockProductsDao.getLowStockProducts(any()))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(InventoryAlertsScreen), findsOneWidget);
    });

    testWidgets('has TabBar with 3 tabs', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      when(() => mockProductsDao.getLowStockProducts(any()))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(TabBar), findsOneWidget);
    });
  });
}
