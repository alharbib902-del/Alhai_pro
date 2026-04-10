import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_auth/src/core/monitoring/memory_monitor.dart';
import 'package:mocktail/mocktail.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('SplashScreen', () {
    late MockAppDatabase mockDb;
    late MockAuthRepository mockAuthRepo;

    setUp(() {
      mockDb = MockAppDatabase();
      mockAuthRepo = MockAuthRepository();
      when(() => mockDb.initializeFts()).thenAnswer((_) async {});

      // Register mock AppDatabase in GetIt so SplashScreen's
      // _initializeFtsInBackground doesn't crash.
      if (getIt.isRegistered<AppDatabase>()) {
        getIt.unregister<AppDatabase>();
      }
      getIt.registerSingleton<AppDatabase>(mockDb);
    });

    tearDown(() {
      if (getIt.isRegistered<AppDatabase>()) {
        getIt.unregister<AppDatabase>();
      }
    });

    Widget buildTestableWidget() {
      // GoRouter is needed because SplashScreen calls context.go()
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const SplashScreen(),
          ),
          // Catch all navigation destinations from SplashScreen
          GoRoute(
            path: '/login',
            builder: (context, state) => const Scaffold(body: Text('Login')),
          ),
          GoRoute(
            path: '/pos',
            builder: (context, state) => const Scaffold(body: Text('POS')),
          ),
          GoRoute(
            path: '/store-select',
            builder: (context, state) =>
                const Scaffold(body: Text('Store Select')),
          ),
        ],
      );

      return ProviderScope(
        overrides: [
          // Override authStateProvider so it never hits GetIt for
          // AuthRepository.
          authStateProvider.overrideWith(
            (ref) => AuthNotifier(mockAuthRepo),
          ),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ar'),
          routerConfig: router,
        ),
      );
    }

    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      expect(find.byType(SplashScreen), findsOneWidget);
      // Clean up timers
      await tester.pump(const Duration(seconds: 4));
      MemoryMonitor.instance.stopMonitoring();
    });

    testWidgets('shows loading indicator', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
      MemoryMonitor.instance.stopMonitoring();
    });

    testWidgets('displays app branding text', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      expect(find.text('Al-HAI POS'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
      MemoryMonitor.instance.stopMonitoring();
    });

    testWidgets('shows robot icon', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      expect(find.byIcon(Icons.smart_toy_rounded), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
      MemoryMonitor.instance.stopMonitoring();
    });

    testWidgets('uses green gradient background', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      // Verify there's a Container with gradient decoration
      final containers = tester.widgetList<Container>(find.byType(Container));
      final hasGradient = containers.any((c) {
        final decoration = c.decoration;
        if (decoration is BoxDecoration) {
          return decoration.gradient is LinearGradient;
        }
        return false;
      });
      expect(hasGradient, isTrue);

      // Clean up timers
      await tester.pump(const Duration(seconds: 4));
      MemoryMonitor.instance.stopMonitoring();
    });
  });
}
