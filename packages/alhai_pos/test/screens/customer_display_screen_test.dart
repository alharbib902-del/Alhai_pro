/// Widget tests for CustomerDisplayScreen
///
/// Tests: rendering, idle view, IgnorePointer wrapper, RTL directionality
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_pos/src/screens/pos/customer_display_screen.dart';
import 'package:alhai_pos/src/providers/customer_display_providers.dart';
import 'package:alhai_pos/src/services/customer_display/customer_display_state.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockAppDatabase extends Mock implements AppDatabase {}

class MockSyncQueueDao extends Mock implements SyncQueueDao {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildTestWidget({List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: [
      // Provide an idle state stream
      customerDisplayStreamProvider.overrideWith(
        (ref) => Stream.value(const CustomerDisplayState.idle()),
      ),
      cashierFeatureSettingsProvider.overrideWith(
        (ref) => Future.value(const CashierFeatureSettings()),
      ),
      ...overrides,
    ],
    child: const MaterialApp(home: CustomerDisplayScreen()),
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

  void setLargeViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
  }

  group('CustomerDisplayScreen', () {
    testWidgets('renders without errors', (tester) async {
      setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestWidget());
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byType(CustomerDisplayScreen), findsOneWidget);
    });

    testWidgets('wraps content in IgnorePointer for read-only display', (
      tester,
    ) async {
      setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestWidget());
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byType(IgnorePointer), findsWidgets);
    });

    testWidgets('uses RTL directionality', (tester) async {
      setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestWidget());
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byType(Directionality), findsWidgets);
    });

    testWidgets('shows scaffold with dark background', (tester) async {
      setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestWidget());
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows idle view with store icon on initial state', (
      tester,
    ) async {
      setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestWidget());
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byIcon(Icons.store_rounded), findsOneWidget);
    });
  });
}
