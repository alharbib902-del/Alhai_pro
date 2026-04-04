import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:alhai_database/alhai_database.dart';
import '../helpers/database_test_helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = createTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  WhatsAppTemplatesTableCompanion _makeTemplate({
    String id = 'tmpl-1',
    String storeId = 'store-1',
    String name = 'إيصال إلكتروني',
    String type = 'receipt',
    String content = 'مرحبا {{customer_name}}، إيصالك رقم {{receipt_no}}',
    bool isActive = true,
    bool isDefault = false,
  }) {
    return WhatsAppTemplatesTableCompanion.insert(
      id: id,
      storeId: storeId,
      name: name,
      type: type,
      content: content,
      isActive: Value(isActive),
      isDefault: Value(isDefault),
      createdAt: DateTime(2025, 1, 1),
    );
  }

  group('WhatsAppTemplatesDao', () {
    test('insertTemplate and getAllTemplates', () async {
      await db.whatsAppTemplatesDao.insertTemplate(_makeTemplate());

      final templates =
          await db.whatsAppTemplatesDao.getAllTemplates('store-1');
      expect(templates, hasLength(1));
      expect(templates.first.name, 'إيصال إلكتروني');
      expect(templates.first.type, 'receipt');
    });

    test('getAllTemplates returns only active templates', () async {
      await db.whatsAppTemplatesDao
          .insertTemplate(_makeTemplate(isActive: true));
      await db.whatsAppTemplatesDao.insertTemplate(_makeTemplate(
        id: 'tmpl-2',
        name: 'قالب محذوف',
        isActive: false,
      ));

      final templates =
          await db.whatsAppTemplatesDao.getAllTemplates('store-1');
      expect(templates, hasLength(1));
    });

    test('getTemplatesByType filters by type', () async {
      await db.whatsAppTemplatesDao
          .insertTemplate(_makeTemplate(type: 'receipt'));
      await db.whatsAppTemplatesDao.insertTemplate(_makeTemplate(
        id: 'tmpl-2',
        name: 'تذكير دين',
        type: 'debt_reminder',
      ));

      final receiptTemplates = await db.whatsAppTemplatesDao
          .getTemplatesByType('store-1', 'receipt');
      expect(receiptTemplates, hasLength(1));
      expect(receiptTemplates.first.type, 'receipt');
    });

    test('getDefaultTemplate returns default for type', () async {
      await db.whatsAppTemplatesDao
          .insertTemplate(_makeTemplate(id: 'tmpl-1', isDefault: false));
      await db.whatsAppTemplatesDao.insertTemplate(_makeTemplate(
        id: 'tmpl-2',
        name: 'إيصال افتراضي',
        type: 'receipt',
        isDefault: true,
      ));

      final defaultTemplate = await db.whatsAppTemplatesDao
          .getDefaultTemplate('store-1', 'receipt');
      expect(defaultTemplate, isNotNull);
      expect(defaultTemplate!.id, 'tmpl-2');
      expect(defaultTemplate.isDefault, true);
    });

    test('getDefaultTemplate returns null when no default', () async {
      await db.whatsAppTemplatesDao
          .insertTemplate(_makeTemplate(isDefault: false));

      final defaultTemplate = await db.whatsAppTemplatesDao
          .getDefaultTemplate('store-1', 'receipt');
      expect(defaultTemplate, isNull);
    });

    test('updateTemplate modifies template', () async {
      await db.whatsAppTemplatesDao.insertTemplate(_makeTemplate());

      await db.whatsAppTemplatesDao.updateTemplate(
        'tmpl-1',
        const WhatsAppTemplatesTableCompanion(
          name: Value('إيصال محدّث'),
          content: Value('محتوى جديد'),
        ),
      );

      final templates =
          await db.whatsAppTemplatesDao.getAllTemplates('store-1');
      expect(templates.first.name, 'إيصال محدّث');
      expect(templates.first.content, 'محتوى جديد');
    });

    test('deleteTemplate removes template', () async {
      await db.whatsAppTemplatesDao.insertTemplate(_makeTemplate());

      final deleted = await db.whatsAppTemplatesDao.deleteTemplate('tmpl-1');
      expect(deleted, 1);
    });

    test('setAsDefault changes default template', () async {
      await db.whatsAppTemplatesDao.insertTemplate(_makeTemplate(
        id: 'tmpl-old',
        type: 'receipt',
        isDefault: true,
      ));
      await db.whatsAppTemplatesDao.insertTemplate(_makeTemplate(
        id: 'tmpl-new',
        name: 'إيصال جديد',
        type: 'receipt',
        isDefault: false,
      ));

      await db.whatsAppTemplatesDao
          .setAsDefault('store-1', 'receipt', 'tmpl-new');

      final oldDefault = await db.whatsAppTemplatesDao
          .getDefaultTemplate('store-1', 'receipt');
      expect(oldDefault!.id, 'tmpl-new');
    });

    test('hasTemplates returns true when templates exist', () async {
      await db.whatsAppTemplatesDao.insertTemplate(_makeTemplate());

      final has = await db.whatsAppTemplatesDao.hasTemplates('store-1');
      expect(has, true);
    });

    test('hasTemplates returns false for empty store', () async {
      final has = await db.whatsAppTemplatesDao.hasTemplates('empty-store');
      expect(has, false);
    });

    test('insertAll batch inserts templates', () async {
      await db.whatsAppTemplatesDao.insertAll([
        _makeTemplate(id: 'tmpl-1', name: 'إيصال', type: 'receipt'),
        _makeTemplate(id: 'tmpl-2', name: 'تذكير', type: 'debt_reminder'),
        _makeTemplate(id: 'tmpl-3', name: 'ترحيب', type: 'welcome'),
      ]);

      final templates =
          await db.whatsAppTemplatesDao.getAllTemplates('store-1');
      expect(templates, hasLength(3));
    });
  });
}
