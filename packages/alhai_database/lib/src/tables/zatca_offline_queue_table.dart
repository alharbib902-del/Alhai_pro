import 'package:drift/drift.dart';

/// جدول طابور فواتير ZATCA الـ offline
///
/// يحل محل SharedPreferences JSON-blob الـ full-rewrite لكل enqueue/dequeue.
/// كل فاتورة = صف واحد مع status (pending | dead_letter).
/// لا يوجد جدول dead-letter منفصل — status column يكفي.
///
/// Indexes:
/// - idx_zatca_queue_status_queued: للفلترة حسب الحالة + الترتيب الزمني
/// - idx_zatca_queue_store: للفلترة حسب المتجر
/// - idx_zatca_queue_retry: للـ cleanup query (retry_count >= 10 AND queued_at < X)
///
/// العمود `invoice_number` هو PK — كل فاتورة يجب أن تظهر مرة واحدة.
/// إذا حاولنا enqueue فاتورة موجودة، UPSERT يحدّث الصف بدل الدُبلكيت.
@TableIndex(
  name: 'idx_zatca_queue_status_queued',
  columns: {#status, #queuedAt},
)
@TableIndex(name: 'idx_zatca_queue_store', columns: {#storeId})
@TableIndex(
  name: 'idx_zatca_queue_retry',
  columns: {#retryCount, #queuedAt},
)
class ZatcaOfflineQueueTable extends Table {
  @override
  String get tableName => 'zatca_offline_queue';

  // ═══════════ المعرفات ═══════════
  /// رقم الفاتورة — PK
  TextColumn get invoiceNumber => text()();

  /// UUID الفاتورة (مولّد من UblInvoiceBuilder)
  TextColumn get uuid => text()();

  /// معرف المتجر صاحب الفاتورة
  TextColumn get storeId => text()();

  // ═══════════ محتوى الفاتورة ═══════════
  /// الـ XML الموقّع بـ base64 (جاهز للإرسال لـ ZATCA)
  TextColumn get signedXmlBase64 => text()();

  /// hash الفاتورة (SHA-256 base64 per ZATCA spec)
  TextColumn get invoiceHash => text()();

  /// هل standard (clearance) أم simplified (reporting)؟
  BoolColumn get isStandard => boolean()();

  // ═══════════ حالة الطابور ═══════════
  /// الحالة: pending (قابل لإعادة المحاولة) أو dead_letter (استنفد المحاولات)
  TextColumn get status => text().withDefault(const Constant('pending'))();

  /// عدد مرات إعادة المحاولة
  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  /// رسالة الخطأ الأخيرة (إن وجدت)
  TextColumn get lastError => text().nullable()();

  // ═══════════ التواريخ ═══════════
  /// وقت الـ queue الأول
  DateTimeColumn get queuedAt => dateTime()();

  /// وقت آخر محاولة (إن وجدت)
  DateTimeColumn get lastRetryAt => dateTime().nullable()();

  /// وقت الانتقال لـ dead_letter (إن وجد)
  DateTimeColumn get deadLetteredAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {invoiceNumber};
}
