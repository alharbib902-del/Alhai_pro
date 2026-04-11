import 'dart:convert';
import 'dart:math';
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/audit_log_table.dart';

part 'audit_log_dao.g.dart';

/// أنواع العمليات في سجل التدقيق
enum AuditAction {
  // المصادقة
  login,
  logout,

  // المبيعات
  saleCreate,
  saleCancel,
  saleRefund,

  // المنتجات
  productCreate,
  productEdit,
  productDelete,
  priceChange,

  // المخزون
  stockAdjust,
  stockReceive,

  // العملاء
  customerCreate,
  customerEdit,
  paymentRecord,

  // الوردية
  shiftOpen,
  shiftClose,
  cashDrawerOpen,

  // الطلبات
  orderStatusChange,
  orderCancel,

  // الإعدادات
  settingsChange,
  interestApply,
}

/// DAO لسجل التدقيق
@DriftAccessor(tables: [AuditLogTable])
class AuditLogDao extends DatabaseAccessor<AppDatabase>
    with _$AuditLogDaoMixin {
  AuditLogDao(super.db);

  // ==================== إضافة سجلات ====================

  /// تسجيل عملية جديدة
  Future<int> log({
    required String storeId,
    required String userId,
    required String userName,
    required AuditAction action,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? oldValue,
    Map<String, dynamic>? newValue,
    String? description,
    String? ipAddress,
    String? deviceInfo,
  }) {
    final rand = Random().nextInt(999999).toString().padLeft(6, '0');
    final id = '${DateTime.now().millisecondsSinceEpoch}_${action.name}_$rand';

    return into(auditLogTable).insert(
      AuditLogTableCompanion.insert(
        id: id,
        storeId: storeId,
        userId: userId,
        userName: userName,
        action: action.name,
        entityType: Value(entityType),
        entityId: Value(entityId),
        oldValue: Value(oldValue != null ? jsonEncode(oldValue) : null),
        newValue: Value(newValue != null ? jsonEncode(newValue) : null),
        description: Value(description),
        ipAddress: Value(ipAddress),
        deviceInfo: Value(deviceInfo),
        createdAt: DateTime.now(),
      ),
    );
  }

  /// تسجيل تسجيل دخول
  Future<int> logLogin(String storeId, String userId, String userName) {
    return log(
      storeId: storeId,
      userId: userId,
      userName: userName,
      action: AuditAction.login,
      description: 'تسجيل دخول',
    );
  }

  /// تسجيل تسجيل خروج
  Future<int> logLogout(String storeId, String userId, String userName) {
    return log(
      storeId: storeId,
      userId: userId,
      userName: userName,
      action: AuditAction.logout,
      description: 'تسجيل خروج',
    );
  }

  /// تسجيل تغيير سعر
  Future<int> logPriceChange({
    required String storeId,
    required String userId,
    required String userName,
    required String productId,
    required String productName,
    required double oldPrice,
    required double newPrice,
  }) {
    return log(
      storeId: storeId,
      userId: userId,
      userName: userName,
      action: AuditAction.priceChange,
      entityType: 'product',
      entityId: productId,
      oldValue: {'price': oldPrice},
      newValue: {'price': newPrice},
      description: 'تغيير سعر $productName من $oldPrice إلى $newPrice',
    );
  }

  /// تسجيل تعديل مخزون
  Future<int> logStockAdjust({
    required String storeId,
    required String userId,
    required String userName,
    required String productId,
    required String productName,
    required double oldQty,
    required double newQty,
    required String reason,
  }) {
    return log(
      storeId: storeId,
      userId: userId,
      userName: userName,
      action: AuditAction.stockAdjust,
      entityType: 'product',
      entityId: productId,
      oldValue: {'quantity': oldQty},
      newValue: {'quantity': newQty},
      description: '$reason: تعديل كمية $productName من $oldQty إلى $newQty',
    );
  }

  /// تسجيل مرتجع
  Future<int> logRefund({
    required String storeId,
    required String userId,
    required String userName,
    required String saleId,
    required double amount,
    required String reason,
  }) {
    return log(
      storeId: storeId,
      userId: userId,
      userName: userName,
      action: AuditAction.saleRefund,
      entityType: 'sale',
      entityId: saleId,
      newValue: {'amount': amount, 'reason': reason},
      description: 'مرتجع بمبلغ $amount ر.س - $reason',
    );
  }

  // ==================== استعلامات ====================

  /// جلب سجلات متجر معين
  Future<List<AuditLogTableData>> getLogs(String storeId, {int limit = 100}) {
    return (select(auditLogTable)
          ..where((l) => l.storeId.equals(storeId))
          ..orderBy([(l) => OrderingTerm.desc(l.createdAt)])
          ..limit(limit))
        .get();
  }

  /// جلب سجلات بفلتر التاريخ
  Future<List<AuditLogTableData>> getLogsByDateRange(
    String storeId,
    DateTime from,
    DateTime to,
  ) {
    return (select(auditLogTable)
          ..where(
            (l) =>
                l.storeId.equals(storeId) &
                l.createdAt.isBiggerOrEqualValue(from) &
                l.createdAt.isSmallerOrEqualValue(to),
          )
          ..orderBy([(l) => OrderingTerm.desc(l.createdAt)]))
        .get();
  }

  /// جلب سجلات حسب نوع العملية
  Future<List<AuditLogTableData>> getLogsByAction(
    String storeId,
    AuditAction action,
  ) {
    return (select(auditLogTable)
          ..where(
            (l) => l.storeId.equals(storeId) & l.action.equals(action.name),
          )
          ..orderBy([(l) => OrderingTerm.desc(l.createdAt)]))
        .get();
  }

  /// جلب سجلات مستخدم معين
  Future<List<AuditLogTableData>> getLogsByUser(String storeId, String userId) {
    return (select(auditLogTable)
          ..where((l) => l.storeId.equals(storeId) & l.userId.equals(userId))
          ..orderBy([(l) => OrderingTerm.desc(l.createdAt)]))
        .get();
  }

  /// جلب السجلات غير المزامنة
  Future<List<AuditLogTableData>> getUnsyncedLogs() {
    return (select(auditLogTable)
          ..where((l) => l.syncedAt.isNull())
          ..orderBy([(l) => OrderingTerm.asc(l.createdAt)]))
        .get();
  }

  /// تحديد السجلات كمزامنة
  Future<int> markAsSynced(List<String> ids) {
    return (update(auditLogTable)..where((l) => l.id.isIn(ids))).write(
      AuditLogTableCompanion(syncedAt: Value(DateTime.now())),
    );
  }

  /// حذف السجلات المزامنة القديمة (أقدم من المدة المحددة)
  Future<int> cleanupOldLogs({Duration olderThan = const Duration(days: 90)}) {
    final cutoff = DateTime.now().subtract(olderThan);
    return (delete(auditLogTable)..where(
          (l) =>
              l.syncedAt.isNotNull() & l.createdAt.isSmallerThanValue(cutoff),
        ))
        .go();
  }
}
