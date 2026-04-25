/// Widget tests for CustomerAnalyticsScreen
///
/// Tests: loading state, error state, data display, period selector
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

class MockCustomersDao extends Mock implements CustomersDao {}

class MockAccountsDao extends Mock implements AccountsDao {}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

void _setLargeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1.0;
}

Widget _buildTestWidget() {
  return ProviderScope(
    overrides: [currentStoreIdProvider.overrideWith((ref) => 'test-store-id')],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const CustomerAnalyticsScreen(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockAppDatabase mockDb;
  late MockCustomersDao mockCustomersDao;
  late MockAccountsDao mockAccountsDao;

  setUp(() {
    mockDb = MockAppDatabase();
    mockCustomersDao = MockCustomersDao();
    mockAccountsDao = MockAccountsDao();

    when(() => mockDb.customersDao).thenReturn(mockCustomersDao);
    when(() => mockDb.accountsDao).thenReturn(mockAccountsDao);

    // Wave 8 (P0-33): screen now reads counts via SQL aggregates,
    // not row fetches. Default to zero so tests don't have to wire
    // every stub when they only care about a single state.
    when(
      () => mockCustomersDao.getCustomersCount(
        any(),
        activeOnly: any(named: 'activeOnly'),
      ),
    ).thenAnswer((_) async => 0);
    when(
      () => mockAccountsDao.getTotalReceivable(any()),
    ).thenAnswer((_) async => 0.0);

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

  group('CustomerAnalyticsScreen', () {
    testWidgets('shows loading state initially', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      // Wave 8 (P0-33): the screen's first await is now the SQL count,
      // not the row fetch. Hold its future to pin the loading state.
      final completer = Completer<int>();
      when(
        () => mockCustomersDao.getCustomersCount(
          any(),
          activeOnly: any(named: 'activeOnly'),
        ),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(0);
      await tester.pumpAndSettle();
    });

    testWidgets('has Scaffold with AppBar', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      final completer = Completer<int>();
      when(
        () => mockCustomersDao.getCustomersCount(
          any(),
          activeOnly: any(named: 'activeOnly'),
        ),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);

      completer.complete(0);
      await tester.pumpAndSettle();
    });

    testWidgets('shows error state on load failure', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      when(
        () => mockCustomersDao.getCustomersCount(
          any(),
          activeOnly: any(named: 'activeOnly'),
        ),
      ).thenThrow(Exception('Database error'));

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });
}
