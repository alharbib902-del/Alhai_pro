/// إعدادات WaSenderAPI لإرسال OTP عبر WhatsApp
///
/// ⚠️ ملاحظة أمنية مهمة:
/// يجب تمرير القيم الحساسة عبر --dart-define عند البناء:
///
/// للتطوير:
/// flutter run --dart-define=WASENDER_API_TOKEN=xxx --dart-define=WASENDER_DEVICE_ID=xxx
///
/// للإنتاج:
/// flutter build apk --dart-define=WASENDER_API_TOKEN=xxx --dart-define=WASENDER_DEVICE_ID=xxx
///
/// ⚠️ لا تضع القيم الفعلية في الكود أبداً!
library;

import 'package:flutter/foundation.dart';

/// إعدادات WaSenderAPI
class WhatsAppConfig {
  WhatsAppConfig._();

  /// API Base URL
  /// الـ endpoint الصحيح حسب توثيق WaSenderAPI الرسمي
  static const String baseUrl = 'https://www.wasenderapi.com/api';

  /// API Token من Environment Variables
  /// ⚠️ مطلوب: --dart-define=WASENDER_API_TOKEN=your_token
  static const String apiToken = String.fromEnvironment(
    'WASENDER_API_TOKEN',
    // لا يوجد defaultValue - يجب تمريره دائماً
  );

  /// WhatsApp Device ID من Environment Variables
  /// ⚠️ مطلوب: --dart-define=WASENDER_DEVICE_ID=your_device_id
  static const String deviceId = String.fromEnvironment(
    'WASENDER_DEVICE_ID',
    // لا يوجد defaultValue - يجب تمريره دائماً
  );

  /// رقم المرسل من Environment Variables
  /// ⚠️ مطلوب: --dart-define=WASENDER_PHONE=+966xxxxxxxxx
  static const String senderNumber = String.fromEnvironment(
    'WASENDER_PHONE',
    // لا يوجد defaultValue - يجب تمريره دائماً
  );

  /// اسم المرسل
  static const String senderName = String.fromEnvironment(
    'WASENDER_NAME',
    defaultValue: 'بقالة الحي',
  );

  /// مدة صلاحية OTP بالدقائق
  static const int otpExpiryMinutes = 5;

  /// طول رمز OTP
  static const int otpLength = 6;

  /// الحد الأقصى لمحاولات التحقق
  static const int maxVerifyAttempts = 3;

  /// الحد الأقصى لطلبات الإرسال في الساعة
  static const int maxSendRequestsPerHour = 10;

  /// فترة الانتظار بين الإرسال (بالثواني)
  static const int resendCooldownSeconds = 60;

  /// هل الإعدادات مكتملة؟
  static bool get isConfigured =>
      apiToken.isNotEmpty && deviceId.isNotEmpty && senderNumber.isNotEmpty;

  /// هل يستخدم Environment Variables؟
  static bool get isUsingEnvVariables => isConfigured;

  /// هل هو وضع التطوير؟ (Web + Debug)
  /// في وضع التطوير: يتم عرض OTP في Console بدلاً من إرساله عبر WhatsApp
  static bool get isDevMode => kIsWeb && kDebugMode;

  /// رسالة خطأ إذا كانت الإعدادات غير مكتملة
  static String get configurationError {
    final missing = <String>[];
    if (apiToken.isEmpty) missing.add('WASENDER_API_TOKEN');
    if (deviceId.isEmpty) missing.add('WASENDER_DEVICE_ID');
    if (senderNumber.isEmpty) missing.add('WASENDER_PHONE');

    if (missing.isEmpty) return '';
    return 'Missing required environment variables: ${missing.join(', ')}. '
           'Use --dart-define to provide them.';
  }

  /// قالب رسالة OTP
  static String getOtpMessage(String otp) {
    return '''$senderName 🛒

رمز التحقق الخاص بك:
*$otp*

⏱️ صالح لمدة $otpExpiryMinutes دقائق
⚠️ لا تشارك هذا الرمز مع أحد

شكراً لاستخدامك تطبيقنا!''';
  }

  /// Headers للـ API
  static Map<String, String> get headers => {
        'Authorization': 'Bearer $apiToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
}
