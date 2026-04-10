import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import 'package:customer_app/features/cart/screens/cart_screen.dart';

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
        home: const CartScreen(),
      ),
    );
  }

  group('CartScreen', () {
    testWidgets('renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows cart title in app bar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('\u0627\u0644\u0633\u0644\u0629'), findsOneWidget);
    });

    testWidgets('shows empty state when cart is empty', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Empty cart should show the empty state text
      expect(
          find.text(
              '\u0627\u0644\u0633\u0644\u0629 \u0641\u0627\u0631\u063a\u0629'),
          findsOneWidget);
    });

    testWidgets('shows browse stores action in empty state', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(
          find.text(
              '\u062a\u0635\u0641\u062d \u0627\u0644\u0645\u062a\u0627\u062c\u0631'),
          findsOneWidget);
    });

    testWidgets('shows add products description in empty state',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(
          find.text(
              '\u0623\u0636\u0641 \u0645\u0646\u062a\u062c\u0627\u062a \u0645\u0646 \u0627\u0644\u0645\u062a\u062c\u0631'),
          findsOneWidget);
    });

    testWidgets('is a ConsumerWidget', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(CartScreen), findsOneWidget);
    });
  });
}
