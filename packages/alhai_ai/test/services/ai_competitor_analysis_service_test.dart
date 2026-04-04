import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_ai/src/services/ai_competitor_analysis_service.dart';

void main() {
  group('PricePosition', () {
    test('has all values', () {
      expect(PricePosition.values.length, 5);
    });
  });

  group('AlertType', () {
    test('has all values', () {
      expect(AlertType.values.length, 5);
    });
  });

  group('mockCompetitors', () {
    test('contains competitors', () {
      expect(AiCompetitorAnalysisService.mockCompetitors, isNotEmpty);
      expect(AiCompetitorAnalysisService.mockCompetitors.length, 5);
    });

    test('each competitor has required fields', () {
      for (final c in AiCompetitorAnalysisService.mockCompetitors) {
        expect(c.id, isNotEmpty);
        expect(c.name, isNotEmpty);
        expect(c.nameAr, isNotEmpty);
        expect(c.type, isNotEmpty);
        expect(c.overallPriceIndex, greaterThan(0));
        expect(c.qualityScore, greaterThan(0));
        expect(c.branchCount, greaterThan(0));
      }
    });

    test('competitors have unique IDs', () {
      final ids =
          AiCompetitorAnalysisService.mockCompetitors.map((c) => c.id).toSet();
      expect(ids.length, AiCompetitorAnalysisService.mockCompetitors.length);
    });
  });

  group('getPriceComparisons', () {
    test('returns price comparisons', () {
      final comparisons = AiCompetitorAnalysisService.getPriceComparisons();
      expect(comparisons, isNotEmpty);
      expect(comparisons.length, 12);
    });

    test('each comparison has required data', () {
      final comparisons = AiCompetitorAnalysisService.getPriceComparisons();

      for (final c in comparisons) {
        expect(c.productId, isNotEmpty);
        expect(c.productName, isNotEmpty);
        expect(c.category, isNotEmpty);
        expect(c.ourPrice, greaterThan(0));
        expect(c.competitorPrices, isNotEmpty);
        expect(c.avgMarketPrice, greaterThan(0));
      }
    });

    test('competitor prices include all competitors', () {
      final comparisons = AiCompetitorAnalysisService.getPriceComparisons();

      for (final c in comparisons) {
        expect(c.competitorPrices.length,
            AiCompetitorAnalysisService.mockCompetitors.length);
      }
    });

    test('position is valid for price difference', () {
      final comparisons = AiCompetitorAnalysisService.getPriceComparisons();

      for (final c in comparisons) {
        expect(PricePosition.values, contains(c.position));
      }
    });
  });

  group('getMarketPosition', () {
    test('returns market position', () {
      final position = AiCompetitorAnalysisService.getMarketPosition();

      expect(position.priceIndex, greaterThan(0));
      expect(position.qualityIndex, greaterThan(0));
      expect(position.valueScore, greaterThan(0));
      expect(position.positionLabel, isNotEmpty);
      expect(position.positionLabelAr, isNotEmpty);
    });

    test('competitors include us', () {
      final position = AiCompetitorAnalysisService.getMarketPosition();

      final us = position.competitors.where((c) => c.isUs).toList();
      expect(us.length, 1);
    });

    test('competitors have valid indices', () {
      final position = AiCompetitorAnalysisService.getMarketPosition();

      for (final c in position.competitors) {
        expect(c.name, isNotEmpty);
        expect(c.priceIndex, greaterThanOrEqualTo(0));
        expect(c.qualityIndex, greaterThanOrEqualTo(0));
        expect(c.marketShare, greaterThan(0));
      }
    });
  });

  group('getAlerts', () {
    test('returns alerts', () {
      final alerts = AiCompetitorAnalysisService.getAlerts();
      expect(alerts, isNotEmpty);
      expect(alerts.length, 5);
    });

    test('alerts have required data', () {
      final alerts = AiCompetitorAnalysisService.getAlerts();

      for (final a in alerts) {
        expect(a.id, isNotEmpty);
        expect(a.competitorName, isNotEmpty);
        expect(a.productName, isNotEmpty);
        expect(a.message, isNotEmpty);
      }
    });

    test('alerts contain different types', () {
      final alerts = AiCompetitorAnalysisService.getAlerts();
      final types = alerts.map((a) => a.alertType).toSet();
      expect(types.length, greaterThanOrEqualTo(3));
    });

    test('price decrease alerts have negative change percent', () {
      final alerts = AiCompetitorAnalysisService.getAlerts();
      final decreases =
          alerts.where((a) => a.alertType == AlertType.priceDecrease).toList();

      for (final a in decreases) {
        expect(a.changePercent, lessThan(0));
        expect(a.newPrice, lessThan(a.oldPrice));
      }
    });

    test('price increase alerts have positive change percent', () {
      final alerts = AiCompetitorAnalysisService.getAlerts();
      final increases =
          alerts.where((a) => a.alertType == AlertType.priceIncrease).toList();

      for (final a in increases) {
        expect(a.changePercent, greaterThan(0));
        expect(a.newPrice, greaterThan(a.oldPrice));
      }
    });
  });

  group('getSummary', () {
    test('returns complete summary', () {
      final summary = AiCompetitorAnalysisService.getSummary();

      expect(summary.totalProductsTracked, greaterThan(0));
      expect(summary.activeAlerts, greaterThan(0));
      expect(summary.marketPositionLabel, isNotEmpty);
    });

    test('cheaper and expensive counts are reasonable', () {
      final summary = AiCompetitorAnalysisService.getSummary();

      expect(
        summary.cheaperThanCompetitors + summary.moreExpensiveThanCompetitors,
        lessThanOrEqualTo(summary.totalProductsTracked),
      );
    });
  });
}
