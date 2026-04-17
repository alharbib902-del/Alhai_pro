import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import 'package:driver_app/features/home/widgets/shift_toggle.dart';
import 'package:driver_app/features/shifts/providers/shifts_providers.dart';
import 'package:driver_app/features/deliveries/providers/delivery_providers.dart';

void main() {
  group('M5 — Shift Toggle Active Delivery Guard', () {
    Widget buildTestWidget({required List<Override> overrides}) {
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
          home: const Scaffold(body: Center(child: ShiftToggle())),
        ),
      );
    }

    testWidgets('shows warning dialog when ending shift with active delivery', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          overrides: [
            // Driver is currently on shift.
            activeShiftProvider.overrideWith((ref) async {
              return {'id': 'shift-1', 'started_at': '2026-04-16T08:00:00Z'};
            }),
            // Active deliveries stream has one non-terminal delivery.
            activeDeliveriesStreamProvider.overrideWith((ref) {
              return const AsyncValue.data([
                {
                  'id': 'delivery-1',
                  'status': 'accepted',
                  'created_at': '2026-04-16T10:00:00Z',
                },
              ]);
            }),
          ],
        ),
      );
      // Let FutureProvider for activeShift resolve.
      await tester.pump();
      await tester.pump();

      // Verify the chip shows "متصل" (online).
      expect(find.text('متصل'), findsOneWidget);

      // Tap the shift toggle.
      await tester.tap(find.byType(ActionChip));
      await tester.pumpAndSettle();

      // Should show the warning dialog.
      expect(find.text('لديك توصيل نشط'), findsOneWidget);
      expect(find.text('إلغاء'), findsOneWidget);
      expect(find.text('إنهاء'), findsOneWidget);
    });

    testWidgets('cancel in dialog keeps shift active', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          overrides: [
            activeShiftProvider.overrideWith((ref) async {
              return {'id': 'shift-1', 'started_at': '2026-04-16T08:00:00Z'};
            }),
            activeDeliveriesStreamProvider.overrideWith((ref) {
              return const AsyncValue.data([
                {
                  'id': 'delivery-1',
                  'status': 'accepted',
                  'created_at': '2026-04-16T10:00:00Z',
                },
              ]);
            }),
          ],
        ),
      );
      await tester.pump();
      await tester.pump();

      // Tap shift toggle to trigger dialog.
      await tester.tap(find.byType(ActionChip));
      await tester.pumpAndSettle();

      // Tap "إلغاء" (Cancel).
      await tester.tap(find.text('إلغاء'));
      await tester.pumpAndSettle();

      // Dialog dismissed, still online.
      expect(find.text('لديك توصيل نشط'), findsNothing);
      expect(find.text('متصل'), findsOneWidget);
    });
  });
}
