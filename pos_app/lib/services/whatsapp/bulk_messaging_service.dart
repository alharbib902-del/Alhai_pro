/// خدمة الإرسال الجماعي لرسائل واتساب
///
/// تتولى:
/// - إنشاء دفعات ترويجية (عروض) لقائمة مستلمين
/// - إنشاء دفعات تذكير ديون
/// - تتبع تقدم الدفعة (pending/sent/delivered/failed)
/// - إلغاء الرسائل المعلقة في دفعة
/// - التحقق من صلاحية أرقام المستلمين
///
/// تعتمد على:
/// - WhatsAppMessagesDao لحفظ الرسائل في طابور الإرسال
/// - PhoneValidationService لتنسيق والتحقق من الأرقام
/// - WhatsAppTemplatesDao للوصول إلى القوالب الافتراضية
library;

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:pos_app/core/config/whatsapp_config.dart';
import 'package:pos_app/core/monitoring/production_logger.dart';
import 'package:pos_app/data/local/app_database.dart';
import 'package:pos_app/data/local/daos/whatsapp_messages_dao.dart';
import 'package:pos_app/data/local/daos/whatsapp_templates_dao.dart';
import 'package:pos_app/services/whatsapp/models/wasender_models.dart';
import 'package:pos_app/services/whatsapp/phone_validation_service.dart';
import 'package:pos_app/services/whatsapp/template_service.dart';

/// خدمة الإرسال الجماعي
class BulkMessagingService {
  final WhatsAppMessagesDao _messagesDao;
  final PhoneValidationService _phoneValidation;
  final WhatsAppTemplatesDao _templatesDao;

  static const _tag = 'BulkMessagingService';
  static const _uuid = Uuid();

  BulkMessagingService(
    this._messagesDao,
    this._phoneValidation,
    this._templatesDao,
  );

  // ═══════════════════════════════════════════════════════
  // إنشاء دفعة ترويجية
  // ═══════════════════════════════════════════════════════

  /// إنشاء دفعة رسائل ترويجية لقائمة مستلمين
  ///
  /// [recipients] قائمة المستلمين مع بياناتهم ومتغيرات القالب الخاصة بكل واحد.
  /// [templateContent] محتوى القالب (مُعرَض مسبقاً أو يحتوي على {{placeholders}}).
  /// [globalTemplateVars] متغيرات عامة تُطبّق على جميع المستلمين.
  /// [imageUrl] رابط صورة اختيارية تُرفق مع الرسالة.
  ///
  /// يُرجع [BulkBatchResult] يحتوي على معرف الدفعة وإحصائيات التحقق.
  Future<BulkBatchResult> createPromotionBatch({
    required String storeId,
    required List<BulkRecipient> recipients,
    required String templateContent,
    Map<String, String>? globalTemplateVars,
    String? imageUrl,
  }) async {
    final batchId = _uuid.v4();
    var validCount = 0;
    var invalidCount = 0;

    ProductionLogger.info(
      'Creating promotion batch $batchId with ${recipients.length} recipients',
      tag: _tag,
    );

    // التحقق من عدم تجاوز الحد الأقصى للدفعة
    if (recipients.length > WhatsAppConfig.maxBatchSize) {
      ProductionLogger.warning(
        'Batch size ${recipients.length} exceeds max ${WhatsAppConfig.maxBatchSize}, '
        'proceeding anyway (queue processor handles throttling)',
        tag: _tag,
      );
    }

    final templateService = WhatsAppTemplateService(_templatesDao);

    for (final recipient in recipients) {
      // التحقق من صحة الرقم
      if (!PhoneValidationService.isValidPhone(recipient.phone)) {
        invalidCount++;
        ProductionLogger.debug(
          'Invalid phone for recipient: ${recipient.name ?? "unknown"}',
          tag: _tag,
        );
        continue;
      }

      final formattedPhone = PhoneValidationService.formatPhone(recipient.phone);

      // بناء المتغيرات: العامة + الخاصة بالمستلم (الخاصة تتغلب على العامة)
      final variables = <String, String>{
        ...?globalTemplateVars,
        if (recipient.name != null) 'customer_name': recipient.name!,
        ...?recipient.templateVars,
      };

      // عرض القالب
      final renderedText = templateService.renderTemplate(
        templateContent,
        variables,
      );

      // تحديد نوع الرسالة
      final messageType = imageUrl != null ? 'image' : 'text';

      final companion = _buildMessageCompanion(
        storeId: storeId,
        phone: formattedPhone,
        text: renderedText,
        messageType: messageType,
        batchId: batchId,
        customerId: recipient.customerId,
        customerName: recipient.name,
        referenceType: 'promotion',
        priority: 1, // عروض = أولوية منخفضة
        mediaUrl: imageUrl,
      );

      try {
        await _messagesDao.enqueue(companion);
        validCount++;
      } catch (e, st) {
        invalidCount++;
        ProductionLogger.error(
          'Failed to enqueue promotion message for ${recipient.phone}',
          tag: _tag,
          error: e,
          stackTrace: st,
        );
      }
    }

    ProductionLogger.info(
      'Promotion batch $batchId created: $validCount valid, $invalidCount invalid',
      tag: _tag,
    );

    return BulkBatchResult(
      batchId: batchId,
      totalMessages: validCount,
      validRecipients: validCount,
      invalidRecipients: invalidCount,
    );
  }

  // ═══════════════════════════════════════════════════════
  // إنشاء دفعة تذكير ديون
  // ═══════════════════════════════════════════════════════

  /// إنشاء دفعة رسائل تذكير ديون
  ///
  /// [recipients] قائمة المدينين مع أسمائهم ومبالغهم.
  /// [templateContent] قالب مخصص اختياري. إذا لم يُحدد، يُستخدم القالب الافتراضي.
  ///
  /// لكل مدين، يتم تنسيق الرسالة باسم العميل والمبلغ المستحق.
  Future<BulkBatchResult> createDebtReminderBatch({
    required String storeId,
    required List<DebtRecipient> recipients,
    String? templateContent,
  }) async {
    final batchId = _uuid.v4();
    var validCount = 0;
    var invalidCount = 0;

    ProductionLogger.info(
      'Creating debt reminder batch $batchId with ${recipients.length} recipients',
      tag: _tag,
    );

    // الحصول على القالب الافتراضي إذا لم يُحدد قالب مخصص
    String effectiveTemplate;
    if (templateContent != null && templateContent.isNotEmpty) {
      effectiveTemplate = templateContent;
    } else {
      final defaultTemplate = await _templatesDao.getDefaultTemplate(
        storeId,
        'debt_reminder',
      );
      effectiveTemplate = defaultTemplate?.content ??
          WhatsAppTemplateService.defaultTemplates['debt_reminder']!['content']!;
    }

    final templateService = WhatsAppTemplateService(_templatesDao);

    for (final recipient in recipients) {
      // التحقق من صحة الرقم
      if (!PhoneValidationService.isValidPhone(recipient.phone)) {
        invalidCount++;
        ProductionLogger.debug(
          'Invalid phone for debt recipient: ${recipient.customerName}',
          tag: _tag,
        );
        continue;
      }

      final formattedPhone = PhoneValidationService.formatPhone(recipient.phone);

      // تنسيق المبلغ (رقمين عشريين)
      final formattedAmount = recipient.amount.toStringAsFixed(2);

      // عرض القالب مع بيانات المدين
      final renderedText = templateService.renderTemplate(
        effectiveTemplate,
        {
          'customer_name': recipient.customerName,
          'amount': formattedAmount,
        },
      );

      final companion = _buildMessageCompanion(
        storeId: storeId,
        phone: formattedPhone,
        text: renderedText,
        messageType: 'text',
        batchId: batchId,
        customerId: recipient.customerId,
        customerName: recipient.customerName,
        referenceType: 'debt_reminder',
        referenceId: recipient.customerId,
        priority: 2, // تذكير ديون = أولوية عادية
      );

      try {
        await _messagesDao.enqueue(companion);
        validCount++;
      } catch (e, st) {
        invalidCount++;
        ProductionLogger.error(
          'Failed to enqueue debt reminder for ${recipient.customerName}',
          tag: _tag,
          error: e,
          stackTrace: st,
        );
      }
    }

    ProductionLogger.info(
      'Debt reminder batch $batchId created: $validCount valid, $invalidCount invalid',
      tag: _tag,
    );

    return BulkBatchResult(
      batchId: batchId,
      totalMessages: validCount,
      validRecipients: validCount,
      invalidRecipients: invalidCount,
    );
  }

  // ═══════════════════════════════════════════════════════
  // تتبع تقدم الدفعة
  // ═══════════════════════════════════════════════════════

  /// الحصول على تقدم دفعة بشكل لحظي (لمرة واحدة)
  ///
  /// يستعلم عن جميع رسائل الدفعة ويُحسب الإحصائيات حسب الحالة.
  Future<BulkBatchProgress> getBatchProgress(String batchId) async {
    final messages = await _messagesDao.getByBatchId(batchId);

    if (messages.isEmpty) {
      return BulkBatchProgress(
        batchId: batchId,
        total: 0,
      );
    }

    var sent = 0;
    var delivered = 0;
    var failed = 0;
    var pending = 0;

    for (final msg in messages) {
      switch (msg.status) {
        case 'sent':
          sent++;
        case 'delivered':
        case 'read':
          delivered++;
        case 'failed':
          failed++;
        case 'pending':
        case 'uploading':
        case 'sending':
          pending++;
      }
    }

    return BulkBatchProgress(
      batchId: batchId,
      total: messages.length,
      sent: sent,
      delivered: delivered,
      failed: failed,
      pending: pending,
    );
  }

  /// مراقبة تقدم دفعة كـ Stream (reactive)
  ///
  /// يُحدّث تلقائياً عند تغير حالة أي رسالة في الدفعة.
  Stream<BulkBatchProgress> watchBatchProgress(String batchId) {
    return _messagesDao.watchBatchProgress(batchId).map((statusCounts) {
      final sent = statusCounts['sent'] ?? 0;
      final delivered = (statusCounts['delivered'] ?? 0) +
          (statusCounts['read'] ?? 0);
      final failed = statusCounts['failed'] ?? 0;
      final pending = (statusCounts['pending'] ?? 0) +
          (statusCounts['uploading'] ?? 0) +
          (statusCounts['sending'] ?? 0);
      final total = sent + delivered + failed + pending;

      return BulkBatchProgress(
        batchId: batchId,
        total: total,
        sent: sent,
        delivered: delivered,
        failed: failed,
        pending: pending,
      );
    });
  }

  // ═══════════════════════════════════════════════════════
  // إلغاء الدفعة
  // ═══════════════════════════════════════════════════════

  /// إلغاء الرسائل المعلقة في دفعة
  ///
  /// يحذف فقط الرسائل بحالة 'pending'. الرسائل المُرسلة أو قيد الإرسال
  /// لا تتأثر.
  ///
  /// يُرجع عدد الرسائل المُلغاة.
  Future<int> cancelBatch(String batchId) async {
    try {
      final cancelledCount = await _messagesDao.cancelBatch(batchId);

      ProductionLogger.info(
        'Cancelled $cancelledCount pending messages in batch $batchId',
        tag: _tag,
      );

      return cancelledCount;
    } catch (e, st) {
      ProductionLogger.error(
        'Failed to cancel batch $batchId',
        tag: _tag,
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════
  // التحقق من المستلمين
  // ═══════════════════════════════════════════════════════

  /// التحقق من صحة وتوفر أرقام المستلمين على واتساب
  ///
  /// لكل رقم:
  /// 1. يتحقق من صحة التنسيق
  /// 2. يتحقق من التسجيل على واتساب (عبر WaSenderAPI)
  ///
  /// ملاحظة: التحقق من واتساب يتطلب اتصال بالـ API ويستهلك حصة الطلبات.
  /// يُنصح باستخدامه للدفعات الكبيرة قبل الإرسال لتقليل الرسائل الفاشلة.
  Future<List<BulkRecipientValidation>> validateRecipients(
    List<String> phones,
  ) async {
    final results = <BulkRecipientValidation>[];

    for (final phone in phones) {
      // التحقق من التنسيق أولاً
      final isValid = PhoneValidationService.isValidPhone(phone);
      if (!isValid) {
        results.add(BulkRecipientValidation(
          phone: phone,
          isValid: false,
          isOnWhatsApp: false,
          error: 'رقم هاتف غير صالح',
        ));
        continue;
      }

      // تنسيق الرقم
      final formatted = PhoneValidationService.formatPhone(phone);

      // التحقق من التسجيل على واتساب عبر API
      bool isOnWhatsApp;
      try {
        isOnWhatsApp = await _phoneValidation.isOnWhatsApp(formatted);
      } catch (e) {
        // عند فشل الاتصال بالـ API نفترض الوجود لعدم حجب الإرسال
        isOnWhatsApp = true;
      }

      results.add(BulkRecipientValidation(
        phone: formatted,
        isValid: true,
        isOnWhatsApp: isOnWhatsApp,
      ));
    }

    ProductionLogger.info(
      'Validated ${phones.length} recipients: '
      '${results.where((r) => r.isValid).length} valid, '
      '${results.where((r) => !r.isValid).length} invalid',
      tag: _tag,
    );

    return results;
  }

  // ═══════════════════════════════════════════════════════
  // بناء رسالة (Helper)
  // ═══════════════════════════════════════════════════════

  /// بناء WhatsAppMessagesTableCompanion جاهز للإدراج
  WhatsAppMessagesTableCompanion _buildMessageCompanion({
    required String storeId,
    required String phone,
    required String text,
    String messageType = 'text',
    String? batchId,
    String? customerId,
    String? customerName,
    String? referenceType,
    String? referenceId,
    int priority = 2,
    String? mediaUrl,
  }) {
    final now = DateTime.now();

    return WhatsAppMessagesTableCompanion(
      id: Value(_uuid.v4()),
      storeId: Value(storeId),
      phone: Value(phone),
      customerName: Value(customerName),
      customerId: Value(customerId),
      messageType: Value(messageType),
      textContent: Value(text),
      mediaUrl: Value(mediaUrl),
      referenceType: Value(referenceType),
      referenceId: Value(referenceId),
      status: const Value('pending'),
      retryCount: const Value(0),
      maxRetries: Value(WhatsAppConfig.maxMessageRetries),
      priority: Value(priority),
      batchId: Value(batchId),
      createdAt: Value(now),
    );
  }
}
