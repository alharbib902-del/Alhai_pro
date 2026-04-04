import 'package:drift/drift.dart';

/// جدول رسائل واتساب (طابور الإرسال المستمر)
///
/// يحل محل الطابور المؤقت في الذاكرة.
/// كل رسالة تُحفظ هنا ثم تُرسل عبر WhatsAppQueueProcessor.
///
/// Indexes:
/// - idx_wa_msg_status: للحصول على الرسائل المعلّقة
/// - idx_wa_msg_phone: للبحث برقم الهاتف
/// - idx_wa_msg_type: للبحث بنوع الرسالة
/// - idx_wa_msg_created_at: للترتيب الزمني
/// - idx_wa_msg_reference: للربط بالكيان المصدر
/// - idx_wa_msg_batch: لتتبع الدفعات الجماعية
/// - idx_wa_msg_external: للربط مع WaSenderAPI msgId
@TableIndex(name: 'idx_wa_msg_status', columns: {#status})
@TableIndex(name: 'idx_wa_msg_phone', columns: {#phone})
@TableIndex(name: 'idx_wa_msg_type', columns: {#messageType})
@TableIndex(name: 'idx_wa_msg_created_at', columns: {#createdAt})
@TableIndex(
    name: 'idx_wa_msg_reference', columns: {#referenceType, #referenceId})
@TableIndex(name: 'idx_wa_msg_batch', columns: {#batchId})
@TableIndex(name: 'idx_wa_msg_external', columns: {#externalMsgId})
class WhatsAppMessagesTable extends Table {
  @override
  String get tableName => 'whatsapp_messages';

  // ═══════════ المعرفات ═══════════
  TextColumn get id => text()();
  TextColumn get storeId => text()();

  // ═══════════ المستلم ═══════════
  TextColumn get phone => text()();
  TextColumn get customerName => text().nullable()();
  TextColumn get customerId => text().nullable()();

  // ═══════════ محتوى الرسالة ═══════════
  /// نوع الرسالة: text, image, document, video, audio, location, contact
  TextColumn get messageType => text()();

  /// محتوى النص
  TextColumn get textContent => text().nullable()();

  /// رابط الوسائط (بعد الرفع)
  TextColumn get mediaUrl => text().nullable()();

  /// مسار الملف المحلي (قبل الرفع)
  TextColumn get mediaLocalPath => text().nullable()();

  /// اسم الملف للمستندات
  TextColumn get fileName => text().nullable()();

  /// معرف القالب المستخدم
  TextColumn get templateId => text().nullable()();

  // ═══════════ الربط بالكيان المصدر ═══════════
  /// نوع المرجع: sale, order, debt_reminder, promotion, return, welcome
  TextColumn get referenceType => text().nullable()();

  /// معرف المرجع (مثل: معرف الفاتورة)
  TextColumn get referenceId => text().nullable()();

  // ═══════════ حالة الإرسال ═══════════
  /// الحالة: pending, uploading, sending, sent, delivered, read, failed
  TextColumn get status => text().withDefault(const Constant('pending'))();

  /// معرف الرسالة من WaSenderAPI
  TextColumn get externalMsgId => text().nullable()();

  // ═══════════ إعادة المحاولة ═══════════
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  IntColumn get maxRetries => integer().withDefault(const Constant(3))();
  TextColumn get lastError => text().nullable()();

  // ═══════════ الأولوية ═══════════
  /// 1=low (عروض), 2=normal (تذكير), 3=high (إيصالات)
  IntColumn get priority => integer().withDefault(const Constant(2))();

  // ═══════════ الدفعة الجماعية ═══════════
  TextColumn get batchId => text().nullable()();

  // ═══════════ التواريخ ═══════════
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get sentAt => dateTime().nullable()();
  DateTimeColumn get deliveredAt => dateTime().nullable()();
  DateTimeColumn get readAt => dateTime().nullable()();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
