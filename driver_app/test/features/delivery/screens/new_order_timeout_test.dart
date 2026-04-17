import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import 'package:driver_app/features/deliveries/screens/new_order_screen.dart';
import 'package:driver_app/features/deliveries/providers/delivery_providers.dart';

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

const _testDeliveryId = 'test-delivery-001';

final _assignedDelivery = <String, dynamic>{
  'id': _testDeliveryId,
  'status': 'assigned',
  'delivery_address': 'شارع الملك فهد، الرياض',
  'delivery_fee': 15,
  'distance_km': 3.2,
  'estimated_time_minutes': 12,
  'orders': <String, dynamic>{'order_number': '1234'},
};

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Tracks calls to updateDeliveryStatus.
class _StatusUpdateTracker {
  final calls = <({String id, String status, String? notes})>[];

  Future<Map<String, dynamic>> call(
    String id,
    String status,
    String? notes,
  ) async {
    calls.add((id: id, status: status, notes: notes));
    return {'success': true};
  }
}

/// Sets up a phone-sized viewport. Must be called at the start of each test.
void _setPhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

Widget _buildTestWidget({
  required List<Map<String, dynamic>> deliveries,
  _StatusUpdateTracker? tracker,
  int timeoutSeconds = 5,
}) {
  final router = GoRouter(
    initialLocation: '/new-order',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const Scaffold(body: Text('home')),
      ),
      GoRoute(
        path: '/new-order',
        builder: (_, __) => NewOrderScreen(timeoutSeconds: timeoutSeconds),
      ),
      GoRoute(
        path: '/orders/:id',
        builder: (_, state) =>
            Scaffold(body: Text('order-detail-${state.pathParameters['id']}')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      activeDeliveriesProvider.overrideWith((ref) async => deliveries),
      if (tracker != null)
        updateDeliveryStatusProvider.overrideWith((ref, params) async {
          return tracker.call(params.id, params.status, params.notes);
        }),
    ],
    child: MaterialApp.router(
      title: 'Test',
      theme: AlhaiTheme.light,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('NewOrderScreen Timeout (C4)', () {
    testWidgets('shows countdown text with initial seconds', (tester) async {
      _setPhoneViewport(tester);
      await tester.pumpWidget(
        _buildTestWidget(deliveries: [_assignedDelivery], timeoutSeconds: 5),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('ثانية للقبول'), findsOneWidget);
      expect(find.text('5 ثانية للقبول'), findsOneWidget);
    });

    testWidgets('countdown decrements each second', (tester) async {
      _setPhoneViewport(tester);
      await tester.pumpWidget(
        _buildTestWidget(deliveries: [_assignedDelivery], timeoutSeconds: 5),
      );
      await tester.pumpAndSettle();

      expect(find.text('5 ثانية للقبول'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('4 ثانية للقبول'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('3 ثانية للقبول'), findsOneWidget);
    });

    testWidgets('shows progress bar', (tester) async {
      _setPhoneViewport(tester);
      await tester.pumpWidget(
        _buildTestWidget(deliveries: [_assignedDelivery], timeoutSeconds: 5),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('auto-rejects with reason=timeout when timer expires', (
      tester,
    ) async {
      _setPhoneViewport(tester);
      final tracker = _StatusUpdateTracker();

      await tester.pumpWidget(
        _buildTestWidget(
          deliveries: [_assignedDelivery],
          tracker: tracker,
          timeoutSeconds: 3,
        ),
      );
      await tester.pumpAndSettle();

      // Tick through the full countdown: 3 → 2 → 1 → 0 (auto-reject).
      await tester.pump(const Duration(seconds: 1)); // 2
      await tester.pump(const Duration(seconds: 1)); // 1
      await tester.pump(const Duration(seconds: 1)); // 0 → auto-reject fires

      // Pump enough frames for the async reject + GoRouter pop to complete.
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(tracker.calls, isNotEmpty);
      final rejectCall = tracker.calls.firstWhere(
        (c) => c.status == 'cancelled',
      );
      expect(rejectCall.id, _testDeliveryId);
      expect(rejectCall.notes, 'timeout');
    });

    testWidgets('accept cancels the timer', (tester) async {
      _setPhoneViewport(tester);
      final tracker = _StatusUpdateTracker();

      await tester.pumpWidget(
        _buildTestWidget(
          deliveries: [_assignedDelivery],
          tracker: tracker,
          timeoutSeconds: 5,
        ),
      );
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('4 ثانية للقبول'), findsOneWidget);

      await tester.tap(find.text('قبول الطلب'));

      // Pump frames for the async accept + GoRouter go() to complete.
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      final acceptCall = tracker.calls.firstWhere(
        (c) => c.status == 'accepted',
        orElse: () => throw StateError('No accept call found'),
      );
      expect(acceptCall.id, _testDeliveryId);

      // No timeout reject should have fired.
      final timeoutCalls = tracker.calls
          .where((c) => c.notes == 'timeout')
          .toList();
      expect(timeoutCalls, isEmpty);
    });

    testWidgets('manual reject uses reason=manual_rejection', (tester) async {
      _setPhoneViewport(tester);
      final tracker = _StatusUpdateTracker();

      await tester.pumpWidget(
        _buildTestWidget(
          deliveries: [_assignedDelivery],
          tracker: tracker,
          timeoutSeconds: 10,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('رفض'));

      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      final rejectCall = tracker.calls.firstWhere(
        (c) => c.status == 'cancelled',
      );
      expect(rejectCall.notes, 'manual_rejection');
    });

    testWidgets('dispose cleans up timer without errors', (tester) async {
      _setPhoneViewport(tester);
      await tester.pumpWidget(
        _buildTestWidget(deliveries: [_assignedDelivery], timeoutSeconds: 30),
      );
      await tester.pumpAndSettle();

      // Tick to ensure timer is running.
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('29 ثانية للقبول'), findsOneWidget);

      // Replace the widget tree — triggers dispose of the NewOrderScreen.
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('replaced'))),
      );
      await tester.pumpAndSettle();

      // No exceptions thrown — timer was cleaned up.
      expect(find.text('replaced'), findsOneWidget);
    });

    testWidgets('shows order details (number, address, fee)', (tester) async {
      _setPhoneViewport(tester);
      await tester.pumpWidget(
        _buildTestWidget(deliveries: [_assignedDelivery], timeoutSeconds: 30),
      );
      await tester.pumpAndSettle();

      expect(find.text('#1234'), findsOneWidget);
      expect(find.textContaining('شارع الملك فهد'), findsOneWidget);
      expect(find.textContaining('15 ر.س'), findsOneWidget);
      expect(find.textContaining('3.2 كم'), findsOneWidget);
    });

    testWidgets('empty assigned list shows no-orders message', (tester) async {
      _setPhoneViewport(tester);
      await tester.pumpWidget(
        _buildTestWidget(deliveries: [], timeoutSeconds: 5),
      );
      await tester.pumpAndSettle();

      expect(find.text('لا توجد طلبات جديدة'), findsOneWidget);
    });
  });
}
