import 'package:drift/drift.dart';

/// جدول dead-letter لفواتير ZATCA اللي استنفدت محاولات إعادة الإرسال
///
/// منفصل عن `zatca_offline_queue` (active queue) لأسباب:
/// - تنظيمي: queue للفواتير النشطة، dead_letter للسجل التدقيقي
/// - retention: queue تُنظَّف مع remove() بعد نجاح، dead_letter تُحتفظ للمراجعة
/// - access pattern: queue hot path، dead_letter polled نادراً
///
/// الصفوف هنا immutable من وجهة نظر الـ operational flow — ينتقلوا هنا
/// وبعدين يُمسحوا يدوياً بعد المراجعة عبر purgeDeadLetter().
///
/// Indexes:
/// - idx_zatca_dead_letter_store: للفلترة حسب المتجر
/// - idx_zatca_dead_letter_at: للترتيب الزمني حسب وقت الانتقال
@TableIndex(name: 'idx_zatca_dead_letter_store', columns: {#storeId})
@TableIndex(name: 'idx_zatca_dead_letter_at', columns: {#deadLetteredAt})
class ZatcaDeadLetterTable extends Table {
  @override
  String get tableName => 'zatca_dead_letter';

  // ═══════════ المعرفات ═══════════
  /// رقم الفاتورة — PK
  TextColumn get invoiceNumber => text()();

  /// UUID الفاتورة (مولّد من UblInvoiceBuilder)
  TextColumn get uuid => text()();

  /// معرف المتجر صاحب الفاتورة
  TextColumn get storeId => text()();

  // ═══════════ محتوى الفاتورة (archived) ═══════════
  /// الـ XML الموقّع بـ base64 (محفوظ للمراجعة/إعادة الإرسال اليدوي)
  TextColumn get signedXmlBase64 => text()();

  /// hash الفاتورة
  TextColumn get invoiceHash => text()();

  /// هل standard (clearance) أم simplified (reporting)؟
  BoolColumn get isStandard => boolean()();

  // ═══════════ معلومات الإخفاق ═══════════
  /// عدد المحاولات اللي تمت قبل الانتقال هنا (عادة = maxRetries = 10)
  IntColumn get retryCount => integer()();

  /// آخر رسالة خطأ مُسَجَّلة
  TextColumn get lastError => text().nullable()();

  /// سبب الانتقال لـ dead_letter: 'max_retries' أو 'stale' أو 'manual'
  TextColumn get deadLetterReason =>
      text().withDefault(const Constant('max_retries'))();

  // ═══════════ التواريخ ═══════════
  /// وقت الـ queue الأول (قبل ما ينتقل هنا)
  DateTimeColumn get queuedAt => dateTime()();

  /// وقت آخر محاولة فاشلة
  DateTimeColumn get lastRetryAt => dateTime().nullable()();

  /// وقت الانتقال لـ dead_letter
  DateTimeColumn get deadLetteredAt => dateTime()();

  @override
  Set<Column> get primaryKey => {invoiceNumber};
}
