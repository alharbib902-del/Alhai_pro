import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

/// Notification domain model (v2.4.0)
@freezed
class AppNotification with _$AppNotification {
  const AppNotification._();

  const factory AppNotification({
    required String id,
    required String userId,
    required String title,
    String? body,
    String? type,
    Map<String, dynamic>? data,
    @Default(false) bool isRead,
    required DateTime createdAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);

  /// Check if notification is unread
  bool get isUnread => !isRead;

  /// Get notification type in Arabic
  String get typeDisplayAr {
    switch (type) {
      case 'order_update':
        return 'تحديث طلب';
      case 'promotion':
        return 'عرض ترويجي';
      case 'system':
        return 'نظام';
      case 'low_stock':
        return 'نفاد مخزون';
      default:
        return 'إشعار';
    }
  }
}
