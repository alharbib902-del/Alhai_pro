import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_ai/src/screens/ai/ai_competitor_analysis_screen.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart'
    show
        isOnlineProvider,
        pendingSyncCountProvider,
        syncStatusProvider,
        syncManagerProvider;
import 'package:alhai_sync/alhai_sync.dart' show SyncManager, SyncStatus;

class MockAppDatabase extends Mock implements AppDatabase {}

class MockSyncManager extends Mock implements SyncManager {}

void _setLargeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1.0;
}

Widget _buildTestableWidget(Widget child,
    {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: [
      currentStoreIdProvider.overrideWith((ref) => 'test-store'),
      isOnlineProvider.overrideWith((ref) => Stream.value(true)),
      pendingSyncCountProvider.overrideWith((ref) => Stream.value(0)),
      syncStatusProvider.overrideWith((ref) => Stream.value(SyncStatus.idle)),
      syncManagerProvider.overrideWithValue(MockSyncManager()),
      ...overrides,
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ar'),
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  late MockAppDatabase mockDb;

  setUp(() {
    mockDb = MockAppDatabase();
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

  group('AiCompetitorAnalysisScreen', () {
    testWidgets('renders without error', (tester) async {
      _setLargeViewport(tester);
      await tester.pumpWidget(
        _buildTestableWidget(const AiCompetitorAnalysisScreen()),
      );
      await tester.pump(const Duration(seconds: 3));

      expect(find.byType(AiCompetitorAnalysisScreen), findsOneWidget);
    });

    testWidgets('has three tabs for price, market, and alerts', (tester) async {
      _setLargeViewport(tester);
      await tester.pumpWidget(
        _buildTestableWidget(const AiCompetitorAnalysisScreen()),
      );
      await tester.pump(const Duration(seconds: 3));

      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byType(Tab), findsNWidgets(3));
    });

    testWidgets('shows summary cards with expected icons', (tester) async {
      _setLargeViewport(tester);
      await tester.pumpWidget(
        _buildTestableWidget(const AiCompetitorAnalysisScreen()),
      );
      await tester.pump(const Duration(seconds: 3));

      // Summary cards contain these icons
      expect(find.byIcon(Icons.inventory_2_rounded), findsWidgets);
      expect(find.byIcon(Icons.trending_down_rounded), findsWidgets);
      expect(find.byIcon(Icons.trending_up_rounded), findsWidgets);
      expect(find.byIcon(Icons.percent_rounded), findsWidgets);
    });

    testWidgets('shows compare_arrows icon in price comparison tab',
        (tester) async {
      _setLargeViewport(tester);
      await tester.pumpWidget(
        _buildTestableWidget(const AiCompetitorAnalysisScreen()),
      );
      await tester.pump(const Duration(seconds: 3));

      expect(find.byIcon(Icons.compare_arrows_rounded), findsWidgets);
    });
  });
}
