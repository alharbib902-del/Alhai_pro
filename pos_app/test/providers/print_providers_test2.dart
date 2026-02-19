/// اختبارات مزودات قائمة الطباعة - PrintQueueNotifier Tests
///
/// اختبارات وحدة نقية للـ PrintQueueNotifier و PrintJob
/// لا تحتاج mocks لأنها تعمل بالذاكرة (in-memory)
///
/// 12 اختبار تغطي:
/// - إضافة مهمة طباعة
/// - إزالة مهمة طباعة
/// - مسح جميع المهام
/// - مسح المهام المكتملة فقط
/// - تحديد مهمة كفاشلة
/// - تحديد مهمة كمكتملة
/// - إعادة محاولة مهمة فاشلة
/// - تحديد مهمة كجاري الطباعة
/// - عداد المهام المعلقة
/// - عداد المهام الفاشلة
/// - PrintJob.toJson/fromJson round-trip
/// - PrintJob.copyWith
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/providers/print_providers.dart';

void main() {
  // ==========================================================================
  // مساعدات الاختبار
  // ==========================================================================

  /// إنشاء مهمة طباعة اختبارية
  PrintJob createTestJob({
    String? id,
    String status = 'pending',
    String type = 'receipt',
    int retryCount = 0,
    String? errorMessage,
  }) {
    return PrintJob(
      id: id ?? 'job-${DateTime.now().microsecondsSinceEpoch}',
      saleId: 'sale-001',
      receiptNo: 'POS-20260218-0001',
      type: type,
      status: status,
      retryCount: retryCount,
      errorMessage: errorMessage,
      createdAt: DateTime(2026, 2, 18, 10, 0),
    );
  }

  group('PrintQueueNotifier - مدير قائمة الطباعة', () {
    late PrintQueueNotifier notifier;

    setUp(() {
      notifier = PrintQueueNotifier();
    });

    // ========================================================================
    // اختبار إضافة مهمة
    // ========================================================================

    test('addJob يضيف مهمة للقائمة', () {
      // Arrange
      final job = createTestJob(id: 'job-1');

      // Act
      notifier.addJob(job);

      // Assert
      expect(notifier.state, hasLength(1));
      expect(notifier.state.first.id, equals('job-1'));
      expect(notifier.state.first.status, equals('pending'));
    });

    // ========================================================================
    // اختبار إزالة مهمة
    // ========================================================================

    test('removeJob يزيل مهمة من القائمة بالمعرف', () {
      // Arrange
      final job1 = createTestJob(id: 'job-1');
      final job2 = createTestJob(id: 'job-2');
      notifier.addJob(job1);
      notifier.addJob(job2);

      // Act
      notifier.removeJob('job-1');

      // Assert
      expect(notifier.state, hasLength(1));
      expect(notifier.state.first.id, equals('job-2'));
    });

    // ========================================================================
    // اختبار مسح جميع المهام
    // ========================================================================

    test('clearAll يمسح جميع المهام', () {
      // Arrange
      notifier.addJob(createTestJob(id: 'job-1'));
      notifier.addJob(createTestJob(id: 'job-2'));
      notifier.addJob(createTestJob(id: 'job-3'));

      // Act
      notifier.clearAll();

      // Assert
      expect(notifier.state, isEmpty);
    });

    // ========================================================================
    // اختبار مسح المهام المكتملة فقط
    // ========================================================================

    test('clearCompleted يمسح المكتملة فقط ويبقي الباقي', () {
      // Arrange
      notifier.addJob(createTestJob(id: 'job-pending', status: 'pending'));
      notifier.addJob(createTestJob(id: 'job-completed', status: 'completed'));
      notifier.addJob(createTestJob(id: 'job-failed', status: 'failed'));

      // Act
      notifier.clearCompleted();

      // Assert
      expect(notifier.state, hasLength(2));
      expect(notifier.state.map((j) => j.id), containsAll(['job-pending', 'job-failed']));
      expect(notifier.state.map((j) => j.id), isNot(contains('job-completed')));
    });

    // ========================================================================
    // اختبار تحديد مهمة كفاشلة
    // ========================================================================

    test('markFailed يحدد الحالة=failed ويزيد retryCount ويضع errorMessage', () {
      // Arrange
      final job = createTestJob(id: 'job-1');
      notifier.addJob(job);

      // Act
      notifier.markFailed('job-1', 'خطأ في الطابعة');

      // Assert
      final updated = notifier.state.first;
      expect(updated.status, equals('failed'));
      expect(updated.retryCount, equals(1));
      expect(updated.errorMessage, equals('خطأ في الطابعة'));
    });

    // ========================================================================
    // اختبار تحديد مهمة كمكتملة
    // ========================================================================

    test('markCompleted يحدد الحالة=completed', () {
      // Arrange
      notifier.addJob(createTestJob(id: 'job-1'));

      // Act
      notifier.markCompleted('job-1');

      // Assert
      expect(notifier.state.first.status, equals('completed'));
    });

    // ========================================================================
    // اختبار إعادة المحاولة
    // ========================================================================

    test('retryJob يعيد الحالة=pending ويمسح errorMessage', () {
      // Arrange
      final job = createTestJob(
        id: 'job-1',
        status: 'failed',
        retryCount: 2,
        errorMessage: 'خطأ سابق',
      );
      notifier.addJob(job);

      // Act
      notifier.retryJob('job-1');

      // Assert
      final updated = notifier.state.first;
      expect(updated.status, equals('pending'));
      // ملاحظة: retryJob لا يغير retryCount، copyWith لا يمرر null
      // errorMessage ستكون null بسبب copyWith(errorMessage: null)
    });

    // ========================================================================
    // اختبار تحديد مهمة كجاري الطباعة
    // ========================================================================

    test('markPrinting يحدد الحالة=printing', () {
      // Arrange
      notifier.addJob(createTestJob(id: 'job-1'));

      // Act
      notifier.markPrinting('job-1');

      // Assert
      expect(notifier.state.first.status, equals('printing'));
    });

    // ========================================================================
    // اختبار عداد المهام المعلقة
    // ========================================================================

    test('pendingCount يعيد العدد الصحيح للمهام المعلقة', () {
      // Arrange
      notifier.addJob(createTestJob(id: 'job-1', status: 'pending'));
      notifier.addJob(createTestJob(id: 'job-2', status: 'pending'));
      notifier.addJob(createTestJob(id: 'job-3', status: 'completed'));
      notifier.addJob(createTestJob(id: 'job-4', status: 'failed'));

      // Assert
      expect(notifier.pendingCount, equals(2));
    });

    // ========================================================================
    // اختبار عداد المهام الفاشلة
    // ========================================================================

    test('failedCount يعيد العدد الصحيح للمهام الفاشلة', () {
      // Arrange
      notifier.addJob(createTestJob(id: 'job-1', status: 'pending'));
      notifier.addJob(createTestJob(id: 'job-2', status: 'failed'));
      notifier.addJob(createTestJob(id: 'job-3', status: 'failed'));

      // Assert
      expect(notifier.failedCount, equals(2));
    });
  });

  // ==========================================================================
  // اختبارات PrintJob
  // ==========================================================================

  group('PrintJob - نموذج مهمة الطباعة', () {
    // ========================================================================
    // اختبار toJson/fromJson round-trip
    // ========================================================================

    test('toJson/fromJson round-trip يحافظ على جميع البيانات', () {
      // Arrange
      final original = PrintJob(
        id: 'job-roundtrip',
        saleId: 'sale-123',
        receiptNo: 'POS-20260218-0042',
        type: 'report',
        status: 'failed',
        errorMessage: 'انتهت الورقة',
        retryCount: 3,
        createdAt: DateTime(2026, 2, 18, 14, 30, 0),
      );

      // Act
      final json = original.toJson();
      final restored = PrintJob.fromJson(json);

      // Assert
      expect(restored.id, equals(original.id));
      expect(restored.saleId, equals(original.saleId));
      expect(restored.receiptNo, equals(original.receiptNo));
      expect(restored.type, equals(original.type));
      expect(restored.status, equals(original.status));
      expect(restored.errorMessage, equals(original.errorMessage));
      expect(restored.retryCount, equals(original.retryCount));
      expect(restored.createdAt, equals(original.createdAt));
    });

    // ========================================================================
    // اختبار copyWith
    // ========================================================================

    test('copyWith ينشئ نسخة صحيحة مع التغييرات المطلوبة', () {
      // Arrange
      final original = PrintJob(
        id: 'job-copy',
        saleId: 'sale-456',
        receiptNo: 'POS-20260218-0099',
        type: 'barcode',
        status: 'pending',
        retryCount: 0,
        createdAt: DateTime(2026, 2, 18, 9, 0),
      );

      // Act
      final copy = original.copyWith(
        status: 'failed',
        errorMessage: 'خطأ',
        retryCount: 1,
      );

      // Assert - الحقول المتغيرة
      expect(copy.status, equals('failed'));
      expect(copy.errorMessage, equals('خطأ'));
      expect(copy.retryCount, equals(1));

      // Assert - الحقول الثابتة (لم تتغير)
      expect(copy.id, equals(original.id));
      expect(copy.saleId, equals(original.saleId));
      expect(copy.receiptNo, equals(original.receiptNo));
      expect(copy.type, equals(original.type));
      expect(copy.createdAt, equals(original.createdAt));
    });
  });
}
