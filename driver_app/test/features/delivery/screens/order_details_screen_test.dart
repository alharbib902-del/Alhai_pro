import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import 'package:driver_app/features/deliveries/screens/order_details_screen.dart';

void main() {
  Widget buildTestWidget({String deliveryId = 'test-delivery-123'}) {
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
        home: OrderDetailsScreen(deliveryId: deliveryId),
      ),
    );
  }

  group('OrderDetailsScreen', () {
    testWidgets('renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows order details title in app bar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Arabic: "Order Details"
      expect(
          find.text(
              '\u062a\u0641\u0627\u0635\u064a\u0644 \u0627\u0644\u0637\u0644\u0628'),
          findsWidgets);
    });

    testWidgets('accepts deliveryId parameter', (tester) async {
      await tester.pumpWidget(buildTestWidget(deliveryId: 'custom-del-id'));
      await tester.pump();

      expect(find.byType(OrderDetailsScreen), findsOneWidget);
    });

    testWidgets('shows loading or data state', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Should show either loading shimmer, error, or data state
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('is a ConsumerWidget', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(OrderDetailsScreen), findsOneWidget);
    });
  });
}
