import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import 'package:driver_app/features/proof/screens/delivery_proof_screen.dart';

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
        home: DeliveryProofScreen(deliveryId: deliveryId),
      ),
    );
  }

  group('DeliveryProofScreen', () {
    testWidgets('renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows proof title in app bar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Arabic: "Delivery Proof"
      expect(find.text('\u0625\u062b\u0628\u0627\u062a \u0627\u0644\u062a\u0633\u0644\u064a\u0645'), findsOneWidget);
    });

    testWidgets('shows photo capture section', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Arabic: "Delivery Photo"
      expect(find.text('\u0635\u0648\u0631\u0629 \u0627\u0644\u062a\u0633\u0644\u064a\u0645'), findsOneWidget);
    });

    testWidgets('shows signature section', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Arabic: "Recipient Signature"
      expect(find.text('\u062a\u0648\u0642\u064a\u0639 \u0627\u0644\u0645\u0633\u062a\u0644\u0645'), findsOneWidget);
    });

    testWidgets('shows capture photo prompt', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Arabic: "Tap to capture photo"
      expect(find.text('\u0627\u0636\u063a\u0637 \u0644\u0627\u0644\u062a\u0642\u0627\u0637 \u0635\u0648\u0631\u0629'), findsOneWidget);
    });

    testWidgets('has camera icon', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
    });

    testWidgets('shows recipient name field', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Arabic: "Recipient Name (optional)"
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('shows confirm delivery button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Arabic: "Confirm Delivery"
      expect(find.text('\u062a\u0623\u0643\u064a\u062f \u0627\u0644\u062a\u0633\u0644\u064a\u0645'), findsOneWidget);
    });

    testWidgets('accepts deliveryId parameter', (tester) async {
      await tester.pumpWidget(buildTestWidget(deliveryId: 'custom-id'));
      await tester.pump();

      expect(find.byType(DeliveryProofScreen), findsOneWidget);
    });
  });
}
