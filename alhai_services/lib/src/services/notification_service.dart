import 'package:alhai_core/alhai_core.dart';

/// خدمة الإشعارات
/// متوافقة مع NotificationsRepository من alhai_core
class NotificationService {
  final NotificationsRepository _notificationsRepo;

  NotificationService(this._notificationsRepo);

  /// الحصول على الإشعارات
  Future<Paginated<AppNotification>> getNotifications({
    bool? isRead,
    int page = 1,
    int limit = 20,
  }) async {
    return await _notificationsRepo.getNotifications(
      isRead: isRead,
      page: page,
      limit: limit,
    );
  }

  /// وضع علامة "مقروء" على إشعار
  Future<void> markAsRead(String notificationId) async {
    await _notificationsRepo.markAsRead(notificationId);
  }

  /// وضع علامة "مقروء" على جميع الإشعارات
  Future<void> markAllAsRead() async {
    await _notificationsRepo.markAllAsRead();
  }

  /// حذف إشعار
  Future<void> deleteNotification(String notificationId) async {
    await _notificationsRepo.deleteNotification(notificationId);
  }

  /// الحصول على عدد الإشعارات غير المقروءة
  Future<int> getUnreadCount() async {
    return await _notificationsRepo.getUnreadCount();
  }

  /// مشاهدة الإشعارات الجديدة (realtime)
  Stream<AppNotification> watchNotifications() {
    return _notificationsRepo.watchNotifications();
  }
}
