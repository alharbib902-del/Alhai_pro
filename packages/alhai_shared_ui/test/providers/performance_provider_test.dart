/// Unit tests for performance provider
///
/// Tests: SalePerformance model, PerformanceStats, PerformanceNotifier
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alhai_shared_ui/alhai_shared_ui.dart';

void main() {
  group('SalePerformance', () {
    test('durationSeconds returns 0 when endTime is null', () {
      final sale = SalePerformance(
        saleId: 'sale-1',
        startTime: DateTime(2026, 1, 1, 10, 0),
      );
      expect(sale.durationSeconds, 0);
      expect(sale.isCompleted, isFalse);
    });

    test('durationSeconds calculates correctly', () {
      final sale = SalePerformance(
        saleId: 'sale-1',
        startTime: DateTime(2026, 1, 1, 10, 0, 0),
        endTime: DateTime(2026, 1, 1, 10, 2, 30),
      );
      expect(sale.durationSeconds, 150);
      expect(sale.isCompleted, isTrue);
    });

    test('copyWith updates endTime', () {
      final sale = SalePerformance(
        saleId: 'sale-1',
        startTime: DateTime(2026, 1, 1, 10, 0),
      );
      final updated =
          sale.copyWith(endTime: DateTime(2026, 1, 1, 10, 5));
      expect(updated.isCompleted, isTrue);
      expect(updated.saleId, 'sale-1');
    });

    test('copyWith updates itemCount and totalAmount', () {
      final sale = SalePerformance(
        saleId: 'sale-1',
        startTime: DateTime(2026, 1, 1, 10, 0),
      );
      final updated = sale.copyWith(itemCount: 5, totalAmount: 250.0);
      expect(updated.itemCount, 5);
      expect(updated.totalAmount, 250.0);
    });

    test('copyWith updates error state', () {
      final sale = SalePerformance(
        saleId: 'sale-1',
        startTime: DateTime(2026, 1, 1, 10, 0),
      );
      final updated = sale.copyWith(
        hasError: true,
        errorMessage: 'Payment failed',
      );
      expect(updated.hasError, isTrue);
      expect(updated.errorMessage, 'Payment failed');
    });
  });

  group('PerformanceStats', () {
    test('has correct defaults', () {
      final stats = PerformanceStats();
      expect(stats.completedSales, 0);
      expect(stats.errorCount, 0);
      expect(stats.avgSaleTime, 0);
      expect(stats.salesPerHour, 0);
      expect(stats.totalSales, 0);
      expect(stats.errorRate, 0);
    });

    test('completedSales counts only completed sales', () {
      final stats = PerformanceStats(sales: [
        SalePerformance(
          saleId: 's1',
          startTime: DateTime(2026, 1, 1, 10, 0),
          endTime: DateTime(2026, 1, 1, 10, 2),
          totalAmount: 100,
        ),
        SalePerformance(
          saleId: 's2',
          startTime: DateTime(2026, 1, 1, 10, 5),
        ), // not completed
      ]);
      expect(stats.completedSales, 1);
    });

    test('errorCount counts errors', () {
      final stats = PerformanceStats(sales: [
        SalePerformance(
          saleId: 's1',
          startTime: DateTime(2026, 1, 1, 10, 0),
          hasError: true,
        ),
        SalePerformance(
          saleId: 's2',
          startTime: DateTime(2026, 1, 1, 10, 5),
        ),
      ]);
      expect(stats.errorCount, 1);
    });

    test('avgSaleTime calculates average', () {
      final stats = PerformanceStats(sales: [
        SalePerformance(
          saleId: 's1',
          startTime: DateTime(2026, 1, 1, 10, 0, 0),
          endTime: DateTime(2026, 1, 1, 10, 0, 60),
        ),
        SalePerformance(
          saleId: 's2',
          startTime: DateTime(2026, 1, 1, 10, 5, 0),
          endTime: DateTime(2026, 1, 1, 10, 5, 120),
        ),
      ]);
      expect(stats.avgSaleTime, 90); // (60 + 120) / 2
    });

    test('totalSales sums completed sales', () {
      final stats = PerformanceStats(sales: [
        SalePerformance(
          saleId: 's1',
          startTime: DateTime(2026, 1, 1, 10, 0),
          endTime: DateTime(2026, 1, 1, 10, 2),
          totalAmount: 100,
        ),
        SalePerformance(
          saleId: 's2',
          startTime: DateTime(2026, 1, 1, 10, 5),
          endTime: DateTime(2026, 1, 1, 10, 7),
          totalAmount: 200,
        ),
      ]);
      expect(stats.totalSales, 300);
    });

    test('errorRate calculates percentage', () {
      final stats = PerformanceStats(sales: [
        SalePerformance(
          saleId: 's1',
          startTime: DateTime(2026, 1, 1, 10, 0),
          hasError: true,
        ),
        SalePerformance(
          saleId: 's2',
          startTime: DateTime(2026, 1, 1, 10, 5),
        ),
        SalePerformance(
          saleId: 's3',
          startTime: DateTime(2026, 1, 1, 10, 10),
        ),
        SalePerformance(
          saleId: 's4',
          startTime: DateTime(2026, 1, 1, 10, 15),
        ),
      ]);
      expect(stats.errorRate, 25.0); // 1/4 = 25%
    });

    test('copyWith updates sales list', () {
      final stats = PerformanceStats();
      final updated = stats.copyWith(sales: [
        SalePerformance(
          saleId: 's1',
          startTime: DateTime(2026, 1, 1, 10, 0),
        ),
      ]);
      expect(updated.sales.length, 1);
    });
  });

  group('PerformanceNotifier', () {
    test('starts with empty stats', () {
      final notifier = PerformanceNotifier();
      expect(notifier.state.sales, isEmpty);
      expect(notifier.hasSaleInProgress, isFalse);
    });

    test('startSale adds a sale and sets current', () {
      final notifier = PerformanceNotifier();
      final id = notifier.startSale();
      expect(id, isNotEmpty);
      expect(notifier.state.sales.length, 1);
      expect(notifier.hasSaleInProgress, isTrue);
    });

    test('completeSale updates the current sale', () {
      final notifier = PerformanceNotifier();
      notifier.startSale();
      notifier.completeSale(itemCount: 3, totalAmount: 150);
      expect(notifier.state.sales.first.isCompleted, isTrue);
      expect(notifier.state.sales.first.itemCount, 3);
      expect(notifier.state.sales.first.totalAmount, 150);
      expect(notifier.hasSaleInProgress, isFalse);
    });

    test('recordError marks current sale as errored', () {
      final notifier = PerformanceNotifier();
      notifier.startSale();
      notifier.recordError('Payment declined');
      expect(notifier.state.sales.first.hasError, isTrue);
      expect(notifier.state.sales.first.errorMessage, 'Payment declined');
    });

    test('cancelSale removes the current sale', () {
      final notifier = PerformanceNotifier();
      notifier.startSale();
      notifier.cancelSale();
      expect(notifier.state.sales, isEmpty);
      expect(notifier.hasSaleInProgress, isFalse);
    });

    test('resetSession clears all data', () {
      final notifier = PerformanceNotifier();
      notifier.startSale();
      notifier.completeSale(itemCount: 1, totalAmount: 50);
      notifier.startSale();
      notifier.resetSession();
      expect(notifier.state.sales, isEmpty);
      expect(notifier.hasSaleInProgress, isFalse);
    });

    test('trims old entries beyond max history', () {
      final notifier = PerformanceNotifier();
      // Add 101 sales (max is 100)
      for (int i = 0; i < 101; i++) {
        notifier.startSale();
        notifier.completeSale(itemCount: 1, totalAmount: 10);
      }
      expect(notifier.state.sales.length, lessThanOrEqualTo(100));
    });
  });

  group('Performance derived providers', () {
    test('avgSaleTimeProvider reads from performanceProvider', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final avgTime = container.read(avgSaleTimeProvider);
      expect(avgTime, 0);
    });

    test('salesPerHourProvider reads from performanceProvider', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final sph = container.read(salesPerHourProvider);
      expect(sph, 0);
    });

    test('errorRateProvider reads from performanceProvider', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final rate = container.read(errorRateProvider);
      expect(rate, 0);
    });

    test('completedSalesCountProvider reads from performanceProvider', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final count = container.read(completedSalesCountProvider);
      expect(count, 0);
    });
  });
}
