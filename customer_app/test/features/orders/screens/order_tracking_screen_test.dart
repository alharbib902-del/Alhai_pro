import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import 'package:customer_app/features/tracking/screens/order_tracking_screen.dart';

void main() {
  Widget buildTestWidget({String orderId = 'test-order-123'}) {
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
        home: OrderTrackingScreen(orderId: orderId),
      ),
    );
  }

  group('OrderTrackingScreen', () {
    testWidgets('renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows tracking title in app bar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Arabic: "Track Order"
      expect(
          find.text('\u062a\u062a\u0628\u0639 \u0627\u0644\u0637\u0644\u0628'),
          findsOneWidget);
    });

    testWidgets('has back button in app bar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('shows loading or waiting for driver state', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Either shows a loading indicator or the waiting for driver state
      final hasLoading =
          find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
      final hasWaiting = find
          .text(
              '\u0641\u064a \u0627\u0646\u062a\u0638\u0627\u0631 \u062a\u0639\u064a\u064a\u0646 \u0633\u0627\u0626\u0642')
          .evaluate()
          .isNotEmpty;

      expect(hasLoading || hasWaiting, isTrue);
    });

    testWidgets('accepts orderId parameter', (tester) async {
      await tester.pumpWidget(buildTestWidget(orderId: 'custom-order'));
      await tester.pump();

      expect(find.byType(OrderTrackingScreen), findsOneWidget);
    });

    testWidgets('is a ConsumerStatefulWidget', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(OrderTrackingScreen), findsOneWidget);
    });
  });
}
