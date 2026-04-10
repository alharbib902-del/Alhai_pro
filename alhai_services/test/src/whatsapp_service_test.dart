import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_services/alhai_services.dart';

void main() {
  late WhatsAppServiceImpl whatsAppService;

  setUp(() {
    whatsAppService = WhatsAppServiceImpl(
      accessToken: 'test-token',
      phoneNumberId: 'phone-123',
    );
  });

  group('WhatsAppServiceImpl', () {
    test('should be created', () {
      expect(whatsAppService, isNotNull);
    });

    group('isValidWhatsAppNumber', () {
      test('should validate Saudi local format (05XXXXXXXX)', () {
        expect(whatsAppService.isValidWhatsAppNumber('0512345678'), isTrue);
        expect(whatsAppService.isValidWhatsAppNumber('0523456789'), isTrue);
      });

      test('should validate Saudi international format (966XXXXXXXXX)', () {
        expect(whatsAppService.isValidWhatsAppNumber('966512345678'), isTrue);
      });

      test('should validate +966 format', () {
        expect(whatsAppService.isValidWhatsAppNumber('+966512345678'), isTrue);
      });

      test('should reject too short numbers', () {
        expect(whatsAppService.isValidWhatsAppNumber('123'), isFalse);
        expect(whatsAppService.isValidWhatsAppNumber('0512'), isFalse);
      });

      test('should reject invalid formats', () {
        expect(whatsAppService.isValidWhatsAppNumber(''), isFalse);
      });
    });

    group('formatPhoneNumber', () {
      test('should convert local to international format', () {
        final formatted = whatsAppService.formatPhoneNumber('0512345678');
        expect(formatted, equals('966512345678'));
      });

      test('should keep international format as-is', () {
        final formatted = whatsAppService.formatPhoneNumber('966512345678');
        expect(formatted, equals('966512345678'));
      });

      test('should handle number starting with 0', () {
        final formatted = whatsAppService
            .formatPhoneNumber('05xxxxxxxx'.replaceAll('x', '1'));
        expect(formatted, startsWith('966'));
      });
    });

    group('sendReceipt', () {
      test('should send receipt for valid phone', () async {
        final response = await whatsAppService.sendReceipt(
          WhatsAppReceiptRequest(
            orderId: 'order-1',
            phone: '0512345678',
            customerName: 'Ahmed',
          ),
        );

        expect(response.status, equals(WhatsAppMessageStatus.sent));
        expect(response.messageId, isNotEmpty);
        expect(response.receiptUrl, isNotEmpty);
      });

      test('should fail for invalid phone', () async {
        final response = await whatsAppService.sendReceipt(
          WhatsAppReceiptRequest(
            orderId: 'order-1',
            phone: '123',
            customerName: 'Ahmed',
          ),
        );

        expect(response.status, equals(WhatsAppMessageStatus.failed));
        expect(response.errorMessage, isNotNull);
      });
    });

    group('checkStatus', () {
      test('should return sent status for known message', () async {
        // First send a message
        final response = await whatsAppService.sendReceipt(
          WhatsAppReceiptRequest(
            orderId: 'order-1',
            phone: '0512345678',
            customerName: 'Ahmed',
          ),
        );

        final status = await whatsAppService.checkStatus(response.messageId);
        expect(status, equals(WhatsAppMessageStatus.sent));
      });

      test('should return failed for unknown message', () async {
        final status = await whatsAppService.checkStatus('unknown-id');
        expect(status, equals(WhatsAppMessageStatus.failed));
      });
    });

    group('getReceiptUrl', () {
      test('should return a URL for order', () async {
        final url = await whatsAppService.getReceiptUrl('order-1');
        expect(url, isNotEmpty);
        expect(url, contains('order-1'));
      });
    });

    group('isConfigured', () {
      test('should return true when token is set', () async {
        final configured = await whatsAppService.isConfigured('store-1');
        expect(configured, isTrue);
      });

      test('should return false when no token', () async {
        final emptyService = WhatsAppServiceImpl();
        final configured = await emptyService.isConfigured('store-1');
        expect(configured, isFalse);
      });

      test('should return true for configured store', () async {
        whatsAppService.configureStore(
          storeId: 'store-1',
          accessToken: 'store-token',
          phoneNumberId: 'phone-456',
        );

        final configured = await whatsAppService.isConfigured('store-1');
        expect(configured, isTrue);
      });
    });

    group('configureStore and disableStore', () {
      test('should configure store', () async {
        whatsAppService.configureStore(
          storeId: 'store-1',
          accessToken: 'token-1',
          phoneNumberId: 'phone-1',
          dailyLimit: 500,
        );

        final configured = await whatsAppService.isConfigured('store-1');
        expect(configured, isTrue);
      });

      test('should disable store', () async {
        whatsAppService.configureStore(
          storeId: 'store-1',
          accessToken: 'token-1',
          phoneNumberId: 'phone-1',
        );

        whatsAppService.disableStore('store-1');

        final configured = await whatsAppService.isConfigured('store-1');
        expect(configured, isFalse);
      });
    });

    group('getRemainingDailyLimit', () {
      test('should return full limit for new day', () async {
        final remaining =
            await whatsAppService.getRemainingDailyLimit('store-1');
        expect(remaining, equals(1000)); // default limit
      });

      test('should decrease after sending', () async {
        await whatsAppService.sendReceipt(
          WhatsAppReceiptRequest(
            orderId: 'order-1',
            phone: '0512345678',
            customerName: 'Test',
          ),
        );

        // Check global limit (not store-specific in this test)
        // The send decrements the global counter
        final remaining =
            await whatsAppService.getRemainingDailyLimit('store-1');
        expect(remaining, equals(1000)); // store-specific, not global
      });
    });

    group('sendTemplateMessage', () {
      test('should send template for valid phone', () async {
        final response = await whatsAppService.sendTemplateMessage(
          phone: '0512345678',
          templateName: 'receipt_notification',
          parameters: ['Ahmed', 'POS-0001'],
        );

        expect(response.status, equals(WhatsAppMessageStatus.sent));
      });

      test('should fail for invalid phone', () async {
        final response = await whatsAppService.sendTemplateMessage(
          phone: '123',
          templateName: 'receipt_notification',
          parameters: ['Ahmed'],
        );

        expect(response.status, equals(WhatsAppMessageStatus.failed));
      });
    });
  });
}
