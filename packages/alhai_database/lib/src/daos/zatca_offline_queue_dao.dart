import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/zatca_offline_queue_table.dart';

part 'zatca_offline_queue_dao.g.dart';

/// DAO لطابور فواتير ZATCA الـ offline
///
/// يحل محل JSON-blob على SharedPreferences. كل عملية enqueue/dequeue/retry
/// = صف واحد محدد بدل full-rewrite.
///
/// Statuses:
///   - pending: الفاتورة قابلة لإعادة المحاولة
///   - dead_letter: استنفدت المحاولات ومعلّقة للمراجعة اليدوية
@DriftAccessor(tables: [ZatcaOfflineQueueTable])
class ZatcaOfflineQueueDao extends DatabaseAccessor<AppDatabase>
    with _$ZatcaOfflineQueueDaoMixin {
  ZatcaOfflineQueueDao(super.db);

  /// الحد الأقصى لعدد المحاولات قبل الانتقال لـ dead_letter
  static const int maxRetries = 10;

  /// الفترة الزمنية التي بعدها تُعتبر الفاتورة قديمة للـ cleanup
  static const Duration staleThreshold = Duration(days: 30);

  // ═══════════ قراءة ═══════════

  /// جلب كل الفواتير المعلّقة (pending) للمتجر
  Future<List<ZatcaOfflineQueueTableData>> getPending({String? storeId}) {
    final query = select(zatcaOfflineQueueTable)
      ..where((q) => q.status.equals('pending'))
      ..orderBy([(q) => OrderingTerm.asc(q.queuedAt)]);
    if (storeId != null) {
      query.where((q) => q.storeId.equals(storeId));
    }
    return query.get();
  }

  /// جلب فواتير dead_letter (للمراجعة اليدوية)
  Future<List<ZatcaOfflineQueueTableData>> getDeadLetter({String? storeId}) {
    final query = select(zatcaOfflineQueueTable)
      ..where((q) => q.status.equals('dead_letter'))
      ..orderBy([(q) => OrderingTerm.desc(q.deadLetteredAt)]);
    if (storeId != null) {
      query.where((q) => q.storeId.equals(storeId));
    }
    return query.get();
  }

  /// جلب فاتورة محددة برقمها
  Future<ZatcaOfflineQueueTableData?> getByInvoiceNumber(
    String invoiceNumber,
  ) =>
      (select(zatcaOfflineQueueTable)
            ..where((q) => q.invoiceNumber.equals(invoiceNumber)))
          .getSingleOrNull();

  /// عدد الفواتير المعلّقة
  Future<int> getPendingCount({String? storeId}) async {
    final countExpr = zatcaOfflineQueueTable.invoiceNumber.count();
    final query = selectOnly(zatcaOfflineQueueTable)
      ..addColumns([countExpr])
      ..where(zatcaOfflineQueueTable.status.equals('pending'));
    if (storeId != null) {
      query.where(zatcaOfflineQueueTable.storeId.equals(storeId));
    }
    final result = await query.getSingle();
    return result.read(countExpr) ?? 0;
  }

  // ═══════════ كتابة ═══════════

  /// إضافة/تحديث فاتورة في الطابور (UPSERT على invoice_number)
  ///
  /// - إذا كانت جديدة: INSERT مع status=pending و retry_count=0
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

  /// حذف فاتورة (بعد إرسال ناجح لـ ZATCA)
  Future<int> remove(String invoiceNumber) =>
      (delete(zatcaOfflineQueueTable)
            ..where((q) => q.invoiceNumber.equals(invoiceNumber)))
          .go();

  /// تسجيل محاولة فاشلة — يزيد retryCount ويحدّث lastRetryAt
  ///
  /// إذا retryCount يصل لـ maxRetries، الفاتورة تنتقل تلقائياً لـ dead_letter.
  Future<void> recordRetry({
    required String invoiceNumber,
    String? lastError,
  }) async {
    final row = await getByInvoiceNumber(invoiceNumber);
    if (row == null) return;

    final newRetryCount = row.retryCount + 1;
    final now = DateTime.now();
    final shouldDeadLetter = newRetryCount >= maxRetries;

    await (update(zatcaOfflineQueueTable)
          ..where((q) => q.invoiceNumber.equals(invoiceNumber)))
        .write(
      ZatcaOfflineQueueTableCompanion(
        retryCount: Value(newRetryCount),
        lastRetryAt: Value(now),
        lastError: Value(lastError),
        status: Value(shouldDeadLetter ? 'dead_letter' : 'pending'),
        deadLetteredAt: shouldDeadLetter ? Value(now) : const Value.absent(),
      ),
    );
  }

  // ═══════════ Cleanup ═══════════

  /// نقل الفواتير القديمة (>30 يوم) والفاشلة (retryCount >= maxRetries)
  /// إلى حالة dead_letter.
  ///
  /// Returns عدد الصفوف اللي تحوّلت.
  Future<int> cleanupStaleToDeadLetter() async {
    final cutoff = DateTime.now().subtract(staleThreshold);
    return (update(zatcaOfflineQueueTable)
          ..where(
            (q) =>
                q.status.equals('pending') &
                q.retryCount.isBiggerOrEqualValue(maxRetries) &
                q.queuedAt.isSmallerThanValue(cutoff),
          ))
        .write(
      ZatcaOfflineQueueTableCompanion(
        status: const Value('dead_letter'),
        deadLetteredAt: Value(DateTime.now()),
      ),
    );
  }

  /// حذف كل الـ dead_letter (للمسح اليدوي بعد المراجعة)
  Future<int> purgeDeadLetter() => (delete(zatcaOfflineQueueTable)
        ..where((q) => q.status.equals('dead_letter')))
      .go();

  // ═══════════ Streams (للـ UI المباشر) ═══════════

  /// Stream لـ pending count (للـ UI indicator)
  Stream<int> watchPendingCount({String? storeId}) {
    final query = selectOnly(zatcaOfflineQueueTable)
      ..addColumns([zatcaOfflineQueueTable.invoiceNumber.count()])
      ..where(zatcaOfflineQueueTable.status.equals('pending'));
    if (storeId != null) {
      query.where(zatcaOfflineQueueTable.storeId.equals(storeId));
    }
    return query.watchSingle().map(
          (row) =>
              row.read(zatcaOfflineQueueTable.invoiceNumber.count()) ?? 0,
        );
  }
}
