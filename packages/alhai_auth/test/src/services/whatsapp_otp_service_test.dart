import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_auth/alhai_auth.dart';

void main() {
  late InMemoryStorage storage;

  setUp(() {
    storage = InMemoryStorage();
    SecureStorageService.setStorage(storage);
  });

  tearDown(() async {
    await WhatsAppOtpService.reset();
    SecurityLogger.clear();
    SecureStorageService.resetStorage();
  });

  group('OtpData', () {
    test('isExpired returns true when past expiry', () {
      final data = OtpData(
        phone: '966512345678',
        otpHash: 'hash',
        otpSalt: 'salt',
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        expiresAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      expect(data.isExpired, isTrue);
    });

    test('isExpired returns false when before expiry', () {
      final data = OtpData(
        phone: '966512345678',
        otpHash: 'hash',
        otpSalt: 'salt',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      );

      expect(data.isExpired, isFalse);
    });

    test('remainingTime returns Duration.zero when expired', () {
      final data = OtpData(
        phone: '966512345678',
        otpHash: 'hash',
        otpSalt: 'salt',
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        expiresAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      expect(data.remainingTime, equals(Duration.zero));
    });

    test('remainingTime returns positive duration when not expired', () {
      final data = OtpData(
        phone: '966512345678',
        otpHash: 'hash',
        otpSalt: 'salt',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      );

      expect(data.remainingTime.inMinutes, greaterThan(0));
    });

    test('toJson and fromJson round-trip', () {
      final now = DateTime.now();
      final data = OtpData(
        phone: '966512345678',
        otpHash: 'abc123',
        otpSalt: 'salt123',
        createdAt: now,
        expiresAt: now.add(const Duration(minutes: 5)),
        verifyAttempts: 1,
      );

      final json = data.toJson();
      final restored = OtpData.fromJson(json);

      expect(restored.phone, equals('966512345678'));
      expect(restored.otpHash, equals('abc123'));
      expect(restored.otpSalt, equals('salt123'));
      expect(restored.verifyAttempts, equals(1));
    });
  });

  group('WhatsAppOtpSendResult', () {
    test('success factory creates successful result', () {
      final result = WhatsAppOtpSendResult.success(messageId: 'msg-1');
      expect(result.isSuccess, isTrue);
      expect(result.messageId, equals('msg-1'));
    });

    test('success with devOtp includes otp', () {
      final result = WhatsAppOtpSendResult.success(
        messageId: 'dev',
        devOtp: '123456',
      );
      expect(result.isSuccess, isTrue);
      expect(result.devOtp, equals('123456'));
    });

    test('error factory creates failed result', () {
      final result = WhatsAppOtpSendResult.error('Connection failed');
      expect(result.isSuccess, isFalse);
      expect(result.error, equals('Connection failed'));
    });

    test('rateLimited factory includes blockedUntil', () {
      final until = DateTime.now().add(const Duration(hours: 1));
      final result = WhatsAppOtpSendResult.rateLimited(until);
      expect(result.isSuccess, isFalse);
      expect(result.blockedUntil, equals(until));
    });

    test('cooldown factory includes duration', () {
      final result = WhatsAppOtpSendResult.cooldown(
        const Duration(seconds: 45),
      );
      expect(result.isSuccess, isFalse);
      expect(result.cooldown, equals(const Duration(seconds: 45)));
    });
  });

  group('WhatsAppOtpVerifyResult', () {
    test('success factory creates successful result', () {
      final result = WhatsAppOtpVerifyResult.success();
      expect(result.isSuccess, isTrue);
    });

    test('invalid factory includes remaining attempts', () {
      final result = WhatsAppOtpVerifyResult.invalid(2);
      expect(result.isSuccess, isFalse);
      expect(result.remainingAttempts, equals(2));
    });

    test('expired factory creates expired result', () {
      final result = WhatsAppOtpVerifyResult.expired();
      expect(result.isSuccess, isFalse);
    });

    test('noOtpSent factory creates no-otp result', () {
      final result = WhatsAppOtpVerifyResult.noOtpSent();
      expect(result.isSuccess, isFalse);
    });

    test('maxAttemptsExceeded factory has zero remaining', () {
      final result = WhatsAppOtpVerifyResult.maxAttemptsExceeded();
      expect(result.isSuccess, isFalse);
      expect(result.remainingAttempts, equals(0));
    });

    test('error factory creates error result', () {
      final result = WhatsAppOtpVerifyResult.error('Something went wrong');
      expect(result.isSuccess, isFalse);
      expect(result.error, equals('Something went wrong'));
    });
  });

  group('WhatsAppOtpService', () {
    group('reset', () {
      test('clears all internal state', () async {
        await WhatsAppOtpService.reset();

        // Should not have any OTP data
        final data = WhatsAppOtpService.getOtpData('966512345678');
        expect(data, isNull);
      });
    });

    group('canResend', () {
      test('returns true when no previous send', () {
        final canResend = WhatsAppOtpService.canResend('966512345678');
        expect(canResend, isTrue);
      });
    });

    group('getOtpData', () {
      test('returns null for unknown phone', () {
        final data = WhatsAppOtpService.getOtpData('966512345678');
        expect(data, isNull);
      });
    });

    group('getCooldownRemaining', () {
      test('returns null when no previous send', () {
        final cooldown = WhatsAppOtpService.getCooldownRemaining(
          '966512345678',
        );
        expect(cooldown, isNull);
      });
    });

    group('verifyOtp', () {
      test('returns noOtpSent when no OTP exists for phone', () async {
        final result = await WhatsAppOtpService.verifyOtp(
          phone: '966512345678',
          otp: '123456',
        );

        expect(result.isSuccess, isFalse);
        expect(result.error, isNotNull);
      });
    });
  });
}
