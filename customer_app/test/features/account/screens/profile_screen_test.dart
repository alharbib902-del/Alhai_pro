import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import 'package:customer_app/features/profile/screens/profile_screen.dart';

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

  group('ProfileScreen', () {
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

    testWidgets('shows menu items', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Arabic: "My Addresses"
      expect(find.text('\u0639\u0646\u0627\u0648\u064a\u0646\u064a'), findsOneWidget);
      // Arabic: "My Orders"
      expect(find.text('\u0637\u0644\u0628\u0627\u062a\u064a'), findsOneWidget);
      // Arabic: "Settings"
      expect(find.text('\u0627\u0644\u0625\u0639\u062f\u0627\u062f\u0627\u062a'), findsOneWidget);
      // Arabic: "Help"
      expect(find.text('\u0627\u0644\u0645\u0633\u0627\u0639\u062f\u0629'), findsOneWidget);
    });

    testWidgets('shows logout button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Arabic: "Logout"
      expect(find.text('\u062a\u0633\u062c\u064a\u0644 \u0627\u0644\u062e\u0631\u0648\u062c'), findsOneWidget);
    });

    testWidgets('shows user info card with fallback', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // When no user, shows fallback name
      expect(find.text('\u0645\u0633\u062a\u062e\u062f\u0645'), findsOneWidget);
    });

    testWidgets('has CircleAvatar for user initials', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('shows logout icon', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.logout), findsOneWidget);
    });
  });
}
