import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_ai/src/services/ai_fraud_detection_service.dart';
import 'package:alhai_ai/src/providers/ai_fraud_detection_providers.dart';

void main() {
  group('fraudSeverityFilterProvider', () {
    test('initial value is null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(fraudSeverityFilterProvider), isNull);
    });

    test('can be set to critical', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(fraudSeverityFilterProvider.notifier).state =
          FraudSeverity.critical;
      expect(container.read(fraudSeverityFilterProvider),
          FraudSeverity.critical);
    });

    test('can be reset to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(fraudSeverityFilterProvider.notifier).state =
          FraudSeverity.high;
      container.read(fraudSeverityFilterProvider.notifier).state = null;
      expect(container.read(fraudSeverityFilterProvider), isNull);
    });
  });

  group('fraudPatternFilterProvider', () {
    test('initial value is null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(fraudPatternFilterProvider), isNull);
    });

    test('can be set to a pattern', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(fraudPatternFilterProvider.notifier).state =
          FraudPattern.unusualRefund;
      expect(container.read(fraudPatternFilterProvider),
          FraudPattern.unusualRefund);
    });
  });

  group('selectedFraudAlertProvider', () {
    test('initial value is null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(selectedFraudAlertProvider), isNull);
    });

    test('can be set to an alert', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final alert = FraudAlert(
        id: 'FA001',
        pattern: FraudPattern.unusualRefund,
        severity: FraudSeverity.high,
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

      container.read(selectedFraudAlertProvider.notifier).state = alert;
      expect(container.read(selectedFraudAlertProvider)?.id, 'FA001');
    });
  });

  group('filteredFraudAlertsProvider', () {
    test('returns all alerts when no filters applied', () {
      final alerts = [
        FraudAlert(
          id: 'FA001',
          pattern: FraudPattern.unusualRefund,
          severity: FraudSeverity.critical,
          description: 'Test 1',
          transactionIds: ['TXN-001'],
          cashierId: 'CSH-001',
          cashierName: 'Test',
          timestamp: DateTime.now(),
          suggestedAction: 'Review',
          isReviewed: false,
        ),
        FraudAlert(
          id: 'FA002',
          pattern: FraudPattern.repeatedVoid,
          severity: FraudSeverity.medium,
          description: 'Test 2',
          transactionIds: ['TXN-002'],
          cashierId: 'CSH-002',
          cashierName: 'Test 2',
          timestamp: DateTime.now(),
          suggestedAction: 'Review',
          isReviewed: false,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          fraudAlertsProvider.overrideWith((ref) async => alerts),
        ],
      );
      addTearDown(container.dispose);

      // Wait for async provider to resolve
      container.read(fraudAlertsProvider);

      final filtered = container.read(filteredFraudAlertsProvider);
      filtered.whenData((data) {
        expect(data.length, 2);
      });
    });

    test('filters by severity when set', () {
      final alerts = [
        FraudAlert(
          id: 'FA001',
          pattern: FraudPattern.unusualRefund,
          severity: FraudSeverity.critical,
          description: 'Test 1',
          transactionIds: ['TXN-001'],
          cashierId: 'CSH-001',
          cashierName: 'Test',
          timestamp: DateTime.now(),
          suggestedAction: 'Review',
          isReviewed: false,
        ),
        FraudAlert(
          id: 'FA002',
          pattern: FraudPattern.repeatedVoid,
          severity: FraudSeverity.medium,
          description: 'Test 2',
          transactionIds: ['TXN-002'],
          cashierId: 'CSH-002',
          cashierName: 'Test 2',
          timestamp: DateTime.now(),
          suggestedAction: 'Review',
          isReviewed: false,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          fraudAlertsProvider.overrideWith((ref) async => alerts),
        ],
      );
      addTearDown(container.dispose);

      container.read(fraudSeverityFilterProvider.notifier).state =
          FraudSeverity.critical;

      final filtered = container.read(filteredFraudAlertsProvider);
      filtered.whenData((data) {
        expect(data.length, 1);
        expect(data.first.severity, FraudSeverity.critical);
      });
    });
  });
}
