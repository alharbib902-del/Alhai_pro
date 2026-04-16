/// Model for admin notifications from admin_notifications table.
library;

/// Types of admin notifications.
enum AdminNotificationType {
  newDistributor,
  documentUploaded,
  distributorApproved,
  distributorRejected,
  distributorSuspended,
  general;

  String get dbValue {
    switch (this) {
      case AdminNotificationType.newDistributor:
        return 'new_distributor';
      case AdminNotificationType.documentUploaded:
        return 'document_uploaded';
      case AdminNotificationType.distributorApproved:
        return 'distributor_approved';
      case AdminNotificationType.distributorRejected:
        return 'distributor_rejected';
      case AdminNotificationType.distributorSuspended:
        return 'distributor_suspended';
      case AdminNotificationType.general:
        return 'general';
    }
  }

  String get arabicLabel {
    switch (this) {
      case AdminNotificationType.newDistributor:
        return 'موزع جديد';
      case AdminNotificationType.documentUploaded:
        return 'مستند مرفوع';
      case AdminNotificationType.distributorApproved:
        return 'تم اعتماد موزع';
      case AdminNotificationType.distributorRejected:
        return 'تم رفض موزع';
      case AdminNotificationType.distributorSuspended:
        return 'تم إيقاف موزع';
      case AdminNotificationType.general:
        return 'عام';
    }
  }

  static AdminNotificationType fromDbValue(String value) {
    return AdminNotificationType.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => AdminNotificationType.general,
    );
  }
}

class AdminNotification {
  final String id;
  final AdminNotificationType type;
  final String title;
  final String? message;
  final String? relatedId;
  final String? relatedType;
  final bool isRead;
  final String? readBy;
  final DateTime? readAt;
  final DateTime createdAt;

  const AdminNotification({
    required this.id,
    required this.type,
    required this.title,
    this.message,
    this.relatedId,
    this.relatedType,
    this.isRead = false,
    this.readBy,
    this.readAt,
    required this.createdAt,
  });

  factory AdminNotification.fromJson(Map<String, dynamic> json) {
    return AdminNotification(
      id: json['id'] as String,
      type: AdminNotificationType.fromDbValue(
        json['type'] as String? ?? 'general',
      ),
      title: json['title'] as String? ?? '',
      message: json['message'] as String?,
      relatedId: json['related_id'] as String?,
      relatedType: json['related_type'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      readBy: json['read_by'] as String?,
      readAt: _tryParseDate(json['read_at']),
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  /// Time elapsed since notification.
  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 0) return 'منذ ${diff.inDays} يوم';
    if (diff.inHours > 0) return 'منذ ${diff.inHours} ساعة';
    if (diff.inMinutes > 0) return 'منذ ${diff.inMinutes} دقيقة';
    return 'الآن';
  }

  static DateTime? _tryParseDate(Object? value) {
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminNotification &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          isRead == other.isRead;

  @override
  int get hashCode => Object.hash(id, isRead);
}
