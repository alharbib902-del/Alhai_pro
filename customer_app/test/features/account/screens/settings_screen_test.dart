import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import 'package:customer_app/features/settings/screens/settings_screen.dart';

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
        home: const SettingsScreen(),
      ),
    );
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SettingsScreen', () {
    testWidgets('renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows settings title in app bar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Arabic: "Settings"
      expect(find.text('\u0627\u0644\u0625\u0639\u062f\u0627\u062f\u0627\u062a'), findsOneWidget);
    });

    testWidgets('shows language setting', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Arabic: "Language"
      expect(find.text('\u0627\u0644\u0644\u063a\u0629'), findsOneWidget);
      // Arabic: "Arabic"
      expect(find.text('\u0627\u0644\u0639\u0631\u0628\u064a\u0629'), findsOneWidget);
    });

    testWidgets('shows notifications setting', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Arabic: "Notifications"
      expect(find.text('\u0627\u0644\u0625\u0634\u0639\u0627\u0631\u0627\u062a'), findsOneWidget);
    });

    testWidgets('shows about section', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Arabic: "About the App"
      expect(find.text('\u0639\u0646 \u0627\u0644\u062a\u0637\u0628\u064a\u0642'), findsOneWidget);
    });

    testWidgets('has language icon', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.language), findsOneWidget);
    });

    testWidgets('has notifications icon', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });

    testWidgets('has info icon for about section', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('has back button in app bar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('has SwitchListTile for notifications', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(SwitchListTile), findsOneWidget);
    });
  });
}
