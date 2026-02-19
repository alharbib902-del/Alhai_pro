import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/services/whatsapp_service.dart';

// ===========================================
// WhatsApp Service Tests
// ===========================================

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Mock url_launcher MethodChannel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/url_launcher'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'canLaunch') return true;
        if (methodCall.method == 'launch') return true;
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io'),
      null,
    );
  });
  group('WhatsAppService', () {
    group('sendMessage', () {
      test('يُرسل رسالة بنجاح', () async {
        final result = await WhatsAppService.sendMessage(
          phoneNumber: '0501234567',
          message: 'مرحباً',
        );
        expect(result, isTrue);
      });

      test('يتعامل مع رقم يبدأ بـ 05', () async {
        final result = await WhatsAppService.sendMessage(
          phoneNumber: '0512345678',
          message: 'اختبار',
        );
        expect(result, isTrue);
      });

      test('يتعامل مع رقم يبدأ بـ 966', () async {
        final result = await WhatsAppService.sendMessage(
          phoneNumber: '966512345678',
          message: 'اختبار',
        );
        expect(result, isTrue);
      });

      test('يتعامل مع رقم يبدأ بـ +966', () async {
        final result = await WhatsAppService.sendMessage(
          phoneNumber: '+966512345678',
          message: 'اختبار',
        );
        expect(result, isTrue);
      });
    });

    group('sendDebtReminder', () {
      test('يُرسل تذكير الدين', () async {
        final result = await WhatsAppService.sendDebtReminder(
          phoneNumber: '0501234567',
          customerName: 'محمد أحمد',
          amount: 500.50,
          storeName: 'متجر الحي',
        );
        expect(result, isTrue);
      });

      test('يتعامل مع مبلغ كبير', () async {
        final result = await WhatsAppService.sendDebtReminder(
          phoneNumber: '0501234567',
          customerName: 'عميل مهم',
          amount: 15000.75,
          storeName: 'سوبرماركت الأمل',
        );
        expect(result, isTrue);
      });
    });

    group('sendReceipt', () {
      test('يُرسل إيصال الفاتورة', () async {
        final result = await WhatsAppService.sendReceipt(
          phoneNumber: '0501234567',
          customerName: 'خالد علي',
          receiptNumber: 'INV-2024-001',
          total: 250.00,
          storeName: 'متجر الحي',
        );
        expect(result, isTrue);
      });
    });

    group('sendPromotion', () {
      test('يُرسل عرض ترويجي', () async {
        final result = await WhatsAppService.sendPromotion(
          phoneNumber: '0501234567',
          customerName: 'سارة',
          promotionTitle: 'خصم 20% على جميع المنتجات',
          promotionDetails: 'العرض ساري حتى نهاية الأسبوع',
          storeName: 'متجر الحي',
        );
        expect(result, isTrue);
      });
    });

    group('sendOrderUpdate', () {
      test('يُرسل تحديث طلب مؤكد', () async {
        final result = await WhatsAppService.sendOrderUpdate(
          phoneNumber: '0501234567',
          orderNumber: 'ORD-2024-001',
          status: 'confirmed',
          storeName: 'متجر الحي',
        );
        expect(result, isTrue);
      });

      test('يُرسل تحديث طلب قيد التحضير', () async {
        final result = await WhatsAppService.sendOrderUpdate(
          phoneNumber: '0501234567',
          orderNumber: 'ORD-2024-002',
          status: 'preparing',
          storeName: 'متجر الحي',
        );
        expect(result, isTrue);
      });

      test('يُرسل تحديث طلب جاهز', () async {
        final result = await WhatsAppService.sendOrderUpdate(
          phoneNumber: '0501234567',
          orderNumber: 'ORD-2024-003',
          status: 'ready',
          storeName: 'متجر الحي',
        );
        expect(result, isTrue);
      });

      test('يُرسل تحديث طلب قيد التوصيل', () async {
        final result = await WhatsAppService.sendOrderUpdate(
          phoneNumber: '0501234567',
          orderNumber: 'ORD-2024-004',
          status: 'delivering',
          storeName: 'متجر الحي',
        );
        expect(result, isTrue);
      });

      test('يُرسل تحديث طلب تم توصيله', () async {
        final result = await WhatsAppService.sendOrderUpdate(
          phoneNumber: '0501234567',
          orderNumber: 'ORD-2024-005',
          status: 'delivered',
          storeName: 'متجر الحي',
        );
        expect(result, isTrue);
      });

      test('يتعامل مع حالة غير معروفة', () async {
        final result = await WhatsAppService.sendOrderUpdate(
          phoneNumber: '0501234567',
          orderNumber: 'ORD-2024-006',
          status: 'unknown_status',
          storeName: 'متجر الحي',
        );
        expect(result, isTrue);
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
