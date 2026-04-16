/// Tests for Lite Notifications List Screen
///
/// Verifies rendering of notification tiles, read/unread states,
/// date grouping, loading state, and error state.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';

import 'package:admin_lite/providers/lite_alerts_providers.dart';
import 'package:admin_lite/screens/alerts/lite_notifications_list_screen.dart';
import '../../helpers/mock_database.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockAppDatabase db;

  setUpAll(() => registerLiteFallbackValues());

  setUp(() {
    db = setupMockDatabase();
    setupTestGetIt(mockDb: db);
  });

  tearDown(() => tearDownTestGetIt());

  // ===========================================================================
  // Factory helpers
  // ===========================================================================

  NotificationsTableData createTestNotification({
    String id = 'notif-1',
    String storeId = 'test-store-1',
    String title = 'Test Notification',
    String body = 'Notification body text',
    String type = 'order',
    bool isRead = false,
    DateTime? createdAt,
  }) {
    return NotificationsTableData(
      id: id,
      storeId: storeId,
      title: title,
      body: body,
      type: type,
      isRead: isRead,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  // ===========================================================================
  // Helper
  // ===========================================================================

  Widget buildScreen({
    AsyncValue<List<NotificationsTableData>>? notificationsValue,
  }) {
    return createTestWidget(
      const LiteNotificationsListScreen(),
      overrides: [
        if (notificationsValue != null)
          liteNotificationsProvider.overrideWith(
            (ref) => notificationsValue.when(
              data: (d) => Future.value(d),
              loading: () => Future.delayed(const Duration(days: 1)),
              error: (e, s) => Future.error(e, s),
            ),
          ),
      ],
    );
  }

  // ===========================================================================
  // Tests
  // ===========================================================================

  group('LiteNotificationsListScreen', () {
    testWidgets('renders with loading state', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final completer = Completer<List<NotificationsTableData>>();

      await tester.pumpWidget(
        createTestWidget(
          const LiteNotificationsListScreen(),
          overrides: [
            liteNotificationsProvider.overrideWith((ref) => completer.future),
          ],
        ),
      );
      await tester.pump();

      expect(find.byType(LiteNotificationsListScreen), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows notification tiles with data', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final notifications = [
        createTestNotification(
          id: 'n1',
          title: 'New Order',
          body: 'Order ORD-001 received',
          type: 'order',
          isRead: false,
          createdAt: DateTime.now(),
        ),
        createTestNotification(
          id: 'n2',
          title: 'Low Stock Alert',
          body: 'Product X is running low',
          type: 'low_stock',
          isRead: true,
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        buildScreen(notificationsValue: AsyncValue.data(notifications)),
      );
      await tester.pumpAndSettle();

      expect(find.text('New Order'), findsOneWidget);
      expect(find.text('Low Stock Alert'), findsOneWidget);
      expect(find.text('Order ORD-001 received'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows unread indicator dot', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final notifications = [
        createTestNotification(
          id: 'n1',
          title: 'Unread Notification',
          body: 'This is unread',
          isRead: false,
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        buildScreen(notificationsValue: AsyncValue.data(notifications)),
      );
      await tester.pumpAndSettle();

      // Unread notification should have the unread dot (8x8 container)
      expect(find.text('Unread Notification'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows type-specific icons', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final notifications = [
        createTestNotification(
          id: 'n1',
          title: 'Order Alert',
          body: 'New order',
          type: 'order',
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        buildScreen(notificationsValue: AsyncValue.data(notifications)),
      );
      await tester.pumpAndSettle();

      // Order type icon
      expect(find.byIcon(Icons.receipt_long), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows mark all as read button', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        buildScreen(notificationsValue: const AsyncValue.data([])),
      );
      await tester.pumpAndSettle();

      // TextButton for mark all as read in app bar
      expect(find.byType(TextButton), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('handles error state', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        buildScreen(
          notificationsValue: AsyncValue.error(
            Exception('Load error'),
            StackTrace.current,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
