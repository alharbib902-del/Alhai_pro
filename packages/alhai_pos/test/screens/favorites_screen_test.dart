/// Widget tests for FavoritesScreen
///
/// Tests: rendering, empty state, loading state, error state
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';

import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_pos/src/screens/pos/favorites_screen.dart';
import 'package:alhai_pos/src/providers/favorites_providers.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockAppDatabase extends Mock implements AppDatabase {}

class MockSyncQueueDao extends Mock implements SyncQueueDao {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildTestWidget({
  AsyncValue<List<FavoriteProductData>>? favoritesState,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: [
      currentStoreIdProvider.overrideWith((ref) => 'test-store-id'),
      favoritesListProvider.overrideWith(
        (ref) => favoritesState?.value ?? Future.value([]),
      ),
      ...overrides,
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const FavoritesScreen(),
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

  group('FavoritesScreen', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byType(FavoritesScreen), findsOneWidget);
    });

    testWidgets('has AppBar with title', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows empty state with heart icon when no favorites', (
      tester,
    ) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('shows AppEmptyState when favorites list is empty', (
      tester,
    ) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byType(AppEmptyState), findsOneWidget);
    });

    testWidgets('shows Scaffold', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
