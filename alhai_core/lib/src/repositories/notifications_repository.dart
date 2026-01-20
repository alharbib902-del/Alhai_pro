import '../models/notification.dart';
import '../models/paginated.dart';

/// Repository contract for notification operations (v2.4.0)
abstract class NotificationsRepository {
  /// Gets paginated notifications for current user
  Future<Paginated<AppNotification>> getNotifications({
    int page = 1,
    int limit = 20,
    bool? isRead,
  });

  /// Gets unread notifications count
  Future<int> getUnreadCount();

  /// Marks a notification as read
  Future<void> markAsRead(String notificationId);

  /// Marks all notifications as read
  Future<void> markAllAsRead();

  /// Deletes a notification
  Future<void> deleteNotification(String notificationId);

  /// Stream of new notifications (realtime)
  Stream<AppNotification> watchNotifications();
}
