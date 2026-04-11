import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_services/alhai_services.dart';

// ---------------------------------------------------------------------------
// Fake
// ---------------------------------------------------------------------------
class FakeActivityLogsRepository implements ActivityLogsRepository {
  final List<ActivityLog> _logs = [];

  @override
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
    var filtered = _logs.where((l) => l.storeId == storeId);
    if (action != null) filtered = filtered.where((l) => l.action == action);
    if (userId != null) filtered = filtered.where((l) => l.userId == userId);
    final list = filtered.toList();
    return Paginated(
      items: list.take(limit).toList(),
      total: list.length,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<Paginated<ActivityLog>> getUserLogs(
    String userId, {
    int page = 1,
    int limit = 50,
  }) async {
    final filtered = _logs.where((l) => l.userId == userId).toList();
    return Paginated(
      items: filtered.take(limit).toList(),
      total: filtered.length,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<List<ActivityLog>> getEntityLogs(
    String entityType,
    String entityId,
  ) async {
    return _logs
        .where((l) => l.entityType == entityType && l.entityId == entityId)
        .toList();
  }

  @override
  Future<ActivityLog> logActivity({
    String? storeId,
    String? userId,
    required String action,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? details,
  }) async {
    final log = ActivityLog(
      id: 'log-${_logs.length + 1}',
      storeId: storeId,
      userId: userId,
      action: action,
      entityType: entityType,
      entityId: entityId,
      details: details,
      createdAt: DateTime.now(),
    );
    _logs.add(log);
    return log;
  }

  @override
  Future<List<ActivitySummary>> getActivitySummary(
    String storeId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return [
      ActivitySummary(
        action: 'create_order',
        count: 10,
        lastOccurrence: DateTime.now(),
      ),
      ActivitySummary(
        action: 'update_product',
        count: 5,
        lastOccurrence: DateTime.now(),
      ),
    ];
  }
}

void main() {
  late ActivityLogService activityLogService;
  late FakeActivityLogsRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeActivityLogsRepository();
    activityLogService = ActivityLogService(fakeRepo);
  });

  group('ActivityLogService', () {
    test('should be created', () {
      expect(activityLogService, isNotNull);
    });

    group('logActivity', () {
      test('should log an activity', () async {
        final log = await activityLogService.logActivity(
          storeId: 'store-1',
          userId: 'user-1',
          action: 'create_order',
          entityType: 'order',
          entityId: 'order-1',
          details: {'total': 100.0},
        );

        expect(log.id, isNotEmpty);
        expect(log.action, equals('create_order'));
        expect(log.entityType, equals('order'));
      });
    });

    group('getStoreLogs', () {
      test('should return store logs', () async {
        await activityLogService.logActivity(
          storeId: 'store-1',
          userId: 'user-1',
          action: 'create_order',
        );
        await activityLogService.logActivity(
          storeId: 'store-1',
          userId: 'user-2',
          action: 'update_product',
        );

        final result = await activityLogService.getStoreLogs('store-1');
        expect(result.items, hasLength(2));
      });

      test('should filter by action', () async {
        await activityLogService.logActivity(
          storeId: 'store-1',
          action: 'create_order',
        );
        await activityLogService.logActivity(
          storeId: 'store-1',
          action: 'delete_product',
        );

        final result = await activityLogService.getStoreLogs(
          'store-1',
          action: 'create_order',
        );
        expect(result.items, hasLength(1));
        expect(result.items.first.action, equals('create_order'));
      });
    });

    group('getUserLogs', () {
      test('should return logs for specific user', () async {
        await activityLogService.logActivity(
          storeId: 'store-1',
          userId: 'user-1',
          action: 'login',
        );
        await activityLogService.logActivity(
          storeId: 'store-1',
          userId: 'user-2',
          action: 'login',
        );

        final result = await activityLogService.getUserLogs('user-1');
        expect(result.items, hasLength(1));
      });
    });

    group('getEntityLogs', () {
      test('should return logs for specific entity', () async {
        await activityLogService.logActivity(
          storeId: 'store-1',
          action: 'update_product',
          entityType: 'product',
          entityId: 'prod-1',
        );

        final logs = await activityLogService.getEntityLogs(
          'product',
          'prod-1',
        );
        expect(logs, hasLength(1));
      });
    });

    group('getActivitySummary', () {
      test('should return summary', () async {
        final summary = await activityLogService.getActivitySummary(
          'store-1',
          startDate: DateTime(2026, 3, 1),
          endDate: DateTime(2026, 3, 31),
        );
        expect(summary, isNotEmpty);
        expect(summary.first.action, equals('create_order'));
        expect(summary.first.count, equals(10));
      });
    });
  });
}
