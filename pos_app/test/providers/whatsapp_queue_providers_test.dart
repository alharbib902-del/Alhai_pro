/// اختبارات مزودات طابور واتساب - Database-backed Providers
///
/// اختبارات للـ providers المعرّفة في whatsapp_queue_providers.dart.
/// الأجزاء التي تعتمد على قاعدة البيانات (DAOs) مغطاة في اختبارات
/// الخدمات الفردية (whatsapp_service_test.dart, etc.).
///
/// هذا الملف يختبر:
/// - receiptPhoneProvider: القيمة الأولية والتعيين والمسح
/// - WhatsAppMessageFilter: التصفية بالحالة ونوع المرجع
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/providers/whatsapp_queue_providers.dart';
import 'package:pos_app/services/whatsapp/models/wasender_models.dart';

void main() {
  // ==========================================================================
  // اختبارات receiptPhoneProvider
  // ==========================================================================

  group('receiptPhoneProvider - مزود رقم هاتف الإيصال', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('يبدأ بقيمة null', () {
      expect(container.read(receiptPhoneProvider), isNull);
    });

    test('يمكن تعيين رقم هاتف', () {
      container.read(receiptPhoneProvider.notifier).state = '0512345678';
      expect(container.read(receiptPhoneProvider), equals('0512345678'));
    });

    test('يمكن مسح رقم الهاتف', () {
      // تعيين أولاً
      container.read(receiptPhoneProvider.notifier).state = '0512345678';
      expect(container.read(receiptPhoneProvider), isNotNull);

      // مسح
      container.read(receiptPhoneProvider.notifier).state = null;
      expect(container.read(receiptPhoneProvider), isNull);
    });

    test('يمكن تحديث رقم الهاتف', () {
      container.read(receiptPhoneProvider.notifier).state = '0512345678';
      container.read(receiptPhoneProvider.notifier).state = '0598765432';
      expect(container.read(receiptPhoneProvider), equals('0598765432'));
    });
  });

  // ==========================================================================
  // اختبارات WhatsAppMessageFilter
  // ==========================================================================

  group('WhatsAppMessageFilter - فلتر الرسائل', () {
    test('ينشئ بدون فلاتر', () {
      const filter = WhatsAppMessageFilter();
      expect(filter.status, isNull);
      expect(filter.referenceType, isNull);
    });

    test('ينشئ مع فلتر الحالة فقط', () {
      const filter = WhatsAppMessageFilter(status: 'pending');
      expect(filter.status, equals('pending'));
      expect(filter.referenceType, isNull);
    });

    test('ينشئ مع فلتر نوع المرجع فقط', () {
      const filter = WhatsAppMessageFilter(referenceType: 'sale');
      expect(filter.status, isNull);
      expect(filter.referenceType, equals('sale'));
    });

    test('ينشئ مع كلا الفلترين', () {
      const filter = WhatsAppMessageFilter(
        status: 'sent',
        referenceType: 'debt_reminder',
      );
      expect(filter.status, equals('sent'));
      expect(filter.referenceType, equals('debt_reminder'));
    });
  });
}
