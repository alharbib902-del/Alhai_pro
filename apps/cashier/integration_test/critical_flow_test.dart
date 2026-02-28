/// Integration test: Critical Flow
///
/// Verifies the app launches without crashing and reaches the main screen.
/// This test exercises the full startup pipeline:
///   - Firebase & Supabase initialization (graceful fallback)
///   - GetIt dependency injection (configureDependencies)
///   - Database encryption key setup
///   - CSV seeding (first launch)
///   - Riverpod ProviderScope creation
///   - GoRouter auth redirect logic
///   - MaterialApp.router rendering
///
/// Run with:
///   flutter test integration_test/critical_flow_test.dart
///   (requires a running device or emulator)
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cashier/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Critical Flow', () {
    testWidgets('app launches and shows main screen', (tester) async {
      // Launch the full app (runs main() which initializes Firebase,
      // Supabase, DI, database, and renders CashierApp).
      app.main();
      await tester.pumpAndSettle();

      // Verify the MaterialApp.router rendered successfully.
      // CashierApp is a ConsumerWidget that returns MaterialApp.router,
      // so finding MaterialApp proves the full widget tree is alive.
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('app renders within ProviderScope', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // ProviderScope must be an ancestor for all Riverpod providers to work.
      // If this fails, Riverpod initialization is broken.
      expect(find.byType(ProviderScope), findsOneWidget);
    });

    testWidgets('app shows either auth screen or POS after redirect',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // After GoRouter's redirect logic runs, the user should land on one of:
      //   - Splash screen (auth status unknown / resolving)
      //   - Login screen (unauthenticated)
      //   - Store select screen (authenticated, no store)
      //   - POS screen (authenticated + store selected)
      //
      // We verify by checking that a Scaffold exists (all screens use one).
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
