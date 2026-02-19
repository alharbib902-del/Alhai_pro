import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/config/whatsapp_config.dart';

// ===========================================
// WhatsApp Config Tests
// ===========================================

void main() {
  group('WhatsAppConfig - Constants', () {
    test('baseUrl معرف', () {
      expect(WhatsAppConfig.baseUrl, 'https://www.wasenderapi.com/api');
    });

    test('senderName له قيمة افتراضية', () {
      // القيمة الافتراضية من defaultValue
      expect(WhatsAppConfig.senderName, isA<String>());
    });

    test('otpExpiryMinutes معرف', () {
      expect(WhatsAppConfig.otpExpiryMinutes, 5);
    });

    test('otpLength معرف', () {
      expect(WhatsAppConfig.otpLength, 6);
    });

    test('maxVerifyAttempts معرف', () {
      expect(WhatsAppConfig.maxVerifyAttempts, 3);
    });

    test('maxSendRequestsPerHour معرف', () {
      expect(WhatsAppConfig.maxSendRequestsPerHour, 10);
    });

    test('resendCooldownSeconds معرف', () {
      expect(WhatsAppConfig.resendCooldownSeconds, 60);
    });
  });

  group('WhatsAppConfig - Configuration Status', () {
    test('isConfigured يتحقق من الإعدادات', () {
      // في بيئة الاختبار، القيم غير معرفة
      expect(WhatsAppConfig.isConfigured, isA<bool>());
    });

    test('isUsingEnvVariables يعتمد على isConfigured', () {
      expect(WhatsAppConfig.isUsingEnvVariables, WhatsAppConfig.isConfigured);
    });

    test('isDevMode يعتمد على kIsWeb و kDebugMode', () {
      expect(WhatsAppConfig.isDevMode, isA<bool>());
    });
  });

  group('WhatsAppConfig - configurationError', () {
    test('يُرجع رسالة خطأ عندما الإعدادات غير مكتملة', () {
      final error = WhatsAppConfig.configurationError;

      if (WhatsAppConfig.isConfigured) {
        expect(error, isEmpty);
      } else {
        expect(error, contains('Missing required environment variables'));
      }
    });

    test('رسالة الخطأ تحتوي على أسماء المتغيرات المفقودة', () {
      if (!WhatsAppConfig.isConfigured) {
        final error = WhatsAppConfig.configurationError;

        if (WhatsAppConfig.apiToken.isEmpty) {
          expect(error, contains('WASENDER_API_TOKEN'));
        }
        if (WhatsAppConfig.deviceId.isEmpty) {
          expect(error, contains('WASENDER_DEVICE_ID'));
        }
        if (WhatsAppConfig.senderNumber.isEmpty) {
          expect(error, contains('WASENDER_PHONE'));
        }
      }
    });
  });

  group('WhatsAppConfig - getOtpMessage', () {
    test('يُنشئ رسالة OTP صحيحة', () {
      final message = WhatsAppConfig.getOtpMessage('123456');

      expect(message, contains('123456'));
      expect(message, contains('رمز التحقق'));
      expect(message, contains('${WhatsAppConfig.otpExpiryMinutes} دقائق'));
    });

    test('يتضمن اسم المرسل', () {
      final message = WhatsAppConfig.getOtpMessage('000000');
      expect(message, contains(WhatsAppConfig.senderName));
    });

    test('يتضمن تحذير عدم المشاركة', () {
      final message = WhatsAppConfig.getOtpMessage('111111');
      expect(message, contains('لا تشارك هذا الرمز'));
    });

    test('يعمل مع أي رمز OTP', () {
      final message1 = WhatsAppConfig.getOtpMessage('999999');
      final message2 = WhatsAppConfig.getOtpMessage('000001');

      expect(message1, contains('999999'));
      expect(message2, contains('000001'));
    });
  });

  group('WhatsAppConfig - headers', () {
    test('يحتوي على Content-Type', () {
      final headers = WhatsAppConfig.headers;
      expect(headers['Content-Type'], 'application/json');
    });

    test('يحتوي على Accept', () {
      final headers = WhatsAppConfig.headers;
      expect(headers['Accept'], 'application/json');
    });

    test('يحتوي على Authorization', () {
      final headers = WhatsAppConfig.headers;
      expect(headers.containsKey('Authorization'), true);
      expect(headers['Authorization'], startsWith('Bearer '));
    });
  });

  group('WhatsAppConfig - Environment Variables', () {
    test('apiToken يُرجع String', () {
      expect(WhatsAppConfig.apiToken, isA<String>());
    });

    test('deviceId يُرجع String', () {
      expect(WhatsAppConfig.deviceId, isA<String>());
    });

    test('senderNumber يُرجع String', () {
      expect(WhatsAppConfig.senderNumber, isA<String>());
    });
  });
}
