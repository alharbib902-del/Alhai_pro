import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import 'package:driver_app/features/profile/screens/profile_screen.dart';

void main() {
  Widget buildTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        title: 'Test',
        theme: AlhaiTheme.light,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const ProfileScreen(),
      ),
    );
  }

  group('ProfileScreen (Driver)', () {
    testWidgets('renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows profile title in app bar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Arabic: "My Account"
      expect(find.text('\u062d\u0633\u0627\u0628\u064a'), findsOneWidget);
    });

    testWidgets('shows profile header with fallback name', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Arabic: "Driver" (default fallback)
      expect(find.text('\u0633\u0627\u0626\u0642'), findsOneWidget);
    });

    testWidgets('shows edit profile option', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Arabic: "Edit Profile"
      expect(
        find.text(
          '\u062a\u0639\u062f\u064a\u0644 \u0627\u0644\u0645\u0644\u0641 \u0627\u0644\u0634\u062e\u0635\u064a',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows shift history option', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Arabic: "Shift History"
      expect(
        find.text(
          '\u0633\u062c\u0644 \u0627\u0644\u0648\u0631\u062f\u064a\u0627\u062a',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows help option', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Arabic: "Help"
      expect(
        find.text('\u0627\u0644\u0645\u0633\u0627\u0639\u062f\u0629'),
        findsOneWidget,
      );
    });

    testWidgets('shows logout option', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Arabic: "Logout"
      expect(
        find.text(
          '\u062a\u0633\u062c\u064a\u0644 \u0627\u0644\u062e\u0631\u0648\u062c',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows version text', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Scroll down to reveal the version text (may be off-screen after
      // adding the driving mode toggle card).
      await tester.scrollUntilVisible(
        find.text('Alhai Driver v1.0.0'),
        200,
      );
      expect(find.text('Alhai Driver v1.0.0'), findsOneWidget);
    });

    testWidgets('has CircleAvatar for driver initials', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('has logout icon', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.logout), findsOneWidget);
    });
  });
}
