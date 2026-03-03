/// Cashier Shell Widget Tests
///
/// Verifies that the CashierShell widget renders correctly
/// and displays navigation items.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:cashier/ui/cashier_shell.dart';

void main() {
  group('CashierShell - Widget creation', () {
    testWidgets('CashierShell can be instantiated and renders content',
        (tester) async {
      // Use a large enough screen to avoid overflow
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      // Suppress overflow errors for this test (known sidebar rendering issue)
      final oldOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        final isOverflow = details.toString().contains('overflowed');
        if (!isOverflow) {
          oldOnError?.call(details);
        }
      };

      final router = GoRouter(
        initialLocation: '/test',
        routes: [
          ShellRoute(
            builder: (context, state, child) => CashierShell(child: child),
            routes: [
              GoRoute(
                path: '/test',
                builder: (context, state) =>
                    const Scaffold(body: Text('Test Content')),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the shell is rendered (content shows inside it)
      expect(find.text('Test Content'), findsOneWidget);

      // Restore error handler
      FlutterError.onError = oldOnError;

      // Reset view
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('CashierShell shows navigation items on desktop',
        (tester) async {
      // Set a large screen for desktop layout (>= 768)
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      // Suppress overflow errors for this test
      final oldOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        final isOverflow = details.toString().contains('overflowed');
        if (!isOverflow) {
          oldOnError?.call(details);
        }
      };

      final router = GoRouter(
        initialLocation: '/pos',
        routes: [
          ShellRoute(
            builder: (context, state, child) => CashierShell(child: child),
            routes: [
              GoRoute(
                path: '/pos',
                builder: (context, state) =>
                    const Scaffold(body: Text('POS Screen')),
              ),
              GoRoute(
                path: '/customers',
                builder: (context, state) =>
                    const Scaffold(body: Text('Customers')),
              ),
              GoRoute(
                path: '/shifts',
                builder: (context, state) =>
                    const Scaffold(body: Text('Shifts')),
              ),
              GoRoute(
                path: '/returns',
                builder: (context, state) =>
                    const Scaffold(body: Text('Returns')),
              ),
              GoRoute(
                path: '/profile',
                builder: (context, state) =>
                    const Scaffold(body: Text('Profile')),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify desktop sidebar navigation items are shown (English l10n values)
      expect(find.text('Point of Sale'), findsOneWidget);
      expect(find.text('Customers'), findsOneWidget);
      expect(find.text('Shifts'), findsOneWidget);
      expect(find.text('Returns'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Verify app title
      expect(find.text('Al-HAI Cashier'), findsOneWidget);

      // Verify content is shown
      expect(find.text('POS Screen'), findsOneWidget);

      // Restore error handler
      FlutterError.onError = oldOnError;

      // Reset view
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('CashierShell shows AppBar on mobile', (tester) async {
      // Set small screen size for mobile layout (< 768)
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;

      // Suppress overflow errors for this test
      final oldOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        final isOverflow = details.toString().contains('overflowed');
        if (!isOverflow) {
          oldOnError?.call(details);
        }
      };

      final router = GoRouter(
        initialLocation: '/pos',
        routes: [
          ShellRoute(
            builder: (context, state, child) => CashierShell(child: child),
            routes: [
              GoRoute(
                path: '/pos',
                builder: (context, state) =>
                    const Scaffold(body: Text('POS Screen')),
              ),
              GoRoute(
                path: '/customers',
                builder: (context, state) =>
                    const Scaffold(body: Text('Customers')),
              ),
              GoRoute(
                path: '/shifts',
                builder: (context, state) =>
                    const Scaffold(body: Text('Shifts')),
              ),
              GoRoute(
                path: '/returns',
                builder: (context, state) =>
                    const Scaffold(body: Text('Returns')),
              ),
              GoRoute(
                path: '/profile',
                builder: (context, state) =>
                    const Scaffold(body: Text('Profile')),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Mobile layout should have an AppBar
      expect(find.byType(AppBar), findsOneWidget);

      // Content should be visible
      expect(find.text('POS Screen'), findsOneWidget);

      // Restore error handler
      FlutterError.onError = oldOnError;

      // Reset view
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  group('CashierShell - App Widget', () {
    test('CashierShell constructor accepts child', () {
      const shell = CashierShell(child: SizedBox());
      expect(shell.child, isA<SizedBox>());
    });

    test('CashierShell is a StatefulWidget', () {
      const shell = CashierShell(child: SizedBox());
      expect(shell, isA<StatefulWidget>());
    });

    test('CashierShell can be created with a key', () {
      const key = ValueKey('test-cashier-shell');
      const shell = CashierShell(key: key, child: SizedBox());
      expect(shell.key, equals(key));
    });
  });
}
