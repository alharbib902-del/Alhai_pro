import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_ai/src/services/ai_return_prediction_service.dart';

void main() {
  late AiReturnPredictionService service;

  setUp(() {
    service = AiReturnPredictionService();
  });

  group('ReturnRiskLevel', () {
    test('has all values', () {
      expect(ReturnRiskLevel.values.length, 4);
    });
  });

  group('ReturnRiskFactor', () {
    test('has all values', () {
      expect(ReturnRiskFactor.values.length, 6);
    });
  });

  group('PreventiveType', () {
    test('has all values', () {
      expect(PreventiveType.values.length, 5);
    });
  });

  group('TrendDirection', () {
    test('has all values', () {
      expect(TrendDirection.values.length, 3);
    });
  });

  group('getReturnProbabilities', () {
    test('returns probabilities', () async {
      final probs = await service.getReturnProbabilities('store-1');
      expect(probs, isNotEmpty);
      expect(probs.length, 10);
    });

    test('probabilities are between 0 and 1', () async {
      final probs = await service.getReturnProbabilities('store-1');

      for (final p in probs) {
        expect(p.probability, greaterThanOrEqualTo(0));
        expect(p.probability, lessThanOrEqualTo(1));
      }
    });

    test('each probability has required fields', () async {
      final probs = await service.getReturnProbabilities('store-1');

      for (final p in probs) {
        expect(p.transactionId, isNotEmpty);
        expect(p.customerName, isNotEmpty);
        expect(p.topRiskProduct, isNotEmpty);
        expect(p.amount, greaterThan(0));
      }
    });

    test('contains all risk levels', () async {
      final probs = await service.getReturnProbabilities('store-1');
      final levels = probs.map((p) => p.riskLevel).toSet();

      expect(levels, contains(ReturnRiskLevel.low));
      expect(levels, contains(ReturnRiskLevel.medium));
      expect(levels, contains(ReturnRiskLevel.high));
      expect(levels, contains(ReturnRiskLevel.veryHigh));
    });

    test('high risk items have higher probabilities', () async {
      final probs = await service.getReturnProbabilities('store-1');

      final highRisk = probs
          .where((p) =>
              p.riskLevel == ReturnRiskLevel.high ||
              p.riskLevel == ReturnRiskLevel.veryHigh)
          .toList();
      final lowRisk =
          probs.where((p) => p.riskLevel == ReturnRiskLevel.low).toList();

      if (highRisk.isNotEmpty && lowRisk.isNotEmpty) {
        final avgHigh =
            highRisk.map((p) => p.probability).reduce((a, b) => a + b) /
                highRisk.length;
        final avgLow =
            lowRisk.map((p) => p.probability).reduce((a, b) => a + b) /
                lowRisk.length;
        expect(avgHigh, greaterThan(avgLow));
      }
    });
  });

  group('getPreventiveActions', () {
    test('returns preventive actions', () async {
      final actions = await service.getPreventiveActions('store-1');
      expect(actions, isNotEmpty);
      expect(actions.length, 5);
    });

    test('each action has required fields', () async {
      final actions = await service.getPreventiveActions('store-1');

      for (final a in actions) {
        expect(a.id, isNotEmpty);
        expect(a.title, isNotEmpty);
        expect(a.description, isNotEmpty);
        expect(a.targetTransactionId, isNotEmpty);
        expect(a.estimatedSavings, greaterThan(0));
      }
    });

    test('actions contain different preventive types', () async {
      final actions = await service.getPreventiveActions('store-1');
      final types = actions.map((a) => a.type).toSet();
      expect(types.length, greaterThanOrEqualTo(4));
    });
  });

  group('getReturnTrends', () {
    test('returns trends', () async {
      final trends = await service.getReturnTrends('store-1');
      expect(trends, isNotEmpty);
      expect(trends.length, 6);
    });

    test('each trend has valid data', () async {
      final trends = await service.getReturnTrends('store-1');

      for (final t in trends) {
        expect(t.period, isNotEmpty);
        expect(t.returnRate, greaterThan(0));
        expect(t.totalReturns, greaterThan(0));
        expect(t.totalSales, greaterThan(0));
      }
    });

    test('return rate is consistent with returns and sales', () async {
      final trends = await service.getReturnTrends('store-1');

      for (final t in trends) {
        expect(t.totalReturns, lessThanOrEqualTo(t.totalSales));
      }
    });

    test('contains different trend directions', () async {
      final trends = await service.getReturnTrends('store-1');
      final directions = trends.map((t) => t.trend).toSet();
      expect(directions.length, greaterThan(1));
    });
  });

  group('calculateAverageReturnRate', () {
    test('returns 0 for empty list', () {
      expect(service.calculateAverageReturnRate([]), 0);
    });

    test('calculates average correctly', () {
      const trends = [
        ReturnTrend(
          period: 'Jan',
          returnRate: 4.0,
          totalReturns: 20,
          totalSales: 500,
          trend: TrendDirection.stable,
        ),
        ReturnTrend(
          period: 'Feb',
          returnRate: 6.0,
          totalReturns: 30,
          totalSales: 500,
          trend: TrendDirection.up,
        ),
      ];

      expect(service.calculateAverageReturnRate(trends), 5.0);
    });
  });

  group('calculateAtRiskAmount', () {
    test('sums only high and very high risk amounts', () async {
      final probs = await service.getReturnProbabilities('store-1');
      final result = service.calculateAtRiskAmount(probs);

      final expected = probs
          .where((p) =>
              p.riskLevel == ReturnRiskLevel.high ||
              p.riskLevel == ReturnRiskLevel.veryHigh)
          .fold<double>(0, (sum, p) => sum + p.amount);

      expect(result, expected);
      expect(result, greaterThan(0));
    });

    test('returns 0 for empty list', () {
      expect(service.calculateAtRiskAmount([]), 0);
    });
  });

  group('static helpers', () {
    test('getFactorLabel returns label for each factor', () {
      for (final factor in ReturnRiskFactor.values) {
        expect(AiReturnPredictionService.getFactorLabel(factor), isNotEmpty);
      }
    });

    test('getRiskColorValue returns color for each level', () {
      for (final level in ReturnRiskLevel.values) {
        expect(
            AiReturnPredictionService.getRiskColorValue(level), greaterThan(0));
      }
    });

    test('getRiskLabel returns label for each level', () {
      for (final level in ReturnRiskLevel.values) {
        expect(AiReturnPredictionService.getRiskLabel(level), isNotEmpty);
      }
    });

    test('getPreventiveTypeLabel returns label for each type', () {
      for (final type in PreventiveType.values) {
        expect(
            AiReturnPredictionService.getPreventiveTypeLabel(type), isNotEmpty);
      }
    });
  });
}
