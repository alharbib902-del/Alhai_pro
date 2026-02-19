import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pos_app/data/local/app_database.dart';
import 'package:pos_app/data/local/daos/whatsapp_messages_dao.dart';
import 'package:pos_app/services/whatsapp/phone_validation_service.dart';
import 'package:pos_app/services/whatsapp_service.dart';

// ===========================================
// Mocks
// ===========================================

class MockWhatsAppMessagesDao extends Mock implements WhatsAppMessagesDao {}

class MockPhoneValidationService extends Mock
    implements PhoneValidationService {}

class FakeWhatsAppMessagesTableCompanion extends Fake
    implements WhatsAppMessagesTableCompanion {}

// ===========================================
// WhatsApp Service Tests
// ===========================================

void main() {
  late MockWhatsAppMessagesDao mockDao;
  late MockPhoneValidationService mockPhoneValidator;
  late WhatsAppService service;

  setUpAll(() {
    registerFallbackValue(FakeWhatsAppMessagesTableCompanion());
    registerFallbackValue(const Duration(minutes: 5));
  });

  setUp(() {
    mockDao = MockWhatsAppMessagesDao();
    mockPhoneValidator = MockPhoneValidationService();

    // enqueue always succeeds (positional parameter)
    when(() => mockDao.enqueue(any())).thenAnswer((_) async => 1);

    // no duplicate messages by default
    when(
      () => mockDao.findRecentDuplicate(
        phone: any(named: 'phone'),
        referenceType: any(named: 'referenceType'),
        referenceId: any(named: 'referenceId'),
      ),
    ).thenAnswer((_) async => null);

    service = WhatsAppService(
      messagesDao: mockDao,
      phoneValidator: mockPhoneValidator,
      storeId: 'test-store',
    );
  });

  group('WhatsAppService', () {
    group('sendMessage', () {
      test('sends a message and returns UUID', () async {
        final result = await service.sendMessage(
          phoneNumber: '0501234567',
          message: 'مرحباً',
        );
        expect(result, isA<String>());
        expect(result.length, greaterThan(0));
        verify(() => mockDao.enqueue(any())).called(1);
      });

      test('handles phone starting with 05', () async {
        final result = await service.sendMessage(
          phoneNumber: '0512345678',
          message: 'اختبار',
        );
        expect(result, isA<String>());
        verify(() => mockDao.enqueue(any())).called(1);
      });

      test('handles phone starting with 966', () async {
        final result = await service.sendMessage(
          phoneNumber: '966512345678',
          message: 'اختبار',
        );
        expect(result, isA<String>());
        verify(() => mockDao.enqueue(any())).called(1);
      });

      test('handles phone starting with +966', () async {
        final result = await service.sendMessage(
          phoneNumber: '+966512345678',
          message: 'اختبار',
        );
        expect(result, isA<String>());
        verify(() => mockDao.enqueue(any())).called(1);
      });
    });

    group('sendDebtReminder', () {
      test('sends debt reminder', () async {
        final result = await service.sendDebtReminder(
          phoneNumber: '0501234567',
          customerName: 'محمد أحمد',
          customerId: 'cust-001',
          amount: 500.50,
          storeName: 'متجر الحي',
        );
        expect(result, isA<String>());
        verify(() => mockDao.enqueue(any())).called(1);
      });

      test('handles large amount', () async {
        final result = await service.sendDebtReminder(
          phoneNumber: '0501234567',
          customerName: 'عميل مهم',
          customerId: 'cust-002',
          amount: 15000.75,
          storeName: 'سوبرماركت الأمل',
        );
        expect(result, isA<String>());
        verify(() => mockDao.enqueue(any())).called(1);
      });
    });

    group('sendReceipt', () {
      test('sends receipt', () async {
        final result = await service.sendReceipt(
          phoneNumber: '0501234567',
          customerName: 'خالد علي',
          receiptNumber: 'INV-2024-001',
          total: 250.00,
          storeName: 'متجر الحي',
        );
        expect(result, isA<String>());
        verify(() => mockDao.enqueue(any())).called(1);
      });
    });

    group('sendPromotion', () {
      test('sends promotion', () async {
        final result = await service.sendPromotion(
          phoneNumber: '0501234567',
          customerName: 'سارة',
          promotionTitle: 'خصم 20% على جميع المنتجات',
          promotionDetails: 'العرض ساري حتى نهاية الأسبوع',
          storeName: 'متجر الحي',
        );
        expect(result, isA<String>());
        verify(() => mockDao.enqueue(any())).called(1);
      });
    });

    group('sendOrderUpdate', () {
      test('sends confirmed order update', () async {
        final result = await service.sendOrderUpdate(
          phoneNumber: '0501234567',
          orderNumber: 'ORD-2024-001',
          status: 'confirmed',
          storeName: 'متجر الحي',
        );
        expect(result, isA<String>());
        verify(() => mockDao.enqueue(any())).called(1);
      });

      test('sends preparing order update', () async {
        final result = await service.sendOrderUpdate(
          phoneNumber: '0501234567',
          orderNumber: 'ORD-2024-002',
          status: 'preparing',
          storeName: 'متجر الحي',
        );
        expect(result, isA<String>());
        verify(() => mockDao.enqueue(any())).called(1);
      });

      test('sends ready order update', () async {
        final result = await service.sendOrderUpdate(
          phoneNumber: '0501234567',
          orderNumber: 'ORD-2024-003',
          status: 'ready',
          storeName: 'متجر الحي',
        );
        expect(result, isA<String>());
        verify(() => mockDao.enqueue(any())).called(1);
      });

      test('sends delivering order update', () async {
        final result = await service.sendOrderUpdate(
          phoneNumber: '0501234567',
          orderNumber: 'ORD-2024-004',
          status: 'delivering',
          storeName: 'متجر الحي',
        );
        expect(result, isA<String>());
        verify(() => mockDao.enqueue(any())).called(1);
      });

      test('sends delivered order update', () async {
        final result = await service.sendOrderUpdate(
          phoneNumber: '0501234567',
          orderNumber: 'ORD-2024-005',
          status: 'delivered',
          storeName: 'متجر الحي',
        );
        expect(result, isA<String>());
        verify(() => mockDao.enqueue(any())).called(1);
      });

      test('handles unknown status', () async {
        final result = await service.sendOrderUpdate(
          phoneNumber: '0501234567',
          orderNumber: 'ORD-2024-006',
          status: 'unknown_status',
          storeName: 'متجر الحي',
        );
        expect(result, isA<String>());
        verify(() => mockDao.enqueue(any())).called(1);
      });
    });

    group('deduplication', () {
      test('returns existing message ID for duplicate', () async {
        // First call - send with reference
        final firstResult = await service.sendReceipt(
          phoneNumber: '0501234567',
          customerName: 'خالد',
          receiptNumber: 'INV-001',
          total: 100.0,
          storeName: 'متجر',
        );

        // Setup mock to return a fake duplicate for the same reference
        when(
          () => mockDao.findRecentDuplicate(
            phone: any(named: 'phone'),
            referenceType: 'sale',
            referenceId: 'INV-001',
          ),
        ).thenAnswer((_) async => _fakeMessageData(firstResult));

        // Second call - should detect duplicate
        final secondResult = await service.sendReceipt(
          phoneNumber: '0501234567',
          customerName: 'خالد',
          receiptNumber: 'INV-001',
          total: 100.0,
          storeName: 'متجر',
        );

        expect(secondResult, equals(firstResult));
        // enqueue should only be called once (the first time)
        verify(() => mockDao.enqueue(any())).called(1);
      });
    });
  });

  group('WhatsAppTemplates', () {
    test('يحتوي على جميع القوالب', () {
      expect(WhatsAppTemplates.debtReminder, 'debt_reminder');
      expect(WhatsAppTemplates.receipt, 'receipt');
      expect(WhatsAppTemplates.promotion, 'promotion');
      expect(WhatsAppTemplates.orderUpdate, 'order_update');
      expect(WhatsAppTemplates.welcome, 'welcome');
    });

    test('templates map يحتوي على الأوصاف', () {
      final templates = WhatsAppTemplates.templates;
      expect(templates, isNotEmpty);
      expect(templates.length, 5);
      expect(templates[WhatsAppTemplates.debtReminder], isNotNull);
      expect(templates[WhatsAppTemplates.receipt], isNotNull);
      expect(templates[WhatsAppTemplates.promotion], isNotNull);
      expect(templates[WhatsAppTemplates.orderUpdate], isNotNull);
      expect(templates[WhatsAppTemplates.welcome], isNotNull);
    });

    test('أوصاف القوالب بالعربية', () {
      final templates = WhatsAppTemplates.templates;
      expect(templates[WhatsAppTemplates.debtReminder], 'تذكير بالدين المستحق');
      expect(templates[WhatsAppTemplates.receipt], 'إيصال الفاتورة');
      expect(templates[WhatsAppTemplates.promotion], 'عرض ترويجي');
      expect(templates[WhatsAppTemplates.orderUpdate], 'تحديث الطلب');
      expect(templates[WhatsAppTemplates.welcome], 'رسالة ترحيب');
    });
  });
}

/// Helper to create a fake WhatsAppMessagesTableData for deduplication tests
WhatsAppMessagesTableData _fakeMessageData(String id) {
  return WhatsAppMessagesTableData(
    id: id,
    storeId: 'test-store',
    phone: '966501234567',
    messageType: 'text',
    textContent: 'test',
    status: 'pending',
    retryCount: 0,
    maxRetries: 3,
    priority: 3,
    createdAt: DateTime.now(),
  );
}
