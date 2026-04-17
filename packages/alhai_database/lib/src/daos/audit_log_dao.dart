import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../constants/retention_policy.dart';
import '../tables/audit_log_table.dart';

part 'audit_log_dao.g.dart';

/// Metadata key injected into audit payloads for the tamper-evident hash chain.
///
/// The presence of this key in `newValue` JSON signals that the row is part
/// of the hash chain and can be verified via [AuditLogDao.verifyChain].
/// Legacy rows without this key are skipped during verification.
const String kAuditHashMetaKey = '__meta__';

/// Current version of the hash-chain canonicalization scheme.
/// Bump this if the canonical JSON format changes (e.g. adding fields).
const int kAuditHashVersion = 1;

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

  /// Monotonic sequence counter to disambiguate audit rows created within
  /// the same millisecond. Ensures strict append order for the hash chain.
  static int _chainSeq = 0;

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

  /// LEGAL WARNING: This cleanup MUST respect Saudi VAT Law Article 66.
  /// Records must be retained for minimum 6 years.
  /// DO NOT reduce retention without legal review.
  Future<int> cleanupOldLogs({
    Duration olderThan = RetentionPolicy.auditLogRetention,
  }) {
    assert(
      olderThan.inDays >= RetentionPolicy.auditLogRetention.inDays,
      'CRITICAL: Audit log retention must be >= 6 years per Saudi VAT law',
    );
    final cutoff = DateTime.now().subtract(olderThan);
    return (delete(auditLogTable)..where(
          (l) =>
              l.syncedAt.isNotNull() & l.createdAt.isSmallerThanValue(cutoff),
        ))
        .go();
  }

  // ==================== Tamper-evident hash chain (ZATCA) ====================
  //
  // Every audit entry appended via [appendLogWithHashChain] carries:
  //   - contentHash:  SHA-256 of the canonical JSON payload + chain fields
  //   - previousHash: the prior row's contentHash (or '' for the first row)
  //
  // Storage strategy: hashes live INSIDE the newValue JSON under a `__meta__`
  // envelope. No schema bump, no migration, no Drift codegen.
  //
  // [verifyChain] walks rows oldest-to-newest recomputing each hash to detect
  // tampering. Returns the first broken row id, or null if the chain is intact.

  /// Appends a new audit entry with tamper-evident hash chain.
  ///
  /// [payload] is the business data (stored in newValue JSON). The hash
  /// metadata is auto-attached under the `__meta__` key. Returns the new
  /// row's id.
  ///
  /// The caller can optionally pass [oldValue] / [entityType] / [entityId] /
  /// [description] for parity with the legacy [log] method. Only [payload]
  /// participates in the canonical hash.
  Future<String> appendLogWithHashChain({
    required String storeId,
    required String userId,
    required String userName,
    required AuditAction action,
    required Map<String, dynamic> payload,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? oldValue,
    String? description,
    String? ipAddress,
    String? deviceInfo,
    DateTime? timestamp,
  }) async {
    final rand = Random().nextInt(999999).toString().padLeft(6, '0');
    final now = timestamp ?? DateTime.now();
    // Monotonic 6-digit suffix ensures rows created within the same
    // millisecond retain strict insertion order under lexical id sort —
    // critical for hash-chain verification.
    final seq = (++_chainSeq).toString().padLeft(12, '0');
    final id = '${now.millisecondsSinceEpoch}_${seq}_${action.name}_$rand';
    final ts = now.toUtc().toIso8601String();

    // Fetch the most recent contentHash (chain tail).
    final lastHash = await _getLastContentHash(storeId: storeId);

    // Build the canonical envelope that participates in the hash.
    final canonical = _canonicalJson({
      'tableName': 'audit_log',
      'recordId': id,
      'operation': action.name,
      'payload': payload,
      'previousHash': lastHash,
      'timestamp': ts,
    });

    final contentHash = sha256.convert(utf8.encode(canonical)).toString();

    // Augment payload with hash metadata — stored inside newValue JSON.
    final enrichedPayload = <String, dynamic>{
      ...payload,
      kAuditHashMetaKey: <String, dynamic>{
        'contentHash': contentHash,
        'previousHash': lastHash,
        'hashVersion': kAuditHashVersion,
        'timestamp': ts,
      },
    };

    await into(auditLogTable).insert(
      AuditLogTableCompanion.insert(
        id: id,
        storeId: storeId,
        userId: userId,
        userName: userName,
        action: action.name,
        entityType: Value(entityType),
        entityId: Value(entityId),
        oldValue: Value(oldValue != null ? jsonEncode(oldValue) : null),
        newValue: Value(jsonEncode(enrichedPayload)),
        description: Value(description),
        ipAddress: Value(ipAddress),
        deviceInfo: Value(deviceInfo),
        createdAt: now,
      ),
    );

    return id;
  }

  /// Walks the log from oldest to newest, recomputing hashes to detect tampering.
  ///
  /// Returns the id of the first row whose stored hash no longer matches the
  /// recomputed value, or `null` if the chain is intact.
  ///
  /// Legacy rows (without the `__meta__` envelope) are skipped — they break
  /// no invariants but do not contribute to chain integrity.
  ///
  /// Pass [storeId] to verify a single store's chain (recommended), or omit
  /// to verify globally.
  Future<String?> verifyChain({String? storeId}) async {
    final query = select(auditLogTable);
    if (storeId != null) {
      query.where((l) => l.storeId.equals(storeId));
    }
    query.orderBy([
      (l) => OrderingTerm.asc(l.createdAt),
      (l) => OrderingTerm.asc(l.id),
    ]);
    final rows = await query.get();

    String lastHash = '';

    for (final row in rows) {
      final newValueStr = row.newValue;
      if (newValueStr == null || newValueStr.isEmpty) continue;

      final Map<String, dynamic> decoded;
      try {
        decoded = jsonDecode(newValueStr) as Map<String, dynamic>;
      } catch (_) {
        continue; // malformed JSON — skip (not a chain row)
      }

      final meta = decoded[kAuditHashMetaKey];
      if (meta is! Map<String, dynamic>) continue; // legacy row — skip

      final storedPreviousHash = meta['previousHash'] as String? ?? '';
      final storedContentHash = meta['contentHash'] as String? ?? '';
      final storedTimestamp = meta['timestamp'] as String? ?? '';

      // Chain link broken: previousHash must match the tail.
      if (storedPreviousHash != lastHash) return row.id;

      // Recompute the canonical JSON sans the injected __meta__.
      final payloadCopy = Map<String, dynamic>.from(decoded)
        ..remove(kAuditHashMetaKey);

      final canonical = _canonicalJson({
        'tableName': 'audit_log',
        'recordId': row.id,
        'operation': row.action,
        'payload': payloadCopy,
        'previousHash': storedPreviousHash,
        'timestamp': storedTimestamp,
      });
      final recomputed = sha256.convert(utf8.encode(canonical)).toString();

      if (recomputed != storedContentHash) return row.id;

      lastHash = storedContentHash;
    }

    return null; // chain intact
  }

  // ==================== Hash-chain helpers ====================

  /// Deterministic JSON serialization: keys sorted alphabetically at every
  /// level. Required so that two runs with the same input produce identical
  /// bytes (and therefore identical hashes).
  ///
  /// Handles: Map (recursed with sorted keys), List (element-wise), primitives
  /// (via [jsonEncode]).
  static String _canonicalJson(Object? value) {
    if (value is Map) {
      final sortedKeys = value.keys.map((k) => k.toString()).toList()..sort();
      final buffer = StringBuffer('{');
      for (int i = 0; i < sortedKeys.length; i++) {
        if (i > 0) buffer.write(',');
        final k = sortedKeys[i];
        buffer
          ..write(jsonEncode(k))
          ..write(':')
          ..write(_canonicalJson(value[k]));
      }
      buffer.write('}');
      return buffer.toString();
    }
    if (value is List) {
      final buffer = StringBuffer('[');
      for (int i = 0; i < value.length; i++) {
        if (i > 0) buffer.write(',');
        buffer.write(_canonicalJson(value[i]));
      }
      buffer.write(']');
      return buffer.toString();
    }
    return jsonEncode(value);
  }

  /// Returns the contentHash of the most-recent chain row (scoped by
  /// [storeId] if given), or `''` if no chain row exists.
  ///
  /// Walks from newest to oldest looking for the first row that carries a
  /// `__meta__` envelope — this tolerates interleaved legacy rows without
  /// breaking the chain.
  Future<String> _getLastContentHash({String? storeId}) async {
    final query = select(auditLogTable);
    if (storeId != null) {
      query.where((l) => l.storeId.equals(storeId));
    }
    query.orderBy([
      (l) => OrderingTerm.desc(l.createdAt),
      (l) => OrderingTerm.desc(l.id),
    ]);
    final rows = await query.get();

    for (final row in rows) {
      final nv = row.newValue;
      if (nv == null || nv.isEmpty) continue;
      try {
        final decoded = jsonDecode(nv) as Map<String, dynamic>;
        final meta = decoded[kAuditHashMetaKey];
        if (meta is Map<String, dynamic>) {
          final h = meta['contentHash'] as String?;
          if (h != null && h.isNotEmpty) return h;
        }
      } catch (_) {
        // ignore malformed rows
      }
    }
    return '';
  }

  /// Canonical JSON for testing / external verification tools.
  /// Exposed so chain verifiers outside the DAO can mirror our hashing logic.
  /// Prefer [appendLogWithHashChain] in production code.
  static String canonicalJsonForTest(Object? value) => _canonicalJson(value);
}
