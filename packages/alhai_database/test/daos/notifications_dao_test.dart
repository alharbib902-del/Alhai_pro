import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';
import '../helpers/database_test_helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = createTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  NotificationsTableCompanion makeNotification({
    String id = 'notif-1',
    String storeId = 'store-1',
    String title = 'مخزون منخفض',
    String body = 'المنتج حليب طازج أقل من الحد الأدنى',
    bool isRead = false,
    DateTime? createdAt,
  }) {
    return NotificationsTableCompanion.insert(
      id: id,
      storeId: storeId,
      title: title,
      body: body,
      isRead: Value(isRead),
      createdAt: createdAt ?? DateTime(2025, 6, 15),
    );
  }

  group('NotificationsDao', () {
    test('insertNotification and getAllNotifications', () async {
      await db.notificationsDao.insertNotification(makeNotification());

      final notifications = await db.notificationsDao.getAllNotifications(
        'store-1',
      );
      expect(notifications, hasLength(1));
      expect(notifications.first.title, 'مخزون منخفض');
    });

    test('getAllNotifications respects limit', () async {
      for (var i = 0; i < 10; i++) {
        await db.notificationsDao.insertNotification(
          makeNotification(id: 'notif-$i'),
        );
      }

      final notifications = await db.notificationsDao.getAllNotifications(
        'store-1',
        limit: 5,
      );
      expect(notifications, hasLength(5));
    });

    test('getUnreadNotifications returns only unread', () async {
      await db.notificationsDao.insertNotification(
        makeNotification(id: 'n-1', isRead: false),
      );
      await db.notificationsDao.insertNotification(
        makeNotification(id: 'n-2', isRead: true),
      );

      final unread = await db.notificationsDao.getUnreadNotifications(
        'store-1',
      );
      expect(unread, hasLength(1));
      expect(unread.first.id, 'n-1');
    });

    test('markAsRead sets isRead to true', () async {
      await db.notificationsDao.insertNotification(makeNotification());

      await db.notificationsDao.markAsRead('notif-1');

      final unread = await db.notificationsDao.getUnreadNotifications(
        'store-1',
      );
      expect(unread, isEmpty);
    });

    test('markAllAsRead marks all as read for store', () async {
      await db.notificationsDao.insertNotification(makeNotification(id: 'n-1'));
      await db.notificationsDao.insertNotification(makeNotification(id: 'n-2'));
      await db.notificationsDao.insertNotification(makeNotification(id: 'n-3'));

      await db.notificationsDao.markAllAsRead('store-1');

      final unread = await db.notificationsDao.getUnreadNotifications(
        'store-1',
      );
      expect(unread, isEmpty);
    });

    test('deleteNotification removes notification', () async {
      await db.notificationsDao.insertNotification(makeNotification());

      final deleted = await db.notificationsDao.deleteNotification('notif-1');
      expect(deleted, 1);
    });

    test('deleteOldNotifications removes old ones', () async {
      await db.notificationsDao.insertNotification(
        makeNotification(id: 'old', createdAt: DateTime(2024, 1, 1)),
      );
      await db.notificationsDao.insertNotification(
        makeNotification(id: 'new', createdAt: DateTime(2025, 6, 15)),
      );

      final deleted = await db.notificationsDao.deleteOldNotifications(
        DateTime(2025, 1, 1),
      );
      expect(deleted, 1);

      final remaining = await db.notificationsDao.getAllNotifications(
        'store-1',
      );
      expect(remaining, hasLength(1));
      expect(remaining.first.id, 'new');
    });
  });
}
