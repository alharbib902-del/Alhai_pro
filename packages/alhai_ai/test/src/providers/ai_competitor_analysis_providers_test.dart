import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_ai/src/providers/ai_competitor_analysis_providers.dart';
import 'package:alhai_ai/src/services/ai_competitor_analysis_service.dart';

void main() {
  group('competitorFilterProvider', () {
    test('initial value is Arabic all', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(competitorFilterProvider), 'الكل');
    });

    test('can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(competitorFilterProvider.notifier).state = 'مشروبات';
      expect(container.read(competitorFilterProvider), 'مشروبات');
    });
  });

  group('competitorSortProvider', () {
    test('initial value is name', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        container.read(competitorSortProvider),
        CompetitorSortType.name,
      );
    });

    test('can be updated to priceDiff', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(competitorSortProvider.notifier).state =
          CompetitorSortType.priceDiff;
      expect(
        container.read(competitorSortProvider),
        CompetitorSortType.priceDiff,
      );
    });
  });

  group('CompetitorSortType', () {
    test('has all values', () {
      expect(CompetitorSortType.values.length, 4);
      expect(CompetitorSortType.values, contains(CompetitorSortType.name));
      expect(CompetitorSortType.values, contains(CompetitorSortType.priceDiff));
      expect(CompetitorSortType.values, contains(CompetitorSortType.ourPrice));
      expect(CompetitorSortType.values, contains(CompetitorSortType.category));
    });
  });

  group('competitorsProvider', () {
    test('returns mock competitors', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final competitors = container.read(competitorsProvider);
      expect(competitors, isNotEmpty);
      expect(competitors, isA<List<Competitor>>());
    });
  });

  group('marketPositionProvider', () {
    test('returns market position data', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final position = container.read(marketPositionProvider);
      expect(position, isA<MarketPosition>());
    });
  });

  group('competitorSummaryProvider', () {
    test('returns analysis summary', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final summary = container.read(competitorSummaryProvider);
      expect(summary, isA<CompetitorAnalysisSummary>());
      expect(summary.totalProductsTracked, greaterThan(0));
    });
  });

  group('CompetitorAlertsNotifier', () {
    test('initial state has alerts', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final alerts = container.read(competitorAlertsProvider);
      expect(alerts, isNotEmpty);
    });

    test('markAllAsRead marks all alerts as read', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(competitorAlertsProvider.notifier).markAllAsRead();
      final alerts = container.read(competitorAlertsProvider);
      expect(alerts.every((a) => a.isRead), isTrue);
    });

    test('unreadCount returns correct count', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(competitorAlertsProvider.notifier);
      final initialUnread = notifier.unreadCount;
      expect(initialUnread, greaterThanOrEqualTo(0));

      notifier.markAllAsRead();
      expect(notifier.unreadCount, 0);
    });
  });

  group('PriceComparisonsNotifier', () {
    test('sortComparisons by name', () {
      final notifier = PriceComparisonsNotifier();
      addTearDown(notifier.dispose);

      final list = [
        PriceComparison(
          productId: 'p1',
          productName: 'B Product',
          ourPrice: 10,
          competitorPrices: {},
          category: 'cat',
          avgMarketPrice: 12,
          priceDifferencePercent: -5,
          position: PricePosition.belowAverage,
        ),
        PriceComparison(
          productId: 'p2',
          productName: 'A Product',
          ourPrice: 8,
          competitorPrices: {},
          category: 'cat',
          avgMarketPrice: 10,
          priceDifferencePercent: -3,
          position: PricePosition.average,
        ),
      ];

      final sorted = notifier.sortComparisons(list, CompetitorSortType.name);
      expect(sorted.first.productName, 'A Product');
    });
  });
}
