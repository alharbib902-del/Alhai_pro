/// خدمة WhatsApp Business للتواصل مع العملاء
///
/// الإصدار الجديد: بدلاً من فتح تطبيق واتساب عبر url_launcher،
/// يتم حفظ الرسائل في قاعدة البيانات المحلية (طابور الإرسال)
/// ثم يقوم WhatsAppQueueProcessor بإرسالها تلقائياً عبر WaSenderAPI.
///
/// هذا يضمن:
/// - عدم فقدان الرسائل عند انقطاع الاتصال
/// - إعادة المحاولة تلقائياً عند الفشل
/// - تتبع حالة كل رسالة (pending → sending → sent → delivered → read)
/// - إمكانية الإرسال الجماعي بدون تدخل المستخدم
library;

import 'package:uuid/uuid.dart';

import 'package:alhai_core/alhai_core.dart' show StoreSettings;
import 'package:alhai_database/alhai_database.dart';
import 'whatsapp/phone_validation_service.dart';

const String _currency = StoreSettings.defaultCurrencySymbol;

/// خدمة WhatsApp Business - إصدار طابور قاعدة البيانات
///
/// جميع الرسائل تُحفظ في جدول whatsapp_messages ثم تُرسل لاحقاً.
/// يُرجع كل أسلوب معرف الرسالة (UUID) لتتبعها.
class WhatsAppService {
  final WhatsAppMessagesDao _messagesDao;
  final PhoneValidationService _phoneValidator; // ignore: unused_field
  final String _storeId;
  static const _uuid = Uuid();

  WhatsAppService({
    required WhatsAppMessagesDao messagesDao,
    required PhoneValidationService phoneValidator,
    String storeId = 'default',
  }) : _messagesDao = messagesDao,
       _phoneValidator = phoneValidator,
       _storeId = storeId;

  // ═══════════════════════════════════════════════════════
  // إرسال رسالة عامة
  // ═══════════════════════════════════════════════════════

  /// إرسال رسالة WhatsApp عبر الطابور
  ///
  /// يُنشئ سجل رسالة في قاعدة البيانات بحالة "pending".
  /// يُرجع معرف الرسالة (UUID) لتتبعها.
  Future<String> sendMessage({
    required String phoneNumber,
    required String message,
    String? customerId,
    String? customerName,
    String? referenceType,
    String? referenceId,
    int priority = 2,
  }) {
    return _enqueueMessage(
      phone: phoneNumber,
      text: message,
      customerId: customerId,
      customerName: customerName,
      referenceType: referenceType,
      referenceId: referenceId,
      priority: priority,
    );
  }

  // ═══════════════════════════════════════════════════════
  // تذكير الديون
  // ═══════════════════════════════════════════════════════

  /// إرسال تذكير دين عبر الطابور
  Future<String> sendDebtReminder({
    required String phoneNumber,
    required String customerName,
    required String customerId,
    required double amount,
    required String storeName,
  }) {
    final message =
        '''
مرحباً $customerName 👋

نود تذكيركم بوجود رصيد مستحق بقيمة ${amount.toStringAsFixed(2)} $_currency

نرجو التواصل معنا لتسوية المبلغ.
شكراً لتعاونكم 🙏

$storeName''';

    return _enqueueMessage(
      phone: phoneNumber,
      text: message,
      customerId: customerId,
      customerName: customerName,
      referenceType: 'debt_reminder',
      referenceId: customerId,
      priority: 2,
    );
  }

  // ═══════════════════════════════════════════════════════
  // إيصال الفاتورة
  // ═══════════════════════════════════════════════════════

  /// إرسال إيصال فاتورة عبر الطابور
  Future<String> sendReceipt({
    required String phoneNumber,
    required String customerName,
    required String receiptNumber,
    required double total,
    required String storeName,
  }) {
    final message =
        '''
شكراً لتسوقكم من $storeName 🛒

رقم الفاتورة: $receiptNumber
الإجمالي: ${total.toStringAsFixed(2)} $_currency

نتطلع لخدمتكم مرة أخرى! 🌟''';

    return _enqueueMessage(
      phone: phoneNumber,
      text: message,
      customerId: null,
      customerName: customerName,
      referenceType: 'sale',
      referenceId: receiptNumber,
      priority: 3,
    );
  }

  // ═══════════════════════════════════════════════════════
  // المساعد الداخلي: إضافة رسالة للطابور
  // ═══════════════════════════════════════════════════════

  /// إنشاء سجل رسالة في قاعدة البيانات بحالة "pending"
  ///
  /// يتم تنسيق رقم الهاتف تلقائياً (05x → 9665x).
  /// يُرجع معرف الرسالة (UUID) لتتبعها لاحقاً.
  Future<String> _enqueueMessage({
    required String phone,
    required String text,
    String messageType = 'text',
    String? customerId,
    String? customerName,
    String? referenceType,
    String? referenceId,
    int priority = 2,
    String? mediaLocalPath,
    String? fileName,
    String? batchId,
  }) async {
    final id = _uuid.v4();
    final formattedPhone = PhoneValidationService.formatPhone(phone);

    // التحقق من وجود رسالة مكررة حديثة (خلال 5 دقائق)
    if (referenceType != null && referenceId != null) {
      final duplicate = await _messagesDao.findRecentDuplicate(
        phone: formattedPhone,
        referenceType: referenceType,
        referenceId: referenceId,
      );
      if (duplicate != null) {
        return duplicate.id; // إرجاع معرف الرسالة الموجودة بدلاً من إنشاء مكررة
      }
    }

    await _messagesDao.enqueue(
      WhatsAppMessagesTableCompanion.insert(
        id: id,
        storeId: _storeId,
        phone: formattedPhone,
        messageType: messageType,
        textContent: Value(text),
        customerId: Value(customerId),
        customerName: Value(customerName),
        referenceType: Value(referenceType),
        referenceId: Value(referenceId),
        mediaLocalPath: Value(mediaLocalPath),
        fileName: Value(fileName),
        batchId: Value(batchId),
        createdAt: DateTime.now(),
        priority: Value(priority),
      ),
    );

    return id;
  }

  // ═══════════════════════════════════════════════════════
  // تنسيق رقم الهاتف (للتوافق مع الكود القديم)
  // ═══════════════════════════════════════════════════════

  /// تنسيق رقم الهاتف السعودي
  ///
  /// يحوّل 05x إلى 9665x ويزيل الرموز والمسافات.
  /// يُفضل استخدام [PhoneValidationService.formatPhone] مباشرة.
  static String formatPhoneNumber(String phone) {
    return PhoneValidationService.formatPhone(phone);
  }
}

// ═══════════════════════════════════════════════════════════
// قوالب رسائل WhatsApp
// ═══════════════════════════════════════════════════════════

/// قوالب رسائل WhatsApp
class WhatsAppTemplates {
  static const String debtReminder = 'debt_reminder';
  static const String receipt = 'receipt';
  static const String promotion = 'promotion';
  static const String orderUpdate = 'order_update';
  static const String welcome = 'welcome';

  static Map<String, String> get templates => {
    debtReminder: 'تذكير بالدين المستحق',
    receipt: 'إيصال الفاتورة',
    promotion: 'عرض ترويجي',
    orderUpdate: 'تحديث الطلب',
    welcome: 'رسالة ترحيب',
  };
}
