import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_services/alhai_services.dart';

void main() {
  group('SmsService', () {
    test('should be created', () {
      final service = SmsService();
      expect(service, isNotNull);
    });

    group('isConfigured', () {
      test('should return false when no API key', () {
        final service = SmsService();
        expect(service.isConfigured, isFalse);
      });

      test('should return false for empty API key', () {
        final service = SmsService(apiKey: '');
        expect(service.isConfigured, isFalse);
      });

      test('should return true when API key is set', () {
        final service = SmsService(apiKey: 'test-key');
        expect(service.isConfigured, isTrue);
      });
    });

    group('sendSms', () {
      test('should fail when not configured', () async {
        final service = SmsService();

        final result = await service.sendSms(
          phoneNumber: '0512345678',
          message: 'Test message',
        );

        expect(result.success, isFalse);
        expect(result.error, contains('غير مكونة'));
      });

      test('should attempt sending when configured', () async {
        final service = SmsService(apiKey: 'test-key');

        final result = await service.sendSms(
          phoneNumber: '0512345678',
          message: 'Test',
        );

        // Will fail due to UnimplementedError (no http package),
        // but should not be "not configured" error
        expect(result.success, isFalse);
        expect(result.error, isNot(contains('غير مكونة')));
      });
    });

    group('sendOtp', () {
      test('should fail when not configured', () async {
        final service = SmsService();

        final result = await service.sendOtp(
          phoneNumber: '0512345678',
          otp: '1234',
        );

        expect(result.success, isFalse);
      });
    });

    group('sendDebtReminder', () {
      test('should fail when not configured', () async {
        final service = SmsService();

        final result = await service.sendDebtReminder(
          phoneNumber: '0512345678',
          customerName: 'Ahmed',
          amount: 500.0,
        );

        expect(result.success, isFalse);
      });
    });

    group('sendOrderConfirmation', () {
      test('should fail when not configured', () async {
        final service = SmsService();

        final result = await service.sendOrderConfirmation(
          phoneNumber: '0512345678',
          orderNumber: 'POS-0001',
          total: 100.0,
        );

        expect(result.success, isFalse);
      });
    });

    group('sendBulkSms', () {
      test('should fail for all numbers when not configured', () async {
        final service = SmsService();

        final result = await service.sendBulkSms(
          phoneNumbers: ['0512345678', '0523456789'],
          message: 'Test',
        );

        expect(result.success, isFalse);
        expect(result.totalSent, equals(0));
        expect(result.totalFailed, equals(2));
      });
    });

    group('checkBalance', () {
      test('should fail when not configured', () async {
        final service = SmsService();
        final result = await service.checkBalance();

        expect(result.success, isFalse);
        expect(result.error, contains('غير مكونة'));
      });

      test('should attempt check when configured', () async {
        final service = SmsService(apiKey: 'test-key');
        final result = await service.checkBalance();

        // Will fail due to UnimplementedError, but not "not configured"
        expect(result.success, isFalse);
        expect(result.error, isNot(contains('غير مكونة')));
      });
    });

    group('SmsProvider', () {
      test('should support all providers', () {
        expect(SmsProvider.values, contains(SmsProvider.unifonic));
        expect(SmsProvider.values, contains(SmsProvider.twilio));
        expect(SmsProvider.values, contains(SmsProvider.vonage));
      });
    });

    group('provider-specific configuration', () {
      test('should create Twilio-configured service', () {
        final service = SmsService(
          apiKey: 'account-sid',
          provider: SmsProvider.twilio,
          twilioAccountSid: 'account-sid',
          twilioAuthToken: 'auth-token',
        );
        expect(service.isConfigured, isTrue);
      });

      test('should create Vonage-configured service', () {
        final service = SmsService(
          apiKey: 'api-key',
          provider: SmsProvider.vonage,
          vonageApiSecret: 'api-secret',
        );
        expect(service.isConfigured, isTrue);
      });
    });

    group('SmsResult', () {
      test('should hold success data', () {
        const result = SmsResult(
          success: true,
          messageId: 'msg-123',
        );
        expect(result.success, isTrue);
        expect(result.messageId, equals('msg-123'));
        expect(result.error, isNull);
      });

      test('should hold error data', () {
        const result = SmsResult(
          success: false,
          error: 'Failed to send',
        );
        expect(result.success, isFalse);
        expect(result.error, equals('Failed to send'));
      });
    });
  });
}
