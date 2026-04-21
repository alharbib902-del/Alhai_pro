import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/zatca_dead_letter_table.dart';
import '../tables/zatca_offline_queue_table.dart';

part 'zatca_offline_queue_dao.g.dart';

/// DAO لطابور فواتير ZATCA الـ offline + dead-letter
///
/// جدولان منفصلان:
///   - zatca_offline_queue: الفواتير النشطة (قابلة لإعادة المحاولة)
///   - zatca_dead_letter:   الفواتير اللي استنفدت المحاولات (للمراجعة)
///
/// الانتقال بين الجدولين atomic عبر moveToDeadLetter() باستخدام
/// transaction + INSERT + DELETE.
@DriftAccessor(tables: [ZatcaOfflineQueueTable, ZatcaDeadLetterTable])
class ZatcaOfflineQueueDao extends DatabaseAccessor<AppDatabase>
    with _$ZatcaOfflineQueueDaoMixin {
  ZatcaOfflineQueueDao(super.db);

  /// الحد الأقصى لعدد المحاولات قبل الانتقال لـ dead_letter
  static const int maxRetries = 10;

  /// الفترة الزمنية التي بعدها تُعتبر الفاتورة قديمة للـ cleanup
  static const Duration staleThreshold = Duration(days: 30);

  // ═══════════ قراءة (active queue) ═══════════

  /// جلب كل الفواتير النشطة في الـ queue
  Future<List<ZatcaOfflineQueueTableData>> getPending({String? storeId}) {
    final query = select(zatcaOfflineQueueTable)
      ..orderBy([(q) => OrderingTerm.asc(q.queuedAt)]);
    if (storeId != null) {
      query.where((q) => q.storeId.equals(storeId));
    }
    return query.get();
  }

  /// جلب فاتورة من الـ active queue برقمها
  Future<ZatcaOfflineQueueTableData?> getByInvoiceNumber(
    String invoiceNumber,
  ) =>
      (select(zatcaOfflineQueueTable)
            ..where((q) => q.invoiceNumber.equals(invoiceNumber)))
          .getSingleOrNull();

  /// عدد الفواتير النشطة
  Future<int> getPendingCount({String? storeId}) async {
    final countExpr = zatcaOfflineQueueTable.invoiceNumber.count();
    final query = selectOnly(zatcaOfflineQueueTable)
      ..addColumns([countExpr]);
    if (storeId != null) {
      query.where(zatcaOfflineQueueTable.storeId.equals(storeId));
    }
    final result = await query.getSingle();
    return result.read(countExpr) ?? 0;
  }

  // ═══════════ قراءة (dead-letter) ═══════════

  /// جلب فواتير dead_letter (للمراجعة اليدوية)
  Future<List<ZatcaDeadLetterTableData>> getDeadLetter({String? storeId}) {
    final query = select(zatcaDeadLetterTable)
      ..orderBy([(d) => OrderingTerm.desc(d.deadLetteredAt)]);
    if (storeId != null) {
      query.where((d) => d.storeId.equals(storeId));
    }
    return query.get();
  }

  /// جلب فاتورة من dead_letter برقمها
  Future<ZatcaDeadLetterTableData?> getDeadLetterByInvoiceNumber(
    String invoiceNumber,
  ) =>
      (select(zatcaDeadLetterTable)
            ..where((d) => d.invoiceNumber.equals(invoiceNumber)))
          .getSingleOrNull();

  /// عدد فواتير dead_letter
  Future<int> getDeadLetterCount({String? storeId}) async {
    final countExpr = zatcaDeadLetterTable.invoiceNumber.count();
    final query = selectOnly(zatcaDeadLetterTable)
      ..addColumns([countExpr]);
    if (storeId != null) {
      query.where(zatcaDeadLetterTable.storeId.equals(storeId));
    }
    final result = await query.getSingle();
    return result.read(countExpr) ?? 0;
  }

  // ═══════════ كتابة ═══════════

  /// إضافة/تحديث فاتورة في الـ active queue (UPSERT على invoice_number)
  ///
  /// - إذا كانت جديدة: INSERT مع retry_count=0
  /// - إذا كانت موجودة: UPDATE للحفاظ على retry_count الحالي
  ///   وتحديث الـ XML/hash فقط (الحالة المعتادة: إعادة توقيع)
  Future<void> upsert({
    required String invoiceNumber,
    required String uuid,
    required String storeId,
    required String signedXmlBase64,
    required String invoiceHash,
    required bool isStandard,
  }) async {
    final existing = await getByInvoiceNumber(invoiceNumber);
    if (existing == null) {
      await into(zatcaOfflineQueueTable).insert(
        ZatcaOfflineQueueTableCompanion(
          invoiceNumber: Value(invoiceNumber),
          uuid: Value(uuid),
          storeId: Value(storeId),
          signedXmlBase64: Value(signedXmlBase64),
          invoiceHash: Value(invoiceHash),
          isStandard: Value(isStandard),
          status: const Value('pending'),
          retryCount: const Value(0),
          queuedAt: Value(DateTime.now()),
        ),
      );
    } else {
      await (update(zatcaOfflineQueueTable)
            ..where((q) => q.invoiceNumber.equals(invoiceNumber)))
          .write(
        ZatcaOfflineQueueTableCompanion(
          signedXmlBase64: Value(signedXmlBase64),
          invoiceHash: Value(invoiceHash),
          isStandard: Value(isStandard),
        ),
      );
    }
  }

  /// حذف فاتورة من الـ active queue (بعد إرسال ناجح لـ ZATCA)
  Future<int> remove(String invoiceNumber) =>
      (delete(zatcaOfflineQueueTable)
            ..where((q) => q.invoiceNumber.equals(invoiceNumber)))
          .go();

  /// تسجيل محاولة فاشلة
  ///
  /// - إذا retryCount < maxRetries: يزيد العداد + يحدّث lastRetryAt في الـ queue
  /// - إذا يصل لـ maxRetries: ينقل الصف لـ dead_letter atomic (INSERT + DELETE)
  Future<void> recordRetry({
    required String invoiceNumber,
    String? lastError,
  }) async {
    final row = await getByInvoiceNumber(invoiceNumber);
    if (row == null) return;

    final newRetryCount = row.retryCount + 1;
    final now = DateTime.now();

    if (newRetryCount >= maxRetries) {
      // نقل الصف لـ dead_letter atomic
      await _moveToDeadLetter(
        row: row,
        finalRetryCount: newRetryCount,
        lastError: lastError,
        reason: 'max_retries',
        movedAt: now,
      );
    } else {
      // تحديث العداد في الـ queue فقط
      await (update(zatcaOfflineQueueTable)
            ..where((q) => q.invoiceNumber.equals(invoiceNumber)))
          .write(
        ZatcaOfflineQueueTableCompanion(
          retryCount: Value(newRetryCount),
          lastRetryAt: Value(now),
          lastError: Value(lastError),
        ),
      );
    }
  }

  /// نقل atomic من zatca_offline_queue → zatca_dead_letter
  ///
  /// داخل transaction — لو INSERT أو DELETE فشل، rollback كامل يضمن
  /// عدم فقدان السجل (ما ينتقل لا ينختفي من الاثنين).
  Future<void> _moveToDeadLetter({
    required ZatcaOfflineQueueTableData row,
    required int finalRetryCount,
    required String? lastError,
    required String reason,
    required DateTime movedAt,
  }) async {
    await transaction(() async {
      await into(zatcaDeadLetterTable).insert(
        ZatcaDeadLetterTableCompanion(
          invoiceNumber: Value(row.invoiceNumber),
          uuid: Value(row.uuid),
          storeId: Value(row.storeId),
          signedXmlBase64: Value(row.signedXmlBase64),
          invoiceHash: Value(row.invoiceHash),
          isStandard: Value(row.isStandard),
          retryCount: Value(finalRetryCount),
          lastError: Value(lastError ?? row.lastError),
          deadLetterReason: Value(reason),
          queuedAt: Value(row.queuedAt),
          lastRetryAt: Value(movedAt),
          deadLetteredAt: Value(movedAt),
        ),
      );
      await (delete(zatcaOfflineQueueTable)
            ..where((q) => q.invoiceNumber.equals(row.invoiceNumber)))
          .go();
    });
  }

  // ═══════════ Cleanup ═══════════

  /// نقل الفواتير القديمة (>30 يوم) والفاشلة (retryCount >= maxRetries)
  /// من الـ active queue إلى dead_letter.
  ///
  /// Returns عدد الصفوف اللي اتنقلت.
  Future<int> cleanupStaleToDeadLetter() async {
    final cutoff = DateTime.now().subtract(staleThreshold);
    final stale = await (select(zatcaOfflineQueueTable)
          ..where(
            (q) =>
                q.retryCount.isBiggerOrEqualValue(maxRetries) &
                q.queuedAt.isSmallerThanValue(cutoff),
          ))
        .get();

    if (stale.isEmpty) return 0;

    final now = DateTime.now();
    for (final row in stale) {
      await _moveToDeadLetter(
        row: row,
        finalRetryCount: row.retryCount,
        lastError: row.lastError,
        reason: 'stale',
        movedAt: now,
      );
    }
    return stale.length;
  }

  /// حذف يدوي لفاتورة من dead_letter (بعد المراجعة)
  Future<int> removeDeadLetter(String invoiceNumber) =>
      (delete(zatcaDeadLetterTable)
            ..where((d) => d.invoiceNumber.equals(invoiceNumber)))
          .go();

  /// حذف كل الـ dead_letter (للمسح اليدوي بعد المراجعة الكاملة)
  Future<int> purgeDeadLetter() => (delete(zatcaDeadLetterTable)).go();

  // ═══════════ Streams (للـ UI المباشر) ═══════════

  /// Stream لـ pending count (للـ UI indicator)
  Stream<int> watchPendingCount({String? storeId}) {
    final query = selectOnly(zatcaOfflineQueueTable)
      ..addColumns([zatcaOfflineQueueTable.invoiceNumber.count()]);
    if (storeId != null) {
      query.where(zatcaOfflineQueueTable.storeId.equals(storeId));
    }
    return query.watchSingle().map(
          (row) =>
              row.read(zatcaOfflineQueueTable.invoiceNumber.count()) ?? 0,
        );
  }

  /// Stream لـ dead_letter count (للـ admin UI)
  Stream<int> watchDeadLetterCount({String? storeId}) {
    final query = selectOnly(zatcaDeadLetterTable)
      ..addColumns([zatcaDeadLetterTable.invoiceNumber.count()]);
    if (storeId != null) {
      query.where(zatcaDeadLetterTable.storeId.equals(storeId));
    }
    return query.watchSingle().map(
          (row) =>
              row.read(zatcaDeadLetterTable.invoiceNumber.count()) ?? 0,
        );
  }
}
