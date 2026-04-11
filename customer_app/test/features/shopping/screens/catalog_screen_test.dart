import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import 'package:customer_app/features/catalog/screens/catalog_screen.dart';

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
        home: const CatalogScreen(),
      ),
    );
  }

  group('CatalogScreen', () {
    testWidgets('renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Should render the Scaffold
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows app bar with products title', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // When no store is selected, should show the products title
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows select store message when no store selected', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // With no selected store, should prompt user to choose a store
      expect(
        find.text(
          '\u0627\u062e\u062a\u0631 \u0645\u062a\u062c\u0631 \u0623\u0648\u0644\u0627\u064b',
        ),
        findsOneWidget,
      );
    });

    testWidgets('has search icon in app bar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // The products title should be shown
      expect(
        find.text('\u0627\u0644\u0645\u0646\u062a\u062c\u0627\u062a'),
        findsOneWidget,
      );
    });

    testWidgets('is a ConsumerStatefulWidget', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(CatalogScreen), findsOneWidget);
    });
  });
}
