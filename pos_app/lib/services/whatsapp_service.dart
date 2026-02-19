import 'package:url_launcher/url_launcher.dart';

/// خدمة WhatsApp Business للتواصل مع العملاء
class WhatsAppService {
  static const String _baseUrl = 'https://wa.me';

  /// إرسال رسالة WhatsApp
  static Future<bool> sendMessage({
    required String phoneNumber,
    required String message,
  }) async {
    final formattedPhone = _formatPhoneNumber(phoneNumber);
    final encodedMessage = Uri.encodeComponent(message);
    final url = Uri.parse('$_baseUrl/$formattedPhone?text=$encodedMessage');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      return true;
    }
    return false;
  }

  /// إرسال تذكير دين
  static Future<bool> sendDebtReminder({
    required String phoneNumber,
    required String customerName,
    required double amount,
    required String storeName,
  }) {
    final message = '''
مرحباً $customerName 👋

نود تذكيركم بوجود رصيد مستحق بقيمة ${amount.toStringAsFixed(2)} ر.س

نرجو التواصل معنا لتسوية المبلغ.
شكراً لتعاونكم 🙏

$storeName
''';
    return sendMessage(phoneNumber: phoneNumber, message: message);
  }

  /// إرسال إيصال
  static Future<bool> sendReceipt({
    required String phoneNumber,
    required String customerName,
    required String receiptNumber,
    required double total,
    required String storeName,
  }) {
    final message = '''
شكراً لتسوقكم من $storeName 🛒

رقم الفاتورة: $receiptNumber
الإجمالي: ${total.toStringAsFixed(2)} ر.س

نتطلع لخدمتكم مرة أخرى! 🌟
''';
    return sendMessage(phoneNumber: phoneNumber, message: message);
  }

  /// إرسال عرض ترويجي
  static Future<bool> sendPromotion({
    required String phoneNumber,
    required String customerName,
    required String promotionTitle,
    required String promotionDetails,
    required String storeName,
  }) {
    final message = '''
مرحباً $customerName 🎉

عرض خاص لك!
$promotionTitle

$promotionDetails

تفضل بزيارتنا للاستفادة من العرض 🏃‍♂️

$storeName
''';
    return sendMessage(phoneNumber: phoneNumber, message: message);
  }

  /// إرسال تحديث طلب
  static Future<bool> sendOrderUpdate({
    required String phoneNumber,
    required String orderNumber,
    required String status,
    required String storeName,
  }) {
    final statusMessages = {
      'confirmed': 'تم تأكيد طلبك ✅',
      'preparing': 'جاري تحضير طلبك 🍳',
      'ready': 'طلبك جاهز للاستلام 📦',
      'delivering': 'طلبك في الطريق إليك 🚗',
      'delivered': 'تم توصيل طلبك بنجاح ✅',
    };
    
    final statusMessage = statusMessages[status] ?? 'تم تحديث حالة طلبك';
    
    final message = '''
مرحباً 👋

تحديث الطلب رقم: $orderNumber
$statusMessage

$storeName
''';
    return sendMessage(phoneNumber: phoneNumber, message: message);
  }

  /// تنسيق رقم الهاتف
  static String _formatPhoneNumber(String phone) {
    // إزالة أي مسافات أو رموز
    var cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // إضافة كود السعودية إذا لم يكن موجوداً
    if (cleaned.startsWith('05')) {
      cleaned = '966${cleaned.substring(1)}';
    } else if (cleaned.startsWith('5')) {
      cleaned = '966$cleaned';
    } else if (!cleaned.startsWith('+') && !cleaned.startsWith('966')) {
      cleaned = '966$cleaned';
    }
    
    return cleaned.replaceAll('+', '');
  }
}

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
