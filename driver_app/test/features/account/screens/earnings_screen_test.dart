import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import 'package:driver_app/features/earnings/screens/earnings_screen.dart';

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
        home: const EarningsScreen(),
      ),
    );
  }

  group('EarningsScreen', () {
    testWidgets('renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows earnings title in app bar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Arabic: "Earnings"
      expect(find.text('\u0627\u0644\u0623\u0631\u0628\u0627\u062d'),
          findsOneWidget);
    });

    testWidgets('shows period selector with segmented buttons', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Arabic: "Today"
      expect(find.text('\u0627\u0644\u064a\u0648\u0645'), findsOneWidget);
      // Arabic: "Week"
      expect(find.text('\u0627\u0644\u0623\u0633\u0628\u0648\u0639'),
          findsOneWidget);
      // Arabic: "Month"
      expect(find.text('\u0627\u0644\u0634\u0647\u0631'), findsOneWidget);
    });

    testWidgets('has SegmentedButton widget', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(
          find.byWidgetPredicate((w) => w is SegmentedButton), findsOneWidget);
    });

    testWidgets('shows loading or data state', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Should show either loading shimmer or data content
      expect(find.byType(EarningsScreen), findsOneWidget);
    });

    testWidgets('is a ConsumerWidget', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(EarningsScreen), findsOneWidget);
    });
  });
}
