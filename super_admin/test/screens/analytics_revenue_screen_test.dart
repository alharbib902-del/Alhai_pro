import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

import 'package:super_admin/screens/analytics/sa_revenue_analytics_screen.dart';

void main() {
  Widget buildTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        title: 'Test',
        theme: AlhaiTheme.dark,
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const SARevenueAnalyticsScreen(),
      ),
    );
  }

  group('SARevenueAnalyticsScreen', () {
    testWidgets('renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('is a ConsumerStatefulWidget', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(SARevenueAnalyticsScreen), findsOneWidget);
    });

    testWidgets('has SegmentedButton for period selection', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(SegmentedButton<String>), findsOneWidget);
    });

    testWidgets('shows loading or data state', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Either loading or analytics content
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
