import 'package:alhai_core/alhai_core.dart';

/// خدمة سجل النشاطات
/// تستخدم من: admin_pos, super_admin
class ActivityLogService {
  final ActivityLogsRepository _logsRepo;

  ActivityLogService(this._logsRepo);

  /// الحصول على سجلات المتجر
  Future<Paginated<ActivityLog>> getStoreLogs(
    String storeId, {
    int page = 1,
    int limit = 50,
    String? action,
    String? entityType,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _logsRepo.getStoreLogs(
      storeId,
      page: page,
      limit: limit,
      action: action,
      entityType: entityType,
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// الحصول على سجلات مستخدم معين
  Future<Paginated<ActivityLog>> getUserLogs(
    String userId, {
    int page = 1,
    int limit = 50,
  }) async {
    return await _logsRepo.getUserLogs(userId, page: page, limit: limit);
  }

  /// الحصول على سجلات كيان معين
  Future<List<ActivityLog>> getEntityLogs(
    String entityType,
    String entityId,
  ) async {
    return await _logsRepo.getEntityLogs(entityType, entityId);
  }

  /// تسجيل نشاط
  Future<ActivityLog> logActivity({
    String? storeId,
    String? userId,
    required String action,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? details,
  }) async {
    return await _logsRepo.logActivity(
      storeId: storeId,
      userId: userId,
      action: action,
      entityType: entityType,
      entityId: entityId,
      details: details,
    );
  }

  /// ملخص النشاطات
  Future<List<ActivitySummary>> getActivitySummary(
    String storeId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _logsRepo.getActivitySummary(
      storeId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
