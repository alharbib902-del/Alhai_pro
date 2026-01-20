import '../models/activity_log.dart';
import '../models/paginated.dart';

/// Repository contract for activity log operations (v2.4.0)
/// Note: Logs are immutable - no update/delete operations
abstract class ActivityLogsRepository {
  /// Gets paginated activity logs for a store
  Future<Paginated<ActivityLog>> getStoreLogs(
    String storeId, {
    int page = 1,
    int limit = 50,
    String? action,
    String? entityType,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Gets activity logs for a specific user
  Future<Paginated<ActivityLog>> getUserLogs(
    String userId, {
    int page = 1,
    int limit = 50,
  });

  /// Gets activity logs for a specific entity
  Future<List<ActivityLog>> getEntityLogs(String entityType, String entityId);

  /// Logs an activity
  Future<ActivityLog> logActivity({
    String? storeId,
    String? userId,
    required String action,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? details,
  });

  /// Gets recent activities summary
  Future<List<ActivitySummary>> getActivitySummary(
    String storeId, {
    required DateTime startDate,
    required DateTime endDate,
  });
}

/// Activity summary for reporting
class ActivitySummary {
  final String action;
  final int count;
  final DateTime lastOccurrence;

  const ActivitySummary({
    required this.action,
    required this.count,
    required this.lastOccurrence,
  });
}
