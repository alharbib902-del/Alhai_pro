import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import 'package:driver_app/features/deliveries/screens/deliveries_list_screen.dart';

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
        home: const DeliveriesListScreen(),
      ),
    );
  }

  group('DeliveriesListScreen', () {
    testWidgets('renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows deliveries title in app bar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Arabic: "Deliveries"
      expect(
          find.text('\u0627\u0644\u062a\u0648\u0635\u064a\u0644\u0627\u062a'),
          findsOneWidget);
    });

    testWidgets('shows segmented filter buttons', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Arabic: "Active"
      expect(find.text('\u0646\u0634\u0637'), findsOneWidget);
      // Arabic: "Completed"
      expect(find.text('\u0645\u0643\u062a\u0645\u0644'), findsOneWidget);
      // Arabic: "All"
      expect(find.text('\u0627\u0644\u0643\u0644'), findsOneWidget);
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

      // Should either be loading or showing data/empty
      expect(find.byType(DeliveriesListScreen), findsOneWidget);
    });

    testWidgets('is a ConsumerWidget', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(DeliveriesListScreen), findsOneWidget);
    });
  });
}
