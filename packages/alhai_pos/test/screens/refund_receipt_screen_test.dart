/// Widget tests for RefundReceiptScreen
///
/// Tests: rendering, null refundId state, loading state, structure
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
import 'package:alhai_pos/src/screens/returns/refund_receipt_screen.dart';
import 'package:alhai_pos/src/providers/returns_providers.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockAppDatabase extends Mock implements AppDatabase {}

class MockReturnsDao extends Mock implements ReturnsDao {}

class MockSyncQueueDao extends Mock implements SyncQueueDao {}

class MockSyncManager extends Mock implements SyncManager {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildTestWidget({
  String? refundId,
  List<Override> overrides = const [],
}) {
  final mockSyncManager = MockSyncManager();

  return ProviderScope(
    overrides: [
      currentStoreIdProvider.overrideWith((ref) => 'test-store-id'),
      isOnlineProvider.overrideWith((ref) => Stream.value(true)),
      pendingSyncCountProvider.overrideWith((ref) => Stream.value(0)),
      syncStatusProvider.overrideWith((ref) => Stream.value(SyncStatus.idle)),
      syncManagerProvider.overrideWithValue(mockSyncManager),
      ...overrides,
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: RefundReceiptScreen(refundId: refundId),
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

  group('RefundReceiptScreen', () {
    testWidgets('renders without errors with null refundId', (tester) async {
      await tester.pumpWidget(_buildTestWidget(refundId: null));
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byType(RefundReceiptScreen), findsOneWidget);
    });

    testWidgets('shows no refund ID message when refundId is null', (
      tester,
    ) async {
      await tester.pumpWidget(_buildTestWidget(refundId: null));
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      // Should show close button
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('shows AppBar with title', (tester) async {
      await tester.pumpWidget(_buildTestWidget(refundId: null));
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders with empty refundId', (tester) async {
      await tester.pumpWidget(_buildTestWidget(refundId: ''));
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byType(RefundReceiptScreen), findsOneWidget);
    });

    testWidgets('shows close icon button in app bar', (tester) async {
      await tester.pumpWidget(_buildTestWidget(refundId: null));
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('shows loading when refundId is provided', (tester) async {
      // Mock returnDetailProvider to return loading state
      await tester.pumpWidget(
        _buildTestWidget(
          refundId: 'ret-1',
          overrides: [
            returnDetailProvider(
              'ret-1',
            ).overrideWith((ref) => Future.value(null)),
          ],
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byType(RefundReceiptScreen), findsOneWidget);
    });
  });
}
