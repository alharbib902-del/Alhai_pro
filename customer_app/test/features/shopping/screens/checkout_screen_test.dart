import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import 'package:customer_app/features/checkout/screens/checkout_screen.dart';

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
        home: const CheckoutScreen(),
      ),
    );
  }

  group('CheckoutScreen', () {
    testWidgets('renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows checkout title in app bar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Arabic: "Complete Order"
      expect(
        find.text(
          '\u0625\u062a\u0645\u0627\u0645 \u0627\u0644\u0637\u0644\u0628',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows delivery address section', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Arabic: "Delivery Address"
      expect(
        find.text(
          '\u0639\u0646\u0648\u0627\u0646 \u0627\u0644\u062a\u0648\u0635\u064a\u0644',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows payment method section', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Arabic: "Payment Method"
      expect(
        find.text(
          '\u0637\u0631\u064a\u0642\u0629 \u0627\u0644\u062f\u0641\u0639',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows order summary section', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Arabic: "Order Summary"
      expect(
        find.text('\u0645\u0644\u062e\u0635 \u0627\u0644\u0637\u0644\u0628'),
        findsOneWidget,
      );
    });

    testWidgets('shows payment options', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Arabic: "Cash on Delivery"
      expect(
        find.text(
          '\u0627\u0644\u062f\u0641\u0639 \u0639\u0646\u062f \u0627\u0644\u0627\u0633\u062a\u0644\u0627\u0645',
        ),
        findsOneWidget,
      );
      // Arabic: "Credit Card"
      expect(
        find.text(
          '\u0628\u0637\u0627\u0642\u0629 \u0627\u0626\u062a\u0645\u0627\u0646',
        ),
        findsOneWidget,
      );
      // Arabic: "Wallet"
      expect(
        find.text('\u0627\u0644\u0645\u062d\u0641\u0638\u0629'),
        findsOneWidget,
      );
    });

    testWidgets('has back button in app bar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('is a ConsumerStatefulWidget', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(CheckoutScreen), findsOneWidget);
    });
  });
}
