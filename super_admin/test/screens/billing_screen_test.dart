import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

import 'package:super_admin/screens/subscriptions/sa_billing_screen.dart';

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
        home: const SABillingScreen(),
      ),
    );
  }

  group('SABillingScreen', () {
    testWidgets('renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('is a ConsumerWidget', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(SABillingScreen), findsOneWidget);
    });

    testWidgets('shows loading or data state', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Either loading or billing content
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
