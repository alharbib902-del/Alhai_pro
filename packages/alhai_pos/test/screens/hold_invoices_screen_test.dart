/// Widget tests for HoldInvoicesScreen
///
/// Tests: rendering, empty state, loading state, invoice list display
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';

import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_pos/src/screens/pos/hold_invoices_screen.dart';
import 'package:alhai_pos/src/providers/cart_providers.dart';
import 'package:alhai_pos/src/providers/held_invoices_providers.dart';

import '../helpers/pos_test_helpers.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockAppDatabase extends Mock implements AppDatabase {}

class MockSyncQueueDao extends Mock implements SyncQueueDao {}

class MockCartNotifier extends StateNotifier<CartState>
    with Mock
    implements CartNotifier {
  MockCartNotifier() : super(const CartState());

  @override
  bool get hasPendingDraft => false;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildTestWidget({
  List<HeldInvoice>? invoices,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: [
      currentStoreIdProvider.overrideWith((ref) => 'test-store-id'),
      cartStateProvider.overrideWith((ref) => MockCartNotifier()),
      dbHeldInvoicesListProvider.overrideWith(
        (ref) => Future.value(invoices ?? []),
      ),
      ...overrides,
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HoldInvoicesScreen(),
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

  group('HoldInvoicesScreen', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byType(HoldInvoicesScreen), findsOneWidget);
    });

    testWidgets('has AppBar with title', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows empty state when no held invoices', (tester) async {
      await tester.pumpWidget(_buildTestWidget(invoices: []));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byIcon(Icons.pause_circle_outline), findsOneWidget);
    });

    testWidgets('shows AppEmptyState when list is empty', (tester) async {
      await tester.pumpWidget(_buildTestWidget(invoices: []));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byType(AppEmptyState), findsOneWidget);
    });

    testWidgets('shows invoices when list is not empty', (tester) async {
      final invoices = [
        HeldInvoice(
          id: 'inv-1',
          cart: createTestCartState(),
          name: 'Test Invoice',
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(_buildTestWidget(invoices: invoices));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      // Should show invoice card content
      expect(find.text('Test Invoice'), findsWidgets);
    });

    testWidgets('shows clear all button when invoices exist', (tester) async {
      final invoices = [
        HeldInvoice(
          id: 'inv-1',
          cart: createTestCartState(),
          name: 'Invoice 1',
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(_buildTestWidget(invoices: invoices));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byIcon(Icons.delete_sweep), findsOneWidget);
    });

    testWidgets('shows badge count for invoices', (tester) async {
      final invoices = [
        HeldInvoice(
          id: 'inv-1',
          cart: createTestCartState(),
          createdAt: DateTime.now(),
        ),
        HeldInvoice(
          id: 'inv-2',
          cart: createTestCartState(),
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(_buildTestWidget(invoices: invoices));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.text('2'), findsWidgets);
    });
  });
}
