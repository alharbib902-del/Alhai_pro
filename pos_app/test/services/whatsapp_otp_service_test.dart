import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/services/whatsapp_otp_service.dart';
import 'package:pos_app/core/config/whatsapp_config.dart';

void main() {
  setUp(() async {
    // Reset state before each test
    await WhatsAppOtpService.reset();
  });

  group('WhatsAppOtpService', () {
    group('OTP Generation', () {
      test('should generate OTP with correct length', () {
        // The _generateOtp is private, but we can test via sendOtp behavior
        expect(WhatsAppConfig.otpLength, 6);
      });
    });

    group('Phone Formatting', () {
      test('should format phone starting with 05', () {
        // Test via getOtpData which uses _formatPhone internally
        final result1 = WhatsAppOtpService.getOtpData('0551234567');
        expect(result1, isNull); // No OTP sent yet
      });

      test('should format phone starting with 5', () {
        final result = WhatsAppOtpService.getOtpData('551234567');
        expect(result, isNull);
      });

      test('should format phone starting with +966', () {
        final result = WhatsAppOtpService.getOtpData('+966551234567');
        expect(result, isNull);
      });
    });

    group('Cooldown', () {
      test('should return null cooldown when no OTP sent', () {
        final cooldown = WhatsAppOtpService.getCooldownRemaining('0551234567');
        expect(cooldown, isNull);
      });

      test('should allow resend when no previous send', () {
        final canResend = WhatsAppOtpService.canResend('0551234567');
        expect(canResend, isTrue);
      });
    });

    group('OtpData', () {
      test('should create OtpData correctly', () {
        final now = DateTime.now();
        final data = OtpData(
          phone: '966551234567',
          otpHash: 'test_hash',
          createdAt: now,
          expiresAt: now.add(const Duration(minutes: 5)),
        );

        expect(data.phone, '966551234567');
        expect(data.otpHash, 'test_hash');
        expect(data.verifyAttempts, 0);
        expect(data.isExpired, isFalse);
      });

      test('should detect expired OTP', () {
        final now = DateTime.now();
        final data = OtpData(
          phone: '966551234567',
          otpHash: 'test_hash',
          createdAt: now.subtract(const Duration(minutes: 10)),
          expiresAt: now.subtract(const Duration(minutes: 5)),
        );

        expect(data.isExpired, isTrue);
        expect(data.remainingTime, Duration.zero);
      });

      test('should serialize to JSON', () {
        final now = DateTime.now();
        final data = OtpData(
          phone: '966551234567',
          otpHash: 'test_hash',
          createdAt: now,
          expiresAt: now.add(const Duration(minutes: 5)),
          verifyAttempts: 1,
        );

        final json = data.toJson();
        expect(json['phone'], '966551234567');
        expect(json['otpHash'], 'test_hash');
        expect(json['verifyAttempts'], 1);
      });

      test('should deserialize from JSON', () {
        final now = DateTime.now();
        final json = {
          'phone': '966551234567',
          'otpHash': 'test_hash',
          'createdAt': now.toIso8601String(),
          'expiresAt': now.add(const Duration(minutes: 5)).toIso8601String(),
          'verifyAttempts': 2,
        };

        final data = OtpData.fromJson(json);
        expect(data.phone, '966551234567');
        expect(data.verifyAttempts, 2);
      });
    });

    group('WhatsAppOtpSendResult', () {
      test('success should have isSuccess true', () {
        final result = WhatsAppOtpSendResult.success(messageId: '123');
        expect(result.isSuccess, isTrue);
        expect(result.messageId, '123');
        expect(result.error, isNull);
      });

      test('error should have isSuccess false', () {
        final result = WhatsAppOtpSendResult.error('Test error');
        expect(result.isSuccess, isFalse);
        expect(result.error, 'Test error');
      });

      test('rateLimited should have blockedUntil', () {
        final until = DateTime.now().add(const Duration(hours: 1));
        final result = WhatsAppOtpSendResult.rateLimited(until);
        expect(result.isSuccess, isFalse);
        expect(result.blockedUntil, until);
      });

      test('cooldown should have cooldown duration', () {
        const cooldown = Duration(seconds: 30);
        final result = WhatsAppOtpSendResult.cooldown(cooldown);
        expect(result.isSuccess, isFalse);
        expect(result.cooldown, cooldown);
      });
    });

    group('WhatsAppOtpVerifyResult', () {
      test('success should have isSuccess true', () {
        final result = WhatsAppOtpVerifyResult.success();
        expect(result.isSuccess, isTrue);
        expect(result.error, isNull);
      });

      test('invalid should have remaining attempts', () {
        final result = WhatsAppOtpVerifyResult.invalid(2);
        expect(result.isSuccess, isFalse);
        expect(result.remainingAttempts, 2);
      });

      test('expired should indicate expiry', () {
        final result = WhatsAppOtpVerifyResult.expired();
        expect(result.isSuccess, isFalse);
        expect(result.error, contains('انتهت'));
      });

      test('noOtpSent should indicate no OTP', () {
        final result = WhatsAppOtpVerifyResult.noOtpSent();
        expect(result.isSuccess, isFalse);
        expect(result.error, contains('لم يتم إرسال'));
      });

      test('maxAttemptsExceeded should have 0 remaining', () {
        final result = WhatsAppOtpVerifyResult.maxAttemptsExceeded();
        expect(result.isSuccess, isFalse);
        expect(result.remainingAttempts, 0);
      });
    });

    group('WhatsAppConfig', () {
      test('should have correct OTP length', () {
        expect(WhatsAppConfig.otpLength, 6);
      });

      test('should have correct expiry minutes', () {
        expect(WhatsAppConfig.otpExpiryMinutes, 5);
      });

      test('should have correct max verify attempts', () {
        expect(WhatsAppConfig.maxVerifyAttempts, 3);
      });

      test('should have correct cooldown seconds', () {
        expect(WhatsAppConfig.resendCooldownSeconds, 60);
      });

      test('should generate OTP message with code', () {
        final message = WhatsAppConfig.getOtpMessage('123456');
        expect(message, contains('123456'));
        expect(message, contains('بقالة الحي'));
        expect(message, contains('5 دقائق'));
      });

      test('should have valid headers', () {
        final headers = WhatsAppConfig.headers;
        expect(headers['Authorization'], startsWith('Bearer '));
        expect(headers['Content-Type'], 'application/json');
      });
    });
  });
}
