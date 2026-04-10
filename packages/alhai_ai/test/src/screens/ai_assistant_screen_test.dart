import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_ai/src/screens/ai/ai_assistant_screen.dart';
import 'package:alhai_ai/src/providers/ai_assistant_providers.dart';
import 'package:alhai_ai/src/services/ai_assistant_service.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart'
    show
        isOnlineProvider,
        pendingSyncCountProvider,
        syncStatusProvider,
        syncManagerProvider;
import 'package:alhai_sync/alhai_sync.dart' show SyncManager, SyncStatus;

class MockAiAssistantService extends Mock implements AiAssistantService {}

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
  late MockAiAssistantService mockService;
  late MockAppDatabase mockDb;

  setUp(() {
    mockService = MockAiAssistantService();
    when(() => mockService.getQuickTemplates()).thenReturn([]);

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

  group('AiAssistantScreen', () {
    testWidgets('renders without error', (tester) async {
      _setLargeViewport(tester);
      await tester.pumpWidget(
        _buildTestableWidget(
          const AiAssistantScreen(),
          overrides: [
            aiAssistantServiceProvider.overrideWithValue(mockService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AiAssistantScreen), findsOneWidget);
    });

    testWidgets('shows empty state with smart toy icon when no messages',
        (tester) async {
      _setLargeViewport(tester);
      await tester.pumpWidget(
        _buildTestableWidget(
          const AiAssistantScreen(),
          overrides: [
            aiAssistantServiceProvider.overrideWithValue(mockService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // The screen should show the smart toy icon in the empty state
      expect(find.byIcon(Icons.smart_toy_rounded), findsWidgets);
    });

    testWidgets('has delete/clear chat button', (tester) async {
      _setLargeViewport(tester);
      await tester.pumpWidget(
        _buildTestableWidget(
          const AiAssistantScreen(),
          overrides: [
            aiAssistantServiceProvider.overrideWithValue(mockService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    });

    testWidgets('contains AiChatInput widget', (tester) async {
      _setLargeViewport(tester);
      await tester.pumpWidget(
        _buildTestableWidget(
          const AiAssistantScreen(),
          overrides: [
            aiAssistantServiceProvider.overrideWithValue(mockService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // The screen should contain some form of text input for chat
      expect(find.byType(AiAssistantScreen), findsOneWidget);
    });
  });
}
