import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/providers/performance_provider.dart';

void main() {
  group('SalePerformance Tests', () {
    test('يحسب المدة بشكل صحيح', () {
      final start = DateTime.now();
      final end = start.add(const Duration(seconds: 45));
      
      final sale = SalePerformance(
        saleId: '1',
        startTime: start,
        endTime: end,
      );

      expect(sale.durationSeconds, 45);
    });

    test('isCompleted يرجع true عند وجود endTime', () {
      final sale = SalePerformance(
        saleId: '1',
        startTime: DateTime.now(),
        endTime: DateTime.now(),
      );

      expect(sale.isCompleted, isTrue);
    });

    test('isCompleted يرجع false عند عدم وجود endTime', () {
      final sale = SalePerformance(
        saleId: '1',
        startTime: DateTime.now(),
      );

      expect(sale.isCompleted, isFalse);
    });
  });

  group('PerformanceStats Tests', () {
    test('يحسب completedSales بشكل صحيح', () {
      final stats = PerformanceStats(
        sales: [
          SalePerformance(saleId: '1', startTime: DateTime.now(), endTime: DateTime.now()),
          SalePerformance(saleId: '2', startTime: DateTime.now()), // غير مكتمل
          SalePerformance(saleId: '3', startTime: DateTime.now(), endTime: DateTime.now()),
        ],
      );

      expect(stats.completedSales, 2);
    });

    test('يحسب errorCount بشكل صحيح', () {
      final stats = PerformanceStats(
        sales: [
          SalePerformance(saleId: '1', startTime: DateTime.now(), hasError: true),
          SalePerformance(saleId: '2', startTime: DateTime.now()),
          SalePerformance(saleId: '3', startTime: DateTime.now(), hasError: true),
        ],
      );

      expect(stats.errorCount, 2);
    });

    test('يحسب avgSaleTime بشكل صحيح', () {
      final now = DateTime.now();
      final stats = PerformanceStats(
        sales: [
          SalePerformance(
            saleId: '1',
            startTime: now,
            endTime: now.add(const Duration(seconds: 30)),
          ),
          SalePerformance(
            saleId: '2',
            startTime: now,
            endTime: now.add(const Duration(seconds: 60)),
          ),
        ],
      );

      expect(stats.avgSaleTime, 45.0); // (30 + 60) / 2
    });

    test('يحسب totalSales بشكل صحيح', () {
      final stats = PerformanceStats(
        sales: [
          SalePerformance(saleId: '1', startTime: DateTime.now(), endTime: DateTime.now(), totalAmount: 100.0),
          SalePerformance(saleId: '2', startTime: DateTime.now(), endTime: DateTime.now(), totalAmount: 150.0),
          SalePerformance(saleId: '3', startTime: DateTime.now(), totalAmount: 50.0), // غير مكتمل - لا يُحسب
        ],
      );

      expect(stats.totalSales, 250.0);
    });

    test('errorRate يحسب النسبة المئوية', () {
      final stats = PerformanceStats(
        sales: [
          SalePerformance(saleId: '1', startTime: DateTime.now(), hasError: true),
          SalePerformance(saleId: '2', startTime: DateTime.now()),
          SalePerformance(saleId: '3', startTime: DateTime.now()),
          SalePerformance(saleId: '4', startTime: DateTime.now()),
        ],
      );

      expect(stats.errorRate, 25.0); // 1 من 4 = 25%
    });
  });

  group('PerformanceNotifier Tests', () {
    test('يبدأ جلسة فارغة', () {
      final notifier = PerformanceNotifier();
      expect(notifier.state.sales, isEmpty);
    });

    test('startSale يضيف عملية جديدة', () {
      final notifier = PerformanceNotifier();
      final saleId = notifier.startSale();

      expect(notifier.state.sales.length, 1);
      expect(notifier.state.sales.first.saleId, saleId);
      expect(notifier.hasSaleInProgress, isTrue);
    });

    test('completeSale يُنهي العملية', () {
      final notifier = PerformanceNotifier();
      notifier.startSale();
      
      notifier.completeSale(itemCount: 5, totalAmount: 100.0);

      expect(notifier.state.sales.first.isCompleted, isTrue);
      expect(notifier.state.sales.first.itemCount, 5);
      expect(notifier.state.sales.first.totalAmount, 100.0);
      expect(notifier.hasSaleInProgress, isFalse);
    });

    test('recordError يسجل خطأ', () {
      final notifier = PerformanceNotifier();
      notifier.startSale();
      
      notifier.recordError('خطأ في الدفع');

      expect(notifier.state.sales.first.hasError, isTrue);
      expect(notifier.state.sales.first.errorMessage, 'خطأ في الدفع');
    });

    test('cancelSale يحذف العملية', () {
      final notifier = PerformanceNotifier();
      notifier.startSale();
      
      expect(notifier.state.sales.length, 1);
      
      notifier.cancelSale();

      expect(notifier.state.sales, isEmpty);
      expect(notifier.hasSaleInProgress, isFalse);
    });

    test('resetSession يمسح كل شيء', () {
      final notifier = PerformanceNotifier();
      notifier.startSale();
      notifier.completeSale(itemCount: 1, totalAmount: 50.0);
      notifier.startSale();
      notifier.completeSale(itemCount: 2, totalAmount: 100.0);

      expect(notifier.state.sales.length, 2);
      
      notifier.resetSession();

      expect(notifier.state.sales, isEmpty);
    });
  });
}
