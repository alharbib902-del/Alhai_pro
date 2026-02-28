import 'package:drift/drift.dart';

/// جدول قوالب رسائل واتساب
///
/// يحتوي على القوالب المُعدّة مسبقاً للإيصالات والتذكيرات والعروض.
/// يدعم المتغيرات {{variable}} التي تُستبدل عند الإرسال.
///
/// Indexes:
/// - idx_wa_tmpl_type: للبحث بنوع القالب
/// - idx_wa_tmpl_active: للحصول على القوالب النشطة فقط
@TableIndex(name: 'idx_wa_tmpl_type', columns: {#type})
@TableIndex(name: 'idx_wa_tmpl_active', columns: {#isActive})
class WhatsAppTemplatesTable extends Table {
  @override
  String get tableName => 'whatsapp_templates';

  // ═══════════ المعرفات ═══════════
  TextColumn get id => text()();
  TextColumn get storeId => text()();

  // ═══════════ بيانات القالب ═══════════
  /// اسم القالب المعروض
  TextColumn get name => text()();

  /// نوع القالب: receipt, debt_reminder, promotion, order_update, welcome, custom
  TextColumn get type => text()();

  /// محتوى القالب مع {{placeholders}}
  TextColumn get content => text()();

  /// لغة القالب (ar, en, etc.)
  TextColumn get language => text().withDefault(const Constant('ar'))();

  // ═══════════ الحالة ═══════════
  /// هل القالب نشط؟
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// هل هو القالب الافتراضي لهذا النوع؟
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  /// نوع الوسائط المرفقة (null, image, document)
  TextColumn get mediaType => text().nullable()();

  // ═══════════ التواريخ ═══════════
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
