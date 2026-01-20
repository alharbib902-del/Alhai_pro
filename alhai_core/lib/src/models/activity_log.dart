import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_log.freezed.dart';
part 'activity_log.g.dart';

/// Activity log domain model (v2.4.0)
/// Immutable audit trail - records cannot be modified after creation
@freezed
class ActivityLog with _$ActivityLog {
  const ActivityLog._();

  const factory ActivityLog({
    required String id,
    String? storeId,
    String? userId,
    required String action,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? details,
    String? ipAddress,
    required DateTime createdAt,
  }) = _ActivityLog;

  factory ActivityLog.fromJson(Map<String, dynamic> json) =>
      _$ActivityLogFromJson(json);

  /// Get action display in Arabic
  String get actionDisplayAr {
    switch (action) {
      case 'login':
        return 'تسجيل دخول';
      case 'logout':
        return 'تسجيل خروج';
      case 'create_order':
        return 'إنشاء طلب';
      case 'update_order':
        return 'تحديث طلب';
      case 'cancel_order':
        return 'إلغاء طلب';
      case 'create_product':
        return 'إضافة منتج';
      case 'update_product':
        return 'تعديل منتج';
      case 'delete_product':
        return 'حذف منتج';
      case 'stock_adjustment':
        return 'تعديل مخزون';
      case 'open_shift':
        return 'فتح وردية';
      case 'close_shift':
        return 'إغلاق وردية';
      case 'add_payment':
        return 'إضافة دفعة';
      case 'refund':
        return 'استرداد';
      default:
        return action;
    }
  }

  /// Get entity type display in Arabic
  String? get entityTypeDisplayAr {
    if (entityType == null) return null;
    switch (entityType) {
      case 'order':
        return 'طلب';
      case 'product':
        return 'منتج';
      case 'user':
        return 'مستخدم';
      case 'store':
        return 'متجر';
      case 'shift':
        return 'وردية';
      case 'payment':
        return 'دفعة';
      default:
        return entityType;
    }
  }
}
