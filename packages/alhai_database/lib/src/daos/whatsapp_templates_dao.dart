import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/whatsapp_templates_table.dart';

part 'whatsapp_templates_dao.g.dart';

/// DAO لقوالب رسائل واتساب
@DriftAccessor(tables: [WhatsAppTemplatesTable])
class WhatsAppTemplatesDao extends DatabaseAccessor<AppDatabase>
    with _$WhatsAppTemplatesDaoMixin {
  WhatsAppTemplatesDao(super.db);

  /// الحصول على جميع القوالب لمتجر
  Future<List<WhatsAppTemplatesTableData>> getAllTemplates(String storeId) {
    return (select(whatsAppTemplatesTable)
          ..where((q) => q.storeId.equals(storeId) & q.isActive.equals(true))
          ..orderBy([(q) => OrderingTerm.asc(q.name)]))
        .get();
  }

  /// الحصول على القوالب حسب النوع
  Future<List<WhatsAppTemplatesTableData>> getTemplatesByType(
    String storeId,
    String type,
  ) {
    return (select(whatsAppTemplatesTable)
          ..where(
            (q) =>
                q.storeId.equals(storeId) &
                q.type.equals(type) &
                q.isActive.equals(true),
          )
          ..orderBy([(q) => OrderingTerm.desc(q.isDefault)]))
        .get();
  }

  /// الحصول على القالب الافتراضي لنوع معين
  Future<WhatsAppTemplatesTableData?> getDefaultTemplate(
    String storeId,
    String type,
  ) {
    return (select(whatsAppTemplatesTable)
          ..where(
            (q) =>
                q.storeId.equals(storeId) &
                q.type.equals(type) &
                q.isDefault.equals(true) &
                q.isActive.equals(true),
          ))
        .getSingleOrNull();
  }

  /// إضافة قالب جديد
  Future<int> insertTemplate(WhatsAppTemplatesTableCompanion template) {
    return into(whatsAppTemplatesTable).insert(template);
  }

  /// تحديث قالب
  Future<int> updateTemplate(
    String id,
    WhatsAppTemplatesTableCompanion template,
  ) {
    return (update(whatsAppTemplatesTable)..where((q) => q.id.equals(id)))
        .write(template);
  }

  /// حذف قالب
  Future<int> deleteTemplate(String id) {
    return (delete(whatsAppTemplatesTable)..where((q) => q.id.equals(id))).go();
  }

  /// تعيين قالب كافتراضي (وإلغاء القديم)
  Future<void> setAsDefault(String storeId, String type, String templateId) {
    return transaction(() async {
      // إلغاء الافتراضي القديم
      await (update(whatsAppTemplatesTable)
            ..where(
              (q) =>
                  q.storeId.equals(storeId) &
                  q.type.equals(type) &
                  q.isDefault.equals(true),
            ))
          .write(const WhatsAppTemplatesTableCompanion(
        isDefault: Value(false),
      ));

      // تعيين الجديد
      await (update(whatsAppTemplatesTable)
            ..where((q) => q.id.equals(templateId)))
          .write(const WhatsAppTemplatesTableCompanion(
        isDefault: Value(true),
      ));
    });
  }

  /// مراقبة القوالب لمتجر
  Stream<List<WhatsAppTemplatesTableData>> watchTemplates(String storeId) {
    return (select(whatsAppTemplatesTable)
          ..where((q) => q.storeId.equals(storeId) & q.isActive.equals(true))
          ..orderBy([
            (q) => OrderingTerm.asc(q.type),
            (q) => OrderingTerm.desc(q.isDefault),
          ]))
        .watch();
  }

  /// هل يوجد قوالب لهذا المتجر؟
  Future<bool> hasTemplates(String storeId) async {
    final count = await customSelect(
      'SELECT COUNT(*) as count FROM whatsapp_templates WHERE store_id = ?',
      variables: [Variable.withString(storeId)],
    ).getSingle();
    return (count.data['count'] as int? ?? 0) > 0;
  }

  /// إضافة قوالب متعددة (للبذر الأولي)
  Future<void> insertAll(List<WhatsAppTemplatesTableCompanion> templates) {
    return batch((batch) {
      batch.insertAll(whatsAppTemplatesTable, templates);
    });
  }
}
