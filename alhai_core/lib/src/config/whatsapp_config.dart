/// إعدادات WaSenderAPI لإرسال OTP عبر WhatsApp
///
/// Canonical location: alhai_core
/// Previously duplicated in alhai_auth and alhai_pos.
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

  // ═══════════════════════════════════════════════════════
  // إعدادات Webhook
  // ═══════════════════════════════════════════════════════

  /// Webhook Secret للتحقق من التوقيع
  /// ⚠️ مطلوب: --dart-define=WASENDER_WEBHOOK_SECRET=xxx
  static const String webhookSecret = String.fromEnvironment(
    'WASENDER_WEBHOOK_SECRET',
  );

  /// هل Webhook مُعد؟
  static bool get isWebhookConfigured => webhookSecret.isNotEmpty;

  // ═══════════════════════════════════════════════════════
  // إعدادات الإرسال الجماعي
  // ═══════════════════════════════════════════════════════

  /// الحد الأقصى لعدد الرسائل في الدفعة الواحدة
  static const int maxBatchSize = 50;

  /// التأخير بين الرسائل بالملي ثانية (لتجنب rate limiting)
  static const int batchDelayMs = 1000;

  /// الحد الأقصى لإعادة محاولة الإرسال
  static const int maxMessageRetries = 3;

  // ═══════════════════════════════════════════════════════
  // حدود رفع الملفات (بالبايت)
  // ═══════════════════════════════════════════════════════

  /// الحد الأقصى لحجم الصور (16MB)
  static const int maxImageSize = 16 * 1024 * 1024;

  /// الحد الأقصى لحجم الفيديو (50MB)
  static const int maxVideoSize = 50 * 1024 * 1024;

  /// الحد الأقصى لحجم المستندات (100MB)
  static const int maxDocumentSize = 100 * 1024 * 1024;

  /// الحد الأقصى لحجم الصوت (16MB)
  static const int maxAudioSize = 16 * 1024 * 1024;

  /// مدة صلاحية رابط الرفع (بالساعات)
  static const int uploadUrlValidityHours = 24;

  /// هل الإعدادات مكتملة؟
  static bool get isConfigured =>
      apiToken.isNotEmpty && deviceId.isNotEmpty && senderNumber.isNotEmpty;

  /// هل يستخدم Environment Variables؟
  static bool get isUsingEnvVariables => isConfigured;

  /// هل وضع الاختبار مفعّل عبر --dart-define=TEST_MODE=true
  static const bool _testMode = bool.fromEnvironment(
    'TEST_MODE',
    defaultValue: false,
  );

  /// هل هو وضع التطوير؟ (Debug Mode أو TEST_MODE=true في Debug فقط)
  /// في وضع التطوير: يتم عرض OTP في UI بدلاً من إرساله عبر WhatsApp
  /// ⚠️ يتم تجاهل TEST_MODE تماماً في Release builds
  static bool get isDevMode {
    if (kReleaseMode) return false;
    return kDebugMode || _testMode;
  }

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
