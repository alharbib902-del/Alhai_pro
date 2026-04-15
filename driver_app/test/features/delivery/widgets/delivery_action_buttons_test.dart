import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import 'package:driver_app/core/constants/driver_constants.dart';
import 'package:driver_app/features/deliveries/widgets/delivery_action_buttons.dart';

void main() {
  Widget buildTestWidget({
    required String status,
    VoidCallback? onProofRequired,
  }) {
    return ProviderScope(
      child: MaterialApp(
        theme: AlhaiTheme.light,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: DeliveryActionButtons(
            deliveryId: 'test-delivery-001',
            currentStatus: status,
            onProofRequired: onProofRequired,
          ),
        ),
      ),
    );
  }

  group('H8 — delivery proof required before completion', () {
    testWidgets(
      'arrived_at_customer with onProofRequired=null shows error SnackBar',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            status: DeliveryStatus.arrivedAtCustomer,
            onProofRequired: null,
          ),
        );
        await tester.pump();

        // Find and tap the "تأكيد التسليم" (Confirm delivery) button.
        final confirmButton = find.text('تأكيد التسليم');
        expect(confirmButton, findsOneWidget);
        await tester.tap(confirmButton);
        await tester.pump();

        // A SnackBar should appear with the proof-required message.
        expect(
          find.text('يجب تقديم إثبات التسليم قبل التأكيد'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'arrived_at_customer with onProofRequired set calls the callback',
      (tester) async {
        bool proofRequested = false;

        await tester.pumpWidget(
          buildTestWidget(
            status: DeliveryStatus.arrivedAtCustomer,
            onProofRequired: () => proofRequested = true,
          ),
        );
        await tester.pump();

        final confirmButton = find.text('تأكيد التسليم');
        expect(confirmButton, findsOneWidget);
        await tester.tap(confirmButton);
        await tester.pump();

        expect(proofRequested, isTrue);
        // No error SnackBar should appear.
        expect(
          find.text('يجب تقديم إثبات التسليم قبل التأكيد'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'arrived_at_customer shows both confirm and fail buttons',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            status: DeliveryStatus.arrivedAtCustomer,
            onProofRequired: null,
          ),
        );
        await tester.pump();

        expect(find.text('تأكيد التسليم'), findsOneWidget);
        expect(find.text('فشل التوصيل'), findsOneWidget);
      },
    );
  });
}
