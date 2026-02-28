import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_core/src/models/notification.dart';

void main() {
  group('AppNotification Model', () {
    AppNotification createNotification({
      String id = 'notif-1',
      String? type,
      bool isRead = false,
    }) {
      return AppNotification(
        id: id,
        userId: 'user-1',
        title: 'Test Notification',
        body: 'Test body',
        type: type,
        isRead: isRead,
        createdAt: DateTime(2026, 1, 15),
      );
    }

    group('isUnread', () {
      test('should return true when not read', () {
        final notification = createNotification(isRead: false);
        expect(notification.isUnread, isTrue);
      });

      test('should return false when read', () {
        final notification = createNotification(isRead: true);
        expect(notification.isUnread, isFalse);
      });
    });

    group('typeDisplayAr', () {
      test('should return Arabic name for order_update', () {
        final notification = createNotification(type: 'order_update');
        expect(notification.typeDisplayAr, equals('تحديث طلب'));
      });

      test('should return Arabic name for promotion', () {
        final notification = createNotification(type: 'promotion');
        expect(notification.typeDisplayAr, equals('عرض ترويجي'));
      });

      test('should return Arabic name for system', () {
        final notification = createNotification(type: 'system');
        expect(notification.typeDisplayAr, equals('نظام'));
      });

      test('should return Arabic name for low_stock', () {
        final notification = createNotification(type: 'low_stock');
        expect(notification.typeDisplayAr, equals('نفاد مخزون'));
      });

      test('should return default for unknown type', () {
        final notification = createNotification(type: 'unknown');
        expect(notification.typeDisplayAr, equals('إشعار'));
      });

      test('should return default for null type', () {
        final notification = createNotification(type: null);
        expect(notification.typeDisplayAr, equals('إشعار'));
      });
    });

    group('serialization', () {
      test('should create AppNotification from JSON', () {
        final json = {
          'id': 'notif-1',
          'userId': 'user-1',
          'title': 'New Order',
          'body': 'You have a new order',
          'type': 'order_update',
          'isRead': false,
          'data': {'orderId': 'order-1'},
          'createdAt': '2026-01-15T10:00:00.000',
        };

        final notification = AppNotification.fromJson(json);

        expect(notification.id, equals('notif-1'));
        expect(notification.title, equals('New Order'));
        expect(notification.type, equals('order_update'));
        expect(notification.isRead, isFalse);
        expect(notification.data, isNotNull);
        expect(notification.data!['orderId'], equals('order-1'));
      });

      test('should serialize to JSON and back', () {
        final notification = createNotification(type: 'system');
        final json = notification.toJson();
        final restored = AppNotification.fromJson(json);

        expect(restored.id, equals(notification.id));
        expect(restored.type, equals('system'));
        expect(restored.title, equals(notification.title));
      });
    });

    group('equality', () {
      test('should be equal for same data', () {
        final n1 = createNotification(id: 'n1', type: 'system');
        final n2 = createNotification(id: 'n1', type: 'system');
        expect(n1, equals(n2));
      });
    });
  });
}
