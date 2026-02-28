import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/notifications_table.dart';

part 'notifications_dao.g.dart';

/// DAO for notifications
@DriftAccessor(tables: [NotificationsTable])
class NotificationsDao extends DatabaseAccessor<AppDatabase> with _$NotificationsDaoMixin {
  NotificationsDao(super.db);

  Future<List<NotificationsTableData>> getAllNotifications(String storeId, {int limit = 50}) {
    return (select(notificationsTable)..where((n) => n.storeId.equals(storeId))..orderBy([(n) => OrderingTerm.desc(n.createdAt)])..limit(limit)).get();
  }

  Future<List<NotificationsTableData>> getUnreadNotifications(String storeId) {
    return (select(notificationsTable)..where((n) => n.storeId.equals(storeId) & n.isRead.equals(false))..orderBy([(n) => OrderingTerm.desc(n.createdAt)])).get();
  }

  Future<int> markAsRead(String id) {
    return (update(notificationsTable)..where((n) => n.id.equals(id))).write(NotificationsTableCompanion(isRead: const Value(true), readAt: Value(DateTime.now())));
  }

  Future<int> markAllAsRead(String storeId) {
    return (update(notificationsTable)..where((n) => n.storeId.equals(storeId) & n.isRead.equals(false))).write(NotificationsTableCompanion(isRead: const Value(true), readAt: Value(DateTime.now())));
  }

  Future<int> insertNotification(NotificationsTableCompanion notification) => into(notificationsTable).insert(notification);
  Future<int> deleteNotification(String id) => (delete(notificationsTable)..where((n) => n.id.equals(id))).go();

  Future<int> deleteOldNotifications(DateTime olderThan) {
    return (delete(notificationsTable)..where((n) => n.createdAt.isSmallerThanValue(olderThan))).go();
  }
}
