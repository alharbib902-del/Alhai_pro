import 'dart:convert';

import 'package:alhai_core/alhai_core.dart' show AppEndpoints, StoreSettings;

/// خدمة الرسائل النصية SMS
/// تستخدم من: cashier, admin_pos
///
/// تحتاج: SMS Gateway مثل:
/// - Twilio
/// - Unifonic (سعودي)
/// - Vonage
class SmsService {
  static const String _currency = StoreSettings.defaultCurrencySymbol;
  final String? _apiUrl;
  final String? _apiKey;
  final String? _senderId;
  final SmsProvider _provider;

  /// Twilio-specific: Account SID (used as part of the API URL path)
  final String? _twilioAccountSid;

  /// Twilio-specific: Auth token (used for HTTP Basic auth)
  final String? _twilioAuthToken;

  /// Vonage-specific: API secret
  final String? _vonageApiSecret;

  SmsService({
    String? apiUrl,
    String? apiKey,
    String? senderId,
    SmsProvider provider = SmsProvider.unifonic,
    String? twilioAccountSid,
    String? twilioAuthToken,
    String? vonageApiSecret,
  }) : _apiUrl = apiUrl,
       _apiKey = apiKey,
       _senderId = senderId,
       _provider = provider,
       _twilioAccountSid = twilioAccountSid,
       _twilioAuthToken = twilioAuthToken,
       _vonageApiSecret = vonageApiSecret;

  /// التحقق من التكوين
  bool get isConfigured => _apiKey != null && _apiKey.isNotEmpty;

  // ==================== إرسال الرسائل ====================

  /// إرسال رسالة SMS
  Future<SmsResult> sendSms({
    required String phoneNumber,
    required String message,
  }) async {
    if (!isConfigured) {
      return const SmsResult(success: false, error: 'خدمة SMS غير مكونة');
    }

    try {
      final senderId = _senderId ?? 'Alhai';

      // Build provider-specific HTTP request
      final request = _buildSendRequest(
        phoneNumber: phoneNumber,
        message: message,
        senderId: senderId,
      );

      // In production, send using http package:
      //   final response = await http.post(
      //     Uri.parse(request.url),
      //     headers: request.headers,
      //     body: request.isJsonBody ? jsonEncode(request.body) : request.body,
      //   );
      //   return _parseSendResponse(response);

      // For now, log the structured request and return a mock result
      final _ = request; // ignore: unused_local_variable
      throw UnimplementedError(
        'SMS sending requires the http package. '
        'Provider: ${_provider.name}, Endpoint: ${request.url}',
      );
    } catch (e) {
      if (e is UnimplementedError) {
        return SmsResult(success: false, error: e.message);
      }
      return SmsResult(success: false, error: e.toString());
    }
  }

  /// إرسال OTP
  Future<SmsResult> sendOtp({
    required String phoneNumber,
    required String otp,
    String? appName,
  }) async {
    final message =
        '${appName ?? 'الهاي'}: رمز التحقق الخاص بك هو: $otp\nصالح لمدة 5 دقائق.';

    return await sendSms(phoneNumber: phoneNumber, message: message);
  }

  // ==================== رسائل محددة مسبقاً ====================

  /// إرسال تذكير دين
  Future<SmsResult> sendDebtReminder({
    required String phoneNumber,
    required String customerName,
    required double amount,
    String? storeName,
  }) async {
    final message =
        '''
$customerName المحترم،
لديكم مبلغ مستحق: ${amount.toStringAsFixed(2)} $_currency
${storeName != null ? 'من: $storeName' : ''}
نرجو السداد في أقرب وقت.
''';

    return await sendSms(phoneNumber: phoneNumber, message: message);
  }

  /// إرسال تأكيد طلب
  Future<SmsResult> sendOrderConfirmation({
    required String phoneNumber,
    required String orderNumber,
    required double total,
  }) async {
    final message =
        '''
تم استلام طلبكم!
رقم الطلب: $orderNumber
الإجمالي: ${total.toStringAsFixed(2)} $_currency
شكراً لتعاملكم معنا.
''';

    return await sendSms(phoneNumber: phoneNumber, message: message);
  }

  /// إرسال تحديث حالة الطلب
  Future<SmsResult> sendOrderStatusUpdate({
    required String phoneNumber,
    required String orderNumber,
    required String status,
  }) async {
    final message = 'تحديث طلبكم #$orderNumber: $status';

    return await sendSms(phoneNumber: phoneNumber, message: message);
  }

  /// إرسال رابط تتبع
  Future<SmsResult> sendTrackingLink({
    required String phoneNumber,
    required String orderNumber,
    required String trackingUrl,
  }) async {
    final message =
        '''
لتتبع طلبكم #$orderNumber:
$trackingUrl
''';

    return await sendSms(phoneNumber: phoneNumber, message: message);
  }

  // ==================== إرسال مجمع ====================

  /// إرسال رسالة لعدة أرقام
  Future<SmsBulkResult> sendBulkSms({
    required List<String> phoneNumbers,
    required String message,
  }) async {
    final results = <String, SmsResult>{};

    for (final phone in phoneNumbers) {
      results[phone] = await sendSms(phoneNumber: phone, message: message);

      // Small delay to avoid rate limiting
      await Future.delayed(const Duration(milliseconds: 100));
    }

    final successCount = results.values.where((r) => r.success).length;

    return SmsBulkResult(
      success: successCount == phoneNumbers.length,
      totalSent: successCount,
      totalFailed: phoneNumbers.length - successCount,
      results: results,
    );
  }

  // ==================== الرصيد ====================

  /// التحقق من رصيد SMS
  Future<SmsBalanceResult> checkBalance() async {
    if (!isConfigured) {
      return const SmsBalanceResult(
        success: false,
        error: 'خدمة SMS غير مكونة',
      );
    }

    try {
      // Build provider-specific balance check request
      final request = _buildBalanceRequest();

      // In production, send using http package:
      //   final response = await http.get(
      //     Uri.parse(request.url),
      //     headers: request.headers,
      //   );
      //   return _parseBalanceResponse(response);

      final _ = request; // ignore: unused_local_variable
      throw UnimplementedError(
        'Balance check requires the http package. '
        'Provider: ${_provider.name}, Endpoint: ${request.url}',
      );
    } catch (e) {
      if (e is UnimplementedError) {
        return SmsBalanceResult(success: false, error: e.message);
      }
      return SmsBalanceResult(success: false, error: e.toString());
    }
  }

  // ==================== Provider-specific request builders ====================

  /// Builds an HTTP request structure for sending an SMS based on the provider.
  SmsHttpRequest _buildSendRequest({
    required String phoneNumber,
    required String message,
    required String senderId,
  }) {
    final apiUrl = _apiUrl ?? _getDefaultApiUrl();

    switch (_provider) {
      case SmsProvider.unifonic:
        // Unifonic REST API
        // Docs: https://docs.unifonic.com/reference/send-sms
        return SmsHttpRequest(
          method: 'POST',
          url: '$apiUrl/rest/Messages/Send',
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json',
          },
          body: {
            'AppSid': _apiKey!,
            'Recipient': phoneNumber,
            'Body': message,
            'SenderID': senderId,
            'responseType': 'JSON',
            'CorrelationID': 'req_${DateTime.now().millisecondsSinceEpoch}',
          },
          isJsonBody: false, // form-urlencoded
        );

      case SmsProvider.twilio:
        // Twilio REST API
        // Docs: https://www.twilio.com/docs/sms/api/message-resource#create-a-message-resource
        final accountSid = _twilioAccountSid ?? _apiKey!;
        final authToken = _twilioAuthToken ?? '';
        final credentials = base64Encode(utf8.encode('$accountSid:$authToken'));

        return SmsHttpRequest(
          method: 'POST',
          url: '$apiUrl/$accountSid/Messages.json',
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Basic $credentials',
          },
          body: {'To': phoneNumber, 'From': senderId, 'Body': message},
          isJsonBody: false, // form-urlencoded
        );

      case SmsProvider.vonage:
        // Vonage (Nexmo) SMS API
        // Docs: https://developer.vonage.com/en/api/sms
        return SmsHttpRequest(
          method: 'POST',
          url: '$apiUrl/sms/json',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: {
            'api_key': _apiKey!,
            'api_secret': _vonageApiSecret ?? '',
            'from': senderId,
            'to': phoneNumber,
            'text': message,
            'type': 'unicode', // Support Arabic text
          },
          isJsonBody: true,
        );
    }
  }

  /// Builds an HTTP request structure for checking SMS balance.
  SmsHttpRequest _buildBalanceRequest() {
    final apiUrl = _apiUrl ?? _getDefaultApiUrl();

    switch (_provider) {
      case SmsProvider.unifonic:
        // Unifonic Account Balance API
        return SmsHttpRequest(
          method: 'POST',
          url: '$apiUrl/rest/Account/GetBalance',
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json',
          },
          body: {'AppSid': _apiKey!},
          isJsonBody: false,
        );

      case SmsProvider.twilio:
        // Twilio Account Balance API
        final accountSid = _twilioAccountSid ?? _apiKey!;
        final authToken = _twilioAuthToken ?? '';
        final credentials = base64Encode(utf8.encode('$accountSid:$authToken'));

        return SmsHttpRequest(
          method: 'GET',
          url: '$apiUrl/$accountSid/Balance.json',
          headers: {
            'Authorization': 'Basic $credentials',
            'Accept': 'application/json',
          },
          body: {},
          isJsonBody: false,
        );

      case SmsProvider.vonage:
        // Vonage Account Balance API
        return SmsHttpRequest(
          method: 'GET',
          url:
              '${AppEndpoints.nexmoBase}/account/get-balance?api_key=${_apiKey!}&api_secret=${_vonageApiSecret ?? ''}',
          headers: {'Accept': 'application/json'},
          body: {},
          isJsonBody: false,
        );
    }
  }

  /// Get default API URL based on provider
  String _getDefaultApiUrl() {
    switch (_provider) {
      case SmsProvider.unifonic:
        return AppEndpoints.unifonicBase;
      case SmsProvider.twilio:
        return AppEndpoints.twilioBase;
      case SmsProvider.vonage:
        return AppEndpoints.nexmoBase;
    }
  }
}

/// Structured HTTP request for SMS API calls.
/// Used to prepare the request before sending with http package.
class SmsHttpRequest {
  final String method;
  final String url;
  final Map<String, String> headers;
  final Map<String, String> body;
  final bool isJsonBody;

  const SmsHttpRequest({
    required this.method,
    required this.url,
    required this.headers,
    required this.body,
    required this.isJsonBody,
  });

  @override
  String toString() => 'SmsHttpRequest($method $url, body: $body)';
}

/// مزود خدمة SMS
enum SmsProvider {
  unifonic, // Saudi provider
  twilio,
  vonage,
}

/// نتيجة إرسال SMS
class SmsResult {
  final bool success;
  final String? messageId;
  final String? error;

  const SmsResult({required this.success, this.messageId, this.error});
}

/// نتيجة إرسال SMS مجمع
class SmsBulkResult {
  final bool success;
  final int totalSent;
  final int totalFailed;
  final Map<String, SmsResult> results;

  const SmsBulkResult({
    required this.success,
    required this.totalSent,
    required this.totalFailed,
    required this.results,
  });
}

/// نتيجة التحقق من الرصيد
class SmsBalanceResult {
  final bool success;
  final double? balance;
  final String? currency;
  final String? error;

  const SmsBalanceResult({
    required this.success,
    this.balance,
    this.currency,
    this.error,
  });
}
