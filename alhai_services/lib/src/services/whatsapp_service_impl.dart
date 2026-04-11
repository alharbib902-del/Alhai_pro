import 'package:alhai_core/alhai_core.dart';

/// Implementation of WhatsAppService for sending receipts via WhatsApp
/// Uses WhatsApp Business API or Cloud API
/// Referenced by: US-3.4 (WhatsApp Receipt)
class WhatsAppServiceImpl implements WhatsAppService {
  // Configuration
  final String? _accessToken;
  final String? _phoneNumberId;
  final String _baseUrl;

  // Message tracking
  final Map<String, WhatsAppMessageStatus> _messageStatuses = {};

  // Store configuration
  final Map<String, _StoreWhatsAppConfig> _storeConfigs = {};

  // Daily limits tracking
  final Map<String, int> _dailyMessageCounts = {};
  static const int _defaultDailyLimit = 1000;

  WhatsAppServiceImpl({
    String? accessToken,
    String? phoneNumberId,
    String? baseUrl,
  }) : _accessToken = accessToken,
       _phoneNumberId = phoneNumberId,
       _baseUrl = baseUrl ?? AppEndpoints.whatsAppGraph;

  @override
  Future<WhatsAppReceiptResponse> sendReceipt(
    WhatsAppReceiptRequest request,
  ) async {
    try {
      // Validate phone number
      if (!isValidWhatsAppNumber(request.phone)) {
        return WhatsAppReceiptResponse(
          messageId: '',
          status: WhatsAppMessageStatus.failed,
          receiptUrl: '',
          errorMessage: 'رقم الهاتف غير صالح لـ WhatsApp',
        );
      }

      // Generate receipt URL
      final receiptUrl = await getReceiptUrl(request.orderId);

      // Prepare message
      final message = _buildReceiptMessage(
        customerName: request.customerName,
        receiptUrl: receiptUrl,
        language: request.language ?? 'ar',
      );

      // In production, this would call the WhatsApp API
      // For now, simulate the API call
      final messageId = await _sendMessage(
        phone: request.phone,
        message: message,
      );

      // Track status
      _messageStatuses[messageId] = WhatsAppMessageStatus.sent;

      // Increment daily count
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final key = 'global_$today';
      _dailyMessageCounts[key] = (_dailyMessageCounts[key] ?? 0) + 1;

      return WhatsAppReceiptResponse(
        messageId: messageId,
        status: WhatsAppMessageStatus.sent,
        receiptUrl: receiptUrl,
      );
    } catch (e) {
      return WhatsAppReceiptResponse(
        messageId: '',
        status: WhatsAppMessageStatus.failed,
        receiptUrl: '',
        errorMessage: 'فشل إرسال الفاتورة: $e',
      );
    }
  }

  @override
  Future<WhatsAppMessageStatus> checkStatus(String messageId) async {
    // In production, this would call the WhatsApp API to check status
    return _messageStatuses[messageId] ?? WhatsAppMessageStatus.failed;
  }

  @override
  bool isValidWhatsAppNumber(String phone) {
    // Remove all non-digit characters
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Saudi Arabia format: 966XXXXXXXXX (12 digits)
    if (cleaned.startsWith('966') && cleaned.length == 12) {
      return true;
    }

    // Local format: 05XXXXXXXX (10 digits)
    if (cleaned.startsWith('05') && cleaned.length == 10) {
      return true;
    }

    // International format with +
    if (phone.startsWith('+') && cleaned.length >= 10) {
      return true;
    }

    return false;
  }

  @override
  Future<String> getReceiptUrl(String orderId) async {
    // Generate a URL for the receipt
    // In production, this would be a public URL to view the receipt
    return AppEndpoints.receiptUrl(orderId);
  }

  @override
  Future<bool> isConfigured(String storeId) async {
    // Check if WhatsApp is configured for this store
    if (_storeConfigs.containsKey(storeId)) {
      final config = _storeConfigs[storeId]!;
      return config.isActive && config.accessToken.isNotEmpty;
    }

    // Fall back to global configuration
    final token = _accessToken;
    return token != null && token.isNotEmpty;
  }

  @override
  Future<int> getRemainingDailyLimit(String storeId) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final key = '${storeId}_$today';
    final sent = _dailyMessageCounts[key] ?? 0;

    // Get store-specific limit or default
    final limit = _storeConfigs[storeId]?.dailyLimit ?? _defaultDailyLimit;

    return (limit - sent).clamp(0, limit);
  }

  // Configure a store for WhatsApp
  void configureStore({
    required String storeId,
    required String accessToken,
    required String phoneNumberId,
    int dailyLimit = _defaultDailyLimit,
  }) {
    _storeConfigs[storeId] = _StoreWhatsAppConfig(
      accessToken: accessToken,
      phoneNumberId: phoneNumberId,
      dailyLimit: dailyLimit,
      isActive: true,
    );
  }

  // Disable WhatsApp for a store
  void disableStore(String storeId) {
    if (_storeConfigs.containsKey(storeId)) {
      final config = _storeConfigs[storeId]!;
      _storeConfigs[storeId] = _StoreWhatsAppConfig(
        accessToken: config.accessToken,
        phoneNumberId: config.phoneNumberId,
        dailyLimit: config.dailyLimit,
        isActive: false,
      );
    }
  }

  // Helper methods

  String _buildReceiptMessage({
    required String customerName,
    required String receiptUrl,
    required String language,
  }) {
    if (language == 'ar') {
      return '''
مرحباً $customerName،

شكراً لتسوقك معنا! 🛒

يمكنك مراجعة فاتورتك من هنا:
$receiptUrl

نتطلع لخدمتك مرة أخرى!
''';
    } else {
      return '''
Hello $customerName,

Thank you for shopping with us! 🛒

You can view your receipt here:
$receiptUrl

We look forward to serving you again!
''';
    }
  }

  Future<String> _sendMessage({
    required String phone,
    required String message,
  }) async {
    // In production, this would call the WhatsApp Business API
    // POST https://graph.facebook.com/v17.0/{phone-number-id}/messages
    // with the message payload

    // ignore: unused_local_variable
    final apiUrl = '$_baseUrl/$_phoneNumberId/messages';
    // ignore: unused_local_variable
    final headers = {
      'Authorization': 'Bearer $_accessToken',
      'Content-Type': 'application/json',
    };

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 100));

    // Generate message ID
    final messageId = 'wamid.${DateTime.now().millisecondsSinceEpoch}';

    return messageId;
  }

  /// Format phone number to international format
  String formatPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Convert 05XXXXXXXX to 966XXXXXXXXX
    if (cleaned.startsWith('05') && cleaned.length == 10) {
      return '966${cleaned.substring(1)}';
    }

    // Remove leading zeros
    if (cleaned.startsWith('0')) {
      return '966${cleaned.substring(1)}';
    }

    return cleaned;
  }

  /// Send template message (for approved templates)
  Future<WhatsAppReceiptResponse> sendTemplateMessage({
    required String phone,
    required String templateName,
    required List<String> parameters,
    String language = 'ar',
  }) async {
    try {
      if (!isValidWhatsAppNumber(phone)) {
        return const WhatsAppReceiptResponse(
          messageId: '',
          status: WhatsAppMessageStatus.failed,
          receiptUrl: '',
          errorMessage: 'رقم الهاتف غير صالح',
        );
      }

      // In production, send template message via API
      await Future.delayed(const Duration(milliseconds: 100));

      final messageId =
          'wamid.template.${DateTime.now().millisecondsSinceEpoch}';
      _messageStatuses[messageId] = WhatsAppMessageStatus.sent;

      return WhatsAppReceiptResponse(
        messageId: messageId,
        status: WhatsAppMessageStatus.sent,
        receiptUrl: '',
      );
    } catch (e) {
      return WhatsAppReceiptResponse(
        messageId: '',
        status: WhatsAppMessageStatus.failed,
        receiptUrl: '',
        errorMessage: e.toString(),
      );
    }
  }
}

/// Internal store configuration
class _StoreWhatsAppConfig {
  final String accessToken;
  final String phoneNumberId;
  final int dailyLimit;
  final bool isActive;

  const _StoreWhatsAppConfig({
    required this.accessToken,
    required this.phoneNumberId,
    required this.dailyLimit,
    required this.isActive,
  });
}
