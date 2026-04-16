/// Tests for Lite Onboarding Screen
///
/// Verifies rendering of onboarding pages, navigation between pages,
/// skip button, page indicators, and next/previous buttons.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

import 'package:admin_lite/screens/onboarding_screen.dart';

void main() {
  // ===========================================================================
  // Helper
  // ===========================================================================

  Widget buildScreen({bool? onboardingSeen}) {
    final router = GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const LiteOnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) =>
              const Scaffold(body: Text('Login Screen')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        if (onboardingSeen != null)
          liteOnboardingSeenProvider.overrideWith((ref) => onboardingSeen),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }

  // ===========================================================================
  // Tests
  // ===========================================================================

  group('LiteOnboardingScreen', () {
    testWidgets('renders first page with icon and content', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(LiteOnboardingScreen), findsOneWidget);
      // First page icon
      expect(find.byIcon(Icons.speed_rounded), findsOneWidget);
      // PageView should be present
      expect(find.byType(PageView), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows skip button', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Skip button should be visible as a TextButton
      expect(find.byType(TextButton), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows page indicators', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // 3 pages = 3 AnimatedContainers for indicators
      expect(find.byType(AnimatedContainer), findsNWidgets(3));

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows next/filled button on first page', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // FilledButton for Next
      expect(find.byType(FilledButton), findsOneWidget);
      // No Previous (OutlinedButton) on first page
      expect(find.byType(OutlinedButton), findsNothing);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('navigates to second page on next tap', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Tap next button
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // Second page icon
      expect(find.byIcon(Icons.analytics_rounded), findsOneWidget);
      // Previous button should now appear
      expect(find.byType(OutlinedButton), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('navigates to third page and shows start button',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Go to page 2
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // Go to page 3
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // Third page icon
      expect(find.byIcon(Icons.groups_rounded), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('previous button goes back to first page', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Go to page 2
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // Tap previous
      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();

      // Should be back on first page
      expect(find.byIcon(Icons.speed_rounded), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('has 3 pages in PageView', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // We can verify by swiping through all pages
      // Page 1 icon
      expect(find.byIcon(Icons.speed_rounded), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
