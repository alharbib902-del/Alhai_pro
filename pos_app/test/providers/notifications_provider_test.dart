import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/providers/notifications_provider.dart';

// ===========================================
// Notifications Provider Tests
// ===========================================

void main() {
  group('NotificationType enum', () {
    test('يحتوي على جميع الأنواع المطلوبة', () {
      expect(NotificationType.values.length, 9);
      expect(NotificationType.values, contains(NotificationType.newOrder));
      expect(NotificationType.values, contains(NotificationType.lowStock));
      expect(NotificationType.values, contains(NotificationType.outOfStock));
      expect(NotificationType.values, contains(NotificationType.newSale));
      expect(NotificationType.values, contains(NotificationType.newDebt));
      expect(NotificationType.values, contains(NotificationType.paymentReminder));
      expect(NotificationType.values, contains(NotificationType.aiSuggestion));
      expect(NotificationType.values, contains(NotificationType.systemUpdate));
      expect(NotificationType.values, contains(NotificationType.general));
    });
  });

  group('NotificationPriority enum', () {
    test('يحتوي على جميع مستويات الأولوية', () {
      expect(NotificationPriority.values.length, 4);
      expect(NotificationPriority.values, contains(NotificationPriority.low));
      expect(NotificationPriority.values, contains(NotificationPriority.normal));
      expect(NotificationPriority.values, contains(NotificationPriority.high));
      expect(NotificationPriority.values, contains(NotificationPriority.urgent));
    });
  });

  group('AppNotification model', () {
    late AppNotification notification;

    setUp(() {
      notification = AppNotification(
        id: 'test_123',
        title: 'اختبار',
        message: 'رسالة الاختبار',
        type: NotificationType.newOrder,
        priority: NotificationPriority.high,
        createdAt: DateTime(2024, 1, 15, 10, 30),
        isRead: false,
        data: {'orderId': '123'},
        actionRoute: '/orders/123',
      );
    });

    test('ينشئ الإشعار بالقيم الصحيحة', () {
      expect(notification.id, 'test_123');
      expect(notification.title, 'اختبار');
      expect(notification.message, 'رسالة الاختبار');
      expect(notification.type, NotificationType.newOrder);
      expect(notification.priority, NotificationPriority.high);
      expect(notification.isRead, false);
      expect(notification.data, {'orderId': '123'});
      expect(notification.actionRoute, '/orders/123');
    });

    test('القيمة الافتراضية للأولوية هي normal', () {
      final notif = AppNotification(
        id: '1',
        title: 'Test',
        message: 'Message',
        type: NotificationType.general,
        createdAt: DateTime.now(),
      );
      expect(notif.priority, NotificationPriority.normal);
    });

    test('القيمة الافتراضية لـ isRead هي false', () {
      final notif = AppNotification(
        id: '1',
        title: 'Test',
        message: 'Message',
        type: NotificationType.general,
        createdAt: DateTime.now(),
      );
      expect(notif.isRead, false);
    });

    group('copyWith', () {
      test('ينسخ مع تغيير القيم المحددة فقط', () {
        final copy = notification.copyWith(isRead: true);

        expect(copy.id, notification.id);
        expect(copy.title, notification.title);
        expect(copy.isRead, true);
      });

      test('ينسخ جميع القيم إذا تم تحديدها', () {
        final copy = notification.copyWith(
          id: 'new_id',
          title: 'عنوان جديد',
          message: 'رسالة جديدة',
          type: NotificationType.lowStock,
          priority: NotificationPriority.urgent,
          isRead: true,
          actionRoute: '/new-route',
        );

        expect(copy.id, 'new_id');
        expect(copy.title, 'عنوان جديد');
        expect(copy.message, 'رسالة جديدة');
        expect(copy.type, NotificationType.lowStock);
        expect(copy.priority, NotificationPriority.urgent);
        expect(copy.isRead, true);
        expect(copy.actionRoute, '/new-route');
      });
    });

    group('toJson / fromJson', () {
      test('يحول الإشعار إلى JSON بشكل صحيح', () {
        final json = notification.toJson();

        expect(json['id'], 'test_123');
        expect(json['title'], 'اختبار');
        expect(json['message'], 'رسالة الاختبار');
        expect(json['type'], NotificationType.newOrder.index);
        expect(json['priority'], NotificationPriority.high.index);
        expect(json['isRead'], false);
        expect(json['data'], {'orderId': '123'});
        expect(json['actionRoute'], '/orders/123');
      });

      test('يحول JSON إلى إشعار بشكل صحيح', () {
        final json = notification.toJson();
        final restored = AppNotification.fromJson(json);

        expect(restored.id, notification.id);
        expect(restored.title, notification.title);
        expect(restored.message, notification.message);
        expect(restored.type, notification.type);
        expect(restored.priority, notification.priority);
        expect(restored.isRead, notification.isRead);
        expect(restored.actionRoute, notification.actionRoute);
      });

      test('fromJson يتعامل مع isRead المفقود', () {
        final json = {
          'id': '1',
          'title': 'Test',
          'message': 'Msg',
          'type': 0,
          'priority': 1,
          'createdAt': DateTime.now().toIso8601String(),
        };

        final notif = AppNotification.fromJson(json);
        expect(notif.isRead, false);
      });
    });

    group('icon', () {
      test('يُرجع أيقونة صحيحة لكل نوع', () {
        expect(
          AppNotification(
            id: '1', title: '', message: '',
            type: NotificationType.newOrder,
            createdAt: DateTime.now(),
          ).icon,
          Icons.shopping_bag,
        );

        expect(
          AppNotification(
            id: '1', title: '', message: '',
            type: NotificationType.lowStock,
            createdAt: DateTime.now(),
          ).icon,
          Icons.inventory,
        );

        expect(
          AppNotification(
            id: '1', title: '', message: '',
            type: NotificationType.outOfStock,
            createdAt: DateTime.now(),
          ).icon,
          Icons.warning,
        );

        expect(
          AppNotification(
            id: '1', title: '', message: '',
            type: NotificationType.newSale,
            createdAt: DateTime.now(),
          ).icon,
          Icons.point_of_sale,
        );

        expect(
          AppNotification(
            id: '1', title: '', message: '',
            type: NotificationType.newDebt,
            createdAt: DateTime.now(),
          ).icon,
          Icons.account_balance_wallet,
        );

        expect(
          AppNotification(
            id: '1', title: '', message: '',
            type: NotificationType.paymentReminder,
            createdAt: DateTime.now(),
          ).icon,
          Icons.payment,
        );

        expect(
          AppNotification(
            id: '1', title: '', message: '',
            type: NotificationType.aiSuggestion,
            createdAt: DateTime.now(),
          ).icon,
          Icons.auto_awesome,
        );

        expect(
          AppNotification(
            id: '1', title: '', message: '',
            type: NotificationType.systemUpdate,
            createdAt: DateTime.now(),
          ).icon,
          Icons.system_update,
        );

        expect(
          AppNotification(
            id: '1', title: '', message: '',
            type: NotificationType.general,
            createdAt: DateTime.now(),
          ).icon,
          Icons.notifications,
        );
      });
    });

    group('color', () {
      test('يُرجع لون صحيح لكل نوع', () {
        expect(
          AppNotification(
            id: '1', title: '', message: '',
            type: NotificationType.newOrder,
            createdAt: DateTime.now(),
          ).color,
          Colors.blue,
        );

        expect(
          AppNotification(
            id: '1', title: '', message: '',
            type: NotificationType.lowStock,
            createdAt: DateTime.now(),
          ).color,
          Colors.orange,
        );

        expect(
          AppNotification(
            id: '1', title: '', message: '',
            type: NotificationType.outOfStock,
            createdAt: DateTime.now(),
          ).color,
          Colors.red,
        );

        expect(
          AppNotification(
            id: '1', title: '', message: '',
            type: NotificationType.newSale,
            createdAt: DateTime.now(),
          ).color,
          Colors.green,
        );

        expect(
          AppNotification(
            id: '1', title: '', message: '',
            type: NotificationType.newDebt,
            createdAt: DateTime.now(),
          ).color,
          Colors.purple,
        );

        expect(
          AppNotification(
            id: '1', title: '', message: '',
            type: NotificationType.paymentReminder,
            createdAt: DateTime.now(),
          ).color,
          Colors.amber,
        );

        expect(
          AppNotification(
            id: '1', title: '', message: '',
            type: NotificationType.aiSuggestion,
            createdAt: DateTime.now(),
          ).color,
          Colors.teal,
        );

        expect(
          AppNotification(
            id: '1', title: '', message: '',
            type: NotificationType.systemUpdate,
            createdAt: DateTime.now(),
          ).color,
          Colors.indigo,
        );

        expect(
          AppNotification(
            id: '1', title: '', message: '',
            type: NotificationType.general,
            createdAt: DateTime.now(),
          ).color,
          Colors.grey,
        );
      });
    });
  });

  group('NotificationsState', () {
    test('القيم الافتراضية صحيحة', () {
      const state = NotificationsState();

      expect(state.notifications, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('copyWith يعمل بشكل صحيح', () {
      const state = NotificationsState(isLoading: true);
      final copy = state.copyWith(isLoading: false, error: 'خطأ');

      expect(copy.isLoading, false);
      expect(copy.error, 'خطأ');
    });

    group('unreadCount', () {
      test('يُرجع 0 عندما لا توجد إشعارات', () {
        const state = NotificationsState();
        expect(state.unreadCount, 0);
      });

      test('يحسب عدد الإشعارات غير المقروءة بشكل صحيح', () {
        final notifications = [
          AppNotification(
            id: '1', title: '', message: '',
            type: NotificationType.general,
            createdAt: DateTime.now(),
            isRead: false,
          ),
          AppNotification(
            id: '2', title: '', message: '',
            type: NotificationType.general,
            createdAt: DateTime.now(),
            isRead: true,
          ),
          AppNotification(
            id: '3', title: '', message: '',
            type: NotificationType.general,
            createdAt: DateTime.now(),
            isRead: false,
          ),
        ];

        final state = NotificationsState(notifications: notifications);
        expect(state.unreadCount, 2);
      });
    });

    group('hasUnread', () {
      test('يُرجع false عندما لا توجد إشعارات غير مقروءة', () {
        const state = NotificationsState();
        expect(state.hasUnread, false);
      });

      test('يُرجع true عندما توجد إشعارات غير مقروءة', () {
        final notifications = [
          AppNotification(
            id: '1', title: '', message: '',
            type: NotificationType.general,
            createdAt: DateTime.now(),
            isRead: false,
          ),
        ];

        final state = NotificationsState(notifications: notifications);
        expect(state.hasUnread, true);
      });
    });

    group('unreadNotifications', () {
      test('يُرجع قائمة فارغة عندما لا توجد إشعارات غير مقروءة', () {
        const state = NotificationsState();
        expect(state.unreadNotifications, isEmpty);
      });

      test('يُرجع الإشعارات غير المقروءة فقط', () {
        final notifications = [
          AppNotification(
            id: '1', title: 'Unread 1', message: '',
            type: NotificationType.general,
            createdAt: DateTime.now(),
            isRead: false,
          ),
          AppNotification(
            id: '2', title: 'Read', message: '',
            type: NotificationType.general,
            createdAt: DateTime.now(),
            isRead: true,
          ),
          AppNotification(
            id: '3', title: 'Unread 2', message: '',
            type: NotificationType.general,
            createdAt: DateTime.now(),
            isRead: false,
          ),
        ];

        final state = NotificationsState(notifications: notifications);
        final unread = state.unreadNotifications;

        expect(unread.length, 2);
        expect(unread.every((n) => !n.isRead), true);
      });
    });

    group('urgentNotifications', () {
      test('يُرجع قائمة فارغة عندما لا توجد إشعارات عاجلة', () {
        const state = NotificationsState();
        expect(state.urgentNotifications, isEmpty);
      });

      test('يُرجع الإشعارات العاجلة غير المقروءة فقط', () {
        final notifications = [
          AppNotification(
            id: '1', title: 'Urgent Unread', message: '',
            type: NotificationType.general,
            createdAt: DateTime.now(),
            isRead: false,
            priority: NotificationPriority.urgent,
          ),
          AppNotification(
            id: '2', title: 'Urgent Read', message: '',
            type: NotificationType.general,
            createdAt: DateTime.now(),
            isRead: true,
            priority: NotificationPriority.urgent,
          ),
          AppNotification(
            id: '3', title: 'Normal Unread', message: '',
            type: NotificationType.general,
            createdAt: DateTime.now(),
            isRead: false,
            priority: NotificationPriority.normal,
          ),
        ];

        final state = NotificationsState(notifications: notifications);
        final urgent = state.urgentNotifications;

        expect(urgent.length, 1);
        expect(urgent.first.title, 'Urgent Unread');
      });
    });
  });
}
