import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pos_app/data/local/app_database.dart';
import 'package:pos_app/data/local/daos/whatsapp_messages_dao.dart';
import 'package:pos_app/data/local/daos/whatsapp_templates_dao.dart';
import 'package:pos_app/services/whatsapp/bulk_messaging_service.dart';
import 'package:pos_app/services/whatsapp/models/wasender_models.dart';
import 'package:pos_app/services/whatsapp/phone_validation_service.dart';

// ===========================================
// Mocks
// ===========================================

class MockWhatsAppMessagesDao extends Mock implements WhatsAppMessagesDao {}

class MockPhoneValidationService extends Mock
    implements PhoneValidationService {}

class MockWhatsAppTemplatesDao extends Mock implements WhatsAppTemplatesDao {}

class FakeWhatsAppMessagesTableCompanion extends Fake
    implements WhatsAppMessagesTableCompanion {}

// ===========================================
// Tests
// ===========================================

void main() {
  late MockWhatsAppMessagesDao mockDao;
  late MockPhoneValidationService mockPhoneValidator;
  late MockWhatsAppTemplatesDao mockTemplatesDao;
  late BulkMessagingService service;

  setUpAll(() {
    registerFallbackValue(FakeWhatsAppMessagesTableCompanion());
  });

  setUp(() {
    mockDao = MockWhatsAppMessagesDao();
    mockPhoneValidator = MockPhoneValidationService();
    mockTemplatesDao = MockWhatsAppTemplatesDao();

    service = BulkMessagingService(
      mockDao,
      mockPhoneValidator,
      mockTemplatesDao,
    );

    // Default: enqueue succeeds
    when(() => mockDao.enqueue(any())).thenAnswer((_) async => 1);
  });

  // ═══════════════════════════════════════════════════════
  // createPromotionBatch
  // ═══════════════════════════════════════════════════════

  group('createPromotionBatch', () {
    test('creates batch with valid recipients', () async {
      final result = await service.createPromotionBatch(
        storeId: 'store-1',
        recipients: const [
          BulkRecipient(phone: '0501234567', name: 'أحمد'),
          BulkRecipient(phone: '0509876543', name: 'سارة'),
        ],
        templateContent: 'عرض خاص لك {{customer_name}}!',
      );

      expect(result.batchId, isNotEmpty);
      expect(result.totalMessages, 2);
      expect(result.validRecipients, 2);
      expect(result.invalidRecipients, 0);
      verify(() => mockDao.enqueue(any())).called(2);
    });

    test('skips invalid phone numbers', () async {
      final result = await service.createPromotionBatch(
        storeId: 'store-1',
        recipients: const [
          BulkRecipient(phone: '0501234567', name: 'صالح'),
          BulkRecipient(phone: '123', name: 'رقم خاطئ'), // invalid
        ],
        templateContent: 'عرض!',
      );

      expect(result.validRecipients, 1);
      expect(result.invalidRecipients, 1);
      verify(() => mockDao.enqueue(any())).called(1);
    });

    test('applies global and recipient template variables', () async {
      WhatsAppMessagesTableCompanion? captured;
      when(() => mockDao.enqueue(any())).thenAnswer((inv) async {
        captured = inv.positionalArguments[0] as WhatsAppMessagesTableCompanion;
        return 1;
      });

      await service.createPromotionBatch(
        storeId: 'store-1',
        recipients: const [
          BulkRecipient(
            phone: '0501234567',
            name: 'محمد',
            templateVars: {'discount': '20%'},
          ),
        ],
        templateContent: 'مرحباً {{customer_name}}، خصم {{discount}}!',
        globalTemplateVars: {'store': 'متجرنا'},
      );

      expect(captured, isNotNull);
      // The rendered text should have variables replaced
      final text = captured!.textContent.value;
      expect(text, contains('محمد'));
      expect(text, contains('20%'));
    });

    test('handles enqueue failure for individual recipient', () async {
      var callCount = 0;
      when(() => mockDao.enqueue(any())).thenAnswer((_) async {
        callCount++;
        if (callCount == 2) throw Exception('DB error');
        return 1;
      });

      final result = await service.createPromotionBatch(
        storeId: 'store-1',
        recipients: const [
          BulkRecipient(phone: '0501234567', name: 'أحمد'),
          BulkRecipient(phone: '0509876543', name: 'سارة'),
          BulkRecipient(phone: '0507654321', name: 'خالد'),
        ],
        templateContent: 'عرض!',
      );

      expect(result.validRecipients, 2);
      expect(result.invalidRecipients, 1); // the failed enqueue
    });

    test('sets image type when imageUrl provided', () async {
      WhatsAppMessagesTableCompanion? captured;
      when(() => mockDao.enqueue(any())).thenAnswer((inv) async {
        captured = inv.positionalArguments[0] as WhatsAppMessagesTableCompanion;
        return 1;
      });

      await service.createPromotionBatch(
        storeId: 'store-1',
        recipients: const [
          BulkRecipient(phone: '0501234567', name: 'أحمد'),
        ],
        templateContent: 'عرض!',
        imageUrl: 'https://example.com/promo.jpg',
      );

      expect(captured!.messageType.value, 'image');
      expect(captured!.mediaUrl.value, 'https://example.com/promo.jpg');
    });

    test('returns empty batch for no recipients', () async {
      final result = await service.createPromotionBatch(
        storeId: 'store-1',
        recipients: const [],
        templateContent: 'عرض!',
      );

      expect(result.totalMessages, 0);
      expect(result.batchId, isNotEmpty);
      verifyNever(() => mockDao.enqueue(any()));
    });
  });

  // ═══════════════════════════════════════════════════════
  // createDebtReminderBatch
  // ═══════════════════════════════════════════════════════

  group('createDebtReminderBatch', () {
    test('creates debt reminder batch with custom template', () async {
      final result = await service.createDebtReminderBatch(
        storeId: 'store-1',
        recipients: const [
          DebtRecipient(
            phone: '0501234567',
            customerName: 'محمد',
            customerId: 'cust-1',
            amount: 500.50,
          ),
        ],
        templateContent:
            'مرحباً {{customer_name}}، مبلغ مستحق: {{amount}} ر.س',
      );

      expect(result.validRecipients, 1);
      expect(result.invalidRecipients, 0);
      verify(() => mockDao.enqueue(any())).called(1);
    });

    test('uses default template when none provided and DB has no template',
        () async {
      // Mock: no custom default template in DB
      when(() => mockTemplatesDao.getDefaultTemplate(any(), any()))
          .thenAnswer((_) async => null);

      WhatsAppMessagesTableCompanion? captured;
      when(() => mockDao.enqueue(any())).thenAnswer((inv) async {
        captured = inv.positionalArguments[0] as WhatsAppMessagesTableCompanion;
        return 1;
      });

      await service.createDebtReminderBatch(
        storeId: 'store-1',
        recipients: const [
          DebtRecipient(
            phone: '0501234567',
            customerName: 'أحمد',
            customerId: 'cust-1',
            amount: 1000.00,
          ),
        ],
      );

      expect(captured, isNotNull);
      final text = captured!.textContent.value;
      // The hardcoded default template from WhatsAppTemplateService.defaultTemplates
      // should contain the customer name and amount after rendering
      expect(text, contains('أحمد'));
      expect(text, contains('1000.00'));
    });

    test('skips invalid phone numbers', () async {
      final result = await service.createDebtReminderBatch(
        storeId: 'store-1',
        recipients: const [
          DebtRecipient(
            phone: '12',
            customerName: 'رقم خاطئ',
            customerId: 'cust-bad',
            amount: 100,
          ),
        ],
        templateContent: 'تذكير',
      );

      expect(result.validRecipients, 0);
      expect(result.invalidRecipients, 1);
      verifyNever(() => mockDao.enqueue(any()));
    });

    test('formats amount to 2 decimal places', () async {
      WhatsAppMessagesTableCompanion? captured;
      when(() => mockDao.enqueue(any())).thenAnswer((inv) async {
        captured = inv.positionalArguments[0] as WhatsAppMessagesTableCompanion;
        return 1;
      });

      await service.createDebtReminderBatch(
        storeId: 'store-1',
        recipients: const [
          DebtRecipient(
            phone: '0501234567',
            customerName: 'سعد',
            customerId: 'cust-1',
            amount: 1234.5,
          ),
        ],
        templateContent: 'المبلغ: {{amount}} ر.س',
      );

      expect(captured!.textContent.value, contains('1234.50'));
    });
  });

  // ═══════════════════════════════════════════════════════
  // getBatchProgress
  // ═══════════════════════════════════════════════════════

  group('getBatchProgress', () {
    test('returns zero progress for empty batch', () async {
      when(() => mockDao.getByBatchId(any())).thenAnswer((_) async => []);

      final progress = await service.getBatchProgress('batch-empty');

      expect(progress.total, 0);
      expect(progress.sent, 0);
      expect(progress.delivered, 0);
      expect(progress.failed, 0);
      expect(progress.pending, 0);
    });

    test('calculates progress from message statuses', () async {
      when(() => mockDao.getByBatchId('batch-1')).thenAnswer((_) async => [
            _fakeMessage(id: '1', status: 'sent'),
            _fakeMessage(id: '2', status: 'delivered'),
            _fakeMessage(id: '3', status: 'read'),
            _fakeMessage(id: '4', status: 'failed'),
            _fakeMessage(id: '5', status: 'pending'),
            _fakeMessage(id: '6', status: 'sending'),
          ]);

      final progress = await service.getBatchProgress('batch-1');

      expect(progress.total, 6);
      expect(progress.sent, 1);
      expect(progress.delivered, 2); // delivered + read
      expect(progress.failed, 1);
      expect(progress.pending, 2); // pending + sending
    });
  });

  // ═══════════════════════════════════════════════════════
  // cancelBatch
  // ═══════════════════════════════════════════════════════

  group('cancelBatch', () {
    test('cancels pending messages in batch', () async {
      when(() => mockDao.cancelBatch('batch-1')).thenAnswer((_) async => 5);

      final cancelled = await service.cancelBatch('batch-1');

      expect(cancelled, 5);
      verify(() => mockDao.cancelBatch('batch-1')).called(1);
    });

    test('rethrows exception from DAO', () async {
      when(() => mockDao.cancelBatch(any()))
          .thenThrow(Exception('DB error'));

      expect(
        () => service.cancelBatch('batch-err'),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ═══════════════════════════════════════════════════════
  // validateRecipients
  // ═══════════════════════════════════════════════════════

  group('validateRecipients', () {
    test('validates valid phones', () async {
      when(() => mockPhoneValidator.isOnWhatsApp(any()))
          .thenAnswer((_) async => true);

      final results = await service.validateRecipients([
        '0501234567',
        '0509876543',
      ]);

      expect(results.length, 2);
      expect(results[0].isValid, isTrue);
      expect(results[0].isOnWhatsApp, isTrue);
      expect(results[1].isValid, isTrue);
    });

    test('marks invalid phone as not valid', () async {
      final results = await service.validateRecipients(['12']);

      expect(results.length, 1);
      expect(results[0].isValid, isFalse);
      expect(results[0].isOnWhatsApp, isFalse);
      expect(results[0].error, isNotNull);
    });

    test('assumes on WhatsApp when API fails', () async {
      when(() => mockPhoneValidator.isOnWhatsApp(any()))
          .thenThrow(Exception('API error'));

      final results = await service.validateRecipients(['0501234567']);

      expect(results[0].isValid, isTrue);
      expect(results[0].isOnWhatsApp, isTrue); // assumes true on error
    });

    test('reports phone not on WhatsApp', () async {
      when(() => mockPhoneValidator.isOnWhatsApp(any()))
          .thenAnswer((_) async => false);

      final results = await service.validateRecipients(['0501234567']);

      expect(results[0].isValid, isTrue);
      expect(results[0].isOnWhatsApp, isFalse);
    });
  });
}

// ===========================================
// Helper
// ===========================================

WhatsAppMessagesTableData _fakeMessage({
  required String id,
  String status = 'pending',
}) {
  return WhatsAppMessagesTableData(
    id: id,
    storeId: 'test-store',
    phone: '966501234567',
    messageType: 'text',
    textContent: 'test',
    status: status,
    retryCount: 0,
    maxRetries: 3,
    priority: 2,
    createdAt: DateTime.now(),
  );
}
