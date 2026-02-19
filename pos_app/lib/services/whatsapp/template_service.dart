/// خدمة إدارة قوالب رسائل واتساب
///
/// تتولى:
/// - إنشاء/تعديل/حذف القوالب
/// - استبدال المتغيرات {{variable}} بقيمها
/// - بذر القوالب الافتراضية (عربي) عند أول تشغيل
/// - تعيين قالب كافتراضي لنوع معين
library;

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:pos_app/core/monitoring/production_logger.dart';
import 'package:pos_app/data/local/app_database.dart';
import 'package:pos_app/data/local/daos/whatsapp_templates_dao.dart';

/// خدمة إدارة وعرض قوالب الرسائل
class WhatsAppTemplateService {
  final WhatsAppTemplatesDao _templatesDao;
  static const _tag = 'WhatsAppTemplateService';
  static const _uuid = Uuid();

  WhatsAppTemplateService(this._templatesDao);

  // ═══════════════════════════════════════════════════════
  // القوالب الافتراضية (عربي)
  // ═══════════════════════════════════════════════════════

  /// القوالب الافتراضية التي تُبذر عند أول استخدام
  static const Map<String, Map<String, String>> defaultTemplates = {
    'receipt': {
      'name': 'إيصال إلكتروني',
      'content': '🛎️ إيصال إلكتروني\n'
          'المتجر: {{store_name}}\n'
          'رقم الفاتورة: {{receipt_no}}\n'
          'التاريخ: {{date}}\n'
          '──────────\n'
          '{{items_list}}\n'
          '──────────\n'
          '*الإجمالي: {{total}} ر.س*\n'
          'طريقة الدفع: {{payment_method}}\n'
          '──────────\n'
          'شكراً لتسوقكم! 🌟',
    },
    'debt_reminder': {
      'name': 'تذكير دين',
      'content': 'مرحباً {{customer_name}} 👋\n'
          '\n'
          'نود تذكيركم بوجود رصيد مستحق بقيمة *{{amount}} ر.س*\n'
          '\n'
          'نرجو التواصل معنا لتسوية المبلغ.\n'
          'شكراً لتعاونكم 🙏\n'
          '\n'
          '{{store_name}}',
    },
    'promotion': {
      'name': 'عرض ترويجي',
      'content': '🎉 عرض خاص لك يا {{customer_name}}!\n'
          '\n'
          '{{promotion_title}}\n'
          '\n'
          '{{promotion_details}}\n'
          '\n'
          '{{store_name}}\n'
          'تفضل بزيارتنا للاستفادة من العرض 🏃',
    },
    'order_update': {
      'name': 'تحديث طلب',
      'content': 'مرحباً 👋\n'
          '\n'
          'تحديث الطلب رقم: {{order_number}}\n'
          'الحالة: {{status_message}}\n'
          '\n'
          '{{store_name}}',
    },
    'welcome': {
      'name': 'ترحيب',
      'content': 'مرحباً {{customer_name}} 👋\n'
          '\n'
          'أهلاً بك في {{store_name}}!\n'
          'يسعدنا انضمامك إلينا 🌟\n'
          '\n'
          '{{store_name}}',
    },
  };

  // ═══════════════════════════════════════════════════════
  // عرض القالب (Template Rendering)
  // ═══════════════════════════════════════════════════════

  /// استبدال المتغيرات {{variable}} بقيمها الفعلية
  ///
  /// مثال:
  /// ```dart
  /// final rendered = renderTemplate(
  ///   'مرحباً {{customer_name}}، إجمالي: {{total}} ر.س',
  ///   {'customer_name': 'أحمد', 'total': '150.00'},
  /// );
  /// // النتيجة: 'مرحباً أحمد، إجمالي: 150.00 ر.س'
  /// ```
  String renderTemplate(String templateContent, Map<String, String> variables) {
    var result = templateContent;

    for (final entry in variables.entries) {
      result = result.replaceAll('{{${entry.key}}}', entry.value);
    }

    // إزالة أي متغيرات لم يتم استبدالها (اختياري: نتركها فارغة)
    result = result.replaceAll(RegExp(r'\{\{[^}]+\}\}'), '');

    return result.trim();
  }

  // ═══════════════════════════════════════════════════════
  // بذر القوالب الافتراضية
  // ═══════════════════════════════════════════════════════

  /// بذر القوالب الافتراضية عند أول تشغيل للمتجر
  ///
  /// يتحقق أولاً من وجود قوالب مسبقة، وإذا لم تكن موجودة
  /// يُدخل القوالب الافتراضية بالعربية.
  Future<void> seedDefaultTemplates(String storeId) async {
    try {
      final hasExisting = await _templatesDao.hasTemplates(storeId);
      if (hasExisting) {
        ProductionLogger.debug(
          'Templates already seeded for store $storeId',
          tag: _tag,
        );
        return;
      }

      final now = DateTime.now();
      final companions = <WhatsAppTemplatesTableCompanion>[];

      for (final entry in defaultTemplates.entries) {
        final type = entry.key;
        final data = entry.value;

        companions.add(WhatsAppTemplatesTableCompanion(
          id: Value(_uuid.v4()),
          storeId: Value(storeId),
          name: Value(data['name']!),
          type: Value(type),
          content: Value(data['content']!),
          language: const Value('ar'),
          isActive: const Value(true),
          isDefault: const Value(true),
          createdAt: Value(now),
        ));
      }

      await _templatesDao.insertAll(companions);

      ProductionLogger.info(
        'Seeded ${companions.length} default templates for store $storeId',
        tag: _tag,
      );
    } catch (e, st) {
      ProductionLogger.error(
        'Failed to seed default templates for store $storeId',
        tag: _tag,
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════
  // عمليات CRUD
  // ═══════════════════════════════════════════════════════

  /// الحصول على جميع القوالب النشطة لمتجر
  Future<List<WhatsAppTemplatesTableData>> getTemplates(String storeId) {
    return _templatesDao.getAllTemplates(storeId);
  }

  /// الحصول على القالب الافتراضي لنوع معين
  Future<WhatsAppTemplatesTableData?> getDefaultForType(
    String storeId,
    String type,
  ) {
    return _templatesDao.getDefaultTemplate(storeId, type);
  }

  /// إنشاء قالب جديد
  ///
  /// يُرجع معرف القالب المُنشأ.
  Future<String> createTemplate({
    required String storeId,
    required String name,
    required String type,
    required String content,
    String language = 'ar',
    String? mediaType,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    try {
      await _templatesDao.insertTemplate(WhatsAppTemplatesTableCompanion(
        id: Value(id),
        storeId: Value(storeId),
        name: Value(name),
        type: Value(type),
        content: Value(content),
        language: Value(language),
        isActive: const Value(true),
        isDefault: const Value(false),
        mediaType: Value(mediaType),
        createdAt: Value(now),
      ));

      ProductionLogger.info(
        'Created template "$name" (type=$type) for store $storeId',
        tag: _tag,
      );

      return id;
    } catch (e, st) {
      ProductionLogger.error(
        'Failed to create template "$name"',
        tag: _tag,
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// تحديث قالب موجود
  Future<void> updateTemplate({
    required String id,
    String? name,
    String? content,
    bool? isActive,
    String? mediaType,
  }) async {
    try {
      final companion = WhatsAppTemplatesTableCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        content: content != null ? Value(content) : const Value.absent(),
        isActive: isActive != null ? Value(isActive) : const Value.absent(),
        mediaType: mediaType != null ? Value(mediaType) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      );

      await _templatesDao.updateTemplate(id, companion);

      ProductionLogger.info(
        'Updated template $id',
        tag: _tag,
      );
    } catch (e, st) {
      ProductionLogger.error(
        'Failed to update template $id',
        tag: _tag,
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// حذف قالب
  Future<void> deleteTemplate(String id) async {
    try {
      await _templatesDao.deleteTemplate(id);

      ProductionLogger.info(
        'Deleted template $id',
        tag: _tag,
      );
    } catch (e, st) {
      ProductionLogger.error(
        'Failed to delete template $id',
        tag: _tag,
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// تعيين قالب كافتراضي لنوعه
  ///
  /// يُلغي القالب الافتراضي السابق لنفس النوع تلقائياً.
  Future<void> setAsDefault(
    String storeId,
    String type,
    String templateId,
  ) async {
    try {
      await _templatesDao.setAsDefault(storeId, type, templateId);

      ProductionLogger.info(
        'Set template $templateId as default for type=$type in store $storeId',
        tag: _tag,
      );
    } catch (e, st) {
      ProductionLogger.error(
        'Failed to set default template $templateId',
        tag: _tag,
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════
  // المراقبة (Streams)
  // ═══════════════════════════════════════════════════════

  /// مراقبة القوالب النشطة لمتجر (reactive)
  Stream<List<WhatsAppTemplatesTableData>> watchTemplates(String storeId) {
    return _templatesDao.watchTemplates(storeId);
  }
}
