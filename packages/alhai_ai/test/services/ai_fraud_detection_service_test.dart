import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_ai/src/services/ai_fraud_detection_service.dart';
import '../helpers/ai_test_helpers.dart';

void main() {
  late AiFraudDetectionService service;
  late MockAppDatabase mockDb;

  setUp(() {
    mockDb = createMockDatabase();
    service = AiFraudDetectionService(mockDb);
  });

  group('FraudSeverity', () {
    test('has all values', () {
      expect(FraudSeverity.values.length, 4);
    });
  });

  group('FraudPattern', () {
    test('has all values', () {
      expect(FraudPattern.values.length, 6);
    });
  });

  group('FraudAlert', () {
    test('copyWith updates isReviewed', () {
      final alert = FraudAlert(
        id: 'FA001',
        pattern: FraudPattern.unusualRefund,
        severity: FraudSeverity.critical,
        description: 'Test',
        transactionIds: ['TXN-001'],
        cashierId: 'CSH-001',
        cashierName: 'Test',
        timestamp: DateTime.now(),
        suggestedAction: 'Review',
        isReviewed: false,
        confidence: 0.9,
        amount: 100,
      );

      final updated = alert.copyWith(isReviewed: true);

      expect(updated.isReviewed, isTrue);
      expect(updated.id, 'FA001');
      expect(updated.pattern, FraudPattern.unusualRefund);
    });

    test('copyWith preserves isReviewed when not set', () {
      final alert = FraudAlert(
        id: 'FA001',
        pattern: FraudPattern.unusualRefund,
        severity: FraudSeverity.critical,
        description: 'Test',
        transactionIds: ['TXN-001'],
        cashierId: 'CSH-001',
        cashierName: 'Test',
        timestamp: DateTime.now(),
        suggestedAction: 'Review',
        isReviewed: true,
      );

      final updated = alert.copyWith();

      expect(updated.isReviewed, isTrue);
    });
  });

  group('detectFraud', () {
    test('returns fraud alerts', () async {
      when(() => mockDb.salesDao).thenReturn(MockSalesDao());

      final alerts = await service.detectFraud('store-1');

      expect(alerts, isNotEmpty);
      expect(alerts.length, 6);
    });

    test('alerts contain all severity levels', () async {
      when(() => mockDb.salesDao).thenReturn(MockSalesDao());

      final alerts = await service.detectFraud('store-1');

      final severities = alerts.map((a) => a.severity).toSet();
      expect(severities, contains(FraudSeverity.critical));
      expect(severities, contains(FraudSeverity.high));
      expect(severities, contains(FraudSeverity.medium));
      expect(severities, contains(FraudSeverity.low));
    });

    test('alerts contain different patterns', () async {
      when(() => mockDb.salesDao).thenReturn(MockSalesDao());

      final alerts = await service.detectFraud('store-1');

      final patterns = alerts.map((a) => a.pattern).toSet();
      expect(patterns.length, greaterThanOrEqualTo(4));
    });

    test('each alert has required data', () async {
      when(() => mockDb.salesDao).thenReturn(MockSalesDao());

      final alerts = await service.detectFraud('store-1');

      for (final alert in alerts) {
        expect(alert.id, isNotEmpty);
        expect(alert.description, isNotEmpty);
        expect(alert.cashierId, isNotEmpty);
        expect(alert.cashierName, isNotEmpty);
        expect(alert.suggestedAction, isNotEmpty);
        expect(alert.transactionIds, isNotEmpty);
      }
    });
  });

  group('getBehaviorScores', () {
    test('returns behavior scores', () async {
      when(() => mockDb.salesDao).thenReturn(MockSalesDao());

      final scores = await service.getBehaviorScores('store-1');

      expect(scores, isNotEmpty);
      expect(scores.length, 6);
    });

    test('scores are within valid range 0-100', () async {
      when(() => mockDb.salesDao).thenReturn(MockSalesDao());

      final scores = await service.getBehaviorScores('store-1');

      for (final score in scores) {
        expect(score.score, greaterThanOrEqualTo(0));
        expect(score.score, lessThanOrEqualTo(100));
      }
    });

    test('factor values are between 0 and 1', () async {
      when(() => mockDb.salesDao).thenReturn(MockSalesDao());

      final scores = await service.getBehaviorScores('store-1');

      for (final score in scores) {
        for (final factor in score.factors.values) {
          expect(factor, greaterThanOrEqualTo(0));
          expect(factor, lessThanOrEqualTo(1));
        }
      }
    });

    test('contains different trend directions', () async {
      when(() => mockDb.salesDao).thenReturn(MockSalesDao());

      final scores = await service.getBehaviorScores('store-1');

      final trends = scores.map((s) => s.trend).toSet();
      expect(trends.length, greaterThan(1));
    });
  });

  group('getInvestigation', () {
    test('returns investigation with timeline', () async {
      final investigation = await service.getInvestigation('FA001');

      expect(investigation.alertId, 'FA001');
      expect(investigation.status, InvestigationStatus.open);
      expect(investigation.timeline, isNotEmpty);
      expect(investigation.timeline.length, 3);
    });

    test('timeline events are in chronological order', () async {
      final investigation = await service.getInvestigation('FA001');

      for (int i = 0; i < investigation.timeline.length - 1; i++) {
        expect(
          investigation.timeline[i].timestamp.isBefore(
            investigation.timeline[i + 1].timestamp,
          ),
          isTrue,
        );
      }
    });
  });

  group('getSummary', () {
    test('returns complete summary', () async {
      when(() => mockDb.salesDao).thenReturn(MockSalesDao());

      final summary = await service.getSummary('store-1');

      expect(summary.totalAlerts, greaterThan(0));
      expect(summary.criticalAlerts, greaterThan(0));
      expect(summary.unreviewedAlerts, greaterThan(0));
      expect(summary.overallRiskScore, greaterThan(0));
      expect(summary.patternCounts, isNotEmpty);
    });

    test('unreviewed count equals total when none reviewed', () async {
      when(() => mockDb.salesDao).thenReturn(MockSalesDao());

      final summary = await service.getSummary('store-1');

      expect(summary.unreviewedAlerts, summary.totalAlerts);
    });

    test('pattern counts sum to total alerts', () async {
      when(() => mockDb.salesDao).thenReturn(MockSalesDao());

      final summary = await service.getSummary('store-1');

      final totalFromPatterns =
          summary.patternCounts.values.fold<int>(0, (sum, c) => sum + c);
      expect(totalFromPatterns, summary.totalAlerts);
    });
  });
}
