import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../../data/local/app_database.dart';
import '../../data/local/daos/sync_queue_dao.dart';

/// أنواع عمليات المزامنة
enum SyncOperation { create, update, delete }

/// أولوية المزامنة
enum SyncPriority { low, normal, high }

/// خدمة طابور المزامنة
/// تضيف العمليات للطابور المحلي ليتم مزامنتها لاحقاً
class SyncService {
  final SyncQueueDao _syncQueueDao;
  final _uuid = const Uuid();
  
  SyncService(this._syncQueueDao);
  
  /// إضافة عملية للطابور
  Future<String> enqueue({
    required String tableName,
    required String recordId,
    required SyncOperation operation,
    required Map<String, dynamic> payload,
    SyncPriority priority = SyncPriority.normal,
  }) async {
    final id = _uuid.v4();
    final idempotencyKey = '${tableName}_${recordId}_${operation.name}_${DateTime.now().millisecondsSinceEpoch}';
    
    // التحقق من عدم وجود نفس العملية
    final existing = await _syncQueueDao.findByIdempotencyKey(idempotencyKey);
    if (existing != null) {
      return existing.id;
    }
    
    await _syncQueueDao.enqueue(
      id: id,
      tableName: tableName,
      recordId: recordId,
      operation: operation.name.toUpperCase(),
      payload: jsonEncode(payload),
      idempotencyKey: idempotencyKey,
      priority: _priorityToInt(priority),
    );
    
    return id;
  }
  
  /// إضافة عملية إنشاء
  Future<String> enqueueCreate({
    required String tableName,
    required String recordId,
    required Map<String, dynamic> data,
    SyncPriority priority = SyncPriority.normal,
  }) {
    return enqueue(
      tableName: tableName,
      recordId: recordId,
      operation: SyncOperation.create,
      payload: data,
      priority: priority,
    );
  }
  
  /// إضافة عملية تحديث
  Future<String> enqueueUpdate({
    required String tableName,
    required String recordId,
    required Map<String, dynamic> changes,
    SyncPriority priority = SyncPriority.normal,
  }) {
    return enqueue(
      tableName: tableName,
      recordId: recordId,
      operation: SyncOperation.update,
      payload: changes,
      priority: priority,
    );
  }
  
  /// إضافة عملية حذف
  Future<String> enqueueDelete({
    required String tableName,
    required String recordId,
    SyncPriority priority = SyncPriority.normal,
  }) {
    return enqueue(
      tableName: tableName,
      recordId: recordId,
      operation: SyncOperation.delete,
      payload: {'deleted': true},
      priority: priority,
    );
  }
  
  /// الحصول على العناصر المعلقة
  Future<List<SyncQueueTableData>> getPendingItems() {
    return _syncQueueDao.getPendingItems();
  }
  
  /// عدد العناصر المعلقة
  Future<int> getPendingCount() {
    return _syncQueueDao.getPendingCount();
  }
  
  /// مراقبة العناصر المعلقة
  Stream<int> watchPendingCount() {
    return _syncQueueDao.watchPendingCount();
  }
  
  /// تعيين كـ "جاري المزامنة"
  Future<void> markAsSyncing(String id) {
    return _syncQueueDao.markAsSyncing(id);
  }
  
  /// تعيين كـ "تمت المزامنة"
  Future<void> markAsSynced(String id) {
    return _syncQueueDao.markAsSynced(id);
  }
  
  /// تعيين كـ "فشل"
  Future<void> markAsFailed(String id, String error) {
    return _syncQueueDao.markAsFailed(id, error);
  }
  
  /// حذف عنصر
  Future<void> removeItem(String id) {
    return _syncQueueDao.removeItem(id);
  }
  
  /// تنظيف العناصر القديمة
  Future<int> cleanup({Duration olderThan = const Duration(days: 7)}) {
    return _syncQueueDao.cleanupSyncedItems(olderThan: olderThan);
  }
  
  int _priorityToInt(SyncPriority priority) {
    switch (priority) {
      case SyncPriority.low:
        return 1;
      case SyncPriority.normal:
        return 2;
      case SyncPriority.high:
        return 3;
    }
  }
}
