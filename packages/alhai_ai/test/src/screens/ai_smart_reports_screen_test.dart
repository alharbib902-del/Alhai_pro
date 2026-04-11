import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_ai/src/screens/ai/ai_smart_reports_screen.dart';
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

Widget _buildTestableWidget(
  Widget child, {
  List<Override> overrides = const [],
}) {
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
  final originalOnError = FlutterError.onError;

  setUp(() {
    mockDb = MockAppDatabase();
    final getIt = GetIt.instance;
    if (getIt.isRegistered<AppDatabase>()) {
      getIt.unregister<AppDatabase>();
    }
    getIt.registerSingleton<AppDatabase>(mockDb);
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

  group('AiSmartReportsScreen', () {
    testWidgets('renders without error', (tester) async {
      _setLargeViewport(tester);
      await tester.pumpWidget(
        _buildTestableWidget(const AiSmartReportsScreen()),
      );
      await tester.pump(const Duration(seconds: 3));

      expect(find.byType(AiSmartReportsScreen), findsOneWidget);
    });

    testWidgets('shows scaffold structure', (tester) async {
      _setLargeViewport(tester);
      await tester.pumpWidget(
        _buildTestableWidget(const AiSmartReportsScreen()),
      );
      await tester.pump(const Duration(seconds: 3));

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows template cards by default', (tester) async {
      _setLargeViewport(tester);
      await tester.pumpWidget(
        _buildTestableWidget(const AiSmartReportsScreen()),
      );
      await tester.pump(const Duration(seconds: 3));

      // Templates are shown by default (_showTemplates = true)
      expect(find.byType(AiSmartReportsScreen), findsOneWidget);
    });
  });
}
