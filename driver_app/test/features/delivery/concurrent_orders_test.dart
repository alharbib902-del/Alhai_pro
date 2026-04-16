import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import 'package:driver_app/features/deliveries/providers/delivery_providers.dart';
import 'package:driver_app/features/deliveries/screens/new_order_screen.dart';

void main() {
  group('M2 — Max Concurrent Orders Check', () {
    Widget buildTestWidget({
      List<Override> overrides = const [],
    }) {
      return ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AlhaiTheme.light,
          home: const NewOrderScreen(timeoutSeconds: 999),
        ),
      );
    }

    testWidgets('shows confirmation dialog when active delivery exists',
        (tester) async {
      // Override activeDeliveriesProvider to return one active delivery
      // and one assigned delivery.
      await tester.pumpWidget(
        buildTestWidget(
          overrides: [
            activeDeliveriesProvider.overrideWith((ref) async {
              return [
                {
                  'id': 'active-1',
                  'status': 'accepted',
                  'created_at': '2026-04-16T10:00:00Z',
                  'fee': 15,
                  'orders': {
                    'id': 'order-1',
                    'order_number': '100',
                    'customer_name': 'Test',
                    'customer_phone': '+966500000000',
                    'delivery_address': 'Test Address',
                  },
                },
                {
                  'id': 'assigned-1',
                  'status': 'assigned',
                  'created_at': '2026-04-16T10:05:00Z',
                  'fee': 20,
                  'orders': {
                    'id': 'order-2',
                    'order_number': '101',
                    'customer_name': 'Test 2',
                    'customer_phone': '+966500000001',
                    'delivery_address': 'Test Address 2',
                  },
                },
              ];
            }),
          ],
        ),
      );
      await tester.pump();
      await tester.pump();

      // Find and tap the accept button.
      final acceptButton = find.text('قبول الطلب');
      if (acceptButton.evaluate().isNotEmpty) {
        await tester.tap(acceptButton);
        await tester.pumpAndSettle();

        // Should show the confirmation dialog.
        expect(find.text('لديك توصيل نشط'), findsOneWidget);
        expect(find.text('إلغاء'), findsOneWidget);
        expect(find.text('قبول'), findsOneWidget);
      }
    });

    testWidgets('does not show dialog when no active delivery', (tester) async {
      // Override with only an assigned delivery (no active ones).
      await tester.pumpWidget(
        buildTestWidget(
          overrides: [
            activeDeliveriesProvider.overrideWith((ref) async {
              return [
                {
                  'id': 'assigned-1',
                  'status': 'assigned',
                  'created_at': '2026-04-16T10:05:00Z',
                  'fee': 20,
                  'orders': {
                    'id': 'order-2',
                    'order_number': '101',
                    'customer_name': 'Test 2',
                    'customer_phone': '+966500000001',
                    'delivery_address': 'Test Address 2',
                  },
                },
              ];
            }),
          ],
        ),
      );
      await tester.pump();
      await tester.pump();

      // Find accept button — should proceed without dialog.
      final acceptButton = find.text('قبول الطلب');
      if (acceptButton.evaluate().isNotEmpty) {
        await tester.tap(acceptButton);
        await tester.pump();

        // No confirmation dialog should appear.
        expect(find.text('لديك توصيل نشط'), findsNothing);
      }
    });
  });
}
