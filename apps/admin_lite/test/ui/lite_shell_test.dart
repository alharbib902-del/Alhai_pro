/// Admin Lite Shell Widget Tests
///
/// Verifies that the LiteShell widget renders correctly
/// with bottom navigation bar.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:admin_lite/ui/lite_shell.dart';

void main() {
  group('LiteShell - Widget creation', () {
    test('LiteShell constructor accepts child', () {
      const shell = LiteShell(child: SizedBox());
      expect(shell.child, isA<SizedBox>());
    });

    test('LiteShell is a StatelessWidget', () {
      const shell = LiteShell(child: SizedBox());
      expect(shell, isA<StatelessWidget>());
    });

    testWidgets('LiteShell renders bottom navigation bar', (tester) async {
      final router = GoRouter(
        initialLocation: '/dashboard',
        routes: [
          ShellRoute(
            builder: (context, state, child) => LiteShell(child: child),
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) =>
                    const Scaffold(body: Text('Dashboard Content')),
              ),
              GoRoute(
                path: '/reports',
                builder: (context, state) =>
                    const Scaffold(body: Text('Reports Content')),
              ),
              GoRoute(
                path: '/ai/assistant',
                builder: (context, state) =>
                    const Scaffold(body: Text('AI Content')),
              ),
              GoRoute(
                path: '/monitoring',
                builder: (context, state) =>
                    const Scaffold(body: Text('Monitoring Content')),
              ),
              GoRoute(
                path: '/more',
                builder: (context, state) =>
                    const Scaffold(body: Text('More Content')),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify bottom navigation bar items
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Reports'), findsOneWidget);
      expect(find.text('AI'), findsOneWidget);
      expect(find.text('Monitoring'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);

      // Verify content is shown
      expect(find.text('Dashboard Content'), findsOneWidget);
    });

    testWidgets('LiteShell bottom nav bar selects correct tab',
        (tester) async {
      final router = GoRouter(
        initialLocation: '/reports',
        routes: [
          ShellRoute(
            builder: (context, state, child) => LiteShell(child: child),
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) =>
                    const Scaffold(body: Text('Dashboard Content')),
              ),
              GoRoute(
                path: '/reports',
                builder: (context, state) =>
                    const Scaffold(body: Text('Reports Content')),
              ),
              GoRoute(
                path: '/ai/assistant',
                builder: (context, state) =>
                    const Scaffold(body: Text('AI Content')),
              ),
              GoRoute(
                path: '/monitoring',
                builder: (context, state) =>
                    const Scaffold(body: Text('Monitoring Content')),
              ),
              GoRoute(
                path: '/more',
                builder: (context, state) =>
                    const Scaffold(body: Text('More Content')),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify reports content is shown
      expect(find.text('Reports Content'), findsOneWidget);

      // Verify BottomNavigationBar is present
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });

  group('LiteShell - Key property', () {
    test('can be created with a key', () {
      const key = ValueKey('test-lite-shell');
      const shell = LiteShell(key: key, child: SizedBox());
      expect(shell.key, equals(key));
    });
  });
}
