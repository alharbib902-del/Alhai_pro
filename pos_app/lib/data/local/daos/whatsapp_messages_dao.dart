import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/whatsapp_messages_table.dart';

part 'whatsapp_messages_dao.g.dart';

/// DAO لرسائل واتساب
///
/// يوفر جميع عمليات CRUD + المراقبة لجدول whatsapp_messages.
/// يتبع نفس نمط SyncQueueDao.
@DriftAccessor(tables: [WhatsAppMessagesTable])
class WhatsAppMessagesDao extends DatabaseAccessor<AppDatabase>
    with _$WhatsAppMessagesDaoMixin {
  WhatsAppMessagesDao(super.db);

  // ═══════════════════════════════════════════════════════
  // إضافة رسالة للطابور
  // ═══════════════════════════════════════════════════════

  /// إضافة رسالة جديدة للطابور
  Future<int> enqueue(WhatsAppMessagesTableCompanion message) {
    return into(whatsAppMessagesTable).insert(message);
  }

  // ═══════════════════════════════════════════════════════
  // الحصول على الرسائل المعلّقة
  // ═══════════════════════════════════════════════════════

  /// الحصول على الرسائل المعلّقة مرتّبة بالأولوية
  Future<List<WhatsAppMessagesTableData>> getPendingMessages() {
    return (select(whatsAppMessagesTable)
          ..where(
            (q) =>
                q.status.equals('pending') |
                (q.status.equals('failed') &
                    q.retryCount.isSmallerThan(q.maxRetries)),
          )
          ..orderBy([
            (q) => OrderingTerm.desc(q.priority),
            (q) => OrderingTerm.asc(q.createdAt),
          ])
          ..limit(20))
        .get();
  }

  /// عدد الرسائل المعلّقة
  Future<int> getPendingCount() async {
    final result = await customSelect(
      '''SELECT COUNT(*) as count FROM whatsapp_messages
         WHERE status IN ('pending', 'uploading', 'sending')
         OR (status = 'failed' AND retry_count < max_retries)''',
    ).getSingle();
    return result.data['count'] as int? ?? 0;
  }

  /// مراقبة عدد المعلّقة (للـ UI badges)
  Stream<int> watchPendingCount() {
    return customSelect(
      '''SELECT COUNT(*) as count FROM whatsapp_messages
         WHERE status IN ('pending', 'uploading', 'sending')
         OR (status = 'failed' AND retry_count < max_retries)''',
      readsFrom: {whatsAppMessagesTable},
    ).map((row) => row.data['count'] as int? ?? 0).watchSingle();
  }

  // ═══════════════════════════════════════════════════════
  // تحديث الحالة
  // ═══════════════════════════════════════════════════════

  /// تحديث إلى "جاري الرفع"
  Future<int> markAsUploading(String id) {
    return (update(whatsAppMessagesTable)
          ..where((q) => q.id.equals(id)))
        .write(WhatsAppMessagesTableCompanion(
      status: const Value('uploading'),
      lastAttemptAt: Value(DateTime.now()),
    ));
  }

  /// تحديث إلى "جاري الإرسال"
  Future<int> markAsSending(String id) {
    return (update(whatsAppMessagesTable)
          ..where((q) => q.id.equals(id)))
        .write(WhatsAppMessagesTableCompanion(
      status: const Value('sending'),
      lastAttemptAt: Value(DateTime.now()),
    ));
  }

  /// تحديث إلى "تم الإرسال"
  Future<int> markAsSent(String id, String externalMsgId) {
    return (update(whatsAppMessagesTable)
          ..where((q) => q.id.equals(id)))
        .write(WhatsAppMessagesTableCompanion(
      status: const Value('sent'),
      externalMsgId: Value(externalMsgId),
      sentAt: Value(DateTime.now()),
    ));
  }

  /// تحديث إلى "تم التوصيل"
  Future<int> markAsDelivered(String id) {
    return (update(whatsAppMessagesTable)
          ..where((q) => q.id.equals(id)))
        .write(WhatsAppMessagesTableCompanion(
      status: const Value('delivered'),
      deliveredAt: Value(DateTime.now()),
    ));
  }

  /// تحديث إلى "تم القراءة"
  Future<int> markAsRead(String id) {
    return (update(whatsAppMessagesTable)
          ..where((q) => q.id.equals(id)))
        .write(WhatsAppMessagesTableCompanion(
      status: const Value('read'),
      readAt: Value(DateTime.now()),
    ));
  }

  /// تحديث إلى "فشل"
  Future<int> markAsFailed(String id, String error) {
    return customUpdate(
      '''UPDATE whatsapp_messages
         SET status = ?, last_error = ?, retry_count = retry_count + 1,
             last_attempt_at = ?
         WHERE id = ?''',
      variables: [
        const Variable('failed'),
        Variable.withString(error),
        Variable.withDateTime(DateTime.now()),
        Variable.withString(id),
      ],
      updates: {whatsAppMessagesTable},
      updateKind: UpdateKind.update,
    );
  }

  /// تحديث رابط الوسائط بعد الرفع
  Future<int> updateMediaUrl(String id, String mediaUrl) {
    return (update(whatsAppMessagesTable)
          ..where((q) => q.id.equals(id)))
        .write(WhatsAppMessagesTableCompanion(
      mediaUrl: Value(mediaUrl),
    ));
  }

  // ═══════════════════════════════════════════════════════
  // البحث
  // ═══════════════════════════════════════════════════════

  /// البحث بمعرف الرسالة الخارجي (للـ webhooks)
  Future<WhatsAppMessagesTableData?> findByExternalMsgId(
    String externalMsgId,
  ) {
    return (select(whatsAppMessagesTable)
          ..where((q) => q.externalMsgId.equals(externalMsgId)))
        .getSingleOrNull();
  }

  /// الحصول على رسائل عميل
  Future<List<WhatsAppMessagesTableData>> getByCustomer(String customerId) {
    return (select(whatsAppMessagesTable)
          ..where((q) => q.customerId.equals(customerId))
          ..orderBy([(q) => OrderingTerm.desc(q.createdAt)]))
        .get();
  }

  /// الحصول على رسائل حسب المرجع (مثل: كل رسائل فاتورة معينة)
  Future<List<WhatsAppMessagesTableData>> getByReference(
    String referenceType,
    String referenceId,
  ) {
    return (select(whatsAppMessagesTable)
          ..where(
            (q) =>
                q.referenceType.equals(referenceType) &
                q.referenceId.equals(referenceId),
          )
          ..orderBy([(q) => OrderingTerm.desc(q.createdAt)]))
        .get();
  }

  /// الحصول على رسائل دفعة جماعية
  Future<List<WhatsAppMessagesTableData>> getByBatchId(String batchId) {
    return (select(whatsAppMessagesTable)
          ..where((q) => q.batchId.equals(batchId))
          ..orderBy([(q) => OrderingTerm.asc(q.createdAt)]))
        .get();
  }

  // ═══════════════════════════════════════════════════════
  // المراقبة (Streams)
  // ═══════════════════════════════════════════════════════

  /// مراقبة الرسائل مع فلتر اختياري
  Stream<List<WhatsAppMessagesTableData>> watchMessages({
    String? status,
    String? referenceType,
  }) {
    var query = select(whatsAppMessagesTable);

    if (status != null) {
      query = query..where((q) => q.status.equals(status));
    }
    if (referenceType != null) {
      query = query..where((q) => q.referenceType.equals(referenceType));
    }

    return (query..orderBy([(q) => OrderingTerm.desc(q.createdAt)])).watch();
  }

  /// مراقبة إحصائيات الحالات
  Stream<Map<String, int>> watchStatusCounts() {
    return customSelect(
      '''SELECT status, COUNT(*) as count
         FROM whatsapp_messages
         GROUP BY status''',
      readsFrom: {whatsAppMessagesTable},
    ).watch().map((rows) {
      final counts = <String, int>{};
      for (final row in rows) {
        counts[row.data['status'] as String] = row.data['count'] as int;
      }
      return counts;
    });
  }

  /// مراقبة تقدم دفعة جماعية
  Stream<Map<String, int>> watchBatchProgress(String batchId) {
    return customSelect(
      '''SELECT status, COUNT(*) as count
         FROM whatsapp_messages
         WHERE batch_id = ?
         GROUP BY status''',
      variables: [Variable.withString(batchId)],
      readsFrom: {whatsAppMessagesTable},
    ).watch().map((rows) {
      final counts = <String, int>{};
      for (final row in rows) {
        counts[row.data['status'] as String] = row.data['count'] as int;
      }
      return counts;
    });
  }

  // ═══════════════════════════════════════════════════════
  // إعادة المحاولة والصيانة
  // ═══════════════════════════════════════════════════════

  /// إعادة تعيين رسالة فاشلة للمحاولة مرة أخرى
  Future<int> retryMessage(String id) {
    return (update(whatsAppMessagesTable)
          ..where((q) => q.id.equals(id)))
        .write(const WhatsAppMessagesTableCompanion(
      status: Value('pending'),
      retryCount: Value(0),
      lastError: Value(null),
    ));
  }

  /// إلغاء رسائل معلّقة في دفعة
  Future<int> cancelBatch(String batchId) {
    return (delete(whatsAppMessagesTable)
          ..where(
            (q) => q.batchId.equals(batchId) & q.status.equals('pending'),
          ))
        .go();
  }

  /// تنظيف الرسائل القديمة المكتملة
  Future<int> cleanupOldMessages({
    Duration olderThan = const Duration(days: 30),
  }) {
    final cutoff = DateTime.now().subtract(olderThan);
    return (delete(whatsAppMessagesTable)
          ..where(
            (q) =>
                q.status.isIn(['sent', 'delivered', 'read']) &
                q.createdAt.isSmallerThanValue(cutoff),
          ))
        .go();
  }

  /// تنظيف جميع الرسائل القديمة (مكتملة + فاشلة نهائياً)
  ///
  /// يحذف الرسائل الأقدم من [olderThan] التي لم تعد بحاجة لمعالجة.
  Future<int> deleteOlderThan({
    Duration olderThan = const Duration(days: 90),
  }) {
    final cutoff = DateTime.now().subtract(olderThan);
    return customUpdate(
      '''DELETE FROM whatsapp_messages
         WHERE created_at < ?
         AND (status IN ('sent', 'delivered', 'read')
              OR (status = 'failed' AND retry_count >= max_retries))''',
      variables: [Variable.withDateTime(cutoff)],
      updates: {whatsAppMessagesTable},
      updateKind: UpdateKind.delete,
    );
  }

  /// البحث عن رسالة مكررة حديثة
  ///
  /// يتحقق هل يوجد رسالة لنفس الرقم والمرجع خلال [within].
  Future<WhatsAppMessagesTableData?> findRecentDuplicate({
    required String phone,
    required String referenceType,
    required String referenceId,
    Duration within = const Duration(minutes: 5),
  }) {
    final cutoff = DateTime.now().subtract(within);
    return (select(whatsAppMessagesTable)
          ..where(
            (q) =>
                q.phone.equals(phone) &
                q.referenceType.equals(referenceType) &
                q.referenceId.equals(referenceId) &
                q.createdAt.isBiggerOrEqualValue(cutoff),
          )
          ..limit(1))
        .getSingleOrNull();
  }

  /// الحصول على إحصائيات الحالات (لمرة واحدة)
  Future<Map<String, int>> getStatusCounts() async {
    final result = await customSelect(
      '''SELECT status, COUNT(*) as count
         FROM whatsapp_messages
         GROUP BY status''',
    ).get();

    final counts = <String, int>{};
    for (final row in result) {
      counts[row.data['status'] as String] = row.data['count'] as int;
    }
    return counts;
  }

  /// الحصول على جميع الرسائل (للعرض الشامل)
  Future<List<WhatsAppMessagesTableData>> getAllMessages({
    int limit = 100,
    int offset = 0,
  }) {
    return (select(whatsAppMessagesTable)
          ..orderBy([(q) => OrderingTerm.desc(q.createdAt)])
          ..limit(limit, offset: offset))
        .get();
  }

  /// حذف رسالة بالمعرف
  Future<int> removeMessage(String id) {
    return (delete(whatsAppMessagesTable)..where((q) => q.id.equals(id))).go();
  }
}
