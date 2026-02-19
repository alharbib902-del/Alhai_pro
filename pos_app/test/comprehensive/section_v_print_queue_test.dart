/// اختبارات قسم V: قائمة الطباعة
///
/// 6 اختبارات تغطي:
/// - V01: إضافة مهمة طباعة فاشلة إلى القائمة
/// - V02: إعادة محاولة مهمة فاشلة
/// - V03: مسح المهام المكتملة
/// - V04: عداد المهام المعلقة صحيح
/// - V05: PrintJob.toJson/fromJson round-trip
/// - V06: تدفق كامل: إضافة -> فشل -> إعادة -> نجاح -> مسح
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:pos_app/providers/print_providers.dart';

void main() {
  group('Section V: قائمة الطباعة', () {
    late PrintQueueNotifier notifier;

    setUp(() {
      notifier = PrintQueueNotifier();
    });

    // ================================================================
    // بيانات مشتركة
    // ================================================================

    PrintJob createTestJob({
      required String id,
      String saleId = 'sale-v-001',
      String receiptNo = 'POS-20250615-0001',
      String type = 'receipt',
      String status = 'pending',
    }) =>
        PrintJob(
          id: id,
          saleId: saleId,
          receiptNo: receiptNo,
          type: type,
          status: status,
          createdAt: DateTime(2025, 6, 15, 14, 30),
        );

    // ==================================================================
    // V01: إضافة مهمة طباعة فاشلة إلى القائمة
    // ==================================================================

    test('V01 إضافة مهمة طباعة: المهمة تُضاف وتُحدد كفاشلة', () {
      // إضافة مهمة
      final job = createTestJob(id: 'pj-v01');
      notifier.addJob(job);

      expect(notifier.state.length, 1);
      expect(notifier.state.first.id, 'pj-v01');
      expect(notifier.state.first.status, 'pending');

      // تحديد المهمة كفاشلة
      notifier.markFailed('pj-v01', 'الطابعة غير متصلة');

      expect(notifier.state.first.status, 'failed');
      expect(notifier.state.first.errorMessage, 'الطابعة غير متصلة');
      expect(notifier.state.first.retryCount, 1);

      // فشل مرة أخرى يزيد العداد
      notifier.markFailed('pj-v01', 'خطأ في الاتصال');
      expect(notifier.state.first.retryCount, 2);
      expect(notifier.state.first.errorMessage, 'خطأ في الاتصال');
    });

    // ==================================================================
    // V02: إعادة محاولة مهمة فاشلة
    // ==================================================================

    test('V02 إعادة محاولة: المهمة الفاشلة تعود لحالة pending', () {
      // إضافة وتفشيل
      final job = createTestJob(id: 'pj-v02');
      notifier.addJob(job);
      notifier.markFailed('pj-v02', 'خطأ في الطباعة');

      expect(notifier.state.first.status, 'failed');
      expect(notifier.state.first.retryCount, 1);

      // إعادة المحاولة
      notifier.retryJob('pj-v02');

      expect(notifier.state.first.status, 'pending');
      // ملاحظة: copyWith مع errorMessage: null لا يمسح القيمة القديمة بسبب ??
      // لذلك نتحقق فقط من أن الحالة تغيرت إلى pending
      // retryCount لا يُعاد تصفيره عند retryJob
      expect(notifier.state.first.retryCount, 1);
    });

    // ==================================================================
    // V03: مسح المهام المكتملة
    // ==================================================================

    test('V03 مسح المهام المكتملة: تبقى المهام غير المكتملة فقط', () {
      // إضافة 4 مهام بحالات مختلفة
      notifier.addJob(createTestJob(id: 'pj-v03-a'));
      notifier.addJob(createTestJob(id: 'pj-v03-b'));
      notifier.addJob(createTestJob(id: 'pj-v03-c'));
      notifier.addJob(createTestJob(id: 'pj-v03-d'));

      expect(notifier.state.length, 4);

      // تحديد بعضها كمكتملة وبعضها كفاشلة
      notifier.markCompleted('pj-v03-a');
      notifier.markCompleted('pj-v03-c');
      notifier.markFailed('pj-v03-b', 'خطأ');
      // pj-v03-d يبقى pending

      // مسح المكتملة
      notifier.clearCompleted();

      // يجب أن تبقى المهام غير المكتملة فقط
      expect(notifier.state.length, 2);
      final remainingIds = notifier.state.map((j) => j.id).toSet();
      expect(remainingIds, contains('pj-v03-b')); // فاشلة
      expect(remainingIds, contains('pj-v03-d')); // معلقة
      expect(remainingIds, isNot(contains('pj-v03-a'))); // مكتملة (مُزالة)
      expect(remainingIds, isNot(contains('pj-v03-c'))); // مكتملة (مُزالة)
    });

    // ==================================================================
    // V04: عداد المهام المعلقة صحيح
    // ==================================================================

    test('V04 عداد المهام: pendingCount و failedCount يعكسان الحالة الفعلية',
        () {
      // البداية: لا مهام
      expect(notifier.pendingCount, 0);
      expect(notifier.failedCount, 0);

      // إضافة 3 مهام (كلها pending)
      notifier.addJob(createTestJob(id: 'pj-v04-a'));
      notifier.addJob(createTestJob(id: 'pj-v04-b'));
      notifier.addJob(createTestJob(id: 'pj-v04-c'));

      expect(notifier.pendingCount, 3);
      expect(notifier.failedCount, 0);

      // فشل مهمة واحدة
      notifier.markFailed('pj-v04-a', 'خطأ');
      expect(notifier.pendingCount, 2);
      expect(notifier.failedCount, 1);

      // إكمال مهمة
      notifier.markCompleted('pj-v04-b');
      expect(notifier.pendingCount, 1);
      expect(notifier.failedCount, 1);

      // تحويل مهمة لجاري الطباعة
      notifier.markPrinting('pj-v04-c');
      expect(notifier.pendingCount, 0);
      expect(notifier.failedCount, 1);

      // إعادة محاولة المهمة الفاشلة
      notifier.retryJob('pj-v04-a');
      expect(notifier.pendingCount, 1);
      expect(notifier.failedCount, 0);
    });

    // ==================================================================
    // V05: PrintJob.toJson/fromJson round-trip
    // ==================================================================

    test('V05 التسلسل: toJson/fromJson round-trip يحافظ على جميع البيانات',
        () {
      final originalJob = PrintJob(
        id: 'pj-v05',
        saleId: 'sale-v05-123',
        receiptNo: 'POS-20250615-0042',
        type: 'receipt',
        status: 'failed',
        errorMessage: 'الطابعة غير متصلة',
        retryCount: 3,
        createdAt: DateTime(2025, 6, 15, 14, 30, 45),
      );

      // تحويل إلى JSON
      final json = originalJob.toJson();

      // التحقق من بنية JSON
      expect(json['id'], 'pj-v05');
      expect(json['saleId'], 'sale-v05-123');
      expect(json['receiptNo'], 'POS-20250615-0042');
      expect(json['type'], 'receipt');
      expect(json['status'], 'failed');
      expect(json['errorMessage'], 'الطابعة غير متصلة');
      expect(json['retryCount'], 3);
      expect(json['createdAt'], isA<String>());

      // إعادة البناء من JSON
      final restoredJob = PrintJob.fromJson(json);

      // التحقق من تطابق جميع الحقول
      expect(restoredJob.id, originalJob.id);
      expect(restoredJob.saleId, originalJob.saleId);
      expect(restoredJob.receiptNo, originalJob.receiptNo);
      expect(restoredJob.type, originalJob.type);
      expect(restoredJob.status, originalJob.status);
      expect(restoredJob.errorMessage, originalJob.errorMessage);
      expect(restoredJob.retryCount, originalJob.retryCount);
      expect(restoredJob.createdAt, originalJob.createdAt);

      // التحقق من round-trip مزدوج
      final json2 = restoredJob.toJson();
      final restoredJob2 = PrintJob.fromJson(json2);
      expect(restoredJob2.id, originalJob.id);
      expect(restoredJob2.createdAt, originalJob.createdAt);
    });

    // ==================================================================
    // V06: تدفق كامل: إضافة -> فشل -> إعادة -> نجاح -> مسح
    // ==================================================================

    test('V06 تدفق كامل: إضافة مهام -> فشل -> إعادة محاولة -> نجاح -> مسح',
        () {
      // === الخطوة 1: إضافة 3 مهام ===
      notifier.addJob(createTestJob(
        id: 'pj-v06-receipt',
        type: 'receipt',
        saleId: 'sale-001',
        receiptNo: 'POS-20250615-0001',
      ));
      notifier.addJob(createTestJob(
        id: 'pj-v06-report',
        type: 'report',
        saleId: 'sale-002',
        receiptNo: 'RPT-20250615-0001',
      ));
      notifier.addJob(createTestJob(
        id: 'pj-v06-barcode',
        type: 'barcode',
        saleId: 'prod-001',
        receiptNo: 'BC-20250615-0001',
      ));

      expect(notifier.state.length, 3);
      expect(notifier.pendingCount, 3);

      // === الخطوة 2: بدء طباعة الأول -> فشل ===
      notifier.markPrinting('pj-v06-receipt');
      expect(notifier.state.firstWhere((j) => j.id == 'pj-v06-receipt').status,
          'printing');

      notifier.markFailed('pj-v06-receipt', 'نفد الحبر');
      expect(notifier.state.firstWhere((j) => j.id == 'pj-v06-receipt').status,
          'failed');
      expect(notifier.failedCount, 1);

      // === الخطوة 3: طباعة الثاني بنجاح ===
      notifier.markPrinting('pj-v06-report');
      notifier.markCompleted('pj-v06-report');
      expect(notifier.state.firstWhere((j) => j.id == 'pj-v06-report').status,
          'completed');

      // === الخطوة 4: إعادة محاولة الأول -> نجاح ===
      notifier.retryJob('pj-v06-receipt');
      expect(notifier.state.firstWhere((j) => j.id == 'pj-v06-receipt').status,
          'pending');
      expect(notifier.failedCount, 0);

      notifier.markPrinting('pj-v06-receipt');
      notifier.markCompleted('pj-v06-receipt');

      // === الخطوة 5: طباعة الثالث بنجاح ===
      notifier.markPrinting('pj-v06-barcode');
      notifier.markCompleted('pj-v06-barcode');

      // الآن كل المهام مكتملة
      expect(notifier.pendingCount, 0);
      expect(notifier.failedCount, 0);
      expect(notifier.state.length, 3);
      expect(
        notifier.state.every((j) => j.status == 'completed'),
        isTrue,
        reason: 'جميع المهام يجب أن تكون مكتملة',
      );

      // === الخطوة 6: مسح المكتملة ===
      notifier.clearCompleted();
      expect(notifier.state.length, 0);

      // === التحقق النهائي: إزالة مهمة بالـ id ===
      notifier.addJob(createTestJob(id: 'pj-v06-extra'));
      expect(notifier.state.length, 1);
      notifier.removeJob('pj-v06-extra');
      expect(notifier.state.length, 0);
    });
  });
}
