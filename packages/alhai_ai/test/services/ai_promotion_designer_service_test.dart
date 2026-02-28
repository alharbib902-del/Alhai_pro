import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_ai/src/services/ai_promotion_designer_service.dart';

void main() {
  late AiPromotionDesignerService service;

  setUp(() {
    service = AiPromotionDesignerService();
  });

  group('PromotionType', () {
    test('has all values', () {
      expect(PromotionType.values.length, 6);
    });
  });

  group('generatePromotions', () {
    test('returns promotions', () async {
      final promotions = await service.generatePromotions('store-1');
      expect(promotions, isNotEmpty);
      expect(promotions.length, 8);
    });

    test('each promotion has required fields', () async {
      final promotions = await service.generatePromotions('store-1');

      for (final p in promotions) {
        expect(p.id, isNotEmpty);
        expect(p.title, isNotEmpty);
        expect(p.description, isNotEmpty);
        expect(p.products, isNotEmpty);
        expect(p.projectedRevenue, greaterThan(0));
        expect(p.projectedCost, greaterThan(0));
      }
    });

    test('promotions have valid date ranges', () async {
      final promotions = await service.generatePromotions('store-1');

      for (final p in promotions) {
        expect(p.endDate.isAfter(p.startDate), isTrue);
      }
    });

    test('promotions have positive ROI', () async {
      final promotions = await service.generatePromotions('store-1');

      for (final p in promotions) {
        expect(p.roi, greaterThan(0));
      }
    });

    test('confidence is between 0 and 1', () async {
      final promotions = await service.generatePromotions('store-1');

      for (final p in promotions) {
        expect(p.confidence, greaterThan(0));
        expect(p.confidence, lessThanOrEqualTo(1));
      }
    });

    test('contains different promotion types', () async {
      final promotions = await service.generatePromotions('store-1');
      final types = promotions.map((p) => p.type).toSet();
      expect(types.length, greaterThanOrEqualTo(4));
    });

    test('projected revenue exceeds projected cost', () async {
      final promotions = await service.generatePromotions('store-1');

      for (final p in promotions) {
        expect(p.projectedRevenue, greaterThan(p.projectedCost));
      }
    });
  });

  group('forecastRoi', () {
    test('returns ROI forecast matching promotion duration', () async {
      final promotions = await service.generatePromotions('store-1');
      final promotion = promotions.first;
      final forecast = await service.forecastRoi(promotion);

      final duration =
          promotion.endDate.difference(promotion.startDate).inDays;
      expect(forecast.length, duration);
    });

    test('forecast days are sequential', () async {
      final promotions = await service.generatePromotions('store-1');
      final forecast = await service.forecastRoi(promotions.first);

      for (int i = 0; i < forecast.length; i++) {
        expect(forecast[i].day, i + 1);
      }
    });

    test('cumulative revenue increases over time', () async {
      final promotions = await service.generatePromotions('store-1');
      final forecast = await service.forecastRoi(promotions.first);

      for (int i = 1; i < forecast.length; i++) {
        expect(forecast[i].projectedRevenue,
            greaterThanOrEqualTo(forecast[i - 1].projectedRevenue));
      }
    });

    test('cumulative cost increases over time', () async {
      final promotions = await service.generatePromotions('store-1');
      final forecast = await service.forecastRoi(promotions.first);

      for (int i = 1; i < forecast.length; i++) {
        expect(forecast[i].projectedCost,
            greaterThanOrEqualTo(forecast[i - 1].projectedCost));
      }
    });
  });

  group('createAbTest', () {
    test('creates A/B test config', () async {
      final promotions = await service.generatePromotions('store-1');
      final abTest =
          await service.createAbTest(promotions[0], promotions[1]);

      expect(abTest.promotionA.id, promotions[0].id);
      expect(abTest.promotionB.id, promotions[1].id);
      expect(abTest.testDurationDays, greaterThan(0));
      expect(abTest.controlGroupPercent, greaterThan(0));
      expect(abTest.metricToTrack, isNotEmpty);
    });
  });

  group('static helpers', () {
    test('getPromotionTypeLabel returns label for each type', () {
      for (final type in PromotionType.values) {
        expect(
            AiPromotionDesignerService.getPromotionTypeLabel(type), isNotEmpty);
      }
    });

    test('getPromotionTypeColorValue returns color for each type', () {
      for (final type in PromotionType.values) {
        expect(AiPromotionDesignerService.getPromotionTypeColorValue(type),
            greaterThan(0));
      }
    });

    test('getPromotionTypeEmoji returns emoji for each type', () {
      for (final type in PromotionType.values) {
        expect(
            AiPromotionDesignerService.getPromotionTypeEmoji(type), isNotEmpty);
      }
    });

    test('labels are unique for each type', () {
      final labels = PromotionType.values
          .map((t) => AiPromotionDesignerService.getPromotionTypeLabel(t))
          .toSet();
      expect(labels.length, PromotionType.values.length);
    });
  });
}
